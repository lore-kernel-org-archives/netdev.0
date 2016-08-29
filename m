From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH v6 1/3] net: ethernet: dwmac: add Ethernet glue logic for stm32 chip
Date: Mon, 29 Aug 2016 18:23:38 +0200
Message-ID: <1472487820-5132-2-git-send-email-alexandre.torgue@st.com>
References: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh@kernel.org>, <manabian@gmail.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:46518 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751190AbcH2QYW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:24:22 -0400
In-Reply-To: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre TORGUE <alexandre.torgue@gmail.com>

stm324xx family chips support Synopsys MAC 3.510 IP.
This patch adds settings for logical glue logic:
-clocks
-mode selection MII or RMII.

Reviewed-by: Joachim Eastwood <manabian@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Maxime Coquelin <maxime.coquelin@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 8f06a66..c732b8c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -104,6 +104,18 @@ config DWMAC_STI
 	  device driver. This driver is used on for the STi series
 	  SOCs GMAC ethernet controller.
 
+config DWMAC_STM32
+	tristate "STM32 DWMAC support"
+	default ARCH_STM32
+	depends on OF && HAS_IOMEM
+	select MFD_SYSCON
+	---help---
+	  Support for ethernet controller on STM32 SOCs.
+
+	  This selects STM32 SoC glue layer support for the stmmac
+	  device driver. This driver is used on for the STM32 series
+	  SOCs GMAC ethernet controller.
+
 config DWMAC_SUNXI
 	tristate "Allwinner GMAC support"
 	default ARCH_SUNXI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 44b630c..f0c9396 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -13,6 +13,7 @@ obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-altr-socfpga.o
 obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
+obj-$(CONFIG_DWMAC_STM32)	+= dwmac-stm32.o
 obj-$(CONFIG_DWMAC_SUNXI)	+= dwmac-sunxi.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
new file mode 100644
index 0000000..79d8b92
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
@@ -0,0 +1,193 @@
+/*
+ * dwmac-stm32.c - DWMAC Specific Glue layer for STM32 MCU
+ *
+ * Copyright (C) Alexandre Torgue 2015
+ * Author:  Alexandre Torgue <alexandre.torgue@gmail.com>
+ * License terms:  GNU General Public License (GPL), version 2
+ *
+ */
+
+#include <linux/clk.h>
+#include <linux/kernel.h>
+#include <linux/mfd/syscon.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/regmap.h>
+#include <linux/slab.h>
+#include <linux/stmmac.h>
+
+#include "stmmac_platform.h"
+
+#define MII_PHY_SEL_MASK	BIT(23)
+
+struct stm32_dwmac {
+	struct clk *clk_tx;
+	struct clk *clk_rx;
+	u32 mode_reg;		/* MAC glue-logic mode register */
+	struct regmap *regmap;
+	u32 speed;
+};
+
+static int stm32_dwmac_init(struct plat_stmmacenet_data *plat_dat)
+{
+	struct stm32_dwmac *dwmac = plat_dat->bsp_priv;
+	u32 reg = dwmac->mode_reg;
+	u32 val;
+	int ret;
+
+	val = (plat_dat->interface == PHY_INTERFACE_MODE_MII) ? 0 : 1;
+	ret = regmap_update_bits(dwmac->regmap, reg, MII_PHY_SEL_MASK, val);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(dwmac->clk_tx);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(dwmac->clk_rx);
+	if (ret)
+		clk_disable_unprepare(dwmac->clk_tx);
+
+	return ret;
+}
+
+static void stm32_dwmac_clk_disable(struct stm32_dwmac *dwmac)
+{
+	clk_disable_unprepare(dwmac->clk_tx);
+	clk_disable_unprepare(dwmac->clk_rx);
+}
+
+static int stm32_dwmac_parse_data(struct stm32_dwmac *dwmac,
+				  struct device *dev)
+{
+	struct device_node *np = dev->of_node;
+	int err;
+
+	/*  Get TX/RX clocks */
+	dwmac->clk_tx = devm_clk_get(dev, "mac-clk-tx");
+	if (IS_ERR(dwmac->clk_tx)) {
+		dev_err(dev, "No tx clock provided...\n");
+		return PTR_ERR(dwmac->clk_tx);
+	}
+	dwmac->clk_rx = devm_clk_get(dev, "mac-clk-rx");
+	if (IS_ERR(dwmac->clk_rx)) {
+		dev_err(dev, "No rx clock provided...\n");
+		return PTR_ERR(dwmac->clk_rx);
+	}
+
+	/* Get mode register */
+	dwmac->regmap = syscon_regmap_lookup_by_phandle(np, "st,syscon");
+	if (IS_ERR(dwmac->regmap))
+		return PTR_ERR(dwmac->regmap);
+
+	err = of_property_read_u32_index(np, "st,syscon", 1, &dwmac->mode_reg);
+	if (err)
+		dev_err(dev, "Can't get sysconfig mode offset (%d)\n", err);
+
+	return err;
+}
+
+static int stm32_dwmac_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+	struct stm32_dwmac *dwmac;
+	int ret;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
+
+	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
+	if (!dwmac)
+		return -ENOMEM;
+
+	ret = stm32_dwmac_parse_data(dwmac, &pdev->dev);
+	if (ret) {
+		dev_err(&pdev->dev, "Unable to parse OF data\n");
+		return ret;
+	}
+
+	plat_dat->bsp_priv = dwmac;
+
+	ret = stm32_dwmac_init(plat_dat);
+	if (ret)
+		return ret;
+
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		stm32_dwmac_clk_disable(dwmac);
+
+	return ret;
+}
+
+static int stm32_dwmac_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	int ret = stmmac_dvr_remove(&pdev->dev);
+
+	stm32_dwmac_clk_disable(priv->plat->bsp_priv);
+
+	return ret;
+}
+
+#ifdef CONFIG_PM_SLEEP
+static int stm32_dwmac_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = stmmac_suspend(dev);
+	stm32_dwmac_clk_disable(priv->plat->bsp_priv);
+
+	return ret;
+}
+
+static int stm32_dwmac_resume(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	ret = stm32_dwmac_init(priv->plat);
+	if (ret)
+		return ret;
+
+	ret = stmmac_resume(dev);
+
+	return ret;
+}
+#endif /* CONFIG_PM_SLEEP */
+
+SIMPLE_DEV_PM_OPS(stm32_dwmac_pm_ops, stm32_dwmac_suspend, stm32_dwmac_resume);
+
+static const struct of_device_id stm32_dwmac_match[] = {
+	{ .compatible = "st,stm32-dwmac"},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, stm32_dwmac_match);
+
+static struct platform_driver stm32_dwmac_driver = {
+	.probe  = stm32_dwmac_probe,
+	.remove = stm32_dwmac_remove,
+	.driver = {
+		.name           = "stm32-dwmac",
+		.pm		= &stm32_dwmac_pm_ops,
+		.of_match_table = stm32_dwmac_match,
+	},
+};
+module_platform_driver(stm32_dwmac_driver);
+
+MODULE_AUTHOR("Alexandre Torgue <alexandre.torgue@gmail.com>");
+MODULE_DESCRIPTION("STMicroelectronics MCU DWMAC Specific Glue layer");
+MODULE_LICENSE("GPL v2");
-- 
1.9.1
