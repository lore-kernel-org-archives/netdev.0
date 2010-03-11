From: Chaithrika U S <chaithrika@ti.com>
Subject: [PATCH] TI DaVinci EMAC: Convert to dev_pm_ops
Date: Thu, 11 Mar 2010 14:07:56 +0530
Message-ID: <1268296676-12514-1-git-send-email-chaithrika@ti.com>
Cc: davem@davemloft.net, --cc=khilman@deeprootsystems.com,
	davinci-linux-open-source@linux.davincidsp.com, nsekhar@ti.com,
	sudhakar.raj@ti.com, Chaithrika U S <chaithrika@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:57180 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754520Ab0CKJVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 04:21:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Migrate from the legacy PM hooks to use dev_pm_ops structure.

Signed-off-by: Chaithrika U S <chaithrika@ti.com>
---

This patch applies to Linus' kernel tree.
The fixes provided in this patch[1] are needed for EMAC driver to build.
[1]http://patchwork.kernel.org/patch/84267/

 drivers/net/davinci_emac.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 2526a9b..eb67fa6 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2829,31 +2829,37 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static
-int davinci_emac_suspend(struct platform_device *pdev, pm_message_t state)
+static int davinci_emac_suspend(struct device *dev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
+	struct platform_device *pdev = to_platform_device(dev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 
-	if (netif_running(dev))
-		emac_dev_stop(dev);
+	if (netif_running(ndev))
+		emac_dev_stop(ndev);
 
 	clk_disable(emac_clk);
 
 	return 0;
 }
 
-static int davinci_emac_resume(struct platform_device *pdev)
+static int davinci_emac_resume(struct device *dev)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
+	struct platform_device *pdev = to_platform_device(dev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 
 	clk_enable(emac_clk);
 
-	if (netif_running(dev))
-		emac_dev_open(dev);
+	if (netif_running(ndev))
+		emac_dev_open(ndev);
 
 	return 0;
 }
 
+static const struct dev_pm_ops davinci_emac_pm_ops = {
+	.suspend	= davinci_emac_suspend,
+	.resume		= davinci_emac_resume,
+};
+
 /**
  * davinci_emac_driver: EMAC platform driver structure
  */
@@ -2861,11 +2867,10 @@ static struct platform_driver davinci_emac_driver = {
 	.driver = {
 		.name	 = "davinci_emac",
 		.owner	 = THIS_MODULE,
+		.pm	 = &davinci_emac_pm_ops,
 	},
 	.probe = davinci_emac_probe,
 	.remove = __devexit_p(davinci_emac_remove),
-	.suspend = davinci_emac_suspend,
-	.resume = davinci_emac_resume,
 };
 
 /**
-- 
1.5.6

