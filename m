From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: [PATCH 1/3] [NET] phy/fixed.c: rework to not duplicate PHY layer
	functionality
Date: Fri, 07 Dec 2007 01:51:22 +0300
Message-ID: <20071206225121.31080.86606.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59494 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392AbXLFWve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 17:51:34 -0500
Cc: "linuxppc-dev" <linuxppc-dev@ozlabs.org>
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With that patch fixed.c now fully emulates MDIO bus, thus no need
to duplicate PHY layer functionality. That, in turn, drastically
simplifies the code, and drops down line count.

As an additional bonus, now there is no need to register MDIO bus
for each PHY, all emulated PHYs placed on the platform fixed MDIO bus.
There is also no more need to pre-allocate PHYs via .config option,
this is all now handled dynamically.


Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
Acked-by: Jeff Garzik <jeff@garzik.org>

---

 drivers/net/phy/Kconfig   |   32 +--
 drivers/net/phy/fixed.c   |  445 +++++++++++++++++----------------------------
 include/linux/phy_fixed.h |   51 ++---
 3 files changed, 195 insertions(+), 333 deletions(-)


diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 54b2ba9..7fe03ce 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -61,34 +61,12 @@ config ICPLUS_PHY
 	  Currently supports the IP175C PHY.
 
 config FIXED_PHY
-	tristate "Drivers for PHY emulation on fixed speed/link"
+	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	---help---
-	  Adds the driver to PHY layer to cover the boards that do not have any PHY bound,
-	  but with the ability to manipulate the speed/link in software. The relevant MII
-	  speed/duplex parameters could be effectively handled in a user-specified function.
-	  Currently tested with mpc866ads.
-
-config FIXED_MII_10_FDX
-	bool "Emulation for 10M Fdx fixed PHY behavior"
-	depends on FIXED_PHY
-
-config FIXED_MII_100_FDX
-	bool "Emulation for 100M Fdx fixed PHY behavior"
-	depends on FIXED_PHY
-
-config FIXED_MII_1000_FDX
-	bool "Emulation for 1000M Fdx fixed PHY behavior"
-	depends on FIXED_PHY
-
-config FIXED_MII_AMNT
-        int "Number of emulated PHYs to allocate "
-        depends on FIXED_PHY
-        default "1"
-        ---help---
-        Sometimes it is required to have several independent emulated
-        PHYs on the bus (in case of multi-eth but phy-less HW for instance).
-        This control will have specified number allocated for each fixed
-        PHY type enabled.
+	  Adds the platform "fixed" MDIO Bus to cover the boards that use
+	  PHYs that are not connected to the real MDIO bus.
+
+	  Currently tested with mpc866ads and mpc8349e-mitx.
 
 config MDIO_BITBANG
 	tristate "Support for bitbanged MDIO buses"
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 5619182..73b6d39 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -1,362 +1,253 @@
 /*
- * drivers/net/phy/fixed.c
+ * Fixed MDIO bus (MDIO bus emulation with fixed PHYs)
  *
- * Driver for fixed PHYs, when transceiver is able to operate in one fixed mode.
+ * Author: Vitaly Bordug <vbordug@ru.mvista.com>
+ *         Anton Vorontsov <avorontsov@ru.mvista.com>
  *
- * Author: Vitaly Bordug
- *
- * Copyright (c) 2006 MontaVista Software, Inc.
+ * Copyright (c) 2006-2007 MontaVista Software, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
- *
  */
+
 #include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/unistd.h>
-#include <linux/slab.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/delay.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/mm.h>
 #include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/list.h>
 #include <linux/mii.h>
-#include <linux/ethtool.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
+#define MII_REGS_NUM 29
 
-/* we need to track the allocated pointers in order to free them on exit */
-static struct fixed_info *fixed_phy_ptrs[CONFIG_FIXED_MII_AMNT*MAX_PHY_AMNT];
-
-/*-----------------------------------------------------------------------------
- *  If something weird is required to be done with link/speed,
- * network driver is able to assign a function to implement this.
- * May be useful for PHY's that need to be software-driven.
- *-----------------------------------------------------------------------------*/
-int fixed_mdio_set_link_update(struct phy_device *phydev,
-			       int (*link_update) (struct net_device *,
-						   struct fixed_phy_status *))
-{
-	struct fixed_info *fixed;
-
-	if (link_update == NULL)
-		return -EINVAL;
-
-	if (phydev) {
-		if (phydev->bus) {
-			fixed = phydev->bus->priv;
-			fixed->link_update = link_update;
-			return 0;
-		}
-	}
-	return -EINVAL;
-}
-
-EXPORT_SYMBOL(fixed_mdio_set_link_update);
+struct fixed_mdio_bus {
+	int irqs[PHY_MAX_ADDR];
+	struct mii_bus mii_bus;
+	struct list_head phys;
+};
 
