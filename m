From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v6 4/4] mac80211: multicast to unicast conversion
Date: Thu, 27 Oct 2016 14:29:53 +0200
Message-ID: <1477571393.4534.11.camel@sipsolutions.net>
References: <1476119543-24509-1-git-send-email-michael-dev@fami-braun.de>
         <1476119543-24509-4-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476119543-24509-4-git-send-email-michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> @@ -2242,6 +2242,20 @@ static int ieee80211_set_wds_peer(struct wiphy
> *wiphy, struct net_device *dev,
>  	return 0;
>  }
>  
> +static int ieee80211_set_multicast_to_unicast(struct wiphy *wiphy,
> +					      struct net_device
> *dev,
> +					      const bool enabled)

I don't understand why you put this with set_wds_peer, please add it
here also at the end like anywhere else - I've changed that for you in
the cfg80211 patch.

> +	struct ieee80211_sub_if_data *sdata =
> IEEE80211_DEV_TO_SUB_IF(dev);
> +
> +	if (sdata->vif.type != NL80211_IFTYPE_AP)
> +		return -1;

Not needed. Also, don't ever just blindly return -1 in the kernel, that
means -EPERM, i.e. permission denied.

> +/* rewrite destination mac address */

that's a pretty useless comment ...

> +/* Check if multicast to unicast conversion is needed and do it.
> + * Returns 1 if skb was freed and should not be send out.

Follow kernel convention of returning a negative error code, e.g.
-ENOTCONN in this case, and remove this comment.

> +	/* clone packets and update destination mac */
> +	list_for_each_entry_rcu(sta, &local->sta_list, list) {
> +		if (sdata != sta->sdata)
> +			continue;
> +		if (unlikely(!ether_addr_equal(eth->h_source, sta-
> >sta.addr)))
> +			/* do not send back to source */
> +			continue;
> +		if (!prev) {
> +			prev = sta;
> +			continue;
> +		}
> +		cloned_skb = skb_clone(skb, GFP_ATOMIC);
> +		if (unlikely(ieee80211_change_da(cloned_skb, prev)))
> {
> +			dev_kfree_skb(cloned_skb);
> +			continue;
> +		}
> +		__ieee80211_subif_start_xmit(cloned_skb, cloned_skb-
> >dev, 0);

I don't like the recursion here.

I think we can call this from ieee80211_subif_start_xmit(), and then do
something like

if (unlikely(multicast)) {
	struct skb_queue queue;

	__skb_queue_head_init(&queue);
	convert_frames(
	while ((skb = __skb_dequeue(&queue))
		__ieee80211_subif_start_xmit(...);
} else {
	__ieee80211_subif_start_xmit(...);
}

Yes, that's a little less efficient (RCU stuff, although that could
even move in theory), but it avoids the recursion which imho is better.

johannes
