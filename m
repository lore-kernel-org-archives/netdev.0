From: Juergen Borleis <jbe@pengutronix.de>
Subject: [PATCH 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Wed,  5 Apr 2017 11:20:23 +0200
Message-ID: <20170405092024.16048-4-jbe@pengutronix.de>
References: <20170405092024.16048-1-jbe@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
        kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:44173 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933069AbdDEJUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 05:20:41 -0400
In-Reply-To: <20170405092024.16048-1-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this mode the switch device and the internal phys will be managed via
I2C interface. The MDIO interface is still supported, but for the
(emulated) CPU port only.

Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
---
 .../devicetree/bindings/net/dsa/lan9303.txt        |  74 ++++++++++++++
 drivers/net/phy/Kconfig                            |  17 ++++
 drivers/net/phy/Makefile                           |   5 +
 drivers/net/phy/lan9303_i2c.c                      | 109 +++++++++++++++++++++
 4 files changed, 205 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/lan9303.txt
 create mode 100644 drivers/net/phy/lan9303_i2c.c

diff --git a/Documentation/devicetree/bindings/net/dsa/lan9303.txt b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
new file mode 100644
index 0000000000000..2c8a466065a27
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
@@ -0,0 +1,74 @@
+SMSC/MicroChip LAN9303 three port ethernet switch
+-------------------------------------------------
+
+Required properties:
+
+- compatible: should be "smsc,lan9303"
+- #size-cells: must be 0
+- #address-cells: must be 1
+
+Optional properties:
+
+- phy-reset-gpios: GPIO to be used to reset the whole device, always low active
+- phy-reset-duration: reset duration, defaults to 200 ms
+
+Subnodes:
+
+The integrated switch subnode should be specified according to the binding
+described in dsa/dsa.txt. The CPU port of this switch is always port 0.
+
+Example:
+
+I2C managed mode:
+
+	master: masterdevice@X {
+		phy-handle = <&ethphy>;
+		status = "okay";
+
+		mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			ethphy: ethernet-phy@0 {
+				compatible = "ethernet-phy-ieee802.3-c22";
+				reg = <0>;
+				max-speed = <100>;
+			};
+		};
+
+	};
+
+	switch: switch@a {
+		compatible = "smsc,lan9303";
+		reg = <0xa>;
+		status = "okay";
+		interrupts-extended = <&gpio2 7 IRQ_TYPE_LEVEL_LOW>;
+		phy-reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
+		phy-reset-duration = <200>;
+
+		dsa,member = <0 0>;
+
+		ports {
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			port@0 { /* RMII fixed link to master */
+				reg = <0>;
+				label = "cpu";
+				ethernet = <&master>;
+				max-speed = <100>;
+			};
+
+			port@1 { /* external port 1 */
+				compatible = "ethernet-phy-ieee802.3-c22";
+				reg = <1>;
+				label = "lan1;
+			};
+
+			port@2 { /* external port 2 */
+				compatible = "ethernet-phy-ieee802.3-c22";
+				reg = <2>;
+				label = "lan2";
+			};
+		};
+	};
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 8dbd59baa34d5..acbc73adbf8c3 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -345,3 +345,20 @@ endif # PHYLIB
 config MICREL_KS8995MA
 	tristate "Micrel KS8995MA 5-ports 10/100 managed Ethernet switch"
 	depends on SPI
+
+config SMSC_LAN9303
+	tristate "SMSC LAN9303 3-ports 10/100 ethernet switch"
+	depends on NET_DSA
+	select NET_DSA_TAG_LAN9303
+	help
+	  This module provides a driver for SMSC LAN9303 3 port ethernet
+	  switch.
+
+config SMSC_LAN9303_I2C
+	bool "I2C managed mode"
+	depends on SMSC_LAN9303
+	depends on I2C && OF
+	select REGMAP_I2C
+	help
+	  Provide access functions if the SMSC LAN9303 is configured for I2C
+	  managed mode.
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 407b0b601ea82..4313adec2e8b6 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -7,6 +7,10 @@ libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
 
 obj-$(CONFIG_PHYLIB)		+= libphy.o
 
