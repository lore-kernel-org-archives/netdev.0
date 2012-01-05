From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than individually
Date: Thu, 5 Jan 2012 17:13:40 +0000
Message-ID: <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49271 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401Ab2AERXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 12:23:34 -0500
In-Reply-To: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already push the shinfo to the very end of the actual allocation which is
already cache-line aligned.

This reduces the minimum overhead required for this allocation such that the
shinfo can be grown in the following patch without overflowing 2048 bytes for a
1500 byte frame. Reducing this overhead means that sometimes the tail end of
the data can end up in the same cache line as the beginning of the shinfo but
in many cases the allocation slop means that there is no overlap.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 include/linux/skbuff.h |    4 ++--
 net/core/skbuff.c      |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 50db9b0..f04333b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -41,7 +41,7 @@
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
 #define SKB_WITH_OVERHEAD(X)	\
-	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+	((X) - sizeof(struct skb_shared_info))
 #define SKB_MAX_ORDER(X, ORDER) \
 	SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
@@ -50,7 +50,7 @@
 /* return minimum truesize of one skb containing X bytes of data */
 #define SKB_TRUESIZE(X) ((X) +						\
 			 SKB_DATA_ALIGN(sizeof(struct sk_buff)) +	\
-			 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+			 sizeof(struct skb_shared_info))
 
 /* A. Checksumming of received packets by device.
  *
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index da0c97f..b6de604 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -189,8 +189,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
 	 * Both skb->head and skb_shared_info are cache line aligned.
 	 */
-	size = SKB_DATA_ALIGN(size);
-	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	size = SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
 	data = kmalloc_node_track_caller(size, gfp_mask, node);
 	if (!data)
 		goto nodata;
-- 
1.7.2.5
