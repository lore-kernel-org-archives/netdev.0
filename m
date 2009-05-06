From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/5] mv643xx_eth: rework receive skb cache alignment
Date: Wed, 6 May 2009 15:01:22 +0200
Message-ID: <20090506130122.GI24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40437 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274AbZEFMyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 08:54:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the platforms that mv643xx_eth is used on, the manual skb->data
alignment logic in mv643xx_eth can be simplified, as the only case we
need to handle is where NET_SKB_PAD is not a multiple of the cache
line size.  If this is the case, the extra padding we need can be
computed at compile time, while if NET_SKB_PAD _is_ a multiple of
the cache line size, the code can be optimised out entirely.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index cc16f3e..05bb1c5 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -174,6 +174,7 @@ static char mv643xx_eth_driver_version[] = "1.4";
  */
 #define DEFAULT_RX_QUEUE_SIZE	128
 #define DEFAULT_TX_QUEUE_SIZE	256
+#define SKB_DMA_REALIGN		((PAGE_SIZE - NET_SKB_PAD) % SMP_CACHE_BYTES)
 
 
 /*
@@ -649,23 +650,20 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 	refilled = 0;
 	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
 		struct sk_buff *skb;
-		int unaligned;
 		int rx;
 		struct rx_desc *rx_desc;
 
 		skb = __skb_dequeue(&mp->rx_recycle);
 		if (skb == NULL)
-			skb = dev_alloc_skb(mp->skb_size +
-					    dma_get_cache_alignment() - 1);
+			skb = dev_alloc_skb(mp->skb_size);
 
 		if (skb == NULL) {
 			mp->oom = 1;
 			goto oom;
 		}
 
-		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
-		if (unaligned)
-			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
+		if (SKB_DMA_REALIGN)
+			skb_reserve(skb, SKB_DMA_REALIGN);
 
 		refilled++;
 		rxq->rx_desc_count++;
@@ -964,8 +962,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		if (skb != NULL) {
 			if (skb_queue_len(&mp->rx_recycle) <
 					mp->rx_ring_size &&
-			    skb_recycle_check(skb, mp->skb_size +
-					dma_get_cache_alignment() - 1))
+			    skb_recycle_check(skb, mp->skb_size))
 				__skb_queue_head(&mp->rx_recycle, skb);
 			else
 				dev_kfree_skb(skb);
@@ -2336,6 +2333,14 @@ static void mv643xx_eth_recalc_skb_size(struct mv643xx_eth_private *mp)
 	 * size field are ignored by the hardware.
 	 */
 	mp->skb_size = (skb_size + 7) & ~7;
+
+	/*
+	 * If NET_SKB_PAD is smaller than a cache line,
+	 * netdev_alloc_skb() will cause skb->data to be misaligned
+	 * to a cache line boundary.  If this is the case, include
+	 * some extra space to allow re-aligning the data area.
+	 */
+	mp->skb_size += SKB_DMA_REALIGN;
 }
 
 static int mv643xx_eth_open(struct net_device *dev)
-- 
1.5.6.4
