From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: [PATCH v3 1/2] net: phy: Add Cortina CS4340 driver
Date: Fri, 26 May 2017 07:58:38 +0000
Message-ID: <1495785519-1468-2-git-send-email-bogdan.purcareata@nxp.com>
References: <1495785519-1468-1-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1495785519-1468-1-git-send-email-bogdan.purcareata@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add basic support for Cortina PHY drivers. Support only CS4340 for now.
The phys are not compatible with IEEE 802.3 clause 22/45 registers.

Implement proper read_status support. The generic 10G phy driver causes
bus register access errors.

The driver should be described using the "ethernet-phy-id" device tree
compatible.

Signed-off-by: Bogdan Purcareata <bogdan.purcareata@nxp.com>
---
v2 -> v3:
- Add probe function to check the device we're talking with is the same
  as the one described in the device tree.
- Change the link status (GPIO interrupt status) register and validate
  that the read is done from the right place (cable plug-in / plug-out).
- Some functions + Kconfig entry renaming.

v1 -> v2:
- Rename "mdio-cortina.c" to "cortina.c" since it's a phy driver.
- Test probing based on the "ethernet-phy-id" compatible. In the previous
  version, getting the phy_id via get_phy_c45_ids() involved an additional
  hack. Drop that approach and document probing in the commit message.

 drivers/net/phy/Kconfig   |   5 ++
 drivers/net/phy/Makefile  |   1 +
 drivers/net/phy/cortina.c | 115 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 121 insertions(+)
 create mode 100644 drivers/net/phy/cortina.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 22dea7f..8cd7a0e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -240,6 +240,11 @@ config CICADA_PHY
 	---help---
 	  Currently supports the cis8204
 
+config CORTINA_PHY
+	tristate "Cortina EDC CDR 10G Ethernet PHY"
+	---help---
+	  Currently supports the CS4340 phy.
+
 config DAVICOM_PHY
 	tristate "Davicom PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 79365be..0de3e20 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -47,6 +47,7 @@ obj-$(CONFIG_BCM_CYGNUS_PHY)	+= bcm-cygnus.o
 obj-$(CONFIG_BCM_NET_PHYLIB)	+= bcm-phy-lib.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_CICADA_PHY)	+= cicada.o
+obj-$(CONFIG_CORTINA_PHY)	+= cortina.o
 obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
 obj-$(CONFIG_DP83848_PHY)	+= dp83848.o
diff --git a/drivers/net/phy/cortina.c b/drivers/net/phy/cortina.c
new file mode 100644
index 0000000..209c022
--- /dev/null
+++ b/drivers/net/phy/cortina.c
@@ -0,0 +1,115 @@
+/*
+ *    Copyright 2017 NXP
+ *
+ *    This program is free software; you can redistribute it and/or modify
+ *    it under the terms of the GNU General Public License as published by
+ *    the Free Software Foundation; either version 2 of the License, or
+ *    (at your option) any later version.
+ *
+ *    This program is distributed in the hope that it will be useful,
+ *    but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *    GNU General Public License for more details.
+ *
+ */
+#include <linux/module.h>
+#include <linux/phy.h>
+
+#define PHY_ID_CS4340	0x13e51002
+
+#define VILLA_GLOBAL_CHIP_ID_LSB			0x0
+#define VILLA_GLOBAL_CHIP_ID_MSB			0x1
+
+#define VILLA_GLOBAL_GPIO_1_INTS			0x017
+
+static int cortina_read_reg(struct phy_device *phydev, u16 regnum)
+{
+	return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr,
+			    MII_ADDR_C45 | regnum);
+}
+
+static int cortina_config_aneg(struct phy_device *phydev)
+{
+	phydev->supported = SUPPORTED_10000baseT_Full;
+	phydev->advertising = SUPPORTED_10000baseT_Full;
+
+	return 0;
+}
+
+static int cortina_read_status(struct phy_device *phydev)
+{
+	int gpio_int_status, ret = 0;
+
+	gpio_int_status = cortina_read_reg(phydev, VILLA_GLOBAL_GPIO_1_INTS);
+	if (gpio_int_status < 0) {
+		ret = gpio_int_status;
+		goto err;
+	}
+
+	if (gpio_int_status & 0x8) {
+		/* up when edc_convergedS set */
+		phydev->speed = SPEED_10000;
+		phydev->duplex = DUPLEX_FULL;
+		phydev->link = 1;
+	} else {
+		phydev->link = 0;
+	}
+
+err:
+	return ret;
+}
+
+static int cortina_soft_reset(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int cortina_probe(struct phy_device *phydev)
+{
+	u32 phy_id = 0, id_lsb, id_msb;
+
+	/* Read device id from phy registers. */
+	id_lsb = cortina_read_reg(phydev, VILLA_GLOBAL_CHIP_ID_LSB);
+	if (id_lsb < 0)
+		return -ENXIO;
+
+	phy_id = id_lsb << 16;
+
+	id_msb = cortina_read_reg(phydev, VILLA_GLOBAL_CHIP_ID_MSB);
+	if (id_msb < 0)
+		return -ENXIO;
+
+	phy_id |= id_msb;
+
+	/* Make sure the device tree binding matched the driver with the
+	 * right device.
+	 */
+	if (phy_id != phydev->drv->phy_id) {
+		phydev_err(phydev, "Error matching phy with %s driver\n",
+			   phydev->drv->name);
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static struct phy_driver cortina_driver[] = {
+{
+	.phy_id		= PHY_ID_CS4340,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Cortina CS4340",
+	.config_aneg	= cortina_config_aneg,
+	.read_status	= cortina_read_status,
+	.soft_reset	= cortina_soft_reset,
+	.probe		= cortina_probe,
+},
+};
+
+module_phy_driver(cortina_driver);
+
+static struct mdio_device_id __maybe_unused cortina_tbl[] = {
+	{ PHY_ID_CS4340, 0xffffffff},
+	{},
+};
+
+MODULE_DEVICE_TABLE(mdio, cortina_tbl);
-- 
1.9.1
