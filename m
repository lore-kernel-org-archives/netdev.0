From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 4/4] net: ethernet: ti cpsw: separate interrupt handler for TX, RX, and MISC
Date: Fri, 18 Jan 2013 11:06:12 +0100
Message-ID: <1358503572-5057-4-git-send-email-sebastian@breakpoint.cc>
References: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Rakesh Ranjan <rakesh.ranjan@vnl.in>,
	Bruno Bittner <Bruno.Bittner@sick.com>, stable@vger.kernel.org,
	Holger Dengler <dengler@linutronix.de>,
	Jan Altenberg <jan@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

The interrupt handling of the device is using the same interrupt
handler function for all possible device interrupts.

If an host error interrupt is raised (misc), then it merily switches
the device driver into NAPI scheduling mode which is completely
pointless since neither RX nor TX completes. It also fails to give
any information about the reason for this host error interrupt.

The solution for this problem is to provide separate interrupt
handlers for RX, TX and the error (misc) interrupt.

This allows at least to print out the host error reason even if we
have no error handling mechanisms there yet. Though it allowed us
to pinpoint the main problem as we had the information what kind of
error the DMA engine run into.
The patch also clean ups the complete TX queue. It was observed that
sometimes the EOI ack for RX queue also ACKed TX packets which were
not-yet processed. This lead to TX stall.

Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Rakesh Ranjan <rakesh.ranjan@vnl.in>
Cc: Bruno Bittner <Bruno.Bittner@sick.com>
Cc: stable@vger.kernel.org
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[dengler: patch description]
Signed-off-by: Holger Dengler <dengler@linutronix.de>
[jan: forward ported]
Signed-off-by: Jan Altenberg <jan@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c          |  249 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/ti/davinci_cpdma.c |   31 +++-
 drivers/net/ethernet/ti/davinci_cpdma.h |    5 +-
 3 files changed, 236 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 40aff68..ee4533d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -118,6 +118,13 @@ do {								\
 #define TX_PRIORITY_MAPPING	0x33221100
 #define CPDMA_TX_PRIORITY_MAP	0x76543210
 
+enum {
+	CPSW_IRQ_TYPE_RX_THRESH,
+	CPSW_IRQ_TYPE_RX,
+	CPSW_IRQ_TYPE_TX,
+	CPSW_IRQ_TYPE_MISC,
+};
+
 #define cpsw_enable_irq(priv)	\
 	do {			\
 		u32 i;		\
@@ -312,9 +319,12 @@ struct cpsw_priv {
 	struct cpdma_ctlr		*dma;
 	struct cpdma_chan		*txch, *rxch;
 	struct cpsw_ale			*ale;
+	bool				rx_irqs_disabled;
+	bool				tx_irqs_disabled;
+	bool				misc_irqs_disabled;
 	/* snapshot of IRQ numbers */
-	u32 irqs_table[4];
-	u32 num_irqs;
+	u32				irqs_table[4];
+	u32				num_irqs;
 	struct cpts cpts;
 };
 
@@ -350,21 +360,93 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	}
 }
 
-static void cpsw_intr_enable(struct cpsw_priv *priv)
+static void cpsw_intr_rx_enable(struct cpsw_priv *priv)
+{
+	__raw_writel(0x01, &priv->wr_regs->rx_en);
+	cpdma_chan_int_ctrl(priv->rxch, true);
+	return;
+}
+
+static void cpsw_intr_rx_disable(struct cpsw_priv *priv)
+{
+	__raw_writel(0x00, &priv->wr_regs->rx_en);
+	cpdma_chan_int_ctrl(priv->rxch, false);
+	return;
+}
+
+static void cpsw_intr_tx_enable(struct cpsw_priv *priv)
+{
+	__raw_writel(0x01, &priv->wr_regs->tx_en);
+	cpdma_chan_int_ctrl(priv->txch, true);
+	return;
+}
+
+static void cpsw_intr_tx_disable(struct cpsw_priv *priv)
 {
-	__raw_writel(0xFF, &priv->wr_regs->tx_en);
-	__raw_writel(0xFF, &priv->wr_regs->rx_en);
+	__raw_writel(0x00, &priv->wr_regs->tx_en);
+	cpdma_chan_int_ctrl(priv->txch, false);
+	return;
+}
 
