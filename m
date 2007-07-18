From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: [PATCH] [updated] PHY fixed driver: rework release path and update
	phy_id notation
Date: Thu, 19 Jul 2007 03:38:04 +0400
Message-ID: <20070718233804.24451.22543.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49010 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937284AbXGRXiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 19:38:17 -0400
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


device_bind_driver() error code returning has been fixed.  
release() function has been written, so that to free resources 
in correct way; the release path is now clean. 
 
Before the rework, it used to cause 
 Device 'fixed@100:1' does not have a release() function, it is broken 
 and must be fixed. 
 BUG: at drivers/base/core.c:104 device_release() 
  
 Call Trace:   
  [<ffffffff802ec380>] kobject_cleanup+0x53/0x7e 
  [<ffffffff802ec3ab>] kobject_release+0x0/0x9 
  [<ffffffff802ecf3f>] kref_put+0x74/0x81 
  [<ffffffff8035493b>] fixed_mdio_register_device+0x230/0x265 
  [<ffffffff80564d31>] fixed_init+0x1f/0x35 
  [<ffffffff802071a4>] init+0x147/0x2fb 
  [<ffffffff80223b6e>] schedule_tail+0x36/0x92 
  [<ffffffff8020a678>] child_rip+0xa/0x12 
  [<ffffffff80311714>] acpi_ds_init_one_object+0x0/0x83 
  [<ffffffff8020705d>] init+0x0/0x2fb 
  [<ffffffff8020a66e>] child_rip+0x0/0x12   
 
 
Also changed the notation of the fixed phy definition on 
mdio bus to the form of <speed>+<duplex> to make it able to be used by 
gianfar and ucc_geth that define phy_id strictly as "%d:%d" and cleaned up 
the whitespace issues.
 
Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>

---

 drivers/net/phy/Kconfig   |   14 ++
 drivers/net/phy/fixed.c   |  310 +++++++++++++++++++++++----------------------
 include/linux/phy_fixed.h |   38 ++++++
 3 files changed, 207 insertions(+), 155 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index dd09011..432c210 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -76,4 +76,18 @@ config FIXED_MII_100_FDX
 	bool "Emulation for 100M Fdx fixed PHY behavior"
 	depends on FIXED_PHY
 
+config FIXED_MII_1000_FDX
+	bool "Emulation for 1000M Fdx fixed PHY behavior"
+	depends on FIXED_PHY
+
+config FIXED_MII_AMNT
+        int "Number of emulated PHYs to allocate "
+        depends on FIXED_PHY
+        default "1"
+        ---help---
+        Sometimes it is required to have several independent emulated
+        PHYs on the bus (in case of multi-eth but phy-less HW for instance).
+        This control will have specified number allocated for each fixed
+        PHY type enabled.
+
 endif # PHYLIB
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index bb96691..5619182 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -30,53 +30,31 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-#define MII_REGS_NUM	7
-
-/*
-    The idea is to emulate normal phy behavior by responding with
-    pre-defined values to mii BMCR read, so that read_status hook could
-    take all the needed info.
-*/
-
-struct fixed_phy_status {
-	u8 	link;
-	u16	speed;
-	u8 	duplex;
-};
-
-/*-----------------------------------------------------------------------------
- *  Private information hoder for mii_bus
- *-----------------------------------------------------------------------------*/
-struct fixed_info {
-	u16 *regs;
-	u8 regs_num;
-	struct fixed_phy_status phy_status;
-	struct phy_device *phydev; /* pointer to the container */
-	/* link & speed cb */
-	int(*link_update)(struct net_device*, struct fixed_phy_status*);
-
-};
+/* we need to track the allocated pointers in order to free them on exit */
+static struct fixed_info *fixed_phy_ptrs[CONFIG_FIXED_MII_AMNT*MAX_PHY_AMNT];
 
 /*-----------------------------------------------------------------------------
  *  If something weird is required to be done with link/speed,
  * network driver is able to assign a function to implement this.
  * May be useful for PHY's that need to be software-driven.
  *-----------------------------------------------------------------------------*/
