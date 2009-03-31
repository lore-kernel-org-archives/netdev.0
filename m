From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 09/14] net: Rework gianfar driver to use of_mdio
	infrastructure.
Date: Tue, 31 Mar 2009 02:27:30 -0600
Message-ID: <20090331082730.1427.96418.stgit@localhost.localdomain>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, afleming@freescale.com, galak@kernel.crashing.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:58055 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbZCaI1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:27:34 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2906140rvb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 01:27:32 -0700 (PDT)
In-Reply-To: <20090331075537.1427.7819.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/gianfar.c |  103 ++++++++++++++++++-------------------------------
 drivers/net/gianfar.h |    3 +
 2 files changed, 40 insertions(+), 66 deletions(-)


diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 65f5587..c22eba9 100644
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
+	priv->phy_node = of_parse_phandle(np, "phy-device", 0);
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
@@ -699,23 +657,38 @@ static int init_phy(struct net_device *dev)
 
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
index dd499d7..4c69a3a 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -780,7 +780,8 @@ struct gfar_private {
 	spinlock_t bflock;
 
 	phy_interface_t interface;
-	char	phy_bus_id[BUS_ID_SIZE];
+	struct device_node *phy_node;
+	struct device_node *tbi_node;
 	u32 device_flags;
 	unsigned char rx_csum_enable:1,
 		extended_hash:1,

