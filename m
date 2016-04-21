From: Marek Vasut <marex@denx.de>
Subject: [RFC][PATCH] net: stmmac: Call custom init from stmmac_dvr_probe
Date: Thu, 21 Apr 2016 14:12:28 +0200
Message-ID: <1461240748-5464-1-git-send-email-marex@denx.de>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
	Marek Vasut <marex@denx.de>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:57850 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbcDUMNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 08:13:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each and every driver which implements custom plat_data->init function
calls it exactly before stmmac_dvr_probe(). Trim down the code duplication
by calling the plat_data->init function from stmmac_dvr_probe() instead.

The stmmac_dvr_probe() does not have access to struct platform_device ,
since not all callers register the driver as a platform device. Analyzing
the ->init and ->exit functions, the platform_device is only used on in
one instance, on loongson, and only to access private data. Thus, replace
the platform device with net_device in both .init and .exit first and fix
up the code slightly to deal with this change.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Chen-Yu Tsai <wens@csie.org>
Cc: Matthew Gerlach <mgerlach@opensource.altera.com>
Cc: Dinh Nguyen <dinguyen@opensource.altera.com>
Cc: David S. Miller <davem@davemloft.net>
---
 arch/blackfin/mach-bf609/boards/ezkit.c               |  2 +-
 arch/mips/loongson32/common/platform.c                |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c   |  7 -------
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c        |  8 ++------
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c   | 15 +++------------
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c       |  8 ++------
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c     |  8 ++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 13 +++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  8 +++-----
 include/linux/stmmac.h                                |  5 +++--
 10 files changed, 32 insertions(+), 48 deletions(-)

diff --git a/arch/blackfin/mach-bf609/boards/ezkit.c b/arch/blackfin/mach-bf609/boards/ezkit.c
index aad5d74..3454fe2 100644
--- a/arch/blackfin/mach-bf609/boards/ezkit.c
+++ b/arch/blackfin/mach-bf609/boards/ezkit.c
@@ -122,7 +122,7 @@ static struct stmmac_dma_cfg eth_dma_cfg = {
 	.pbl	= 2,
 };
 
