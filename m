From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 03/11] stmmac: prepare stmmac platform to support stand alone drivers
Date: Thu, 14 May 2015 12:10:58 +0200
Message-ID: <1431598266-25736-4-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36585 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932828AbbENKLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:43 -0400
Received: by lagv1 with SMTP id v1so60437401lag.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:42 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare the stmmac platform code to support standalone drivers
by exporting the need functions and having of_match_device use
the match table reference already present in the driver struct.

This will allow us to reuse the platform driver functions from
this code easily in other stand alone platform drivers.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 14 +++++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h |  4 ++++
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1ac7c8a2c631..0d1f1ec96bc0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -130,11 +130,12 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	struct device_node *np = pdev->dev.of_node;
 	struct stmmac_dma_cfg *dma_cfg;
 	const struct of_device_id *device;
+	struct device *dev = &pdev->dev;
 
 	if (!np)
 		return -ENODEV;
 
-	device = of_match_device(stmmac_dt_ids, &pdev->dev);
+	device = of_match_device(dev->driver->of_match_table, dev);
 	if (!device)
 		return -ENODEV;
 
@@ -269,7 +270,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
  * the necessary platform resources, invoke custom helper (if required) and
  * invoke the main probe function.
  */
-static int stmmac_pltfr_probe(struct platform_device *pdev)
+int stmmac_pltfr_probe(struct platform_device *pdev)
 {
 	int ret = 0;
 	struct resource *res;
@@ -375,6 +376,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(stmmac_pltfr_probe);
 
 /**
  * stmmac_pltfr_remove
@@ -382,7 +384,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
  * Description: this function calls the main to free the net resources
  * and calls the platforms hook and release the resources (e.g. mem).
  */
-static int stmmac_pltfr_remove(struct platform_device *pdev)
+int stmmac_pltfr_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
@@ -396,6 +398,7 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(stmmac_pltfr_remove);
 
 #ifdef CONFIG_PM_SLEEP
 /**
@@ -439,8 +442,9 @@ static int stmmac_pltfr_resume(struct device *dev)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-static SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops,
-			 stmmac_pltfr_suspend, stmmac_pltfr_resume);
+SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops, stmmac_pltfr_suspend,
+				       stmmac_pltfr_resume);
+EXPORT_SYMBOL_GPL(stmmac_pltfr_pm_ops);
 
 static struct platform_driver stmmac_pltfr_driver = {
 	.probe = stmmac_pltfr_probe,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 59fe8fb46a48..5be0b101bffd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -19,6 +19,10 @@
 #ifndef __STMMAC_PLATFORM_H__
 #define __STMMAC_PLATFORM_H__
 
+int stmmac_pltfr_probe(struct platform_device *pdev);
+int stmmac_pltfr_remove(struct platform_device *pdev);
+extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
+
 extern const struct stmmac_of_data lpc18xx_dwmac_data;
 extern const struct stmmac_of_data meson6_dwmac_data;
 extern const struct stmmac_of_data sun7i_gmac_data;
-- 
1.8.0
