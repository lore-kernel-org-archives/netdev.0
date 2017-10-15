From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 07/10] net: korina: move tx to napi context
Date: Sun, 15 Oct 2017 19:23:53 +0300
Message-ID: <20171015162353.1050-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52645 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751682AbdJOQdK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:33:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 2B56219193D
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:23:15 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 79 +++++++++++--------------------------------
 1 file changed, 20 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index a076b0c49e6e..f606f1e01af1 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -185,10 +185,6 @@ static inline void korina_abort_dma(struct net_device *dev,
 {
 	if (readl(&ch->dmac) & DMA_CHAN_RUN_BIT) {
 		writel(0x10, &ch->dmac);
-
-		while (!(readl(&ch->dmas) & DMA_STAT_HALT))
-			netif_trans_update(dev);
-
 		writel(0, &ch->dmas);
 	}
 
@@ -260,12 +256,9 @@ static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
-	unsigned long flags;
 	u32 chain_prev, chain_next, dmandptr;
 	struct dma_desc *td;
 
-	spin_lock_irqsave(&lp->lock, flags);
-
 	td = &lp->td_ring[lp->tx_chain_tail];
 
 	/* stop queue when full, drop pkts if queue already full */
@@ -276,7 +269,6 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 		if (lp->tx_count > (KORINA_NUM_TDS - 2)) {
 			dev->stats.tx_dropped++;
 			dev_kfree_skb_any(skb);
-			spin_unlock_irqrestore(&lp->lock, flags);
 
 			return NETDEV_TX_BUSY;
 		}
@@ -319,9 +311,6 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	dma_cache_wback((u32) td, sizeof(*td));
 
-	netif_trans_update(dev);
-	spin_unlock_irqrestore(&lp->lock, flags);
-
 	return NETDEV_TX_OK;
 }
 
@@ -332,8 +321,6 @@ static void korina_tx(struct net_device *dev)
 	u32 devcs;
 	u32 dmas;
 
-	spin_lock(&lp->lock);
-
 	/* Process all desc that are done */
 	while (IS_DMA_FINISHED(td->control)) {
 		if (lp->tx_full == 1) {
@@ -389,10 +376,6 @@ static void korina_tx(struct net_device *dev)
 	/* Clear the DMA status register */
 	dmas = readl(&lp->tx_dma_regs->dmas);
 	writel(~dmas, &lp->tx_dma_regs->dmas);
-
-	korina_int_enable_tx(lp);
-
-	spin_unlock(&lp->lock);
 }
 
 static int korina_rx(struct net_device *dev, int limit)
@@ -513,67 +496,47 @@ static int korina_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = lp->dev;
 	int work_done;
 
+	korina_tx(dev);
+
 	work_done = korina_rx(dev, budget);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
+		spin_lock_bh(&lp->lock);
+		korina_int_enable_tx(lp);
 		korina_int_enable_rx(lp);
+		spin_unlock_bh(&lp->lock);
 	}
 	return work_done;
 }
 
-static irqreturn_t
-korina_tx_dma_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	struct korina_private *lp = netdev_priv(dev);
-	u32 dmas;
-
-	dmas = readl(&lp->tx_dma_regs->dmas);
-
-	if (likely(dmas & KORINA_INT_TX)) {
-		korina_int_disable_tx(lp);
-
-		korina_tx(dev);
-
-		if (lp->tx_chain_status == desc_filled &&
-			(readl(&(lp->tx_dma_regs->dmandptr)) == 0)) {
-			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
-				&(lp->tx_dma_regs->dmandptr));
-			lp->tx_chain_status = desc_empty;
-			lp->tx_chain_head = lp->tx_chain_tail;
-			netif_trans_update(dev);
-		}
-
-		if (unlikely(dmas & DMA_STAT_ERR))
-			lp->dma_halt_cnt++;
-
-		return IRQ_HANDLED;
-	}
-
-	return IRQ_NONE;
-}
-
 /* Ethernet Rx DMA interrupt */
-static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
+static irqreturn_t korina_dma_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct korina_private *lp = netdev_priv(dev);
 	u32 dmas;
+	unsigned long flags;
+	irqreturn_t ret = IRQ_NONE;
 
-	dmas = readl(&lp->rx_dma_regs->dmas);
+	spin_lock_irqsave(&lp->lock, flags);
 
-	if (likely(dmas & KORINA_INT_RX)) {
+	dmas = readl(&lp->tx_dma_regs->dmas);
+	dmas |= readl(&lp->rx_dma_regs->dmas);
+
+	if (likely(dmas & KORINA_INT_TXRX)) {
 		korina_int_disable_rx(lp);
+		korina_int_disable_tx(lp);
 
 		napi_schedule(&lp->napi);
 
 		if (unlikely(dmas & DMA_STAT_ERR))
 			lp->dma_halt_cnt++;
 
-		return IRQ_HANDLED;
+		ret = IRQ_HANDLED;
 	}
 
-	return IRQ_NONE;
+	spin_unlock_irqrestore(&lp->lock, flags);
+	return ret;
 }
 
 /*
@@ -792,8 +755,6 @@ static int korina_init(struct net_device *dev)
 
 	/* reset ethernet logic */
 	writel(0, &lp->eth_regs->ethintfc);
-	while ((readl(&lp->eth_regs->ethintfc) & ETH_INT_FC_RIP))
-		netif_trans_update(dev);
 
 	/* Enable Ethernet Interface */
 	writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
@@ -897,7 +858,7 @@ static void korina_tx_timeout(struct net_device *dev)
 static void korina_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	korina_tx_dma_interrupt(dev->irq, dev);
+	korina_dma_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
@@ -916,14 +877,14 @@ static int korina_open(struct net_device *dev)
 
 	/* Install the interrupt handler
 	 * that handles the Done Finished */
-	ret = request_irq(lp->rx_irq, korina_rx_dma_interrupt,
+	ret = request_irq(lp->rx_irq, korina_dma_interrupt,
 			0, "Korina ethernet Rx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Rx DMA IRQ %d\n",
 			dev->name, lp->rx_irq);
 		goto err_release;
 	}
-	ret = request_irq(lp->tx_irq, korina_tx_dma_interrupt,
+	ret = request_irq(lp->tx_irq, korina_dma_interrupt,
 			0, "Korina ethernet Tx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Tx DMA IRQ %d\n",
-- 
2.11.0
