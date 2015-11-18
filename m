From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: dsa: Add support for a switch reset gpio
Date: Thu, 19 Nov 2015 00:29:24 +0100
Message-ID: <1447889365-25256-2-git-send-email-andrew@lunn.ch>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36887 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757337AbbKRX3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 18:29:38 -0500
In-Reply-To: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some boards have a gpio line tied to the switch reset pin. Allow this
gpio to be retrieved from the device tree, and take the switch out of
reset before performing the probe.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |  3 +++
 include/net/dsa.h                                 |  9 +++++++++
 net/dsa/dsa.c                                     | 19 +++++++++++++++++++
 3 files changed, 31 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 04e6bef3ac3f..5fdbbcdf8c4b 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -31,6 +31,8 @@ A switch child node has the following optional property:
 			  switch. Must be set if the switch can not detect
 			  the presence and/or size of a connected EEPROM,
 			  otherwise optional.
+- reset-gpios		: phandle and specifier to a gpio line connected to
+			  reset pin of the switch chip.
 
 A switch may have multiple "port" children nodes
 
@@ -114,6 +116,7 @@ Example:
 			#size-cells = <0>;
 			reg = <17 1>;	/* MDIO address 17, switch 1 in tree */
 			mii-bus = <&mii_bus1>;
+			reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
 
 			switch1port0: port@0 {
 				reg = <0>;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 82a4c6011173..913a61ea81d3 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -16,6 +16,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
+#include <linux/of_gpio.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/ethtool.h>
@@ -64,6 +65,14 @@ struct dsa_chip_data {
 	 * NULL if there is only one switch chip.
 	 */
 	s8		*rtable;
+
+	/*
+	 * A switch may have a GPIO line tied to its reset pin. Parse
+	 * this from the device tree, and use it before performing
+	 * switch soft reset.
+	 */
+	int reset;
+	enum of_gpio_flags reset_flags;
 };
 
 struct dsa_platform_data {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 1eba07feb34a..39cd19eaaf4e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -21,6 +21,8 @@
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 #include <linux/of_net.h>
+#include <linux/nvmem-consumer.h>
+#include <linux/of_gpio.h>
 #include <linux/sysfs.h>
 #include <linux/phy_fixed.h>
 #include "dsa_priv.h"
@@ -688,6 +690,9 @@ static int dsa_of_probe(struct device *dev)
 	const char *port_name;
 	int chip_index, port_index;
 	const unsigned int *sw_addr, *port_reg;
+	int gpio;
+	enum of_gpio_flags flags;
+	int off;
 	u32 eeprom_len;
 	int ret;
 
@@ -767,6 +772,20 @@ static int dsa_of_probe(struct device *dev)
 			cd->host_dev = &mdio_bus_switch->dev;
 		}
 
+		gpio = of_get_named_gpio_flags(child, "reset-gpios", 0,
+					       &flags);
+		if (gpio_is_valid(gpio)) {
+			ret = devm_gpio_request_one(dev, gpio, flags,
+						    "switch_reset");
+			if (ret)
+				goto out_free_chip;
+
+			cd->reset = gpio;
+			cd->reset_flags = flags;
+			off = (flags && OF_GPIO_ACTIVE_LOW ? 1 : 0);
+			gpio_direction_output(cd->reset, off);
+		}
+
 		for_each_available_child_of_node(child, port) {
 			port_reg = of_get_property(port, "reg", NULL);
 			if (!port_reg)
-- 
2.6.2
