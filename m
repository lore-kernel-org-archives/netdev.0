From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH 5/6] phy: Add USB3 PHY support for Broadcom NSP SoC
Date: Wed,  9 Nov 2016 04:33:13 -0500
Message-ID: <1478683994-12008-6-git-send-email-yendapally.reddy@broadcom.com>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Yendapally Reddy Dhananjaya Reddy
        <yendapally.reddy@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34457 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753531AbcKIJdj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 04:33:39 -0500
Received: by mail-pf0-f171.google.com with SMTP id n85so124413746pfi.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 01:33:39 -0800 (PST)
In-Reply-To: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for Broadcom NSP USB3 PHY

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 drivers/phy/Kconfig            |   9 +++
 drivers/phy/Makefile           |   1 +
 drivers/phy/phy-bcm-nsp-usb3.c | 176 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 186 insertions(+)
 create mode 100644 drivers/phy/phy-bcm-nsp-usb3.c

diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
index fe00f91..85cc556 100644
--- a/drivers/phy/Kconfig
+++ b/drivers/phy/Kconfig
@@ -489,4 +489,13 @@ config PHY_NS2_PCIE
 	help
 	  Enable this to support the Broadcom Northstar2 PCIe PHY.
 	  If unsure, say N.
+
+config PHY_NSP_USB3
+	tristate "Broadcom NorthStar plus USB3 PHY driver"
+	depends on OF && (ARCH_BCM_NSP || COMPILE_TEST)
+	select GENERIC_PHY
+	default ARCH_BCM_NSP
+	help
+	  Enable this to support the Broadcom Northstar plus USB3 PHY.
+	  If unsure, say N.
 endmenu
diff --git a/drivers/phy/Makefile b/drivers/phy/Makefile
index a534cf5..ba9b4c0 100644
--- a/drivers/phy/Makefile
+++ b/drivers/phy/Makefile
@@ -60,3 +60,4 @@ obj-$(CONFIG_PHY_PISTACHIO_USB)		+= phy-pistachio-usb.o
 obj-$(CONFIG_PHY_CYGNUS_PCIE)		+= phy-bcm-cygnus-pcie.o
 obj-$(CONFIG_ARCH_TEGRA) += tegra/
 obj-$(CONFIG_PHY_NS2_PCIE)		+= phy-bcm-ns2-pcie.o