-int stmmac_ptp_clk_init(struct platform_device *pdev, void *priv)
+int stmmac_ptp_clk_init(struct net_device *ndev, void *priv)
 {
 	bfin_write32(PADS0_EMAC_PTP_CLKSEL, 0);
 	return 0;
diff --git a/arch/mips/loongson32/common/platform.c b/arch/mips/loongson32/common/platform.c
index f2c714d..e746df7 100644
--- a/arch/mips/loongson32/common/platform.c
+++ b/arch/mips/loongson32/common/platform.c
@@ -125,14 +125,14 @@ static struct stmmac_dma_cfg ls1x_eth_dma_cfg = {
 	.pbl		= 1,
 };
 
-int ls1x_eth_mux_init(struct platform_device *pdev, void *priv)
+int ls1x_eth_mux_init(struct net_device *ndev, void *priv)
 {
-	struct plat_stmmacenet_data *plat_dat = NULL;
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	struct plat_stmmacenet_data *plat_dat = priv->plat;
 	u32 val;
 
 	val = __raw_readl(LS1X_MUX_CTRL1);
 
-	plat_dat = dev_get_platdata(&pdev->dev);
 	if (plat_dat->bus_id) {
 		__raw_writel(__raw_readl(LS1X_MUX_CTRL0) | GMAC1_USE_UART1 |
 			     GMAC1_USE_UART0, LS1X_MUX_CTRL0);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
index b1e5f24..3107a71 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -46,13 +46,6 @@ static int dwmac_generic_probe(struct platform_device *pdev)
 		plat_dat->unicast_filter_entries = 1;
 	}
 
-	/* Custom initialisation (if needed) */
-	if (plat_dat->init) {
-		ret = plat_dat->init(pdev, plat_dat->bsp_priv);
-		if (ret)
-			return ret;
-	}
-
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 0cd3ecf..3b5a59d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -529,7 +529,7 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 	return bsp_priv;
 }
 
-static int rk_gmac_init(struct platform_device *pdev, void *priv)
+static int rk_gmac_init(struct net_device *ndev, void *priv)
 {
 	struct rk_priv_data *bsp_priv = priv;
 	int ret;
@@ -545,7 +545,7 @@ static int rk_gmac_init(struct platform_device *pdev, void *priv)
 	return 0;
 }
 
-static void rk_gmac_exit(struct platform_device *pdev, void *priv)
+static void rk_gmac_exit(struct net_device *ndev, void *priv)
 {
 	struct rk_priv_data *gmac = priv;
 
@@ -596,10 +596,6 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	if (IS_ERR(plat_dat->bsp_priv))
 		return PTR_ERR(plat_dat->bsp_priv);
 
-	ret = rk_gmac_init(pdev, plat_dat->bsp_priv);
-	if (ret)
-		return ret;
-
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 784eb53..97f5615 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -184,17 +184,12 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	return 0;
 }
 
-static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
+static int socfpga_dwmac_init(struct net_device *ndev, void *priv)
 {
 	struct socfpga_dwmac *dwmac = priv;
-	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct stmmac_priv *stpriv = NULL;
+	struct stmmac_priv *stpriv = netdev_priv(ndev);
 	int ret = 0;
 
-	if (!ndev)
-		return -EINVAL;
-
-	stpriv = netdev_priv(ndev);
 	if (!stpriv)
 		return -EINVAL;
 
@@ -264,11 +259,7 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	plat_dat->init = socfpga_dwmac_init;
 	plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
 
-	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
-	if (!ret)
-		ret = socfpga_dwmac_init(pdev, dwmac);
-
-	return ret;
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
 static const struct of_device_id socfpga_dwmac_match[] = {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 58c05ac..049d1dc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -228,7 +228,7 @@ static void stid127_fix_retime_src(void *priv, u32 spd)
 	regmap_update_bits(dwmac->regmap, reg, STID127_RETIME_SRC_MASK, val);
 }
 
-static int sti_dwmac_init(struct platform_device *pdev, void *priv)
+static int sti_dwmac_init(struct net_device *ndev, void *priv)
 {
 	struct sti_dwmac *dwmac = priv;
 	struct regmap *regmap = dwmac->regmap;
@@ -254,7 +254,7 @@ static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 	return 0;
 }
 
-static void sti_dwmac_exit(struct platform_device *pdev, void *priv)
+static void sti_dwmac_exit(struct net_device *ndev, void *priv)
 {
 	struct sti_dwmac *dwmac = priv;
 
@@ -361,10 +361,6 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	plat_dat->exit = sti_dwmac_exit;
 	plat_dat->fix_mac_speed = data->fix_retime_src;
 
-	ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
-	if (ret)
-		return ret;
-
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
index adff463..5a21574 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
@@ -36,7 +36,7 @@ struct sunxi_priv_data {
 #define SUN7I_GMAC_GMII_RGMII_RATE	125000000
 #define SUN7I_GMAC_MII_RATE		25000000
 
-static int sun7i_gmac_init(struct platform_device *pdev, void *priv)
+static int sun7i_gmac_init(struct net_device *ndev, void *priv)
 {
 	struct sunxi_priv_data *gmac = priv;
 	int ret;
@@ -65,7 +65,7 @@ static int sun7i_gmac_init(struct platform_device *pdev, void *priv)
 	return 0;
 }
 
-static void sun7i_gmac_exit(struct platform_device *pdev, void *priv)
+static void sun7i_gmac_exit(struct net_device *ndev, void *priv)
 {
 	struct sunxi_priv_data *gmac = priv;
 
@@ -149,10 +149,6 @@ static int sun7i_gmac_probe(struct platform_device *pdev)
 	plat_dat->exit = sun7i_gmac_exit;
 	plat_dat->fix_mac_speed = sun7i_fix_speed;
 
-	ret = sun7i_gmac_init(pdev, plat_dat->bsp_priv);
-	if (ret)
-		return ret;
-
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 	if (ret)
 		sun7i_gmac_exit(pdev, plat_dat->bsp_priv);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b87edb7..a62cbe31 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3260,6 +3260,13 @@ int stmmac_dvr_probe(struct device *device,
 	if (priv->stmmac_rst)
 		reset_control_deassert(priv->stmmac_rst);
 
+	/* Custom initialisation (if needed) */
+	if (plat_dat->init) {
+		ret = plat_dat->init(ndev, plat_dat->bsp_priv);
+		if (ret)
+			return ret;
+	}
+
 	/* Init MAC and get the capabilities */
 	ret = stmmac_hw_init(priv);
 	if (ret)
@@ -3357,6 +3364,7 @@ EXPORT_SYMBOL_GPL(stmmac_dvr_probe);
 int stmmac_dvr_remove(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
+	struct plat_stmmacenet_data *plat_dat = priv->plat;
 
 	pr_info("%s:\n\tremoving driver", __func__);
 
@@ -3366,6 +3374,11 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	stmmac_set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
+
+	/* Custom de-initialisation (if needed) */
+	if (plat_dat->exit)
+		plat_dat->exit(ndev, plat_dat->bsp_priv);
+
 	if (priv->stmmac_rst)
 		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->pclk);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index effaa4f..7473433 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -389,7 +389,7 @@ int stmmac_pltfr_remove(struct platform_device *pdev)
 	int ret = stmmac_dvr_remove(ndev);
 
 	if (priv->plat->exit)
-		priv->plat->exit(pdev, priv->plat->bsp_priv);
+		priv->plat->exit(ndev, priv->plat->bsp_priv);
 
 	return ret;
 }
@@ -408,11 +408,10 @@ static int stmmac_pltfr_suspend(struct device *dev)
 	int ret;
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	struct platform_device *pdev = to_platform_device(dev);
 
 	ret = stmmac_suspend(ndev);
 	if (priv->plat->exit)
-		priv->plat->exit(pdev, priv->plat->bsp_priv);
+		priv->plat->exit(ndev, priv->plat->bsp_priv);
 
 	return ret;
 }
@@ -428,10 +427,9 @@ static int stmmac_pltfr_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	struct platform_device *pdev = to_platform_device(dev);
 
 	if (priv->plat->init)
-		priv->plat->init(pdev, priv->plat->bsp_priv);
+		priv->plat->init(ndev, priv->plat->bsp_priv);
 
 	return stmmac_resume(ndev);
 }
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index ffdaca9..ddd4342 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -27,6 +27,7 @@
 #define __STMMAC_PLATFORM_DATA
 
 #include <linux/platform_device.h>
+#include <linux/netdevice.h>
 
 #define STMMAC_RX_COE_NONE	0
 #define STMMAC_RX_COE_TYPE1	1
@@ -133,8 +134,8 @@ struct plat_stmmacenet_data {
 	int rx_fifo_size;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
-	int (*init)(struct platform_device *pdev, void *priv);
-	void (*exit)(struct platform_device *pdev, void *priv);
+	int (*init)(struct net_device *ndev, void *priv);
+	void (*exit)(struct net_device *ndev, void *priv);
 	void *bsp_priv;
 	struct stmmac_axi *axi;
 	int has_gmac4;
-- 
2.7.0
