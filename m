From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2 2/3] net: of_mdio: add of_mdiobus_link_phydev()
Date: Sat, 24 May 2014 09:34:26 +0200
Message-ID: <1400916867-24573-3-git-send-email-zonque@gmail.com>
References: <1400916867-24573-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com, Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:50470 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbaEXHeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 03:34:44 -0400
Received: by mail-wi0-f180.google.com with SMTP id hi2so1907784wib.1
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 00:34:42 -0700 (PDT)
In-Reply-To: <1400916867-24573-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function to walk the list of subnodes of a mdio bus and look for
a node that matches the phy's address with its 'reg' property. If found,
set the of_node pointer for the phy. This allows auto-probed pyh
devices to be augmented by information passed in via DT.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c |  6 ++++++
 drivers/of/of_mdio.c       | 33 +++++++++++++++++++++++++++++++++
 include/linux/of_mdio.h    |  8 ++++++++
 3 files changed, 47 insertions(+)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 76f54b3..e1444b2 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -233,6 +233,12 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 	if (IS_ERR(phydev) || phydev == NULL)
 		return phydev;
 
+	/*
+	 * For DT, see if the auto-probed phy has a correspoding child
+	 * in the bus node, and set the of_node pointer in this case.
+	 */
+	of_mdiobus_link_phydev(bus, phydev);
+
 	err = phy_device_register(phydev);
 	if (err) {
 		phy_device_free(phydev);
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 4eb335e..92e09ac 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -209,6 +209,39 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 }
 EXPORT_SYMBOL(of_mdiobus_register);
 
+/**
+ * of_mdiobus_link_phydev - Find a device node for a phy
+ * @mdio: pointer to mii_bus structure
+ * @phydev: phydev for which the of_node pointer should be set
+ *
+ * Walk the list of subnodes of a mdio bus and look for a node that matches the
+ * phy's address with its 'reg' property. If found, set the of_node pointer for
+ * the phy. This allows auto-probed pyh devices to be supplied with information
+ * passed in via DT.
+ */
+void of_mdiobus_link_phydev(struct mii_bus *mdio,
+			    struct phy_device *phydev)
+{
+	struct device *dev = &phydev->dev;
+	struct device_node *child;
+
+	if (dev->of_node || !mdio->dev.of_node)
+		return;
+
+	for_each_available_child_of_node(mdio->dev.of_node, child) {
+		int addr;
+
+		addr = of_mdio_parse_addr(&mdio->dev, child);
+		if (addr < 0)
+			continue;
+
+		if (addr == phydev->addr) {
+			dev->of_node = child;
+			return;
+		}
+	}
+}
+
 /* Helper function for of_phy_find_device */
 static int of_phy_match(struct device *dev, void *phy_np)
 {
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 881a7c3..de72206 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -28,6 +28,9 @@ extern struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 
+extern void of_mdiobus_link_phydev(struct mii_bus *mdio,
+				   struct phy_device *phydev);
+
 #else /* CONFIG_OF */
 static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 {
@@ -70,6 +73,11 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 {
 	return NULL;
 }
+
+static inline void of_mdiobus_link_phydev(struct mii_bus *mdio,
+					  struct phy_device *phydev)
+{
+}
 #endif /* CONFIG_OF */
 
 #endif /* __LINUX_OF_MDIO_H */
-- 
1.9.0
