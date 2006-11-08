From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] Add support for configuring the PHY connection interface
Date: Wed, 8 Nov 2006 00:10:23 -0600 (CST)
Message-ID: <Pine.LNX.4.61.0611080009010.6936@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:21941 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1754344AbWKHGK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 01:10:57 -0500
To: Netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Kumar Gala <galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most PHYs connect to an ethernet controller over a GMII or MII
interface.  However, a growing number are connected over
different interfaces, such as RGMII or SGMII.

The ethernet driver will tell the PHY what type of connection it
is by setting it manually, or passing it in through phy_connect
(or phy_attach).

Changes include:
* Updates to documentation
* Updates to other PHY Lib consumers
* Changes to PHY Lib to add interface support
* Some minor changes to whitespace in phy.h
* interface values now passed to gianfar

Signed-off-by: Andrew Fleming <afleming@freescale.com>
---
 Documentation/networking/phy.txt   |   11 ++++++++---
 arch/powerpc/sysdev/fsl_soc.c      |   36 ++++++++++++++++++++++++++++++++++++
 drivers/net/au1000_eth.c           |    3 ++-
 drivers/net/fs_enet/fs_enet-main.c |    3 ++-
 drivers/net/gianfar.c              |    5 +++--
 drivers/net/phy/phy_device.c       |   29 ++++++++++++++++++++---------
 include/linux/phy.h                |   32 ++++++++++++++++++++++++++------
 7 files changed, 97 insertions(+), 22 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 29ccae4..1c9873d 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -97,11 +97,12 @@ Letting the PHY Abstraction Layer do Eve
  
  Next, you need to know the device name of the PHY connected to this device. 
  The name will look something like, "phy0:0", where the first number is the
- bus id, and the second is the PHY's address on that bus.
+ bus id, and the second is the PHY's address on that bus.  Typically,
+ the bus is responsible for making its ID unique.
  
  Now, to connect, just call this function:
  
-   phydev = phy_connect(dev, phy_name, &adjust_link, flags);
+   phydev = phy_connect(dev, phy_name, &adjust_link, flags, interface);
 
  phydev is a pointer to the phy_device structure which represents the PHY.  If
  phy_connect is successful, it will return the pointer.  dev, here, is the
@@ -115,6 +116,10 @@ Letting the PHY Abstraction Layer do Eve
  This is useful if the system has put hardware restrictions on
  the PHY/controller, of which the PHY needs to be aware.
 
+ interface is a u32 which specifies the connection type used
+ between the controller and the PHY.  Examples are GMII, MII,
+ RGMII, and SGMII.  For a full list, see include/linux/phy.h
+
  Now just make sure that phydev->supported and phydev->advertising have any
  values pruned from them which don't make sense for your controller (a 10/100
  controller may be connected to a gigabit capable PHY, so you would need to
@@ -191,7 +196,7 @@ Doing it all yourself
    start, or disables then frees them for stop.
 
  struct phy_device * phy_attach(struct net_device *dev, const char *phy_id,
-		 u32 flags);
+		 u32 flags, u32 interface);
 
    Attaches a network device to a particular PHY, binding the PHY to a generic
    driver if none was found during bus initialization.  Passes in
diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index b4b5b4a..b053370 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -211,6 +211,36 @@ static int __init gfar_set_flags(struct 
 	return device_flags;
 }
 
