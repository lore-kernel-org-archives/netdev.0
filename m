From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 07/17] stmmac: dwmac-sunxi: turn setup callback into a probe function
Date: Wed, 29 Jul 2015 00:08:54 +0200
Message-ID: <1438121344-5304-8-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, wens@csie.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33732 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbG1WJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:29 -0400
Received: by laah7 with SMTP id h7so77150486laa.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:28 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using a few functions from stmmac_platform a proper probe
function can be created from the setup glue callback. This
makes it look more like a standard driver and the OF match
data can also be dropped.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c | 49 ++++++++++++++---------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
index c9d6e2d5bfc9..52b8ed9bd87c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
@@ -103,54 +103,67 @@ static void sun7i_fix_speed(void *priv, unsigned int speed)
 	}
 }
 
-static void *sun7i_gmac_setup(struct platform_device *pdev)
+static int sun7i_gmac_probe(struct platform_device *pdev)
 {
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
 	struct sunxi_priv_data *gmac;
 	struct device *dev = &pdev->dev;
+	int ret;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
 
 	gmac = devm_kzalloc(dev, sizeof(*gmac), GFP_KERNEL);
 	if (!gmac)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	gmac->interface = of_get_phy_mode(dev->of_node);
 
 	gmac->tx_clk = devm_clk_get(dev, "allwinner_gmac_tx");
 	if (IS_ERR(gmac->tx_clk)) {
 		dev_err(dev, "could not get tx clock\n");
-		return gmac->tx_clk;
+		return PTR_ERR(gmac->tx_clk);
 	}
 
 	/* Optional regulator for PHY */
 	gmac->regulator = devm_regulator_get_optional(dev, "phy");
 	if (IS_ERR(gmac->regulator)) {
 		if (PTR_ERR(gmac->regulator) == -EPROBE_DEFER)
-			return ERR_PTR(-EPROBE_DEFER);
+			return -EPROBE_DEFER;
 		dev_info(dev, "no regulator found\n");
 		gmac->regulator = NULL;
 	}
 
-	return gmac;
-}
+	/* platform data specifying hardware features and callbacks.
+	 * hardware features were copied from Allwinner drivers. */
+	plat_dat->tx_coe = 1;
+	plat_dat->has_gmac = true;
+	plat_dat->bsp_priv = gmac;
+	plat_dat->init = sun7i_gmac_init;
+	plat_dat->exit = sun7i_gmac_exit;
+	plat_dat->fix_mac_speed = sun7i_fix_speed;
 
-/* of_data specifying hardware features and callbacks.
- * hardware features were copied from Allwinner drivers. */
-static const struct stmmac_of_data sun7i_gmac_data = {
-	.has_gmac = 1,
-	.tx_coe = 1,
-	.fix_mac_speed = sun7i_fix_speed,
-	.setup = sun7i_gmac_setup,
-	.init = sun7i_gmac_init,
-	.exit = sun7i_gmac_exit,
-};
+	ret = sun7i_gmac_init(pdev, plat_dat->bsp_priv);
+	if (ret)
+		return ret;
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
 
 static const struct of_device_id sun7i_dwmac_match[] = {
-	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
+	{ .compatible = "allwinner,sun7i-a20-gmac" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, sun7i_dwmac_match);
 
 static struct platform_driver sun7i_dwmac_driver = {
-	.probe  = stmmac_pltfr_probe,
+	.probe  = sun7i_gmac_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "sun7i-dwmac",
-- 
1.8.0
