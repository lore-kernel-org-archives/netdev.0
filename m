From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Concerns regarding PFMEMALLOC handling in __netdev_alloc_skb
Date: Thu, 28 Aug 2014 14:34:03 -0700
Message-ID: <1409261643.3173.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140828232350.70684900@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Shmulik Ladkani <sladkani@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44552 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbaH1VeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 17:34:05 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so4205862pad.35
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 14:34:05 -0700 (PDT)
In-Reply-To: <20140828232350.70684900@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-28 at 23:23 +0300, Shmulik Ladkani wrote:
> Hi,
> 
> From c93bdd0e03 "netvm: allow skb allocation to use PFMEMALLOC reserves":
> 
> @@ -366,7 +417,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
>  			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>  
>  	if (fragsz <= PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
> -		void *data = netdev_alloc_frag(fragsz);
> +		void *data;
> +
> +		if (sk_memalloc_socks())
> +			gfp_mask |= __GFP_MEMALLOC;
> +
> +		data = __netdev_alloc_frag(fragsz, gfp_mask);
>  
> 		if (likely(data)) {
> 			skb = build_skb(data, fragsz);
> 			if (unlikely(!skb))
> 				put_page(virt_to_head_page(data));
> 		}
>  	} else {
> -		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
> +		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
> +				  SKB_ALLOC_RX, NUMA_NO_NODE);
>  	}
> 
> In the 'else' part, SKB_ALLOC_RX is provided to '__alloc_skb()'.
> Thus '__alloc_skb()' may attempt using the PFMEMALLOC reserve in case
> 'sk_memalloc_socks()' is true - and 'skb->pfmemalloc' will be set
> accordingly. Good.
> 
> However, in the 'if' part, in case 'sk_memalloc_socks()' is true,
> __GFP_MEMALLOC is passed to '__netdev_alloc_frag()'.
> 
> There are two possible issues here:
> 
> 1. '__netdev_alloc_frag()' might not honour __GFP_MEMALLOC in case the
>    frag fits into current netdev_alloc_cache.frag
> 
> 2. Even if 'nc->frag.page' gets allocated/refilled, and __GFP_MEMALLOC
>    is passed to 'alloc_pages()' - in case the new page is from the
>    PFMEMALLOC reserve, that notion is not propagated to back to
>    skb->pfmemalloc.
> 
> Are these of any concern?

This was discussed few days ago.

http://www.spinics.net/lists/netdev/msg293334.html

http://www.spinics.net/lists/netdev/msg293336.html

You should sync with Govindarajulu Varadarajan to cook a proper patch.
