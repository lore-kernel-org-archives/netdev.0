From: Alexandru Gagniuc <alex.g@adaptrum.com>
Subject: [PATCH v2 1/2] net: stmmac: Add Adaptrum Anarion GMAC glue layer
Date: Fri,  4 Aug 2017 13:08:51 -0700
Message-ID: <20170804200852.16049-1-alex.g@adaptrum.com>
References: <20170728.190155.457209566729295513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        robh+dt@kernel.org, Alexandru Gagniuc <alex.g@adaptrum.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0080.outbound.protection.outlook.com ([104.47.38.80]:35872
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751343AbdHDUJE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 16:09:04 -0400
In-Reply-To: <20170728.190155.457209566729295513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the GMAC on the Anarion chip can be used, the PHY interface
selection must be configured with the DWMAC block in reset.

This layer covers a block containing only two registers. Although it
is possible to model this as a reset controller and use the "resets"
property of stmmac, it's much more intuitive to include this in the
glue layer instead.

At this time only RGMII is supported, because it is the only mode
which has been validated hardware-wise.

Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
---
Changes since v1:
 * Moved documentation for bindings to separate patch

 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   9 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 .../net/ethernet/stmicro/stmmac/dwmac-anarion.c    | 152 +++++++++++++++++++++
 3 files changed, 162 insertions(+)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-anarion.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 85c0e41..9703576 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -45,6 +45,15 @@ config DWMAC_GENERIC
 	  platform specific code to function or is using platform
 	  data for setup.
 
+config DWMAC_ANARION
+	tristate "Adaptrum Anarion GMAC support"
+	default ARC
+	depends on OF && (ARC || COMPILE_TEST)
+	help
+	  Support for Adaptrum Anarion GMAC Ethernet controller.
+
+	  This selects the Anarion SoC glue layer support for the stmmac driver.
+
 config DWMAC_IPQ806X
 	tristate "QCA IPQ806x DWMAC support"
 	default ARCH_QCOM
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index fd4937a..238307f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -7,6 +7,7 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 
 # Ordering matters. Generic driver must be last.
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
+obj-$(CONFIG_DWMAC_ANARION)	+= dwmac-anarion.o
 obj-$(CONFIG_DWMAC_IPQ806X)	+= dwmac-ipq806x.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
 obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o dwmac-meson8b.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-anarion.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-anarion.c
new file mode 100644
index 0000000..85ce80c
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-anarion.c
@@ -0,0 +1,152 @@
+/*
+ * Adaptrum Anarion DWMAC glue layer
+ *
+ * Copyright (C) 2017, Adaptrum, Inc.
+ * (Written by Alexandru Gagniuc <alex.g at adaptrum.com> for Adaptrum, Inc.)
+ * Licensed under the GPLv2 or (at your option) any later version.
+ */
+
+#include <linux/io.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/stmmac.h>
+
+#include "stmmac.h"
+#include "stmmac_platform.h"
+
+#define GMAC_RESET_CONTROL_REG		0
+#define GMAC_SW_CONFIG_REG		4
+#define  GMAC_CONFIG_INTF_SEL_MASK	(0x7 << 0)
+#define  GMAC_CONFIG_INTF_RGMII		(0x1 << 0)
+
+struct anarion_gmac {
+	uintptr_t ctl_block;
+	uint32_t phy_intf_sel;
+};
+
+static uint32_t gmac_read_reg(struct anarion_gmac *gmac, uint8_t reg)
+{
+	return readl((void *)(gmac->ctl_block + reg));
+};
+
+static void gmac_write_reg(struct anarion_gmac *gmac, uint8_t reg, uint32_t val)
+{
+	writel(val, (void *)(gmac->ctl_block + reg));
+}
+
+static int anarion_gmac_init(struct platform_device *pdev, void *priv)
+{
+	uint32_t sw_config;
+	struct anarion_gmac *gmac = priv;
+
+	/* Reset logic, configure interface mode, then release reset. SIMPLE! */
+	gmac_write_reg(gmac, GMAC_RESET_CONTROL_REG, 1);
+
+	sw_config = gmac_read_reg(gmac, GMAC_SW_CONFIG_REG);
+	sw_config &= ~GMAC_CONFIG_INTF_SEL_MASK;
+	sw_config |= (gmac->phy_intf_sel & GMAC_CONFIG_INTF_SEL_MASK);
+	gmac_write_reg(gmac, GMAC_SW_CONFIG_REG, sw_config);
+
+	gmac_write_reg(gmac, GMAC_RESET_CONTROL_REG, 0);
+
+	return 0;
+}
+
+static void anarion_gmac_exit(struct platform_device *pdev, void *priv)
+{
+	struct anarion_gmac *gmac = priv;
+
+	gmac_write_reg(gmac, GMAC_RESET_CONTROL_REG, 1);
+}
+
+static struct anarion_gmac *anarion_config_dt(struct platform_device *pdev)
+{
+	int phy_mode;
+	struct resource *res;
+	void __iomem *ctl_block;
+	struct anarion_gmac *gmac;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	ctl_block = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(ctl_block)) {
+		dev_err(&pdev->dev, "Cannot get reset region (%ld)!\n",
+			PTR_ERR(ctl_block));
+		return ctl_block;
+	}
+
+	gmac = devm_kzalloc(&pdev->dev, sizeof(*gmac), GFP_KERNEL);
+	if (!gmac)
+		return ERR_PTR(-ENOMEM);
+
+	gmac->ctl_block = (uintptr_t)ctl_block;
+
+	phy_mode = of_get_phy_mode(pdev->dev.of_node);
+	switch (phy_mode) {
+	case PHY_INTERFACE_MODE_RGMII:		/* Fall through */
+	case PHY_INTERFACE_MODE_RGMII_ID	/* Fall through */:
+	case PHY_INTERFACE_MODE_RGMII_RXID:	/* Fall through */
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+		gmac->phy_intf_sel = GMAC_CONFIG_INTF_RGMII;
+		break;
+	default:
+		dev_err(&pdev->dev, "Unsupported phy-mode (%d)\n",
+			phy_mode);
+		return ERR_PTR(-ENOTSUPP);
+	}
+
+	return gmac;
+}
+
+static int anarion_dwmac_probe(struct platform_device *pdev)
+{
+	int ret;
+	struct anarion_gmac *gmac;
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	gmac = anarion_config_dt(pdev);
+	if (IS_ERR(gmac))
+		return PTR_ERR(gmac);
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
+
+	plat_dat->init = anarion_gmac_init;
+	plat_dat->exit = anarion_gmac_exit;
+	anarion_gmac_init(pdev, gmac);
+	plat_dat->bsp_priv = gmac;
+
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret) {
+		stmmac_remove_config_dt(pdev, plat_dat);
+		return ret;
+	}
+
+	return 0;
+}
+
+static const struct of_device_id anarion_dwmac_match[] = {
+	{ .compatible = "adaptrum,anarion-gmac" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, anarion_dwmac_match);
+
+static struct platform_driver anarion_dwmac_driver = {
+	.probe  = anarion_dwmac_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "anarion-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = anarion_dwmac_match,
+	},
+};
+module_platform_driver(anarion_dwmac_driver);
+
+MODULE_DESCRIPTION("Adaptrum Anarion DWMAC specific glue layer");
+MODULE_AUTHOR("Alexandru Gagniuc <mr.nuke.me@gmail.com>");
+MODULE_LICENSE("GPL v2");
-- 
2.9.3
