From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 16/24] phy: Move PHY PM operations into phy_device
Date: Mon,  4 Jan 2016 18:36:54 +0100
Message-ID: <1451929022-5580-17-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35014 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134AbcADRjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:39:31 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO PM operations are really PHY device PM operations. So move
them into phy_device. This will be needed when we support devices on
the mdio bus which are not PHYs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio_bus.c   |  83 ++++----------------------------
 drivers/net/phy/phy_device.c | 110 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mdio.h         |   2 +-
 3 files changed, 121 insertions(+), 74 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index e6dddb086265..65ff8199bd09 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -561,95 +561,32 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 }
 
 #ifdef CONFIG_PM
-
-static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
-{
-	struct device_driver *drv = phydev->mdio.dev.driver;
-	struct phy_driver *phydrv = to_phy_driver(drv);
-	struct net_device *netdev = phydev->attached_dev;
-
-	if (!drv || !phydrv->suspend)
-		return false;
-
-	/* PHY not attached? May suspend if the PHY has not already been
-	 * suspended as part of a prior call to phy_disconnect() ->
-	 * phy_detach() -> phy_suspend() because the parent netdev might be the
-	 * MDIO bus driver and clock gated at this point.
-	 */
-	if (!netdev)
-		return !phydev->suspended;
-
-	/* Don't suspend PHY if the attched netdev parent may wakeup.
-	 * The parent may point to a PCI device, as in tg3 driver.
-	 */
-	if (netdev->dev.parent && device_may_wakeup(netdev->dev.parent))
-		return false;
-
-	/* Also don't suspend PHY if the netdev itself may wakeup. This
-	 * is the case for devices w/o underlaying pwr. mgmt. aware bus,
-	 * e.g. SoC devices.
-	 */
-	if (device_may_wakeup(&netdev->dev))
-		return false;
-
-	return true;
-}
-
 static int mdio_bus_suspend(struct device *dev)
 {
-	struct phy_device *phydev = to_phy_device(dev);
+	struct mdio_device *mdio = to_mdio_device(dev);
 
-	/* We must stop the state machine manually, otherwise it stops out of
-	 * control, possibly with the phydev->lock held. Upon resume, netdev
-	 * may call phy routines that try to grab the same lock, and that may
-	 * lead to a deadlock.
-	 */
-	if (phydev->attached_dev && phydev->adjust_link)
-		phy_stop_machine(phydev);
-
-	if (!mdio_bus_phy_may_suspend(phydev))
-		return 0;
+	if (mdio->pm_ops && mdio->pm_ops->suspend)
+		return mdio->pm_ops->suspend(dev);
 
-	return phy_suspend(phydev);
+	return 0;
 }
 
 static int mdio_bus_resume(struct device *dev)
 {
-	struct phy_device *phydev = to_phy_device(dev);
-	int ret;
-
-	if (!mdio_bus_phy_may_suspend(phydev))
-		goto no_resume;
+	struct mdio_device *mdio = to_mdio_device(dev);
 
-	ret = phy_resume(phydev);
-	if (ret < 0)
-		return ret;
-
-no_resume:
-	if (phydev->attached_dev && phydev->adjust_link)
-		phy_start_machine(phydev);
+	if (mdio->pm_ops && mdio->pm_ops->resume)
+		return mdio->pm_ops->resume(dev);
 
 	return 0;
 }
 
 static int mdio_bus_restore(struct device *dev)
 {
-	struct phy_device *phydev = to_phy_device(dev);
-	struct net_device *netdev = phydev->attached_dev;
-	int ret;
-
-	if (!netdev)
-		return 0;
-
-	ret = phy_init_hw(phydev);
-	if (ret < 0)
-		return ret;
-
-	/* The PHY needs to renegotiate. */
-	phydev->link = 0;
-	phydev->state = PHY_UP;
+	struct mdio_device *mdio = to_mdio_device(dev);
 
-	phy_start_machine(phydev);
+	if (mdio->pm_ops && mdio->pm_ops->restore)
+		return mdio->pm_ops->restore(dev);
 
 	return 0;
 }
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 4dd42f75a0d2..09fc51917a4d 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -63,6 +63,115 @@ static struct phy_driver genphy_driver[GENPHY_DRV_MAX];
 static LIST_HEAD(phy_fixup_list);
 static DEFINE_MUTEX(phy_fixup_lock);
 
