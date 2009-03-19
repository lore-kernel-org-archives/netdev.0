From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 7/9] net/ucc_geth: Rework ucc_geth driver to use OF PHY/MDIO
	helper functions
Date: Wed, 18 Mar 2009 23:00:50 -0600
Message-ID: <20090319050049.11320.98769.stgit@localhost.localdomain>
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
	with ESMTP id S1753328AbZCSFAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:00:54 -0400
Received: by wa-out-1112.google.com with SMTP id j5so245042wah.21
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:00:52 -0700 (PDT)
In-Reply-To: <20090319050015.11320.61641.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/ucc_geth.c     |   27 ++++++---------------------
 drivers/net/ucc_geth_mii.c |   17 +++--------------
 2 files changed, 9 insertions(+), 35 deletions(-)


diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e879868..45bb627 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -28,6 +28,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/workqueue.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/uaccess.h>
@@ -1537,35 +1538,19 @@ static int init_phy(struct net_device *dev)
 {
 	struct ucc_geth_private *priv = netdev_priv(dev);
 	struct device_node *np = priv->node;
-	struct device_node *phy, *mdio;
-	const phandle *ph;
-	char bus_name[MII_BUS_ID_SIZE];
-	const unsigned int *id;
+	struct device_node *phy;
 	struct phy_device *phydev;
-	char phy_id[BUS_ID_SIZE];
 
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	ph = of_get_property(np, "phy-handle", NULL);
-	phy = of_find_node_by_phandle(*ph);
-	mdio = of_get_parent(phy);
-
-	id = of_get_property(phy, "reg", NULL);
-
+	phy = of_parse_phandle(np, "phy-handle", 0);
+	phydev = of_phy_connect(dev, phy, &adjust_link, 0, priv->phy_interface);
 	of_node_put(phy);
-	of_node_put(mdio);
-
-	uec_mdio_bus_name(bus_name, mdio);
-	snprintf(phy_id, sizeof(phy_id), "%s:%02x",
-                                bus_name, *id);
-
-	phydev = phy_connect(dev, phy_id, &adjust_link, 0, priv->phy_interface);
-
-	if (IS_ERR(phydev)) {
+	if (!phydev) {
 		printk("%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phydev);
+		return -ENODEV;
 	}
 
 	phydev->supported &= (ADVERTISED_10baseT_Half |
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 0ada4ed..9f2492f 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -36,6 +36,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/fsl_devices.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/io.h>
@@ -135,11 +136,10 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 {
 	struct device *device = &ofdev->dev;
 	struct device_node *np = ofdev->node, *tempnp = NULL;
-	struct device_node *child = NULL;
 	struct ucc_mii_mng __iomem *regs;
 	struct mii_bus *new_bus;
 	struct resource res;
-	int k, err = 0;
+	int err = 0;
 
 	new_bus = mdiobus_alloc();
 	if (NULL == new_bus)
@@ -165,17 +165,6 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 		goto reg_map_fail;
 	}
 
-	for (k = 0; k < 32; k++)
-		new_bus->irq[k] = PHY_POLL;
-
-	while ((child = of_get_next_child(np, child)) != NULL) {
-		int irq = irq_of_parse_and_map(child, 0);
-		if (irq != NO_IRQ) {
-			const u32 *id = of_get_property(child, "reg", NULL);
-			new_bus->irq[*id] = irq;
-		}
-	}
-
 	/* Set the base address */
 	regs = ioremap(res.start, sizeof(struct ucc_mii_mng));
 
@@ -220,7 +209,7 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 		}
 	}
 
-	err = mdiobus_register(new_bus);
+	err = of_mdiobus_register(new_bus, np);
 	if (0 != err) {
 		printk(KERN_ERR "%s: Cannot register as MDIO bus\n",
 		       new_bus->name);

