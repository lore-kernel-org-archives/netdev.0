From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] add nl80211
Date: Thu, 24 Aug 2006 16:36:34 +0200
Message-ID: <20060824143634.GM3470@postel.suug.ch>
References: <1156254768.3825.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:10417 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751587AbWHXOgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 10:36:14 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156254768.3825.1.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-08-22 15:52
> +static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
> +	[NL80211_ATTR_IFINDEX] = { .type = NLA_U32 },
> +	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
> +	[NL80211_ATTR_FLAGS] = { .type = NLA_U32 },
> +	[NL80211_ATTR_QUEUE] = { .type = NLA_U32 },
> +	[NL80211_ATTR_FRAME] = { .type = NLA_STRING, .len = 2500 },

Might want to put this in a header so userspace can see the limit.

> +	[NL80211_ATTR_IFNAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ-1 },
> +};
> +
> +static int nl80211_get_commands(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct nl80211_registered_driver *drv;
> +	struct sk_buff *msg;
> +	void *hdr;
> +	int err;
> +	struct nlattr *start;
> +	u8 *data;
> +
> +	drv = nl80211_drv_from_info_with_locking(info);
> +	if (IS_ERR(drv))
> +		return PTR_ERR(drv);
> +
> +	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
> +			     NL80211_CMD_GET_COMMANDS);

This isn't wrong in particular but usually we reverse the
meaning of the command when sending back answers, i.e. in
your case you'd define CMD_GET_COMMAND and CMD_NEW_COMMAND
with the following behaviour:

CMD_GET_COMMAND
   Search for command specified by the attributes and send
   back a CMD_NEW_COMMAND message.

CMD_GET_COMMAND with NLM_F_DUMP
   Iterate over all commands  and send back a CMD_NEW_COMMAND
   message for each command.

In your case I'd call it GET_CMDLIST and NEW_CMDLIST which
means you request a command list with GET_CMDLIST and
receive the answer with a CMD_NEWLIST message.


> +	start = nla_nest_start(msg, NL80211_ATTR_CMDS);
> +	if (!start)
> +		goto nla_nest_failure;
> +	data = nla_data(start);
> +
> +	/* unconditionally allow some common commands we handle centrally */
> +	skb_put(msg, 1);
> +	*data++ = NL80211_CMD_GET_COMMANDS;
> +	skb_put(msg, 1);
> +	*data++ = NL80211_CMD_GET_WIPHYS;
> +	skb_put(msg, 1);
> +	*data++ = NL80211_CMD_GET_INTERFACES;
> +
> +	CHECK_CMD(inject_packet, INJECT);
> +	CHECK_CMD(add_virtual_intf, ADD_VIRTUAL_INTERFACE);
> +	CHECK_CMD(del_virtual_intf, DEL_VIRTUAL_INTERFACE);
> +
> +	nla_nest_end(msg, start);

I'd just use the command id as attribute type:

	NLA_PUT_FLAG(msg, NL80211_CMD_GET_COMMANDS);
	NLA_PUT_FLAG(msg, NL80211_CMD_GET_WIPHYS);
	....

This makes checking avaibility of a command as easy as
accessing an array for userspace.


> +	err = genlmsg_end(msg, hdr);
> +	if (err)
> +		goto msg_free;

genlmsg_end() can't fail, it just returns skb->len which
is only of importance while dumping to see if there is
still more to dump or not.

> +void *nl80211msg_new(struct sk_buff **skb, u32 pid, u32 seq, int flags, u8 cmd)
> +{
> +	void *hdr;
> +
> +	*skb = nlmsg_new(NLMSG_GOODSIZE);
> +	if (!*skb)
> +		return ERR_PTR(-ENOBUFS);
> +
> +	hdr = nl80211hdr_put(*skb, pid, seq, flags, cmd);
> +	if (!hdr) {
> +		nlmsg_free(*skb);
> +		/* what would be a good error here? */
> +		return ERR_PTR(-EINVAL);
> +	}

ENOBUFS


You might want to send out notifications for various events such as the
additiona and deletion of virtual interfaces etc.
