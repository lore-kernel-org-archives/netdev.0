From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 6/8] stmmac: add proper probe function to dwmac-lpc18xx
Date: Fri, 17 Jul 2015 00:26:10 +0200
Message-ID: <1437085572-11371-7-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35069 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380AbbGPW0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:40 -0400
Received: by lahh5 with SMTP id h5so51606819lah.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:39 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using a few functions from stmmac_platform we can now create
a proper probe function in this driver. By doing so we can drop
the OF match data and simplify the overall driver.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 59 +++++++++-------------
 1 file changed, 23 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
index cb888d3ebbdc..78e9d1861896 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
@@ -25,66 +25,53 @@
 # define LPC18XX_CREG_CREG6_ETHMODE_MII		0x0
 # define LPC18XX_CREG_CREG6_ETHMODE_RMII	0x4
 
-struct lpc18xx_dwmac_priv_data {
+static int lpc18xx_dwmac_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
 	struct regmap *reg;
-	int interface;
-};
+	u8 ethmode;
+	int ret;
 
-static void *lpc18xx_dwmac_setup(struct platform_device *pdev)
-{
-	struct lpc18xx_dwmac_priv_data *dwmac;
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
 
-	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return ERR_PTR(-ENOMEM);
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
 
-	dwmac->interface = of_get_phy_mode(pdev->dev.of_node);
-	if (dwmac->interface < 0)
-		return ERR_PTR(dwmac->interface);
+	plat_dat->has_gmac = true;
 
-	dwmac->reg = syscon_regmap_lookup_by_compatible("nxp,lpc1850-creg");
-	if (IS_ERR(dwmac->reg)) {
-		dev_err(&pdev->dev, "Syscon lookup failed\n");
-		return dwmac->reg;
+	reg = syscon_regmap_lookup_by_compatible("nxp,lpc1850-creg");
+	if (IS_ERR(reg)) {
+		dev_err(&pdev->dev, "syscon lookup failed\n");
+		return PTR_ERR(reg);
 	}
 
-	return dwmac;
-}
-
-static int lpc18xx_dwmac_init(struct platform_device *pdev, void *priv)
-{
-	struct lpc18xx_dwmac_priv_data *dwmac = priv;
-	u8 ethmode;
-
-	if (dwmac->interface == PHY_INTERFACE_MODE_MII) {
+	if (plat_dat->interface == PHY_INTERFACE_MODE_MII) {
 		ethmode = LPC18XX_CREG_CREG6_ETHMODE_MII;
-	} else if (dwmac->interface == PHY_INTERFACE_MODE_RMII) {
+	} else if (plat_dat->interface == PHY_INTERFACE_MODE_RMII) {
 		ethmode = LPC18XX_CREG_CREG6_ETHMODE_RMII;
 	} else {
 		dev_err(&pdev->dev, "Only MII and RMII mode supported\n");
 		return -EINVAL;
 	}
 
-	regmap_update_bits(dwmac->reg, LPC18XX_CREG_CREG6,
+	regmap_update_bits(reg, LPC18XX_CREG_CREG6,
 			   LPC18XX_CREG_CREG6_ETHMODE_MASK, ethmode);
 
-	return 0;
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
-static const struct stmmac_of_data lpc18xx_dwmac_data = {
-	.has_gmac = 1,
-	.setup = lpc18xx_dwmac_setup,
-	.init = lpc18xx_dwmac_init,
-};
-
 static const struct of_device_id lpc18xx_dwmac_match[] = {
-	{ .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data },
+	{ .compatible = "nxp,lpc1850-dwmac" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, lpc18xx_dwmac_match);
 
 static struct platform_driver lpc18xx_dwmac_driver = {
-	.probe  = stmmac_pltfr_probe,
+	.probe  = lpc18xx_dwmac_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "lpc18xx-dwmac",
-- 
1.8.0