+/* Return the Linux interface mode type based on the
+ * specification in the device-tree */
+static int __init gfar_get_interface(struct device_node *np)
+{
+	const char *istr;
+	int interface = 0;
+
+	istr = get_property(np, "interface", NULL);
+
+	if (istr == NULL)
+		istr = "GMII";
+
+	if (!strcasecmp(istr, "GMII"))
+		interface = PHY_INTERFACE_MODE_GMII;
+	else if (!strcasecmp(istr, "MII"))
+		interface = PHY_INTERFACE_MODE_MII;
+	else if (!strcasecmp(istr, "RGMII"))
+		interface = PHY_INTERFACE_MODE_RGMII;
+	else if (!strcasecmp(istr, "SGMII"))
+		interface = PHY_INTERFACE_MODE_SGMII;
+	else if (!strcasecmp(istr, "TBI"))
+		interface = PHY_INTERFACE_MODE_TBI;
+	else if (!strcasecmp(istr, "RMII"))
+		interface = PHY_INTERFACE_MODE_RMII;
+	else if (!strcasecmp(istr, "RTBI"))
+		interface = PHY_INTERFACE_MODE_RTBI;
+
+	return interface;
+}
+
 static struct device_node * __init gfar_get_phy_node(struct device_node *np)
 {
 	const phandle *ph;
@@ -342,6 +372,12 @@ static int __init gfar_of_init(void)
 		if (mac_addr)
 			memcpy(gfar_data.mac_addr, mac_addr, 6);
 
+		gfar_data.interface = gfar_get_interface(np);
+		if (gfar_data.interface == 0) {
+			printk("gfar %d failed to set interface\n", num);
+			continue;
+		}
+
 		ret = gfar_set_phy_info(np, &gfar_data.phy_id,
 				&gfar_data.bus_id, &gfar_data.phy_flags);
   		if (ret) {
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 4873dc6..ad540ce 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -360,7 +360,8 @@ #endif /* defined(AU1XXX_PHY_STATIC_CONF
 	BUG_ON(!phydev);
 	BUG_ON(phydev->attached_dev);
 
-	phydev = phy_connect(dev, phydev->dev.bus_id, &au1000_adjust_link, 0);
+	phydev = phy_connect(dev, phydev->dev.bus_id, &au1000_adjust_link, 0,
+			PHY_INTERFACE_MODE_MII);
 
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index cb39587..889d3a1 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -779,7 +779,8 @@ static int fs_init_phy(struct net_device
 	fep->oldspeed = 0;
 	fep->oldduplex = -1;
 	if(fep->fpi->bus_id)
-		phydev = phy_connect(dev, fep->fpi->bus_id, &fs_adjust_link, 0);
+		phydev = phy_connect(dev, fep->fpi->bus_id, &fs_adjust_link, 0,
+				PHY_INTERFACE_MODE_MII);
 	else {
 		printk("No phy bus ID specified in BSP code\n");
 		return -EINVAL;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index a06d8d1..80e4aec 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -9,7 +9,7 @@
  * Author: Andy Fleming
  * Maintainer: Kumar Gala
  *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ * Copyright (c) 2002-2006 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -410,7 +410,8 @@ static int init_phy(struct net_device *d
 
 	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
 
-	phydev = phy_connect(dev, phy_id, &adjust_link, 0);
+	phydev = phy_connect(dev, phy_id, &adjust_link, 0,
+			priv->einfo->interface);
 
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 2a08b2b..b01fc70 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -59,6 +59,7 @@ struct phy_device* phy_device_create(str
 	dev->duplex = -1;
 	dev->pause = dev->asym_pause = 0;
 	dev->link = 1;
+	dev->interface = PHY_INTERFACE_MODE_GMII;
 
 	dev->autoneg = AUTONEG_ENABLE;
 
@@ -137,11 +138,12 @@ void phy_prepare_link(struct phy_device 
  *   the desired functionality.
  */
 struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
-		void (*handler)(struct net_device *), u32 flags)
+		void (*handler)(struct net_device *), u32 flags,
+		u32 interface)
 {
 	struct phy_device *phydev;
 
-	phydev = phy_attach(dev, phy_id, flags);
+	phydev = phy_attach(dev, phy_id, flags, interface);
 
 	if (IS_ERR(phydev))
 		return phydev;
@@ -186,7 +188,7 @@ static int phy_compare_id(struct device 
 }
 
 struct phy_device *phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags)
+		const char *phy_id, u32 flags, u32 interface)
 {
 	struct bus_type *bus = &mdio_bus_type;
 	struct phy_device *phydev;
@@ -231,6 +233,20 @@ struct phy_device *phy_attach(struct net
 
 	phydev->dev_flags = flags;
 
+	phydev->interface = interface;
+
+	/* Do initial configuration here, now that
+	 * we have certain key parameters
+	 * (dev_flags and interface) */
+	if (phydev->drv->config_init) {
+		int err;
+
+		err = phydev->drv->config_init(phydev);
+
+		if (err < 0)
+			return ERR_PTR(err);
+	}
+
 	return phydev;
 }
 EXPORT_SYMBOL(phy_attach);
@@ -612,13 +628,8 @@ static int phy_probe(struct device *dev)
 
 	spin_unlock(&phydev->lock);
 
-	if (err < 0)
-		return err;
-
-	if (phydev->drv->config_init)
-		err = phydev->drv->config_init(phydev);
-
 	return err;
+
 }
 
 static int phy_remove(struct device *dev)
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 892d6ab..7d9ead0 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -46,15 +46,32 @@ #define PHY_IGNORE_INTERRUPT	-2
 #define PHY_HAS_INTERRUPT	0x00000001
 #define PHY_HAS_MAGICANEG	0x00000002
 
+/* Interface Mode definitions */
+#define PHY_INTERFACE_MODE_MII		(0)
+#define PHY_INTERFACE_MODE_GMII		(1)
+#define PHY_INTERFACE_MODE_SGMII	(1 << 1)
+#define PHY_INTERFACE_MODE_TBI		(1 << 2)
+
+/* Make the reduced modes all have the upper bit set,
+ * so that controllers/PHYs that use that information
+ * can get at it easily (also, it saves bit space)
+ */
+#define PHY_INTERFACE_MODE_REDUCED	0x80000000
+#define _reduced(x)			(PHY_INTERFACE_MODE_REDUCED | x)
+#define PHY_INTERFACE_MODE_RGMII	_reduced(PHY_INTERFACE_MODE_GMII)
+#define PHY_INTERFACE_MODE_RMII		_reduced(PHY_INTERFACE_MODE_MII)
+#define PHY_INTERFACE_MODE_RTBI		_reduced(PHY_INTERFACE_MODE_TBI)
+
+
 #define MII_BUS_MAX 4
 
 
-#define PHY_INIT_TIMEOUT 100000
+#define PHY_INIT_TIMEOUT	100000
 #define PHY_STATE_TIME		1
 #define PHY_FORCE_TIMEOUT	10
 #define PHY_AN_TIMEOUT		10
 
-#define PHY_MAX_ADDR 32
+#define PHY_MAX_ADDR	32
 
 /* Used when trying to connect to a specific phy (mii bus id:phy device id) */
 #define PHY_ID_FMT "%x:%02x"
@@ -86,8 +103,8 @@ struct mii_bus {
 	int *irq;
 };
 
-#define PHY_INTERRUPT_DISABLED 0x0
-#define PHY_INTERRUPT_ENABLED 0x80000000
+#define PHY_INTERRUPT_DISABLED	0x0
+#define PHY_INTERRUPT_ENABLED	0x80000000
 
 /* PHY state machine states:
  *
@@ -229,6 +246,8 @@ struct phy_device {
 
 	u32 dev_flags;
 
+	u32 interface;
+
 	/* Bus address of the PHY (0-32) */
 	int addr;
 
@@ -344,9 +363,10 @@ struct phy_device* get_phy_device(struct
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
 struct phy_device * phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags);
+		const char *phy_id, u32 flags, u32 interface);
 struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
-		void (*handler)(struct net_device *), u32 flags);
+		void (*handler)(struct net_device *), u32 flags,
+		u32 interface);
 void phy_disconnect(struct phy_device *phydev);
 void phy_detach(struct phy_device *phydev);
 void phy_start(struct phy_device *phydev);
-- 
1.4.2.3

