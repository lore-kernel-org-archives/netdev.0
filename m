From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: [PATCH 2/2] drivers: phy: Add Cortina CS4340 driver
Date: Tue, 23 May 2017 15:53:19 +0000
Message-ID: <1495554799-23060-3-git-send-email-bogdan.purcareata@nxp.com>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0043.outbound.protection.outlook.com ([104.47.32.43]:8320
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S968469AbdEWPx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 11:53:26 -0400
In-Reply-To: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add basic support for Cortina PHY drivers. Support only CS4340 for now.
The phys are not fully compatible with IEEE 802.3 clause 45 registers.
Implement proper read_status support, so that phy polling does not cause
bus register access errors.

Signed-off-by: Bogdan Purcareata <bogdan.purcareata@nxp.com>
---
 drivers/net/phy/Kconfig        |  5 +++
 drivers/net/phy/Makefile       |  1 +
 drivers/net/phy/mdio-cortina.c | 90 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 96 insertions(+)
 create mode 100644 drivers/net/phy/mdio-cortina.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 60ffc9d..1d2aeb4 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -82,6 +82,11 @@ config MDIO_BUS_MUX_MMIOREG
 config MDIO_CAVIUM
 	tristate
 
+config MDIO_CORTINA
+	tristate "Driver for Cortina quad-10G Ethernet PHY"
+	---help---
+	  Currently only supports the Cortina CS4340 PHY.
+
 config MDIO_GPIO
 	tristate "GPIO lib-based bitbanged MDIO buses"
 	depends on MDIO_BITBANG && GPIOLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e36db9a..c82754f 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_MDIO_BUS_MUX_BCM_IPROC)	+= mdio-mux-bcm-iproc.o
 obj-$(CONFIG_MDIO_BUS_MUX_GPIO)	+= mdio-mux-gpio.o
 obj-$(CONFIG_MDIO_BUS_MUX_MMIOREG) += mdio-mux-mmioreg.o
 obj-$(CONFIG_MDIO_CAVIUM)	+= mdio-cavium.o
+obj-$(CONFIG_MDIO_CORTINA)	+= mdio-cortina.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
 obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
diff --git a/drivers/net/phy/mdio-cortina.c b/drivers/net/phy/mdio-cortina.c
new file mode 100644
index 0000000..2a5c234
--- /dev/null
+++ b/drivers/net/phy/mdio-cortina.c
@@ -0,0 +1,90 @@
+/*
+ *    Based on code from Cortina Systems, Inc.
+ *
+ *    Copyright (C) 2011 Cortina Systems, Inc.
+ *    Copyright (C) 2017 NXP
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
+#define CORTINA_GPIO_GPIO_INTS				0x16D
+
+static int cortina_read_x(struct phy_device *phydev, int off, u16 regnum)
+{
+	return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr + off,
+			    MII_ADDR_C45 | regnum);
+}
+
+static int cortina_read(struct phy_device *phydev, u16 regnum)
+{
+	return cortina_read_x(phydev, 0, regnum);
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
+	int gpio_int_status;
+	int ret = 0;
+
+	gpio_int_status = cortina_read(phydev, CORTINA_GPIO_GPIO_INTS);
+	if (gpio_int_status < 0) {
+		ret = gpio_int_status;
+		goto err;
+	}
+
+	if (gpio_int_status & 0x8) {
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
+static struct phy_driver cortina_driver[] = {
+{
+	.phy_id         = PHY_ID_CS4340,
+	.phy_id_mask    = 0xffffffff,
+	.name           = "Cortina CS4340",
+	.config_aneg    = cortina_config_aneg,
+	.read_status    = cortina_read_status,
+	.soft_reset     = cortina_soft_reset,
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
