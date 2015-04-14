From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/4] mac80211-hwsim: notify user-space about channel
 change.
Date: Tue, 14 Apr 2015 10:14:09 +0200
Message-ID: <1428999249.3019.7.camel@sipsolutions.net>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54358 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659AbbDNIOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:14:12 -0400
In-Reply-To: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +static void mac80211_hwsim_check_nl_notify(struct mac80211_hwsim_data *data)
> +{
> +	struct sk_buff *skb;
> +	u32 center_freq = 0;
> +	u32 _portid;
> +	void *msg_head;
> +
> +	/* wmediumd mode check */
> +	_portid = ACCESS_ONCE(wmediumd_portid);
> +
> +	if (!_portid)
> +		return;
> +
> +	skb = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> +	if (skb == NULL)
> +		goto err_print;
> +
> +	msg_head = genlmsg_put(skb, 0, 0, &hwsim_genl_family, 0,
> +			       HWSIM_CMD_NOTIFY);
> +	if (msg_head == NULL) {
> +		printk(KERN_DEBUG "mac80211_hwsim: problem with msg_head, notify\n");

None of this can really happen, so I don't think you should print
anything here. It's just a waste of space in all ways I think.

> +	if (nla_put(skb, HWSIM_ATTR_ADDR_TRANSMITTER,
> +		    ETH_ALEN, data->addresses[1].addr))

That doesn't seem right, Bob just fixed the code to not do this any
more.

> +	if (nla_put_u32(skb, HWSIM_ATTR_FREQ, center_freq))
> +		goto nla_put_failure;

You shouldn't unconditionally put this attribute but just leave it out
when the channel isn't known. However, see below.

> +nla_put_failure:
> +	nlmsg_free(skb);
> +err_print:
> +	printk(KERN_DEBUG "mac80211_hwsim: error occurred in %s\n", __func__);

ditto.

> @@ -1465,6 +1511,8 @@ static int mac80211_hwsim_config(struct ieee80211_hw *hw, u32 changed)
>  				      HRTIMER_MODE_REL);
>  	}
>  
> +	mac80211_hwsim_check_nl_notify(data);

Still this bothers me a bit, if you enable multi-channel in hwsim, you
don't actually get a data->channel, which renders this functionality
useless, you might never get this message.

Wouldn't it be better to have an API to wmediumd and similar userspace
that didn't break as soon as you enable multi-channel?

johannes
