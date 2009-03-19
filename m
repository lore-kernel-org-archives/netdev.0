From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 6/9] net/gianfar: Rework gianfar driver to use OF PHY/MDIO
	helper functions
Date: Wed, 18 Mar 2009 23:00:44 -0600
Message-ID: <20090319050043.11320.96160.stgit@localhost.localdomain>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:12515 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbZCSFAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:00:49 -0400
Received: by wa-out-1112.google.com with SMTP id j5so245042wah.21
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:00:48 -0700 (PDT)
In-Reply-To: <20090319050015.11320.61641.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/gianfar.c     |   94 ++++++++++++++-------------------------------
 drivers/net/gianfar.h     |    3 +
 drivers/net/gianfar_mii.c |   52 +------------------------
 3 files changed, 34 insertions(+), 115 deletions(-)


diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 9831b3f..0521267 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -75,6 +75,7 @@
 #include <linux/if_vlan.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
@@ -155,17 +156,13 @@ static inline int gfar_uses_fcb(struct gfar_private *priv)
 
 static int gfar_of_init(struct net_device *dev)
 {
-	struct device_node *phy, *mdio;
-	const unsigned int *id;
 	const char *model;
 	const char *ctype;
 	const void *mac_addr;
-	const phandle *ph;
 	u64 addr, size;
 	int err = 0;
 	struct gfar_private *priv = netdev_priv(dev);
 	struct device_node *np = priv->node;
-	char bus_name[MII_BUS_ID_SIZE];
 
 	if (!np || !of_device_is_available(np))
 		return -ENODEV;
@@ -228,8 +225,8 @@ static int gfar_of_init(struct net_device *dev)
 	if (of_get_property(np, "fsl,magic-packet", NULL))
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
 
-	ph = of_get_property(np, "phy-handle", NULL);
-	if (ph == NULL) {
+	priv->phy_node = of_parse_phandle(np, "phy-device", 0);
+	if (!priv->phy_node) {
 		u32 *fixed_link;
 
 		fixed_link = (u32 *)of_get_property(np, "fixed-link", NULL);
@@ -237,57 +234,10 @@ static int gfar_of_init(struct net_device *dev)
 			err = -ENODEV;
 			goto err_out;
 		}
-
-		snprintf(priv->phy_bus_id, sizeof(priv->phy_bus_id),
-				PHY_ID_FMT, "0", fixed_link[0]);
-	} else {
-		phy = of_find_node_by_phandle(*ph);
-
-		if (phy == NULL) {
-			err = -ENODEV;
-			goto err_out;
-		}
-
-		mdio = of_get_parent(phy);
-
-		id = of_get_property(phy, "reg", NULL);
-
-		of_node_put(phy);
-		of_node_put(mdio);
-
-		gfar_mdio_bus_name(bus_name, mdio);
-		snprintf(priv->phy_bus_id, sizeof(priv->phy_bus_id), "%s:%02x",
-				bus_name, *id);
 	}
 
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
-	ph = of_get_property(np, "tbi-handle", NULL);
-	if (ph) {
-		struct device_node *tbi = of_find_node_by_phandle(*ph);
-		struct of_device *ofdev;
-		struct mii_bus *bus;
-
-		if (!tbi)
-			return 0;
-
-		mdio = of_get_parent(tbi);
-		if (!mdio)
-			return 0;
-
-		ofdev = of_find_device_by_node(mdio);
-
-		of_node_put(mdio);
-
-		id = of_get_property(tbi, "reg", NULL);
-		if (!id)
-			return 0;
-
-		of_node_put(tbi);
-
-		bus = dev_get_drvdata(&ofdev->dev);
-
-		priv->tbiphy = bus->phy_map[*id];
-	}
+	priv->tbi_node = of_parse_phandle(np, "tbi-handle", 0);
 
 	return 0;
 
@@ -661,7 +611,6 @@ static int init_phy(struct net_device *dev)
 	uint gigabit_support =
 		priv->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
 		SUPPORTED_1000baseT_Full : 0;
-	struct phy_device *phydev;
 	phy_interface_t interface;
 
 	priv->oldlink = 0;
@@ -670,23 +619,38 @@ static int init_phy(struct net_device *dev)
 
 	interface = gfar_get_interface(dev);
 
-	phydev = phy_connect(dev, priv->phy_bus_id, &adjust_link, 0, interface);
+	if (priv->phy_node) {
+		priv->phydev = of_phy_connect(dev, priv->phy_node, &adjust_link,
+					      0, interface);
+		if (!priv->phydev) {
+			dev_err(&dev->dev, "error: Could not attach to PHY\n");
+			return -ENODEV;
+		}
+	}
+
+	if (priv->tbi_node) {
+		priv->tbiphy = of_phy_connect(dev, priv->tbi_node, &adjust_link,
+					      0, interface);
+		if (!priv->tbiphy) {
+			dev_err(&dev->dev, "error: Could not attach to TBI\n");
+			goto err_tbiphy;
+		}
+	}
 
 	if (interface == PHY_INTERFACE_MODE_SGMII)
 		gfar_configure_serdes(dev);
 
-	if (IS_ERR(phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phydev);
-	}
-
 	/* Remove any features not supported by the controller */
-	phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
-	phydev->advertising = phydev->supported;
-
-	priv->phydev = phydev;
+	priv->phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
+	priv->phydev->advertising = priv->phydev->supported;
 
 	return 0;
+
+ err_tbiphy:
+	if (priv->phy_node)
+		phy_disconnect(priv->phydev);
+	priv->phydev = NULL;
+	return -ENODEV;
 }
 
 /*
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index eaa8689..d3d56a9 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -775,7 +775,8 @@ struct gfar_private {
 	spinlock_t bflock;
 
 	phy_interface_t interface;
-	char	phy_bus_id[BUS_ID_SIZE];
+	struct device_node *phy_node;
+	struct device_node *tbi_node;
 	u32 device_flags;
 	unsigned char rx_csum_enable:1,
 		extended_hash:1,
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index f49a426..c6d77bd 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -35,6 +35,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/of.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/io.h>
@@ -152,45 +153,6 @@ static int gfar_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-/* Allocate an array which provides irq #s for each PHY on the given bus */
-static int *create_irq_map(struct device_node *np)
-{
-	int *irqs;
-	int i;
-	struct device_node *child = NULL;
-
-	irqs = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
-
-	if (!irqs)
-		return NULL;
-
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		irqs[i] = PHY_POLL;
-
-	while ((child = of_get_next_child(np, child)) != NULL) {
-		int irq = irq_of_parse_and_map(child, 0);
-		const u32 *id;
-
-		if (irq == NO_IRQ)
-			continue;
-
-		id = of_get_property(child, "reg", NULL);
-
-		if (!id)
-			continue;
-
-		if (*id < PHY_MAX_ADDR && *id >= 0)
-			irqs[*id] = irq;
-		else
-			printk(KERN_WARNING "%s: "
-					"%d is not a valid PHY address\n",
-					np->full_name, *id);
-	}
-
-	return irqs;
-}
-
-
 void gfar_mdio_bus_name(char *name, struct device_node *np)
 {
 	const u32 *reg;
@@ -253,7 +215,7 @@ static int gfar_mdio_probe(struct of_device *ofdev,
 
 	new_bus->priv = (void __force *)regs;
 
-	new_bus->irq = create_irq_map(np);
+	new_bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
 
 	if (new_bus->irq == NULL) {
 		err = -ENOMEM;
@@ -301,15 +263,7 @@ static int gfar_mdio_probe(struct of_device *ofdev,
 
 	gfar_write(&enet_regs->tbipa, tbiaddr);
 
-	/*
-	 * The TBIPHY-only buses will find PHYs at every address,
-	 * so we mask them all but the TBI
-	 */
-	if (!of_device_is_compatible(np, "fsl,gianfar-mdio"))
-		new_bus->phy_mask = ~(1 << tbiaddr);
-
-	err = mdiobus_register(new_bus);
-
+	err = of_mdiobus_register(new_bus, np);
 	if (err != 0) {
 		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
 				new_bus->name);

