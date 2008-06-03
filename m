From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 22/39] mv643xx_eth: move rx_return_buff() into its only caller
Date: Tue,  3 Jun 2008 13:02:37 +0200
Message-ID: <1212490974-23719-23-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48747 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755127AbYFCMAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:30 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx_return_buff() is also a remnant of the HAL layering that the
original mv643xx_eth driver used.  Moving it into its caller kills
the last reference to FUNC_RET_STATUS/pkt_info.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   80 ++++++++++++++++-----------------------------
 1 files changed, 28 insertions(+), 52 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2fac2b6..a54c342 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -434,74 +434,50 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_eth_private *mep)
 /* rx ***********************************************************************/
 static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
 
-static FUNC_RET_STATUS rx_return_buff(struct mv643xx_eth_private *mep,
-						struct pkt_info *pkt_info)
+static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 {
-	int used_rx_desc;	/* Where to return Rx resource */
-	volatile struct rx_desc *rx_desc;
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&mep->lock, flags);
 
-	/* Get 'used' Rx descriptor */
-	used_rx_desc = mep->rx_used_desc;
-	rx_desc = &mep->rx_desc_area[used_rx_desc];
-
-	rx_desc->buf_ptr = pkt_info->buf_ptr;
-	rx_desc->buf_size = pkt_info->byte_cnt;
-	mep->rx_skb[used_rx_desc] = pkt_info->return_info;
-
-	/* Flush the write pipe */
-
-	/* Return the descriptor to DMA ownership */
-	wmb();
-	rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
-	wmb();
-
-	/* Move the used descriptor pointer to the next descriptor */
-	mep->rx_used_desc = (used_rx_desc + 1) % mep->rx_ring_size;
-
-	spin_unlock_irqrestore(&mep->lock, flags);
-
-	return ETH_OK;
-}
-
-static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
-{
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	struct pkt_info pkt_info;
-	struct sk_buff *skb;
-	int unaligned;
-
 	while (mep->rx_desc_count < mep->rx_ring_size) {
+		struct sk_buff *skb;
+		int unaligned;
+		int rx;
+
 		skb = dev_alloc_skb(ETH_RX_SKB_SIZE + dma_get_cache_alignment());
-		if (!skb)
+		if (skb == NULL)
 			break;
-		mep->rx_desc_count++;
+
 		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
 		if (unaligned)
 			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
-		pkt_info.cmd_sts = RX_ENABLE_INTERRUPT;
-		pkt_info.byte_cnt = ETH_RX_SKB_SIZE;
-		pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
-					ETH_RX_SKB_SIZE, DMA_FROM_DEVICE);
-		pkt_info.return_info = skb;
-		if (rx_return_buff(mep, &pkt_info) != ETH_OK) {
-			printk(KERN_ERR
-				"%s: Error allocating RX Ring\n", dev->name);
-			break;
-		}
+
+		mep->rx_desc_count++;
+		rx = mep->rx_used_desc;
+		mep->rx_used_desc = (rx + 1) % mep->rx_ring_size;
+
+		mep->rx_desc_area[rx].buf_ptr = dma_map_single(NULL,
+							skb->data,
+							ETH_RX_SKB_SIZE,
+							DMA_FROM_DEVICE);
+		mep->rx_desc_area[rx].buf_size = ETH_RX_SKB_SIZE;
+		mep->rx_skb[rx] = skb;
+		wmb();
+		mep->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
+						RX_ENABLE_INTERRUPT;
+		wmb();
+
 		skb_reserve(skb, ETH_HW_IP_ALIGN);
 	}
-	/*
-	 * If RX ring is empty of SKB, set a timer to try allocating
-	 * again at a later time.
-	 */
+
 	if (mep->rx_desc_count == 0) {
-		printk(KERN_INFO "%s: Rx ring is empty\n", dev->name);
-		mep->timeout.expires = jiffies + (HZ / 10);	/* 100 mSec */
+		mep->timeout.expires = jiffies + (HZ / 10);
 		add_timer(&mep->timeout);
 	}
+
+	spin_unlock_irqrestore(&mep->lock, flags);
 }
 
 static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
-- 
1.5.3.4

