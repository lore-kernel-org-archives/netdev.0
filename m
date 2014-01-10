From: <shh.xie@gmail.com>
Subject: [PATCH 3/6] [v6] phylib: turn genphy_driver to an array
Date: Fri, 10 Jan 2014 14:27:22 +0800
Message-ID: <1389335242-32626-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Then other generic phy driver such as generic 10g phy driver can join it.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes for v6:
rebased on top of 'net-next' tree. commit id 11b57f90257c1.

 drivers/net/phy/phy_device.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 5d81c89..1cde2b2 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -50,7 +50,12 @@ static void phy_device_release(struct device *dev)
 	kfree(to_phy_device(dev));
 }
 
-static struct phy_driver genphy_driver;
+enum genphy_driver {
+	GENPHY_DRV_1G,
+	GENPHY_DRV_MAX
+};
+
+static struct phy_driver genphy_driver[GENPHY_DRV_MAX];
 
 static LIST_HEAD(phy_fixup_list);
 static DEFINE_MUTEX(phy_fixup_lock);
@@ -580,7 +585,7 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			return -ENODEV;
 		}
 
-		d->driver = &genphy_driver.driver;
+		d->driver = &genphy_driver[GENPHY_DRV_1G].driver;
 
 		err = d->driver->probe(d);
 		if (err >= 0)
@@ -658,6 +663,7 @@ EXPORT_SYMBOL(phy_attach);
  */
 void phy_detach(struct phy_device *phydev)
 {
+	int i;
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
 	phy_suspend(phydev);
@@ -667,8 +673,12 @@ void phy_detach(struct phy_device *phydev)
 	 * from the generic driver so that there's a chance a
 	 * real driver could be loaded
 	 */
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
 
@@ -1173,7 +1183,8 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
 }
 EXPORT_SYMBOL(phy_drivers_unregister);
 
-static struct phy_driver genphy_driver = {
+static struct phy_driver genphy_driver[] = {
+{
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
@@ -1184,7 +1195,7 @@ static struct phy_driver genphy_driver = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE, },
-};
+} };
 
 static int __init phy_init(void)
 {
@@ -1194,7 +1205,8 @@ static int __init phy_init(void)
 	if (rc)
 		return rc;
 
-	rc = phy_driver_register(&genphy_driver);
+	rc = phy_drivers_register(genphy_driver,
+				  ARRAY_SIZE(genphy_driver));
 	if (rc)
 		mdio_bus_exit();
 
@@ -1203,7 +1215,8 @@ static int __init phy_init(void)
 
 static void __exit phy_exit(void)
 {
-	phy_driver_unregister(&genphy_driver);
+	phy_drivers_unregister(genphy_driver,
+			       ARRAY_SIZE(genphy_driver));
 	mdio_bus_exit();
 }
 
-- 
1.8.4.1
