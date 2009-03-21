From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 11/13] net: Rework fs_enet driver to use of_mdio
	infrastructure
Date: Sat, 21 Mar 2009 16:29:13 -0600
Message-ID: <20090321222912.20493.53810.stgit@localhost.localdomain>
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
	with ESMTP id S1755078AbZCUW3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 18:29:22 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2085459wff.4
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2009 15:29:21 -0700 (PDT)
In-Reply-To: <20090321222047.20493.87335.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch simplifies the driver by making use of more common code.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/fs_enet/fs_enet-main.c |   69 ++++++------------------------------
 drivers/net/fs_enet/mii-bitbang.c  |   29 +--------------
 drivers/net/fs_enet/mii-fec.c      |   26 +-------------
 include/linux/fs_enet_pd.h         |    6 +--
 4 files changed, 16 insertions(+), 114 deletions(-)


diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index ce900e5..28dde90 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -36,6 +36,8 @@
 #include <linux/fs.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
+#include <linux/of.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 #include <linux/of_gpio.h>
 
@@ -752,9 +754,10 @@ static int fs_init_phy(struct net_device *dev)
 	fep->oldlink = 0;
 	fep->oldspeed = 0;
 	fep->oldduplex = -1;
-	if(fep->fpi->bus_id)
-		phydev = phy_connect(dev, fep->fpi->bus_id, &fs_adjust_link, 0,
-				PHY_INTERFACE_MODE_MII);
+	if(fep->fpi->phy_node)
+		phydev = of_phy_connect(dev, fep->fpi->phy_node,
+					&fs_adjust_link, 0,
+					PHY_INTERFACE_MODE_MII);
 	else {
 		printk("No phy bus ID specified in BSP code\n");
 		return -EINVAL;
@@ -962,57 +965,6 @@ static void cleanup_immap(void)
 
 /**************************************************************************************/
 
-static int __devinit find_phy(struct device_node *np,
-                              struct fs_platform_info *fpi)
-{
-	struct device_node *phynode, *mdionode;
-	int ret = 0, len, bus_id;
-	const u32 *data;
-
-	data  = of_get_property(np, "fixed-link", NULL);
-	if (data) {
-		snprintf(fpi->bus_id, 16, "%x:%02x", 0, *data);
-		return 0;
-	}
-
-	data = of_get_property(np, "phy-handle", &len);
-	if (!data || len != 4)
-		return -EINVAL;
-
-	phynode = of_find_node_by_phandle(*data);
-	if (!phynode)
-		return -EINVAL;
-
-	data = of_get_property(phynode, "reg", &len);
-	if (!data || len != 4) {
-		ret = -EINVAL;
-		goto out_put_phy;
-	}
-
-	mdionode = of_get_parent(phynode);
-	if (!mdionode) {
-		ret = -EINVAL;
-		goto out_put_phy;
-	}
-
-	bus_id = of_get_gpio(mdionode, 0);
-	if (bus_id < 0) {
-		struct resource res;
-		ret = of_address_to_resource(mdionode, 0, &res);
-		if (ret)
-			goto out_put_mdio;
-		bus_id = res.start;
-	}
-
-	snprintf(fpi->bus_id, 16, "%x:%02x", bus_id, *data);
-
-out_put_mdio:
-	of_node_put(mdionode);
-out_put_phy:
-	of_node_put(phynode);
-	return ret;
-}
-
 #ifdef CONFIG_FS_ENET_HAS_FEC
 #define IS_FEC(match) ((match)->data == &fs_fec_ops)
 #else
@@ -1046,9 +998,9 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	fpi->rx_copybreak = 240;
 	fpi->use_napi = 1;
 	fpi->napi_weight = 17;
-
-	ret = find_phy(ofdev->node, fpi);
-	if (ret)
+	fpi->phy_node = of_parse_phandle(ofdev->node, "phy-handle", 0);
+	if ((!fpi->phy_node) && (!of_get_property(ofdev->node, "fixed-link",
+						  NULL)))
 		goto out_free_fpi;
 
 	privsize = sizeof(*fep) +
@@ -1129,6 +1081,7 @@ out_cleanup_data:
 out_free_dev:
 	free_netdev(ndev);
 	dev_set_drvdata(&ofdev->dev, NULL);
+	of_node_put(fpi->phy_node);
 out_free_fpi:
 	kfree(fpi);
 	return ret;
@@ -1144,7 +1097,7 @@ static int fs_enet_remove(struct of_device *ofdev)
 	fep->ops->free_bd(ndev);
 	fep->ops->cleanup_data(ndev);
 	dev_set_drvdata(fep->dev, NULL);
-
+	of_node_put(fpi->phy_node);
 	free_netdev(ndev);
 	return 0;
 }
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 49b6645..93b481b 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -22,6 +22,7 @@
 #include <linux/mii.h>
 #include <linux/platform_device.h>
 #include <linux/mdio-bitbang.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include "fs_enet.h"
