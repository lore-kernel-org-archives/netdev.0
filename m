From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 19/22] mdio_bus: Generalise of_mdiobus_link_phydev()
Date: Wed,  6 Jan 2016 20:11:24 +0100
Message-ID: <1452107487-475-20-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42327 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbcAFTM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:12:27 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function should work with any sort of MDIO device which can be
probed on the bus, not just PHY devices. So generalise it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index bd523b2c6331..0d369ad19d17 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -237,15 +237,16 @@ struct mii_bus *of_mdio_find_bus(struct device_node *mdio_bus_np)
 }
 EXPORT_SYMBOL(of_mdio_find_bus);
 
-/* Walk the list of subnodes of a mdio bus and look for a node that matches the
- * phy's address with its 'reg' property. If found, set the of_node pointer for
- * the phy. This allows auto-probed pyh devices to be supplied with information
- * passed in via DT.
+/* Walk the list of subnodes of a mdio bus and look for a node that
+ * matches the mdio device's address with its 'reg' property. If
+ * found, set the of_node pointer for the mdio device. This allows
+ * auto-probed phy devices to be supplied with information passed in
+ * via DT.
  */
-static void of_mdiobus_link_phydev(struct mii_bus *bus,
-				   struct phy_device *phydev)
+static void of_mdiobus_link_mdiodev(struct mii_bus *bus,
+				    struct mdio_device *mdiodev)
 {
-	struct device *dev = &phydev->mdio.dev;
+	struct device *dev = &mdiodev->dev;
 	struct device_node *child;
 
 	if (dev->of_node || !bus->dev.of_node)
@@ -257,27 +258,27 @@ static void of_mdiobus_link_phydev(struct mii_bus *bus,
 
 		ret = of_property_read_u32(child, "reg", &addr);
 		if (ret < 0) {
-			dev_err(dev, "%s has invalid PHY address\n",
+			dev_err(dev, "%s has invalid MDIO address\n",
 				child->full_name);
 			continue;
 		}
 
-		/* A PHY must have a reg property in the range [0-31] */
+		/* A MDIO device must have a reg property in the range [0-31] */
 		if (addr >= PHY_MAX_ADDR) {
-			dev_err(dev, "%s PHY address %i is too large\n",
+			dev_err(dev, "%s MDIO address %i is too large\n",
 				child->full_name, addr);
 			continue;
 		}
 
-		if (addr == phydev->mdio.addr) {
+		if (addr == mdiodev->addr) {
 			dev->of_node = child;
 			return;
 		}
 	}
 }
 #else /* !IS_ENABLED(CONFIG_OF_MDIO) */
-static inline void of_mdiobus_link_phydev(struct mii_bus *mdio,
-					  struct phy_device *phydev)
+static inline void of_mdiobus_link_mdiodev(struct mii_bus *mdio,
+					   struct mdio_device *mdiodev)
 {
 }
 #endif
@@ -406,7 +407,7 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 	 * For DT, see if the auto-probed phy has a correspoding child
 	 * in the bus node, and set the of_node pointer in this case.
 	 */
-	of_mdiobus_link_phydev(bus, phydev);
+	of_mdiobus_link_mdiodev(bus, &phydev->mdio);
 
 	err = phy_device_register(phydev);
 	if (err) {
-- 
2.6.4