+obj-$(CONFIG_PHY_NSP_USB3)		+= phy-bcm-nsp-usb3.o
diff --git a/drivers/phy/phy-bcm-nsp-usb3.c b/drivers/phy/phy-bcm-nsp-usb3.c
new file mode 100644
index 0000000..0033382
--- /dev/null
+++ b/drivers/phy/phy-bcm-nsp-usb3.c
@@ -0,0 +1,176 @@
+/*
+ * Copyright (C) 2016 Broadcom
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/mfd/syscon.h>
+#include <linux/mdio.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/phy/phy.h>
+#include <linux/regmap.h>
+
+#define NSP_USB3_RST_CTRL_OFFSET	0x3f8
+
+/* mdio reg access */
+#define NSP_USB3_PHY_BASE_ADDR_REG	0x1f
+
+#define NSP_USB3_PHY_PLL30_BLOCK	0x8000
+#define NSP_USB3_PLL_CONTROL		0x01
+#define NSP_USB3_PLLA_CONTROL0		0x0a
+#define NSP_USB3_PLLA_CONTROL1		0x0b
+
+#define NSP_USB3_PHY_TX_PMD_BLOCK	0x8040
+#define NSP_USB3_TX_PMD_CONTROL1	0x01
+
+#define NSP_USB3_PHY_PIPE_BLOCK		0x8060
+#define NSP_USB3_LFPS_CMP		0x02
+#define NSP_USB3_LFPS_DEGLITCH		0x03
+
+struct nsp_usb3_phy {
+	struct regmap *usb3_ctrl;
+	struct phy *phy;
+	struct mdio_device *mdiodev;
+};
+
+static int nsp_usb3_phy_init(struct phy *phy)
+{
+	struct nsp_usb3_phy *iphy = phy_get_drvdata(phy);
+	struct mii_bus *bus = iphy->mdiodev->bus;
+	int addr = iphy->mdiodev->addr;
+	u32 data;
+	int rc;
+
+	rc = regmap_read(iphy->usb3_ctrl, 0, &data);
+	if (rc)
+		return rc;
+	data |= 1;
+	rc = regmap_write(iphy->usb3_ctrl, 0, data);
+	if (rc)
+		return rc;
+
+	rc = regmap_write(iphy->usb3_ctrl, NSP_USB3_RST_CTRL_OFFSET, 1);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PHY_BASE_ADDR_REG,
+			   NSP_USB3_PHY_PLL30_BLOCK);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PLL_CONTROL, 0x1000);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PLLA_CONTROL0, 0x6400);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PLLA_CONTROL1, 0xc000);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PLLA_CONTROL1, 0x8000);
+	if (rc)
+		return rc;
+
+	rc = regmap_write(iphy->usb3_ctrl, NSP_USB3_RST_CTRL_OFFSET, 0);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PLL_CONTROL, 0x9000);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PHY_BASE_ADDR_REG,
+			   NSP_USB3_PHY_PIPE_BLOCK);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_LFPS_CMP, 0xf30d);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_LFPS_DEGLITCH, 0x6302);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_PHY_BASE_ADDR_REG,
+			   NSP_USB3_PHY_TX_PMD_BLOCK);
+	if (rc)
+		return rc;
+
+	rc = mdiobus_write(bus, addr, NSP_USB3_TX_PMD_CONTROL1, 0x1003);
+
+	return rc;
+}
+
+static struct phy_ops nsp_usb3_phy_ops = {
+	.init = nsp_usb3_phy_init,
+};
+
+static int nsp_usb3_phy_probe(struct mdio_device *mdiodev)
+{
+	struct device *dev = &mdiodev->dev;
+	struct phy_provider *provider;
+	struct nsp_usb3_phy *iphy;
+
+	iphy = devm_kzalloc(dev, sizeof(*iphy), GFP_KERNEL);
+	if (!iphy)
+		return -ENOMEM;
+	iphy->mdiodev = mdiodev;
+
+	iphy->usb3_ctrl = syscon_regmap_lookup_by_phandle(dev->of_node,
+						 "usb3-ctrl-syscon");
+	if (IS_ERR(iphy->usb3_ctrl))
+		return PTR_ERR(iphy->usb3_ctrl);
+
+	iphy->phy = devm_phy_create(dev, dev->of_node, &nsp_usb3_phy_ops);
+	if (IS_ERR(iphy->phy)) {
+		dev_err(dev, "failed to create PHY\n");
+		return PTR_ERR(iphy->phy);
+	}
+
+	phy_set_drvdata(iphy->phy, iphy);
+
+	provider = devm_of_phy_provider_register(dev, of_phy_simple_xlate);
+	if (IS_ERR(provider)) {
+		dev_err(dev, "could not register PHY provider\n");
+		return PTR_ERR(provider);
+	}
+
+	return 0;
+}
+
+static const struct of_device_id nsp_usb3_phy_of_match[] = {
+	{.compatible = "brcm,nsp-usb3-phy",},
+	{ /* sentinel */ }
+};
+
+static struct mdio_driver nsp_usb3_phy_driver = {
+	.mdiodrv = {
+		.driver = {
+			.name = "nsp-usb3-phy",
+			.of_match_table = nsp_usb3_phy_of_match,
+		},
+	},
+	.probe = nsp_usb3_phy_probe,
+};
+
+mdio_module_driver(nsp_usb3_phy_driver);
+
+MODULE_DESCRIPTION("Broadcom NSP USB3 PHY driver");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com");
-- 
2.1.0
