From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 1/2] net: stmmac: Add OXNAS Glue Driver
Date: Wed,  2 Nov 2016 15:02:36 +0100
Message-ID: <20161102140237.6955-2-narmstrong@baylibre.com>
References: <20161102140237.6955-1-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-oxnas@lists.tuxfamily.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161102140237.6955-1-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Synopsys Designware MAC Glue layer for the Oxford Semiconductor OX820.

Acked-by: Joachim Eastwood <manabian@gmail.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |  11 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile      |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c | 217 ++++++++++++++++++++++
 3 files changed, 229 insertions(+)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 3818c5e..6e9fcc3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -69,6 +69,17 @@ config DWMAC_MESON
 	  the stmmac device driver. This driver is used for Meson6,
 	  Meson8, Meson8b and GXBB SoCs.
 
+config DWMAC_OXNAS
+	tristate "Oxford Semiconductor OXNAS dwmac support"
+	default ARCH_OXNAS
+	depends on OF && COMMON_CLK && (ARCH_OXNAS || COMPILE_TEST)
+	select MFD_SYSCON
+	help
+	  Support for Ethernet controller on Oxford Semiconductor OXNAS SoCs.
+
+	  This selects the Oxford Semiconductor OXNASSoC glue layer support for
+	  the stmmac device driver. This driver is used for OX820.
+
 config DWMAC_ROCKCHIP
 	tristate "Rockchip dwmac support"
 	default ARCH_ROCKCHIP
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 5d6ece5..8f83a86 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
 obj-$(CONFIG_DWMAC_IPQ806X)	+= dwmac-ipq806x.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
 obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o dwmac-meson8b.o
+obj-$(CONFIG_DWMAC_OXNAS)	+= dwmac-oxnas.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-altr-socfpga.o
 obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