+static void cpsw_intr_misc_enable(struct cpsw_priv *priv)
+{
+	__raw_writel(0x04, &priv->wr_regs->misc_en);
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	return;
 }
 
+static void cpsw_intr_misc_disable(struct cpsw_priv *priv)
+{
+	__raw_writel(0x00, &priv->wr_regs->misc_en);
+	cpdma_ctlr_int_ctrl(priv->dma, false);
+}
+
+static void cpsw_intr_enable(struct cpsw_priv *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	if (priv->rx_irqs_disabled) {
+		enable_irq(priv->irqs_table[CPSW_IRQ_TYPE_RX]);
+		priv->rx_irqs_disabled = false;
+	}
+	if (priv->tx_irqs_disabled) {
+		enable_irq(priv->irqs_table[CPSW_IRQ_TYPE_TX]);
+		priv->tx_irqs_disabled = false;
+	}
+	if (priv->misc_irqs_disabled) {
+		enable_irq(priv->irqs_table[CPSW_IRQ_TYPE_MISC]);
+		priv->misc_irqs_disabled = false;
+	}
+	cpsw_intr_rx_enable(priv);
+	cpsw_intr_tx_enable(priv);
+	cpsw_intr_misc_enable(priv);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+ }
+
 static void cpsw_intr_disable(struct cpsw_priv *priv)
 {
-	__raw_writel(0, &priv->wr_regs->tx_en);
-	__raw_writel(0, &priv->wr_regs->rx_en);
+	unsigned long flags;
+	spin_lock_irqsave(&priv->lock, flags);
+	if (!priv->rx_irqs_disabled) {
+		disable_irq_nosync(priv->irqs_table[CPSW_IRQ_TYPE_RX]);
+		priv->rx_irqs_disabled = true;
+	}
+	if (!priv->tx_irqs_disabled) {
+		disable_irq_nosync(priv->irqs_table[CPSW_IRQ_TYPE_TX]);
+		priv->tx_irqs_disabled = true;
+	}
+	if (!priv->misc_irqs_disabled) {
+		disable_irq_nosync(priv->irqs_table[CPSW_IRQ_TYPE_MISC]);
+		priv->misc_irqs_disabled = true;
+	}
 
-	cpdma_ctlr_int_ctrl(priv->dma, false);
+	cpsw_intr_rx_disable(priv);
+	cpsw_intr_tx_disable(priv);
+	cpsw_intr_misc_disable(priv);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
 	return;
 }
 
@@ -422,15 +504,57 @@ void cpsw_rx_handler(void *token, int len, int status)
 	WARN_ON(ret < 0);
 }
 
-static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
+static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_priv *priv = dev_id;
+	unsigned long flags;
 
