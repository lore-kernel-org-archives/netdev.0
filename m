From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH RFC 2/3] net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
Date: Sat, 25 Jun 2016 18:50:12 +0200
Message-ID: <20160625165013.15917-3-martin.blumenstingl@googlemail.com>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Cc: carlo@caione.org, khilman@baylibre.com, robh+dt@kernel.org,
	mark.rutland@arm.com, netdev@vger.kernel.org,
	peppe.cavallaro@st.com,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36173 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcFYQuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:50:25 -0400
Received: by mail-wm0-f67.google.com with SMTP id c82so13318930wme.3
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 09:50:24 -0700 (PDT)
In-Reply-To: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet controller available in Meson8b and GXBB SoCs is a Synopsys
DesignWare MAC IP core which is already supported by the stmmac driver.

In addition to the standard stmmac driver some Meson8b / GXBB specific
registers have to be configured for the PHY clocks. These SoC specific
registers are called PRG_ETHERNET_ADDR0 and PRG_ETHERNET_ADDR1 in the
datasheet.
These registers are not backwards compatible with those on Meson 6b,
which is why a new glue driver was introduced.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 219 +++++++++++++++++++++
 include/dt-bindings/net/amlogic-meson8b-dwmac.h    |  33 ++++
 3 files changed, 253 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
 create mode 100644 include/dt-bindings/net/amlogic-meson8b-dwmac.h

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 0fb362d..79e5d0c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -9,7 +9,7 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
 obj-$(CONFIG_DWMAC_IPQ806X)	+= dwmac-ipq806x.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
-obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
+obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o dwmac-meson8b.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-socfpga.o
 obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
