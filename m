From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 03/17] stmmac: dwmac-ipq806x: turn setup callback into a probe function
Date: Wed, 29 Jul 2015 00:08:50 +0200
Message-ID: <1438121344-5304-4-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net, mathieu@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:34693 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbbG1WJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:24 -0400
Received: by lbbzr7 with SMTP id zr7so83961849lbb.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:23 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using a few functions from stmmac_platform a proper probe
function can be created from the setup glue callback. This
makes it look more like a standard driver and the OF match
data can also be dropped.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-ipq806x.c    | 38 +++++++++++++---------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
index 5f1b3f9d8dba..333489f0fd24 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
@@ -255,23 +255,33 @@ static void ipq806x_gmac_fix_mac_speed(void *priv, unsigned int speed)
 	ipq806x_gmac_set_speed(gmac, speed);
 }
 
-static void *ipq806x_gmac_setup(struct platform_device *pdev)
+static int ipq806x_gmac_probe(struct platform_device *pdev)
 {
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
 	struct device *dev = &pdev->dev;
 	struct ipq806x_gmac *gmac;
 	int val;
 	void *err;
 
+	val = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (val)
+		return val;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
+
 	gmac = devm_kzalloc(dev, sizeof(*gmac), GFP_KERNEL);
 	if (!gmac)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	gmac->pdev = pdev;
 
 	err = ipq806x_gmac_of_parse(gmac);
-	if (err) {
+	if (IS_ERR(err)) {
 		dev_err(dev, "device tree parsing error\n");
-		return err;
+		return PTR_ERR(err);
 	}
 
 	regmap_write(gmac->qsgmii_csr, QSGMII_PCS_CAL_LCKDT_CTL,
@@ -292,7 +302,7 @@ static void *ipq806x_gmac_setup(struct platform_device *pdev)
 	default:
 		dev_err(&pdev->dev, "Unsupported PHY mode: \"%s\"\n",
 			phy_modes(gmac->phy_mode));
-		return NULL;
+		return -EINVAL;
 	}
 	regmap_write(gmac->nss_common, NSS_COMMON_GMAC_CTL(gmac->id), val);
 
@@ -311,7 +321,7 @@ static void *ipq806x_gmac_setup(struct platform_device *pdev)
 	default:
 		dev_err(&pdev->dev, "Unsupported PHY mode: \"%s\"\n",
 			phy_modes(gmac->phy_mode));
-		return NULL;
+		return -EINVAL;
 	}
 	regmap_write(gmac->nss_common, NSS_COMMON_CLK_SRC_CTRL, val);
 
@@ -334,23 +344,21 @@ static void *ipq806x_gmac_setup(struct platform_device *pdev)
 			     0xC << QSGMII_PHY_TX_DRV_AMP_OFFSET);
 	}
 
-	return gmac;
-}
+	plat_dat->has_gmac = true;
+	plat_dat->bsp_priv = gmac;
+	plat_dat->fix_mac_speed = ipq806x_gmac_fix_mac_speed;
 
-static const struct stmmac_of_data ipq806x_gmac_data = {
-	.has_gmac	= 1,
-	.setup		= ipq806x_gmac_setup,
-	.fix_mac_speed	= ipq806x_gmac_fix_mac_speed,
-};
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
 
 static const struct of_device_id ipq806x_gmac_dwmac_match[] = {
-	{ .compatible = "qcom,ipq806x-gmac", .data = &ipq806x_gmac_data },
+	{ .compatible = "qcom,ipq806x-gmac" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, ipq806x_gmac_dwmac_match);
 
 static struct platform_driver ipq806x_gmac_dwmac_driver = {
-	.probe = stmmac_pltfr_probe,
+	.probe = ipq806x_gmac_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name		= "ipq806x-gmac-dwmac",
-- 
1.8.0
