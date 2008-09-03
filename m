From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 15/17] mv643xx_eth: move all work to the napi poll handler
Date: Wed,  3 Sep 2008 14:29:42 +0200
Message-ID: <1220444984-20150-16-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52898 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753016AbYICM3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:50 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move link status handling, transmit reclaim and TX_END handling from
the interrupt handler to the napi poll handler.  This allows switching
->lock over to a non-IRQ-safe lock and removes all explicit interrupt
disabling from the driver.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  524 ++++++++++++++++++++++++---------------------
 1 files changed, 277 insertions(+), 247 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1ceed87..632f4b4 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -57,7 +57,6 @@
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.3";
 
-#define MV643XX_ETH_TX_FAST_REFILL
 
 /*
  * Registers shared between all ports.
@@ -103,7 +102,6 @@ static char mv643xx_eth_driver_version[] = "1.3";
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
-#define  INT_TX_END_0			0x00080000
 #define  INT_TX_END			0x07f80000
 #define  INT_RX				0x000003fc
 #define  INT_EXT			0x00000002
@@ -355,6 +353,14 @@ struct mv643xx_eth_private {
 	struct work_struct tx_timeout_task;
 	struct mii_if_info mii;
 
+	struct napi_struct napi;
+	u8 work_link;
+	u8 work_tx;
+	u8 work_tx_end;
+	u8 work_rx;
+	u8 work_rx_refill;
+	u8 work_rx_oom;
+
 	/*
 	 * RX state.
 	 */
@@ -362,7 +368,6 @@ struct mv643xx_eth_private {
 	unsigned long rx_desc_sram_addr;
 	int rx_desc_sram_size;
 	int rxq_count;
-	struct napi_struct napi;
 	struct timer_list rx_oom;
 	struct rx_queue rxq[8];
 
@@ -374,9 +379,6 @@ struct mv643xx_eth_private {
 	int tx_desc_sram_size;
 	int txq_count;
 	struct tx_queue txq[8];
-#ifdef MV643XX_ETH_TX_FAST_REFILL
-	int tx_clean_threshold;
-#endif
 };
 
 
@@ -446,82 +448,19 @@ static void txq_disable(struct tx_queue *txq)
 		udelay(10);
 }
 
-static void __txq_maybe_wake(struct tx_queue *txq)
+static void txq_maybe_wake(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 
+	spin_lock(&mp->lock);
 	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
 		netif_tx_wake_queue(nq);
+	spin_unlock(&mp->lock);
 }
 
 
-/* rx ***********************************************************************/
-static void txq_reclaim(struct tx_queue *txq, int force);
-
-static int rxq_refill(struct rx_queue *rxq, int budget, int *oom)
-{
-	int skb_size;
-	int refilled;
-
-	/*
-	 * Reserve 2+14 bytes for an ethernet header (the hardware
-	 * automatically prepends 2 bytes of dummy data to each
-	 * received packet), 16 bytes for up to four VLAN tags, and
-	 * 4 bytes for the trailing FCS -- 36 bytes total.
-	 */
-	skb_size = rxq_to_mp(rxq)->dev->mtu + 36;
-
-	/*
-	 * Make sure that the skb size is a multiple of 8 bytes, as
-	 * the lower three bits of the receive descriptor's buffer
-	 * size field are ignored by the hardware.
-	 */
-	skb_size = (skb_size + 7) & ~7;
-
-	refilled = 0;
-	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
-		struct sk_buff *skb;
-		int unaligned;
-		int rx;
-
-		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
-		if (skb == NULL) {
-			*oom = 1;
-			break;
-		}
-
-		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
-		if (unaligned)
-			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
-
-		refilled++;
-		rxq->rx_desc_count++;
-
-		rx = rxq->rx_used_desc++;
-		if (rxq->rx_used_desc == rxq->rx_ring_size)
-			rxq->rx_used_desc = 0;
-
-		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
-						skb_size, DMA_FROM_DEVICE);
-		rxq->rx_desc_area[rx].buf_size = skb_size;
-		rxq->rx_skb[rx] = skb;
-		wmb();
-		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
-						RX_ENABLE_INTERRUPT;
-		wmb();
-
-		/*
-		 * The hardware automatically prepends 2 bytes of
-		 * dummy data to each received packet, so that the
-		 * IP header ends up 16-byte aligned.
-		 */
-		skb_reserve(skb, 2);
-	}
-
-	return refilled;
-}
-
+/* rx napi ******************************************************************/
 static int rxq_process(struct rx_queue *rxq, int budget)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
