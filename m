From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/3] net: of_mdio: add of_mdiobus_link_phydev()
Date: Sat, 10 May 2014 18:37:54 +0200
Message-ID: <1399739875-16434-3-git-send-email-zonque@gmail.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com, Daniel Mack <zonque@gmail.com>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:51493 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaEJQiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 12:38:06 -0400
Received: by mail-ee0-f45.google.com with SMTP id d49so3383629eek.18
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 09:38:05 -0700 (PDT)
In-Reply-To: <1399739875-16434-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function to Walk the list of subnodes of a mdio bus and look for
a node that matches the phy's address with its 'reg' property. If found,
set the of_node pointer for the phy. This allows auto-probed pyh
devices to be augmented by information passed in via DT.

Signed-off-by: Daniel Mack <zonque@gmail.com>
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
index 171f9d5..931a977 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -211,6 +211,39 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
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
+	if (dev->of_node)
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
