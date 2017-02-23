From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/7] net: stmmac: dwc-qos: Split out ->probe() and ->remove()
Date: Thu, 23 Feb 2017 18:24:37 +0100
Message-ID: <20170223172438.14770-7-thierry.reding@gmail.com>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170223172438.14770-1-thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

Split out the binding specific parts of ->probe() and ->remove() to
enable the driver to support variants of the binding. This is useful in
order to keep backwards-compatibility while making it easy for a sub-
driver to deal only with the updated bindings rather than having to add
compatibility quirks all over the place.

Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
---
 .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 114 ++++++++++++++++-----
 1 file changed, 88 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
index 1a3fa3d9f855..5071d3c15adc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
@@ -18,6 +18,7 @@
 #include <linux/io.h>
 #include <linux/ioport.h>
 #include <linux/module.h>
+#include <linux/of_device.h>
 #include <linux/of_net.h>
 #include <linux/mfd/syscon.h>
 #include <linux/platform_device.h>
@@ -106,13 +107,70 @@ static int dwc_eth_dwmac_config_dt(struct platform_device *pdev,
 	return 0;
 }
 
+static void *dwc_qos_probe(struct platform_device *pdev,
+			   struct plat_stmmacenet_data *plat_dat,
+			   struct stmmac_resources *stmmac_res)
+{
+	int err;
+
+	plat_dat->stmmac_clk = devm_clk_get(&pdev->dev, "apb_pclk");
+	if (IS_ERR(plat_dat->stmmac_clk)) {
+		dev_err(&pdev->dev, "apb_pclk clock not found.\n");
+		return ERR_CAST(plat_dat->stmmac_clk);
+	}
+
+	clk_prepare_enable(plat_dat->stmmac_clk);
+
+	plat_dat->pclk = devm_clk_get(&pdev->dev, "phy_ref_clk");
+	if (IS_ERR(plat_dat->pclk)) {
+		dev_err(&pdev->dev, "phy_ref_clk clock not found.\n");
+		err = PTR_ERR(plat_dat->pclk);
+		goto disable;
+	}
+
+	clk_prepare_enable(plat_dat->pclk);
+
+	return NULL;
+
+disable:
+	clk_disable_unprepare(plat_dat->stmmac_clk);
+	return ERR_PTR(err);
+}
+
+static int dwc_qos_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+
+	clk_disable_unprepare(priv->plat->pclk);
+	clk_disable_unprepare(priv->plat->stmmac_clk);
+
+	return 0;
+}
+
+struct dwc_eth_dwmac_data {
+	void *(*probe)(struct platform_device *pdev,
+		       struct plat_stmmacenet_data *data,
+		       struct stmmac_resources *res);
+	int (*remove)(struct platform_device *pdev);
+};
+
+static const struct dwc_eth_dwmac_data dwc_qos_data = {
+	.probe = dwc_qos_probe,
+	.remove = dwc_qos_remove,
+};
+
 static int dwc_eth_dwmac_probe(struct platform_device *pdev)
 {
+	const struct dwc_eth_dwmac_data *data;
 	struct plat_stmmacenet_data *plat_dat;
 	struct stmmac_resources stmmac_res;
 	struct resource *res;
+	void *priv;
 	int ret;
 
+	data = of_device_get_match_data(&pdev->dev);
+
 	memset(&stmmac_res, 0, sizeof(struct stmmac_resources));
 
 	/**
@@ -138,39 +196,26 @@ static int dwc_eth_dwmac_probe(struct platform_device *pdev)
 	if (IS_ERR(plat_dat))
 		return PTR_ERR(plat_dat);
 
-	plat_dat->stmmac_clk = devm_clk_get(&pdev->dev, "apb_pclk");
-	if (IS_ERR(plat_dat->stmmac_clk)) {
-		dev_err(&pdev->dev, "apb_pclk clock not found.\n");
-		ret = PTR_ERR(plat_dat->stmmac_clk);
-		plat_dat->stmmac_clk = NULL;
-		goto err_remove_config_dt;
-	}
-	clk_prepare_enable(plat_dat->stmmac_clk);
-
-	plat_dat->pclk = devm_clk_get(&pdev->dev, "phy_ref_clk");
-	if (IS_ERR(plat_dat->pclk)) {
-		dev_err(&pdev->dev, "phy_ref_clk clock not found.\n");
-		ret = PTR_ERR(plat_dat->pclk);
-		plat_dat->pclk = NULL;
-		goto err_out_clk_dis_phy;
+	priv = data->probe(pdev, plat_dat, &stmmac_res);
+	if (IS_ERR(priv)) {
+		ret = PTR_ERR(priv);
+		dev_err(&pdev->dev, "failed to probe subdriver: %d\n", ret);
+		goto remove_config;
 	}
-	clk_prepare_enable(plat_dat->pclk);
 
 	ret = dwc_eth_dwmac_config_dt(pdev, plat_dat);
 	if (ret)
-		goto err_out_clk_dis_aper;
+		goto remove;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
-		goto err_out_clk_dis_aper;
+		goto remove;
 
-	return 0;
+	return ret;
 
-err_out_clk_dis_aper:
-	clk_disable_unprepare(plat_dat->pclk);
-err_out_clk_dis_phy:
-	clk_disable_unprepare(plat_dat->stmmac_clk);
-err_remove_config_dt:
+remove:
+	data->remove(pdev);
+remove_config:
 	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
@@ -178,11 +223,28 @@ static int dwc_eth_dwmac_probe(struct platform_device *pdev)
 
 static int dwc_eth_dwmac_remove(struct platform_device *pdev)
 {
-	return stmmac_pltfr_remove(pdev);
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	const struct dwc_eth_dwmac_data *data;
+	int err;
+
+	data = of_device_get_match_data(&pdev->dev);
+
+	err = stmmac_dvr_remove(&pdev->dev);
+	if (err < 0)
+		dev_err(&pdev->dev, "failed to remove platform: %d\n", err);
+
+	err = data->remove(pdev);
+	if (err < 0)
+		dev_err(&pdev->dev, "failed to remove subdriver: %d\n", err);
+
+	stmmac_remove_config_dt(pdev, priv->plat);
+
+	return err;
 }
 
 static const struct of_device_id dwc_eth_dwmac_match[] = {
-	{ .compatible = "snps,dwc-qos-ethernet-4.10", },
+	{ .compatible = "snps,dwc-qos-ethernet-4.10", .data = &dwc_qos_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, dwc_eth_dwmac_match);
-- 
2.11.1
