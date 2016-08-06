From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 10/14] net; ethernet: ti: cpsw: move irq stuff under cpsw_common
Date: Sat,  6 Aug 2016 13:48:40 +0300
Message-ID: <1470480524-6851-11-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The irq data are common per net device. So no need to hold these
data per net dev, move it under cpsw_common. Also delete irq_num
var, as after optimization it's not needed. Correct number of
irqs to 2, as anyway, driver is using only 2, at least for now.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 65 +++++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d3af373..4080487 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -143,6 +143,7 @@ do {								\
 #define cpsw_slave_index(priv)				\
 		((priv->data.dual_emac) ? priv->emac_port :	\
 		priv->data.active_slave)
+#define IRQ_NUM			2
 
 static int debug_level;
 module_param(debug_level, int, 0);
@@ -371,6 +372,10 @@ struct cpsw_common {
 	struct cpsw_host_regs __iomem	*host_port_regs;
 	struct cpdma_ctlr		*dma;
 	struct cpdma_chan		*txch, *rxch;
+	bool				quirk_irq;
+	bool				rx_irq_disabled;
+	bool				tx_irq_disabled;
+	u32 irqs_table[IRQ_NUM];
 };
 
 struct cpsw_priv {
@@ -389,12 +394,6 @@ struct cpsw_priv {
 	struct cpsw_ale			*ale;
 	bool				rx_pause;
 	bool				tx_pause;
-	bool				quirk_irq;
-	bool				rx_irq_disabled;
-	bool				tx_irq_disabled;
-	/* snapshot of IRQ numbers */
-	u32 irqs_table[4];
-	u32 num_irqs;
 	struct cpts *cpts;
 	u32 emac_port;
 	struct cpsw_common *cpsw;
@@ -758,9 +757,9 @@ static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 	writel(0, &cpsw->wr_regs->tx_en);
 	cpdma_ctlr_eoi(cpsw->dma, CPDMA_EOI_TX);
 
-	if (priv->quirk_irq) {
-		disable_irq_nosync(priv->irqs_table[1]);
-		priv->tx_irq_disabled = true;
+	if (cpsw->quirk_irq) {
+		disable_irq_nosync(cpsw->irqs_table[1]);
+		cpsw->tx_irq_disabled = true;
 	}
 
 	napi_schedule(&priv->napi_tx);
@@ -775,9 +774,9 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 	cpdma_ctlr_eoi(cpsw->dma, CPDMA_EOI_RX);
 	writel(0, &cpsw->wr_regs->rx_en);
 
-	if (priv->quirk_irq) {
-		disable_irq_nosync(priv->irqs_table[0]);
-		priv->rx_irq_disabled = true;
+	if (cpsw->quirk_irq) {
+		disable_irq_nosync(cpsw->irqs_table[0]);
+		cpsw->rx_irq_disabled = true;
 	}
 
 	napi_schedule(&priv->napi_rx);
@@ -794,9 +793,9 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 	if (num_tx < budget) {
 		napi_complete(napi_tx);
 		writel(0xff, &cpsw->wr_regs->tx_en);
-		if (priv->quirk_irq && priv->tx_irq_disabled) {
-			priv->tx_irq_disabled = false;
-			enable_irq(priv->irqs_table[1]);
+		if (cpsw->quirk_irq && cpsw->tx_irq_disabled) {
+			cpsw->tx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[1]);
 		}
 	}
 
@@ -814,9 +813,9 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 	if (num_rx < budget) {
 		napi_complete(napi_rx);
 		writel(0xff, &cpsw->wr_regs->rx_en);
-		if (priv->quirk_irq && priv->rx_irq_disabled) {
-			priv->rx_irq_disabled = false;
-			enable_irq(priv->irqs_table[0]);
+		if (cpsw->quirk_irq && cpsw->rx_irq_disabled) {
+			cpsw->rx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[0]);
 		}
 	}
 
@@ -1303,14 +1302,14 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		napi_enable(&priv_sl0->napi_rx);
 		napi_enable(&priv_sl0->napi_tx);
 
-		if (priv_sl0->tx_irq_disabled) {
-			priv_sl0->tx_irq_disabled = false;
-			enable_irq(priv->irqs_table[1]);
+		if (cpsw->tx_irq_disabled) {
+			cpsw->tx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[1]);
 		}
 
-		if (priv_sl0->rx_irq_disabled) {
-			priv_sl0->rx_irq_disabled = false;
-			enable_irq(priv->irqs_table[0]);
+		if (cpsw->rx_irq_disabled) {
+			cpsw->rx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[0]);
 		}
 
 		buf_num = cpdma_chan_get_rx_buf_num(cpsw->dma);
@@ -1659,8 +1658,8 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 	struct cpsw_common *cpsw = priv->cpsw;
 
 	cpsw_intr_disable(priv->cpsw);
-	cpsw_rx_interrupt(priv->irqs_table[0], priv);
-	cpsw_tx_interrupt(priv->irqs_table[1], priv);
+	cpsw_rx_interrupt(cpsw->irqs_table[0], priv);
+	cpsw_tx_interrupt(cpsw->irqs_table[1], priv);
 	cpsw_intr_enable(priv->cpsw);
 }
 #endif
@@ -2177,7 +2176,7 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 	struct cpsw_platform_data	*data = &priv->data;
 	struct net_device		*ndev;
 	struct cpsw_priv		*priv_sl2;
-	int ret = 0, i;
+	int ret = 0;
 	struct cpsw_common		*cpsw = priv->cpsw;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
@@ -2214,11 +2213,6 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 	priv->slaves[1].ndev = ndev;
 	priv_sl2->cpts = priv->cpts;
 	priv_sl2->version = priv->version;
-
-	for (i = 0; i < priv->num_irqs; i++) {
-		priv_sl2->irqs_table[i] = priv->irqs_table[i];
-		priv_sl2->num_irqs = priv->num_irqs;
-	}
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
@@ -2493,7 +2487,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (of_id) {
 		pdev->id_entry = of_id->data;
 		if (pdev->id_entry->driver_data)
-			priv->quirk_irq = true;
+			cpsw->quirk_irq = true;
 	}
 
 	/* Grab RX and TX IRQs. Note that we also have RX_THRESHOLD and
@@ -2511,7 +2505,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	priv->irqs_table[0] = irq;
+	cpsw->irqs_table[0] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
@@ -2526,14 +2520,13 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	priv->irqs_table[1] = irq;
+	cpsw->irqs_table[1] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
 	}
-	priv->num_irqs = 2;
 
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-- 
1.9.1
