From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 10/28] net: dsa: Keep a reference to the switch device for component matching
Date: Wed, 23 Dec 2015 13:56:24 +0100
Message-ID: <1450875402-20740-11-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48749 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbbLWM6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:13 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch devices are component slaves. Such devices have a "switch"
property in the DSA device tree which is a phandle to the switch
device. When the slaves bind they register to DSA. So the DSA can
match the switch to the correct switch instance in the device tree,
keep a reference to the device tree node during parsing of the device
tree.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt | 2 ++
 include/net/dsa.h                                 | 3 +++
 net/dsa/dsa.c                                     | 6 +++++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 5fdbbcdf8c4b..f99e5694a61f 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -27,6 +27,8 @@ Each of these switch child nodes should have the following required properties:
 
 A switch child node has the following optional property:
 
+- switch		: A phandle to a switch device.
+
 - eeprom-length		: Set to the length of an EEPROM connected to the
 			  switch. Must be set if the switch can not detect
 			  the presence and/or size of a connected EEPROM,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index f6b8001a500f..ea4cfdf1b549 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -48,6 +48,9 @@ struct dsa_chip_data {
 	 */
 	struct device_node *of_node;
 
+	/* Device tree node pointer for the switch chip device. */
+	struct device_node *of_chip;
+
 	/*
 	 * The names of the switch's ports.  Use "cpu" to
 	 * designate the switch port that the cpu is connected to,
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 2558c11f73ce..be8e181f161b 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -655,7 +655,7 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 {
 	struct device_node *np = dev->of_node;
-	struct device_node *child, *mdio, *ethernet, *port;
+	struct device_node *child, *chip, *mdio, *ethernet, *port;
 	struct mii_bus *mdio_bus, *mdio_bus_switch;
 	struct net_device *ethernet_dev;
 	struct dsa_chip_data *cd;
@@ -705,6 +705,10 @@ static int dsa_of_probe(struct device *dev, struct dsa_platform_data *pd)
 
 		cd->of_node = child;
 
+		chip = of_parse_phandle(child, "switch", 0);
+		if (chip)
+			cd->of_chip = chip;
+
 		/* When assigning the host device, increment its refcount */
 		cd->host_dev = get_device(&mdio_bus->dev);
 
-- 
2.6.3
