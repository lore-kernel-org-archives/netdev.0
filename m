From: <s-paulraj@ti.com>
Subject: [PATCH 3/4] of/mdio: add context argument to adjust link callback
Date: Fri, 6 Jul 2012 16:09:56 -0400
Message-ID: <1341605396-20619-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sandeep Paulraj <s-paulraj@ti.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>, <cyril@ti.com>,
	<grant.likely@secretlab.ca>, <linux-keystone@list.ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42457 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816Ab2GFUKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 16:10:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Paulraj <s-paulraj@ti.com>

This patch implements extensions to device-tree phy interfaces in order to
have context information passed back into the adjust link callbacks.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Sandeep Paulraj <s-paulraj@ti.com>
---
 drivers/of/of_mdio.c    |   24 +++++++++++++++---------
 include/linux/of_mdio.h |   15 ++++++++-------
 2 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 2574abd..a0a09db 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -136,20 +136,24 @@ EXPORT_SYMBOL(of_phy_find_device);
  * @phy_np: Pointer to device tree node for the PHY
  * @hndlr: Link state callback for the network device
  * @iface: PHY data interface type
+ * @context: Context for callback handler
  *
  * Returns a pointer to the phy_device if successful.  NULL otherwise
  */
-struct phy_device *of_phy_connect(struct net_device *dev,
-				  struct device_node *phy_np,
-				  void (*hndlr)(struct net_device *), u32 flags,
-				  phy_interface_t iface)
+struct phy_device *
+of_phy_connect(struct net_device *dev,
+	       struct device_node *phy_np,
+	       void (*hndlr)(struct net_device *, void *context),
+	       u32 flags, phy_interface_t iface, void *context)
 {
 	struct phy_device *phy = of_phy_find_device(phy_np);
+	int error;
 
 	if (!phy)
 		return NULL;
 
-	return phy_connect_direct(dev, phy, hndlr, flags, iface) ? NULL : phy;
+	error = phy_connect_direct(dev, phy, hndlr, flags, iface, context);
+	return error ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect);
 
@@ -158,14 +162,16 @@ EXPORT_SYMBOL(of_phy_connect);
  * @dev: pointer to net_device claiming the phy
  * @hndlr: Link state callback for the network device
  * @iface: PHY data interface type
+ * @context: Context for callback handler
  *
  * This function is a temporary stop-gap and will be removed soon.  It is
  * only to support the fs_enet, ucc_geth and gianfar Ethernet drivers.  Do
  * not call this function from new drivers.
  */
-struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
-					     void (*hndlr)(struct net_device *),
-					     phy_interface_t iface)
+struct phy_device *
+of_phy_connect_fixed_link(struct net_device *dev,
+			  void (*hndlr)(struct net_device *, void *context),
+			  phy_interface_t iface, void *context)
 {
 	struct device_node *net_np;
 	char bus_id[MII_BUS_ID_SIZE + 3];
@@ -186,7 +192,7 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
 
 	sprintf(bus_id, PHY_ID_FMT, "fixed-0", be32_to_cpu(phy_id[0]));
 
-	phy = phy_connect(dev, bus_id, hndlr, 0, iface);
+	phy = phy_connect(dev, bus_id, hndlr, 0, iface, context);
 	return IS_ERR(phy) ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect_fixed_link);
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 912c27a..d72d0c6 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -14,13 +14,14 @@
 
 extern int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np);
 extern struct phy_device *of_phy_find_device(struct device_node *phy_np);
-extern struct phy_device *of_phy_connect(struct net_device *dev,
-					 struct device_node *phy_np,
-					 void (*hndlr)(struct net_device *),
-					 u32 flags, phy_interface_t iface);
-extern struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
-					 void (*hndlr)(struct net_device *),
-					 phy_interface_t iface);
+extern struct phy_device *
+of_phy_connect(struct net_device *dev, struct device_node *phy_np,
+	       void (*hndlr)(struct net_device *, void *context),
+	       u32 flags, phy_interface_t iface, void *context);
+extern struct phy_device *
+of_phy_connect_fixed_link(struct net_device *dev,
+			  void (*hndlr)(struct net_device *, void *context),
+			  phy_interface_t iface, void *context);
 
 extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
 
-- 
1.7.9.5
