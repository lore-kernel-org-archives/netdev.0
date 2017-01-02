From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 2/3] net: stmmac: dwmac-oxnas: fix fixed-link-phydev leaks
Date: Mon,  2 Jan 2017 12:56:03 +0100
Message-ID: <20170102115604.32482-3-johan@kernel.org>
References: <20170102115604.32482-1-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        netdev@vger.kernel.org, linux-oxnas@lists.tuxfamily.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170102115604.32482-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to deregister and free any fixed-link phy registered during
probe on probe errors and on driver unbind by calling the new glue
helper function.

For driver unbind, use the generic stmmac-platform remove implementation
and add an exit callback to disable the clock.

Fixes: 5ed7414062e7 ("net: stmmac: Add OXNAS Glue Driver")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c | 41 ++++++++++++++---------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
index fcc237e0aae1..3efd110613df 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
@@ -105,6 +105,13 @@ static int oxnas_dwmac_init(struct oxnas_dwmac *dwmac)
 	return 0;
 }
 
+static void oxnas_dwmac_exit(struct platform_device *pdev, void *priv)
+{
+	struct oxnas_dwmac *dwmac = priv;
+
+	clk_disable_unprepare(dwmac->clk);
+}
+
 static int oxnas_dwmac_probe(struct platform_device *pdev)
 {
 	struct plat_stmmacenet_data *plat_dat;
@@ -121,40 +128,44 @@ static int oxnas_dwmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return -ENOMEM;
+	if (!dwmac) {
+		ret = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	dwmac->dev = &pdev->dev;
 	plat_dat->bsp_priv = dwmac;
+	plat_dat->exit = oxnas_dwmac_exit;
 
 	dwmac->regmap = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
 							"oxsemi,sys-ctrl");
 	if (IS_ERR(dwmac->regmap)) {
 		dev_err(&pdev->dev, "failed to have sysctrl regmap\n");
-		return PTR_ERR(dwmac->regmap);
+		ret = PTR_ERR(dwmac->regmap);
+		goto err_remove_config_dt;
 	}
 
 	dwmac->clk = devm_clk_get(&pdev->dev, "gmac");
-	if (IS_ERR(dwmac->clk))
-		return PTR_ERR(dwmac->clk);
+	if (IS_ERR(dwmac->clk)) {
+		ret = PTR_ERR(dwmac->clk);
+		goto err_remove_config_dt;
+	}
 
 	ret = oxnas_dwmac_init(dwmac);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
-		clk_disable_unprepare(dwmac->clk);
+		goto err_dwmac_exit;
 
-	return ret;
-}
 
-static int oxnas_dwmac_remove(struct platform_device *pdev)
-{
-	struct oxnas_dwmac *dwmac = get_stmmac_bsp_priv(&pdev->dev);
-	int ret = stmmac_dvr_remove(&pdev->dev);
+	return 0;
 
-	clk_disable_unprepare(dwmac->clk);
+err_dwmac_exit:
+	oxnas_dwmac_exit(pdev, plat_dat->bsp_priv);
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
@@ -197,7 +208,7 @@ MODULE_DEVICE_TABLE(of, oxnas_dwmac_match);
 
 static struct platform_driver oxnas_dwmac_driver = {
 	.probe  = oxnas_dwmac_probe,
-	.remove = oxnas_dwmac_remove,
+	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "oxnas-dwmac",
 		.pm		= &oxnas_dwmac_pm_ops,
-- 
2.10.2
