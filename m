From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT 4/4] mac80211: use multi-queue master netdevice
Date: Wed, 30 Apr 2008 16:37:33 +0200
Message-ID: <200804301637.35170.IvDoorn@gmail.com>
References: <20080430124055.091382000@sipsolutions.net> <20080430130051.397094000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080430130051.397094000-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Overall the rt2x00 changes are good, but I have a few suggestions :)

> --- everything.orig/drivers/net/wireless/rt2x00/rt2x00mac.c	2008-04-30 14:02:32.000000000 +0200
> +++ everything/drivers/net/wireless/rt2x00/rt2x00mac.c	2008-04-30 14:02:34.000000000 +0200
> @@ -81,7 +81,7 @@ int rt2x00mac_tx(struct ieee80211_hw *hw
>  {
>  	struct rt2x00_dev *rt2x00dev = hw->priv;
>  	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr *)skb->data;
> -	enum data_queue_qid qid = mac80211_queue_to_qid(control->queue);
> +	enum data_queue_qid qid = skb_get_queue_mapping(skb);
>  	struct data_queue *queue;
>  	struct skb_frame_desc *skbdesc;
>  	u16 frame_control;
> @@ -129,12 +129,14 @@ int rt2x00mac_tx(struct ieee80211_hw *hw
>  			       IEEE80211_TXCTL_USE_CTS_PROTECT)) &&
>  	    !rt2x00dev->ops->hw->set_rts_threshold) {
>  		if (rt2x00queue_available(queue) <= 1) {
> -			ieee80211_stop_queue(rt2x00dev->hw, control->queue);
> +			ieee80211_stop_queue(
> +				rt2x00dev->hw, skb_get_queue_mapping(skb));

ieee80211_stop_queue(rt2x00dev->hw, qid);
The result of skb_get_queue_mapping(skb) was already stored in the
'qid' variable at the start of the function. And since this is a 1-1 mapping
from skb queue to rt2x00 queue, it is safe to use 'qid' directly in all instances.

>  			return NETDEV_TX_BUSY;
>  		}
>  
>  		if (rt2x00mac_tx_rts_cts(rt2x00dev, queue, skb, control)) {
> -			ieee80211_stop_queue(rt2x00dev->hw, control->queue);
> +			ieee80211_stop_queue(
> +				rt2x00dev->hw, skb_get_queue_mapping(skb));

ieee80211_stop_queue(rt2x00dev->hw, qid);

>  			return NETDEV_TX_BUSY;
>  		}
>  	}
> @@ -146,12 +148,12 @@ int rt2x00mac_tx(struct ieee80211_hw *hw
>  	memset(skbdesc, 0, sizeof(*skbdesc));
>  
>  	if (rt2x00dev->ops->lib->write_tx_data(rt2x00dev, queue, skb, control)) {
> -		ieee80211_stop_queue(rt2x00dev->hw, control->queue);
> +		ieee80211_stop_queue(rt2x00dev->hw, skb_get_queue_mapping(skb));

ieee80211_stop_queue(rt2x00dev->hw, qid);

>  		return NETDEV_TX_BUSY;
>  	}
>  
>  	if (rt2x00queue_full(queue))
> -		ieee80211_stop_queue(rt2x00dev->hw, control->queue);
> +		ieee80211_stop_queue(rt2x00dev->hw, skb_get_queue_mapping(skb));

ieee80211_stop_queue(rt2x00dev->hw, qid);

>  	if (rt2x00dev->ops->lib->kick_tx_queue)
>  		rt2x00dev->ops->lib->kick_tx_queue(rt2x00dev, qid);

Thanks,

Ivo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
