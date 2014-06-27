From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2] net: fix circular dependency in of_mdio code
Date: Sat, 28 Jun 2014 01:23:35 +0200
Message-ID: <1403911415-18690-1-git-send-email-zonque@gmail.com>
Cc: jeffm@suse.com, f.fainelli@gmail.com, netdev@vger.kernel.org,
	Daniel Mack <zonque@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59013 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbaF0XXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:23:44 -0400
Received: by mail-wi0-f178.google.com with SMTP id n15so3545400wiw.5
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 16:23:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev()) introduced a
circular dependency between libphy and of_mdio.

depmod: ERROR: <modroot>/kernel/drivers/net/phy/libphy.ko in
dependency cycle!
depmod: ERROR: <modroot>/kernel/drivers/of/of_mdio.ko in dependency cycle!

The problem is that of_mdio.c references &mdio_bus_type and libphy now
references of_mdiobus_link_phydev.

Fix this by not exporting of_mdiobus_link_phydev() from of_mdio.ko.
Make it a static function in mdio_bus.c instead.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Reported-by: Jeff Mahoney <jeffm@suse.com>
Fixes: 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev())
---
v2: Provide a stub for of_mdiobus_link_phydev() for !CONFIG_OF_MDIO.

 drivers/net/phy/mdio_bus.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/of/of_mdio.c       | 34 ----------------------------------
 include/linux/of_mdio.h    |  8 --------
 3 files changed, 44 insertions(+), 42 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 2e58aa5..4eaadcf 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -187,6 +187,50 @@ struct mii_bus *of_mdio_find_bus(struct device_node *mdio_bus_np)
 	return d ? to_mii_bus(d) : NULL;
 }
 EXPORT_SYMBOL(of_mdio_find_bus);
+
+/* Walk the list of subnodes of a mdio bus and look for a node that matches the
+ * phy's address with its 'reg' property. If found, set the of_node pointer for
+ * the phy. This allows auto-probed pyh devices to be supplied with information
+ * passed in via DT.
+ */
+static void of_mdiobus_link_phydev(struct mii_bus *mdio,
+				   struct phy_device *phydev)
+{
+	struct device *dev = &phydev->dev;
+	struct device_node *child;
+
+	if (dev->of_node || !mdio->dev.of_node)
+		return;
+
+	for_each_available_child_of_node(mdio->dev.of_node, child) {
+		int addr;
+		int ret;
+
+		ret = of_property_read_u32(child, "reg", &addr);
+		if (ret < 0) {
+			dev_err(dev, "%s has invalid PHY address\n",
+				child->full_name);
+			continue;
+		}
+
+		/* A PHY must have a reg property in the range [0-31] */
+		if (addr >= PHY_MAX_ADDR) {
+			dev_err(dev, "%s PHY address %i is too large\n",
+				child->full_name, addr);
+			continue;
+		}
+
+		if (addr == phydev->addr) {
+			dev->of_node = child;
+			return;
+		}
+	}
+}
+#else /* !IS_ENABLED(CONFIG_OF_MDIO) */
+static inline void of_mdiobus_link_phydev(struct mii_bus *mdio,
+					  struct phy_device *phydev)
+{
+}
 #endif
 
 /**
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index fb4a598..38fa57c 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -182,40 +182,6 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 }
 EXPORT_SYMBOL(of_mdiobus_register);
 
-/**
- * of_mdiobus_link_phydev - Find a device node for a phy
- * @mdio: pointer to mii_bus structure
- * @phydev: phydev for which the of_node pointer should be set
- *
- * Walk the list of subnodes of a mdio bus and look for a node that matches the
- * phy's address with its 'reg' property. If found, set the of_node pointer for
- * the phy. This allows auto-probed pyh devices to be supplied with information
- * passed in via DT.
- */
-void of_mdiobus_link_phydev(struct mii_bus *mdio,
-			    struct phy_device *phydev)
-{
-	struct device *dev = &phydev->dev;
-	struct device_node *child;
-
-	if (dev->of_node || !mdio->dev.of_node)
-		return;
-
-	for_each_available_child_of_node(mdio->dev.of_node, child) {
-		int addr;
-
-		addr = of_mdio_parse_addr(&mdio->dev, child);
-		if (addr < 0)
-			continue;
-
-		if (addr == phydev->addr) {
-			dev->of_node = child;
-			return;
-		}
-	}
-}
-EXPORT_SYMBOL(of_mdiobus_link_phydev);
-
 /* Helper function for of_phy_find_device */
 static int of_phy_match(struct device *dev, void *phy_np)
 {
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index a70c949..d449018 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -25,9 +25,6 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 
-extern void of_mdiobus_link_phydev(struct mii_bus *mdio,
-				   struct phy_device *phydev);
-
 #else /* CONFIG_OF */
 static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
@@ -63,11 +60,6 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 {
 	return NULL;
 }
-
-static inline void of_mdiobus_link_phydev(struct mii_bus *mdio,
-					  struct phy_device *phydev)
-{
-}
 #endif /* CONFIG_OF */
 
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
-- 
1.9.3
