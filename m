From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 13/32] net: dsa: Make dsa,mii-bus optional
Date: Sun, 28 Feb 2016 17:41:21 +0100
Message-ID: <1456677700-23027-14-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44935 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758779AbcB1QmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:24 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When all the switches are devices and register to the DSA framework,
having a dsa,mii-bus property is not required.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |  3 +-
 net/dsa/dsa.c                                     | 36 +++++++++++++----------
 2 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index f99e5694a61f..625b2e5d8ae2 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -8,11 +8,12 @@ Required properties:
 			  Second cell is used only when cascading/chaining.
 - #size-cells		: Must be 0
 - dsa,ethernet		: Should be a phandle to a valid Ethernet device node
-- dsa,mii-bus		: Should be a phandle to a valid MDIO bus device node
 
 Optional properties:
 - interrupts		: property with a value describing the switch
 			  interrupt number (not supported by the driver)
+- dsa,mii-bus		: Should be a phandle to a valid MDIO bus device node.
+			  Required when not all switches are devices.
 
 A DSA node can contain multiple switch chips which are therefore child nodes of
 the parent DSA node. The maximum number of allowed child nodes is 4
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 73a3fd561ef3..fb6d390503e1 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -662,8 +662,8 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 {
 	struct device_node *np = dev->of_node;
-	struct device_node *child, *chip, *mdio, *ethernet, *port;
-	struct mii_bus *mdio_bus, *mdio_bus_switch;
+	struct device_node *child, *chip, *mdio, *switch_mdio, *ethernet, *port;
+	struct mii_bus *mdio_bus = NULL, *mdio_bus_switch;
 	struct net_device *ethernet_dev;
 	struct dsa_chip_data *cd;
 	const char *port_name;
@@ -676,12 +676,6 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 	int ret = 0;
 
 	mdio = of_parse_phandle(np, "dsa,mii-bus", 0);
-	if (!mdio)
-		return -EINVAL;
-
-	mdio_bus = of_mdio_find_bus(mdio);
-	if (!mdio_bus)
-		return -EPROBE_DEFER;
 
 	ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
 	if (!ethernet) {
@@ -713,11 +707,22 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 		cd->of_node = child;
 
 		chip = of_parse_phandle(child, "switch", 0);
-		if (chip)
+		if (chip) {
 			cd->of_chip = chip;
+		} else {
+			if (!mdio)
+				return -EINVAL;
 
-		/* When assigning the host device, increment its refcount */
-		cd->host_dev = get_device(&mdio_bus->dev);
+			mdio_bus = of_mdio_find_bus(mdio);
+			if (!mdio_bus)
+				return -EPROBE_DEFER;
+
+			/*
+			 * When assigning the host device, increment
+			 * its refcount
+			 */
+			cd->host_dev = get_device(&mdio_bus->dev);
+		}
 
 		sw_addr = of_get_property(child, "reg", NULL);
 		if (!sw_addr)
@@ -730,9 +735,9 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 		if (!of_property_read_u32(child, "eeprom-length", &eeprom_len))
 			cd->eeprom_len = eeprom_len;
 
-		mdio = of_parse_phandle(child, "mii-bus", 0);
-		if (mdio) {
-			mdio_bus_switch = of_mdio_find_bus(mdio);
+		switch_mdio = of_parse_phandle(child, "mii-bus", 0);
+		if (switch_mdio) {
+			mdio_bus_switch = of_mdio_find_bus(switch_mdio);
 			if (!mdio_bus_switch) {
 				ret = -EPROBE_DEFER;
 				goto out_free_chip;
@@ -791,7 +796,8 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 
 	/* The individual chips hold their own refcount on the mdio bus,
 	 * so drop ours */
-	put_device(&mdio_bus->dev);
+	if (mdio_bus)
+		put_device(&mdio_bus->dev);
 
 	return 0;
 
-- 
2.7.0
