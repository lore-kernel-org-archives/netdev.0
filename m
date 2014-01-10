From: <shh.xie@gmail.com>
Subject: [PATCH 5/6] [v6] phylib: Support attaching to generic 10g driver
Date: Fri, 10 Jan 2014 14:27:54 +0800
Message-ID: <1389335274-328-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Shaohui.Xie@freescale.com>, Andy Fleming <afleming@gmail.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Fleming <afleming@gmail.com>

phy_attach_direct() may now attach to a generic 10G driver. It can
also be used exactly as phy_connect_direct(), which will be useful
when using of_mdio, as phy_connect (and therefore of_phy_connect)
start the PHY state machine, which is currently irrelevant for 10G
PHYs.

Signed-off-by: Andy Fleming <afleming@gmail.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
changes for v6:
rebased on top of 'net-next' tree. commit id 11b57f90257c1.

 drivers/net/phy/phy_device.c | 22 +++++++++-------------
 include/linux/phy.h          |  2 ++
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 18714fe..39794c4 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -62,9 +62,6 @@ static struct phy_driver genphy_driver[GENPHY_DRV_MAX];
 static LIST_HEAD(phy_fixup_list);
 static DEFINE_MUTEX(phy_fixup_lock);
 
-static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
-			     u32 flags, phy_interface_t interface);
-
 /**
  * phy_register_fixup - creates a new phy_fixup and adds it to the list
  * @bus_id: A string which matches phydev->dev.bus_id (or PHY_ANY_ID)
@@ -567,13 +564,13 @@ EXPORT_SYMBOL(phy_init_hw);
  *
  * Description: Called by drivers to attach to a particular PHY
  *     device. The phy_device is found, and properly hooked up
- *     to the phy_driver.  If no driver is attached, then the
- *     genphy_driver is used.  The phy_device is given a ptr to
+ *     to the phy_driver.  If no driver is attached, then a
+ *     generic driver is used.  The phy_device is given a ptr to
  *     the attaching device, and given a callback for link status
  *     change.  The phy_device is returned to the attaching driver.
  */
-static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
-			     u32 flags, phy_interface_t interface)
+int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
+		      u32 flags, phy_interface_t interface)
 {
 	struct device *d = &phydev->dev;
 	int err;
@@ -582,12 +579,10 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	 * exist, and we should use the genphy driver.
 	 */
 	if (NULL == d->driver) {
-		if (phydev->is_c45) {
-			pr_err("No driver for phy %x\n", phydev->phy_id);
-			return -ENODEV;
-		}
-
-		d->driver = &genphy_driver[GENPHY_DRV_1G].driver;
+		if (phydev->is_c45)
+			d->driver = &genphy_driver[GENPHY_DRV_10G].driver;
+		else
+			d->driver = &genphy_driver[GENPHY_DRV_1G].driver;
 
 		err = d->driver->probe(d);
 		if (err >= 0)
@@ -623,6 +618,7 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	return err;
 }
+EXPORT_SYMBOL(phy_attach_direct);
 
 /**
  * phy_attach - attach a network device to a particular PHY device
diff --git a/include/linux/phy.h b/include/linux/phy.h
index a9685b1..565188c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -588,6 +588,8 @@ int phy_resume(struct phy_device *phydev);
 struct phy_device *phy_attach(struct net_device *dev, const char *bus_id,
 			      phy_interface_t interface);
 struct phy_device *phy_find_first(struct mii_bus *bus);
+int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
+		      u32 flags, phy_interface_t interface);
 int phy_connect_direct(struct net_device *dev, struct phy_device *phydev,
 		       void (*handler)(struct net_device *),
 		       phy_interface_t interface);
-- 
1.8.4.1