-	if (likely(netif_running(priv->ndev))) {
-		cpsw_intr_disable(priv);
-		cpsw_disable_irq(priv);
+	spin_lock_irqsave(&priv->lock, flags);
+	disable_irq_nosync(irq);
+	priv->rx_irqs_disabled = true;
+	cpsw_intr_rx_disable(priv);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	if (netif_running(priv->ndev))
 		napi_schedule(&priv->napi);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
+{
+	struct cpsw_priv *priv = dev_id;
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	disable_irq_nosync(irq);
+	priv->tx_irqs_disabled = true;
+	cpsw_intr_tx_disable(priv);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	if (netif_running(priv->ndev))
+		napi_schedule(&priv->napi);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t cpsw_misc_interrupt(int irq, void *dev_id)
+{
+	struct cpsw_priv *priv = dev_id;
+	unsigned long flags;
+
+	if (!netif_running(priv->ndev)) {
+		spin_lock_irqsave(&priv->lock, flags);
+		disable_irq_nosync(irq);
+		priv->misc_irqs_disabled = true;
+		cpsw_intr_misc_disable(priv);
+		spin_unlock_irqrestore(&priv->lock, flags);
+		return IRQ_HANDLED;
 	}
+
+	printk(KERN_ERR "Host error: %x\n", cpdma_get_host_state(priv->dma));
+	cpdma_ctlr_misc_eoi(priv->dma);
+
 	return IRQ_HANDLED;
 }
 
@@ -445,20 +569,39 @@ static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
 static int cpsw_poll(struct napi_struct *napi, int budget)
 {
 	struct cpsw_priv	*priv = napi_to_priv(napi);
-	int			num_tx, num_rx;
+	int			num_rx = 0;
+	int			txcnt = 0;
+	int			tx;
+	unsigned long		flags;
 
-	num_tx = cpdma_chan_process(priv->txch, 128);
-	num_rx = cpdma_chan_process(priv->rxch, budget);
-
-	if (num_rx || num_tx)
-		cpsw_dbg(priv, intr, "poll %d rx, %d tx pkts\n",
-			 num_rx, num_tx);
+	/* cleanup the complete TX queue */
+	do {
+		tx = cpdma_chan_process(priv->txch, 128);
+		if (tx > 0)
+			txcnt += tx;
+	} while (tx == 128);
+	if (txcnt) {
+		spin_lock_irqsave(&priv->lock, flags);
+		if (priv->tx_irqs_disabled == true) {
+			cpsw_intr_tx_enable(priv);
+			cpdma_ctlr_tx_eoi(priv->dma);
+			enable_irq(priv->irqs_table[CPSW_IRQ_TYPE_TX]);
+			priv->tx_irqs_disabled = false;
+		}
+		spin_unlock_irqrestore(&priv->lock, flags);
+	}
 
+	num_rx = cpdma_chan_process(priv->rxch, budget);
 	if (num_rx < budget) {
-		napi_complete(napi);
-		cpsw_intr_enable(priv);
-		cpdma_ctlr_eoi(priv->dma);
-		cpsw_enable_irq(priv);
+		spin_lock_irqsave(&priv->lock, flags);
+		if (priv->rx_irqs_disabled == true) {
+			napi_complete(napi);
+			cpsw_intr_rx_enable(priv);
+			cpdma_ctlr_rx_eoi(priv->dma);
+			enable_irq(priv->irqs_table[CPSW_IRQ_TYPE_RX]);
+			priv->rx_irqs_disabled = false;
+		}
+		spin_unlock_irqrestore(&priv->lock, flags);
 	}
 
 	return num_rx;
@@ -679,7 +822,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 	napi_enable(&priv->napi);
-	cpdma_ctlr_eoi(priv->dma);
+	cpdma_ctlr_rx_eoi(priv->dma);
+	cpdma_ctlr_tx_eoi(priv->dma);
 
 	return 0;
 }
@@ -702,7 +846,6 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	napi_disable(&priv->napi);
 	netif_carrier_off(priv->ndev);
 	cpsw_intr_disable(priv);
-	cpdma_ctlr_int_ctrl(priv->dma, false);
 	cpdma_ctlr_stop(priv->dma);
 	cpsw_ale_stop(priv->ale);
 	for_each_slave(priv, cpsw_slave_stop, priv);
@@ -896,12 +1039,11 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 	cpsw_err(priv, tx_err, "transmit timeout, restarting dma\n");
 	priv->stats.tx_errors++;
 	cpsw_intr_disable(priv);
-	cpdma_ctlr_int_ctrl(priv->dma, false);
 	cpdma_chan_stop(priv->txch);
 	cpdma_chan_start(priv->txch);
-	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
-	cpdma_ctlr_eoi(priv->dma);
+	cpdma_ctlr_rx_eoi(priv->dma);
+	cpdma_ctlr_tx_eoi(priv->dma);
 }
 
 static struct net_device_stats *cpsw_ndo_get_stats(struct net_device *ndev)
@@ -916,11 +1058,11 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
 	cpsw_intr_disable(priv);
-	cpdma_ctlr_int_ctrl(priv->dma, false);
-	cpsw_interrupt(ndev->irq, priv);
-	cpdma_ctlr_int_ctrl(priv->dma, true);
+	cpsw_rx_interrupt(priv->irqs_table[CPSW_IRQ_TYPE_RX], priv);
+	cpsw_tx_interrupt(priv->irqs_table[CPSW_IRQ_TYPE_TX], priv);
 	cpsw_intr_enable(priv);
-	cpdma_ctlr_eoi(priv->dma);
+	cpdma_ctlr_rx_eoi(priv->dma);
+	cpdma_ctlr_tx_eoi(priv->dma);
 }
 #endif
 
