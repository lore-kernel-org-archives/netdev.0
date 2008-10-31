From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH 1/2] gianfar: Fix race in TBI/SerDes configuration
Date: Thu, 30 Oct 2008 18:17:06 -0700
Message-ID: <1225415827-8167-1-git-send-email-tpiepho@freescale.com>
References: <Pine.LNX.4.64.0810301738020.3943@t2.domain.actdsltmp>
Cc: linuxppc-dev@ozlabs.org, Nate Case <ncase@xes-inc.com>,
	Trent Piepho <tpiepho@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48246 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbYJaBRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 21:17:50 -0400
In-Reply-To: <Pine.LNX.4.64.0810301738020.3943@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The init_phy() function attaches to the PHY, then configures the
SerDes<->TBI link (in SGMII mode).  The TBI is on the MDIO bus with the PHY
(sort of) and is accessed via the gianfar's MDIO registers, using the
functions gfar_local_mdio_read/write(), which don't do any locking.

The previously attached PHY will start a work-queue on a timer, and
probably an irq handler as well, which will talk to the PHY and thus use
the MDIO bus.  This uses phy_read/write(), which have locking, but not
against the gfar_local_mdio versions.

The result is that PHY code will try to use the MDIO bus at the same time
as the SerDes setup code, corrupting the transfers.

Setting up the SerDes before attaching to the PHY will insure that there is
no race between the SerDes code and *our* PHY, but doesn't fix everything.
Typically the PHYs for all gianfar devices are on the same MDIO bus, which
is associated with the first gianfar device.  This means that the first
gianfar's SerDes code could corrupt the MDIO transfers for a different
gianfar's PHY.

The lock used by phy_read/write() is contained in the mii_bus structure,
which is pointed to by the PHY.  This is difficult to access from the
gianfar drivers, as there is no link between a gianfar device and the
mii_bus which shares the same MDIO registers.  As far as the device layer
and drivers are concerned they are two unrelated devices (which happen to
share registers).

Generally all gianfar devices' PHYs will be on the bus associated with the
first gianfar.  But this might not be the case, so simply locking the
gianfar's PHY's mii bus might not lock the mii bus that the SerDes setup
code is going to use.

We solve this by having the code that creates the gianfar platform device
look in the device tree for an mdio device that shares the gianfar's
registers.  If one is found the ID of its platform device is saved in the
gianfar's platform data.

A new function in the gianfar mii code, gfar_get_miibus(), can use the bus
ID to search through the platform devices for a gianfar_mdio device with
the right ID.  The platform device's driver data is the mii_bus structure,
which the SerDes setup code can use to lock the current bus.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
CC: Andy Fleming <afleming@freescale.com>
---
 arch/powerpc/sysdev/fsl_soc.c |   26 ++++++++++++++++++++++++++
 drivers/net/gianfar.c         |    7 +++++++
 drivers/net/gianfar_mii.c     |   21 +++++++++++++++++++++
 drivers/net/gianfar_mii.h     |    3 +++
 include/linux/fsl_devices.h   |    3 ++-
 5 files changed, 59 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index 01b884b..26ecb96 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -223,6 +223,8 @@ static int gfar_mdio_of_init_one(struct device_node *np)
 	if (ret)
 		return ret;
 
+	/* The gianfar device will try to use the same ID created below to find
+	 * this bus, to coordinate register access (since they share).  */
 	mdio_dev = platform_device_register_simple("fsl-gianfar_mdio",
 			res.start&0xfffff, &res, 1);
 	if (IS_ERR(mdio_dev))
@@ -394,6 +396,30 @@ static int __init gfar_of_init(void)
 			of_node_put(mdio);
 		}
 
