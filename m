From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 10/17] stmmac: move stmmac_pltfr_probe into dwmac-generic
Date: Wed, 29 Jul 2015 00:08:57 +0200
Message-ID: <1438121344-5304-11-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36109 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbG1WJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:32 -0400
Received: by lbbqi7 with SMTP id qi7so83900945lbb.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:31 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As all dwmac-* drivers now have their own probe function move
the common one into dwmac-generic driver and drop the EXPORT.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-generic.c    | 49 ++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 55 ----------------------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 -
 3 files changed, 48 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
index e817a1a44379..f4fe9f1a33b4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -16,6 +16,53 @@
 #include "stmmac.h"
 #include "stmmac_platform.h"
 
+static int dwmac_generic_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+	int ret;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	if (pdev->dev.of_node) {
+		plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+		if (IS_ERR(plat_dat)) {
+			dev_err(&pdev->dev, "dt configuration failed\n");
+			return PTR_ERR(plat_dat);
+		}
+	} else {
+		plat_dat = dev_get_platdata(&pdev->dev);
+		if (!plat_dat) {
+			dev_err(&pdev->dev, "no platform data provided\n");
+			return  -EINVAL;
+		}
+
+		/* Set default value for multicast hash bins */
+		plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+		/* Set default value for unicast filter entries */
+		plat_dat->unicast_filter_entries = 1;
+	}
+
+	/* Custom setup (if needed) */
+	if (plat_dat->setup) {
+		plat_dat->bsp_priv = plat_dat->setup(pdev);
+		if (IS_ERR(plat_dat->bsp_priv))
+			return PTR_ERR(plat_dat->bsp_priv);
+	}
+
+	/* Custom initialisation (if needed) */
+	if (plat_dat->init) {
+		ret = plat_dat->init(pdev, plat_dat->bsp_priv);
+		if (ret)
+			return ret;
+	}
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
+
 static const struct of_device_id dwmac_generic_match[] = {
 	{ .compatible = "st,spear600-gmac"},
 	{ .compatible = "snps,dwmac-3.610"},
@@ -27,7 +74,7 @@ static const struct of_device_id dwmac_generic_match[] = {
 MODULE_DEVICE_TABLE(of, dwmac_generic_match);
 
 static struct platform_driver dwmac_generic_driver = {
-	.probe  = stmmac_pltfr_probe,
+	.probe  = dwmac_generic_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = STMMAC_RESOURCE_NAME,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1dcb5ebefe5c..9c49d95e529a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -304,61 +304,6 @@ int stmmac_get_platform_resources(struct platform_device *pdev,
 EXPORT_SYMBOL_GPL(stmmac_get_platform_resources);
 
 /**
- * stmmac_pltfr_probe - platform driver probe.
- * @pdev: platform device pointer
- * Description: platform_device probe function. It is to allocate
- * the necessary platform resources, invoke custom helper (if required) and
- * invoke the main probe function.
- */
-int stmmac_pltfr_probe(struct platform_device *pdev)
-{
-	struct plat_stmmacenet_data *plat_dat;
-	struct stmmac_resources stmmac_res;
-	int ret;
-
-	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
-	if (ret)
-		return ret;
-
-	if (pdev->dev.of_node) {
-		plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
-		if (IS_ERR(plat_dat)) {
-			dev_err(&pdev->dev, "dt configuration failed\n");
-			return PTR_ERR(plat_dat);
-		}
-	} else {
-		plat_dat = dev_get_platdata(&pdev->dev);
-		if (!plat_dat) {
-			dev_err(&pdev->dev, "no platform data provided\n");
-			return  -EINVAL;
-		}
-
-		/* Set default value for multicast hash bins */
-		plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
-
-		/* Set default value for unicast filter entries */
-		plat_dat->unicast_filter_entries = 1;
-	}
-
-	/* Custom setup (if needed) */
-	if (plat_dat->setup) {
-		plat_dat->bsp_priv = plat_dat->setup(pdev);
-		if (IS_ERR(plat_dat->bsp_priv))
-			return PTR_ERR(plat_dat->bsp_priv);
-	}
-
-	/* Custom initialisation (if needed)*/
-	if (plat_dat->init) {
-		ret = plat_dat->init(pdev, plat_dat->bsp_priv);
-		if (unlikely(ret))
-			return ret;
-	}
-
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
-}
-EXPORT_SYMBOL_GPL(stmmac_pltfr_probe);
-
-/**
  * stmmac_pltfr_remove
  * @pdev: platform device pointer
  * Description: this function calls the main to free the net resources
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 84ceb5342686..ffeb8d9e2b2e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -27,7 +27,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac);
 int stmmac_get_platform_resources(struct platform_device *pdev,
 				  struct stmmac_resources *stmmac_res);
 
-int stmmac_pltfr_probe(struct platform_device *pdev);
 int stmmac_pltfr_remove(struct platform_device *pdev);
 extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
 
-- 
1.8.0
