From: Shmulik Ladkani <sladkani@cisco.com>
Subject: Concerns regarding PFMEMALLOC handling in __netdev_alloc_skb
Date: Thu, 28 Aug 2014 23:23:50 +0300
Message-ID: <20140828232350.70684900@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Neil Brown <neilb@suse.de>, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mel Gorman <mgorman@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aer-iport-1.cisco.com ([173.38.203.51]:53214 "EHLO
	aer-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaH1Udm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 16:33:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>From c93bdd0e03 "netvm: allow skb allocation to use PFMEMALLOC reserves":

@@ -366,7 +417,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	if (fragsz <= PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
-		void *data = netdev_alloc_frag(fragsz);
+		void *data;
+
+		if (sk_memalloc_socks())
+			gfp_mask |= __GFP_MEMALLOC;
+
+		data = __netdev_alloc_frag(fragsz, gfp_mask);
 
		if (likely(data)) {
			skb = build_skb(data, fragsz);
			if (unlikely(!skb))
				put_page(virt_to_head_page(data));
		}
 	} else {
-		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
+		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
+				  SKB_ALLOC_RX, NUMA_NO_NODE);
 	}

In the 'else' part, SKB_ALLOC_RX is provided to '__alloc_skb()'.
Thus '__alloc_skb()' may attempt using the PFMEMALLOC reserve in case
'sk_memalloc_socks()' is true - and 'skb->pfmemalloc' will be set
accordingly. Good.

However, in the 'if' part, in case 'sk_memalloc_socks()' is true,
__GFP_MEMALLOC is passed to '__netdev_alloc_frag()'.

There are two possible issues here:

1. '__netdev_alloc_frag()' might not honour __GFP_MEMALLOC in case the
   frag fits into current netdev_alloc_cache.frag

2. Even if 'nc->frag.page' gets allocated/refilled, and __GFP_MEMALLOC
   is passed to 'alloc_pages()' - in case the new page is from the
   PFMEMALLOC reserve, that notion is not propagated to back to
   skb->pfmemalloc.

Are these of any concern?

Regards,
Shmulik