+#ifdef CONFIG_PM
+static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
+{
+	struct device_driver *drv = phydev->mdio.dev.driver;
+	struct phy_driver *phydrv = to_phy_driver(drv);
+	struct net_device *netdev = phydev->attached_dev;
+
+	if (!drv || !phydrv->suspend)
+		return false;
+
+	/* PHY not attached? May suspend if the PHY has not already been
+	 * suspended as part of a prior call to phy_disconnect() ->
+	 * phy_detach() -> phy_suspend() because the parent netdev might be the
+	 * MDIO bus driver and clock gated at this point.
+	 */
+	if (!netdev)
+		return !phydev->suspended;
+
+	/* Don't suspend PHY if the attached netdev parent may wakeup.
+	 * The parent may point to a PCI device, as in tg3 driver.
+	 */
+	if (netdev->dev.parent && device_may_wakeup(netdev->dev.parent))
+		return false;
+
+	/* Also don't suspend PHY if the netdev itself may wakeup. This
+	 * is the case for devices w/o underlaying pwr. mgmt. aware bus,
+	 * e.g. SoC devices.
+	 */
+	if (device_may_wakeup(&netdev->dev))
+		return false;
+
+	return true;
+}
+
+static int mdio_bus_phy_suspend(struct device *dev)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+
+	/* We must stop the state machine manually, otherwise it stops out of
+	 * control, possibly with the phydev->lock held. Upon resume, netdev
+	 * may call phy routines that try to grab the same lock, and that may
+	 * lead to a deadlock.
+	 */
+	if (phydev->attached_dev && phydev->adjust_link)
+		phy_stop_machine(phydev);
+
+	if (!mdio_bus_phy_may_suspend(phydev))
+		return 0;
+
+	return phy_suspend(phydev);
+}
+
+static int mdio_bus_phy_resume(struct device *dev)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	int ret;
+
+	if (!mdio_bus_phy_may_suspend(phydev))
+		goto no_resume;
+
+	ret = phy_resume(phydev);
+	if (ret < 0)
+		return ret;
+
+no_resume:
+	if (phydev->attached_dev && phydev->adjust_link)
+		phy_start_machine(phydev);
+
+	return 0;
+}
+
+static int mdio_bus_phy_restore(struct device *dev)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	struct net_device *netdev = phydev->attached_dev;
+	int ret;
+
+	if (!netdev)
+		return 0;
+
+	ret = phy_init_hw(phydev);
+	if (ret < 0)
+		return ret;
+
+	/* The PHY needs to renegotiate. */
+	phydev->link = 0;
+	phydev->state = PHY_UP;
+
+	phy_start_machine(phydev);
+
+	return 0;
+}
+
+static const struct dev_pm_ops mdio_bus_phy_pm_ops = {
+	.suspend = mdio_bus_phy_suspend,
+	.resume = mdio_bus_phy_resume,
+	.freeze = mdio_bus_phy_suspend,
+	.thaw = mdio_bus_phy_resume,
+	.restore = mdio_bus_phy_restore,
+};
+
+#define MDIO_BUS_PHY_PM_OPS (&mdio_bus_phy_pm_ops)
+
+#else
+
+#define MDIO_BUS_PHY_PM_OPS NULL
+
+#endif /* CONFIG_PM */
+
 /**
  * phy_register_fixup - creates a new phy_fixup and adds it to the list
  * @bus_id: A string which matches phydev->mdio.dev.bus_id (or PHY_ANY_ID)
@@ -165,6 +274,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 	mdiodev->dev.parent = &bus->dev;
 	mdiodev->dev.bus = &mdio_bus_type;
 	mdiodev->bus = bus;
+	mdiodev->pm_ops = MDIO_BUS_PHY_PM_OPS;
 	mdiodev->addr = addr;
 	mdiodev->flags = MDIO_DEVICE_FLAG_PHY;
 
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 8cd9579e18ea..9f844d372ed5 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -15,7 +15,7 @@ struct mii_bus;
 
 struct mdio_device {
 	struct device dev;
-
+	const struct dev_pm_ops *pm_ops;
 	struct mii_bus *bus;
 	/* Bus address of the MDIO device (0-31) */
 	int addr;
-- 
2.6.4