new file mode 100644
index 0000000..c355975
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
@@ -0,0 +1,217 @@
+/*
+ * Oxford Semiconductor OXNAS DWMAC glue layer
+ *
+ * Copyright (C) 2016 Neil Armstrong <narmstrong@baylibre.com>
+ * Copyright (C) 2014 Daniel Golle <daniel@makrotopia.org>
+ * Copyright (C) 2013 Ma Haijun <mahaijuns@gmail.com>
+ * Copyright (C) 2012 John Crispin <blogic@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program. If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/device.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/platform_device.h>
+#include <linux/regmap.h>
+#include <linux/mfd/syscon.h>
+#include <linux/stmmac.h>
+
+#include "stmmac_platform.h"
+
+/* System Control regmap offsets */
+#define OXNAS_DWMAC_CTRL_REGOFFSET	0x78
+#define OXNAS_DWMAC_DELAY_REGOFFSET	0x100
+
+/* Control Register */
+#define DWMAC_CKEN_RX_IN        14
+#define DWMAC_CKEN_RXN_OUT      13
+#define DWMAC_CKEN_RX_OUT       12
+#define DWMAC_CKEN_TX_IN        10
+#define DWMAC_CKEN_TXN_OUT      9
+#define DWMAC_CKEN_TX_OUT       8
+#define DWMAC_RX_SOURCE         7
+#define DWMAC_TX_SOURCE         6
+#define DWMAC_LOW_TX_SOURCE     4
+#define DWMAC_AUTO_TX_SOURCE    3
+#define DWMAC_RGMII             2
+#define DWMAC_SIMPLE_MUX        1
+#define DWMAC_CKEN_GTX          0
+
+/* Delay register */
+#define DWMAC_TX_VARDELAY_SHIFT		0
+#define DWMAC_TXN_VARDELAY_SHIFT	8
+#define DWMAC_RX_VARDELAY_SHIFT		16
+#define DWMAC_RXN_VARDELAY_SHIFT	24
+#define DWMAC_TX_VARDELAY(d)		((d) << DWMAC_TX_VARDELAY_SHIFT)
+#define DWMAC_TXN_VARDELAY(d)		((d) << DWMAC_TXN_VARDELAY_SHIFT)
+#define DWMAC_RX_VARDELAY(d)		((d) << DWMAC_RX_VARDELAY_SHIFT)
+#define DWMAC_RXN_VARDELAY(d)		((d) << DWMAC_RXN_VARDELAY_SHIFT)
+
+struct oxnas_dwmac {
+	struct device	*dev;
+	struct clk	*clk;
+	struct regmap	*regmap;
+};
+
+static int oxnas_dwmac_init(struct oxnas_dwmac *dwmac)
+{
+	unsigned int value;
+	int ret;
+
+	/* Reset HW here before changing the glue configuration */
+	ret = device_reset(dwmac->dev);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(dwmac->clk);
+	if (ret)
+		return ret;
+
+	ret = regmap_read(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, &value);
+	if (ret < 0) {
+		clk_disable_unprepare(dwmac->clk);
+		return ret;
+	}
+
+	/* Enable GMII_GTXCLK to follow GMII_REFCLK, required for gigabit PHY */
+	value |= BIT(DWMAC_CKEN_GTX)		|
+		 /* Use simple mux for 25/125 Mhz clock switching */
+		 BIT(DWMAC_SIMPLE_MUX)		|
+		 /* set auto switch tx clock source */
+		 BIT(DWMAC_AUTO_TX_SOURCE)	|
+		 /* enable tx & rx vardelay */
+		 BIT(DWMAC_CKEN_TX_OUT)		|
+		 BIT(DWMAC_CKEN_TXN_OUT)	|
+		 BIT(DWMAC_CKEN_TX_IN)		|
+		 BIT(DWMAC_CKEN_RX_OUT)		|
+		 BIT(DWMAC_CKEN_RXN_OUT)	|
+		 BIT(DWMAC_CKEN_RX_IN);
+	regmap_write(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, value);
+
+	/* set tx & rx vardelay */
+	value = DWMAC_TX_VARDELAY(4)	|
+		DWMAC_TXN_VARDELAY(2)	|
+		DWMAC_RX_VARDELAY(10)	|
+		DWMAC_RXN_VARDELAY(8);
+	regmap_write(dwmac->regmap, OXNAS_DWMAC_DELAY_REGOFFSET, value);
+
+	return 0;
+}
+
+static int oxnas_dwmac_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+	struct device_node *sysctrl;
+	struct oxnas_dwmac *dwmac;
+	int ret;
+
+	sysctrl = of_parse_phandle(pdev->dev.of_node, "oxsemi,sys-ctrl", 0);
+	if (!sysctrl) {
+		dev_err(&pdev->dev, "failed to get sys-ctrl node\n");
+		return -EINVAL;
+	}
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
+	dwmac->dev = &pdev->dev;
+	plat_dat->bsp_priv = dwmac;
+
+	dwmac->regmap = syscon_node_to_regmap(sysctrl);
+	if (IS_ERR(dwmac->regmap)) {
+		dev_err(&pdev->dev, "failed to have sysctrl regmap\n");
+		return PTR_ERR(dwmac->regmap);
+	}
+
+	dwmac->clk = devm_clk_get(&pdev->dev, "gmac");
+	if (IS_ERR(dwmac->clk))
+		return PTR_ERR(dwmac->clk);
+
+	ret = oxnas_dwmac_init(dwmac);
+	if (ret)
+		return ret;
+
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		clk_disable_unprepare(dwmac->clk);
+
+	return ret;
+}
+
+static int oxnas_dwmac_remove(struct platform_device *pdev)
+{
+	struct oxnas_dwmac *dwmac = get_stmmac_bsp_priv(&pdev->dev);
+	int ret = stmmac_dvr_remove(&pdev->dev);
+
+	clk_disable_unprepare(dwmac->clk);
+
+	return ret;
+}
+
+#ifdef CONFIG_PM_SLEEP
+static int oxnas_dwmac_suspend(struct device *dev)
+{
+	struct oxnas_dwmac *dwmac = get_stmmac_bsp_priv(dev);
+	int ret;
+
+	ret = stmmac_suspend(dev);
+	clk_disable_unprepare(dwmac->clk);
+
+	return ret;
+}
+
+static int oxnas_dwmac_resume(struct device *dev)
+{
+	struct oxnas_dwmac *dwmac = get_stmmac_bsp_priv(dev);
+	int ret;
+
+	ret = oxnas_dwmac_init(dwmac);
+	if (ret)
+		return ret;
+
+	ret = stmmac_resume(dev);
+
+	return ret;
+}
+#endif /* CONFIG_PM_SLEEP */
+
+static SIMPLE_DEV_PM_OPS(oxnas_dwmac_pm_ops,
+	oxnas_dwmac_suspend, oxnas_dwmac_resume);
+
+static const struct of_device_id oxnas_dwmac_match[] = {
+	{ .compatible = "oxsemi,ox820-dwmac" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, oxnas_dwmac_match);
+
+static struct platform_driver oxnas_dwmac_driver = {
+	.probe  = oxnas_dwmac_probe,
+	.remove = oxnas_dwmac_remove,
+	.driver = {
+		.name           = "oxnas-dwmac",
+		.pm		= &oxnas_dwmac_pm_ops,
+		.of_match_table = oxnas_dwmac_match,
+	},
+};
+module_platform_driver(oxnas_dwmac_driver);
+
+MODULE_AUTHOR("Neil Armstrong <narmstrong@baylibre.com>");
+MODULE_DESCRIPTION("Oxford Semiconductor OXNAS DWMAC glue layer");
+MODULE_LICENSE("GPL v2");
-- 
2.7.0
