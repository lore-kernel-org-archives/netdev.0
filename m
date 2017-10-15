From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 02/10] net: korina: reorder functions
Date: Sun, 15 Oct 2017 19:22:55 +0300
Message-ID: <20171015162255.727-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52621 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751854AbdJOQ2L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:28:11 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id DA191191883
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:22:16 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 317 +++++++++++++++++++++---------------------
 1 file changed, 158 insertions(+), 159 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 84b2654e2d06..5545f86aac4a 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -195,6 +195,35 @@ static void korina_chain_rx(struct korina_private *lp,
 	korina_chain_dma(lp->rx_dma_regs, CPHYSADDR(rd));
 }
 
+static int mdio_read(struct net_device *dev, int mii_id, int reg)
+{
+	struct korina_private *lp = netdev_priv(dev);
+	int ret;
+
+	mii_id = ((lp->rx_irq == 0x2c ? 1 : 0) << 8);
+
+	writel(0, &lp->eth_regs->miimcfg);
+	writel(0, &lp->eth_regs->miimcmd);
+	writel(mii_id | reg, &lp->eth_regs->miimaddr);
+	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
+
+	ret = (int)(readl(&lp->eth_regs->miimrdd));
+	return ret;
+}
+
+static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
+{
+	struct korina_private *lp = netdev_priv(dev);
+
+	mii_id = ((lp->rx_irq == 0x2c ? 1 : 0) << 8);
+
+	writel(0, &lp->eth_regs->miimcfg);
+	writel(1, &lp->eth_regs->miimcmd);
+	writel(mii_id | reg, &lp->eth_regs->miimaddr);
+	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
+	writel(val, &lp->eth_regs->miimwtd);
+}
+
 /* transmit packet */
 static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
@@ -264,60 +293,87 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int mdio_read(struct net_device *dev, int mii_id, int reg)
+static void korina_tx(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
-	int ret;
+	struct dma_desc *td = &lp->td_ring[lp->tx_next_done];
+	u32 devcs;
+	u32 dmas;
 
-	mii_id = ((lp->rx_irq == 0x2c ? 1 : 0) << 8);
+	spin_lock(&lp->lock);
 
-	writel(0, &lp->eth_regs->miimcfg);
-	writel(0, &lp->eth_regs->miimcmd);
-	writel(mii_id | reg, &lp->eth_regs->miimaddr);
-	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
+	/* Process all desc that are done */
+	while (IS_DMA_FINISHED(td->control)) {
+		if (lp->tx_full == 1) {
+			netif_wake_queue(dev);
+			lp->tx_full = 0;
+		}
 
-	ret = (int)(readl(&lp->eth_regs->miimrdd));
-	return ret;
-}
+		devcs = lp->td_ring[lp->tx_next_done].devcs;
+		if ((devcs & (ETH_TX_FD | ETH_TX_LD)) !=
+				(ETH_TX_FD | ETH_TX_LD)) {
+			dev->stats.tx_errors++;
+			dev->stats.tx_dropped++;
 
-static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
-{
-	struct korina_private *lp = netdev_priv(dev);
+			/* Should never happen */
+			printk(KERN_ERR "%s: split tx ignored\n",
+							dev->name);
+		} else if (devcs & ETH_TX_TOK) {
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes +=
+					lp->tx_skb[lp->tx_next_done]->len;
+		} else {
+			dev->stats.tx_errors++;
+			dev->stats.tx_dropped++;
 
-	mii_id = ((lp->rx_irq == 0x2c ? 1 : 0) << 8);
+			/* Underflow */
+			if (devcs & ETH_TX_UND)
+				dev->stats.tx_fifo_errors++;
 
-	writel(0, &lp->eth_regs->miimcfg);
-	writel(1, &lp->eth_regs->miimcmd);
-	writel(mii_id | reg, &lp->eth_regs->miimaddr);
-	writel(ETH_MII_CMD_SCN, &lp->eth_regs->miimcmd);
-	writel(val, &lp->eth_regs->miimwtd);
-}
+			/* Oversized frame */
+			if (devcs & ETH_TX_OF)
+				dev->stats.tx_aborted_errors++;
 
-/* Ethernet Rx DMA interrupt */
-static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	struct korina_private *lp = netdev_priv(dev);
-	u32 dmas, dmasm;
-	irqreturn_t retval;
+			/* Excessive deferrals */
+			if (devcs & ETH_TX_ED)
+				dev->stats.tx_carrier_errors++;
 
-	dmas = readl(&lp->rx_dma_regs->dmas);
-	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
-		dmasm = readl(&lp->rx_dma_regs->dmasm);
-		writel(dmasm | (DMA_STAT_DONE |
-				DMA_STAT_HALT | DMA_STAT_ERR),
-				&lp->rx_dma_regs->dmasm);
+			/* Collisions: medium busy */
+			if (devcs & ETH_TX_EC)
+				dev->stats.collisions++;
 
-		napi_schedule(&lp->napi);
+			/* Late collision */
+			if (devcs & ETH_TX_LC)
+				dev->stats.tx_window_errors++;
+		}
 
-		if (dmas & DMA_STAT_ERR)
-			printk(KERN_ERR "%s: DMA error\n", dev->name);
+		/* We must always free the original skb */
+		if (lp->tx_skb[lp->tx_next_done]) {
+			dev_kfree_skb_any(lp->tx_skb[lp->tx_next_done]);
+			lp->tx_skb[lp->tx_next_done] = NULL;
+		}
 
-		retval = IRQ_HANDLED;
-	} else
-		retval = IRQ_NONE;
+		lp->td_ring[lp->tx_next_done].control = DMA_DESC_IOF;
+		lp->td_ring[lp->tx_next_done].devcs = ETH_TX_FD | ETH_TX_LD;
+		lp->td_ring[lp->tx_next_done].link = 0;
+		lp->td_ring[lp->tx_next_done].ca = 0;
+		lp->tx_count--;
 
