From: Haiying Wang <Haiying.Wang@freescale.com>
Subject: [PATCH] ucc_geth: Change uec phy id to the same format as gianfar's
Date: Thu, 29 Jan 2009 13:39:02 -0500
Message-ID: <1233254342-8435-1-git-send-email-Haiying.Wang@freescale.com>
Cc: Haiying Wang <Haiying.Wang@freescale.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36992 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbZA2SjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 13:39:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit b31a1d8b41513b96e9c7ec2f68c5734cef0b26a4 changes the gianfar's phy id to
the format like "mdio@xxxx:xx", but uec still uses the old format like "xxxxxxxx:xx".
For the board whose UEC uses gianfar-mdio like MPC8568MDS, the phy can not be attached
because of the incompatible phy id format. This patch changes uec's phy id to the same
format as gianfar's.

Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
---
 drivers/net/ucc_geth.c           |   20 ++++++++++++++++++--
 drivers/net/ucc_geth.h           |    2 ++
 drivers/net/ucc_geth_mii.c       |   12 +++++++++++-
 drivers/net/ucc_geth_mii.h       |    1 +
 4 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 1144122..6ffeffa 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1536,6 +1536,11 @@ static void adjust_link(struct net_device *dev)
 static int init_phy(struct net_device *dev)
 {
 	struct ucc_geth_private *priv = netdev_priv(dev);
+	struct device_node *np = priv->node;
+	struct device_node *phy, *mdio;
+	const phandle *ph;
+	char bus_name[MII_BUS_ID_SIZE];
+	const unsigned int *id;
 	struct phy_device *phydev;
 	char phy_id[BUS_ID_SIZE];
 
@@ -1543,9 +1548,19 @@ static int init_phy(struct net_device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, priv->ug_info->mdio_bus,
-		 priv->ug_info->phy_address);
+	ph = of_get_property(np, "phy-handle", NULL);
+	phy = of_find_node_by_phandle(*ph);
+	mdio = of_get_parent(phy);
+
+	id = of_get_property(phy, "reg", NULL);
+
+	of_node_put(phy);
+	of_node_put(mdio);
 
+	uec_mdio_bus_name(bus_name, mdio);
+	snprintf(phy_id, sizeof(phy_id), "%s:%02x",
+                                bus_name, *id);
+
 	phydev = phy_connect(dev, phy_id, &adjust_link, 0, priv->phy_interface);
 
 	if (IS_ERR(phydev)) {
@@ -3748,6 +3763,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ugeth->ug_info = ug_info;
 	ugeth->dev = dev;
+	ugeth->node = np;
 
 	return 0;
 }
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 8f699cb..16cbe42 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1186,6 +1186,8 @@ struct ucc_geth_private {
 	int oldspeed;
 	int oldduplex;
 	int oldlink;
+
+	struct device_node *node;
 };
 
 void uec_set_ethtool_ops(struct net_device *netdev);
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index c001d26..5463591 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -156,7 +156,7 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 	if (err)
 		goto reg_map_fail;
 
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
+	uec_mdio_bus_name(new_bus->id, np);
 
 	new_bus->irq = kmalloc(32 * sizeof(int), GFP_KERNEL);
 
@@ -283,3 +283,13 @@ void uec_mdio_exit(void)
 {
 	of_unregister_platform_driver(&uec_mdio_driver);
 }
+
+void uec_mdio_bus_name(char *name, struct device_node *np)
+{
+        const u32 *reg;
+
+        reg = of_get_property(np, "reg", NULL);
+
+        snprintf(name, MII_BUS_ID_SIZE, "%s@%x", np->name, reg ? *reg : 0);
+}
+
diff --git a/drivers/net/ucc_geth_mii.h b/drivers/net/ucc_geth_mii.h
index 1e45b20..840cf80 100644
--- a/drivers/net/ucc_geth_mii.h
+++ b/drivers/net/ucc_geth_mii.h
@@ -97,4 +97,5 @@ int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
 int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
 int __init uec_mdio_init(void);
 void uec_mdio_exit(void);
+void uec_mdio_bus_name(char *name, struct device_node *np);
 #endif				/* __UEC_MII_H */
-- 
1.6.0.2

