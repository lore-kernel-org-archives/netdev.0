From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 14/17] stmmac: dwmac-rk: use rk_gmac_ops as of match data
Date: Wed, 29 Jul 2015 00:09:01 +0200
Message-ID: <1438121344-5304-15-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	linux-rockchip@lists.infradead.org
To: peppe.cavallaro@st.com, heiko@sntech.de, roger.chen@rock-chips.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:35394 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbbG1WJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:36 -0400
Received: by lahh5 with SMTP id h5so77071949lah.2
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:35 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the setup glue callback and use rk_gmac_ops as OF match
data so it can used directly when calling rk_gmac_setup.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 27 ++++----------------------
 1 file changed, 4 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 5d8042ea8370..11baa4b19779 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -529,16 +529,6 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 	return bsp_priv;
 }
 
-static void *rk3288_gmac_setup(struct platform_device *pdev)
-{
-	return rk_gmac_setup(pdev, &rk3288_ops);
-}
-
-static void *rk3368_gmac_setup(struct platform_device *pdev)
-{
-	return rk_gmac_setup(pdev, &rk3368_ops);
-}
-
 static int rk_gmac_init(struct platform_device *pdev, void *priv)
 {
 	struct rk_priv_data *bsp_priv = priv;
@@ -580,7 +570,7 @@ static int rk_gmac_probe(struct platform_device *pdev)
 {
 	struct plat_stmmacenet_data *plat_dat;
 	struct stmmac_resources stmmac_res;
-	const struct stmmac_of_data *data;
+	const struct rk_gmac_ops *data;
 	int ret;
 
 	data = of_device_get_match_data(&pdev->dev);
@@ -598,12 +588,11 @@ static int rk_gmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	plat_dat->has_gmac = true;
-	plat_dat->setup = data->setup;
 	plat_dat->init = rk_gmac_init;
 	plat_dat->exit = rk_gmac_exit;
 	plat_dat->fix_mac_speed = rk_fix_speed;
 
-	plat_dat->bsp_priv = plat_dat->setup(pdev);
+	plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
 	if (IS_ERR(plat_dat->bsp_priv))
 		return PTR_ERR(plat_dat->bsp_priv);
 
@@ -614,17 +603,9 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
-static const struct stmmac_of_data rk3288_gmac_data = {
-	.setup = rk3288_gmac_setup,
-};
-
-static const struct stmmac_of_data rk3368_gmac_data = {
-	.setup = rk3368_gmac_setup,
-};
-
 static const struct of_device_id rk_gmac_dwmac_match[] = {
-	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
-	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_gmac_data},
+	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_ops },
+	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_ops },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
-- 
1.8.0