@@ -149,31 +150,12 @@ static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
 	return 0;
 }
 
-static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
-{
-	const u32 *data;
-	int len, id, irq;
-
-	data = of_get_property(np, "reg", &len);
-	if (!data || len != 4)
-		return;
-
-	id = *data;
-	bus->phy_mask &= ~(1 << id);
-
-	irq = of_irq_to_resource(np, 0, NULL);
-	if (irq != NO_IRQ)
-		bus->irq[id] = irq;
-}
-
 static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
                                         const struct of_device_id *match)
 {
-	struct device_node *np = NULL;
 	struct mii_bus *new_bus;
 	struct bb_info *bitbang;
 	int ret = -ENOMEM;
-	int i;
 
 	bitbang = kzalloc(sizeof(struct bb_info), GFP_KERNEL);
 	if (!bitbang)
@@ -196,17 +178,10 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	if (!new_bus->irq)
 		goto out_unmap_regs;
 
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		new_bus->irq[i] = -1;
-
-	while ((np = of_get_next_child(ofdev->node, np)))
-		if (!strcmp(np->type, "ethernet-phy"))
-			add_phy(new_bus, np);
-
 	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
 
-	ret = mdiobus_register(new_bus);
+	ret = of_mdiobus_register(new_bus, ofdev->node);
 	if (ret)
 		goto out_free_irqs;
 
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 28077cc..bdc3160 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -102,23 +102,6 @@ static int fs_enet_fec_mii_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
-{
-	const u32 *data;
-	int len, id, irq;
-
-	data = of_get_property(np, "reg", &len);
-	if (!data || len != 4)
-		return;
-
-	id = *data;
-	bus->phy_mask &= ~(1 << id);
-
-	irq = of_irq_to_resource(np, 0, NULL);
-	if (irq != NO_IRQ)
-		bus->irq[id] = irq;
-}
-
 static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
                                         const struct of_device_id *match)
 {
@@ -165,17 +148,10 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	if (!new_bus->irq)
 		goto out_unmap_regs;
 
-	for (i = 0; i < PHY_MAX_ADDR; i++)
-		new_bus->irq[i] = -1;
-
-	while ((np = of_get_next_child(ofdev->node, np)))
-		if (!strcmp(np->type, "ethernet-phy"))
-			add_phy(new_bus, np);
-
 	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
 
-	ret = mdiobus_register(new_bus);
+	ret = of_mdiobus_register(new_bus, ofdev->node);
 	if (ret)
 		goto out_free_irqs;
 
diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 8300cab..51b7934 100644
--- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -17,6 +17,7 @@
 #define FS_ENET_PD_H
 
 #include <linux/string.h>
+#include <linux/of_mdio.h>
 #include <asm/types.h>
 
 #define FS_ENET_NAME	"fs_enet"
@@ -130,10 +131,7 @@ struct fs_platform_info {
 	
 	u32 device_flags;
 
-	int phy_addr;		/* the phy address (-1 no phy) */
-	char bus_id[16];
-	int phy_irq;		/* the phy irq (if it exists)  */
-
+	struct device_node *phy_node;
 	const struct fs_mii_bus_info *bus_info;
 
 	int rx_ring, tx_ring;	/* number of buffers on rx     */

