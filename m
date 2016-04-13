From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/8] dsa: Move gpio reset into switch driver
Date: Thu, 14 Apr 2016 01:59:54 +0200
Message-ID: <1460591998-20598-5-git-send-email-andrew@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55173 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106AbcDNAAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:00:34 -0400
In-Reply-To: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resetting the switch is something the driver does, not the framework.
So move the parsing of this property into the driver.

There are no in kernel users of this property, so moving it does not
break anything. There is a board which will make use of this property
making its way into the kernel.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt     |  2 --
 Documentation/devicetree/bindings/net/dsa/marvell.txt | 10 ++++++++++
 drivers/net/dsa/mv88e6xxx.c                           | 14 +++++++++++++-
 drivers/net/dsa/mv88e6xxx.h                           |  7 +++++++
 include/net/dsa.h                                     |  8 --------
 net/dsa/dsa.c                                         | 16 ----------------
 6 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 5fdbbcdf8c4b..9f4807f90c31 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -31,8 +31,6 @@ A switch child node has the following optional property:
 			  switch. Must be set if the switch can not detect
 			  the presence and/or size of a connected EEPROM,
 			  otherwise optional.
-- reset-gpios		: phandle and specifier to a gpio line connected to
-			  reset pin of the switch chip.
 
 A switch may have multiple "port" children nodes
 
diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index 51b7cd9408f2..301416e94513 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -10,12 +10,20 @@ If you need a stable binding, use the old dsa.txt binding.
 Marvell Switches are MDIO devices. The following properties should be
 placed as a child node of an mdio device.
 
+The properties described here are those specific to Marvell devices.
+Additional required and optional properties can be found in dsa2.txt.
+
 Required properties:
 - compatible		: Should be one of "marvell,mv88e6123",
 			  "marvell,mv88e6131", "marvell,mv88e6171",
 			  "marvell,mv88e6352" or "marvell,mv88e6060"
 - reg			: Address on the MII bus for the switch.
 
+Optional properties:
+
+- reset-gpios		: Should be a gpio specifier for a reset line
+
+Optional Properties
 Example:
 
 	mdio {
@@ -25,5 +33,7 @@ Example:
 		switch0: switch@1 {
 			reg = <0>;
 			compatible = "marvell,mv88e6131";
+
+			reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
 		};
 	};
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9e906e0459c7..ef29a94da975 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2830,7 +2830,7 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
-	struct gpio_desc *gpiod = ds->pd->reset;
+	struct gpio_desc *gpiod = ps->reset;
 	unsigned long timeout;
 	int ret;
 	int i;
@@ -3178,6 +3178,7 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
 	struct mv88e6xxx_priv_state *ps;
 	struct dsa_switch *ds;
 	const char *name;
+	int err;
 
 	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
 	if (!ds)
@@ -3199,6 +3200,17 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
 		return -ENODEV;
 	}
 
+	ps->reset = devm_gpiod_get(&mdiodev->dev, "reset", GPIOD_ASIS);
+	err = PTR_ERR(ps->reset);
+	if (err) {
+		if (err == -ENOENT) {
+			/* Optional, so not an error */
+			ps->reset = NULL;
+		} else {
+			return err;
+		}
+	}
+
 	dev_set_drvdata(dev, ds);
 
 	return 0;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 3bdc0fdf692f..739d3ff1bddf 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -12,6 +12,7 @@
 #define __MV88E6XXX_H
 
 #include <linux/if_vlan.h>
+#include <linux/gpio/consumer.h>
 
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
@@ -446,6 +447,12 @@ struct mv88e6xxx_priv_state {
 	DECLARE_BITMAP(port_state_update_mask, DSA_MAX_PORTS);
 
 	struct work_struct bridge_work;
+
+	/* A switch may have a GPIO line tied to its reset pin. Parse
+	 * this from the device tree, and use it before performing
+	 * switch soft reset.
+	 */
+	struct gpio_desc *reset;
 };
 
 enum stat_type {
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 689ebd3542ba..b54a2ed1002c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -16,7 +16,6 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
-#include <linux/of_gpio.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/ethtool.h>
@@ -65,13 +64,6 @@ struct dsa_chip_data {
 	 * NULL if there is only one switch chip.
 	 */
 	s8		*rtable;
-
-	/*
-	 * A switch may have a GPIO line tied to its reset pin. Parse
-	 * this from the device tree, and use it before performing
-	 * switch soft reset.
-	 */
-	struct gpio_desc *reset;
 };
 
 struct dsa_platform_data {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 60ea98481806..1e2238e71ea7 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -660,9 +660,6 @@ static int dsa_of_probe(struct device *dev)
 	const char *port_name;
 	int chip_index, port_index;
 	const unsigned int *sw_addr, *port_reg;
-	int gpio;
-	enum of_gpio_flags of_flags;
-	unsigned long flags;
 	u32 eeprom_len;
 	int ret;
 
@@ -741,19 +738,6 @@ static int dsa_of_probe(struct device *dev)
 			put_device(cd->host_dev);
 			cd->host_dev = &mdio_bus_switch->dev;
 		}
-		gpio = of_get_named_gpio_flags(child, "reset-gpios", 0,
-					       &of_flags);
-		if (gpio_is_valid(gpio)) {
-			flags = (of_flags == OF_GPIO_ACTIVE_LOW ?
-				 GPIOF_ACTIVE_LOW : 0);
-			ret = devm_gpio_request_one(dev, gpio, flags,
-						    "switch_reset");
-			if (ret)
-				goto out_free_chip;
-
-			cd->reset = gpio_to_desc(gpio);
-			gpiod_direction_output(cd->reset, 0);
-		}
 
 		for_each_available_child_of_node(child, port) {
 			port_reg = of_get_property(port, "reg", NULL);
-- 
2.7.0
