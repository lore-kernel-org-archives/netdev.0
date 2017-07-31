From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/7] net: bcmgenet: utilize generic Broadcom UniMAC MDIO controller driver
Date: Mon, 31 Jul 2017 12:04:26 -0700
Message-ID: <20170731190429.24204-6-f.fainelli@gmail.com>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33886 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdGaTEt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:49 -0400
Received: by mail-wr0-f193.google.com with SMTP id o33so24837395wrb.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:48 -0700 (PDT)
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the GENET driver to register an UniMAC MDIO bus controller for
the GENET internal MDIO bus, update the platform data code to attach the
PHY to the correct MDIO bus controller.

The Device Tree portion of the code is mostly left unmodified since the
lookup/binding is done via phandles and Device Tree nodes which are much
more flexible in locating and binding PHYs to their respective MDIO bus
controllers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/Kconfig          |   1 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 148 +++++++++++++++++++------
 3 files changed, 116 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 285f8bc25682..ec7a798c6bd1 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -65,6 +65,7 @@ config BCMGENET
 	select PHYLIB
 	select FIXED_PHY
 	select BCM7XXX_PHY
+	select MDIO_BCM_UNIMAC
 	help
 	  This driver supports the built-in Ethernet MACs found in the
 	  Broadcom BCM7xxx Set Top Box family chipset.
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index b9344de669f8..4775999ee016 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -657,6 +657,7 @@ struct bcmgenet_priv {
 
 	struct clk *clk;
 	struct platform_device *pdev;
+	struct platform_device *mii_pdev;
 
 	/* WOL */
 	struct clk *clk_wol;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 071fcbd14e6a..368d5eab306b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -24,6 +24,7 @@
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
 #include <linux/platform_data/bcmgenet.h>
+#include <linux/platform_data/mdio-bcm-unimac.h>
 
 #include "bcmgenet.h"
 
@@ -464,31 +465,120 @@ static int bcmgenet_mii_alloc(struct bcmgenet_priv *priv)
 	return 0;
 }
 
