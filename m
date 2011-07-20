From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/4] stmmac: unify MAC and PHY configuration parameters (V2)
Date: Wed, 20 Jul 2011 12:05:23 +0200
Message-ID: <1311156324-23928-3-git-send-email-peppe.cavallaro@st.com>
References: <1311156324-23928-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Stuart Menefy <stuart.menefy@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:53907 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751244Ab1GTKHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 06:07:10 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7BB0DD1
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:07:04 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1919B1806
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:07:04 +0000 (GMT)
In-Reply-To: <1311156324-23928-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this change, most PHY configuration parameters were passed
into the STMMAC device as a separate PHY device. As well as being
unusual, this made it difficult to make changes to the MAC/PHY
relationship.

This patch moves all the PHY parameters into the MAC configuration
structure, mainly as a separate structure. This allows us to completely
ignore the MDIO bus attached to a stmmac if desired, and not create
the PHY bus. It also allows the stmmac driver to use a different PHY
from the one it is connected to, for example a fixed PHY or bit banging
PHY.

Also derive the stmmac/PHY connection type (MII/RMII etc) from the
mode can be passed into <platf>_configure_ethernet.
STLinux kernel at git://git.stlinux.com/stm/linux-sh4-2.6.32.y.git
provides several examples how to use this new infrastructure (that
actually is easier to maintain and clearer).

Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h      |    6 +--
 drivers/net/stmmac/stmmac_main.c |   95 +++-----------------------------------
 drivers/net/stmmac/stmmac_mdio.c |   83 +++++++++++++++++++++++----------
 include/linux/stmmac.h           |   24 +++++-----
 4 files changed, 77 insertions(+), 131 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 92c1d73..0b17429 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -56,14 +56,9 @@ struct stmmac_priv {
 	struct stmmac_extra_stats xstats;
 	struct napi_struct napi;
 
-	phy_interface_t phy_interface;
-	int phy_addr;
-	int phy_mask;
-	int (*phy_reset) (void *priv);
 	int rx_coe;
 	int no_csum_insertion;
 
-	int phy_irq;
 	struct phy_device *phydev;
 	int oldlink;
 	int speed;
@@ -71,6 +66,7 @@ struct stmmac_priv {
 	unsigned int flow_ctrl;
 	unsigned int pause;
 	struct mii_bus *mii;
+	int mii_irq[PHY_MAX_ADDR];
 
 	u32 msg_enable;
 	spinlock_t lock;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 9e02bd4..2856d66 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -49,7 +49,6 @@
 #include "stmmac.h"
 
 #define STMMAC_RESOURCE_NAME	"stmmaceth"
-#define PHY_RESOURCE_NAME	"stmmacphy"
 
 #undef STMMAC_DEBUG
 /*#define STMMAC_DEBUG*/
@@ -305,18 +304,13 @@ static int stmmac_init_phy(struct net_device *dev)
 	priv->speed = 0;
 	priv->oldduplex = -1;
 
-	if (priv->phy_addr == -1) {
-		/* We don't have a PHY, so do nothing */
-		return 0;
-	}
-
 	snprintf(bus_id, MII_BUS_ID_SIZE, "%x", priv->plat->bus_id);
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
-		 priv->phy_addr);
+		 priv->plat->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
 
 	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0,
-			priv->phy_interface);
+			     priv->plat->interface);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
@@ -335,7 +329,7 @@ static int stmmac_init_phy(struct net_device *dev)
 		return -ENODEV;
 	}
 	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
-	       " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
+		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
 
 	priv->phydev = phydev;
 
@@ -1543,71 +1537,6 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	return 0;
 }
 
