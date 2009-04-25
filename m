From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v3 09/13] net: Rework ucc_geth driver to use of_mdio
	infrastructure
Date: Sat, 25 Apr 2009 16:53:23 -0600
Message-ID: <20090425225323.32392.1254.stgit@localhost.localdomain>
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
	with ESMTP id S1754107AbZDYWxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 18:53:25 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1420826rvb.1
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2009 15:53:25 -0700 (PDT)
In-Reply-To: <20090425224458.32392.31296.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Acked-by: Andy Fleming <afleming@freescale.com>
---

 drivers/net/ucc_geth.c |   47 ++++++++++++-----------------------------------
 drivers/net/ucc_geth.h |    2 +-
 2 files changed, 13 insertions(+), 36 deletions(-)


diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index d3f39e8..195b490 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -27,6 +27,7 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/workqueue.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/uaccess.h>
@@ -1542,12 +1543,14 @@ static int init_phy(struct net_device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	phydev = phy_connect(dev, ug_info->phy_bus_id, &adjust_link, 0,
-			     priv->phy_interface);
+	if (!ug_info->phy_node)
+		return 0;
 
-	if (IS_ERR(phydev)) {
+	phydev = of_phy_connect(dev, ug_info->phy_node, &adjust_link, 0,
+				priv->phy_interface);
+	if (!phydev) {
 		printk("%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phydev);
+		return -ENODEV;
 	}
 
 	phydev->supported &= (ADVERTISED_10baseT_Half |
@@ -3519,14 +3522,12 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
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
 	const u32 *fixed_link;
 	const unsigned int *prop;
 	const char *sprop;
@@ -3626,45 +3627,21 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
 	fixed_link = of_get_property(np, "fixed-link", NULL);
 	if (fixed_link) {
-		snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_id),
-			 PHY_ID_FMT, "0", fixed_link[0]);
 		phy = NULL;
 	} else {
-		char bus_name[MII_BUS_ID_SIZE];
-
-		ph = of_get_property(np, "phy-handle", NULL);
-		phy = of_find_node_by_phandle(*ph);
-
+		phy = of_parse_phandle(np, "phy-handle", 0);
 		if (phy == NULL)
 			return -ENODEV;
-
-		/* set the PHY address */
-		prop = of_get_property(phy, "reg", NULL);
-		if (prop == NULL)
-			return -1;
-
-		/* Set the bus id */
-		mdio = of_get_parent(phy);
-
-		if (mdio == NULL)
-			return -ENODEV;
-
-		err = of_address_to_resource(mdio, 0, &res);
-
-		if (err) {
-			of_node_put(mdio);
-			return err;
-		}
-		fsl_pq_mdio_bus_name(bus_name, mdio);
-		of_node_put(mdio);
-		snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_id),
-			"%s:%02x", bus_name, *prop);
 	}
+	ug_info->phy_node = phy;
 
 	/* get the phy interface type, or default to MII */
 	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
+		if (!phy)
+			return -ENODEV;
+
 		prop = of_get_property(phy, "interface", NULL);
 		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 2f8ee7c..bc31975 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1100,7 +1100,7 @@ struct ucc_geth_info {
 	u32 eventRegMask;
 	u16 pausePeriod;
 	u16 extensionField;
-	char phy_bus_id[BUS_ID_SIZE];
+	struct device_node *phy_node;
 	u8 weightfactor[NUM_TX_QUEUES];
 	u8 interruptcoalescingmaxvalue[NUM_RX_QUEUES];
 	u8 l2qt[UCC_GETH_VLAN_PRIORITY_MAX];

