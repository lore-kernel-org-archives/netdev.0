From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 08/13] net: Rework ucc_geth driver to use of_mdio
	infrastructure
Date: Sat, 21 Mar 2009 16:28:56 -0600
Message-ID: <20090321222855.20493.71112.stgit@localhost.localdomain>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:31077 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664AbZCUW3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:29:00 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085459wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:28:59 -0700 (PDT)
In-Reply-To: <20090321222047.20493.87335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.
It also removes what appears to be a large block of duplicated code.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/ucc_geth.c     |   65 +++++---------------------------------------
 drivers/net/ucc_geth.h     |    2 -
 drivers/net/ucc_geth_mii.c |   17 ++----------
 3 files changed, 11 insertions(+), 73 deletions(-)


diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e879868..fa8336b 100644
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
@@ -3522,15 +3507,12 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 {
 	struct device *device = &ofdev->dev;
 	struct device_node *np = ofdev->node;
-	struct device_node *mdio;
 	struct net_device *dev = NULL;
 	struct ucc_geth_private *ugeth = NULL;
 	struct ucc_geth_info *ug_info;
 	struct resource res;
 	struct device_node *phy;
 	int err, ucc_num, max_speed = 0;
-	const phandle *ph;
-	const u32 *fixed_link;
 	const unsigned int *prop;
 	const char *sprop;
 	const void *mac_addr;
@@ -3627,44 +3609,13 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info->uf_info.regs = res.start;
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
-	fixed_link = of_get_property(np, "fixed-link", NULL);
-	if (fixed_link) {
-		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "0");
-		ug_info->phy_address = fixed_link[0];
-		phy = NULL;
-	} else {
-		ph = of_get_property(np, "phy-handle", NULL);
-		phy = of_find_node_by_phandle(*ph);
-
-		if (phy == NULL)
-			return -ENODEV;
-
-		/* set the PHY address */
-		prop = of_get_property(phy, "reg", NULL);
-		if (prop == NULL)
-			return -1;
-		ug_info->phy_address = *prop;
-
-		/* Set the bus id */
-		mdio = of_get_parent(phy);
-
-		if (mdio == NULL)
-			return -1;
-
-		err = of_address_to_resource(mdio, 0, &res);
-		of_node_put(mdio);
-
-		if (err)
-			return -1;
-
-		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "%x", res.start);
-	}
-
 	/* get the phy interface type, or default to MII */
 	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
+		phy = of_parse_phandle(np, "phy-handle", 0);
 		prop = of_get_property(phy, "interface", NULL);
+		of_node_put(phy);
 		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];
 			max_speed = enet_to_speed[*prop];
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 16cbe42..6143dfe 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1091,8 +1091,6 @@ struct ucc_geth_info {
 	u32 eventRegMask;
 	u16 pausePeriod;
 	u16 extensionField;
-	u8 phy_address;
-	char mdio_bus[MII_BUS_ID_SIZE];
 	u8 weightfactor[NUM_TX_QUEUES];
 	u8 interruptcoalescingmaxvalue[NUM_RX_QUEUES];
 	u8 l2qt[UCC_GETH_VLAN_PRIORITY_MAX];
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