-static int stmmacphy_dvr_probe(struct platform_device *pdev)
-{
-	struct plat_stmmacphy_data *plat_dat = pdev->dev.platform_data;
-
-	pr_debug("stmmacphy_dvr_probe: added phy for bus %d\n",
-	       plat_dat->bus_id);
-
-	return 0;
-}
-
-static int stmmacphy_dvr_remove(struct platform_device *pdev)
-{
-	return 0;
-}
-
-static struct platform_driver stmmacphy_driver = {
-	.driver = {
-		   .name = PHY_RESOURCE_NAME,
-		   },
-	.probe = stmmacphy_dvr_probe,
-	.remove = stmmacphy_dvr_remove,
-};
-
-/**
- * stmmac_associate_phy
- * @dev: pointer to device structure
- * @data: points to the private structure.
- * Description: Scans through all the PHYs we have registered and checks if
- * any are associated with our MAC.  If so, then just fill in
- * the blanks in our local context structure
- */
-static int stmmac_associate_phy(struct device *dev, void *data)
-{
-	struct stmmac_priv *priv = (struct stmmac_priv *)data;
-	struct plat_stmmacphy_data *plat_dat = dev->platform_data;
-
-	DBG(probe, DEBUG, "%s: checking phy for bus %d\n", __func__,
-		plat_dat->bus_id);
-
-	/* Check that this phy is for the MAC being initialised */
-	if (priv->plat->bus_id != plat_dat->bus_id)
-		return 0;
-
-	/* OK, this PHY is connected to the MAC.
-	   Go ahead and get the parameters */
-	DBG(probe, DEBUG, "%s: OK. Found PHY config\n", __func__);
-	priv->phy_irq =
-	    platform_get_irq_byname(to_platform_device(dev), "phyirq");
-	DBG(probe, DEBUG, "%s: PHY irq on bus %d is %d\n", __func__,
-	    plat_dat->bus_id, priv->phy_irq);
-
-	/* Override with kernel parameters if supplied XXX CRS XXX
-	 * this needs to have multiple instances */
-	if ((phyaddr >= 0) && (phyaddr <= 31))
-		plat_dat->phy_addr = phyaddr;
-
-	priv->phy_addr = plat_dat->phy_addr;
-	priv->phy_mask = plat_dat->phy_mask;
-	priv->phy_interface = plat_dat->interface;
-	priv->phy_reset = plat_dat->phy_reset;
-
-	DBG(probe, DEBUG, "%s: exiting\n", __func__);
-	return 1;	/* forces exit of driver_for_each_device() */
-}
-
 /**
  * stmmac_dvr_probe
  * @pdev: platform device pointer
@@ -1698,14 +1627,10 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	if (ret < 0)
 		goto out_plat_exit;
 
-	/* associate a PHY - it is provided by another platform bus */
-	if (!driver_for_each_device
-	    (&(stmmacphy_driver.driver), NULL, (void *)priv,
-	     stmmac_associate_phy)) {
-		pr_err("No PHY device is associated with this MAC!\n");
-		ret = -ENODEV;
-		goto out_unregister;
-	}
+	/* Override with kernel parameters if supplied XXX CRS XXX
+	 * this needs to have multiple instances */
+	if ((phyaddr >= 0) && (phyaddr <= 31))
+		priv->plat->phy_addr = phyaddr;
 
 	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
 	       "\tIO base addr: 0x%p)\n", ndev->name, pdev->name,
@@ -1905,11 +1830,6 @@ static int __init stmmac_init_module(void)
 {
 	int ret;
 
-	if (platform_driver_register(&stmmacphy_driver)) {
-		pr_err("No PHY devices registered!\n");
-		return -ENODEV;
-	}
-
 	ret = platform_driver_register(&stmmac_driver);
 	return ret;
 }
@@ -1920,7 +1840,6 @@ static int __init stmmac_init_module(void)
  */
 static void __exit stmmac_cleanup_module(void)
 {
-	platform_driver_unregister(&stmmacphy_driver);
 	platform_driver_unregister(&stmmac_driver);
 }
 
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index 234b406..b1c3ecf 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -112,9 +112,9 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned int mii_address = priv->hw->mii.addr;
 