@@ -553,6 +492,8 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		rxq->rx_desc_count--;
 		rx++;
 
+		mp->work_rx_refill |= 1 << rxq->index;
+
 		/*
 		 * Update statistics.
 		 *
@@ -605,54 +546,78 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		mp->dev->last_rx = jiffies;
 	}
 
+	if (rx < budget)
+		mp->work_rx &= ~(1 << rxq->index);
+
 	return rx;
 }
 
-static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
+static int rxq_refill(struct rx_queue *rxq, int budget)
 {
-	struct mv643xx_eth_private *mp;
-	int work_done;
-	int oom;
-	int i;
+	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
+	int skb_size;
+	int refilled;
 
-	mp = container_of(napi, struct mv643xx_eth_private, napi);
+	/*
+	 * Reserve 2+14 bytes for an ethernet header (the hardware
+	 * automatically prepends 2 bytes of dummy data to each
+	 * received packet), 16 bytes for up to four VLAN tags, and
+	 * 4 bytes for the trailing FCS -- 36 bytes total.
+	 */
+	skb_size = rxq_to_mp(rxq)->dev->mtu + 36;
 
-#ifdef MV643XX_ETH_TX_FAST_REFILL
-	if (++mp->tx_clean_threshold > 5) {
-		mp->tx_clean_threshold = 0;
-		for (i = 0; i < mp->txq_count; i++)
-			txq_reclaim(mp->txq + i, 0);
+	/*
+	 * Make sure that the skb size is a multiple of 8 bytes, as
+	 * the lower three bits of the receive descriptor's buffer
+	 * size field are ignored by the hardware.
+	 */
+	skb_size = (skb_size + 7) & ~7;
 
-		spin_lock_irq(&mp->lock);
-		__txq_maybe_wake(mp->txq);
-		spin_unlock_irq(&mp->lock);
-	}
-#endif
+	refilled = 0;
+	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
+		struct sk_buff *skb;
+		int unaligned;
+		int rx;
 
-	work_done = 0;
-	oom = 0;
-	for (i = mp->rxq_count - 1; work_done < budget && i >= 0; i--) {
-		struct rx_queue *rxq = mp->rxq + i;
+		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
+		if (skb == NULL) {
+			mp->work_rx_oom |= 1 << rxq->index;
+			goto oom;
+		}
 
-		work_done += rxq_process(rxq, budget - work_done);
-		work_done += rxq_refill(rxq, budget - work_done, &oom);
-	}
+		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
+		if (unaligned)
+			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
 
-	if (work_done < budget) {
-		if (oom)
-			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
-		netif_rx_complete(mp->dev, napi);
-		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
-	}
+		refilled++;
+		rxq->rx_desc_count++;
 
-	return work_done;
-}
+		rx = rxq->rx_used_desc++;
+		if (rxq->rx_used_desc == rxq->rx_ring_size)
+			rxq->rx_used_desc = 0;
 
-static inline void oom_timer_wrapper(unsigned long data)
-{
-	struct mv643xx_eth_private *mp = (void *)data;
+		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
+						skb_size, DMA_FROM_DEVICE);
+		rxq->rx_desc_area[rx].buf_size = skb_size;
+		rxq->rx_skb[rx] = skb;
+		wmb();
+		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
+						RX_ENABLE_INTERRUPT;
+		wmb();
 
-	napi_schedule(&mp->napi);
+		/*
+		 * The hardware automatically prepends 2 bytes of
+		 * dummy data to each received packet, so that the
+		 * IP header ends up 16-byte aligned.
+		 */
+		skb_reserve(skb, 2);
+	}
+
+	if (refilled < budget)
+		mp->work_rx_refill &= ~(1 << rxq->index);
+
+oom:
+	return refilled;
 }
 
 
@@ -807,9 +772,8 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	wmb();
 	desc->cmd_sts = cmd_sts;
 
-	/* clear TX_END interrupt status */
-	wrl(mp, INT_CAUSE(mp->port_num), ~(INT_TX_END_0 << txq->index));
-	rdl(mp, INT_CAUSE(mp->port_num));
+	/* clear TX_END status */
+	mp->work_tx_end &= ~(1 << txq->index);
 
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
@@ -825,7 +789,6 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	int queue;
 	struct tx_queue *txq;
 	struct netdev_queue *nq;
-	unsigned long flags;
 	int entries_left;
 
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
@@ -840,10 +803,10 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	txq = mp->txq + queue;
 	nq = netdev_get_tx_queue(dev, queue);
 
