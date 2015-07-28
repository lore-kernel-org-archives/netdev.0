From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 17/17] stmmac: dwmac-sti: refactor the init glue callbacks
Date: Wed, 29 Jul 2015 00:09:04 +0200
Message-ID: <1438121344-5304-18-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	kernel@stlinux.com
To: peppe.cavallaro@st.com, srinivas.kandagatla@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:33706 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbG1WJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:39 -0400
Received: by lbbnr7 with SMTP id nr7so5951358lbb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:38 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the two platform specific init callbacks and make
them use a common one by creating a function member in
the internal data structure. This allow us to remove the
layer of indirection and simplify the code a bit.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 43 +++++++------------------
 1 file changed, 12 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 83c501edb688..7f6f4a4fcc70 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -129,11 +129,11 @@ struct sti_dwmac {
 	struct device *dev;
 	struct regmap *regmap;
 	u32 speed;
+	void (*fix_retime_src)(void *priv, unsigned int speed);
 };
 
 struct sti_dwmac_of_data {
-	void (*fix_mac_speed)(void *priv, unsigned int speed);
-	int (*init)(struct platform_device *pdev, void *priv);
+	void (*fix_retime_src)(void *priv, unsigned int speed);
 };
 
 static u32 phy_intf_sels[] = {
@@ -228,8 +228,9 @@ static void stid127_fix_retime_src(void *priv, u32 spd)
 	regmap_update_bits(dwmac->regmap, reg, STID127_RETIME_SRC_MASK, val);
 }
 
-static void sti_dwmac_ctrl_init(struct sti_dwmac *dwmac)
+static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 {
+	struct sti_dwmac *dwmac = priv;
 	struct regmap *regmap = dwmac->regmap;
 	int iface = dwmac->interface;
 	struct device *dev = dwmac->dev;
@@ -247,28 +248,8 @@ static void sti_dwmac_ctrl_init(struct sti_dwmac *dwmac)
 
 	val = (iface == PHY_INTERFACE_MODE_REVMII) ? 0 : ENMII;
 	regmap_update_bits(regmap, reg, ENMII_MASK, val);
-}
-
-static int stix4xx_init(struct platform_device *pdev, void *priv)
-{
-	struct sti_dwmac *dwmac = priv;
-	u32 spd = dwmac->speed;
-
-	sti_dwmac_ctrl_init(dwmac);
 
-	stih4xx_fix_retime_src(priv, spd);
-
-	return 0;
-}
-
-static int stid127_init(struct platform_device *pdev, void *priv)
-{
-	struct sti_dwmac *dwmac = priv;
-	u32 spd = dwmac->speed;
-
-	sti_dwmac_ctrl_init(dwmac);
-
-	stid127_fix_retime_src(priv, spd);
+	dwmac->fix_retime_src(priv, dwmac->speed);
 
 	return 0;
 }
@@ -372,12 +353,14 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 		return ret;
 	}
 
+	dwmac->fix_retime_src = data->fix_retime_src;
+
 	plat_dat->bsp_priv = dwmac;
-	plat_dat->init = data->init;
+	plat_dat->init = sti_dwmac_init;
 	plat_dat->exit = sti_dwmac_exit;
-	plat_dat->fix_mac_speed = data->fix_mac_speed;
+	plat_dat->fix_mac_speed = data->fix_retime_src;
 
-	ret = plat_dat->init(pdev, plat_dat->bsp_priv);
+	ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
 	if (ret)
 		return ret;
 
@@ -385,13 +368,11 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 }
 
 static const struct sti_dwmac_of_data stih4xx_dwmac_data = {
-	.fix_mac_speed = stih4xx_fix_retime_src,
-	.init = stix4xx_init,
+	.fix_retime_src = stih4xx_fix_retime_src,
 };
 
 static const struct sti_dwmac_of_data stid127_dwmac_data = {
-	.fix_mac_speed = stid127_fix_retime_src,
-	.init = stid127_init,
+	.fix_retime_src = stid127_fix_retime_src,
 };
 
 static const struct of_device_id sti_dwmac_match[] = {
-- 
1.8.0
