From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 7/7] net: ethernet: stmmac: fix of-node and fixed-link-phydev leaks
Date: Wed, 30 Nov 2016 15:29:55 +0100
Message-ID: <1480516195-27696-8-git-send-email-johan@kernel.org>
References: <1480516195-27696-1-git-send-email-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480516195-27696-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to deregister and free any fixed-link phy registered during
probe on probe errors and on driver unbind by adding a new glue helper
function.

Drop the of-node reference taken in the same path also on late probe
errors (and not just on driver unbind) by moving the put from
stmmac_dvr_remove() to the new helper.

Fixes: 277323814e49 ("stmmac: add fixed-link device-tree support")
Fixes: 4613b279bee7 ("ethernet: stmicro: stmmac: add missing of_node_put
after calling of_parse_phandle")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 .../net/ethernet/stmicro/stmmac/dwmac-generic.c    |  5 +++-
 .../net/ethernet/stmicro/stmmac/dwmac-ipq806x.c    | 25 +++++++++++++----
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 17 ++++++++++--
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 23 ++++++++++++----
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 21 +++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 10 +++++--
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 12 +++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 12 +++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 19 +++++++++----
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 26 +++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 32 ++++++++++++++++++++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  2 ++
 13 files changed, 156 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
index 05e46a82cdb1..e6e6c2fcc4b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -50,7 +50,7 @@ static int dwmac_generic_probe(struct platform_device *pdev)
 	if (plat_dat->init) {
 		ret = plat_dat->init(pdev, plat_dat->bsp_priv);
 		if (ret)
-			return ret;
+			goto err_remove_config_dt;
 	}
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
@@ -62,6 +62,9 @@ static int dwmac_generic_probe(struct platform_device *pdev)
 err_exit:
 	if (plat_dat->exit)
 		plat_dat->exit(pdev, plat_dat->bsp_priv);
+err_remove_config_dt:
+	if (pdev->dev.of_node)
+		stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
index 36d3355f2fb0..866444b6c82f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
@@ -271,15 +271,17 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	gmac = devm_kzalloc(dev, sizeof(*gmac), GFP_KERNEL);
-	if (!gmac)
-		return -ENOMEM;
+	if (!gmac) {
+		err = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	gmac->pdev = pdev;
 
 	err = ipq806x_gmac_of_parse(gmac);
 	if (err) {
 		dev_err(dev, "device tree parsing error\n");
-		return err;
+		goto err_remove_config_dt;
 	}
 
 	regmap_write(gmac->qsgmii_csr, QSGMII_PCS_CAL_LCKDT_CTL,
@@ -300,7 +302,8 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 	default:
 		dev_err(&pdev->dev, "Unsupported PHY mode: \"%s\"\n",
 			phy_modes(gmac->phy_mode));
-		return -EINVAL;
+		err = -EINVAL;
+		goto err_remove_config_dt;
 	}
 	regmap_write(gmac->nss_common, NSS_COMMON_GMAC_CTL(gmac->id), val);
 
@@ -319,7 +322,8 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 	default:
 		dev_err(&pdev->dev, "Unsupported PHY mode: \"%s\"\n",
 			phy_modes(gmac->phy_mode));
-		return -EINVAL;
+		err = -EINVAL;
+		goto err_remove_config_dt;
 	}
 	regmap_write(gmac->nss_common, NSS_COMMON_CLK_SRC_CTRL, val);
 
@@ -346,7 +350,16 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 	plat_dat->bsp_priv = gmac;
 	plat_dat->fix_mac_speed = ipq806x_gmac_fix_mac_speed;
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	err = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (err)
+		goto err_remove_config_dt;
+
+	return 0;
+
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
+
+	return err;
 }
 
 static const struct of_device_id ipq806x_gmac_dwmac_match[] = {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
index 78e9d1861896..3d3f43d91b98 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
@@ -46,7 +46,8 @@ static int lpc18xx_dwmac_probe(struct platform_device *pdev)
 	reg = syscon_regmap_lookup_by_compatible("nxp,lpc1850-creg");
 	if (IS_ERR(reg)) {
 		dev_err(&pdev->dev, "syscon lookup failed\n");
-		return PTR_ERR(reg);
+		ret = PTR_ERR(reg);
+		goto err_remove_config_dt;
 	}
 
 	if (plat_dat->interface == PHY_INTERFACE_MODE_MII) {
@@ -55,13 +56,23 @@ static int lpc18xx_dwmac_probe(struct platform_device *pdev)
 		ethmode = LPC18XX_CREG_CREG6_ETHMODE_RMII;
 	} else {
 		dev_err(&pdev->dev, "Only MII and RMII mode supported\n");
-		return -EINVAL;
+		ret = -EINVAL;
+		goto err_remove_config_dt;
 	}
 
 	regmap_update_bits(reg, LPC18XX_CREG_CREG6,
 			   LPC18XX_CREG_CREG6_ETHMODE_MASK, ethmode);
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		goto err_remove_config_dt;
+
+	return 0;
+
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
+
+	return ret;
 }
 
 static const struct of_device_id lpc18xx_dwmac_match[] = {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
index 309d99536a2c..7fdd1760a74c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
@@ -64,18 +64,31 @@ static int meson6_dwmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return -ENOMEM;
+	if (!dwmac) {
+		ret = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	dwmac->reg = devm_ioremap_resource(&pdev->dev, res);
-	if (IS_ERR(dwmac->reg))
-		return PTR_ERR(dwmac->reg);
+	if (IS_ERR(dwmac->reg)) {
+		ret = PTR_ERR(dwmac->reg);
+		goto err_remove_config_dt;
+	}
 
 	plat_dat->bsp_priv = dwmac;
 	plat_dat->fix_mac_speed = meson6_dwmac_fix_mac_speed;
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		goto err_remove_config_dt;
+
+	return 0;
+
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
+
+	return ret;
 }
 
 static const struct of_device_id meson6_dwmac_match[] = {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
index 45e7aaf0170d..ffaed1f35efe 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -264,28 +264,33 @@ static int meson8b_dwmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return -ENOMEM;
+	if (!dwmac) {
+		ret = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	dwmac->regs = devm_ioremap_resource(&pdev->dev, res);
-	if (IS_ERR(dwmac->regs))
-		return PTR_ERR(dwmac->regs);
+	if (IS_ERR(dwmac->regs)) {
+		ret = PTR_ERR(dwmac->regs);
+		goto err_remove_config_dt;
+	}
 
 	dwmac->pdev = pdev;
 	dwmac->phy_mode = of_get_phy_mode(pdev->dev.of_node);
 	if (dwmac->phy_mode < 0) {
 		dev_err(&pdev->dev, "missing phy-mode property\n");
-		return -EINVAL;
+		ret = -EINVAL;
+		goto err_remove_config_dt;
 	}
 
 	ret = meson8b_init_clk(dwmac);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	ret = meson8b_init_prg_eth(dwmac);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	plat_dat->bsp_priv = dwmac;
 
@@ -297,6 +302,8 @@ static int meson8b_dwmac_probe(struct platform_device *pdev)
 
 err_clk_disable:
 	clk_disable_unprepare(dwmac->m25_div_clk);
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index e7aabe56c15a..d80c88bd2bba 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -981,12 +981,14 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	plat_dat->resume = rk_gmac_resume;
 
 	plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
-	if (IS_ERR(plat_dat->bsp_priv))
-		return PTR_ERR(plat_dat->bsp_priv);
+	if (IS_ERR(plat_dat->bsp_priv)) {
+		ret = PTR_ERR(plat_dat->bsp_priv);
+		goto err_remove_config_dt;
+	}
 
 	ret = rk_gmac_init(pdev, plat_dat->bsp_priv);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
@@ -996,6 +998,8 @@ static int rk_gmac_probe(struct platform_device *pdev)
 
 err_gmac_exit:
 	rk_gmac_exit(pdev, plat_dat->bsp_priv);
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 47db157da3e8..0c420e97de1e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -316,13 +316,15 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return -ENOMEM;
+	if (!dwmac) {
+		ret = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	ret = socfpga_dwmac_parse_data(dwmac, dev);
 	if (ret) {
 		dev_err(dev, "Unable to parse OF data\n");
-		return ret;
+		goto err_remove_config_dt;
 	}
 
 	plat_dat->bsp_priv = dwmac;
@@ -330,7 +332,7 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	ndev = platform_get_drvdata(pdev);
 	stpriv = netdev_priv(ndev);
@@ -349,6 +351,8 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 
 err_dvr_remove:
 	stmmac_dvr_remove(&pdev->dev);
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index a1ce018bf844..060b98c37a85 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -345,13 +345,15 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return -ENOMEM;
+	if (!dwmac) {
+		ret = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	ret = sti_dwmac_parse_data(dwmac, pdev);
 	if (ret) {
 		dev_err(&pdev->dev, "Unable to parse OF data\n");
-		return ret;
+		goto err_remove_config_dt;
 	}
 
 	dwmac->fix_retime_src = data->fix_retime_src;
@@ -363,7 +365,7 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 
 	ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
@@ -373,6 +375,8 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 
 err_dwmac_exit:
 	sti_dwmac_exit(pdev, plat_dat->bsp_priv);
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
index e5a926b8bee7..61cb24810d10 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
@@ -107,24 +107,33 @@ static int stm32_dwmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
-	if (!dwmac)
-		return -ENOMEM;
+	if (!dwmac) {
+		ret = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	ret = stm32_dwmac_parse_data(dwmac, &pdev->dev);
 	if (ret) {
 		dev_err(&pdev->dev, "Unable to parse OF data\n");
-		return ret;
+		goto err_remove_config_dt;
 	}
 
 	plat_dat->bsp_priv = dwmac;
 
 	ret = stm32_dwmac_init(plat_dat);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
-		stm32_dwmac_clk_disable(dwmac);
+		goto err_clk_disable;
+
+	return 0;
+
+err_clk_disable:
+	stm32_dwmac_clk_disable(dwmac);
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
index adff46375a32..d07520fb969e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
@@ -120,22 +120,27 @@ static int sun7i_gmac_probe(struct platform_device *pdev)
 		return PTR_ERR(plat_dat);
 
 	gmac = devm_kzalloc(dev, sizeof(*gmac), GFP_KERNEL);
-	if (!gmac)
-		return -ENOMEM;
+	if (!gmac) {
+		ret = -ENOMEM;
+		goto err_remove_config_dt;
+	}
 
 	gmac->interface = of_get_phy_mode(dev->of_node);
 
 	gmac->tx_clk = devm_clk_get(dev, "allwinner_gmac_tx");
 	if (IS_ERR(gmac->tx_clk)) {
 		dev_err(dev, "could not get tx clock\n");
-		return PTR_ERR(gmac->tx_clk);
+		ret = PTR_ERR(gmac->tx_clk);
+		goto err_remove_config_dt;
 	}
 
 	/* Optional regulator for PHY */
 	gmac->regulator = devm_regulator_get_optional(dev, "phy");
 	if (IS_ERR(gmac->regulator)) {
-		if (PTR_ERR(gmac->regulator) == -EPROBE_DEFER)
-			return -EPROBE_DEFER;
+		if (PTR_ERR(gmac->regulator) == -EPROBE_DEFER) {
+			ret = -EPROBE_DEFER;
+			goto err_remove_config_dt;
+		}
 		dev_info(dev, "no regulator found\n");
 		gmac->regulator = NULL;
 	}
@@ -151,11 +156,18 @@ static int sun7i_gmac_probe(struct platform_device *pdev)
 
 	ret = sun7i_gmac_init(pdev, plat_dat->bsp_priv);
 	if (ret)
-		return ret;
+		goto err_remove_config_dt;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
-		sun7i_gmac_exit(pdev, plat_dat->bsp_priv);
+		goto err_gmac_exit;
+
+	return 0;
+
+err_gmac_exit:
+	sun7i_gmac_exit(pdev, plat_dat->bsp_priv);
+err_remove_config_dt:
+	stmmac_remove_config_dt(pdev, plat_dat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1f9ec02fa7f8..caf069a465f2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3416,7 +3416,6 @@ int stmmac_dvr_remove(struct device *dev)
 	stmmac_set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
-	of_node_put(priv->plat->phy_node);
 	if (priv->stmmac_rst)
 		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->pclk);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index bcbf123d5ba2..a840818bf4df 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -305,7 +305,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
 				       GFP_KERNEL);
 		if (!dma_cfg) {
-			of_node_put(plat->phy_node);
+			stmmac_remove_config_dt(pdev, plat);
 			return ERR_PTR(-ENOMEM);
 		}
 		plat->dma_cfg = dma_cfg;
@@ -328,14 +328,37 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 
 	return plat;
 }
+
+/**
+ * stmmac_remove_config_dt - undo the effects of stmmac_probe_config_dt()
+ * @pdev: platform_device structure
+ * @plat: driver data platform structure
+ *
+ * Release resources claimed by stmmac_probe_config_dt().
+ */
+void stmmac_remove_config_dt(struct platform_device *pdev,
+			     struct plat_stmmacenet_data *plat)
+{
+	struct device_node *np = pdev->dev.of_node;
+
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
+	of_node_put(plat->phy_node);
+}
 #else
 struct plat_stmmacenet_data *
 stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
 	return ERR_PTR(-ENOSYS);
 }
+
+void stmmac_remove_config_dt(struct platform_device *pdev,
+			     struct plat_stmmacenet_data *plat)
+{
+}
 #endif /* CONFIG_OF */
 EXPORT_SYMBOL_GPL(stmmac_probe_config_dt);
+EXPORT_SYMBOL_GPL(stmmac_remove_config_dt);
 
 int stmmac_get_platform_resources(struct platform_device *pdev,
 				  struct stmmac_resources *stmmac_res)
@@ -391,10 +414,13 @@ int stmmac_pltfr_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
+	struct plat_stmmacenet_data *plat = priv->plat;
 	int ret = stmmac_dvr_remove(&pdev->dev);
 
-	if (priv->plat->exit)
-		priv->plat->exit(pdev, priv->plat->bsp_priv);
+	if (plat->exit)
+		plat->exit(pdev, plat->bsp_priv);
+
+	stmmac_remove_config_dt(pdev, plat);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 64e147f53a9c..b72eb0de57b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -23,6 +23,8 @@
 
 struct plat_stmmacenet_data *
 stmmac_probe_config_dt(struct platform_device *pdev, const char **mac);
+void stmmac_remove_config_dt(struct platform_device *pdev,
+			     struct plat_stmmacenet_data *plat);
 
 int stmmac_get_platform_resources(struct platform_device *pdev,
 				  struct stmmac_resources *stmmac_res);
-- 
2.7.3
