From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 4/8] stmmac: make stmmac_probe_config_dt return the platform data struct
Date: Fri, 17 Jul 2015 00:26:08 +0200
Message-ID: <1437085572-11371-5-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:33257 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbbGPW0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:38 -0400
Received: by laem6 with SMTP id m6so51645903lae.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:37 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since stmmac_probe_config_dt() allocates the platform data structure
it is cleaner if it just returned this structure directly. This
function will later be used in the probe function in dwmac-* drivers.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 28 ++++++++++------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 94962d75b99a..ea467be93673 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -104,9 +104,8 @@ static int dwmac1000_validate_ucast_entries(int ucast_entries)
  * this function is to read the driver parameters from device-tree and
  * set some private fields that will be used by the main at runtime.
  */
-static int stmmac_probe_config_dt(struct platform_device *pdev,
-				  struct plat_stmmacenet_data **plat_dat,
-				  const char **mac)
+static struct plat_stmmacenet_data *
+stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct plat_stmmacenet_data *plat;
@@ -115,9 +114,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 
 	plat = devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
 	if (!plat)
-		return -ENOMEM;
-
-	*plat_dat = plat;
+		return ERR_PTR(-ENOMEM);
 
 	data = of_device_get_match_data(&pdev->dev);
 	if (data) {
@@ -156,7 +153,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	/* If phy-handle is not specified, check if we have a fixed-phy */
 	if (!plat->phy_node && of_phy_is_fixed_link(np)) {
 		if ((of_phy_register_fixed_link(np) < 0))
-			return -ENODEV;
+			return ERR_PTR(-ENODEV);
 
 		plat->phy_node = of_node_get(np);
 	}
@@ -233,7 +230,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 				       GFP_KERNEL);
 		if (!dma_cfg) {
 			of_node_put(np);
-			return -ENOMEM;
+			return ERR_PTR(-ENOMEM);
 		}
 		plat->dma_cfg = dma_cfg;
 		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
@@ -251,14 +248,13 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 		pr_warn("force_sf_dma_mode is ignored if force_thresh_dma_mode is set.");
 	}
 
-	return 0;
+	return plat;
 }
 #else
-static int stmmac_probe_config_dt(struct platform_device *pdev,
-				  struct plat_stmmacenet_data **plat,
-				  const char **mac)
+static struct plat_stmmacenet_data *
+stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
-	return -ENOSYS;
+	return ERR_PTR(-ENOSYS);
 }
 #endif /* CONFIG_OF */
 
@@ -325,10 +321,10 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 		return ret;
 
 	if (pdev->dev.of_node) {
-		ret = stmmac_probe_config_dt(pdev, &plat_dat, &stmmac_res.mac);
-		if (ret) {
+		plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+		if (IS_ERR(plat_dat)) {
 			dev_err(&pdev->dev, "dt configuration failed\n");
-			return ret;
+			return PTR_ERR(plat_dat);
 		}
 	} else {
 		plat_dat = dev_get_platdata(&pdev->dev);
-- 
1.8.0
