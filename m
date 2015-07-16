From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 7/8] stmmac: add proper probe function to dwmac-meson
Date: Fri, 17 Jul 2015 00:26:11 +0200
Message-ID: <1437085572-11371-8-git-send-email-manabian@gmail.com>
References: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net, b.galvani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:34865 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317AbbGPW0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:41 -0400
Received: by lblf12 with SMTP id f12so51840169lbl.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:40 -0700 (PDT)
In-Reply-To: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using a few functions from stmmac_platform we can now create
a proper probe function in this driver. By doing so we can drop
the OF match data and simplify the overall driver.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c | 31 +++++++++++++++--------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
index 61a324a87d09..c1bac1912b37 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
@@ -47,36 +47,45 @@ static void meson6_dwmac_fix_mac_speed(void *priv, unsigned int speed)
 	writel(val, dwmac->reg);
 }
 
-static void *meson6_dwmac_setup(struct platform_device *pdev)
+static int meson6_dwmac_probe(struct platform_device *pdev)
 {
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
 	struct meson_dwmac *dwmac;
 	struct resource *res;
+	int ret;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
 
 	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
 	if (!dwmac)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	dwmac->reg = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(dwmac->reg))
-		return ERR_CAST(dwmac->reg);
+		return PTR_ERR(dwmac->reg);
 
-	return dwmac;
-}
+	plat_dat->bsp_priv = dwmac;
+	plat_dat->fix_mac_speed = meson6_dwmac_fix_mac_speed;
 
-static const struct stmmac_of_data meson6_dwmac_data = {
-	.setup		= meson6_dwmac_setup,
-	.fix_mac_speed	= meson6_dwmac_fix_mac_speed,
-};
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
 
 static const struct of_device_id meson6_dwmac_match[] = {
-	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
+	{ .compatible = "amlogic,meson6-dwmac" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, meson6_dwmac_match);
 
 static struct platform_driver meson6_dwmac_driver = {
-	.probe  = stmmac_pltfr_probe,
+	.probe  = meson6_dwmac_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "meson6-dwmac",
-- 
1.8.0