-	spin_lock_irqsave(&mp->lock, flags);
+	spin_lock(&mp->lock);
 
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
-		spin_unlock_irqrestore(&mp->lock, flags);
+		spin_unlock(&mp->lock);
 		if (net_ratelimit())
 			dev_printk(KERN_ERR, &dev->dev, "tx queue full?!\n");
 		kfree_skb(skb);
@@ -859,12 +822,105 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (entries_left < MAX_SKB_FRAGS + 1)
 		netif_tx_stop_queue(nq);
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	spin_unlock(&mp->lock);
 
 	return NETDEV_TX_OK;
 }
 
 
+/* tx napi ******************************************************************/
+static void txq_kick(struct tx_queue *txq)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	u32 hw_desc_ptr;
+	u32 expected_ptr;
+
+	spin_lock(&mp->lock);
+
+	if (rdl(mp, TXQ_COMMAND(mp->port_num)) & (1 << txq->index))
+		goto out;
+
+	hw_desc_ptr = rdl(mp, TXQ_CURRENT_DESC_PTR(mp->port_num, txq->index));
+	expected_ptr = (u32)txq->tx_desc_dma +
+				txq->tx_curr_desc * sizeof(struct tx_desc);
+
+	if (hw_desc_ptr != expected_ptr)
+		txq_enable(txq);
+
+out:
+	spin_unlock(&mp->lock);
+
+	mp->work_tx_end &= ~(1 << txq->index);
+}
+
+static int txq_reclaim(struct tx_queue *txq, int budget, int force)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int reclaimed;
+
+	spin_lock(&mp->lock);
+
+	reclaimed = 0;
+	while (reclaimed < budget && txq->tx_desc_count > 0) {
+		int tx_index;
+		struct tx_desc *desc;
+		u32 cmd_sts;
+		struct sk_buff *skb;
+		dma_addr_t addr;
+		int count;
+
+		tx_index = txq->tx_used_desc;
+		desc = &txq->tx_desc_area[tx_index];
+		cmd_sts = desc->cmd_sts;
+
+		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+			if (!force)
+				break;
+			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
+		}
+
+		txq->tx_used_desc = tx_index + 1;
+		if (txq->tx_used_desc == txq->tx_ring_size)
+			txq->tx_used_desc = 0;
+
+		reclaimed++;
+		txq->tx_desc_count--;
+
+		addr = desc->buf_ptr;
+		count = desc->byte_cnt;
+		skb = txq->tx_skb[tx_index];
+		txq->tx_skb[tx_index] = NULL;
+
+		if (cmd_sts & ERROR_SUMMARY) {
+			dev_printk(KERN_INFO, &mp->dev->dev, "tx error\n");
+			mp->dev->stats.tx_errors++;
+		}
+
+		/*
+		 * Drop mp->lock while we free the skb.
+		 */
+		spin_unlock(&mp->lock);
+
+		if (cmd_sts & TX_FIRST_DESC)
+			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
+		else
+			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
+
+		if (skb)
+			dev_kfree_skb(skb);
+
+		spin_lock(&mp->lock);
+	}
+
+	if (reclaimed < budget)
+		mp->work_tx &= ~(1 << txq->index);
+
+	spin_unlock(&mp->lock);
+
+	return reclaimed;
+}
+
+
 /* tx rate control **********************************************************/
 /*
  * Set total maximum TX rate (shared by all TX queues for this port)
@@ -1648,7 +1704,6 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	return 0;
 
-
 out_free:
 	if (index == 0 && size <= mp->tx_desc_sram_size)
 		iounmap(txq->tx_desc_area);
@@ -1661,84 +1716,75 @@ out:
 	return -ENOMEM;
 }
 
-static void txq_reclaim(struct tx_queue *txq, int force)
+static void txq_deinit(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-	unsigned long flags;
 
-	spin_lock_irqsave(&mp->lock, flags);
-	while (txq->tx_desc_count > 0) {
-		int tx_index;
-		struct tx_desc *desc;
-		u32 cmd_sts;
-		struct sk_buff *skb;
-		dma_addr_t addr;
-		int count;
+	txq_disable(txq);
+	// @@@
+	txq_reclaim(txq, INT_MAX, 1);
 
-		tx_index = txq->tx_used_desc;
-		desc = &txq->tx_desc_area[tx_index];
-		cmd_sts = desc->cmd_sts;
+	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
-		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
-			if (!force)
-				break;
-			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
-		}
+	if (txq->index == 0 &&
+	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
+		iounmap(txq->tx_desc_area);
+	else
+		dma_free_coherent(NULL, txq->tx_desc_area_size,
+				  txq->tx_desc_area, txq->tx_desc_dma);
 
-		txq->tx_used_desc = tx_index + 1;
-		if (txq->tx_used_desc == txq->tx_ring_size)
-			txq->tx_used_desc = 0;
-		txq->tx_desc_count--;
+	kfree(txq->tx_skb);
+}
 
-		addr = desc->buf_ptr;
-		count = desc->byte_cnt;
-		skb = txq->tx_skb[tx_index];
-		txq->tx_skb[tx_index] = NULL;
 
-		if (cmd_sts & ERROR_SUMMARY) {
-			dev_printk(KERN_INFO, &mp->dev->dev, "tx error\n");
-			mp->dev->stats.tx_errors++;
-		}
+/* netdev ops and related ***************************************************/
+static int mv643xx_eth_collect_events(struct mv643xx_eth_private *mp)
+{
+	u32 int_cause;
+	u32 int_cause_ext;
 
-		/*
-		 * Drop mp->lock while we free the skb.
-		 */
-		spin_unlock_irqrestore(&mp->lock, flags);
+	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
+			(INT_TX_END | INT_RX | INT_EXT);
+	if (int_cause == 0)
+		return 0;
 
-		if (cmd_sts & TX_FIRST_DESC)
-			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
-		else
-			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
+	int_cause_ext = 0;
+	if (int_cause & INT_EXT)
+		int_cause_ext = rdl(mp, INT_CAUSE_EXT(mp->port_num));
 
-		if (skb)
-			dev_kfree_skb_irq(skb);
+	int_cause &= INT_TX_END | INT_RX;
+	if (int_cause) {
+		wrl(mp, INT_CAUSE(mp->port_num), ~int_cause);
+		mp->work_tx_end |= ((int_cause & INT_TX_END) >> 19) &
+				~(rdl(mp, TXQ_COMMAND(mp->port_num)) & 0xff);
+		mp->work_rx |= (int_cause & INT_RX) >> 2;
+	}
 
-		spin_lock_irqsave(&mp->lock, flags);
+	int_cause_ext &= INT_EXT_LINK_PHY | INT_EXT_TX;
+	if (int_cause_ext) {
+		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
+		if (int_cause_ext & INT_EXT_LINK_PHY)
+			mp->work_link = 1;
+		mp->work_tx |= int_cause_ext & INT_EXT_TX;
 	}
-	spin_unlock_irqrestore(&mp->lock, flags);
+
+	return 1;
 }
 
