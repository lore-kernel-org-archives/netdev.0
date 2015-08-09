From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next] dsa: Support multiple MDIO busses
Date: Sun,  9 Aug 2015 03:29:04 +0200
Message-ID: <1439083745-14169-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56401 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992827AbbHIBgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2015 21:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using a cluster of switches, some topologies will have an MDIO
bus per switch, not one for the whole cluster. Allow this to be
represented in the device tree, by adding an optional mii-bus property
at the switch level.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---

v2: Fix documentation, which placed the properties documentation in
    the wrong place.
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |  5 +++++
 net/dsa/dsa.c                                     | 12 +++++++++++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index f0b4cd72411d..fc06f4a7c788 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -32,6 +32,10 @@ A switch child node has the following optional property:
 			  the presence and/or size of a connected EEPROM,
 			  otherwise optional.
 
+- mii-bus		: Should be a phandle to a valid MDIO bus device node.
+			  This mii-bus will be used in preference to the
+			  global dsa,mii-bus defined above, for this switch.
+
 A switch may have multiple "port" children nodes
 
 Each port children node must have the following mandatory properties:
@@ -107,6 +111,7 @@ Example:
 			#address-cells = <1>;
 			#size-cells = <0>;
 			reg = <17 1>;	/* MDIO address 17, switch 1 in tree */
+			mii-bus = <&mii_bus1>;
 
 			switch1uplink: port@0 {
 				reg = <0>;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b445d492c115..78d4ac97aae3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -574,7 +574,7 @@ static int dsa_of_probe(struct device *dev)
 {
 	struct device_node *np = dev->of_node;
 	struct device_node *child, *mdio, *ethernet, *port, *link;
-	struct mii_bus *mdio_bus;
+	struct mii_bus *mdio_bus, *mdio_bus_switch;
 	struct net_device *ethernet_dev;
 	struct dsa_platform_data *pd;
 	struct dsa_chip_data *cd;
@@ -636,6 +636,16 @@ static int dsa_of_probe(struct device *dev)
 		if (!of_property_read_u32(child, "eeprom-length", &eeprom_len))
 			cd->eeprom_len = eeprom_len;
 
+		mdio = of_parse_phandle(child, "mii-bus", 0);
+		if (mdio) {
+			mdio_bus_switch = of_mdio_find_bus(mdio);
+			if (!mdio_bus_switch) {
+				ret = -EPROBE_DEFER;
+				goto out_free_chip;
+			}
+			cd->host_dev = &mdio_bus_switch->dev;
+		}
+
 		for_each_available_child_of_node(child, port) {
 			port_reg = of_get_property(port, "reg", NULL);
 			if (!port_reg)
-- 
2.5.0
