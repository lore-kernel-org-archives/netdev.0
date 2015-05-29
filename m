From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 1/3] net: dsa: Refactor DT probing of a switch port
Date: Fri, 29 May 2015 21:13:32 +0200
Message-ID: <1432926814-22648-2-git-send-email-andrew@lunn.ch>
References: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48109 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882AbbE2TSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 15:18:55 -0400
In-Reply-To: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the DT probing of a switch port into a function of its own, since
it is about to get more complex. Add better error handling as well.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 77 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 44 insertions(+), 33 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index e6f6cc3a1bcf..b7b72d398d00 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -570,17 +570,54 @@ static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
 	kfree(pd->chip);
 }
 
+static int dsa_of_probe_port(struct dsa_platform_data *pd,
+			     struct dsa_chip_data *cd,
+			     int chip_index,
+			     struct device_node *port)
+{
+	const unsigned int *port_reg;
+	const char *port_name;
+	struct device_node *link;
+	int port_index, ret;
+
+	port_reg = of_get_property(port, "reg", NULL);
+	if (!port_reg)
+		return -EINVAL;
+
+	port_index = be32_to_cpup(port_reg);
+
+	port_name = of_get_property(port, "label", NULL);
+	if (!port_name)
+		return -EINVAL;
+
+	cd->port_dn[port_index] = port;
+
+	cd->port_names[port_index] = kstrdup(port_name, GFP_KERNEL);
+	if (!cd->port_names[port_index])
+		return -ENOMEM;
+
+	link = of_parse_phandle(port, "link", 0);
+
+	if (!strcmp(port_name, "dsa") && link && pd->nr_chips > 1) {
+		ret = dsa_of_setup_routing_table(pd, cd,
+						 chip_index, port_index, link);
+		if (ret)
+			return ret;
+	}
+
+	return port_index;
+}
+
 static int dsa_of_probe(struct device *dev)
 {
 	struct device_node *np = dev->of_node;
-	struct device_node *child, *mdio, *ethernet, *port, *link;
+	struct device_node *child, *mdio, *ethernet, *port;
 	struct mii_bus *mdio_bus;
 	struct net_device *ethernet_dev;
 	struct dsa_platform_data *pd;
 	struct dsa_chip_data *cd;
-	const char *port_name;
-	int chip_index, port_index;
-	const unsigned int *sw_addr, *port_reg;
+	int chip_index;
+	const unsigned int *sw_addr;
 	u32 eeprom_len;
 	int ret;
 
@@ -637,36 +674,10 @@ static int dsa_of_probe(struct device *dev)
 			cd->eeprom_len = eeprom_len;
 
 		for_each_available_child_of_node(child, port) {
-			port_reg = of_get_property(port, "reg", NULL);
-			if (!port_reg)
-				continue;
-
-			port_index = be32_to_cpup(port_reg);
-
-			port_name = of_get_property(port, "label", NULL);
-			if (!port_name)
-				continue;
-
-			cd->port_dn[port_index] = port;
-
-			cd->port_names[port_index] = kstrdup(port_name,
-					GFP_KERNEL);
-			if (!cd->port_names[port_index]) {
-				ret = -ENOMEM;
+			ret = dsa_of_probe_port(pd, cd, chip_index, port);
+			if (ret < 0)
 				goto out_free_chip;
-			}
-
-			link = of_parse_phandle(port, "link", 0);
-
-			if (!strcmp(port_name, "dsa") && link &&
-					pd->nr_chips > 1) {
-				ret = dsa_of_setup_routing_table(pd, cd,
-						chip_index, port_index, link);
-				if (ret)
-					goto out_free_chip;
-			}
-
-			if (port_index == DSA_MAX_PORTS)
+			if (ret == DSA_MAX_PORTS)
 				break;
 		}
 	}
-- 
2.1.4
