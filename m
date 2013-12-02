From: <shh.xie@gmail.com>
Subject: [PATCH 3/6][v2] phylib: turn genphy_driver to an array
Date: Mon, 2 Dec 2013 15:30:47 +0800
Message-ID: <1385969447-17079-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0248.outbound.messaging.microsoft.com ([213.199.154.248]:8098
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132Ab3LBIvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 03:51:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Then other generic phy driver such as generic 10g phy driver can join it.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
v2 changes: add break if find a match in unbind.

 drivers/net/phy/phy_device.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index d6447b3..748bf07 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -53,7 +53,12 @@ static void phy_device_release(struct device *dev)
 	kfree(to_phy_device(dev));
 }
 
-static struct phy_driver genphy_driver;
+enum genphy_driver {
+	GENPHY_DRV_1G,
+	GENPHY_DRV_MAX
+};
+
+static struct phy_driver genphy_driver[GENPHY_DRV_MAX];
 extern int mdio_bus_init(void);
 extern void mdio_bus_exit(void);
 
@@ -539,7 +544,7 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			return -ENODEV;
 		}
 
-		d->driver = &genphy_driver.driver;
+		d->driver = &genphy_driver[GENPHY_DRV_1G].driver;
 
 		err = d->driver->probe(d);
 		if (err >= 0)
@@ -613,6 +618,7 @@ EXPORT_SYMBOL(phy_attach);
  */
 void phy_detach(struct phy_device *phydev)
 {
+	int i;
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
 
@@ -620,8 +626,12 @@ void phy_detach(struct phy_device *phydev)
 	 * was using the generic driver), we unbind the device
 	 * from the generic driver so that there's a chance a
 	 * real driver could be loaded */
-	if (phydev->dev.driver == &genphy_driver.driver)
-		device_release_driver(&phydev->dev);
+	for (i = 0; i < ARRAY_SIZE(genphy_driver); i++) {
+		if (phydev->dev.driver == &genphy_driver[i].driver) {
+			device_release_driver(&phydev->dev);
+			break;
+		}
+	}
 }
 EXPORT_SYMBOL(phy_detach);
 
@@ -1116,7 +1126,8 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
 }
 EXPORT_SYMBOL(phy_drivers_unregister);
 
-static struct phy_driver genphy_driver = {
+static struct phy_driver genphy_driver[] = {
+{
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
@@ -1127,7 +1138,7 @@ static struct phy_driver genphy_driver = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= {.owner= THIS_MODULE, },
-};
+} };
 
 static int __init phy_init(void)
 {
@@ -1137,7 +1148,8 @@ static int __init phy_init(void)
 	if (rc)
 		return rc;
 
-	rc = phy_driver_register(&genphy_driver);
+	rc = phy_drivers_register(genphy_driver,
+				  ARRAY_SIZE(genphy_driver));
 	if (rc)
 		mdio_bus_exit();
 
@@ -1146,7 +1158,8 @@ static int __init phy_init(void)
 
 static void __exit phy_exit(void)
 {
-	phy_driver_unregister(&genphy_driver);
+	phy_drivers_unregister(genphy_driver,
+			       ARRAY_SIZE(genphy_driver));
 	mdio_bus_exit();
 }
 
-- 
1.8.4.1
