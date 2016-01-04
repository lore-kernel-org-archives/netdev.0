From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 12/24] of: phy: Only register a phy device for phys
Date: Mon,  4 Jan 2016 18:36:50 +0100
Message-ID: <1451929022-5580-13-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34967 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752876AbcADRiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:38:10 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon support devices other than phys on the mdio bus. Look at
a child's compatibility string to determine if it is a phy, before
registering a phy device.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/of/of_mdio.c | 37 ++++++++++++++++++++++++++++++-------
 1 file changed, 30 insertions(+), 7 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 25bace4db85a..75a415d7cf8c 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -114,6 +114,31 @@ int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
 }
 EXPORT_SYMBOL(of_mdio_parse_addr);
 
+/*
+ * Return true if the child node is for a phy. It must either:
+ * o Compatible string of "ethernet-phy-idX.X"
+ * o Compatible string of "ethernet-phy-ieee802.3-c45"
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
+	if (!of_find_property(child, "compatible", NULL))
+		return true;
+
+	return false;
+}
+
 /**
  * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
  * @mdio: pointer to mii_bus structure
@@ -145,7 +170,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 	if (rc)
 		return rc;
 
-	/* Loop over the child nodes and register a phy_device for each one */
+	/* Loop over the child nodes and register a phy_device for each phy */
 	for_each_available_child_of_node(np, child) {
 		addr = of_mdio_parse_addr(&mdio->dev, child);
 		if (addr < 0) {
@@ -153,9 +178,8 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 			continue;
 		}
 
-		rc = of_mdiobus_register_phy(mdio, child, addr);
-		if (rc)
-			continue;
+		if (of_mdiobus_child_is_phy(child))
+			of_mdiobus_register_phy(mdio, child, addr);
 	}
 
 	if (!scanphys)
@@ -177,9 +201,8 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
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