-static void txq_deinit(struct tx_queue *txq)
+static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 {
-	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-
-	txq_disable(txq);
-	txq_reclaim(txq, 1);
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
+	if (unlikely(!mv643xx_eth_collect_events(mp)))
+		return IRQ_NONE;
 
-	if (txq->index == 0 &&
-	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
-		iounmap(txq->tx_desc_area);
-	else
-		dma_free_coherent(NULL, txq->tx_desc_area_size,
-				  txq->tx_desc_area, txq->tx_desc_dma);
+	wrl(mp, INT_MASK(mp->port_num), 0);
+	napi_schedule(&mp->napi);
 
-	kfree(txq->tx_skb);
+	return IRQ_HANDLED;
 }
 
-
-/* netdev ops and related ***************************************************/
 static void handle_link_event(struct mv643xx_eth_private *mp)
 {
 	struct net_device *dev = mp->dev;
@@ -1759,7 +1805,7 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 			for (i = 0; i < mp->txq_count; i++) {
 				struct tx_queue *txq = mp->txq + i;
 
-				txq_reclaim(txq, 1);
+				txq_reclaim(txq, INT_MAX, 1);
 				txq_reset_hw_ptr(txq);
 			}
 		}
@@ -1792,86 +1838,72 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 		netif_carrier_on(dev);
 }
 
-static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
+static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
-	struct net_device *dev = (struct net_device *)dev_id;
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	u32 int_cause;
-	u32 int_cause_ext;
+	struct mv643xx_eth_private *mp;
+	int work_done;
 
-	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
-			(INT_TX_END | INT_RX | INT_EXT);
-	if (int_cause == 0)
-		return IRQ_NONE;
+	mp = container_of(napi, struct mv643xx_eth_private, napi);
 
-	int_cause_ext = 0;
-	if (int_cause & INT_EXT) {
-		int_cause_ext = rdl(mp, INT_CAUSE_EXT(mp->port_num))
-				& (INT_EXT_LINK_PHY | INT_EXT_TX);
-		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
-	}
+	mp->work_rx_refill |= mp->work_rx_oom;
+	mp->work_rx_oom = 0;
 
