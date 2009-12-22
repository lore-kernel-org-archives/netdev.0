From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH 2/3] phylib: Properly reinitialize PHYs after hibernation
Date: Wed, 23 Dec 2009 01:14:51 +0300
Message-ID: <20091222221451.GB9268@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	Andy Fleming <afleming@freescale.com>, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Since hibernation assumes power loss, we should fully reinitialize
PHYs (including platform fixups), as if PHYs were just attached.

This patch factors phy_init_hw() out of phy_attach_direct(), then
converts mdio_bus to dev_pm_ops and adds an appropriate restore()
callback.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/phy/mdio_bus.c   |   50 ++++++++++++++++++++++++++++++++++++------
 drivers/net/phy/phy_device.c |   30 ++++++++++++------------
 include/linux/phy.h          |    1 +
 3 files changed, 59 insertions(+), 22 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 49252d3..667fc09 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -295,10 +295,9 @@ static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
 	return true;
 }
 
-/* Suspend and resume.  Copied from platform_suspend and
- * platform_resume
- */
-static int mdio_bus_suspend(struct device * dev, pm_message_t state)
+#ifdef CONFIG_PM
+
+static int mdio_bus_suspend(struct device *dev)
 {
 	struct phy_driver *phydrv = to_phy_driver(dev->driver);
 	struct phy_device *phydev = to_phy_device(dev);
@@ -318,7 +317,7 @@ static int mdio_bus_suspend(struct device * dev, pm_message_t state)
 	return phydrv->suspend(phydev);
 }
 
-static int mdio_bus_resume(struct device * dev)
+static int mdio_bus_resume(struct device *dev)
 {
 	struct phy_driver *phydrv = to_phy_driver(dev->driver);
 	struct phy_device *phydev = to_phy_device(dev);
@@ -338,11 +337,48 @@ no_resume:
 	return 0;
 }
 
+static int mdio_bus_restore(struct device *dev)
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
+	phy_start_machine(phydev, NULL);
+
+	return 0;
+}
+
+static struct dev_pm_ops mdio_bus_pm_ops = {
+	.suspend = mdio_bus_suspend,
+	.resume = mdio_bus_resume,
+	.freeze = mdio_bus_suspend,
+	.thaw = mdio_bus_resume,
+	.restore = mdio_bus_restore,
+};
+
+#define MDIO_BUS_PM_OPS (&mdio_bus_pm_ops)
+
+#else
+
+#define MDIO_BUS_PM_OPS NULL
+
+#endif /* CONFIG_PM */
+
 struct bus_type mdio_bus_type = {
 	.name		= "mdio_bus",
 	.match		= mdio_bus_match,
-	.suspend	= mdio_bus_suspend,
-	.resume		= mdio_bus_resume,
+	.pm		= MDIO_BUS_PM_OPS,
 };
 EXPORT_SYMBOL(mdio_bus_type);
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index b10fedd..8212b2b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -378,6 +378,20 @@ void phy_disconnect(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_disconnect);
 
+int phy_init_hw(struct phy_device *phydev)
+{
+	int ret;
+
+	if (!phydev->drv || !phydev->drv->config_init)
+		return 0;
+
+	ret = phy_scan_fixups(phydev);
+	if (ret < 0)
+		return ret;
+
+	return phydev->drv->config_init(phydev);
+}
+
 /**
  * phy_attach_direct - attach a network device to a given PHY device pointer
  * @dev: network device to attach
@@ -425,21 +439,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	/* Do initial configuration here, now that
 	 * we have certain key parameters
 	 * (dev_flags and interface) */
-	if (phydev->drv->config_init) {
-		int err;
-
-		err = phy_scan_fixups(phydev);
-
-		if (err < 0)
-			return err;
-
-		err = phydev->drv->config_init(phydev);
-
-		if (err < 0)
-			return err;
-	}
-
-	return 0;
+	return phy_init_hw(phydev);
 }
 EXPORT_SYMBOL(phy_attach_direct);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index b1368b8..7968def 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -447,6 +447,7 @@ struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_device_register(struct phy_device *phy);
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
+int phy_init_hw(struct phy_device *phydev);
 int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		u32 flags, phy_interface_t interface);
 struct phy_device * phy_attach(struct net_device *dev,
-- 
1.6.3.3
