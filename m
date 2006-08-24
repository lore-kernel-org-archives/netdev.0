From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] add nl80211
Date: Thu, 24 Aug 2006 19:27:17 +0200
Message-ID: <20060824172717.GN3470@postel.suug.ch>
References: <1156254768.3825.1.camel@ux156> <1156435624.10283.9.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:23990 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030413AbWHXR04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 13:26:56 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156435624.10283.9.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-08-24 18:07
> +static int nl80211_get_cmdlist(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct nl80211_registered_driver *drv;
> +	struct sk_buff *msg;
> +	void *hdr;
> +	int err;
> +	struct nlattr *start;
> +	u8 *data;
> +
> +	drv = nl80211_get_drv_from_info(info);
> +	if (IS_ERR(drv))
> +		return PTR_ERR(drv);
> +
> +	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
> +			     NL80211_CMD_NEW_CMDLIST);
> +	if (IS_ERR(hdr)) {
> +		err = PTR_ERR(hdr);
> +		goto put_drv;
> +	}
> +
> +	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
> +
> +	start = nla_nest_start(msg, NL80211_ATTR_CMDS);
> +	if (!start)
> +		goto nla_put_failure;
> +	data = nla_data(start);

This data variable is now unused.

> +static int nl80211_get_wiphys(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct sk_buff *msg;
> +	void *hdr;
> +	struct nlattr *start;
> +	u32 *data;
> +	struct nl80211_registered_driver *drv;
> +
> +	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
> +			     NL80211_CMD_NEW_WIPHYS);
> +	if (IS_ERR(hdr))
> +		return PTR_ERR(hdr);
> +
> +	start = nla_nest_start(msg, NL80211_ATTR_WIPHY);
> +	if (!start)
> +		goto nla_put_failure;
> +	data = nla_data(start);
> +
> +	mutex_lock(&nl80211_drv_mutex);
> +	list_for_each_entry(drv, &nl80211_drv_list, list) {
> +		skb_put(msg, sizeof(*data));
> +		*data++ = drv->wiphy;
> +	}

I'd use normal u32 attributes here as well and simply
enumerate their type 1..n.

	int idx = 1
	list_for_each_entry(drv, &nl80211_drv_list, list)
		NLA_PUT_U32(msg, idx++, drv->wiphy);

The additional header seems waste but this way you stay flexible
and can extend the protocol later on. Attribute lengths are
checked with an open end in mind, i.e. you can put more stuff
behind that u32 in the future and your old applications will
still work.

You also might want to consider returning ifindex and
the associated name.

> +static int addifidx(void *data, int ifidx)
> +{
> +	struct sk_buff *msg = data;
> +	u32 *p;
> +
> +	if (unlikely(skb_tailroom(msg) < 4))
> +		return -ENOSPC;
> +
> +	p = (u32*)skb_put(msg, 4);
> +	*p = ifidx;
> +
> +	return 0;
> +}

Same here, just use nla_put_u32()

> +static int nl80211_get_intfs(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct nl80211_registered_driver *drv;
> +	struct sk_buff *msg;
> +	void *hdr;
> +	int err;
> +	struct nlattr *start;
> +	u8 *data;
> +
> +	drv = nl80211_get_drv_from_info(info);
> +	if (IS_ERR(drv))
> +		return PTR_ERR(drv);
> +
> +	hdr = nl80211msg_new(&msg, info->snd_pid, info->snd_seq, 0,
> +			     NL80211_CMD_GET_INTERFACES);
> +	if (IS_ERR(hdr)) {
> +		err = PTR_ERR(hdr);
> +		goto put_drv;
> +	}
> +
> +	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY, drv->wiphy);
> +
> +	start = nla_nest_start(msg, NL80211_ATTR_IFINDEX);

Try not to reuse the same attribute type for different purposes,
it will force you to duplicate the validation policy for every
single command and things become very error prone.
