From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4 6/9] xen-netback: Handle guests with too many
 frags
Date: Thu, 16 Jan 2014 00:03:15 +0000
Message-ID: <20140116000314.GD5331@zion.uk.xensource.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
 <1389731995-9887-7-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:30639 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbaAPADQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 19:03:16 -0500
Content-Disposition: inline
In-Reply-To: <1389731995-9887-7-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 08:39:52PM +0000, Zoltan Kiss wrote:
[...]
>  	/* Skip first skb fragment if it is on same page as header fragment. */
> @@ -832,6 +851,29 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>  
>  	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
>  
> +	if (frag_overflow) {
> +		struct sk_buff *nskb = xenvif_alloc_skb(0);
> +		if (unlikely(nskb == NULL)) {
> +			netdev_err(vif->dev,
> +				   "Can't allocate the frag_list skb.\n");

This, and other occurences of netdev_* logs need to be rate limit.
Otherwise you risk flooding kernel log when system is under memory
pressure.

> +			return NULL;
> +		}
> +
> +		shinfo = skb_shinfo(nskb);
> +		frags = shinfo->frags;
> +
> +		for (shinfo->nr_frags = 0; shinfo->nr_frags < frag_overflow;
> +		     shinfo->nr_frags++, txp++, gop++) {
> +			index = pending_index(vif->pending_cons++);
> +			pending_idx = vif->pending_ring[index];
> +			xenvif_tx_create_gop(vif, pending_idx, txp, gop);
> +			frag_set_pending_idx(&frags[shinfo->nr_frags],
> +					     pending_idx);
> +		}
> +
> +		skb_shinfo(skb)->frag_list = nskb;
> +	}
> +
>  	return gop;
>  }
>  
[...]
> @@ -1537,6 +1613,32 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  				  pending_idx :
>  				  INVALID_PENDING_IDX);
>  
> +		if (skb_shinfo(skb)->frag_list) {
> +			nskb = skb_shinfo(skb)->frag_list;
> +			xenvif_fill_frags(vif, nskb, INVALID_PENDING_IDX);
> +			skb->len += nskb->len;
> +			skb->data_len += nskb->len;
> +			skb->truesize += nskb->truesize;
> +			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +			skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +			vif->tx_zerocopy_sent += 2;
> +			nskb = skb;
> +
> +			skb = skb_copy_expand(skb,
> +					      0,
> +					      0,
> +					      GFP_ATOMIC | __GFP_NOWARN);
> +			if (!skb) {
> +				netdev_dbg(vif->dev,
> +					   "Can't consolidate skb with too many fragments\n");

Rate limit.

> +				if (skb_shinfo(nskb)->destructor_arg)
> +					skb_shinfo(nskb)->tx_flags |=
> +						SKBTX_DEV_ZEROCOPY;

Why is this needed? nskb is the saved pointer to original skb, which has
already had SKBTX_DEV_ZEROCOPY in tx_flags. Did I miss something?

Wei.

> +				kfree_skb(nskb);
> +				continue;
> +			}
> +			skb_shinfo(skb)->destructor_arg = NULL;
> +		}
>  		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
>  			int target = min_t(int, skb->len, PKT_PROT_LEN);
>  			__pskb_pull_tail(skb, target - skb_headlen(skb));
> @@ -1590,6 +1692,9 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  		}
>  
>  		netif_receive_skb(skb);
> +
> +		if (nskb)
> +			kfree_skb(nskb);
>  	}
>  
>  	return work_done;