-static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
+static struct device_node *bcmgenet_mii_of_find_mdio(struct bcmgenet_priv *priv)
 {
 	struct device_node *dn = priv->pdev->dev.of_node;
 	struct device *kdev = &priv->pdev->dev;
-	struct phy_device *phydev = NULL;
 	char *compat;
-	int phy_mode;
-	int ret;
 
 	compat = kasprintf(GFP_KERNEL, "brcm,genet-mdio-v%d", priv->version);
 	if (!compat)
-		return -ENOMEM;
+		return NULL;
 
 	priv->mdio_dn = of_find_compatible_node(dn, NULL, compat);
 	kfree(compat);
 	if (!priv->mdio_dn) {
 		dev_err(kdev, "unable to find MDIO bus node\n");
-		return -ENODEV;
+		return NULL;
 	}
 
-	ret = of_mdiobus_register(priv->mii_bus, priv->mdio_dn);
-	if (ret) {
-		dev_err(kdev, "failed to register MDIO bus\n");
-		return ret;
+	return priv->mdio_dn;
+}
+
+static void bcmgenet_mii_pdata_init(struct bcmgenet_priv *priv,
+				    struct unimac_mdio_pdata *ppd)
+{
+	struct device *kdev = &priv->pdev->dev;
+	struct bcmgenet_platform_data *pd = kdev->platform_data;
+
+	if (pd->phy_interface != PHY_INTERFACE_MODE_MOCA && pd->mdio_enabled) {
+		/*
+		 * Internal or external PHY with MDIO access
+		 */
+		if (pd->phy_address >= 0 && pd->phy_address < PHY_MAX_ADDR)
+			ppd->phy_mask = 1 << pd->phy_address;
+		else
+			ppd->phy_mask = 0;
 	}
+}
+
+static int bcmgenet_mii_wait(void *wait_func_data)
+{
+	struct bcmgenet_priv *priv = wait_func_data;
+
+	wait_event_timeout(priv->wq,
+			   !(bcmgenet_umac_readl(priv, UMAC_MDIO_CMD)
+			   & MDIO_START_BUSY),
+			   HZ / 100);
+	return 0;
+}
+
+static int bcmgenet_mii_register(struct bcmgenet_priv *priv)
+{
+	struct platform_device *pdev = priv->pdev;
+	struct bcmgenet_platform_data *pdata = pdev->dev.platform_data;
+	struct device_node *dn = pdev->dev.of_node;
+	struct unimac_mdio_pdata ppd;
+	struct platform_device *ppdev;
+	struct resource *pres, res;
+	int id, ret;
+
+	pres = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	memset(&res, 0, sizeof(res));
+	memset(&ppd, 0, sizeof(ppd));
+
+	ppd.wait_func = bcmgenet_mii_wait;
+	ppd.wait_func_data = priv;
+	ppd.bus_name = "bcmgenet MII bus";
+
+	/* Unimac MDIO bus controller starts at UniMAC offset + MDIO_CMD
+	 * and is 2 * 32-bits word long, 8 bytes total.
+	 */
+	res.start = pres->start + GENET_UMAC_OFF + UMAC_MDIO_CMD;
+	res.end = res.start + 8;
+	res.flags = IORESOURCE_MEM;
+
+	if (dn)
+		id = of_alias_get_id(dn, "eth");
+	else
+		id = pdev->id;
+
+	ppdev = platform_device_alloc(UNIMAC_MDIO_DRV_NAME, id);
+	if (!ppdev)
+		return -ENOMEM;
+
+	/* Retain this platform_device pointer for later cleanup */
+	priv->mii_pdev = ppdev;
+	ppdev->dev.parent = &pdev->dev;
+	ppdev->dev.of_node = bcmgenet_mii_of_find_mdio(priv);
+	if (pdata)
+		bcmgenet_mii_pdata_init(priv, &ppd);
+
+	ret = platform_device_add_resources(ppdev, &res, 1);
+	if (ret)
+		goto out;
+
+	ret = platform_device_add_data(ppdev, &ppd, sizeof(ppd));
+	if (ret)
+		goto out;
+
+	ret = platform_device_add(ppdev);
+	if (ret)
+		goto out;
+
+	return 0;
+out:
+	platform_device_put(ppdev);
+	return ret;
+}
+
+static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
+{
+	struct device_node *dn = priv->pdev->dev.of_node;
+	struct device *kdev = &priv->pdev->dev;
+	struct phy_device *phydev;
+	int phy_mode;
+	int ret;
 
 	/* Fetch the PHY phandle */
 	priv->phy_dn = of_parse_phandle(dn, "phy-handle", 0);
@@ -536,33 +626,23 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 {
 	struct device *kdev = &priv->pdev->dev;
 	struct bcmgenet_platform_data *pd = kdev->platform_data;
-	struct mii_bus *mdio = priv->mii_bus;
+	char phy_name[MII_BUS_ID_SIZE + 3];
+	char mdio_bus_id[MII_BUS_ID_SIZE];
 	struct phy_device *phydev;
-	int ret;
+
+	snprintf(mdio_bus_id, MII_BUS_ID_SIZE, "%s-%d",
+		 UNIMAC_MDIO_DRV_NAME, priv->pdev->id);
 
 	if (pd->phy_interface != PHY_INTERFACE_MODE_MOCA && pd->mdio_enabled) {
+		snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT,
+			 mdio_bus_id, pd->phy_address);
+
 		/*
 		 * Internal or external PHY with MDIO access
 		 */
-		if (pd->phy_address >= 0 && pd->phy_address < PHY_MAX_ADDR)
-			mdio->phy_mask = ~(1 << pd->phy_address);
-		else
-			mdio->phy_mask = 0;
-
-		ret = mdiobus_register(mdio);
-		if (ret) {
-			dev_err(kdev, "failed to register MDIO bus\n");
-			return ret;
-		}
-
-		if (pd->phy_address >= 0 && pd->phy_address < PHY_MAX_ADDR)
-			phydev = mdiobus_get_phy(mdio, pd->phy_address);
-		else
-			phydev = phy_find_first(mdio);
-
+		phydev = phy_attach(priv->dev, phy_name, pd->phy_interface);
 		if (!phydev) {
 			dev_err(kdev, "failed to register PHY device\n");
-			mdiobus_unregister(mdio);
 			return -ENODEV;
 		}
 	} else {
@@ -611,7 +691,7 @@ int bcmgenet_mii_init(struct net_device *dev)
 	struct device_node *dn = priv->pdev->dev.of_node;
 	int ret;
 
-	ret = bcmgenet_mii_alloc(priv);
+	ret = bcmgenet_mii_register(priv);
 	if (ret)
 		return ret;
 
@@ -625,8 +705,8 @@ int bcmgenet_mii_init(struct net_device *dev)
 	if (of_phy_is_fixed_link(dn))
 		of_phy_deregister_fixed_link(dn);
 	of_node_put(priv->phy_dn);
-	mdiobus_unregister(priv->mii_bus);
-	mdiobus_free(priv->mii_bus);
+	platform_device_unregister(priv->mii_pdev);
+	platform_device_put(priv->mii_pdev);
 	return ret;
 }
 
@@ -638,6 +718,6 @@ void bcmgenet_mii_exit(struct net_device *dev)
 	if (of_phy_is_fixed_link(dn))
 		of_phy_deregister_fixed_link(dn);
 	of_node_put(priv->phy_dn);
-	mdiobus_unregister(priv->mii_bus);
-	mdiobus_free(priv->mii_bus);
+	platform_device_unregister(priv->mii_pdev);
+	platform_device_put(priv->mii_pdev);
 }
-- 
2.9.3