-	return retval;
+		/* Go on to next transmission */
+		lp->tx_next_done = (lp->tx_next_done + 1) & KORINA_TDS_MASK;
+		td = &lp->td_ring[lp->tx_next_done];
+
+	}
+
+	/* Clear the DMA status register */
+	dmas = readl(&lp->tx_dma_regs->dmas);
+	writel(~dmas, &lp->tx_dma_regs->dmas);
+
+	writel(readl(&lp->tx_dma_regs->dmasm) &
+			~(DMA_STAT_FINI | DMA_STAT_ERR),
+			&lp->tx_dma_regs->dmasm);
+
+	spin_unlock(&lp->lock);
 }
 
 static int korina_rx(struct net_device *dev, int limit)
@@ -449,6 +505,68 @@ static int korina_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+static irqreturn_t
+korina_tx_dma_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct korina_private *lp = netdev_priv(dev);
+	u32 dmas, dmasm;
+	irqreturn_t retval;
+
+	dmas = readl(&lp->tx_dma_regs->dmas);
+
+	if (dmas & (DMA_STAT_FINI | DMA_STAT_ERR)) {
+		dmasm = readl(&lp->tx_dma_regs->dmasm);
+		writel(dmasm | (DMA_STAT_FINI | DMA_STAT_ERR),
+				&lp->tx_dma_regs->dmasm);
+
+		korina_tx(dev);
+
+		if (lp->tx_chain_status == desc_filled &&
+			(readl(&(lp->tx_dma_regs->dmandptr)) == 0)) {
+			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
+				&(lp->tx_dma_regs->dmandptr));
+			lp->tx_chain_status = desc_empty;
+			lp->tx_chain_head = lp->tx_chain_tail;
+			netif_trans_update(dev);
+		}
+		if (dmas & DMA_STAT_ERR)
+			printk(KERN_ERR "%s: DMA error\n", dev->name);
+
+		retval = IRQ_HANDLED;
+	} else
+		retval = IRQ_NONE;
+
+	return retval;
+}
+
+/* Ethernet Rx DMA interrupt */
+static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct korina_private *lp = netdev_priv(dev);
+	u32 dmas, dmasm;
+	irqreturn_t retval;
+
+	dmas = readl(&lp->rx_dma_regs->dmas);
+	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
+		dmasm = readl(&lp->rx_dma_regs->dmasm);
+		writel(dmasm | (DMA_STAT_DONE |
+				DMA_STAT_HALT | DMA_STAT_ERR),
+				&lp->rx_dma_regs->dmasm);
+
+		napi_schedule(&lp->napi);
+
+		if (dmas & DMA_STAT_ERR)
+			printk(KERN_ERR "%s: DMA error\n", dev->name);
+
+		retval = IRQ_HANDLED;
+	} else
+		retval = IRQ_NONE;
+
+	return retval;
+}
+
 /*
  * Set or clear the multicast filter for this adaptor.
  */
