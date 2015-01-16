From: Felipe Balbi <balbi@ti.com>
Subject: [patch-net-next v3 2/2] net: ethernet: cpsw: don't requests IRQs we don't use
Date: Fri, 16 Jan 2015 10:11:12 -0600
Message-ID: <1421424672-19323-2-git-send-email-balbi@ti.com>
References: <1421424672-19323-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tony Lindgren <tony@atomide.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>
To: <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1421424672-19323-1-git-send-email-balbi@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CPSW never uses RX_THRESHOLD or MISC interrupts. In
fact, they are always kept masked in their appropriate
IRQ Enable register.

Instead of allocating an IRQ that never fires, it's best
to remove that code altogether and let future patches
implement it if anybody needs those.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---

combined patches 2 and 3.

 drivers/net/ethernet/ti/cpsw.c | 72 +++++++++++++++++++-----------------------
 1 file changed, 33 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8e1af51e4b76..ba09ff3c1695 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -754,17 +754,25 @@ requeue:
 		dev_kfree_skb_any(new_skb);
 }
 
-static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
+static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_priv *priv = dev_id;
-	int value = irq - priv->irqs_table[0];
 
-	/* NOTICE: Ending IRQ here. The trick with the 'value' variable above
-	 * is to make sure we will always write the correct value to the EOI
-	 * register. Namely 0 for RX_THRESH Interrupt, 1 for RX Interrupt, 2
-	 * for TX Interrupt and 3 for MISC Interrupt.
-	 */
-	cpdma_ctlr_eoi(priv->dma, value);
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
 
 	cpsw_intr_disable(priv);
 	if (priv->irq_enabled == true) {
@@ -1617,7 +1625,8 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 
 	cpsw_intr_disable(priv);
 	cpdma_ctlr_int_ctrl(priv->dma, false);
-	cpsw_interrupt(ndev->irq, priv);
+	cpsw_rx_interrupt(priv->irq[0], priv);
+	cpsw_tx_interrupt(priv->irq[1], priv);
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
 }
@@ -2339,62 +2348,47 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_dma_ret;
 	}
 
-	ndev->irq = platform_get_irq(pdev, 0);
+	ndev->irq = platform_get_irq(pdev, 1);
 	if (ndev->irq < 0) {
 		dev_err(priv->dev, "error getting irq resource\n");
 		ret = -ENOENT;
 		goto clean_ale_ret;
 	}
 
-	irq = platform_get_irq(pdev, 0);
-	if (irq < 0)
-		goto clean_ale_ret;
-
-	priv->irqs_table[0] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
-			       0, dev_name(&pdev->dev), priv);
-	if (ret < 0) {
-		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
-		goto clean_ale_ret;
-	}
+	/* Grab RX and TX IRQs. Note that we also have RX_THRESHOLD and
+	 * MISC IRQs which are always kept disabled with this driver so
+	 * we will not request them.
+	 *
+	 * If anyone wants to implement support for those, make sure to
+	 * first request and append them to irqs_table array.
+	 */
 
+	/* RX IRQ */
 	irq = platform_get_irq(pdev, 1);
 	if (irq < 0)
 		goto clean_ale_ret;
 
-	priv->irqs_table[1] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+	priv->irqs_table[0] = irq;
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
 	}
 
+	/* TX IRQ */
 	irq = platform_get_irq(pdev, 2);
 	if (irq < 0)
 		goto clean_ale_ret;
 
-	priv->irqs_table[2] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
-			       0, dev_name(&pdev->dev), priv);
-	if (ret < 0) {
-		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
-		goto clean_ale_ret;
-	}
-
-	irq = platform_get_irq(pdev, 3);
-	if (irq < 0)
-		goto clean_ale_ret;
-
-	priv->irqs_table[3] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+	priv->irqs_table[1] = irq;
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
 			       0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
 	}
-
-	priv->num_irqs = 4;
+	priv->num_irqs = 2;
 
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-- 
2.2.0

