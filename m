From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 12/22] of: phy: Only register a phy device for phys
Date: Wed,  6 Jan 2016 20:11:17 +0100
Message-ID: <1452107487-475-13-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42321 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbcAFTMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:12:20 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon support devices other than phys on the mdio bus. Look at
a child's compatibility string to determine if it is a phy, before
registering a phy device.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Also accept "ethernet-phy-ieee802.3-c22" as indicating a PHY.
---
 drivers/of/of_mdio.c | 41 ++++++++++++++++++++++++++++++++++-------
 1 file changed, 34 insertions(+), 7 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index bc9d76329435..c0292051392e 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -114,6 +114,35 @@ int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
 }
 EXPORT_SYMBOL(of_mdio_parse_addr);
 
+/*
+ * Return true if the child node is for a phy. It must either:
+ * o Compatible string of "ethernet-phy-idX.X"
+ * o Compatible string of "ethernet-phy-ieee802.3-c45"
+ * o Compatible string of "ethernet-phy-ieee802.3-c22"
+ * o No compatibility string
+ *
+ * A device which is not a phy is expected to have a compatible string
+ * indicating what sort of device it is.
+ */
+static bool of_mdiobus_child_is_phy(struct device_node *child)
+{
+	u32 phy_id;
+
+	if (of_get_phy_id(child, &phy_id) != -EINVAL)
+		return true;
+
+	if (of_device_is_compatible(child, "ethernet-phy-ieee802.3-c45"))
+		return true;
+
+	if (of_device_is_compatible(child, "ethernet-phy-ieee802.3-c22"))
+		return true;
+
+	if (!of_find_property(child, "compatible", NULL))
+		return true;
+
+	return false;
+}
+
 /**
  * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
  * @mdio: pointer to mii_bus structure
@@ -140,7 +169,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 	if (rc)
 		return rc;
 
-	/* Loop over the child nodes and register a phy_device for each one */
+	/* Loop over the child nodes and register a phy_device for each phy */
 	for_each_available_child_of_node(np, child) {
 		addr = of_mdio_parse_addr(&mdio->dev, child);
 		if (addr < 0) {
@@ -148,9 +177,8 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 			continue;
 		}
 
-		rc = of_mdiobus_register_phy(mdio, child, addr);
-		if (rc)
-			continue;
+		if (of_mdiobus_child_is_phy(child))
+			of_mdiobus_register_phy(mdio, child, addr);
 	}
 
 	if (!scanphys)
@@ -172,9 +200,8 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 			dev_info(&mdio->dev, "scan phy %s at address %i\n",
 				 child->name, addr);
 
-			rc = of_mdiobus_register_phy(mdio, child, addr);
-			if (rc)
-				continue;
+			if (of_mdiobus_child_is_phy(child))
+				of_mdiobus_register_phy(mdio, child, addr);
 		}
 	}
 
-- 
2.6.4
