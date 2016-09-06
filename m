From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH v5 4/6] net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
Date: Tue,  6 Sep 2016 23:38:46 +0200
Message-ID: <20160906213848.17785-5-martin.blumenstingl@googlemail.com>
References: <20160904182320.671-1-martin.blumenstingl@googlemail.com>
 <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, b.galvani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160906213848.17785-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The Ethernet controller available in Meson8b and GXBB SoCs is a Synopsys
DesignWare MAC IP core which is already supported by the stmmac driver.

In addition to the standard stmmac driver some Meson8b / GXBB specific
registers have to be configured for the PHY clocks. These SoC specific
registers are called PRG_ETHERNET_ADDR0 and PRG_ETHERNET_ADDR1 in the
datasheet.
These registers are not backwards compatible with those on Meson 6b,
which is why a new glue driver is introduced. This worked for many
boards because the bootloader programs the PRG_ETHERNET registers
correctly. Additionally the meson6-dwmac driver only sets bit 1 of
PRG_ETHERNET_ADDR0 which (according to the datasheet) is only used
during reset.

Currently all configuration values can be determined automatically,
based on the configured phy-mode (which is mandatory for the stmmac
driver). If required the tx-delay and the mux clock (so it supports
the MPLL2 clock as well) can be made configurable in the future.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Tested-by: Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   6 +-
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 324 +++++++++++++++++++++
 3 files changed, 328 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 8f06a66..54de175 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -61,13 +61,13 @@ config DWMAC_LPC18XX
 config DWMAC_MESON
 	tristate "Amlogic Meson dwmac support"
 	default ARCH_MESON
-	depends on OF && (ARCH_MESON || COMPILE_TEST)
+	depends on OF && COMMON_CLK && (ARCH_MESON || COMPILE_TEST)
 	help
 	  Support for Ethernet controller on Amlogic Meson SoCs.
 
 	  This selects the Amlogic Meson SoC glue layer support for
-	  the stmmac device driver. This driver is used for Meson6 and
-	  Meson8 SoCs.
+	  the stmmac device driver. This driver is used for Meson6,
+	  Meson8, Meson8b and GXBB SoCs.
 
 config DWMAC_ROCKCHIP
 	tristate "Rockchip dwmac support"
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 44b630c..f77edb9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -9,7 +9,7 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
 obj-$(CONFIG_DWMAC_IPQ806X)	+= dwmac-ipq806x.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
-obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
+obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o dwmac-meson8b.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-altr-socfpga.o
 obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