-	if (int_cause_ext & INT_EXT_LINK_PHY)
-		handle_link_event(mp);
+	work_done = 0;
+	while (work_done < budget) {
+		u8 queue_mask;
+		int queue;
+		int work_tbd;
+
+		if (mp->work_link) {
+			mp->work_link = 0;
+			handle_link_event(mp);
+			continue;
+		}
 
-	/*
-	 * RxBuffer or RxError set for any of the 8 queues?
-	 */
-	if (int_cause & INT_RX) {
-		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_RX));
-		wrl(mp, INT_MASK(mp->port_num), 0x00000000);
-		rdl(mp, INT_MASK(mp->port_num));
+		queue_mask = mp->work_tx | mp->work_tx_end |
+				mp->work_rx | mp->work_rx_refill;
+		if (!queue_mask) {
+			if (mv643xx_eth_collect_events(mp))
+				continue;
+			break;
+		}
 
-		napi_schedule(&mp->napi);
+		queue = fls(queue_mask) - 1;
+		queue_mask = 1 << queue;
+
+		work_tbd = budget - work_done;
+		if (work_tbd > 5)
+			work_tbd = 5;
+
+		if (mp->work_tx_end & queue_mask) {
+			txq_kick(mp->txq + queue);
+		} else if (mp->work_tx & queue_mask) {
+			work_done += txq_reclaim(mp->txq + queue, work_tbd, 0);
+			txq_maybe_wake(mp->txq + queue);
+		} else if (mp->work_rx & queue_mask) {
+			work_done += rxq_process(mp->rxq + queue, work_tbd);
+		} else if (mp->work_rx_refill & queue_mask) {
+			work_done += rxq_refill(mp->rxq + queue, work_tbd);
+		} else {
+			BUG();
+		}
 	}
 
-	/*
-	 * TxBuffer or TxError set for any of the 8 queues?
-	 */
-	if (int_cause_ext & INT_EXT_TX) {
-		int i;
-
-		for (i = 0; i < mp->txq_count; i++)
-			txq_reclaim(mp->txq + i, 0);
-
-		/*
-		 * Enough space again in the primary TX queue for a
-		 * full packet?
-		 */
-		spin_lock(&mp->lock);
-		__txq_maybe_wake(mp->txq);
-		spin_unlock(&mp->lock);
+	if (work_done < budget) {
+		if (mp->work_rx_oom)
+			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
+		napi_complete(napi);
+		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 	}
 
-	/*
-	 * Any TxEnd interrupts?
-	 */
-	if (int_cause & INT_TX_END) {
-		int i;
-
-		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_TX_END));
-
-		spin_lock(&mp->lock);
-		for (i = 0; i < 8; i++) {
-			struct tx_queue *txq = mp->txq + i;
-			u32 hw_desc_ptr;
-			u32 expected_ptr;
-
-			if ((int_cause & (INT_TX_END_0 << i)) == 0)
-				continue;
-
-			hw_desc_ptr =
-				rdl(mp, TXQ_CURRENT_DESC_PTR(mp->port_num, i));
-			expected_ptr = (u32)txq->tx_desc_dma +
-				txq->tx_curr_desc * sizeof(struct tx_desc);
+	return work_done;
+}
 
-			if (hw_desc_ptr != expected_ptr)
-				txq_enable(txq);
-		}
-		spin_unlock(&mp->lock);
-	}
+static inline void oom_timer_wrapper(unsigned long data)
+{
+	struct mv643xx_eth_private *mp = (void *)data;
 
-	return IRQ_HANDLED;
+	napi_schedule(&mp->napi);
 }
 
 static void phy_reset(struct mv643xx_eth_private *mp)
@@ -2000,7 +2032,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
-	int oom;
 	int i;
 
 	wrl(mp, INT_CAUSE(mp->port_num), 0);
@@ -2018,7 +2049,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	napi_enable(&mp->napi);
 
-	oom = 0;
 	for (i = 0; i < mp->rxq_count; i++) {
 		err = rxq_init(mp, i);
 		if (err) {
@@ -2027,10 +2057,10 @@ static int mv643xx_eth_open(struct net_device *dev)
 			goto out;
 		}
 
-		rxq_refill(mp->rxq + i, INT_MAX, &oom);
+		rxq_refill(mp->rxq + i, INT_MAX);
 	}
 
-	if (oom) {
+	if (mp->work_rx_oom) {
 		mp->rx_oom.expires = jiffies + (HZ / 10);
 		add_timer(&mp->rx_oom);
 	}
-- 
1.5.6.4

