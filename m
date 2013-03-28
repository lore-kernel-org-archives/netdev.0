From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: [PATCH v2 3/3] net/macb: make clk_enable atomic
Date: Thu, 28 Mar 2013 10:07:07 +0100
Message-ID: <1364461627-26521-4-git-send-email-s.trumtrar@pengutronix.de>
References: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Steffen Trumtrar <s.trumtrar@pengutronix.de>,
	Fabio Estevam <festevam@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59352 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407Ab3C1JHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 05:07:25 -0400
In-Reply-To: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use clk_prepare_enable/clk_disable_unprepare to be safe on SMP systems.

Signed-off-by: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Fabio Estevam <festevam@gmail.com>
---

Changes in v2:
	- use clk_disable_unprepare() (reported by Fabio Estevam)
	- use clk_prepare_enable() in resume function

 drivers/net/ethernet/cadence/macb.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 71e766b..4378d63 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1561,14 +1561,14 @@ static int __init macb_probe(struct platform_device *pdev)
 		dev_err(&pdev->dev, "failed to get macb_clk\n");
 		goto err_out_free_dev;
 	}
-	clk_enable(bp->pclk);
+	clk_prepare_enable(bp->pclk);
 
 	bp->hclk = clk_get(&pdev->dev, "hclk");
 	if (IS_ERR(bp->hclk)) {
 		dev_err(&pdev->dev, "failed to get hclk\n");
 		goto err_out_put_pclk;
 	}
-	clk_enable(bp->hclk);
+	clk_prepare_enable(bp->hclk);
 
 	bp->regs = ioremap(regs->start, resource_size(regs));
 	if (!bp->regs) {
@@ -1658,9 +1658,9 @@ err_out_free_irq:
 err_out_iounmap:
 	iounmap(bp->regs);
 err_out_disable_clocks:
-	clk_disable(bp->hclk);
+	clk_disable_unprepare(bp->hclk);
 	clk_put(bp->hclk);
-	clk_disable(bp->pclk);
+	clk_disable_unprepare(bp->pclk);
 err_out_put_pclk:
 	clk_put(bp->pclk);
 err_out_free_dev:
@@ -1687,9 +1687,9 @@ static int __exit macb_remove(struct platform_device *pdev)
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		iounmap(bp->regs);
-		clk_disable(bp->hclk);
+		clk_disable_unprepare(bp->hclk);
 		clk_put(bp->hclk);
-		clk_disable(bp->pclk);
+		clk_disable_unprepare(bp->pclk);
 		clk_put(bp->pclk);
 		free_netdev(dev);
 		platform_set_drvdata(pdev, NULL);
@@ -1707,8 +1707,8 @@ static int macb_suspend(struct platform_device *pdev, pm_message_t state)
 	netif_carrier_off(netdev);
 	netif_device_detach(netdev);
 
-	clk_disable(bp->hclk);
-	clk_disable(bp->pclk);
+	clk_disable_unprepare(bp->hclk);
+	clk_disable_unprepare(bp->pclk);
 
 	return 0;
 }
@@ -1718,8 +1718,8 @@ static int macb_resume(struct platform_device *pdev)
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct macb *bp = netdev_priv(netdev);
 
-	clk_enable(bp->pclk);
-	clk_enable(bp->hclk);
+	clk_prepare_enable(bp->pclk);
+	clk_prepare_enable(bp->hclk);
 
 	netif_device_attach(netdev);
 
-- 
1.8.2.rc2
