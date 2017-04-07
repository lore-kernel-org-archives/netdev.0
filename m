From: Juergen Borleis <jbe@pengutronix.de>
Subject: [PATCH v2 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Fri,  7 Apr 2017 10:15:02 +0200
Message-ID: <20170407081502.30172-5-jbe@pengutronix.de>
References: <20170407081502.30172-1-jbe@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
        kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:38885 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754895AbdDGIPO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:15:14 -0400
In-Reply-To: <20170407081502.30172-1-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the LAN9303 device is in MDIO manged mode, all register accesses must
be done via MDIO.

Please note: this code is *untested* yet due to the absence of such
configured hardware. It is based on a patch of Stefan Roese from 2014.

Signed-off-by: Juergen Borleis <jbe@pengutronix.de>
---
 .../devicetree/bindings/net/dsa/lan9303.txt        |   4 +
 drivers/net/dsa/Kconfig                            |   8 ++
 drivers/net/dsa/Makefile                           |   1 +
 drivers/net/dsa/lan9303_mdio.c                     | 144 +++++++++++++++++++++
 4 files changed, 157 insertions(+)
 create mode 100644 drivers/net/dsa/lan9303_mdio.c

diff --git a/Documentation/devicetree/bindings/net/dsa/lan9303.txt b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
index 22f803f3a607d..d0f08a300433b 100644
--- a/Documentation/devicetree/bindings/net/dsa/lan9303.txt
+++ b/Documentation/devicetree/bindings/net/dsa/lan9303.txt
@@ -62,3 +62,7 @@ I2C managed mode:
 			};
 		};
 	};
+
+MDIO managed mode:
+
+	*TODO*
diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 73c86a19ae094..a4d0ba43b0781 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -51,4 +51,12 @@ config NET_DSA_SMSC_LAN9303_I2C
 	  Enable access functions if the SMSC/Microchip LAN9303 is configured
 	  for I2C managed mode.
 
+config NET_DSA_SMSC_LAN9303_MDIO
+	bool "MDIO managed mode"
+	depends on NET_DSA_SMSC_LAN9303
+	depends on OF_MDIO
+	---help---
+	  Enable access functions if the SMSC/Microchip LAN9303 is configured
+	  for MDIO managed mode.
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index 2711417c73ef3..6ccb8899f3082 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,5 +1,6 @@
 lan9303-objs-y			:= lan9303-core.o
 lan9303-objs-$(CONFIG_NET_DSA_SMSC_LAN9303_I2C) += lan9303_i2c.o
+lan9303-objs-$(CONFIG_NET_DSA_SMSC_LAN9303_MDIO) += lan9303_mdio.o
 
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm-sf2.o
diff --git a/drivers/net/dsa/lan9303_mdio.c b/drivers/net/dsa/lan9303_mdio.c
new file mode 100644
index 0000000000000..8230b4e215f42
--- /dev/null
+++ b/drivers/net/dsa/lan9303_mdio.c
@@ -0,0 +1,144 @@
+/*
+ * Copyright (C) 2017 Pengutronix, Juergen Borleis <kernel@pengutronix.de>
+ *
+ * Partially based on a patch from
+ * Copyright (c) 2014 Stefan Roese <sr@denx.de>
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
+#include <linux/mdio.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+
+#include "lan9303.h"
+
+/* Generate phy-addr and -reg from the input address */
+#define PHY_ADDR(x) ((((x) >> 6) + 0x10) & 0x1f)
+#define PHY_REG(x) (((x) >> 1) & 0x1f)
+
+struct lan9303_mdio {
+	struct mdio_device *device;
+	struct lan9303 chip;
+};
+
+static void lan9303_mdio_real_write(struct mdio_device *mdio, int reg, u16 val)
+{
+	mdio->bus->write(mdio->bus, PHY_ADDR(reg), PHY_REG(reg), val);
+}
+
+static int lan9303_mdio_write(void *ctx, uint32_t reg, uint32_t val)
+{
+	struct lan9303_mdio *sw_dev = (struct lan9303_mdio *)ctx;
+
+	mutex_lock(&sw_dev->device->bus->mdio_lock);
+	lan9303_mdio_real_write(sw_dev->device, reg, val & 0xffff);
+	lan9303_mdio_real_write(sw_dev->device, reg + 2, (val >> 16) & 0xffff);
+	mutex_unlock(&sw_dev->device->bus->mdio_lock);
+
+	return 0;
+}
+
+static u16 lan9303_mdio_real_read(struct mdio_device *mdio, int reg)
+{
+	return mdio->bus->read(mdio->bus, PHY_ADDR(reg), PHY_REG(reg));
+}
+
+static int lan9303_mdio_read(void *ctx, uint32_t reg, uint32_t *val)
+{
+	struct lan9303_mdio *sw_dev = (struct lan9303_mdio *)ctx;
+
+	mutex_lock(&sw_dev->device->bus->mdio_lock);
+	*val = lan9303_mdio_real_read(sw_dev->device, reg);
+	*val |= (lan9303_mdio_real_read(sw_dev->device, reg + 2) << 16);
+	mutex_unlock(&sw_dev->device->bus->mdio_lock);
+
+	return 0;
+}
+
+static const struct regmap_config lan9303_mdio_regmap_config = {
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
+	.reg_read = lan9303_mdio_read,
+	.reg_write = lan9303_mdio_write,
+
+	.cache_type = REGCACHE_NONE,
+};
+
+static int lan9303_mdio_probe(struct mdio_device *mdiodev)
+{
+	struct lan9303_mdio *sw_dev;
+	int ret;
+
+	sw_dev = devm_kzalloc(&mdiodev->dev, sizeof(struct lan9303_mdio),
+			      GFP_KERNEL);
+	if (!sw_dev)
+		return -ENOMEM;
+
+	sw_dev->chip.regmap = devm_regmap_init(&mdiodev->dev, NULL, sw_dev,
+						&lan9303_mdio_regmap_config);
+	if (IS_ERR(sw_dev->chip.regmap)) {
+		ret = PTR_ERR(sw_dev->chip.regmap);
+		dev_err(&mdiodev->dev, "regmap init failed: %d\n", ret);
+		return ret;
+	}
+
+	/* link forward and backward */
+	sw_dev->device = mdiodev;
+	dev_set_drvdata(&mdiodev->dev, sw_dev);
+	sw_dev->chip.dev = &mdiodev->dev;
+
+	ret = lan9303_probe(&sw_dev->chip, mdiodev->dev.of_node);
+	if (ret != 0)
+		return ret;
+
+	dev_info(&mdiodev->dev, "LAN9303 MDIO driver loaded successfully\n");
+
+	return 0;
+}
+
+static void lan9303_mdio_remove(struct mdio_device *mdiodev)
+{
+	struct lan9303_mdio *sw_dev = dev_get_drvdata(&mdiodev->dev);
+
+	if (!sw_dev)
+		return;
+
+	lan9303_remove(&sw_dev->chip);
+}
+
+/*-------------------------------------------------------------------------*/
+
+static const struct of_device_id lan9303_mdio_of_match[] = {
+	{ .compatible = "smsc,lan9303" },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, lan9303_mdio_of_match);
+
+static struct mdio_driver lan9303_mdio_driver = {
+	.mdiodrv.driver = {
+		.name = "LAN9303_MDIO",
+		.of_match_table = of_match_ptr(lan9303_mdio_of_match),
+	},
+	.probe  = lan9303_mdio_probe,
+	.remove = lan9303_mdio_remove,
+};
+mdio_module_driver(lan9303_mdio_driver);
-- 
2.11.0