+lan9303-objs-y := lan9303-core.o
+lan9303-objs-$(CONFIG_SMSC_LAN9303_I2C) += lan9303_i2c.o
+lan9303-objs := $(lan9303-objs-y)
+
 obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
@@ -52,6 +56,7 @@ obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
+obj-$(CONFIG_SMSC_LAN9303)	+= lan9303.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
 obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
diff --git a/drivers/net/phy/lan9303_i2c.c b/drivers/net/phy/lan9303_i2c.c
new file mode 100644
index 0000000000000..d8d0e592ccd8d
--- /dev/null
+++ b/drivers/net/phy/lan9303_i2c.c
@@ -0,0 +1,109 @@
+/*
+ * Copyright (C) 2017 Pengutronix, Juergen Borleis <kernel@pengutronix.de>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/i2c.h>
+#include <linux/of.h>
+
+#include "lan9303.h"
+
+struct lan9303_i2c {
+	struct i2c_client *device;
+	struct lan9303 chip;
+};
+
+static const struct regmap_config lan9303_i2c_regmap_config = {
+	.reg_bits = 8,
+	.val_bits = 32,
+	.reg_stride = 1,
+	.can_multi_write = true,
+	.max_register = 0x0ff, /* address bits 0..1 are not used */
+	.reg_format_endian = REGMAP_ENDIAN_LITTLE,
+
+	.volatile_table = &lan9303_register_set,
+	.wr_table = &lan9303_register_set,
+	.rd_table = &lan9303_register_set,
+
+	.cache_type = REGCACHE_NONE,
+};
+
+static int lan9303_i2c_probe(struct i2c_client *client,
+			     const struct i2c_device_id *id)
+{
+	struct lan9303_i2c *sw_dev;
+	int ret;
+
+	sw_dev = devm_kzalloc(&client->dev, sizeof(struct lan9303_i2c),
+			      GFP_KERNEL);
+	if (!sw_dev)
+		return -ENOMEM;
+
+	sw_dev->chip.regmap = devm_regmap_init_i2c(client,
+						&lan9303_i2c_regmap_config);
+	if (IS_ERR(sw_dev->chip.regmap)) {
+		ret = PTR_ERR(sw_dev->chip.regmap);
+		dev_err(&client->dev, "Failed to allocate register map: %d\n",
+			ret);
+		return ret;
+	}
+
+	/* link forward and backward */
+	sw_dev->device = client;
+	i2c_set_clientdata(client, sw_dev);
+	sw_dev->chip.dev = &client->dev;
+
+	ret = lan9303_probe(&sw_dev->chip, client->dev.of_node);
+	if (ret != 0)
+		return ret;
+
+	dev_info(&client->dev, "LAN9303 I2C driver loaded successfully\n");
+
+	return 0;
+}
+
+static int lan9303_i2c_remove(struct i2c_client *client)
+{
+	struct lan9303_i2c *sw_dev;
+
+	sw_dev = i2c_get_clientdata(client);
+	if (!sw_dev)
+		return -ENODEV;
+
+	return lan9303_remove(&sw_dev->chip);
+}
+
+/*-------------------------------------------------------------------------*/
+
+static const struct i2c_device_id lan9303_i2c_id[] = {
+	{ "lan9303", 0 },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(i2c, lan9303_i2c_id);
+
+static const struct of_device_id lan9303_i2c_of_match[] = {
+	{ .compatible = "smsc,lan9303", },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, lan9303_i2c_of_match);
+
+static struct i2c_driver lan9303_i2c_driver = {
+	.driver = {
+		.name = "LAN9303_I2C",
+		.of_match_table = of_match_ptr(lan9303_i2c_of_match),
+	},
+	.probe = lan9303_i2c_probe,
+	.remove = lan9303_i2c_remove,
+	.id_table = lan9303_i2c_id,
+};
+module_i2c_driver(lan9303_i2c_driver);
-- 
2.11.0
