From: Felipe Balbi <balbi@ti.com>
Subject: [patch-net-next 1/3] net: ethernet: cpsw: unroll IRQ request loop
Date: Tue, 13 Jan 2015 13:44:46 -0600
Message-ID: <1421178288-7393-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tony Lindgren <tony@atomide.com>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:32883 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbbAMTpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:45:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is in preparation for a nicer IRQ
handling scheme where we use different IRQ
handlers for each IRQ line (as it should be).

Later, we will also drop IRQs offset 0 and 3
because they are always disabled in this driver.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 62 ++++++++++++++++++++++++++++++++----------
 1 file changed, 47 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e61ee8351272..6e04128b9543 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2156,7 +2156,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	void __iomem			*ss_regs;
 	struct resource			*res, *ss_res;
 	u32 slave_offset, sliver_offset, slave_size;
-	int ret = 0, i, k = 0;
+	int ret = 0, i;
+	int irq;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
@@ -2345,24 +2346,55 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
-		if (k >= ARRAY_SIZE(priv->irqs_table)) {
-			ret = -EINVAL;
-			goto clean_ale_ret;
-		}
+	irq = platform_get_irq(pdev, 0);
+	if (irq < 0)
+		goto clean_ale_ret;
 
-		ret = devm_request_irq(&pdev->dev, res->start, cpsw_interrupt,
-				       0, dev_name(&pdev->dev), priv);
-		if (ret < 0) {
-			dev_err(priv->dev, "error attaching irq (%d)\n", ret);
-			goto clean_ale_ret;
-		}
+	priv->irqs_table[0] = irq;
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+			0, dev_name(&pdev->dev), priv);
+	if (ret < 0) {
+		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
+		goto clean_ale_ret;
+	}
 
-		priv->irqs_table[k] = res->start;
-		k++;
+	irq = platform_get_irq(pdev, 1);
+	if (irq < 0)
+		goto clean_ale_ret;
+
+	priv->irqs_table[1] = irq;
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+			0, dev_name(&pdev->dev), priv);
+	if (ret < 0) {
+		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
+		goto clean_ale_ret;
+	}
+
+	irq = platform_get_irq(pdev, 2);
+	if (irq < 0)
+		goto clean_ale_ret;
+
+	priv->irqs_table[2] = irq;
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+			0, dev_name(&pdev->dev), priv);
+	if (ret < 0) {
+		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
+		goto clean_ale_ret;
+	}
+
+	irq = platform_get_irq(pdev, 3);
+	if (irq < 0)
+		goto clean_ale_ret;
+
+	priv->irqs_table[3] = irq;
+	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
+			0, dev_name(&pdev->dev), priv);
+	if (ret < 0) {
+		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
+		goto clean_ale_ret;
 	}
 
-	priv->num_irqs = k;
+	priv->num_irqs = 4;
 
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-- 
2.2.0