new file mode 100644
index 0000000..250e4ce
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -0,0 +1,324 @@
+/*
+ * Amlogic Meson8b and GXBB DWMAC glue layer
+ *
+ * Copyright (C) 2016 Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program. If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/clk.h>
+#include <linux/clk-provider.h>
+#include <linux/device.h>
+#include <linux/ethtool.h>
+#include <linux/io.h>
+#include <linux/ioport.h>
+#include <linux/module.h>
+#include <linux/of_net.h>
+#include <linux/mfd/syscon.h>
+#include <linux/platform_device.h>
+#include <linux/stmmac.h>
+
+#include "stmmac_platform.h"
+
+#define PRG_ETH0			0x0
+
+#define PRG_ETH0_RGMII_MODE		BIT(0)
+
+/* mux to choose between fclk_div2 (bit unset) and mpll2 (bit set) */
+#define PRG_ETH0_CLK_M250_SEL_SHIFT	4
+#define PRG_ETH0_CLK_M250_SEL_MASK	GENMASK(4, 4)
+
+#define PRG_ETH0_TXDLY_SHIFT		5
+#define PRG_ETH0_TXDLY_MASK		GENMASK(6, 5)
+#define PRG_ETH0_TXDLY_OFF		(0x0 << PRG_ETH0_TXDLY_SHIFT)
+#define PRG_ETH0_TXDLY_QUARTER		(0x1 << PRG_ETH0_TXDLY_SHIFT)
+#define PRG_ETH0_TXDLY_HALF		(0x2 << PRG_ETH0_TXDLY_SHIFT)
+#define PRG_ETH0_TXDLY_THREE_QUARTERS	(0x3 << PRG_ETH0_TXDLY_SHIFT)
+
+/* divider for the result of m250_sel */
+#define PRG_ETH0_CLK_M250_DIV_SHIFT	7
+#define PRG_ETH0_CLK_M250_DIV_WIDTH	3
+
+/* divides the result of m25_sel by either 5 (bit unset) or 10 (bit set) */
+#define PRG_ETH0_CLK_M25_DIV_SHIFT	10
+#define PRG_ETH0_CLK_M25_DIV_WIDTH	1
+
+#define PRG_ETH0_INVERTED_RMII_CLK	BIT(11)
+#define PRG_ETH0_TX_AND_PHY_REF_CLK	BIT(12)
+
+#define MUX_CLK_NUM_PARENTS		2
+
+struct meson8b_dwmac {
+	struct platform_device	*pdev;
+
+	void __iomem		*regs;
+
+	phy_interface_t		phy_mode;
+
+	struct clk_mux		m250_mux;
+	struct clk		*m250_mux_clk;
+	struct clk		*m250_mux_parent[MUX_CLK_NUM_PARENTS];
+
+	struct clk_divider	m250_div;
+	struct clk		*m250_div_clk;
+
+	struct clk_divider	m25_div;
+	struct clk		*m25_div_clk;
+};
+
+static void meson8b_dwmac_mask_bits(struct meson8b_dwmac *dwmac, u32 reg,
+				    u32 mask, u32 value)
+{
+	u32 data;
+
+	data = readl(dwmac->regs + reg);
+	data &= ~mask;
+	data |= (value & mask);
+
+	writel(data, dwmac->regs + reg);
+}
+
+static int meson8b_init_clk(struct meson8b_dwmac *dwmac)
+{
+	struct clk_init_data init;
+	int i, ret;
+	struct device *dev = &dwmac->pdev->dev;
+	char clk_name[32];
+	const char *clk_div_parents[1];
+	const char *mux_parent_names[MUX_CLK_NUM_PARENTS];
+	static struct clk_div_table clk_25m_div_table[] = {
+		{ .val = 0, .div = 5 },
+		{ .val = 1, .div = 10 },
+		{ /* sentinel */ },
+	};
+
+	/* get the mux parents from DT */
+	for (i = 0; i < MUX_CLK_NUM_PARENTS; i++) {
+		char name[16];
+
+		snprintf(name, sizeof(name), "clkin%d", i);
+		dwmac->m250_mux_parent[i] = devm_clk_get(dev, name);
+		if (IS_ERR(dwmac->m250_mux_parent[i])) {
+			ret = PTR_ERR(dwmac->m250_mux_parent[i]);
+			if (ret != -EPROBE_DEFER)
+				dev_err(dev, "Missing clock %s\n", name);
+			return ret;
+		}
+
+		mux_parent_names[i] =
+			__clk_get_name(dwmac->m250_mux_parent[i]);
+	}
+
+	/* create the m250_mux */
+	snprintf(clk_name, sizeof(clk_name), "%s#m250_sel", dev_name(dev));
+	init.name = clk_name;
+	init.ops = &clk_mux_ops;
+	init.flags = 0;
+	init.parent_names = mux_parent_names;
+	init.num_parents = MUX_CLK_NUM_PARENTS;
+
+	dwmac->m250_mux.reg = dwmac->regs + PRG_ETH0;
+	dwmac->m250_mux.shift = PRG_ETH0_CLK_M250_SEL_SHIFT;
+	dwmac->m250_mux.mask = PRG_ETH0_CLK_M250_SEL_MASK;
+	dwmac->m250_mux.flags = 0;
+	dwmac->m250_mux.table = NULL;
+	dwmac->m250_mux.hw.init = &init;
+
+	dwmac->m250_mux_clk = devm_clk_register(dev, &dwmac->m250_mux.hw);
+	if (WARN_ON(IS_ERR(dwmac->m250_mux_clk)))
+		return PTR_ERR(dwmac->m250_mux_clk);
+
+	/* create the m250_div */
+	snprintf(clk_name, sizeof(clk_name), "%s#m250_div", dev_name(dev));
+	init.name = devm_kstrdup(dev, clk_name, GFP_KERNEL);
+	init.ops = &clk_divider_ops;
+	init.flags = CLK_SET_RATE_PARENT;
+	clk_div_parents[0] = __clk_get_name(dwmac->m250_mux_clk);
+	init.parent_names = clk_div_parents;
+	init.num_parents = ARRAY_SIZE(clk_div_parents);
+
+	dwmac->m250_div.reg = dwmac->regs + PRG_ETH0;
+	dwmac->m250_div.shift = PRG_ETH0_CLK_M250_DIV_SHIFT;
+	dwmac->m250_div.width = PRG_ETH0_CLK_M250_DIV_WIDTH;
+	dwmac->m250_div.hw.init = &init;
+	dwmac->m250_div.flags = CLK_DIVIDER_ONE_BASED | CLK_DIVIDER_ALLOW_ZERO;
+
+	dwmac->m250_div_clk = devm_clk_register(dev, &dwmac->m250_div.hw);
+	if (WARN_ON(IS_ERR(dwmac->m250_div_clk)))
+		return PTR_ERR(dwmac->m250_div_clk);
+
+	/* create the m25_div */
+	snprintf(clk_name, sizeof(clk_name), "%s#m25_div", dev_name(dev));
+	init.name = devm_kstrdup(dev, clk_name, GFP_KERNEL);
+	init.ops = &clk_divider_ops;
+	init.flags = CLK_IS_BASIC | CLK_SET_RATE_PARENT;
+	clk_div_parents[0] = __clk_get_name(dwmac->m250_div_clk);
+	init.parent_names = clk_div_parents;
+	init.num_parents = ARRAY_SIZE(clk_div_parents);
+
+	dwmac->m25_div.reg = dwmac->regs + PRG_ETH0;
+	dwmac->m25_div.shift = PRG_ETH0_CLK_M25_DIV_SHIFT;
+	dwmac->m25_div.width = PRG_ETH0_CLK_M25_DIV_WIDTH;
+	dwmac->m25_div.table = clk_25m_div_table;
+	dwmac->m25_div.hw.init = &init;
+	dwmac->m25_div.flags = CLK_DIVIDER_ALLOW_ZERO;
+
+	dwmac->m25_div_clk = devm_clk_register(dev, &dwmac->m25_div.hw);
+	if (WARN_ON(IS_ERR(dwmac->m25_div_clk)))
+		return PTR_ERR(dwmac->m25_div_clk);
+
+	return 0;
+}
+
+static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
+{
+	int ret;
+	unsigned long clk_rate;
+
+	switch (dwmac->phy_mode) {
+	case PHY_INTERFACE_MODE_RGMII:
+	case PHY_INTERFACE_MODE_RGMII_ID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+		/* Generate a 25MHz clock for the PHY */
+		clk_rate = 25 * 1000 * 1000;
+
+		/* enable RGMII mode */
+		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_RGMII_MODE,
+					PRG_ETH0_RGMII_MODE);
+
+		/* only relevant for RMII mode -> disable in RGMII mode */
+		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0,
+					PRG_ETH0_INVERTED_RMII_CLK, 0);
+
+		/* TX clock delay - all known boards use a 1/4 cycle delay */
+		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
+					PRG_ETH0_TXDLY_QUARTER);
+		break;
+
+	case PHY_INTERFACE_MODE_RMII:
+		/* Use the rate of the mux clock for the internal RMII PHY */
+		clk_rate = clk_get_rate(dwmac->m250_mux_clk);
+
+		/* disable RGMII mode -> enables RMII mode */
+		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_RGMII_MODE,
+					0);
+
+		/* invert internal clk_rmii_i to generate 25/2.5 tx_rx_clk */
+		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0,
+					PRG_ETH0_INVERTED_RMII_CLK,
+					PRG_ETH0_INVERTED_RMII_CLK);
+
+		/* TX clock delay cannot be configured in RMII mode */
+		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
+					0);
+
+		break;
+
+	default:
+		dev_err(&dwmac->pdev->dev, "unsupported phy-mode %s\n",
+			phy_modes(dwmac->phy_mode));
+		return -EINVAL;
+	}
+
+	ret = clk_prepare_enable(dwmac->m25_div_clk);
+	if (ret) {
+		dev_err(&dwmac->pdev->dev, "failed to enable the PHY clock\n");
+		return ret;
+	}
+
+	ret = clk_set_rate(dwmac->m25_div_clk, clk_rate);
+	if (ret) {
+		clk_disable_unprepare(dwmac->m25_div_clk);
+
+		dev_err(&dwmac->pdev->dev, "failed to set PHY clock\n");
+		return ret;
+	}
+
+	/* enable TX_CLK and PHY_REF_CLK generator */
+	meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TX_AND_PHY_REF_CLK,
+				PRG_ETH0_TX_AND_PHY_REF_CLK);
+
+	return 0;
+}
+
+static int meson8b_dwmac_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+	struct resource *res;
+	struct meson8b_dwmac *dwmac;
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
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	dwmac->regs = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(dwmac->regs))
+		return PTR_ERR(dwmac->regs);
+
+	dwmac->pdev = pdev;
+	dwmac->phy_mode = of_get_phy_mode(pdev->dev.of_node);
+	if (dwmac->phy_mode < 0) {
+		dev_err(&pdev->dev, "missing phy-mode property\n");
+		return -EINVAL;
+	}
+
+	ret = meson8b_init_clk(dwmac);
+	if (ret)
+		return ret;
+
+	ret = meson8b_init_prg_eth(dwmac);
+	if (ret)
+		return ret;
+
+	plat_dat->bsp_priv = dwmac;
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
+
+static int meson8b_dwmac_remove(struct platform_device *pdev)
+{
+	struct meson8b_dwmac *dwmac = get_stmmac_bsp_priv(&pdev->dev);
+
+	clk_disable_unprepare(dwmac->m25_div_clk);
+
+	return stmmac_pltfr_remove(pdev);
+}
+
+static const struct of_device_id meson8b_dwmac_match[] = {
+	{ .compatible = "amlogic,meson8b-dwmac" },
+	{ .compatible = "amlogic,meson-gxbb-dwmac" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, meson8b_dwmac_match);
+
+static struct platform_driver meson8b_dwmac_driver = {
+	.probe  = meson8b_dwmac_probe,
+	.remove = meson8b_dwmac_remove,
+	.driver = {
+		.name           = "meson8b-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = meson8b_dwmac_match,
+	},
+};
+module_platform_driver(meson8b_dwmac_driver);
+
+MODULE_AUTHOR("Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>");
+MODULE_DESCRIPTION("Amlogic Meson8b and GXBB DWMAC glue layer");
+MODULE_LICENSE("GPL v2");
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
