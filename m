From: Felipe Balbi <balbi@ti.com>
Subject: [patch-net-next v2 2/3] net: ethernet: cpsw: split out IRQ handler
Date: Wed, 14 Jan 2015 10:58:48 -0600
Message-ID: <1421254729-10602-2-git-send-email-balbi@ti.com>
References: <1421254729-10602-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tony Lindgren <tony@atomide.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>
To: <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1421254729-10602-1-git-send-email-balbi@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we can introduce dedicated IRQ handlers
for each of the IRQ events. This helps with
cleaning up a little bit of the clutter in
cpsw_interrupt() while also making sure that
TX IRQs will try to handle TX buffers while
RX IRQs will try to handle RX buffers.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8e1af51e4b76..c6c483f3e49f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -754,18 +754,36 @@ requeue:
 		dev_kfree_skb_any(new_skb);
 }
 
-static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
+static irqreturn_t cpsw_dummy_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_priv *priv = dev_id;
 	int value = irq - priv->irqs_table[0];
 
-	/* NOTICE: Ending IRQ here. The trick with the 'value' variable above
-	 * is to make sure we will always write the correct value to the EOI
-	 * register. Namely 0 for RX_THRESH Interrupt, 1 for RX Interrupt, 2
-	 * for TX Interrupt and 3 for MISC Interrupt.
-	 */
 	cpdma_ctlr_eoi(priv->dma, value);
 
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
+{
+	struct cpsw_priv *priv = dev_id;
+
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
+	cpdma_chan_process(priv->txch, 128);
+
+	priv = cpsw_get_slave_priv(priv, 1);
+	if (priv)
+		cpdma_chan_process(priv->txch, 128);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
+{
+	struct cpsw_priv *priv = dev_id;
+
+	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
+
 	cpsw_intr_disable(priv);
 	if (priv->irq_enabled == true) {
 		cpsw_disable_irq(priv);
@@ -1617,7 +1635,8 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 
 	cpsw_intr_disable(priv);
 	cpdma_ctlr_int_ctrl(priv->dma, false);
-	cpsw_interrupt(ndev->irq, priv);
+	cpsw_rx_interrupt(priv->irq[1], priv);
+	cpsw_tx_interrupt(priv->irq[2], priv);
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
 }
@@ -2351,7 +2370,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 
 	priv->irqs_table[0] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_dummy_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
@@ -2363,7 +2382,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 
 	priv->irqs_table[1] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
@@ -2375,7 +2394,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 
 	priv->irqs_table[2] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
@@ -2387,7 +2406,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 
 	priv->irqs_table[3] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_dummy_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
-- 
2.2.0

