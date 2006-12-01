From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH 2.6.20] PHY: Add support for configuring the PHY connection
 interface
Date: Fri, 1 Dec 2006 12:01:06 -0600 (CST)
Message-ID: <Pine.LNX.4.61.0612011156330.15004@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:1787 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S1759311AbWLASBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 13:01:47 -0500
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
* Updates to PHY Lib consumers
* Changes to PHY Lib to add interface support
* Some minor changes to whitespace in phy.h
* gianfar driver now detects interface and passes appropriate
  value to PHY Lib
Signed-off-by: Andrew Fleming <afleming@freescale.com>
---
This version of the patch changes interface to be a typed enum, and 
switches gianfar to discover the interface, rather than having it passed 
in from the platform code.

 Documentation/networking/phy.txt   |   13 ++++++++----
 drivers/net/au1000_eth.c           |    3 ++-
 drivers/net/fs_enet/fs_enet-main.c |    3 ++-
 drivers/net/gianfar.c              |   39 ++++++++++++++++++++++++++++++++++--
 drivers/net/gianfar.h              |    3 +++
 drivers/net/phy/phy_device.c       |   29 ++++++++++++++++++---------
 include/linux/phy.h                |   26 ++++++++++++++++++------
 7 files changed, 93 insertions(+), 23 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 29ccae4..0bc95ea 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -1,7 +1,7 @@
 
 -------
 PHY Abstraction Layer
-(Updated 2005-07-21)
+(Updated 2006-11-30)
 
 Purpose
 
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
+		 u32 flags, phy_interface_t interface);
 
    Attaches a network device to a particular PHY, binding the PHY to a generic
    driver if none was found during bus initialization.  Passes in
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7db3c8a..f0b6879 100644
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
index a06d8d1..4fb9d96 100644
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
@@ -392,6 +392,38 @@ static int gfar_remove(struct platform_d
 }
 
 
+/* Reads the controller's registers to determine what interface
+ * connects it to the PHY.
+ */
+static phy_interface_t gfar_get_interface(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	u32 ecntrl = gfar_read(&priv->regs->ecntrl);
+
+	if (ecntrl & ECNTRL_SGMII_MODE)
+		return PHY_INTERFACE_MODE_SGMII;
+
+	if (ecntrl & ECNTRL_TBI_MODE) {
+		if (ecntrl & ECNTRL_REDUCED_MODE)
+			return PHY_INTERFACE_MODE_RTBI;
+		else
+			return PHY_INTERFACE_MODE_TBI;
+	}
+
+	if (ecntrl & ECNTRL_REDUCED_MODE) {
+		if (ecntrl & ECNTRL_REDUCED_MII_MODE)
+			return PHY_INTERFACE_MODE_RMII;
+		else
+			return PHY_INTERFACE_MODE_RGMII;
+	}
+
+	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT)
+		return PHY_INTERFACE_MODE_GMII;
+
+	return PHY_INTERFACE_MODE_MII;
+}
+
+
 /* Initializes driver's PHY state, and attaches to the PHY.
  * Returns 0 on success.
  */
@@ -403,6 +435,7 @@ static int init_phy(struct net_device *d
 		SUPPORTED_1000baseT_Full : 0;
 	struct phy_device *phydev;
 	char phy_id[BUS_ID_SIZE];
+	phy_interface_t interface;
 
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
@@ -410,7 +443,9 @@ static int init_phy(struct net_device *d
 
 	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
 
-	phydev = phy_connect(dev, phy_id, &adjust_link, 0);
+	interface = gfar_get_interface(dev);
+
+	phydev = phy_connect(dev, phy_id, &adjust_link, 0, interface);
 
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 9e81a50..39e9e32 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -160,7 +160,10 @@ #define MACCFG2_LENGTHCHECK	0x00000010
 
 #define ECNTRL_INIT_SETTINGS	0x00001000
 #define ECNTRL_TBI_MODE         0x00000020
+#define ECNTRL_REDUCED_MODE	0x00000010
 #define ECNTRL_R100		0x00000008
+#define ECNTRL_REDUCED_MII_MODE	0x00000004
+#define ECNTRL_SGMII_MODE	0x00000002
 
 #define MRBLR_INIT_SETTINGS	DEFAULT_RX_BUFFER_SIZE
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3bbd5e7..89af68d 100644
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
@@ -611,13 +627,8 @@ static int phy_probe(struct device *dev)
 
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
index 892d6ab..fb42e91 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -46,15 +46,26 @@ #define PHY_IGNORE_INTERRUPT	-2
 #define PHY_HAS_INTERRUPT	0x00000001
 #define PHY_HAS_MAGICANEG	0x00000002
 
+/* Interface Mode definitions */
+typedef enum {
+	PHY_INTERFACE_MODE_MII,
+	PHY_INTERFACE_MODE_GMII,
+	PHY_INTERFACE_MODE_SGMII,
+	PHY_INTERFACE_MODE_TBI,
+	PHY_INTERFACE_MODE_RMII,
+	PHY_INTERFACE_MODE_RGMII,
+	PHY_INTERFACE_MODE_RTBI
+} phy_interface_t;
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
@@ -86,8 +97,8 @@ struct mii_bus {
 	int *irq;
 };
 
-#define PHY_INTERRUPT_DISABLED 0x0
-#define PHY_INTERRUPT_ENABLED 0x80000000
+#define PHY_INTERRUPT_DISABLED	0x0
+#define PHY_INTERRUPT_ENABLED	0x80000000
 
 /* PHY state machine states:
  *
@@ -229,6 +240,8 @@ struct phy_device {
 
 	u32 dev_flags;
 
+	phy_interface_t interface;
+
 	/* Bus address of the PHY (0-32) */
 	int addr;
 
@@ -344,9 +357,10 @@ struct phy_device* get_phy_device(struct
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
 struct phy_device * phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags);
+		const char *phy_id, u32 flags, phy_interface_t interface);
 struct phy_device * phy_connect(struct net_device *dev, const char *phy_id,
-		void (*handler)(struct net_device *), u32 flags);
+		void (*handler)(struct net_device *), u32 flags,
+		phy_interface_t interface);
 void phy_disconnect(struct phy_device *phydev);
 void phy_detach(struct phy_device *phydev);
 void phy_start(struct phy_device *phydev);
-- 
1.4.2.3

