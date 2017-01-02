From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 3/3] net: stmmac: dwmac-oxnas: use generic pm implementation
Date: Mon,  2 Jan 2017 12:56:04 +0100
Message-ID: <20170102115604.32482-4-johan@kernel.org>
References: <20170102115604.32482-1-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        netdev@vger.kernel.org, linux-oxnas@lists.tuxfamily.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35527 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755538AbdABL4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 06:56:33 -0500
In-Reply-To: <20170102115604.32482-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have an exit callback in place, add init as well and get rid
of the custom PM callbacks in favour of the generic ones.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c | 38 +++--------------------
 1 file changed, 5 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
index 3efd110613df..3dc7d279f805 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
@@ -60,8 +60,9 @@ struct oxnas_dwmac {
 	struct regmap	*regmap;
 };
 
-static int oxnas_dwmac_init(struct oxnas_dwmac *dwmac)
+static int oxnas_dwmac_init(struct platform_device *pdev, void *priv)
 {
+	struct oxnas_dwmac *dwmac = priv;
 	unsigned int value;
 	int ret;
 
@@ -135,6 +136,7 @@ static int oxnas_dwmac_probe(struct platform_device *pdev)
 
 	dwmac->dev = &pdev->dev;
 	plat_dat->bsp_priv = dwmac;
+	plat_dat->init = oxnas_dwmac_init;
 	plat_dat->exit = oxnas_dwmac_exit;
 
 	dwmac->regmap = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
@@ -151,7 +153,7 @@ static int oxnas_dwmac_probe(struct platform_device *pdev)
 		goto err_remove_config_dt;
 	}
 
-	ret = oxnas_dwmac_init(dwmac);
+	ret = oxnas_dwmac_init(pdev, plat_dat->bsp_priv);
 	if (ret)
 		goto err_remove_config_dt;
 
@@ -170,36 +172,6 @@ static int oxnas_dwmac_probe(struct platform_device *pdev)
 	return ret;
 }
 
-#ifdef CONFIG_PM_SLEEP
-static int oxnas_dwmac_suspend(struct device *dev)
-{
-	struct oxnas_dwmac *dwmac = get_stmmac_bsp_priv(dev);
-	int ret;
-
-	ret = stmmac_suspend(dev);
-	clk_disable_unprepare(dwmac->clk);
-
-	return ret;
-}
-
-static int oxnas_dwmac_resume(struct device *dev)
-{
-	struct oxnas_dwmac *dwmac = get_stmmac_bsp_priv(dev);
-	int ret;
-
-	ret = oxnas_dwmac_init(dwmac);
-	if (ret)
-		return ret;
-
-	ret = stmmac_resume(dev);
-
-	return ret;
-}
-#endif /* CONFIG_PM_SLEEP */
-
-static SIMPLE_DEV_PM_OPS(oxnas_dwmac_pm_ops,
-	oxnas_dwmac_suspend, oxnas_dwmac_resume);
-
 static const struct of_device_id oxnas_dwmac_match[] = {
 	{ .compatible = "oxsemi,ox820-dwmac" },
 	{ }
@@ -211,7 +183,7 @@ static struct platform_driver oxnas_dwmac_driver = {
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "oxnas-dwmac",
-		.pm		= &oxnas_dwmac_pm_ops,
+		.pm		= &stmmac_pltfr_pm_ops,
 		.of_match_table = oxnas_dwmac_match,
 	},
 };
-- 
2.10.2