-struct fixed_info *fixed_mdio_get_phydev (int phydev_ind)
-{
-	if (phydev_ind >= MAX_PHY_AMNT)
-		return NULL;
-	return fixed_phy_ptrs[phydev_ind];
-}
+struct fixed_phy {
+	int id;
+	u16 regs[MII_REGS_NUM];
+	struct phy_device *phydev;
+	struct fixed_phy_status status;
+	int (*link_update)(struct net_device *, struct fixed_phy_status *);
+	struct list_head node;
+};
 
-EXPORT_SYMBOL(fixed_mdio_get_phydev);
+static struct platform_device *pdev;
+static struct fixed_mdio_bus platform_fmb = {
+	.phys = LIST_HEAD_INIT(platform_fmb.phys),
+};
 
-/*-----------------------------------------------------------------------------
- *  This is used for updating internal mii regs from the status
- *-----------------------------------------------------------------------------*/
-#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX) || defined(CONFIG_FIXED_MII_1000_FDX)
-static int fixed_mdio_update_regs(struct fixed_info *fixed)
+static int fixed_phy_update_regs(struct fixed_phy *fp)
 {
-	u16 *regs = fixed->regs;
-	u16 bmsr = 0;
+	u16 bmsr = BMSR_ANEGCAPABLE;
 	u16 bmcr = 0;
+	u16 lpagb = 0;
+	u16 lpa = 0;
 
-	if (!regs) {
-		printk(KERN_ERR "%s: regs not set up", __FUNCTION__);
-		return -EINVAL;
-	}
-
-	if (fixed->phy_status.link)
-		bmsr |= BMSR_LSTATUS;
-
-	if (fixed->phy_status.duplex) {
+	if (fp->status.duplex) {
 		bmcr |= BMCR_FULLDPLX;
 
-		switch (fixed->phy_status.speed) {
+		switch (fp->status.speed) {
+		case 1000:
+			bmsr |= BMSR_ESTATEN;
+			bmcr |= BMCR_SPEED1000;
+			lpagb |= LPA_1000FULL;
+			break;
 		case 100:
 			bmsr |= BMSR_100FULL;
 			bmcr |= BMCR_SPEED100;
+			lpa |= LPA_100FULL;
 			break;
-
 		case 10:
 			bmsr |= BMSR_10FULL;
+			lpa |= LPA_10FULL;
 			break;
+		default:
+			printk(KERN_WARNING "fixed phy: unknown speed\n");
+			return -EINVAL;
 		}
 	} else {
-		switch (fixed->phy_status.speed) {
+		switch (fp->status.speed) {
+		case 1000:
+			bmsr |= BMSR_ESTATEN;
+			bmcr |= BMCR_SPEED1000;
+			lpagb |= LPA_1000HALF;
+			break;
 		case 100:
 			bmsr |= BMSR_100HALF;
 			bmcr |= BMCR_SPEED100;
+			lpa |= LPA_100HALF;
 			break;
-
 		case 10:
-			bmsr |= BMSR_100HALF;
+			bmsr |= BMSR_10HALF;
+			lpa |= LPA_10HALF;
 			break;
+		default:
+			printk(KERN_WARNING "fixed phy: unknown speed\n");
+			return -EINVAL;
 		}
 	}
 
-	regs[MII_BMCR] = bmcr;
-	regs[MII_BMSR] = bmsr | 0x800;	/*we are always capable of 10 hdx */
+	if (fp->status.link)
+		bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
+
+	if (fp->status.pause)
+		lpa |= LPA_PAUSE_CAP;
+
+	if (fp->status.asym_pause)
+		lpa |= LPA_PAUSE_ASYM;
+
+	fp->regs[MII_PHYSID1] = fp->id >> 16;
+	fp->regs[MII_PHYSID2] = fp->id;
+
+	fp->regs[MII_BMSR] = bmsr;
+	fp->regs[MII_BMCR] = bmcr;
+	fp->regs[MII_LPA] = lpa;
+	fp->regs[MII_STAT1000] = lpagb;
 
 	return 0;
 }
 
-static int fixed_mii_read(struct mii_bus *bus, int phy_id, int location)
+static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int reg_num)
 {
-	struct fixed_info *fixed = bus->priv;
-
-	/* if user has registered link update callback, use it */
-	if (fixed->phydev)
-		if (fixed->phydev->attached_dev) {
-			if (fixed->link_update) {
-				fixed->link_update(fixed->phydev->attached_dev,
-						   &fixed->phy_status);
-				fixed_mdio_update_regs(fixed);
+	struct fixed_mdio_bus *fmb = container_of(bus, struct fixed_mdio_bus,
+						  mii_bus);
+	struct fixed_phy *fp;
+
+	if (reg_num >= MII_REGS_NUM)
+		return -1;
+
+	list_for_each_entry(fp, &fmb->phys, node) {
+		if (fp->id == phy_id) {
+			/* Issue callback if user registered it. */
+			if (fp->link_update) {
+				fp->link_update(fp->phydev->attached_dev,
+						&fp->status);
+				fixed_phy_update_regs(fp);
 			}
+			return fp->regs[reg_num];
 		}
+	}
 
-	if ((unsigned int)location >= fixed->regs_num)
-		return -1;
-	return fixed->regs[location];
+	return 0xFFFF;
 }
 
-static int fixed_mii_write(struct mii_bus *bus, int phy_id, int location,
-			   u16 val)
+static int fixed_mdio_write(struct mii_bus *bus, int phy_id, int reg_num,
+			    u16 val)
 {
-	/* do nothing for now */
 	return 0;
 }
 
-static int fixed_mii_reset(struct mii_bus *bus)
+/*
+ * If something weird is required to be done with link/speed,
+ * network driver is able to assign a function to implement this.
+ * May be useful for PHY's that need to be software-driven.
+ */
+int fixed_phy_set_link_update(struct phy_device *phydev,
+			      int (*link_update)(struct net_device *,
+						 struct fixed_phy_status *))
 {
-	/*nothing here - no way/need to reset it */
-	return 0;
-}
-#endif
+	struct fixed_mdio_bus *fmb = &platform_fmb;
+	struct fixed_phy *fp;
 
-static int fixed_config_aneg(struct phy_device *phydev)
-{
-	/* :TODO:03/13/2006 09:45:37 PM::
-	   The full autoneg funcionality can be emulated,
-	   but no need to have anything here for now
-	 */
-	return 0;
-}
+	if (!link_update || !phydev || !phydev->bus)
+		return -EINVAL;
 
-/*-----------------------------------------------------------------------------
- * the manual bind will do the magic - with phy_id_mask == 0
- * match will never return true...
- *-----------------------------------------------------------------------------*/
-static struct phy_driver fixed_mdio_driver = {
-	.name = "Fixed PHY",
-#ifdef CONFIG_FIXED_MII_1000_FDX
-	.features = PHY_GBIT_FEATURES,
-#else
-	.features = PHY_BASIC_FEATURES,
-#endif
-	.config_aneg = fixed_config_aneg,
-	.read_status = genphy_read_status,
-	.driver = { .owner = THIS_MODULE, },
-};
+	list_for_each_entry(fp, &fmb->phys, node) {
+		if (fp->id == phydev->phy_id) {
+			fp->link_update = link_update;
+			fp->phydev = phydev;
+			return 0;
+		}
+	}
 
-static void fixed_mdio_release(struct device *dev)
-{
-	struct phy_device *phydev = container_of(dev, struct phy_device, dev);
-	struct mii_bus *bus = phydev->bus;
-	struct fixed_info *fixed = bus->priv;
-
-	kfree(phydev);
-	kfree(bus->dev);
-	kfree(bus);
-	kfree(fixed->regs);
-	kfree(fixed);
+	return -ENOENT;
 }
+EXPORT_SYMBOL_GPL(fixed_phy_set_link_update);
 
-/*-----------------------------------------------------------------------------
- *  This func is used to create all the necessary stuff, bind
- * the fixed phy driver and register all it on the mdio_bus_type.
- * speed is either 10 or 100 or 1000, duplex is boolean.
- * number is used to create multiple fixed PHYs, so that several devices can
- * utilize them simultaneously.
- *
- * The device on mdio bus will look like [bus_id]:[phy_id],
- * bus_id = number
- * phy_id = speed+duplex.
- *-----------------------------------------------------------------------------*/
-#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX) || defined(CONFIG_FIXED_MII_1000_FDX)
-struct fixed_info *fixed_mdio_register_device(
-	int bus_id, int speed, int duplex, u8 phy_id)
+int fixed_phy_add(unsigned int irq, int phy_id,
+		  struct fixed_phy_status *status)
 {
-	struct mii_bus *new_bus;
-	struct fixed_info *fixed;
-	struct phy_device *phydev;
-	int err;
+	int ret;
+	struct fixed_mdio_bus *fmb = &platform_fmb;
+	struct fixed_phy *fp;
 
-	struct device *dev = kzalloc(sizeof(struct device), GFP_KERNEL);
+	fp = kzalloc(sizeof(*fp), GFP_KERNEL);
+	if (!fp)
+		return -ENOMEM;
 
-	if (dev == NULL)
-		goto err_dev_alloc;
+	memset(fp->regs, 0xFF,  sizeof(fp->regs[0]) * MII_REGS_NUM);
 
-	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	fmb->irqs[phy_id] = irq;
 
-	if (new_bus == NULL)
-		goto err_bus_alloc;
+	fp->id = phy_id;
+	fp->status = *status;
 
-	fixed = kzalloc(sizeof(struct fixed_info), GFP_KERNEL);
+	ret = fixed_phy_update_regs(fp);
+	if (ret)
+		goto err_regs;
 
-	if (fixed == NULL)
-		goto err_fixed_alloc;
+	list_add_tail(&fp->node, &fmb->phys);
 
-	fixed->regs = kzalloc(MII_REGS_NUM * sizeof(int), GFP_KERNEL);
-	if (NULL == fixed->regs)
-		goto err_fixed_regs_alloc;
+	return 0;
 
-	fixed->regs_num = MII_REGS_NUM;
-	fixed->phy_status.speed = speed;
-	fixed->phy_status.duplex = duplex;
-	fixed->phy_status.link = 1;
+err_regs:
+	kfree(fp);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(fixed_phy_add);
 
-	new_bus->name = "Fixed MII Bus";
-	new_bus->read = &fixed_mii_read;
-	new_bus->write = &fixed_mii_write;
-	new_bus->reset = &fixed_mii_reset;
-	/*set up workspace */
-	fixed_mdio_update_regs(fixed);
-	new_bus->priv = fixed;
+static int __init fixed_mdio_bus_init(void)
+{
+	struct fixed_mdio_bus *fmb = &platform_fmb;
+	int ret;
 
-	new_bus->dev = dev;
-	dev_set_drvdata(dev, new_bus);
+	pdev = platform_device_register_simple("Fixed MDIO bus", 0, NULL, 0);
+	if (!pdev) {
+		ret = -ENOMEM;
+		goto err_pdev;
+	}
 
-	/* create phy_device and register it on the mdio bus */
-	phydev = phy_device_create(new_bus, 0, 0);
-	if (phydev == NULL)
-		goto err_phy_dev_create;
+	fmb->mii_bus.id = 0;
+	fmb->mii_bus.name = "Fixed MDIO Bus";
+	fmb->mii_bus.dev = &pdev->dev;
+	fmb->mii_bus.read = &fixed_mdio_read;
+	fmb->mii_bus.write = &fixed_mdio_write;
+	fmb->mii_bus.irq = fmb->irqs;
 
-	/*
-	 * Put the phydev pointer into the fixed pack so that bus read/write
-	 * code could be able to access for instance attached netdev. Well it
-	 * doesn't have to do so, only in case of utilizing user-specified
-	 * link-update...
-	 */
+	ret = mdiobus_register(&fmb->mii_bus);
+	if (ret)
+		goto err_mdiobus_reg;
 
-	fixed->phydev = phydev;
-	phydev->speed = speed;
-	phydev->duplex = duplex;
+	return 0;
 
-	phydev->irq = PHY_IGNORE_INTERRUPT;
-	phydev->dev.bus = &mdio_bus_type;
+err_mdiobus_reg:
+	platform_device_unregister(pdev);
+err_pdev:
+	return ret;
+}
+module_init(fixed_mdio_bus_init);
 
-	snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
-		 PHY_ID_FMT, bus_id, phy_id);
+static void __exit fixed_mdio_bus_exit(void)
+{
+	struct fixed_mdio_bus *fmb = &platform_fmb;
+	struct fixed_phy *fp;
 
-	phydev->bus = new_bus;
+	mdiobus_unregister(&fmb->mii_bus);
+	platform_device_unregister(pdev);
 
-	phydev->dev.driver = &fixed_mdio_driver.driver;
-	phydev->dev.release = fixed_mdio_release;
-	err = phydev->dev.driver->probe(&phydev->dev);
-	if (err < 0) {
-		printk(KERN_ERR "Phy %s: problems with fixed driver\n",
-		       phydev->dev.bus_id);
-		goto err_out;
-	}
-	err = device_register(&phydev->dev);
-	if (err) {
-		printk(KERN_ERR "Phy %s failed to register\n",
-		       phydev->dev.bus_id);
-		goto err_out;
+	list_for_each_entry(fp, &fmb->phys, node) {
+		list_del(&fp->node);
+		kfree(fp);
 	}
-	//phydev->state = PHY_RUNNING; /* make phy go up quick, but in 10Mbit/HDX
-	return fixed;
-
-err_out:
-	kfree(phydev);
-err_phy_dev_create:
-	kfree(fixed->regs);
-err_fixed_regs_alloc:
-	kfree(fixed);
-err_fixed_alloc:
-	kfree(new_bus);
-err_bus_alloc:
-	kfree(dev);
-err_dev_alloc:
-
-	return NULL;
-
 }
-#endif
+module_exit(fixed_mdio_bus_exit);
 
-MODULE_DESCRIPTION("Fixed PHY device & driver for PAL");
+MODULE_DESCRIPTION("Fixed MDIO bus (MDIO bus emulation with fixed PHYs)");
 MODULE_AUTHOR("Vitaly Bordug");
 MODULE_LICENSE("GPL");
-
-static int __init fixed_init(void)
-{
-	int cnt = 0;
-	int i;
-/* register on the bus... Not expected to be matched
- * with anything there...
- *
- */
-	phy_driver_register(&fixed_mdio_driver);
-
-/* We will create several mdio devices here, and will bound the upper
- * driver to them.
- *
- * Then the external software can lookup the phy bus by searching
- * for 0:101, to be connected to the virtual 100M Fdx phy.
- *
- * In case several virtual PHYs required, the bus_id will be in form
- * [num]:[duplex]+[speed], which make it able even to define
- * driver-specific link control callback, if for instance PHY is
- * completely SW-driven.
- */
-	for (i=1; i <= CONFIG_FIXED_MII_AMNT; i++) {
-#ifdef CONFIG_FIXED_MII_1000_FDX
-		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(0, 1000, 1, i);
-#endif
-#ifdef CONFIG_FIXED_MII_100_FDX
-		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(1, 100, 1, i);
-#endif
-#ifdef CONFIG_FIXED_MII_10_FDX
-		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(2, 10, 1, i);
-#endif
-	}
-
-	return 0;
-}
-
-static void __exit fixed_exit(void)
-{
-	int i;
-
-	phy_driver_unregister(&fixed_mdio_driver);
-	for (i=0; i < MAX_PHY_AMNT; i++)
-		if ( fixed_phy_ptrs[i] )
-			device_unregister(&fixed_phy_ptrs[i]->phydev->dev);
-}
-
-module_init(fixed_init);
-module_exit(fixed_exit);
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index 04ba70d..509d8f5 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -1,38 +1,31 @@
 #ifndef __PHY_FIXED_H
 #define __PHY_FIXED_H
 
-#define MII_REGS_NUM	29
-
-/* max number of virtual phy stuff */
-#define MAX_PHY_AMNT	10
-/*
-    The idea is to emulate normal phy behavior by responding with
-    pre-defined values to mii BMCR read, so that read_status hook could
-    take all the needed info.
-*/
-
 struct fixed_phy_status {
-	u8 link;
-	u16 speed;
-	u8 duplex;
+	int link;
+	int speed;
+	int duplex;
+	int pause;
+	int asym_pause;
 };
 
-/*-----------------------------------------------------------------------------
- *  Private information hoder for mii_bus
- *-----------------------------------------------------------------------------*/
-struct fixed_info {
-	u16 *regs;
-	u8 regs_num;
-	struct fixed_phy_status phy_status;
-	struct phy_device *phydev;	/* pointer to the container */
-	/* link & speed cb */
-	int (*link_update) (struct net_device *, struct fixed_phy_status *);
+#ifdef CONFIG_FIXED_PHY
+extern int fixed_phy_add(unsigned int irq, int phy_id,
+			 struct fixed_phy_status *status);
+#else
+static inline int fixed_phy_add(unsigned int irq, int phy_id,
+				struct fixed_phy_status *status)
+{
+	return -ENODEV;
+}
+#endif /* CONFIG_FIXED_PHY */
 
-};
-
-
-int fixed_mdio_set_link_update(struct phy_device *,
-       int (*link_update) (struct net_device *, struct fixed_phy_status *));
-struct fixed_info *fixed_mdio_get_phydev (int phydev_ind);
+/*
+ * This function issued only by fixed_phy-aware drivers, no need
+ * protect it with #ifdef
+ */
+extern int fixed_phy_set_link_update(struct phy_device *phydev,
+			int (*link_update)(struct net_device *,
+					   struct fixed_phy_status *));
 
 #endif /* __PHY_FIXED_H */

