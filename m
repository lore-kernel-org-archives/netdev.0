From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/3] net: dsa: Allow multi hop routes to be expressed
Date: Mon, 17 Aug 2015 23:52:50 +0200
Message-ID: <1439848372-4055-2-git-send-email-andrew@lunn.ch>
References: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60894 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbbHQWAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 18:00:37 -0400
In-Reply-To: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With more than two switches in a hierarchy, it becomes necessary to
describe multi-hop routes between switches. The current binding does
not allow this, although the older platform_data did. Extend the link
property to be a list rather than a single phandle to a remote switch.
It is then possible to express that a port should be used to reach
more than one switch and the switch maybe more than one hop away.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt | 33 +++++++++++++++----
 net/dsa/dsa.c                                     | 40 +++++++++++++++++------
 2 files changed, 57 insertions(+), 16 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 9cf9a0ec333c..04e6bef3ac3f 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -44,9 +44,10 @@ Note that a port labelled "dsa" will imply checking for the uplink phandle
 described below.
 
 Optionnal property:
-- link			: Should be a phandle to another switch's DSA port.
+- link			: Should be a list of phandles to another switch's DSA port.
 			  This property is only used when switches are being
-			  chained/cascaded together.
+			  chained/cascaded together. This port is used as outgoing port
+			  towards the phandle port, which can be more than one hop away.
 
 - phy-handle		: Phandle to a PHY on an external MDIO bus, not the
 			  switch internal one. See
@@ -100,10 +101,11 @@ Example:
 				label = "cpu";
 			};
 
-			switch0uplink: port@6 {
+			switch0port6: port@6 {
 				reg = <6>;
 				label = "dsa";
-				link = <&switch1uplink>;
+				link = <&switch1port0
+				        &switch2port0>;
 			};
 		};
 
@@ -113,10 +115,29 @@ Example:
 			reg = <17 1>;	/* MDIO address 17, switch 1 in tree */
 			mii-bus = <&mii_bus1>;
 
-			switch1uplink: port@0 {
+			switch1port0: port@0 {
 				reg = <0>;
 				label = "dsa";
-				link = <&switch0uplink>;
+				link = <&switch0port6>;
+			};
+			switch1port1: port@1 {
+				reg = <1>;
+				label = "dsa";
+				link = <&switch2port1>;
+			};
+		};
+
+		switch@2 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <18 2>;	/* MDIO address 18, switch 2 in tree */
+			mii-bus = <&mii_bus1>;
+
+			switch2port0: port@0 {
+				reg = <0>;
+				label = "dsa";
+				link = <&switch1port1
+				        &switch0port6>;
 			};
 		};
 	};
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 78d4ac97aae3..053eb2b8e682 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -554,6 +554,31 @@ static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
 	return 0;
 }
 
+static int dsa_of_probe_links(struct dsa_platform_data *pd,
+			      struct dsa_chip_data *cd,
+			      int chip_index, int port_index,
+			      struct device_node *port,
+			      const char *port_name)
+{
+	struct device_node *link;
+	int link_index;
+	int ret;
+
+	for (link_index = 0;; link_index++) {
+		link = of_parse_phandle(port, "link", link_index);
+		if (!link)
+			break;
+
+		if (!strcmp(port_name, "dsa") && pd->nr_chips > 1) {
+			ret = dsa_of_setup_routing_table(pd, cd, chip_index,
+							 port_index, link);
+			if (ret)
+				return ret;
+		}
+	}
+	return 0;
+}
+
 static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 {
 	int i;
@@ -573,7 +598,7 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 static int dsa_of_probe(struct device *dev)
 {
 	struct device_node *np = dev->of_node;
-	struct device_node *child, *mdio, *ethernet, *port, *link;
+	struct device_node *child, *mdio, *ethernet, *port;
 	struct mii_bus *mdio_bus, *mdio_bus_switch;
 	struct net_device *ethernet_dev;
 	struct dsa_platform_data *pd;
@@ -668,15 +693,10 @@ static int dsa_of_probe(struct device *dev)
 				goto out_free_chip;
 			}
 
-			link = of_parse_phandle(port, "link", 0);
-
-			if (!strcmp(port_name, "dsa") && link &&
-					pd->nr_chips > 1) {
-				ret = dsa_of_setup_routing_table(pd, cd,
-						chip_index, port_index, link);
-				if (ret)
-					goto out_free_chip;
-			}
+			ret = dsa_of_probe_links(pd, cd, chip_index,
+						 port_index, port, port_name);
+			if (ret)
+				goto out_free_chip;
 
 		}
 	}
-- 
2.5.0