-int fixed_mdio_set_link_update(struct phy_device* phydev,
-		int(*link_update)(struct net_device*, struct fixed_phy_status*))
+int fixed_mdio_set_link_update(struct phy_device *phydev,
+			       int (*link_update) (struct net_device *,
+						   struct fixed_phy_status *))
 {
 	struct fixed_info *fixed;
 
-	if(link_update == NULL)
+	if (link_update == NULL)
 		return -EINVAL;
 
-	if(phydev) {
-		if(phydev->bus)	{
+	if (phydev) {
+		if (phydev->bus) {
 			fixed = phydev->bus->priv;
 			fixed->link_update = link_update;
 			return 0;
@@ -84,54 +62,64 @@ int fixed_mdio_set_link_update(struct phy_device* phydev,
 	}
 	return -EINVAL;
 }
+
 EXPORT_SYMBOL(fixed_mdio_set_link_update);
 
+struct fixed_info *fixed_mdio_get_phydev (int phydev_ind)
+{
+	if (phydev_ind >= MAX_PHY_AMNT)
+		return NULL;
+	return fixed_phy_ptrs[phydev_ind];
+}
+
+EXPORT_SYMBOL(fixed_mdio_get_phydev);
+
 /*-----------------------------------------------------------------------------
  *  This is used for updating internal mii regs from the status
  *-----------------------------------------------------------------------------*/
-#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX)
+#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX) || defined(CONFIG_FIXED_MII_1000_FDX)
 static int fixed_mdio_update_regs(struct fixed_info *fixed)
 {
 	u16 *regs = fixed->regs;
 	u16 bmsr = 0;
 	u16 bmcr = 0;
 
-	if(!regs) {
+	if (!regs) {
 		printk(KERN_ERR "%s: regs not set up", __FUNCTION__);
 		return -EINVAL;
 	}
 
-	if(fixed->phy_status.link)
+	if (fixed->phy_status.link)
 		bmsr |= BMSR_LSTATUS;
 
-	if(fixed->phy_status.duplex) {
+	if (fixed->phy_status.duplex) {
 		bmcr |= BMCR_FULLDPLX;
 
-		switch ( fixed->phy_status.speed ) {
+		switch (fixed->phy_status.speed) {
 		case 100:
 			bmsr |= BMSR_100FULL;
 			bmcr |= BMCR_SPEED100;
-		break;
+			break;
 
 		case 10:
 			bmsr |= BMSR_10FULL;
-		break;
+			break;
 		}
 	} else {
-		switch ( fixed->phy_status.speed ) {
+		switch (fixed->phy_status.speed) {
 		case 100:
 			bmsr |= BMSR_100HALF;
 			bmcr |= BMCR_SPEED100;
-		break;
+			break;
 
 		case 10:
 			bmsr |= BMSR_100HALF;
-		break;
+			break;
 		}
 	}
 
-	regs[MII_BMCR] =  bmcr;
-	regs[MII_BMSR] =  bmsr | 0x800; /*we are always capable of 10 hdx*/
+	regs[MII_BMCR] = bmcr;
+	regs[MII_BMSR] = bmsr | 0x800;	/*we are always capable of 10 hdx */
 
 	return 0;
 }
@@ -141,29 +129,30 @@ static int fixed_mii_read(struct mii_bus *bus, int phy_id, int location)
 	struct fixed_info *fixed = bus->priv;
 
 	/* if user has registered link update callback, use it */
-	if(fixed->phydev)
-		if(fixed->phydev->attached_dev) {
-			if(fixed->link_update) {
+	if (fixed->phydev)
+		if (fixed->phydev->attached_dev) {
+			if (fixed->link_update) {
 				fixed->link_update(fixed->phydev->attached_dev,
-						&fixed->phy_status);
+						   &fixed->phy_status);
 				fixed_mdio_update_regs(fixed);
 			}
-	}
+		}
 
 	if ((unsigned int)location >= fixed->regs_num)
 		return -1;
 	return fixed->regs[location];
 }
 
-static int fixed_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
+static int fixed_mii_write(struct mii_bus *bus, int phy_id, int location,
+			   u16 val)
 {
-	/* do nothing for now*/
+	/* do nothing for now */
 	return 0;
 }
 
 static int fixed_mii_reset(struct mii_bus *bus)
 {
-	/*nothing here - no way/need to reset it*/
+	/*nothing here - no way/need to reset it */
 	return 0;
 }
 #endif
@@ -171,8 +160,8 @@ static int fixed_mii_reset(struct mii_bus *bus)
 static int fixed_config_aneg(struct phy_device *phydev)
 {
 	/* :TODO:03/13/2006 09:45:37 PM::
-	 The full autoneg funcionality can be emulated,
-	 but no need to have anything here for now
+	   The full autoneg funcionality can be emulated,
+	   but no need to have anything here for now
 	 */
 	return 0;
 }
@@ -182,59 +171,79 @@ static int fixed_config_aneg(struct phy_device *phydev)
  * match will never return true...
  *-----------------------------------------------------------------------------*/
 static struct phy_driver fixed_mdio_driver = {
-	.name		= "Fixed PHY",
-	.features	= PHY_BASIC_FEATURES,
-	.config_aneg	= fixed_config_aneg,
-	.read_status	= genphy_read_status,
-	.driver 	= { .owner = THIS_MODULE,},
+	.name = "Fixed PHY",
+#ifdef CONFIG_FIXED_MII_1000_FDX
+	.features = PHY_GBIT_FEATURES,
+#else
+	.features = PHY_BASIC_FEATURES,
+#endif
+	.config_aneg = fixed_config_aneg,
+	.read_status = genphy_read_status,
+	.driver = { .owner = THIS_MODULE, },
 };
 
+static void fixed_mdio_release(struct device *dev)
+{
+	struct phy_device *phydev = container_of(dev, struct phy_device, dev);
+	struct mii_bus *bus = phydev->bus;
+	struct fixed_info *fixed = bus->priv;
+
+	kfree(phydev);
+	kfree(bus->dev);
+	kfree(bus);
+	kfree(fixed->regs);
+	kfree(fixed);
+}
+
 /*-----------------------------------------------------------------------------
  *  This func is used to create all the necessary stuff, bind
  * the fixed phy driver and register all it on the mdio_bus_type.
- * speed is either 10 or 100, duplex is boolean.
+ * speed is either 10 or 100 or 1000, duplex is boolean.
  * number is used to create multiple fixed PHYs, so that several devices can
  * utilize them simultaneously.
+ *
+ * The device on mdio bus will look like [bus_id]:[phy_id],
+ * bus_id = number
+ * phy_id = speed+duplex.
  *-----------------------------------------------------------------------------*/
-#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX)
-static int fixed_mdio_register_device(int number, int speed, int duplex)
+#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX) || defined(CONFIG_FIXED_MII_1000_FDX)
+struct fixed_info *fixed_mdio_register_device(
+	int bus_id, int speed, int duplex, u8 phy_id)
 {
 	struct mii_bus *new_bus;
 	struct fixed_info *fixed;
 	struct phy_device *phydev;
-	int err = 0;
+	int err;
 
-	struct device* dev = kzalloc(sizeof(struct device), GFP_KERNEL);
+	struct device *dev = kzalloc(sizeof(struct device), GFP_KERNEL);
 
-	if (NULL == dev)
-		return -ENOMEM;
+	if (dev == NULL)
+		goto err_dev_alloc;
 
 	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
 
-	if (NULL == new_bus) {
-		kfree(dev);
-		return -ENOMEM;
-	}
+	if (new_bus == NULL)
+		goto err_bus_alloc;
+
 	fixed = kzalloc(sizeof(struct fixed_info), GFP_KERNEL);
 
-	if (NULL == fixed) {
-		kfree(dev);
-		kfree(new_bus);
-		return -ENOMEM;
-	}
+	if (fixed == NULL)
+		goto err_fixed_alloc;
+
+	fixed->regs = kzalloc(MII_REGS_NUM * sizeof(int), GFP_KERNEL);
+	if (NULL == fixed->regs)
+		goto err_fixed_regs_alloc;
 
-	fixed->regs = kzalloc(MII_REGS_NUM*sizeof(int), GFP_KERNEL);
 	fixed->regs_num = MII_REGS_NUM;
 	fixed->phy_status.speed = speed;
 	fixed->phy_status.duplex = duplex;
 	fixed->phy_status.link = 1;
 
-	new_bus->name = "Fixed MII Bus",
-	new_bus->read = &fixed_mii_read,
-	new_bus->write = &fixed_mii_write,
-	new_bus->reset = &fixed_mii_reset,
-
-	/*set up workspace*/
+	new_bus->name = "Fixed MII Bus";
+	new_bus->read = &fixed_mii_read;
+	new_bus->write = &fixed_mii_write;
+	new_bus->reset = &fixed_mii_reset;
+	/*set up workspace */
 	fixed_mdio_update_regs(fixed);
 	new_bus->priv = fixed;
 
@@ -243,119 +252,110 @@ static int fixed_mdio_register_device(int number, int speed, int duplex)
 
 	/* create phy_device and register it on the mdio bus */
 	phydev = phy_device_create(new_bus, 0, 0);
+	if (phydev == NULL)
+		goto err_phy_dev_create;
 
 	/*
-	 Put the phydev pointer into the fixed pack so that bus read/write code could
-	 be able to access for instance attached netdev. Well it doesn't have to do
-	 so, only in case of utilizing user-specified link-update...
+	 * Put the phydev pointer into the fixed pack so that bus read/write
+	 * code could be able to access for instance attached netdev. Well it
+	 * doesn't have to do so, only in case of utilizing user-specified
+	 * link-update...
 	 */
-	fixed->phydev = phydev;
 
-	if(NULL == phydev) {
-		err = -ENOMEM;
-		goto device_create_fail;
-	}
+	fixed->phydev = phydev;
+	phydev->speed = speed;
+	phydev->duplex = duplex;
 
 	phydev->irq = PHY_IGNORE_INTERRUPT;
 	phydev->dev.bus = &mdio_bus_type;
 
-	if(number)
-		snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
-				"fixed_%d@%d:%d", number, speed, duplex);
-	else
-		snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
-				"fixed@%d:%d", speed, duplex);
-	phydev->bus = new_bus;
+	snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
+		 PHY_ID_FMT, bus_id, phy_id);
 
-	err = device_register(&phydev->dev);
-	if(err) {
-		printk(KERN_ERR "Phy %s failed to register\n",
-				phydev->dev.bus_id);
-		goto bus_register_fail;
-	}
+	phydev->bus = new_bus;
 
-	/*
-	   the mdio bus has phy_id match... In order not to do it
-	   artificially, we are binding the driver here by hand;
-	   it will be the same for all the fixed phys anyway.
-	 */
 	phydev->dev.driver = &fixed_mdio_driver.driver;
-
+	phydev->dev.release = fixed_mdio_release;
 	err = phydev->dev.driver->probe(&phydev->dev);
-	if(err < 0) {
-		printk(KERN_ERR "Phy %s: problems with fixed driver\n",phydev->dev.bus_id);
-		goto probe_fail;
+	if (err < 0) {
+		printk(KERN_ERR "Phy %s: problems with fixed driver\n",
+		       phydev->dev.bus_id);
+		goto err_out;
 	}
+	err = device_register(&phydev->dev);
+	if (err) {
+		printk(KERN_ERR "Phy %s failed to register\n",
+		       phydev->dev.bus_id);
+		goto err_out;
+	}
+	//phydev->state = PHY_RUNNING; /* make phy go up quick, but in 10Mbit/HDX
+	return fixed;
 
-	err = device_bind_driver(&phydev->dev);
-	if (err)
-		goto probe_fail;
-
-	return 0;
-
-probe_fail:
-	device_unregister(&phydev->dev);
-bus_register_fail:
+err_out:
 	kfree(phydev);
-device_create_fail:
-	kfree(dev);
-	kfree(new_bus);
+err_phy_dev_create:
+	kfree(fixed->regs);
+err_fixed_regs_alloc:
 	kfree(fixed);
+err_fixed_alloc:
+	kfree(new_bus);
+err_bus_alloc:
+	kfree(dev);
+err_dev_alloc:
+
+	return NULL;
 
-	return err;
 }
 #endif
 
-
 MODULE_DESCRIPTION("Fixed PHY device & driver for PAL");
 MODULE_AUTHOR("Vitaly Bordug");
 MODULE_LICENSE("GPL");
 
 static int __init fixed_init(void)
 {
-#if 0
-	int ret;
-	int duplex = 0;
-#endif
-
-	/* register on the bus... Not expected to be matched with anything there... */
+	int cnt = 0;
+	int i;
+/* register on the bus... Not expected to be matched
+ * with anything there...
+ *
+ */
 	phy_driver_register(&fixed_mdio_driver);
 
-	/* So let the fun begin...
-	   We will create several mdio devices here, and will bound the upper
-	   driver to them.
-
-	   Then the external software can lookup the phy bus by searching
-	   fixed@speed:duplex, e.g. fixed@100:1, to be connected to the
-	   virtual 100M Fdx phy.
-
-	   In case several virtual PHYs required, the bus_id will be in form
-	   fixed_<num>@<speed>:<duplex>, which make it able even to define
-	   driver-specific link control callback, if for instance PHY is completely
-	   SW-driven.
-
-	*/
-
-#ifdef CONFIG_FIXED_MII_DUPLEX
-#if 0
-	duplex = 1;
-#endif
+/* We will create several mdio devices here, and will bound the upper
+ * driver to them.
+ *
+ * Then the external software can lookup the phy bus by searching
+ * for 0:101, to be connected to the virtual 100M Fdx phy.
+ *
+ * In case several virtual PHYs required, the bus_id will be in form
+ * [num]:[duplex]+[speed], which make it able even to define
+ * driver-specific link control callback, if for instance PHY is
+ * completely SW-driven.
+ */
+	for (i=1; i <= CONFIG_FIXED_MII_AMNT; i++) {
+#ifdef CONFIG_FIXED_MII_1000_FDX
+		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(0, 1000, 1, i);
 #endif
-
 #ifdef CONFIG_FIXED_MII_100_FDX
-	fixed_mdio_register_device(0, 100, 1);
+		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(1, 100, 1, i);
 #endif
-
 #ifdef CONFIG_FIXED_MII_10_FDX
-	fixed_mdio_register_device(0, 10, 1);
+		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(2, 10, 1, i);
 #endif
+	}
+
 	return 0;
 }
 
 static void __exit fixed_exit(void)
 {
+	int i;
+
 	phy_driver_unregister(&fixed_mdio_driver);
-	/* :WARNING:02/18/2006 04:32:40 AM:: Cleanup all the created stuff */
+	for (i=0; i < MAX_PHY_AMNT; i++)
+		if ( fixed_phy_ptrs[i] )
+			device_unregister(&fixed_phy_ptrs[i]->phydev->dev);
 }
 
 module_init(fixed_init);
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
new file mode 100644
index 0000000..04ba70d
--- /dev/null
+++ b/include/linux/phy_fixed.h
@@ -0,0 +1,38 @@
+#ifndef __PHY_FIXED_H
+#define __PHY_FIXED_H
+
+#define MII_REGS_NUM	29
+
+/* max number of virtual phy stuff */
+#define MAX_PHY_AMNT	10
+/*
+    The idea is to emulate normal phy behavior by responding with
+    pre-defined values to mii BMCR read, so that read_status hook could
+    take all the needed info.
+*/
+
+struct fixed_phy_status {
+	u8 link;
+	u16 speed;
+	u8 duplex;
+};
+
+/*-----------------------------------------------------------------------------
+ *  Private information hoder for mii_bus
+ *-----------------------------------------------------------------------------*/
+struct fixed_info {
+	u16 *regs;
+	u8 regs_num;
+	struct fixed_phy_status phy_status;
+	struct phy_device *phydev;	/* pointer to the container */
+	/* link & speed cb */
+	int (*link_update) (struct net_device *, struct fixed_phy_status *);
+
+};
+
+
+int fixed_mdio_set_link_update(struct phy_device *,
+       int (*link_update) (struct net_device *, struct fixed_phy_status *));
+struct fixed_info *fixed_mdio_get_phydev (int phydev_ind);
+
+#endif /* __PHY_FIXED_H */

