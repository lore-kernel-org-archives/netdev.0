From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 12/28] net: dsa: Make dsa,mii-bus optional
Date: Wed, 23 Dec 2015 13:56:26 +0100
Message-ID: <1450875402-20740-13-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48770 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757193AbbLWM63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:29 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When all the switches are devices and register to the DSA framework,
having a dsa,mii-bus property is not required.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |  3 ++-
 net/dsa/dsa.c                                     | 26 +++++++++++++----------
 2 files changed, 17 insertions(+), 12 deletions(-)

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
index 8b89eece6b52..eca487dcc9fe 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -656,7 +656,7 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 {
 	struct device_node *np = dev->of_node;
 	struct device_node *child, *chip, *mdio, *ethernet, *port;
-	struct mii_bus *mdio_bus, *mdio_bus_switch;
+	struct mii_bus *mdio_bus = NULL, *mdio_bus_switch;
 	struct net_device *ethernet_dev;
 	struct dsa_chip_data *cd;
 	const char *port_name;
@@ -669,12 +669,6 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
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
@@ -706,11 +700,20 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 		cd->of_node = child;
 
 		chip = of_parse_phandle(child, "switch", 0);
-		if (chip)
+		if (chip) {
 			cd->of_chip = chip;
+		} else {
+			if (!mdio)
+				return -EINVAL;
+
+			mdio_bus = of_mdio_find_bus(mdio);
+			if (!mdio_bus)
+				return -EPROBE_DEFER;
 
-		/* When assigning the host device, increment its refcount */
-		cd->host_dev = get_device(&mdio_bus->dev);
+			/* When assigning the host device, increment
+			 * its refcount */
+			cd->host_dev = get_device(&mdio_bus->dev);
+		}
 
 		sw_addr = of_get_property(child, "reg", NULL);
 		if (!sw_addr)
@@ -784,7 +787,8 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 
 	/* The individual chips hold their own refcount on the mdio bus,
 	 * so drop ours */
-	put_device(&mdio_bus->dev);
+	if (mdio_bus)
+		put_device(&mdio_bus->dev);
 
 	return 0;
 
-- 
2.6.3
