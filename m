From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH v4 2/2] net: phy: Add gmiitorgmii converter support
Date: Mon, 8 Aug 2016 12:45:05 +0530
Message-ID: <1470640505-8279-2-git-send-email-appanad@xilinx.com>
References: <1470640505-8279-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<appanad@xilinx.com>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
	<punnaia@xilinx.com>, <anirudh@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470640505-8279-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for gmiitorgmii converter.

The GMII to RGMII IP core provides the Reduced Gigabit Media
Independent Interface (RGMII) between Ethernet physical media
Devices and the Gigabit Ethernet controller. This core can
Switch dynamically between the three different speed modes of
Operation by configuring the converter register through mdio write.

MDIO interface is used to set operating speed of Ethernet MAC.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Thanks a lot Andrew for your inputs.
Changes for v4:
--> Updated phydev speed for all 3 speeds as suggested by zhuyj.
Changes for v3:
--> Updated the driver as suggested by Andrew.
Changes for v2:
--> Passed struct xphy pointer directly to the fix_mac_speed
API as suggested by the Florian.
--> Added checks for the phy-node fail case as suggested
by the Florian

 drivers/net/phy/Kconfig             |   8 +++
 drivers/net/phy/Makefile            |   1 +
 drivers/net/phy/xilinx_gmii2rgmii.c | 125 ++++++++++++++++++++++++++++++++++++
 3 files changed, 134 insertions(+)
 create mode 100644 drivers/net/phy/xilinx_gmii2rgmii.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 47a6434..28150f8 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -307,6 +307,14 @@ config MDIO_XGENE
 	  This module provides a driver for the MDIO busses found in the
 	  APM X-Gene SoC's.
 
+config XILINX_GMII2RGMII
+       tristate "Xilinx GMII2RGMII converter driver"
+       default y
+       ---help---
+         This driver support xilinx GMII to RGMII IP core it provides
+         the Reduced Gigabit Media Independent Interface(RGMII) between
+         Ethernet physical media devices and the Gigabit Ethernet controller.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 534dfa7..5d38f5a 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -49,3 +49,4 @@ obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
 obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
 obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
 obj-$(CONFIG_MDIO_XGENE)	+= mdio-xgene.o
+obj-$(CONFIG_XILINX_GMII2RGMII) += xilinx_gmii2rgmii.o
diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
new file mode 100644
index 0000000..8e4a0f3
--- /dev/null
+++ b/drivers/net/phy/xilinx_gmii2rgmii.c
@@ -0,0 +1,125 @@
+/* Xilinx GMII2RGMII Converter driver
+ *
+ * Copyright (C) 2016 Xilinx, Inc.
+ *
+ * Author: Kedareswara rao Appana <appanad@xilinx.com>
+ *
+ * Description:
+ * This driver is developed for Xilinx GMII2RGMII Converter
+ *
+ * This program is free software: you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/mdio.h>
+#include <linux/phy.h>
+#include <linux/of_mdio.h>
+
+#define XILINX_GMII2RGMII_REG	0x10
+#define BMCR_SPEED10		0x00
+
+struct gmii2rgmii {
+	struct phy_device *phy_dev;
+	struct phy_driver *phy_drv;
+	struct phy_driver conv_phy_drv;
+	int addr;
+};
+
+static int xgmiitorgmii_read_status(struct phy_device *phydev)
+{
+	struct gmii2rgmii *priv = (struct gmii2rgmii *)phydev->priv;
+	u16 val = 0;
+
+	priv->phy_drv->read_status(phydev);
+
+	val = mdiobus_read(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG);
+
+	switch (phydev->speed) {
+	case SPEED_1000:
+		val |= BMCR_SPEED1000;
+	case SPEED_100:
+		val |= BMCR_SPEED100;
+	case SPEED_10:
+		val |= BMCR_SPEED10;
+	}
+
+	mdiobus_write(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG, val);
+
+	return 0;
+}
+
+int xgmiitorgmii_probe(struct mdio_device *mdiodev)
+{
+	struct device *dev = &mdiodev->dev;
+	struct device_node *np = dev->of_node, *phy_node;
+	struct gmii2rgmii *priv;
+	int ret;
+
+	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (IS_ERR(phy_node)) {
+		dev_err(dev, "Couldn't parse phy-handle\n");
+		ret = -ENODEV;
+		goto out;
+	}
+
+	priv->phy_dev = of_phy_find_device(phy_node);
+	if (!priv->phy_dev) {
+		ret = -EPROBE_DEFER;
+		dev_info(dev, "Couldn't find phydev\n");
+		goto out;
+	}
+
+	priv->addr = mdiodev->addr;
+	priv->phy_drv = priv->phy_dev->drv;
+	memcpy(&priv->conv_phy_drv, priv->phy_dev->drv,
+	       sizeof(struct phy_driver));
+	priv->conv_phy_drv.read_status = xgmiitorgmii_read_status;
+	priv->phy_dev->priv = priv;
+	priv->phy_dev->drv = &priv->conv_phy_drv;
+
+	return 0;
+out:
+	return ret;
+}
+
+static const struct of_device_id xgmiitorgmii_of_match[] = {
+	{ .compatible = "xlnx,gmii-to-rgmii-1.0" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, xgmiitorgmii_of_match);
+
+static struct mdio_driver xgmiitorgmii_driver = {
+	.probe	= xgmiitorgmii_probe,
+	.mdiodrv.driver = {
+		.name = "xgmiitorgmii",
+		.of_match_table = xgmiitorgmii_of_match,
+	},
+};
+
+static int __init xgmiitorgmii_init(void)
+{
+	return mdio_driver_register(&xgmiitorgmii_driver);
+}
+module_init(xgmiitorgmii_init);
+
+static void __exit xgmiitorgmii_cleanup(void)
+{
+	mdio_driver_unregister(&xgmiitorgmii_driver);
+}
+module_exit(xgmiitorgmii_cleanup);
+
+MODULE_DESCRIPTION("Xilinx GMII2RGMII converter driver");
+MODULE_LICENSE("GPL");
-- 
2.1.2
