From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 03/10] net: korina: introduce and use interrupt disable/enable helpers
Date: Sun, 15 Oct 2017 19:23:07 +0300
Message-ID: <20171015162307.796-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52615 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751341AbdJOQ2K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:28:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 26100191887
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:22:28 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 83 +++++++++++++++++++++++++------------------
 1 file changed, 48 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 5545f86aac4a..04c1a3f38a79 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -91,6 +91,10 @@
 #define RD_RING_SIZE	(KORINA_NUM_RDS * sizeof(struct dma_desc))
 #define TD_RING_SIZE	(KORINA_NUM_TDS * sizeof(struct dma_desc))
 
+#define KORINA_INT_TX	(DMA_STAT_FINI | DMA_STAT_ERR)
+#define KORINA_INT_RX	(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)
+#define KORINA_INT_TXRX	(KORINA_INT_TX | KORINA_INT_RX)
+
 #define TX_TIMEOUT	(6000 * HZ / 1000)
 
 enum chain_status {
@@ -142,6 +146,38 @@ struct korina_private {
 
 extern unsigned int idt_cpu_freq;
 
+static inline void korina_int_disable(u32 *dmasm, u32 ints)
+{
+	u32 tmp = readl(dmasm);
+	writel(tmp | ints, dmasm);
+}
+
+static inline void korina_int_enable(u32 *dmasm, u32 ints)
+{
+	u32 tmp = readl(dmasm);
+	writel(tmp & ~ints, dmasm);
+}
+
+static inline void korina_int_disable_tx(struct korina_private *kp)
+{
+	korina_int_disable(&kp->tx_dma_regs->dmasm, KORINA_INT_TX);
+}
+
+static inline void korina_int_disable_rx(struct korina_private *kp)
+{
+	korina_int_disable(&kp->rx_dma_regs->dmasm, KORINA_INT_RX);
+}
+
+static inline void korina_int_enable_tx(struct korina_private *kp)
+{
+	korina_int_enable(&kp->tx_dma_regs->dmasm, KORINA_INT_TX);
+}
+
+static inline void korina_int_enable_rx(struct korina_private *kp)
+{
+	korina_int_enable(&kp->rx_dma_regs->dmasm, KORINA_INT_RX);
+}
+
 static inline void korina_start_dma(struct dma_reg *ch, u32 dma_addr)
 {
 	writel(0, &ch->dmandptr);
@@ -369,9 +405,7 @@ static void korina_tx(struct net_device *dev)
 	dmas = readl(&lp->tx_dma_regs->dmas);
 	writel(~dmas, &lp->tx_dma_regs->dmas);
 
-	writel(readl(&lp->tx_dma_regs->dmasm) &
-			~(DMA_STAT_FINI | DMA_STAT_ERR),
-			&lp->tx_dma_regs->dmasm);
+	korina_int_enable_tx(lp);
 
 	spin_unlock(&lp->lock);
 }
@@ -497,10 +531,7 @@ static int korina_poll(struct napi_struct *napi, int budget)
 	work_done = korina_rx(dev, budget);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
-
-		writel(readl(&lp->rx_dma_regs->dmasm) &
-			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
-			&lp->rx_dma_regs->dmasm);
+		korina_int_enable_rx(lp);
 	}
 	return work_done;
 }
@@ -510,15 +541,13 @@ korina_tx_dma_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct korina_private *lp = netdev_priv(dev);
-	u32 dmas, dmasm;
+	u32 dmas;
 	irqreturn_t retval;
 
 	dmas = readl(&lp->tx_dma_regs->dmas);
 
 	if (dmas & (DMA_STAT_FINI | DMA_STAT_ERR)) {
-		dmasm = readl(&lp->tx_dma_regs->dmasm);
-		writel(dmasm | (DMA_STAT_FINI | DMA_STAT_ERR),
-				&lp->tx_dma_regs->dmasm);
+		korina_int_disable_tx(lp);
 
 		korina_tx(dev);
 
@@ -545,15 +574,12 @@ static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct korina_private *lp = netdev_priv(dev);
-	u32 dmas, dmasm;
+	u32 dmas;
 	irqreturn_t retval;
 
 	dmas = readl(&lp->rx_dma_regs->dmas);
 	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
-		dmasm = readl(&lp->rx_dma_regs->dmasm);
-		writel(dmasm | (DMA_STAT_DONE |
-				DMA_STAT_HALT | DMA_STAT_ERR),
-				&lp->rx_dma_regs->dmasm);
+		korina_int_disable_rx(lp);
 
 		napi_schedule(&lp->napi);
 
@@ -803,12 +829,8 @@ static int korina_init(struct net_device *dev)
 	/* Start Rx DMA */
 	korina_start_rx(lp, &lp->rd_ring[0]);
 
-	writel(readl(&lp->tx_dma_regs->dmasm) &
-			~(DMA_STAT_FINI | DMA_STAT_ERR),
-			&lp->tx_dma_regs->dmasm);
-	writel(readl(&lp->rx_dma_regs->dmasm) &
-			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
-			&lp->rx_dma_regs->dmasm);
+	korina_int_enable_tx(lp);
+	korina_int_enable_rx(lp);
 
 	/* Accept only packets destined for this Ethernet device address */
 	writel(ETH_ARC_AB, &lp->eth_regs->etharc);
@@ -867,12 +889,8 @@ static void korina_restart_task(struct work_struct *work)
 	disable_irq(lp->rx_irq);
 	disable_irq(lp->tx_irq);
 
-	writel(readl(&lp->tx_dma_regs->dmasm) |
-				DMA_STAT_FINI | DMA_STAT_ERR,
-				&lp->tx_dma_regs->dmasm);
-	writel(readl(&lp->rx_dma_regs->dmasm) |
-				DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR,
-				&lp->rx_dma_regs->dmasm);
+	korina_int_disable_tx(lp);
+	korina_int_disable_rx(lp);
 
 	napi_disable(&lp->napi);
 
@@ -947,7 +965,6 @@ static int korina_open(struct net_device *dev)
 static int korina_close(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
-	u32 tmp;
 
 	del_timer(&lp->media_check_timer);
 
@@ -956,14 +973,10 @@ static int korina_close(struct net_device *dev)
 	disable_irq(lp->tx_irq);
 
 	korina_abort_tx(dev);
-	tmp = readl(&lp->tx_dma_regs->dmasm);
-	tmp = tmp | DMA_STAT_FINI | DMA_STAT_ERR;
-	writel(tmp, &lp->tx_dma_regs->dmasm);
+	korina_int_disable_tx(lp);
 
 	korina_abort_rx(dev);
-	tmp = readl(&lp->rx_dma_regs->dmasm);
-	tmp = tmp | DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR;
-	writel(tmp, &lp->rx_dma_regs->dmasm);
+	korina_int_disable_rx(lp);
 
 	napi_disable(&lp->napi);
 
-- 
2.11.0
