From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v3 07/13] net: Rework gianfar driver to use of_mdio
	infrastructure.
Date: Sat, 25 Apr 2009 16:53:12 -0600
Message-ID: <20090425225312.32392.81899.stgit@localhost.localdomain>
References: <20090425224458.32392.31296.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:58506 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbZDYWxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 18:53:15 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1420826rvb.1
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 15:53:15 -0700 (PDT)
In-Reply-To: <20090425224458.32392.31296.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Tested on Freescale MPC8349emitxgp eval board

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Acked-by: Andy Fleming <afleming@freescale.com>
---

 drivers/net/gianfar.c |  109 +++++++++++++++++--------------------------------
 drivers/net/gianfar.h |    4 +-
 2 files changed, 39 insertions(+), 74 deletions(-)


diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 65f5587..038f293 100644
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
@@ -168,17 +169,13 @@ static inline int gfar_uses_fcb(struct gfar_private *priv)
 
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
 	const u32 *stash;
 	const u32 *stash_len;
 	const u32 *stash_idx;
@@ -264,8 +261,8 @@ static int gfar_of_init(struct net_device *dev)
 	if (of_get_property(np, "fsl,magic-packet", NULL))
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
 
-	ph = of_get_property(np, "phy-handle", NULL);
-	if (ph == NULL) {
+	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (!priv->phy_node) {
 		u32 *fixed_link;
 
 		fixed_link = (u32 *)of_get_property(np, "fixed-link", NULL);
@@ -273,57 +270,10 @@ static int gfar_of_init(struct net_device *dev)
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
-
-		fsl_pq_mdio_bus_name(bus_name, mdio);
-		of_node_put(mdio);
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
 
@@ -529,6 +479,10 @@ static int gfar_probe(struct of_device *ofdev,
 register_fail:
 	iounmap(priv->regs);
 regs_fail:
+	if (priv->phy_node)
+		of_node_put(priv->phy_node);
+	if (priv->tbi_node)
+		of_node_put(priv->tbi_node);
 	free_netdev(dev);
 	return err;
 }
@@ -537,6 +491,11 @@ static int gfar_remove(struct of_device *ofdev)
 {
 	struct gfar_private *priv = dev_get_drvdata(&ofdev->dev);
 
+	if (priv->phy_node)
+		of_node_put(priv->phy_node);
+	if (priv->tbi_node)
+		of_node_put(priv->tbi_node);
+
 	dev_set_drvdata(&ofdev->dev, NULL);
 
 	iounmap(priv->regs);
@@ -690,7 +649,6 @@ static int init_phy(struct net_device *dev)
 	uint gigabit_support =
 		priv->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
 		SUPPORTED_1000baseT_Full : 0;
-	struct phy_device *phydev;
 	phy_interface_t interface;
 
 	priv->oldlink = 0;
@@ -699,21 +657,21 @@ static int init_phy(struct net_device *dev)
 
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
 }
@@ -730,10 +688,17 @@ static int init_phy(struct net_device *dev)
 static void gfar_configure_serdes(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *tbiphy;
+
+	if (!priv->tbi_node) {
+		dev_warn(&dev->dev, "error: SGMII mode requires that the "
+				    "device tree specify a tbi-handle\n");
+		return;
+	}
 
-	if (!priv->tbiphy) {
-		printk(KERN_WARNING "SGMII mode requires that the device "
-				"tree specify a tbi-handle\n");
+	tbiphy = of_phy_find_device(priv->tbi_node);
+	if (!tbiphy) {
+		dev_err(&dev->dev, "error: Could not get TBI device\n");
 		return;
 	}
 
@@ -743,17 +708,17 @@ static void gfar_configure_serdes(struct net_device *dev)
 	 * everything for us?  Resetting it takes the link down and requires
 	 * several seconds for it to come back.
 	 */
-	if (phy_read(priv->tbiphy, MII_BMSR) & BMSR_LSTATUS)
+	if (phy_read(tbiphy, MII_BMSR) & BMSR_LSTATUS)
 		return;
 
 	/* Single clk mode, mii mode off(for serdes communication) */
-	phy_write(priv->tbiphy, MII_TBICON, TBICON_CLK_SELECT);
+	phy_write(tbiphy, MII_TBICON, TBICON_CLK_SELECT);
 
-	phy_write(priv->tbiphy, MII_ADVERTISE,
+	phy_write(tbiphy, MII_ADVERTISE,
 			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
 			ADVERTISE_1000XPSE_ASYM);
 
-	phy_write(priv->tbiphy, MII_BMCR, BMCR_ANENABLE |
+	phy_write(tbiphy, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
 }
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 0642d52..91317bc 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -779,7 +779,8 @@ struct gfar_private {
 	spinlock_t bflock;
 
 	phy_interface_t interface;
-	char	phy_bus_id[BUS_ID_SIZE];
+	struct device_node *phy_node;
+	struct device_node *tbi_node;
 	u32 device_flags;
 	unsigned char rx_csum_enable:1,
 		extended_hash:1,
@@ -793,7 +794,6 @@ struct gfar_private {
 
 	/* PHY stuff */
 	struct phy_device *phydev;
-	struct phy_device *tbiphy;
 	struct mii_bus *mii_bus;
 	int oldspeed;
 	int oldduplex;