new file mode 100644
index 0000000..4c2d1e1
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -0,0 +1,219 @@
+/*
+ * Amlogic Meson S805/S905 DWMAC glue layer
+ *
+ * Copyright (C) 20016 Martin Blumenstingl <martin.blumenstingl@googlemail.com>
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
+#include <linux/ethtool.h>
+#include <linux/io.h>
+#include <linux/ioport.h>
+#include <linux/module.h>
+#include <linux/of_net.h>
+#include <linux/mfd/syscon.h>
+#include <linux/platform_device.h>
+#include <linux/regmap.h>
+#include <linux/stmmac.h>
+
+#include "stmmac_platform.h"
+
+#define PRG_ETH0			0x0
+#define PRG_ETH0_RGMII_MODE		BIT(0)
+#define PRG_ETH0_TXDLY_SHIFT		5 /* 2 bits [5-6] */
+#define PRG_ETH0_TXDLY_MASK		(0x3 << PRG_ETH0_TXDLY_SHIFT)
+#define PRG_ETH0_MP2_CLK_SHIFT		7 /* 3 bits [7-9] */
+#define PRG_ETH0_MP2_CLK_MASK		(0x7 << PRG_ETH0_MP2_CLK_SHIFT)
+#define PRG_ETH0_GEN_25MHZ_PHY_CLK	BIT(10)
+#define PRG_ETH0_TX_CLK_SPEED_100	BIT(11)
+#define PRG_ETH0_TX_AND_PHY_REF_CLK	BIT(12)
+
+struct meson8b_dwmac {
+	struct platform_device	*pdev;
+	struct regmap		*prg_ethernet;
+	phy_interface_t		phy_mode;
+	u32			tx_delay;
+	u32			mp2_clk;
+	bool			enable_25mhz_phy_clk;
+};
+
+static void meson8b_dwmac_fix_mac_speed(void *priv, unsigned int speed)
+{
+	struct meson8b_dwmac *dwmac = priv;
+
+	/* MAC speed adjustment is only needed in RMII mode */
+	if (dwmac->phy_mode != PHY_INTERFACE_MODE_RMII)
+		return;
+
+	switch (speed) {
+	case SPEED_10:
+		/* 2.5MHz */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_TX_CLK_SPEED_100, 0);
+		break;
+	case SPEED_100:
+		/* 25MHz */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_TX_CLK_SPEED_100,
+				   PRG_ETH0_TX_CLK_SPEED_100);
+		break;
+	}
+}
+
+static int meson8b_dwmac_of_parse(struct meson8b_dwmac *dwmac)
+{
+	struct device *dev = &dwmac->pdev->dev;
+	struct device_node *np = dev->of_node;
+
+	dwmac->phy_mode = of_get_phy_mode(np);
+	if (dwmac->phy_mode < 0) {
+		dev_err(dev, "missing phy-mode property\n");
+		return -EINVAL;
+	}
+
+	/* register map for MAC configuration */
+	dwmac->prg_ethernet = syscon_regmap_lookup_by_phandle(np,
+					"amlogic,prg-ethernet");
+	if (IS_ERR(dwmac->prg_ethernet)) {
+		dev_err(dev, "missing amlogic,prg-ethernet property\n");
+		return PTR_ERR(dwmac->prg_ethernet);
+	}
+
+	if (of_property_read_bool(np, "amlogic,enable-25mhz-phy-clk"))
+		dwmac->enable_25mhz_phy_clk = true;
+
+	/* TX delay is optional */
+	of_property_read_u32(np, "amlogic,tx-delay", &dwmac->tx_delay);
+
+	/* MP2 clock is optional at least in RMII mode */
+	of_property_read_u32(np, "amlogic,mp2-clock", &dwmac->mp2_clk);
+
+	return 0;
+}
+
+static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
+{
+	switch (dwmac->phy_mode) {
+	case PHY_INTERFACE_MODE_RGMII:
+	case PHY_INTERFACE_MODE_RGMII_ID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+		/* enable RGMII mode */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_RGMII_MODE,
+				   PRG_ETH0_RGMII_MODE);
+
+		/* only relevant for RMII mode -> disable in RGMII mode */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_TX_CLK_SPEED_100, 0);
+
+		/* TX clock delay (ranges from 0 to 3/4 clock cycles) */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_TXDLY_MASK,
+				   dwmac->tx_delay << PRG_ETH0_TXDLY_SHIFT);
+		break;
+
+	case PHY_INTERFACE_MODE_RMII:
+		/* disable RGMII mode -> enables RMII mode */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_RGMII_MODE, 0);
+
+		/* default to 100Mbit mode */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_TX_CLK_SPEED_100,
+				   PRG_ETH0_TX_CLK_SPEED_100);
+
+		/* TX clock delay cannot be configured in RMII mode */
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_TXDLY_MASK, 0);
+
+		break;
+
+	default:
+		dev_err(&dwmac->pdev->dev, "unsupported phy-mode %s\n",
+			phy_modes(dwmac->phy_mode));
+		return -EINVAL;
+	}
+
+	/* mp2_clk is the factor for mp2_clk_out, rate = 250MHz * factor */
+	regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0, PRG_ETH0_MP2_CLK_MASK,
+			   dwmac->mp2_clk << PRG_ETH0_MP2_CLK_SHIFT);
+
+	/* should we generate 25MHz for the PHY? */
+	if (dwmac->enable_25mhz_phy_clk)
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_GEN_25MHZ_PHY_CLK,
+				   PRG_ETH0_GEN_25MHZ_PHY_CLK);
+	else
+		regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+				   PRG_ETH0_GEN_25MHZ_PHY_CLK, 0);
+
+	/* enable TX_CLK and PHY_REF_CLK generator */
+	regmap_update_bits(dwmac->prg_ethernet, PRG_ETH0,
+			   PRG_ETH0_TX_AND_PHY_REF_CLK,
+			   PRG_ETH0_TX_AND_PHY_REF_CLK);
+
+	return 0;
+}
+
+static int meson8b_dwmac_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
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
+	dwmac->pdev = pdev;
+
+	ret = meson8b_dwmac_of_parse(dwmac);
+	if (ret)
+		return ret;
+
+	ret = meson8b_init_prg_eth(dwmac);
+	if (ret)
+		return ret;
+
+	plat_dat->bsp_priv = dwmac;
+	plat_dat->fix_mac_speed = meson8b_dwmac_fix_mac_speed;
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
+
+static const struct of_device_id meson8b_dwmac_match[] = {
+	{ .compatible = "amlogic,meson8b-dwmac" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, meson8b_dwmac_match);
+
+static struct platform_driver meson8b_dwmac_driver = {
+	.probe  = meson8b_dwmac_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "meson8b-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = meson8b_dwmac_match,
+	},
+};
+module_platform_driver(meson8b_dwmac_driver);
+
+MODULE_AUTHOR("Martin Blumenstingl <martin.blumenstingl@googlemail.com>");
+MODULE_DESCRIPTION("Amlogic Meson S805/S905 DWMAC glue layer");
+MODULE_LICENSE("GPL v2");
diff --git a/include/dt-bindings/net/amlogic-meson8b-dwmac.h b/include/dt-bindings/net/amlogic-meson8b-dwmac.h
new file mode 100644
index 0000000..413ef4e
--- /dev/null
+++ b/include/dt-bindings/net/amlogic-meson8b-dwmac.h
@@ -0,0 +1,33 @@
+/*
+ * Device Tree constants for the Amlogic Meson S805/S905 DWMAC
+ *
+ * Copyright (C) 20016 Martin Blumenstingl <martin.blumenstingl@googlemail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program. If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef _DT_BINDINGS_AMLOGIC_MESON8B_DWMAC_H
+#define _DT_BINDINGS_AMLOGIC_MESON8B_DWMAC_H
+
+/* TX delay settings */
+#define MESON8B_DWMAC_TX_CLK_DELAY_OFF				0x0
+#define MESON8B_DWMAC_TX_CLK_DELAY_QUARTER_CYCLE		0x1
+#define MESON8B_DWMAC_TX_CLK_DELAY_HALF_CYCLE			0x2
+#define MESON8B_DWMAC_TX_CLK_DELAY_THREE_QUARTER_CYCLEs		0x3
+
+/* mp2 clock rates */
+#define MESON8B_DWMAC_MP2_CLOCK_DISABLED	0
+#define MESON8B_DWMAC_MP2_CLOCK_250MHZ		1
+#define MESON8B_DWMAC_MP2_CLOCK_500MHZ		2
+#define MESON8B_DWMAC_MP2_CLOCK_750MHZ		3
+#define MESON8B_DWMAC_MP2_CLOCK_1000MHZ		4
+#define MESON8B_DWMAC_MP2_CLOCK_1250MHZ		5
+#define MESON8B_DWMAC_MP2_CLOCK_1500MHZ		6
+#define MESON8B_DWMAC_MP2_CLOCK_1750MHZ		7
+
+#endif /* _DT_BINDINGS_AMLOGIC_MESON8B_DWMAC_H */
-- 
2.9.0
