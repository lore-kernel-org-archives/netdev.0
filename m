From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 04/10] net: pad skb data and shinfo as a whole rather than individually
Date: Tue, 10 Apr 2012 15:26:18 +0100
Message-ID: <1334067984-7706-4-git-send-email-ian.campbell@citrix.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3234 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755434Ab2DJOcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 10:32:42 -0400
In-Reply-To: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reduces the minimum overhead required for this allocation such that the
shinfo can be grown in the following patch without overflowing 2048 bytes for a
1500 byte frame.

Reducing this overhead while also growing the shinfo means that sometimes the
tail end of the data can end up in the same cache line as the beginning of the
shinfo. Specifically in the case of the 64 byte cache lines on a 64 bit system
the first 8 bytes of shinfo can overlap the tail cacheline of the data. In many
cases the allocation slop means that there is no overlap.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fbc92b2..0ad6a46 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -43,17 +43,20 @@
 				 ~(SMP_CACHE_BYTES - 1))
 /* maximum data size which can fit into an allocation of X bytes */
 #define SKB_WITH_OVERHEAD(X)	\
-	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+	((X) - sizeof(struct skb_shared_info))
 /*
  * minimum allocation size required for an skb containing X bytes of data
  *
  * We do our best to align skb_shared_info on a separate cache
  * line. It usually works because kmalloc(X > SMP_CACHE_BYTES) gives
- * aligned memory blocks, unless SLUB/SLAB debug is enabled.  Both
- * skb->head and skb_shared_info are cache line aligned.
+ * aligned memory blocks, unless SLUB/SLAB debug is enabled.
+ * skb->head is aligned to a cache line while the tail of
+ * skb_shared_info is cache line aligned.  We arrange that the order
+ * of the fields in skb_shared_info is such that the interesting
+ * fields are cache line aligned and fit within a 64 byte cache line.
  */
 #define SKB_ALLOCSIZE(X)	\
-	(SKB_DATA_ALIGN((X)) + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+	(SKB_DATA_ALIGN((X) + sizeof(struct skb_shared_info)))
 
 #define SKB_MAX_ORDER(X, ORDER) \
 	SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
@@ -63,7 +66,7 @@
 /* return minimum truesize of one skb containing X bytes of data */
 #define SKB_TRUESIZE(X) ((X) +						\
 			 SKB_DATA_ALIGN(sizeof(struct sk_buff)) +	\
-			 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+			 sizeof(struct skb_shared_info))
 
 /* A. Checksumming of received packets by device.
  *
-- 
1.7.2.5