@@ -492,125 +610,6 @@ static void korina_multicast_list(struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-static void korina_tx(struct net_device *dev)
-{
-	struct korina_private *lp = netdev_priv(dev);
-	struct dma_desc *td = &lp->td_ring[lp->tx_next_done];
-	u32 devcs;
-	u32 dmas;
-
-	spin_lock(&lp->lock);
-
-	/* Process all desc that are done */
-	while (IS_DMA_FINISHED(td->control)) {
-		if (lp->tx_full == 1) {
-			netif_wake_queue(dev);
-			lp->tx_full = 0;
-		}
-
-		devcs = lp->td_ring[lp->tx_next_done].devcs;
-		if ((devcs & (ETH_TX_FD | ETH_TX_LD)) !=
-				(ETH_TX_FD | ETH_TX_LD)) {
-			dev->stats.tx_errors++;
-			dev->stats.tx_dropped++;
-
-			/* Should never happen */
-			printk(KERN_ERR "%s: split tx ignored\n",
-							dev->name);
-		} else if (devcs & ETH_TX_TOK) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes +=
-					lp->tx_skb[lp->tx_next_done]->len;
-		} else {
-			dev->stats.tx_errors++;
-			dev->stats.tx_dropped++;
-
-			/* Underflow */
-			if (devcs & ETH_TX_UND)
-				dev->stats.tx_fifo_errors++;
-
-			/* Oversized frame */
-			if (devcs & ETH_TX_OF)
-				dev->stats.tx_aborted_errors++;
-
-			/* Excessive deferrals */
-			if (devcs & ETH_TX_ED)
-				dev->stats.tx_carrier_errors++;
-
-			/* Collisions: medium busy */
-			if (devcs & ETH_TX_EC)
-				dev->stats.collisions++;
-
-			/* Late collision */
-			if (devcs & ETH_TX_LC)
-				dev->stats.tx_window_errors++;
-		}
-
-		/* We must always free the original skb */
-		if (lp->tx_skb[lp->tx_next_done]) {
-			dev_kfree_skb_any(lp->tx_skb[lp->tx_next_done]);
-			lp->tx_skb[lp->tx_next_done] = NULL;
-		}
-
-		lp->td_ring[lp->tx_next_done].control = DMA_DESC_IOF;
-		lp->td_ring[lp->tx_next_done].devcs = ETH_TX_FD | ETH_TX_LD;
-		lp->td_ring[lp->tx_next_done].link = 0;
-		lp->td_ring[lp->tx_next_done].ca = 0;
-		lp->tx_count--;
-
-		/* Go on to next transmission */
-		lp->tx_next_done = (lp->tx_next_done + 1) & KORINA_TDS_MASK;
-		td = &lp->td_ring[lp->tx_next_done];
-
-	}
-
-	/* Clear the DMA status register */
-	dmas = readl(&lp->tx_dma_regs->dmas);
-	writel(~dmas, &lp->tx_dma_regs->dmas);
-
-	writel(readl(&lp->tx_dma_regs->dmasm) &
-			~(DMA_STAT_FINI | DMA_STAT_ERR),
-			&lp->tx_dma_regs->dmasm);
-
-	spin_unlock(&lp->lock);
-}
-
-static irqreturn_t
-korina_tx_dma_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	struct korina_private *lp = netdev_priv(dev);
-	u32 dmas, dmasm;
-	irqreturn_t retval;
-
-	dmas = readl(&lp->tx_dma_regs->dmas);
-
-	if (dmas & (DMA_STAT_FINI | DMA_STAT_ERR)) {
-		dmasm = readl(&lp->tx_dma_regs->dmasm);
-		writel(dmasm | (DMA_STAT_FINI | DMA_STAT_ERR),
-				&lp->tx_dma_regs->dmasm);
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
-		if (dmas & DMA_STAT_ERR)
-			printk(KERN_ERR "%s: DMA error\n", dev->name);
-
-		retval = IRQ_HANDLED;
-	} else
-		retval = IRQ_NONE;
-
-	return retval;
-}
-
-
 static void korina_check_media(struct net_device *dev, unsigned int init_media)
 {
 	struct korina_private *lp = netdev_priv(dev);
-- 
2.11.0
