From: Felipe Balbi <balbi@ti.com>
Subject: [patch-net-next 3/3] net: ethernet: cpsw: don't requests IRQs we don't use
Date: Tue, 13 Jan 2015 13:44:48 -0600
Message-ID: <1421178288-7393-3-git-send-email-balbi@ti.com>
References: <1421178288-7393-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tony Lindgren <tony@atomide.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:42715 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbbAMTpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:45:36 -0500
In-Reply-To: <1421178288-7393-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPSW never uses RX_THRESHOLD or MISC interrupts. In
fact, they are always kept masked in their appropriate
IRQ Enable register.

Instead of allocating an IRQ that never fires, it's best
to remove that code altogether and let future patches
implement it if anybody needs those.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 55 ++++++++++++------------------------------
 1 file changed, 15 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c9081bdbbcbc..fd0acd9b41ae 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -754,16 +754,6 @@ requeue:
 		dev_kfree_skb_any(new_skb);
 }
 
-static irqreturn_t cpsw_dummy_interrupt(int irq, void *dev_id)
-{
-	struct cpsw_priv *priv = dev_id;
-	int value = irq - priv->irqs_table[0];
-
-	cpdma_ctlr_eoi(priv->dma, value);
-
-	return IRQ_HANDLED;
-}
-
 static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_priv *priv = dev_id;
@@ -1635,8 +1625,8 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
 
 	cpsw_intr_disable(priv);
 	cpdma_ctlr_int_ctrl(priv->dma, false);
-	cpsw_rx_interrupt(priv->irq[1], priv);
-	cpsw_tx_interrupt(priv->irq[2], priv);
+	cpsw_rx_interrupt(priv->irq[0], priv);
+	cpsw_tx_interrupt(priv->irq[1], priv);
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	cpsw_intr_enable(priv);
 }
@@ -2358,30 +2348,27 @@ static int cpsw_probe(struct platform_device *pdev)
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
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_dummy_interrupt,
-			0, dev_name(&pdev->dev), priv);
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
+	priv->irqs_table[0] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
 			0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
@@ -2389,31 +2376,19 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
+	/* TX IRQ */
 	irq = platform_get_irq(pdev, 2);
 	if (irq < 0)
 		goto clean_ale_ret;
 
-	priv->irqs_table[2] = irq;
+	priv->irqs_table[1] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
 			0, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
 	}
-
-	irq = platform_get_irq(pdev, 3);
-	if (irq < 0)
-		goto clean_ale_ret;
-
-	priv->irqs_table[3] = irq;
-	ret = devm_request_irq(&pdev->dev, irq, cpsw_dummy_interrupt,
-			0, dev_name(&pdev->dev), priv);
-	if (ret < 0) {
-		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
-		goto clean_ale_ret;
-	}
-
-	priv->num_irqs = 4;
+	priv->num_irqs = 2;
 
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-- 
2.2.0
