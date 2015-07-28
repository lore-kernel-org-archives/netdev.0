From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 05/17] stmmac: dwmac-socfpga: turn setup callback into a probe function
Date: Wed, 29 Jul 2015 00:08:52 +0200
Message-ID: <1438121344-5304-6-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, dinguyen@opensource.altera.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35329 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbbG1WJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:27 -0400
Received: by lahh5 with SMTP id h5so77070088lah.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:25 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using a few functions from stmmac_platform a proper probe
function can be created from the setup glue callback. This
makes it look more like a standard driver and the OF match
data can also be dropped.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 40 ++++++++++++++--------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 0df409e2edcd..401383b252a8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -232,46 +232,58 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
 	return ret;
 }
 
-static void *socfpga_dwmac_probe(struct platform_device *pdev)
+static int socfpga_dwmac_probe(struct platform_device *pdev)
 {
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
 	struct device		*dev = &pdev->dev;
 	int			ret;
 	struct socfpga_dwmac	*dwmac;
 
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
+
 	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
 	if (!dwmac)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	ret = socfpga_dwmac_parse_data(dwmac, dev);
 	if (ret) {
 		dev_err(dev, "Unable to parse OF data\n");
-		return ERR_PTR(ret);
+		return ret;
 	}
 
 	ret = socfpga_dwmac_setup(dwmac);
 	if (ret) {
 		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
-		return ERR_PTR(ret);
+		return ret;
 	}
 
-	return dwmac;
-}
+	plat_dat->bsp_priv = dwmac;
+	plat_dat->init = socfpga_dwmac_init;
+	plat_dat->exit = socfpga_dwmac_exit;
+	plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
 
-static const struct stmmac_of_data socfpga_gmac_data = {
-	.setup = socfpga_dwmac_probe,
-	.init = socfpga_dwmac_init,
-	.exit = socfpga_dwmac_exit,
-	.fix_mac_speed = socfpga_dwmac_fix_mac_speed,
-};
+	ret = socfpga_dwmac_init(pdev, plat_dat->bsp_priv);
+	if (ret)
+		return ret;
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
 
 static const struct of_device_id socfpga_dwmac_match[] = {
-	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
+	{ .compatible = "altr,socfpga-stmmac" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, socfpga_dwmac_match);
 
 static struct platform_driver socfpga_dwmac_driver = {
-	.probe  = stmmac_pltfr_probe,
+	.probe  = socfpga_dwmac_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "socfpga-dwmac",
-- 
1.8.0
