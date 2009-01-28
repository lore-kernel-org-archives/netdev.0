From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH -next 2/2] phylib: Rework suspend/resume code to check
	netdev wakeup capability
Date: Wed, 28 Jan 2009 23:39:14 +0300
Message-ID: <20090128203914.GB14693__19166.0244171091$1233175322$gmane$org@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

In most cases (e.g. PCI drivers) MDIO and MAC controllers are
represented by the same device. But for SOC ethernets we have
separate devices. So, in SOC case, checking whether MDIO
controller may wakeup is not only makes little sense, but also
prevents us from doing per-netdevice wakeup management.

This patch reworks suspend/resume code so that now it checks
for net device's wakeup flags, not MDIO controller's ones.

Each netdevice should manage its wakeup flags, and phylib will
decide whether suspend an attached PHY or not.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/phy/mdio_bus.c |   54 ++++++++++++++++++++++++++++++++-----------
 1 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 811a637..bb29ae3 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -21,6 +21,7 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/delay.h>
+#include <linux/device.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -286,33 +287,58 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 		(phydev->phy_id & phydrv->phy_id_mask));
 }
 
+static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
+{
+	struct device_driver *drv = phydev->dev.driver;
+	struct phy_driver *phydrv = to_phy_driver(drv);
+	struct net_device *netdev = phydev->attached_dev;
+
+	if (!drv || !phydrv->suspend)
+		return false;
+
+	/* PHY not attached? May suspend. */
+	if (!netdev)
+		return true;
+
+	/*
+	 * Don't suspend PHY if the attched netdev parent may wakeup.
+	 * The parent may point to a PCI device, as in tg3 driver.
+	 */
+	if (netdev->dev.parent && device_may_wakeup(netdev->dev.parent))
+		return false;
+
+	/*
+	 * Also don't suspend PHY if the netdev itself may wakeup. This
+	 * is the case for devices w/o underlaying pwr. mgmt. aware bus,
+	 * e.g. SoC devices.
+	 */
+	if (device_may_wakeup(&netdev->dev))
+		return false;
+
+	return true;
+}
+
 /* Suspend and resume.  Copied from platform_suspend and
  * platform_resume
  */
 static int mdio_bus_suspend(struct device * dev, pm_message_t state)
 {
-	int ret = 0;
-	struct device_driver *drv = dev->driver;
-	struct phy_driver *phydrv = to_phy_driver(drv);
+	struct phy_driver *phydrv = to_phy_driver(dev->driver);
 	struct phy_device *phydev = to_phy_device(dev);
 
-	if (drv && phydrv->suspend && !device_may_wakeup(phydev->dev.parent))
-		ret = phydrv->suspend(phydev);
-
-	return ret;
+	if (!mdio_bus_phy_may_suspend(phydev))
+		return 0;
+	return phydrv->suspend(phydev);
 }
 
 static int mdio_bus_resume(struct device * dev)
 {
-	int ret = 0;
-	struct device_driver *drv = dev->driver;
-	struct phy_driver *phydrv = to_phy_driver(drv);
+	struct phy_driver *phydrv = to_phy_driver(dev->driver);
 	struct phy_device *phydev = to_phy_device(dev);
 
-	if (drv && phydrv->resume && !device_may_wakeup(phydev->dev.parent))
-		ret = phydrv->resume(phydev);
-
-	return ret;
+	if (!mdio_bus_phy_may_suspend(phydev))
+		return 0;
+	return phydrv->resume(phydev);
 }
 
 struct bus_type mdio_bus_type = {
-- 
1.5.6.5
