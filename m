From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 01/10] net: add and use SKB_ALLOCSIZE
Date: Tue, 10 Apr 2012 15:26:15 +0100
Message-ID: <1334067984-7706-1-git-send-email-ian.campbell@citrix.com>
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
	id S1758795Ab2DJOck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 10:32:40 -0400
In-Reply-To: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gives the allocation size required for an skb containing X bytes of data

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/ethernet/broadcom/bnx2.c        |    7 +++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    3 +--
 drivers/net/ethernet/broadcom/tg3.c         |    3 +--
 include/linux/skbuff.h                      |   12 ++++++++++++
 net/core/skbuff.c                           |    8 +-------
 5 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 8297e28..dede71f 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -5321,8 +5321,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	/* 8 for CRC and VLAN */
 	rx_size = bp->dev->mtu + ETH_HLEN + BNX2_RX_OFFSET + 8;
 
-	rx_space = SKB_DATA_ALIGN(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD +
-		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	rx_space = SKB_ALLOCSIZE(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD;
 
 	bp->rx_copy_thresh = BNX2_RX_COPY_THRESH;
 	bp->rx_pg_ring_size = 0;
@@ -5345,8 +5344,8 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 
 	bp->rx_buf_use_size = rx_size;
 	/* hw alignment + build_skb() overhead*/
-	bp->rx_buf_size = SKB_DATA_ALIGN(bp->rx_buf_use_size + BNX2_RX_ALIGN) +
-		NET_SKB_PAD + SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	bp->rx_buf_size = SKB_ALLOCSIZE(bp->rx_buf_use_size + BNX2_RX_ALIGN) +
+		NET_SKB_PAD;
 	bp->rx_jumbo_thresh = rx_size - BNX2_RX_OFFSET;
 	bp->rx_ring_size = size;
 	bp->rx_max_ring = bnx2_find_max_ring(size, MAX_RX_RINGS);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e37161f..12f2ceb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1229,8 +1229,7 @@ struct bnx2x {
 #define BNX2X_FW_RX_ALIGN_START	(1UL << BNX2X_RX_ALIGN_SHIFT)
 
 #define BNX2X_FW_RX_ALIGN_END					\
-	max(1UL << BNX2X_RX_ALIGN_SHIFT, 			\
-	    SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+	max(1UL << BNX2X_RX_ALIGN_SHIFT, SKB_ALLOCSIZE(0))
 
 #define BNX2X_PXP_DRAM_ALIGN		(BNX2X_RX_ALIGN_SHIFT - 5)
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7b71387..4d4b063 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5672,8 +5672,7 @@ static int tg3_alloc_rx_data(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 	 * Callers depend upon this behavior and assume that
 	 * we leave everything unchanged if we fail.
 	 */
-	skb_size = SKB_DATA_ALIGN(data_size + TG3_RX_OFFSET(tp)) +
-		   SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	skb_size = SKB_ALLOCSIZE(data_size + TG3_RX_OFFSET(tp));
 	data = kmalloc(skb_size, GFP_ATOMIC);
 	if (!data)
 		return -ENOMEM;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 192250b..fbc92b2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -41,8 +41,20 @@
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
+/* maximum data size which can fit into an allocation of X bytes */
 #define SKB_WITH_OVERHEAD(X)	\
 	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+/*
+ * minimum allocation size required for an skb containing X bytes of data
+ *
+ * We do our best to align skb_shared_info on a separate cache
+ * line. It usually works because kmalloc(X > SMP_CACHE_BYTES) gives
+ * aligned memory blocks, unless SLUB/SLAB debug is enabled.  Both
+ * skb->head and skb_shared_info are cache line aligned.
+ */
+#define SKB_ALLOCSIZE(X)	\
+	(SKB_DATA_ALIGN((X)) + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+
 #define SKB_MAX_ORDER(X, ORDER) \
 	SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a690cae..59a1ecb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -184,13 +184,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		goto out;
 	prefetchw(skb);
 
-	/* We do our best to align skb_shared_info on a separate cache
-	 * line. It usually works because kmalloc(X > SMP_CACHE_BYTES) gives
-	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
-	 * Both skb->head and skb_shared_info are cache line aligned.
-	 */
-	size = SKB_DATA_ALIGN(size);
-	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	size = SKB_ALLOCSIZE(size);
 	data = kmalloc_node_track_caller(size, gfp_mask, node);
 	if (!data)
 		goto nodata;
-- 
1.7.2.5
