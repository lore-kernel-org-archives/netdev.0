From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 1/4] stmmac: dwmac-rk: turn resume/suspend into standard PM callbacks
Date: Sat,  5 Nov 2016 14:04:49 +0100
Message-ID: <20161105130452.24226-2-manabian@gmail.com>
References: <20161105130452.24226-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, heiko@sntech.de,
        linux-rockchip@lists.infradead.org, vpalatin@chromium.org,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35102 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754151AbcKENFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 09:05:14 -0400
Received: by mail-lf0-f68.google.com with SMTP id p100so6148220lfg.2
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2016 06:05:13 -0700 (PDT)
In-Reply-To: <20161105130452.24226-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use standard PM resume/suspend callbacks instead of the hooks in
stmmac_platform. This gives the driver more control and flexibility
when implementing PM functionality. The hooks in stmmac_platform
also doesn't buy us anything extra.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 59 ++++++++++++++------------
 1 file changed, 32 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 3740a44..d91acd5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -915,30 +915,6 @@ static void rk_gmac_exit(struct platform_device *pdev, void *priv)
 	rk_gmac_powerdown(bsp_priv);
 }
 
-static void rk_gmac_suspend(struct platform_device *pdev, void *priv)
-{
-	struct rk_priv_data *bsp_priv = priv;
-
-	/* Keep the PHY up if we use Wake-on-Lan. */
-	if (device_may_wakeup(&pdev->dev))
-		return;
-
-	rk_gmac_powerdown(bsp_priv);
-	bsp_priv->suspended = true;
-}
-
-static void rk_gmac_resume(struct platform_device *pdev, void *priv)
-{
-	struct rk_priv_data *bsp_priv = priv;
-
-	/* The PHY was up for Wake-on-Lan. */
-	if (!bsp_priv->suspended)
-		return;
-
-	rk_gmac_powerup(bsp_priv);
-	bsp_priv->suspended = false;
-}
-
 static void rk_fix_speed(void *priv, unsigned int speed)
 {
 	struct rk_priv_data *bsp_priv = priv;
@@ -977,8 +953,6 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	plat_dat->init = rk_gmac_init;
 	plat_dat->exit = rk_gmac_exit;
 	plat_dat->fix_mac_speed = rk_fix_speed;
-	plat_dat->suspend = rk_gmac_suspend;
-	plat_dat->resume = rk_gmac_resume;
 
 	plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
 	if (IS_ERR(plat_dat->bsp_priv))
@@ -991,6 +965,37 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int rk_gmac_suspend(struct device *dev)
+{
+	struct rk_priv_data *bsp_priv = get_stmmac_bsp_priv(dev);
+	int ret = stmmac_suspend(dev);
+
+	/* Keep the PHY up if we use Wake-on-Lan. */
+	if (!device_may_wakeup(dev)) {
+		rk_gmac_powerdown(bsp_priv);
+		bsp_priv->suspended = true;
+	}
+
+	return ret;
+}
+
+static int rk_gmac_resume(struct device *dev)
+{
+	struct rk_priv_data *bsp_priv = get_stmmac_bsp_priv(dev);
+
+	/* The PHY was up for Wake-on-Lan. */
+	if (bsp_priv->suspended) {
+		rk_gmac_powerup(bsp_priv);
+		bsp_priv->suspended = false;
+	}
+
+	return stmmac_resume(dev);
+}
+#endif /* CONFIG_PM_SLEEP */
+
+static SIMPLE_DEV_PM_OPS(rk_gmac_pm_ops, rk_gmac_suspend, rk_gmac_resume);
+
 static const struct of_device_id rk_gmac_dwmac_match[] = {
 	{ .compatible = "rockchip,rk3228-gmac", .data = &rk3228_ops },
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_ops },
@@ -1006,7 +1011,7 @@ static struct platform_driver rk_gmac_dwmac_driver = {
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "rk_gmac-dwmac",
-		.pm		= &stmmac_pltfr_pm_ops,
+		.pm		= &rk_gmac_pm_ops,
 		.of_match_table = rk_gmac_dwmac_match,
 	},
 };
-- 
2.10.2
