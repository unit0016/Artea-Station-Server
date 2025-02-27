/*

Here's how to use the chat system with configs

send2adminchat is a simple function that broadcasts to admin channels

send2chat is a bit verbose but can be very specific

The second parameter is a string, this string should be read from a config.
What this does is dictacte which TGS4 channels can be sent to.

For example if you have the following channels in tgs4 set up
- Channel 1, Tag: asdf
- Channel 2, Tag: bombay,asdf
- Channel 3, Tag: Hello my name is asdf
- Channel 4, No Tag
- Channel 5, Tag: butts

and you make the call:

send2chat("I sniff butts", CONFIG_GET(string/where_to_send_sniff_butts))

and the config option is set like:

WHERE_TO_SEND_SNIFF_BUTTS asdf

It will be sent to channels 1 and 2

Alternatively if you set the config option to just:

WHERE_TO_SEND_SNIFF_BUTTS

it will be sent to all connected chats.

In TGS3 it will always be sent to all connected designated game chats.
*/

/**
 * Sends a message to TGS chat channels.
 *
 * message - The message to send.
 * channel_tag - Required. If "", the message with be sent to all connected (Game-type for TGS3) channels. Otherwise, it will be sent to TGS4 channels with that tag (Delimited by ','s).
 * admin_only - Determines if this communication can only be sent to admin only channels.
 */
/proc/send2chat(message, channel_tag, admin_only = FALSE)
	if(channel_tag == null || !world.TgsAvailable())
		return

	var/datum/tgs_version/version = world.TgsVersion()
	if(channel_tag == "" || version.suite == 3)
		world.TgsTargetedChatBroadcast(message, admin_only)
		return

	var/list/channels_to_use = list()
	for(var/I in world.TgsChatChannelInfo())
		var/datum/tgs_chat_channel/channel = I
		var/list/applicable_tags = splittext(channel.custom_tag, ",")
		if((!admin_only || channel.is_admin_channel) && (channel_tag in applicable_tags))
			channels_to_use += channel

	if(channels_to_use.len)
		world.TgsChatBroadcast(message, channels_to_use)

/**
 * Sends a message to TGS admin chat channels.
 *
 * category - The category of the mssage.
 * message - The message to send.
 */
/proc/send2adminchat(category, message, embed_links = FALSE)
	category = replacetext(replacetext(category, "\proper", ""), "\improper", "")
	message = replacetext(replacetext(message, "\proper", ""), "\improper", "")
	if(!embed_links)
		message = GLOB.has_discord_embeddable_links.Replace(replacetext(message, "`", ""), " ```$1``` ")
	world.TgsTargetedChatBroadcast("[category] | [message]", TRUE)

/// Handles text formatting for item use hints in examine text
#define EXAMINE_HINT(text) ("<b>" + text + "</b>")

/**
 * Returns a boolean based on whether or not the string contains a comma or an apostrophe,
 * to be used for emotes to decide whether or not to have a space between the name of the user
 * and the emote.
 *
 * Requires the message to be HTML decoded beforehand. Not doing it here for performance reasons.
 *
 * Returns TRUE if there should be a space, FALSE if there shouldn't.
 */
/proc/should_have_space_before_emote(string)
	var/static/regex/no_spacing_emote_characters = regex(@"(,|')")
	return no_spacing_emote_characters.Find(string) ? FALSE : TRUE