@@ -1333,17 +1475,37 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
+	priv->num_irqs = 0;
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
-		for (i = res->start; i <= res->end; i++) {
-			if (request_irq(i, cpsw_interrupt, IRQF_DISABLED,
+		i = res->start;
+		switch (k) {
+		case CPSW_IRQ_TYPE_RX_THRESH:
+			i = 0;
+			break;
+		case CPSW_IRQ_TYPE_RX:
+			if (request_irq(i, cpsw_rx_interrupt, 0,
 					dev_name(&pdev->dev), priv)) {
 				dev_err(priv->dev, "error attaching irq\n");
-				goto clean_ale_ret;
+				goto clean_irq_ret;
 			}
-			priv->irqs_table[k] = i;
-			priv->num_irqs = k;
+			break;
+		case CPSW_IRQ_TYPE_TX:
+			if (request_irq(i, cpsw_tx_interrupt, 0,
+					dev_name(&pdev->dev), priv)) {
+				dev_err(priv->dev, "error attaching irq\n");
+				goto clean_irq_ret;
+			}
+			break;
+		case CPSW_IRQ_TYPE_MISC:
+			if (request_irq(i, cpsw_misc_interrupt, 0,
+					dev_name(&pdev->dev), priv)) {
+				dev_err(priv->dev, "error attaching irq\n");
+				goto clean_irq_ret;
+			}
+			break;
 		}
-		k++;
+		priv->irqs_table[k++] = i;
+		priv->num_irqs = k;
 	}
 
 	ndev->flags |= IFF_ALLMULTI;	/* see cpsw_ndo_change_rx_flags() */
@@ -1371,7 +1533,10 @@ static int cpsw_probe(struct platform_device *pdev)
 	return 0;
 
 clean_irq_ret:
-	free_irq(ndev->irq, priv);
+	for (i = 0; i < priv->num_irqs; i++) {
+		if (priv->irqs_table[i] > 0)
+			free_irq(priv->irqs_table[i], priv);
+	}
 clean_ale_ret:
 	cpsw_ale_destroy(priv->ale);
 clean_dma_ret:
@@ -1402,12 +1567,16 @@ static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	int i;
 
 	pr_info("removing device");
 	platform_set_drvdata(pdev, NULL);
 
 	cpts_unregister(&priv->cpts);
-	free_irq(ndev->irq, priv);
+	for (i = 0; i < priv->num_irqs; i++) {
+		if (priv->irqs_table[i] > 0)
+			free_irq(priv->irqs_table[i], priv);
+	}
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
 	cpdma_chan_destroy(priv->rxch);
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 70325cd..8c7c589 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -479,7 +479,7 @@ EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 {
 	unsigned long flags;
-	int i, reg;
+	int reg;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
 	if (ctlr->state != CPDMA_STATE_ACTIVE) {
@@ -489,20 +489,35 @@ int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 
 	reg = enable ? CPDMA_DMAINTMASKSET : CPDMA_DMAINTMASKCLEAR;
 	dma_reg_write(ctlr, reg, CPDMA_DMAINT_HOSTERR);
-
-	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
-		if (ctlr->channels[i])
-			cpdma_chan_int_ctrl(ctlr->channels[i], enable);
-	}
-
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_int_ctrl);
+
+u32 cpdma_get_host_state(struct cpdma_ctlr *ctlr)
+{
+	return dma_reg_read(ctlr, CPDMA_DMASTATUS);
+}
+EXPORT_SYMBOL_GPL(cpdma_get_host_state);
+
+void cpdma_ctlr_rx_eoi(struct cpdma_ctlr *ctlr)
+{
+	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 1);
+}
+EXPORT_SYMBOL_GPL(cpdma_ctlr_rx_eoi);
+
+void cpdma_ctlr_tx_eoi(struct cpdma_ctlr *ctlr)
+{
+	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 2);
+}
+EXPORT_SYMBOL_GPL(cpdma_ctlr_tx_eoi);
 
-void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr)
+void cpdma_ctlr_misc_eoi(struct cpdma_ctlr *ctlr)
 {
 	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 0);
+	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 3);
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_misc_eoi);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler)
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index afa19a0..083a0cc 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -86,8 +86,11 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
-void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr);
+void cpdma_ctlr_rx_eoi(struct cpdma_ctlr *ctlr);
+void cpdma_ctlr_tx_eoi(struct cpdma_ctlr *ctlr);
+void cpdma_ctlr_misc_eoi(struct cpdma_ctlr *ctlr);
 int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
+u32 cpdma_get_host_state(struct cpdma_ctlr *ctlr);
 
 enum cpdma_control {
 	CPDMA_CMD_IDLE,			/* write-only */
-- 
1.7.6.5
