From: Juergen Borleis <jbe@pengutronix.de>
Subject: [PATCH v2 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Fri,  7 Apr 2017 10:15:01 +0200
Message-ID: <20170407081502.30172-4-jbe@pengutronix.de>
References: <20170407081502.30172-1-jbe@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
        kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:46871 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754910AbdDGIPO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:15:14 -0400
In-Reply-To: <20170407081502.30172-1-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this mode the switch device and the internal phys will be managed via
I2C interface. The MDIO interface is still supported, but for the
(emulated) CPU port only.

Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
---
 .../devicetree/bindings/net/dsa/lan9303.txt        |  64 ++++++++++++
 drivers/net/dsa/Kconfig                            |  17 ++++
 drivers/net/dsa/Makefile                           |   5 +
 drivers/net/dsa/lan9303_i2c.c                      | 109 +++++++++++++++++++++
 4 files changed, 195 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/lan9303.txt
 create mode 100644 drivers/net/dsa/lan9303_i2c.c

diff --git a/Documentation/devicetree/bindings/net/dsa/lan9303.txt b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
new file mode 100644
index 0000000000000..22f803f3a607d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
@@ -0,0 +1,64 @@
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
+- reset-gpios: GPIO to be used to reset the whole device, always low active
+- reset-duration: reset duration in milliseconds, defaults to 200 ms
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
+		status = "okay";
+
+		fixed-link { /* RMII fixed link to LAN9303 */
+			speed = <100>;
+			full-duplex;
+		};
+	};
+
+	switch: switch@a {
+		compatible = "smsc,lan9303";
+		reg = <0xa>;
+		status = "okay";
+		reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
+		reset-duration = <200>;
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
diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 065984670ff19..73c86a19ae094 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -34,4 +34,21 @@ config NET_DSA_QCA8K
 	  This enables support for the Qualcomm Atheros QCA8K Ethernet
 	  switch chips.
 
+menuconfig NET_DSA_SMSC_LAN9303
+	tristate "SMSC/Microchip LAN9303 3-ports 10/100 ethernet switch"
+	depends on NET_DSA
+	select NET_DSA_TAG_LAN9303
+	---help---
+	  This enables support for the SMSC/Microchip LAN9303 3 port ethernet
+	  switch chips.
+
+config NET_DSA_SMSC_LAN9303_I2C
+	bool "I2C managed mode"
+	depends on NET_DSA_SMSC_LAN9303
+	depends on I2C && OF
+	select REGMAP_I2C
+	---help---
+	  Enable access functions if the SMSC/Microchip LAN9303 is configured
+	  for I2C managed mode.
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index a3c9416322172..2711417c73ef3 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,7 +1,12 @@
+lan9303-objs-y			:= lan9303-core.o
+lan9303-objs-$(CONFIG_NET_DSA_SMSC_LAN9303_I2C) += lan9303_i2c.o
+
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm-sf2.o
 bcm-sf2-objs			:= bcm_sf2.o bcm_sf2_cfp.o
 obj-$(CONFIG_NET_DSA_QCA8K)	+= qca8k.o
+obj-$(CONFIG_NET_DSA_SMSC_LAN9303) += lan9303.o
+lan9303-objs			:= $(lan9303-objs-y)
 
 obj-y				+= b53/
 obj-y				+= mv88e6xxx/
diff --git a/drivers/net/dsa/lan9303_i2c.c b/drivers/net/dsa/lan9303_i2c.c
new file mode 100644
index 0000000000000..d8d0e592ccd8d
--- /dev/null
+++ b/drivers/net/dsa/lan9303_i2c.c
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