-	if (priv->phy_reset) {
+	if (priv->plat->mdio_bus_data->phy_reset) {
 		pr_debug("stmmac_mdio_reset: calling phy_reset\n");
-		priv->phy_reset(priv->plat->bsp_priv);
+		priv->plat->mdio_bus_data->phy_reset(priv->plat->bsp_priv);
 	}
 
 	/* This is a workaround for problems with the STE101P PHY.
@@ -137,30 +137,29 @@ int stmmac_mdio_register(struct net_device *ndev)
 	struct mii_bus *new_bus;
 	int *irqlist;
 	struct stmmac_priv *priv = netdev_priv(ndev);
+	struct stmmac_mdio_bus_data *mdio_bus_data = priv->plat->mdio_bus_data;
 	int addr, found;
 
+	if (!mdio_bus_data)
+		return 0;
+
 	new_bus = mdiobus_alloc();
 	if (new_bus == NULL)
 		return -ENOMEM;
 
-	irqlist = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (irqlist == NULL) {
-		err = -ENOMEM;
-		goto irqlist_alloc_fail;
-	}
-
-	/* Assign IRQ to phy at address phy_addr */
-	if (priv->phy_addr != -1)
-		irqlist[priv->phy_addr] = priv->phy_irq;
+	if (mdio_bus_data->irqs)
+		irqlist = mdio_bus_data->irqs;
+	else
+		irqlist = priv->mii_irq;
 
 	new_bus->name = "STMMAC MII Bus";
 	new_bus->read = &stmmac_mdio_read;
 	new_bus->write = &stmmac_mdio_write;
 	new_bus->reset = &stmmac_mdio_reset;
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", priv->plat->bus_id);
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", mdio_bus_data->bus_id);
 	new_bus->priv = ndev;
 	new_bus->irq = irqlist;
-	new_bus->phy_mask = priv->phy_mask;
+	new_bus->phy_mask = mdio_bus_data->phy_mask;
 	new_bus->parent = priv->device;
 	err = mdiobus_register(new_bus);
 	if (err != 0) {
@@ -171,18 +170,50 @@ int stmmac_mdio_register(struct net_device *ndev)
 	priv->mii = new_bus;
 
 	found = 0;
-	for (addr = 0; addr < 32; addr++) {
+	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
 		struct phy_device *phydev = new_bus->phy_map[addr];
 		if (phydev) {
-			if (priv->phy_addr == -1) {
-				priv->phy_addr = addr;
-				phydev->irq = priv->phy_irq;
-				irqlist[addr] = priv->phy_irq;
+			int act = 0;
+			char irq_num[4];
+			char *irq_str;
+
+			/*
+			 * If an IRQ was provided to be assigned after
+			 * the bus probe, do it here.
+			 */
+			if ((mdio_bus_data->irqs == NULL) &&
+			    (mdio_bus_data->probed_phy_irq > 0)) {
+				irqlist[addr] = mdio_bus_data->probed_phy_irq;
+				phydev->irq = mdio_bus_data->probed_phy_irq;
 			}
-			pr_info("%s: PHY ID %08x at %d IRQ %d (%s)%s\n",
-			       ndev->name, phydev->phy_id, addr,
-			       phydev->irq, dev_name(&phydev->dev),
-			       (addr == priv->phy_addr) ? " active" : "");
+
+			/*
+			 * If we're  going to bind the MAC to this PHY bus,
+			 * and no PHY number was provided to the MAC,
+			 * use the one probed here.
+			 */
+			if ((priv->plat->bus_id == mdio_bus_data->bus_id) &&
+			    (priv->plat->phy_addr == -1))
+				priv->plat->phy_addr = addr;
+
+			act = (priv->plat->bus_id == mdio_bus_data->bus_id) &&
+				(priv->plat->phy_addr == addr);
+			switch (phydev->irq) {
+			case PHY_POLL:
+				irq_str = "POLL";
+				break;
+			case PHY_IGNORE_INTERRUPT:
+				irq_str = "IGNORE";
+				break;
+			default:
+				sprintf(irq_num, "%d", phydev->irq);
+				irq_str = irq_num;
+				break;
+			}
+			pr_info("%s: PHY ID %08x at %d IRQ %s (%s)%s\n",
+				ndev->name, phydev->phy_id, addr,
+				irq_str, dev_name(&phydev->dev),
+				act ? " active" : "");
 			found = 1;
 		}
 	}
@@ -191,10 +222,9 @@ int stmmac_mdio_register(struct net_device *ndev)
 		pr_warning("%s: No PHY found\n", ndev->name);
 
 	return 0;
+
 bus_register_fail:
-	kfree(irqlist);
-irqlist_alloc_fail:
-	kfree(new_bus);
+	mdiobus_free(new_bus);
 	return err;
 }
 
@@ -209,7 +239,8 @@ int stmmac_mdio_unregister(struct net_device *ndev)
 
 	mdiobus_unregister(priv->mii);
 	priv->mii->priv = NULL;
-	kfree(priv->mii);
+	mdiobus_free(priv->mii);
+	priv->mii = NULL;
 
 	return 0;
 }
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 05d7756..0dddc9e 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -28,11 +28,21 @@
 
 #include <linux/platform_device.h>
 
-/* platform data for platform device structure's platform_data field */
+/* Platfrom data for platform device structure's platform_data field */
+
+struct stmmac_mdio_bus_data {
+	int bus_id;
+	int (*phy_reset)(void *priv);
+	unsigned int phy_mask;
+	int *irqs;
+	int probed_phy_irq;
+};
 
-/* Private data for the STM on-board ethernet driver */
 struct plat_stmmacenet_data {
 	int bus_id;
+	int phy_addr;
+	int interface;
+	struct stmmac_mdio_bus_data *mdio_bus_data;
 	int pbl;
 	int clk_csr;
 	int has_gmac;
@@ -48,14 +58,4 @@ struct plat_stmmacenet_data {
 	void *custom_cfg;
 	void *bsp_priv;
 };
-
-struct plat_stmmacphy_data {
-	int bus_id;
-	int phy_addr;
-	unsigned int phy_mask;
-	int interface;
-	int (*phy_reset)(void *priv);
-	void *priv;
-};
 #endif
-
-- 
1.7.4.4