+		/* Get MDIO bus controlled by this eTSEC, if any.  Normally only
+		 * eTSEC 1 will control an MDIO bus, not necessarily the same
+		 * bus that its PHY is on ('mdio' above), so we can't just use
+		 * that.  What we do is look for a gianfar mdio device that has
+		 * overlapping registers with this device.  That's really the
+		 * whole point, to find the device sharing our registers to
+		 * coordinate access with it.
+		 */
+		for_each_compatible_node(mdio, NULL, "fsl,gianfar-mdio") {
+			if (of_address_to_resource(mdio, 0, &res))
+				continue;
+
+			if (res.start >= r[0].start && res.end <= r[0].end) {
+				/* Get the ID the mdio bus platform device was
+				 * registered with.  gfar_data.bus_id is
+				 * different because it's for finding a PHY,
+				 * while this is for finding a MII bus.
+				 */
+				gfar_data.mdio_bus = res.start&0xfffff;
+				of_node_put(mdio);
+				break;
+			}
+		}
+
 		ret =
 		    platform_device_add_data(gfar_dev, &gfar_data,
 					     sizeof(struct
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 64b2011..249541a 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -586,6 +586,10 @@ static void gfar_configure_serdes(struct net_device *dev)
 	struct gfar_mii __iomem *regs =
 			(void __iomem *)&priv->regs->gfar_mii_regs;
 	int tbipa = gfar_read(&priv->regs->tbipa);
+	struct mii_bus *bus = gfar_get_miibus(priv);
+
+	if (bus)
+		mutex_lock(&bus->mdio_lock);
 
 	/* Single clk mode, mii mode off(for serdes communication) */
 	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
@@ -596,6 +600,9 @@ static void gfar_configure_serdes(struct net_device *dev)
 
 	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
+
+	if (bus)
+		mutex_unlock(&bus->mdio_lock);
 }
 
 static void init_registers(struct net_device *dev)
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index bf73eea..0e2595d 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -269,6 +269,27 @@ static struct device_driver gianfar_mdio_driver = {
 	.remove = gfar_mdio_remove,
 };
 
+static int match_mdio_bus(struct device *dev, void *data)
+{
+	const struct gfar_private *priv = data;
+	const struct platform_device *pdev = to_platform_device(dev);
+
+	return !strcmp(pdev->name, gianfar_mdio_driver.name) &&
+		pdev->id == priv->einfo->mdio_bus;
+}
+
+/* Given a gfar_priv structure, find the mii_bus controlled by this device (not
+ * necessarily the same as the bus the gfar's PHY is on), if one exists.
+ * Normally only the first gianfar controls a mii_bus.  */
+struct mii_bus *gfar_get_miibus(const struct gfar_private *priv)
+{
+	/*const*/ struct device *d;
+
+	d = bus_find_device(gianfar_mdio_driver.bus, NULL, (void *)priv,
+			    match_mdio_bus);
+	return d ? dev_get_drvdata(d) : NULL;
+}
+
 int __init gfar_mdio_init(void)
 {
 	return driver_register(&gianfar_mdio_driver);
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
index 2af28b1..02dc970 100644
--- a/drivers/net/gianfar_mii.h
+++ b/drivers/net/gianfar_mii.h
@@ -18,6 +18,8 @@
 #ifndef __GIANFAR_MII_H
 #define __GIANFAR_MII_H
 
+struct gfar_private; /* forward ref */
+
 #define MIIMIND_BUSY            0x00000001
 #define MIIMIND_NOTVALID        0x00000004
 
@@ -44,6 +46,7 @@ int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
 int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
 			  int regnum, u16 value);
 int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
+struct mii_bus *gfar_get_miibus(const struct gfar_private *priv);
 int __init gfar_mdio_init(void);
 void gfar_mdio_exit(void);
 #endif /* GIANFAR_PHY_H */
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 4e625e0..708bab5 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -49,7 +49,8 @@ struct gianfar_platform_data {
 	u32	device_flags;
 	/* board specific information */
 	u32	board_flags;
-	char	bus_id[MII_BUS_ID_SIZE];
+	int	mdio_bus;			/* Bus controlled by us */
+	char	bus_id[MII_BUS_ID_SIZE];	/* Bus PHY is on */
 	u32	phy_id;
 	u8	mac_addr[6];
 	phy_interface_t interface;
-- 
1.5.4.1

