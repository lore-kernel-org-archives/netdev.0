From: Andy Fleming <afleming@freescale.com>
Subject: RFC: PHY Abstraction Layer II
Date: Tue, 8 Mar 2005 19:47:53 -0600
Message-ID: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-3-1029171143
Cc: Kumar Gala <kumar.gala@freescale.com>
To: Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Apple-Mail-3-1029171143
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed

I've finally gotten all of ebs's suggestions into the PHY code.  Here 
is the new version.  It has the following improvements:

* All PHYs now determine speed,duplex, etc using the same generic code, 
rather than PHY-specific registers.

* The genphy driver works for gigabit PHYs now, as well.  In theory, if 
your PHY isn't broken in some way (I've encountered a number that are), 
you should be able to just use genphy.

* The genphy driver now detects what features the PHY has, rather than 
relying on arbitrarily hard-coded values

* Pause negotiation and advertising has been added

* PHY read and write functions now return errors if the bus read/write 
functions return errors.  These errors are handled properly, and should 
not cause any problem.  It is the bus's responsibility, however, to 
make sure that the PHY is started again once the error is cleared.

This patch contains just the PHY code.  A later email will contain the 
gianfar driver and 85xx patches, which will serve as an example for how 
to use the PHY code.

A note about size:  I did some rough size comparisons, and it looks 
like this code adds ~10 K to the binary size of the kernel (for PPC 32, 
85xx).  However, that's a rough estimate, since my tree includes 
features added to the gianfar driver (eg: ethtool support for setting 
speed/duplex).



--Apple-Mail-3-1029171143
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="phy_only_20050308.patch"
Content-Disposition: attachment;
	filename=phy_only_20050308.patch

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2005-03-08 19:12:44 -06:00
+++ b/drivers/net/Kconfig	2005-03-08 19:12:44 -06:00
@@ -153,6 +153,8 @@
 	source "drivers/net/arcnet/Kconfig"
 endif
 
+source "drivers/net/phy/Kconfig"
+
 #
 #	Ethernet
 #
@@ -2056,6 +2058,8 @@
 config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on 85xx || 83xx
+	select PHYLIB
+	select PHYCONTROL
 	help
 	  This driver supports the Gigabit TSEC on the MPC85xx 
 	  family of chips, and the FEC on the 8540
diff -Nru a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile	2005-03-08 19:12:44 -06:00
+++ b/drivers/net/Makefile	2005-03-08 19:12:44 -06:00
@@ -12,7 +12,7 @@
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 
-gianfar_driver-objs := gianfar.o gianfar_ethtool.o gianfar_phy.o
+gianfar_driver-objs := gianfar.o gianfar_ethtool.o gianfar_mii.o
 
 #
 # link order important here
@@ -63,6 +63,7 @@
 #
 
 obj-$(CONFIG_MII) += mii.o
+obj-$(CONFIG_PHYLIB) += phy/
 
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
diff -Nru a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/Kconfig	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,57 @@
+#
+# PHY Layer Configuration
+#
+
+menu "PHY device support"
+
+config PHYLIB
+	bool "PHY Device support and infrastructure"
+	depends on NET_ETHERNET
+	help
+	  Ethernet controllers are usually attached to PHY
+	  devices.  This option provides infrastructure for
+	  managing PHY devices.
+
+config PHYCONTROL
+	bool "Support for automatically handling PHY state changes"
+	depends on PHYLIB
+	help
+	  Adds code to perform all the work for keeping PHY link
+	  state (speed/duplex/etc) up-to-date.  Also handles
+	  interrupts.
+
+comment "MII PHY device drivers"
+	depends on PHYLIB
+
+config MARVELL_PHY
+	bool "Drivers for Marvell PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently has a driver for the 88E1011S
+	
+config DAVICOM_PHY
+	bool "Drivers for Davicom PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports dm9161e and dm9131
+
+config QSEMI_PHY
+	bool "Drivers for Quality Semiconductor PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the qs6612
+
+config LXT_PHY
+	bool "Drivers for the Intel LXT PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the lxt970, lxt971
+
+config CICADA_PHY
+	bool "Drivers for the Cicada PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the cis8204
+
+endmenu
+
diff -Nru a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/Makefile	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,9 @@
+# Makefile for Linux PHY drivers
+
+obj-$(CONFIG_PHYLIB) += phy.o phy_device.o mdio_bus.o
+
+obj-$(CONFIG_MARVELL_PHY) += marvell.o
+obj-$(CONFIG_DAVICOM_PHY) += davicom.o
+obj-$(CONFIG_CICADA_PHY) += cicada.o
+obj-$(CONFIG_LXT_PHY) += lxt.o
+obj-$(CONFIG_QSEMI_PHY) += qsemi.o
diff -Nru a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/cicada.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,134 @@
+/*
+ * drivers/net/phy/cicada.c
+ *
+ * Driver for Cicada PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* Cicada Extended Control Register 1 */
+#define MII_CIS8201_EXT_CON1           0x17
+#define MII_CIS8201_EXTCON1_INIT       0x0000
+
+/* Cicada Interrupt Mask Register */
+#define MII_CIS8201_IMASK		0x19
+#define MII_CIS8201_IMASK_IEN		0x8000
+#define MII_CIS8201_IMASK_SPEED	0x4000
+#define MII_CIS8201_IMASK_LINK		0x2000
+#define MII_CIS8201_IMASK_DUPLEX	0x1000
+#define MII_CIS8201_IMASK_MASK		0xf000
+
+/* Cicada Interrupt Status Register */
+#define MII_CIS8201_ISTAT		0x1a
+#define MII_CIS8201_ISTAT_STATUS	0x8000
+#define MII_CIS8201_ISTAT_SPEED	0x4000
+#define MII_CIS8201_ISTAT_LINK		0x2000
+#define MII_CIS8201_ISTAT_DUPLEX	0x1000
+
+/* Cicada Auxiliary Control/Status Register */
+#define MII_CIS8201_AUX_CONSTAT        0x1c
+#define MII_CIS8201_AUXCONSTAT_INIT    0x0004
+#define MII_CIS8201_AUXCONSTAT_DUPLEX  0x0020
+#define MII_CIS8201_AUXCONSTAT_SPEED   0x0018
+#define MII_CIS8201_AUXCONSTAT_GBIT    0x0010
+#define MII_CIS8201_AUXCONSTAT_100     0x0008
+
+
+static int cis820x_probe(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_write(phydev, MII_CIS8201_AUX_CONSTAT,
+			MII_CIS8201_AUXCONSTAT_INIT);
+
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_CIS8201_EXT_CON1,
+			MII_CIS8201_EXTCON1_INIT);
+
+	return err;
+}
+
+static int cis820x_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, MII_CIS8201_ISTAT);
+
+	return (err < 0) ? err : 0;
+}
+
+static int cis820x_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_CIS8201_IMASK, 
+				MII_CIS8201_IMASK_MASK);
+	else
+		err = phy_write(phydev, MII_CIS8201_IMASK, 0);
+
+	return err;
+}
+
+/* Cicada 820x */
+static struct phy_driver cis8204_driver = {
+	0x000fc440,
+	"Cicada Cis8204",
+	0x000fffc0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.probe		= &cis820x_probe,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &cis820x_ack_interrupt,
+	.config_intr	= &cis820x_config_intr,
+};
+
+int __init cis8204_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&cis8204_driver);
+
+	return retval;
+}
+
+static void __exit cis8204_exit(void)
+{
+	phy_driver_unregister(&cis8204_driver);
+}
+
+module_init(cis8204_init);
+module_exit(cis8204_exit);
diff -Nru a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/davicom.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,275 @@
+/*
+ * drivers/net/phy/davicom.c
+ *
+ * Driver for Davicom PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+#define MII_DM9161_SCR		0x10
+#define MII_DM9161_SCR_INIT	0x0610
+
+/* DM9161 Interrupt Register */
+#define MII_DM9161_INTR	0x15
+#define MII_DM9161_INTR_PEND		0x8000
+#define MII_DM9161_INTR_DPLX_MASK	0x0800
+#define MII_DM9161_INTR_SPD_MASK	0x0400
+#define MII_DM9161_INTR_LINK_MASK	0x0200
+#define MII_DM9161_INTR_MASK		0x0100
+#define MII_DM9161_INTR_DPLX_CHANGE	0x0010
+#define MII_DM9161_INTR_SPD_CHANGE	0x0008
+#define MII_DM9161_INTR_LINK_CHANGE	0x0004
+#define MII_DM9161_INTR_INIT 		0x0000
+#define MII_DM9161_INTR_STOP	\
+(MII_DM9161_INTR_DPLX_MASK | MII_DM9161_INTR_SPD_MASK \
+ | MII_DM9161_INTR_LINK_MASK | MII_DM9161_INTR_MASK)
+
+/* DM9161 10BT Configuration/Status */
+#define MII_DM9161_10BTCSR	0x12
+#define MII_DM9161_10BTCSR_INIT	0x7800
+
+struct dm9161_private {
+	struct timer_list timer;
+	int resetdone;
+};
+
+#define DM9161_DELAY 1
+int dm9161_config_intr(struct phy_device *phydev)
+{
+	int temp;
+
+	temp = phy_read(phydev, MII_DM9161_INTR);
+
+	if (temp < 0)
+		return temp;
+
+	if(PHY_INTERRUPT_ENABLED == phydev->interrupts )
+		temp &= ~(MII_DM9161_INTR_STOP);
+	else
+		temp |= MII_DM9161_INTR_STOP;
+
+	temp = phy_write(phydev, MII_DM9161_INTR, temp);
+
+	return temp;
+}
+
+
+#if 0
+static void dm9161_timer(unsigned long data)
+{
+	struct phy_device *phydev = (struct phy_device *)data;
+	struct dm9161_private *priv = phydev->priv;
+	int status = phy_read(phydev, MII_BMSR);
+
+	if (status < 0) {
+		mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+		return;
+	}
+
+	spin_lock(&phydev->lock);
+	if (status & BMSR_ANEGCOMPLETE) {
+		if (PHY_PENDING == phydev->state)
+			phydev->state = PHY_UP;
+		else
+			phydev->state = PHY_READY;
+	} else
+		mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+
+	spin_unlock(&phydev->lock);
+}
+#endif
+
+
+static int dm9161_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+	/* Isolate the PHY */
+	err = phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	if (err < 0)
+		return err;
+
+	/* Configure the new settings */
+	err = genphy_config_advert(phydev);
+
+	if (err < 0)
+		return err;
+
+	/* Reconnect the PHY, and enable Autonegotiation */
+	err = phy_write(phydev, MII_BMCR, BMCR_ANENABLE);
+
+	if (err < 0)
+		return err;
+
+#if 0
+	/* Start a timer for DM9161_DELAY seconds to wait
+	 * for the PHY to be ready */
+	init_timer(&priv->timer);
+	priv->timer.function = &dm9161_timer;
+	priv->timer.data = (unsigned long) phydev;
+	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+#endif
+
+	return 0;
+}
+
+static int dm9161_probe(struct phy_device *phydev)
+{
+	struct dm9161_private *priv;
+	int err;
+
+	/* Allocate the private data structure */
+	priv = kmalloc(sizeof(struct dm9161_private), GFP_KERNEL);
+
+	if (NULL == priv)
+		return -ENOMEM;
+
+	phydev->priv = priv;
+
+	/* Reset is not done yet */
+	priv->resetdone = 0;
+
+	/* Isolate the PHY */
+	err = phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
+
+	if (err < 0)
+		return err;
+
+	/* Do not bypass the scrambler/descrambler */
+	err = phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+
+	if (err < 0)
+		return err;
+
+	/* Clear 10BTCSR to default */
+	err = phy_write(phydev, MII_DM9161_10BTCSR, MII_DM9161_10BTCSR_INIT);
+
+	if (err < 0)
+		return err;
+
+	/* Reconnect the PHY, and enable Autonegotiation */
+	err = phy_write(phydev, MII_BMCR, BMCR_ANENABLE);
+
+	if (err < 0)
+		return err;
+
+#if 0
+	phydev->state = PHY_STARTING;
+
+	/* Start a timer for DM9161_DELAY seconds to wait
+	 * for the PHY to be ready */
+	init_timer(&priv->timer);
+	priv->timer.function = &dm9161_timer;
+	priv->timer.data = (unsigned long) phydev;
+	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
+
+	printk(KERN_INFO "Bringing up a Davicom PHY, this could take"
+			" a while...\n");
+#endif
+	return 0;
+}
+
+static void dm9161_remove(struct phy_device *phydev)
+{
+	struct dm9161_private *priv = phydev->priv;
+
+//	del_timer_sync(&priv->timer);
+	kfree(priv);
+}
+
+static int dm9161_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, MII_DM9161_INTR);
+
+	return (err < 0) ? err : 0;
+}
+
+static struct phy_driver dm9161_driver = {
+	.phy_id		= 0x0181b880,
+	.name		= "Davicom DM9161E",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.probe		= dm9161_probe,
+	.config_aneg	= dm9161_config_aneg,
+	.read_status	= genphy_read_status,
+	.remove		= dm9161_remove,
+};
+
+static struct phy_driver dm9131_driver = {
+	.phy_id		= 0x00181b80,
+	.name		= "Davicom DM9131",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= dm9161_ack_interrupt,
+	.config_intr	= dm9161_config_intr,
+};
+
+int __init dm9161_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&dm9161_driver);
+
+	return retval;
+}
+
+static void __exit dm9161_exit(void)
+{
+	phy_driver_unregister(&dm9161_driver);
+}
+
+module_init(dm9161_init);
+module_exit(dm9161_exit);
+
+int __init dm9131_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&dm9131_driver);
+
+	return retval;
+}
+
+static void __exit dm9131_exit(void)
+{
+	phy_driver_unregister(&dm9131_driver);
+}
+
+module_init(dm9131_init);
+module_exit(dm9131_exit);
diff -Nru a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/lxt.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,179 @@
+/*
+ * drivers/net/phy/lxt.c
+ *
+ * Driver for Intel LXT PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* The Level one LXT970 is used by many boards				     */
+
+#define MII_LXT970_IER       17  /* Interrupt Enable Register */
+
+#define MII_LXT970_IER_IEN	0x0002
+
+#define MII_LXT970_ISR       18  /* Interrupt Status Register */
+
+#define MII_LXT970_CONFIG    19  /* Configuration Register    */
+
+/* ------------------------------------------------------------------------- */
+/* The Level one LXT971 is used on some of my custom boards                  */
+
+/* register definitions for the 971 */
+#define MII_LXT971_IER		18  /* Interrupt Enable Register */
+#define MII_LXT971_IER_IEN	0x00f2
+
+#define MII_LXT971_ISR		19  /* Interrupt Status Register */
+
+
+static int lxt970_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, MII_BMSR);
+
+	if (err < 0)
+		return err;
+
+	err = phy_read(phydev, MII_LXT970_ISR);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int lxt970_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_LXT970_IER, MII_LXT970_IER_IEN);
+	else
+		err = phy_write(phydev, MII_LXT970_IER, 0);
+
+	return err;
+}
+
+static int lxt970_probe(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_write(phydev, MII_LXT970_CONFIG, 0);
+
+	return err;
+}
+
+
+static int lxt971_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, MII_LXT971_ISR);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int lxt971_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_LXT971_IER, MII_LXT971_IER_IEN);
+	else
+		err = phy_write(phydev, MII_LXT971_IER, 0);
+
+	return err;
+}
+
+static struct phy_driver lxt970_driver = {
+	.phy_id		= 0x07810000,
+	.name		= "LXT970",
+	.phy_id_mask	= 0x0fffffff,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.probe		= lxt970_probe,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= lxt970_ack_interrupt,
+	.config_intr	= lxt970_config_intr,
+};
+
+static struct phy_driver lxt971_driver = {
+	.phy_id		= 0x0001378e,
+	.name		= "LXT971",
+	.phy_id_mask	= 0x0fffffff,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= lxt971_ack_interrupt,
+	.config_intr	= lxt971_config_intr,
+};
+
+int __init lxt970_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&lxt970_driver);
+
+	return retval;
+}
+
+static void __exit lxt970_exit(void)
+{
+	phy_driver_unregister(&lxt970_driver);
+}
+
+module_init(lxt970_init);
+module_exit(lxt970_exit);
+
+int __init lxt971_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&lxt971_driver);
+
+	return retval;
+}
+
+static void __exit lxt971_exit(void)
+{
+	phy_driver_unregister(&lxt971_driver);
+}
+
+module_init(lxt971_init);
+module_exit(lxt971_exit);
diff -Nru a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/marvell.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,139 @@
+/*
+ * drivers/net/phy/marvell.c
+ *
+ * Driver for Marvell PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+#define MII_M1011_IEVENT		0x13
+#define MII_M1011_IEVENT_CLEAR		0x0000
+
+#define MII_M1011_IMASK			0x12
+#define MII_M1011_IMASK_INIT		0x6400
+#define MII_M1011_IMASK_CLEAR		0x0000
+
+static int marvell_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	/* Clear the interrupts by reading the reg */
+	err = phy_read(phydev, MII_M1011_IEVENT);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int marvell_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if(phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
+	else
+		err = phy_write(phydev, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
+
+	return err;
+}
+
+static int marvell_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+	/* The Marvell PHY has an errata which requires
+	 * that certain registers get written in order
+	 * to restart autonegotiation */
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1d, 0x1f);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0x200c);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1d, 0x5);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0x100);
+	if (err < 0)
+		return err;
+
+
+	err = genphy_config_aneg(phydev);
+
+	return err;
+}
+
+
+static struct phy_driver m88e1101_driver = {
+	.phy_id		= 0x01410c00,
+	.phy_id_mask	= 0xffffff00,
+	.name		= "Marvell 88E1101",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= &marvell_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &marvell_ack_interrupt,
+	.config_intr	= &marvell_config_intr,
+};
+
+int __init marvell_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&m88e1101_driver);
+
+	return retval;
+}
+
+static void __exit marvell_exit(void)
+{
+	phy_driver_unregister(&m88e1101_driver);
+}
+
+module_init(marvell_init);
+module_exit(marvell_exit);
diff -Nru a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/mdio_bus.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,178 @@
+/*
+ * drivers/net/phy/mdio_bus.c
+ *
+ * MDIO Bus interface
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* register_mdiobus
+ * bus: The bus being registered
+ *
+ * description: Called by a bus driver to bring up all the PHYs
+ *   on the bus, and attach them to the bus
+ */
+int register_mdiobus(struct mii_bus *bus)
+{
+	int i;
+	int err = 0;
+
+	spin_lock_init(&bus->mdio_lock);
+
+	if (NULL == bus || NULL == bus->name ||
+			NULL == bus->read ||
+			NULL == bus->write)
+		return -EINVAL;
+
+	if (bus->reset)
+		bus->reset(bus);
+
+	for (i=0; i < PHY_MAX_ADDR; i++) {
+		struct phy_device *phydev;
+
+		phydev = get_phy_device(bus, i);
+
+		/* There's a PHY at this address
+		 * We need to set:
+		 * 1) IRQ
+		 * 2) bus_id
+		 * 3) parent
+		 * 4) bus
+		 * 5) mii_bus
+		 * And, we need to register it */
+		if (phydev) {
+			phydev->irq = bus->irq[i];
+
+			phydev->dev.parent = bus->dev;
+
+			phydev->dev.bus = &mdio_bus_type;
+
+			phydev->bus = bus;
+
+			sprintf(phydev->dev.bus_id, "phy%d:%d", bus->id, i);
+
+			err = device_register(&phydev->dev);
+
+			if (err)
+				printk("phy %d did not register (%d)\n",
+						i, err);
+
+		/* If get_phy_device returned NULL, it may be
+		 * because an error occurred.  If so, we return
+		 * that error */
+		} else if (errno)
+			return errno;
+
+		bus->phy_map[i] = phydev;
+	}
+
+	pr_info("%s: probed\n", bus->name);
+
+	return err;
+}
+EXPORT_SYMBOL(register_mdiobus);
+
+void unregister_mdiobus(struct mii_bus *bus)
+{
+	int i;
+
+	for (i=0; i < PHY_MAX_ADDR; i++)
+		if (bus->phy_map[i]) {
+			device_unregister(&bus->phy_map[i]->dev);
+			kfree(bus->phy_map[i]);
+		}
+
+}
+EXPORT_SYMBOL(unregister_mdiobus);
+
+/* mdio_bus_match
+ * dev: a PHY device
+ * drv: a PHY driver
+ *
+ * description: Given a PHY device, and a PHY driver, return 1 if
+ *   the driver supports the device.  Otherwise, return 0
+ */
+int mdio_bus_match(struct device *dev, struct device_driver *drv)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	struct phy_driver *phydrv = to_phy_driver(drv);
+
+	return (phydrv->phy_id == (phydev->phy_id & phydrv->phy_id_mask));
+}
+
+/* Suspend and resume.  Copied from platform_suspend and
+ * platform_resume
+ */
+static int mdio_bus_suspend(struct device * dev, u32 state)
+{
+	int ret = 0;
+
+	if (dev->driver && dev->driver->suspend) {
+		ret = dev->driver->suspend(dev, state, SUSPEND_DISABLE);
+		if (ret == 0)
+			ret = dev->driver->suspend(dev, state, SUSPEND_SAVE_STATE);
+		if (ret == 0)
+			ret = dev->driver->suspend(dev, state, SUSPEND_POWER_DOWN);
+	}
+	return ret;
+}
+
+static int mdio_bus_resume(struct device * dev)
+{
+	int ret = 0;
+
+	if (dev->driver && dev->driver->resume) {
+		ret = dev->driver->resume(dev, RESUME_POWER_ON);
+		if (ret == 0)
+			ret = dev->driver->resume(dev, RESUME_RESTORE_STATE);
+		if (ret == 0)
+			ret = dev->driver->resume(dev, RESUME_ENABLE);
+	}
+	return ret;
+}
+
+struct bus_type mdio_bus_type = {
+	.name	= "mdio_bus",
+	.match	= mdio_bus_match,
+	.suspend= mdio_bus_suspend,
+	.resume	= mdio_bus_resume,
+};
+
+int __init mdio_bus_init(void)
+{
+	return bus_register(&mdio_bus_type);
+}
+
+subsys_initcall(mdio_bus_init);
diff -Nru a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/phy.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,625 @@
+/*
+ * drivers/net/phy/phy.c
+ *
+ * Framework for configuring and reading PHY devices
+ * Based on code in sungem_phy.c and gianfar_phy.c
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+int phy_read(struct phy_device *phydev, u16 regnum);
+int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+
+/* Convenience functions for reading a given PHY register.
+ * This MUST NOT be called from interrupt context,
+ * because the bus read function may sleep
+ * or generally lock up. */
+int phy_read(struct phy_device *phydev, u16 regnum)
+{
+	int retval;
+	struct mii_bus *bus = phydev->bus;
+
+	spin_lock_bh(&bus->mdio_lock);
+	retval = bus->read(bus, phydev->addr, regnum);
+	spin_unlock_bh(&bus->mdio_lock);
+
+	return retval;
+}
+
+int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
+{
+	int err;
+	struct mii_bus *bus = phydev->bus;
+
+	spin_lock_bh(&bus->mdio_lock);
+	err = bus->write(bus, phydev->addr, regnum, val);
+	spin_unlock_bh(&bus->mdio_lock);
+
+	return err;
+}
+
+
+int phy_clear_interrupt(struct phy_device *phydev)
+{
+	int err = 0;
+
+	if (phydev->drv->ack_interrupt)
+		err = phydev->drv->ack_interrupt(phydev);
+
+	return err;
+}
+
+
+int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
+{
+	int err = 0;
+
+	phydev->interrupts = interrupts;
+	if (phydev->drv->config_intr)
+		err = phydev->drv->config_intr(phydev);
+
+	return err;
+}
+
+
+static inline int phy_read_status(struct phy_device *phydev)
+{
+	return phydev->drv->read_status(phydev);
+}
+
+/* phy_aneg_done
+ *
+ * description: Reads the status register and returns 0 either if
+ *   auto-negotiation is incomplete, or if there was an error.
+ *   Returns BMSR_ANEGCOMPLETE if auto-negotiation is done.
+ *   Must be called with phydev->lock locked.
+ */
+static inline int phy_aneg_done(struct phy_device *phydev)
+{
+	int retval;
+
+	retval = phy_read(phydev, MII_BMSR);
+
+	if (retval < 0)
+		return retval;
+
+	return retval & BMSR_ANEGCOMPLETE;
+}
+
+/* phy_start_aneg
+ * phydev: The PHY on which to initiate auto-negotiation
+ *
+ * description: Calls the PHY driver's config_aneg, and then
+ *   sets the PHY state to PHY_AN if auto-negotiation is enabled,
+ *   and to PHY_FORCING if auto-negotiation is disabled. Unless
+ *   the PHY is currently HALTED.
+ */
+int phy_start_aneg(struct phy_device *phydev)
+{
+	int err = 0;
+
+	spin_lock(&phydev->lock);
+
+	if (AUTONEG_DISABLE == phydev->autoneg)
+		phy_sanitize_settings(phydev);
+
+	err = phydev->drv->config_aneg(phydev);
+
+	if (err < 0)
+		return err;
+
+	if (phydev->state != PHY_HALTED) {
+		if (AUTONEG_ENABLE == phydev->autoneg) {
+			phydev->state = PHY_AN;
+			phydev->link_timeout = PHY_AN_TIMEOUT;
+		} else {
+			phydev->state = PHY_FORCING;
+			phydev->link_timeout = PHY_FORCE_TIMEOUT;
+		}
+	}
+
+	spin_unlock(&phydev->lock);
+
+	return err;
+}
+
+
+/* A structure for mapping a particular speed and duplex
+ * combination to a particular SUPPORTED and ADVERTISED value */
+struct phy_setting {
+	int speed;
+	int duplex;
+	u32 setting;
+};
+
+/* A mapping of all SUPPORTED settings to speed/duplex */
+static struct phy_setting settings[] = {
+	{ .speed = 10000, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10000baseT_Full,
+	},
+	{ .speed = SPEED_1000, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_1000baseT_Full,
+	},
+	{ .speed = SPEED_1000, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_1000baseT_Half,
+	},
+	{ .speed = SPEED_100, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_100baseT_Full,
+	},
+	{ .speed = SPEED_100, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_100baseT_Half,
+	},
+	{ .speed = SPEED_10, .duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10baseT_Full,
+	},
+	{ .speed = SPEED_10, .duplex = DUPLEX_HALF,
+		.setting = SUPPORTED_10baseT_Half,
+	},
+};
+
+#define MAX_NUM_SETTINGS (sizeof(settings)/sizeof(struct phy_setting))
+
+/* phy_find_setting
+ * speed: desired speed of setting
+ * duplex: desired duplex of setting
+ *
+ * description: Searches the settings array for the setting which
+ *   matches the desired speed and duplex, and returns the index
+ *   of that setting.  Returns the index of the last setting if
+ *   none of the others match.
+ */
+static inline int phy_find_setting(int speed, int duplex)
+{
+	int idx = 0;
+
+	while (idx < MAX_NUM_SETTINGS &&
+			(settings[idx].speed != speed ||
+			settings[idx].duplex != duplex))
+		idx++;
+
+	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+}
+
+/* phy_find_valid
+ * idx: The first index in settings[] to search
+ * features: A mask of the valid settings
+ *
+ * description: Returns the index of the first valid setting less
+ *   than or equal to the one pointed to by idx, as determined by
+ *   the mask in features.  Returns the index of the last setting
+ *   if nothing else matches.
+ */
+static inline int phy_find_valid(int idx, u32 features)
+{
+	while (idx < MAX_NUM_SETTINGS && !(settings[idx].setting & features))
+		idx++;
+
+	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+}
+
+/* phy_sanitize_settings
+ * phydev: The PHY in question
+ *
+ * description: Make sure the PHY is set to supported speeds and
+ *   duplexes.  Drop down by one in this order:  1000/FULL,
+ *   1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF
+ */
+void phy_sanitize_settings(struct phy_device *phydev)
+{
+	u32 features = phydev->supported;
+	int idx;
+
+	/* Sanitize settings based on PHY capabilities */
+	if ((features & SUPPORTED_Autoneg) == 0)
+		phydev->autoneg = 0;
+
+	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
+			features);
+
+	phydev->speed = settings[idx].speed;
+	phydev->duplex = settings[idx].duplex;
+}
+
+/* phy_force_reduction
+ * phydev: The PHY in question
+ *
+ * description: Reduces the speed/duplex settings by
+ *   one notch.  The order is so:
+ *   1000/FULL, 1000/HALF, 100/FULL, 100/HALF,
+ *   10/FULL, 10/HALF.  The function bottoms out at 10/HALF.
+ */
+void phy_force_reduction(struct phy_device *phydev)
+{
+	int idx;
+
+	idx = phy_find_setting(phydev->speed, phydev->duplex);
+	
+	idx++;
+
+	idx = phy_find_valid(idx, phydev->supported);
+
+	phydev->speed = settings[idx].speed;
+	phydev->duplex = settings[idx].duplex;
+
+	pr_info("Trying %d/%s\n", phydev->speed,
+			DUPLEX_FULL == phydev->duplex ? "FULL" : "HALF");
+}
+
+#ifdef CONFIG_PHYCONTROL
+/* phy_error:
+ *
+ * Moves the PHY to the HALTED state in response to a read
+ * or write error, and tells the controller the link is down.
+ * Must not be called from interrupt context, or while the
+ * phydev->lock is held.
+ */
+void phy_error(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+	phydev->state = PHY_HALTED;
+	spin_unlock(&phydev->lock);
+}
+
+/* phy_interrupt
+ * irq: Interrupt number
+ * phy_dat: PHY device which caused the interrupt (presumably)
+ * regs: --
+ *
+ * description: When a PHY interrupt occurs, the handler disables
+ * interrupts, and schedules a work task to clear the interrupt.
+ */
+static irqreturn_t phy_interrupt(int irq, void *phy_dat, struct pt_regs *regs)
+{
+	struct phy_device *phydev = phy_dat;
+
+	/* The MDIO bus is not allowed to be written in interrupt
+	 * context, so we need to disable the irq here.  A work
+	 * queue will write the PHY to disable and clear the
+	 * interrupt, and then reenable the irq line. */
+	disable_irq_nosync(irq);
+
+	schedule_work(&phydev->phy_queue);
+
+	return IRQ_HANDLED;
+}
+
+/* phy_start_interrupts
+ * phydev: The PHY whose interrupts are being enabled
+ *
+ * description: Request the interrupt for the given PHY.  If
+ *   this fails, then we set irq to -1 so that we do polling.
+ *   Otherwise, we enable the interrupts in the PHY.
+ *   Returns 0 on success.
+ */
+int phy_start_interrupts(struct phy_device *phydev)
+{
+	int err = 0;
+
+	if (request_irq(phydev->irq, phy_interrupt,
+				SA_SHIRQ,
+				"phy_interrupt",
+				phydev) < 0) {
+		printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
+				phydev->bus->name,
+				phydev->irq);
+		phydev->irq = -1;
+		return 0;
+	}
+
+	err = phy_clear_interrupt(phydev);
+
+	if (err < 0)
+		return err;
+
+	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+
+	return err;
+}
+
+/* Scheduled by the phy_interrupt/timer to handle PHY changes */
+void phy_change(void *data)
+{
+	int err;
+	struct phy_device *phydev = data;
+
+	/* Disable PHY interrupts */
+	err = phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+
+	if (err)
+		goto phy_err;
+
+	/* Clear the interrupt */
+	err = phy_clear_interrupt(phydev);
+
+	if (err)
+		goto phy_err;
+
+	spin_lock(&phydev->lock);
+	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
+		phydev->state = PHY_CHANGELINK;
+	spin_unlock(&phydev->lock);
+
+	enable_irq(phydev->irq);
+
+	/* Reenable interrupts */
+	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+
+	if (err)
+		goto irq_enable_err;
+
+	return;
+
+irq_enable_err:
+	disable_irq(phydev->irq);
+phy_err:
+	phy_error(phydev);
+}
+
+/* Bring down the PHY link, and stop checking the status. */
+void phy_stop(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+
+	if (PHY_HALTED == phydev->state) {
+		spin_unlock(&phydev->lock);
+		return;
+	}
+
+	if (phydev->irq != -1) {
+		/* Clear any pending interrupts */
+		phy_clear_interrupt(phydev);
+
+		/* Disable PHY Interrupts */
+		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+	}
+
+	phydev->state = PHY_HALTED;
+
+	spin_unlock(&phydev->lock);
+}
+
+
+/* phy_start
+ * phydev: The PHY device being started
+ *
+ * description: Indicates the attached device's readiness to
+ *   handle PHY-related work.  Used during startup to start the
+ *   PHY, and after a call to phy_stop() to resume operation.
+ *   Also used to indicate the MDIO bus has cleared an error
+ *   condition.
+ */
+void phy_start(struct phy_device *phydev)
+{
+	spin_lock(&phydev->lock);
+
+	switch (phydev->state) {
+		case PHY_STARTING:
+			phydev->state = PHY_PENDING;
+			break;
+		case PHY_READY:
+			phydev->state = PHY_UP;
+			break;
+		case PHY_HALTED:
+			phydev->state = PHY_RESUMING;
+		default:
+			break;
+	}
+	spin_unlock(&phydev->lock);
+}
+EXPORT_SYMBOL(phy_stop);
+EXPORT_SYMBOL(phy_start);
+
+/* PHY timer which handles the state machine */
+void phy_timer(unsigned long data)
+{
+	struct phy_device *phydev = (struct phy_device *)data;
+	int needs_aneg = 0;
+	int err = 0;
+
+	spin_lock(&phydev->lock);
+
+	if (phydev->adjust_state)
+		phydev->adjust_state(phydev->attached_dev);
+
+	switch(phydev->state) {
+		case PHY_DOWN:
+		case PHY_STARTING:
+		case PHY_READY:
+		case PHY_PENDING:
+			break;
+		case PHY_UP:
+			needs_aneg = 1;
+
+			phydev->link_timeout = PHY_AN_TIMEOUT;
+
+			if (phydev->irq != -1)
+				err = phy_start_interrupts(phydev);
+
+			break;
+		case PHY_AN:
+			/* Check if negotiation is done.  Break
+			 * if there's an error */
+			err = phy_aneg_done(phydev);
+			if (err < 0)
+				break;
+
+			/* If auto-negotiation is done, we change to
+			 * either RUNNING, or NOLINK */
+			if (err > 0) {
+				err = phy_read_status(phydev);
+
+				if (err)
+					break;
+
+				if (phydev->link)
+					phydev->state = PHY_RUNNING;
+				else
+					phydev->state = PHY_NOLINK;
+
+				phydev->adjust_link(phydev->attached_dev);
+
+			} else if (0 == phydev->link_timeout--) {
+				/* The counter expired, so either we
+				 * switch to forced mode, or the
+				 * magic_aneg bit exists, and we try aneg
+				 * again */
+				if (!(phydev->drv->flags & PHY_HAS_MAGICANEG)) {
+					int idx;
+
+					/* We'll start from the
+					 * fastest speed, and work
+					 * our way down */
+					idx = phy_find_valid(0,
+							phydev->supported);
+
+					phydev->speed = settings[idx].speed;
+					phydev->duplex = settings[idx].duplex;
+					
+					phydev->autoneg = AUTONEG_DISABLE;
+					phydev->state = PHY_FORCING;
+					phydev->link_timeout =
+						PHY_FORCE_TIMEOUT;
+
+					pr_info("Trying %d/%s\n", phydev->speed,
+							DUPLEX_FULL ==
+							phydev->duplex ?
+							"FULL" : "HALF");
+				}
+
+				needs_aneg = 1;
+			}
+			break;
+		case PHY_NOLINK:
+			err = phy_read_status(phydev);
+
+			if (err)
+				break;
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+				phydev->adjust_link(phydev->attached_dev);
+			}
+			break;
+		case PHY_FORCING:
+			err = phy_read_status(phydev);
+
+			if (err)
+				break;
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+			} else {
+				if (0 == phydev->link_timeout--) {
+					phy_force_reduction(phydev);
+					needs_aneg = 1;
+				}
+			}
+
+			phydev->adjust_link(phydev->attached_dev);
+			break;
+		case PHY_RUNNING:
+			/* Only register a CHANGE if we aren't
+			 * using interrupts */
+			if (-1 == phydev->irq)
+				phydev->state = PHY_CHANGELINK;
+			break;
+		case PHY_CHANGELINK:
+			err = phy_read_status(phydev);
+
+			if (err)
+				break;
+
+			if (phydev->link)
+				phydev->state = PHY_RUNNING;
+			else {
+				phydev->state = PHY_NOLINK;
+			}
+
+			phydev->adjust_link(phydev->attached_dev);
+
+			if (-1 != phydev->irq)
+				err = phy_config_interrupt(phydev,
+						PHY_INTERRUPT_ENABLED);
+			break;
+		case PHY_HALTED:
+			if (phydev->link) {
+				phydev->link = 0;
+				phydev->adjust_link(phydev->attached_dev);
+			}
+			break;
+		case PHY_RESUMING:
+
+			err = phy_clear_interrupt(phydev);
+
+			if (err)
+				break;
+
+			err = phy_config_interrupt(phydev,
+					PHY_INTERRUPT_ENABLED);
+
+			if (err)
+				break;
+
+			if (AUTONEG_ENABLE == phydev->autoneg) {
+				err = phy_aneg_done(phydev);
+				if (err < 0)
+					break;
+
+				/* err > 0 if AN is done.
+				 * Otherwise, it's 0, and we're
+				 * still waiting for AN */
+				if (err > 0) {
+					phydev->state = PHY_RUNNING;
+				} else {
+					phydev->state = PHY_AN;
+					phydev->link_timeout = PHY_AN_TIMEOUT;
+				}
+			} else
+				phydev->state = PHY_RUNNING;
+			break;
+	}
+
+	spin_unlock(&phydev->lock);
+
+	if (needs_aneg)
+		err = phy_start_aneg(phydev);
+
+	if (err < 0)
+		phy_error(phydev);
+
+	mod_timer(&phydev->phy_timer, jiffies + PHY_STATE_TIME * HZ);
+}
+
+#endif /* CONFIG_PHYCONTROL */
diff -Nru a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/phy_device.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,735 @@
+/*
+ * drivers/net/phy/phy_device.c
+ *
+ * Framework for finding and configuring PHYs.
+ * Also contains generic PHY driver
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* get_phy_device
+ * bus: The bus the PHY is on
+ * addr: The address of the desired PHY device
+ *
+ * description: Reads the ID registers of the desired PHY,
+ *   then allocates and returns the phy_device which
+ *   represents it.
+ */
+struct phy_device * get_phy_device(struct mii_bus *bus, uint addr)
+{
+	int phy_reg;
+	u32 phy_id;
+	struct phy_device *dev = NULL;
+
+	errno = 0;
+
+	/* Grab the bits from PHYIR1, and put them
+	 * in the upper half */
+	phy_reg = bus->read(bus, addr, MII_PHYSID1);
+
+	if (phy_reg < 0) {
+		errno = phy_reg;
+		return NULL;
+	}
+
+	phy_id = (phy_reg & 0xffff) << 16;
+
+	/* Grab the bits from PHYIR2, and put them in the lower half */
+	phy_reg = bus->read(bus, addr, MII_PHYSID2);
+
+	if (phy_reg < 0) {
+		errno = phy_reg;
+		return NULL;
+	}
+
+	phy_id |= (phy_reg & 0xffff);
+
+	/* If the phy_id is all Fs, there is no device there */
+	if (0xffffffff == phy_id)
+		return NULL;
+
+	/* Otherwise, we allocate the device, and initialize the
+	 * default values */
+	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
+
+	if (NULL == dev) {
+		errno = -ENOMEM;
+		return NULL;
+	}
+
+	memset(dev, 0, sizeof(*dev));
+
+	dev->speed = 0;
+	dev->duplex = -1;
+	dev->pause = dev->asym_pause = 0;
+	dev->link = 1;
+
+	dev->autoneg = AUTONEG_ENABLE;
+
+	dev->addr = addr;
+	dev->phy_id = phy_id;
+	dev->bus = bus;
+
+	dev->state = PHY_DOWN;
+
+	spin_lock_init(&dev->lock);
+
+	INIT_WORK(&dev->phy_queue, phy_change, dev);
+
+	return dev;
+}
+
+/* phy_prepare_link:
+ * phydev: The PHY device whose link is being prepped
+ * adjust_link: The link change handler for the controller
+ *
+ * description: Tells the PHY infrastructure to handle the
+ *   gory details on monitoring link status (whether through
+ *   polling or an interrupt), and to call back to the
+ *   connected device driver when the link status changes.
+ *   If you want to monitor your own link state, don't call
+ *   this function */
+void phy_prepare_link(struct phy_device *phydev,
+		void (*handler)(struct device *))
+{
+	phydev->adjust_link = handler;
+}
+
+#ifdef CONFIG_PHYCONTROL
+/* phy_start_machine:
+ * phydev: The PHY device whose state machine is being started
+ * handler: The callback function for state change notifications.
+ *
+ * description: The PHY infrastructure can run a state machine
+ *   which tracks whether the PHY is starting up, negotiating,
+ *   etc.  This function starts the timer which tracks the state
+ *   of the PHY.  If you want to be notified when the state
+ *   changes, pass in the callback, otherwise, pass NULL.  If you
+ *   want to maintain your own state machine, do not call this
+ *   function. */
+void phy_start_machine(struct phy_device *phydev,
+		void (*handler)(struct device *))
+{
+	phydev->adjust_state = handler;
+
+	init_timer(&phydev->phy_timer);
+	phydev->phy_timer.function = &phy_timer;
+	phydev->phy_timer.data = (unsigned long) phydev;
+	mod_timer(&phydev->phy_timer, jiffies + HZ);
+}
+
+/* phy_stop_machine
+ *
+ * description: Stops the state machine timer, sets the state to
+ *   UP (unless it wasn't up yet), and then frees the interrupt,
+ *   if it is in use. This function must be called BEFORE
+ *   phy_detach.
+ */
+void phy_stop_machine(struct phy_device *phydev)
+{
+	del_timer_sync(&phydev->phy_timer);
+
+	spin_lock(&phydev->lock);
+	if (phydev->state > PHY_UP)
+		phydev->state = PHY_UP;
+	spin_unlock(&phydev->lock);
+
+	if (phydev->irq != -1) {
+		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
+		phy_clear_interrupt(phydev);
+		free_irq(phydev->irq, phydev);
+	}
+
+	phydev->adjust_state = NULL;
+}
+
+
+/* phy_connect:
+ * dev: The requesting device
+ * phy_id: The name of the requested PHY device
+ * adjust_link: A callback function for handling link status
+ *   changes
+ *
+ * description: Convenience function for connecting ethernet (or
+ *   other) devices to PHY devices.  The default behavior is for
+ *   the PHY infrastructure to handle everything, and only notify
+ *   the connected driver when the link status changes.  If you
+ *   don't want, or can't use the provided functionality, you may
+ *   choose to call only the subset of functions which provide
+ *   the desired functionality.
+ */
+struct phy_device * phy_connect(struct device *dev, const char *phy_id,
+		void (*handler)(struct device *))
+{
+	struct phy_device *phydev;
+
+	phydev = phy_attach(dev, phy_id);
+
+	if (NULL == phydev)
+		return phydev;
+
+	phy_prepare_link(phydev, handler);
+
+	phy_start_machine(phydev, NULL);
+
+	return phydev;
+}
+EXPORT_SYMBOL(phy_connect);
+
+void phy_disconnect(struct phy_device *phydev)
+{
+	phy_stop_machine(phydev);
+	
+	phydev->adjust_link = NULL;
+
+	phy_detach(phydev);
+}
+EXPORT_SYMBOL(phy_disconnect);
+
+#endif /* CONFIG_PHYCONTROL */
+
+/* phy_attach:
+ *   dev: The requesting device
+ *   phy_id: The name of the requested PHY device
+ *
+ *   description: Called by drivers to attach to a particular PHY
+ *     device. The phy_device is found, and properly hooked up
+ *     to the phy_driver.  If no driver is attached, then the
+ *     genphy_driver is used.  The phy_device is given a ptr to
+ *     the attaching device, and given a callback for link status
+ *     change.  The phy_device is returned to the attaching
+ *     driver.
+ */
+struct phy_device *phy_attach(struct device *dev, const char *phy_id)
+{
+	struct phy_device *phydev = NULL;
+	struct bus_type *bus = &mdio_bus_type;
+	struct list_head *entry;
+
+	/* Search the list of PHY devices on the mdio bus for the
+	 * PHY with the requested name */
+	list_for_each(entry, &bus->devices.list)
+	{
+		struct device *d = container_of(entry, struct device, bus_list);
+
+		if (!strcmp(phy_id, d->bus_id)) {
+			phydev = to_phy_device(d);
+			break;
+		}
+	}
+
+	if (NULL == phydev) {
+		printk(KERN_ERR "%s not found\n", phy_id);
+		errno = -ENODEV;
+		return NULL;
+	}
+
+	/* Assume that if there is no driver, that it doesn't
+	 * exist, and we should use the genphy driver. */
+	if (NULL == phydev->dev.driver) {
+		int err;
+		down_write(&phydev->dev.bus->subsys.rwsem);
+		phydev->dev.driver = &genphy_driver.driver;
+
+		err = phydev->dev.driver->probe(&phydev->dev);
+
+		if (err < 0) {
+			errno = err;
+			return NULL;
+		}
+
+		device_bind_driver(&phydev->dev);
+		up_write(&phydev->dev.bus->subsys.rwsem);
+	}
+
+	if (phydev->attached_dev) {
+		printk(KERN_ERR "%s: %s already attached\n",
+				dev->bus_id, phy_id);
+		errno = -EBUSY;
+		return NULL;
+	}
+
+	phydev->attached_dev = dev;
+
+	return phydev;
+}
+EXPORT_SYMBOL(phy_attach);
+
+void phy_detach(struct phy_device *phydev)
+{
+	phydev->attached_dev = NULL;
+
+	/* If the device had no specific driver before (i.e. - it
+	 * was using the generic driver), we unbind the device
+	 * from the generic driver so that there's a chance a
+	 * real driver could be loaded */
+	if (phydev->dev.driver == &genphy_driver.driver) {
+		down_write(&phydev->dev.bus->subsys.rwsem);
+		device_release_driver(&phydev->dev);
+		up_write(&phydev->dev.bus->subsys.rwsem);
+	}
+}
+EXPORT_SYMBOL(phy_detach);
+
+
+/* Generic PHY support and helper functions */
+
+/* genphy_config_advert
+ *
+ * description: Writes MII_ADVERTISE with the appropriate values,
+ *   after sanitizing the values to make sure we only advertise
+ *   what is supported
+ */
+int genphy_config_advert(struct phy_device *phydev)
+{
+	u32 advertise;
+	int adv;
+	int err;
+
+	/* Only allow advertising what
+	 * this PHY supports */
+	phydev->advertising &= phydev->supported;
+	advertise = phydev->advertising;
+
+	/* Setup standard advertisement */
+	adv = phy_read(phydev, MII_ADVERTISE);
+
+	if (adv < 0)
+		return adv;
+
+	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP | 
+		 ADVERTISE_PAUSE_ASYM);
+	if (advertise & ADVERTISED_10baseT_Half)
+		adv |= ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		adv |= ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		adv |= ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		adv |= ADVERTISE_100FULL;
+	if (advertise & ADVERTISED_Pause)
+		adv |= ADVERTISE_PAUSE_CAP;
+	if (advertise & ADVERTISED_Asym_Pause)
+		adv |= ADVERTISE_PAUSE_ASYM;
+
+	err = phy_write(phydev, MII_ADVERTISE, adv);
+
+	if (err < 0)
+		return err;
+
+	/* Configure gigabit if it's supported */
+	if (phydev->supported & (SUPPORTED_1000baseT_Half |
+				SUPPORTED_1000baseT_Full)) {
+		adv = phy_read(phydev, MII_CTRL1000);
+
+		if (adv < 0)
+			return adv;
+
+		adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+		if (advertise & SUPPORTED_1000baseT_Half)
+			adv |= ADVERTISE_1000HALF;
+		if (advertise & SUPPORTED_1000baseT_Full)
+			adv |= ADVERTISE_1000FULL;
+		err = phy_write(phydev, MII_CTRL1000, adv);
+
+		if (err < 0)
+			return err;
+	}
+
+	return adv;
+}
+
+
+/* genphy_setup_forced
+ *
+ * description: Configures MII_BMCR to force speed/duplex
+ *   to the values in phydev. Assumes that the values are valid.
+ *   Please see phy_sanitize_settings() */
+int genphy_setup_forced(struct phy_device *phydev)
+{
+	int ctl = phy_read(phydev, MII_BMCR);
+
+	if (ctl < 0)
+		return ctl;
+
+	phydev->pause = phydev->asym_pause = 0;
+
+	ctl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPEED1000|BMCR_ANENABLE);
+	ctl |= BMCR_RESET;
+
+	if (SPEED_1000 == phydev->speed)
+		ctl |= BMCR_SPEED1000;
+	else if (SPEED_100 == phydev->speed)
+		ctl |= BMCR_SPEED100;
+
+	if (DUPLEX_FULL == phydev->duplex)
+		ctl |= BMCR_FULLDPLX;
+	
+	ctl = phy_write(phydev, MII_BMCR, ctl);
+
+	return ctl;
+}
+
+
+/* Enable and Restart Autonegotiation */
+int genphy_restart_aneg(struct phy_device *phydev)
+{
+	int ctl;
+
+	ctl = phy_read(phydev, MII_BMCR);
+
+	if (ctl < 0)
+		return ctl;
+
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+
+	ctl = phy_write(phydev, MII_BMCR, ctl);
+
+	return ctl;
+}
+
+
+/* genphy_config_aneg
+ *
+ * description: If auto-negotiation is enabled, we configure the
+ *   advertising, and then restart auto-negotiation.  If it is not
+ *   enabled, then we write the BMCR
+ */
+int genphy_config_aneg(struct phy_device *phydev)
+{
+	int err = 0;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		err = genphy_config_advert(phydev);
+
+		if (err < 0)
+			return err;
+
+		err = genphy_restart_aneg(phydev);
+	} else
+		err = genphy_setup_forced(phydev);
+
+	return err;
+}
+
+
+/* genphy_update_link
+ *
+ * description: Update the value in phydev->link to reflect the
+ *   current link value.  In order to do this, we need to read
+ *   the status register twice, keeping the second value
+ */
+int genphy_update_link(struct phy_device *phydev)
+{
+	int status;
+
+	/* Do a fake read */
+	status = phy_read(phydev, MII_BMSR);
+
+	if (status < 0)
+		return status;
+
+	/* Read link and autonegotiation status */
+	status = phy_read(phydev, MII_BMSR);
+
+	if (status < 0)
+		return status;
+
+	if ((status & BMSR_LSTATUS) == 0)
+		phydev->link = 0;
+	else
+		phydev->link = 1;
+
+	return 0;
+}
+
+/* genphy_read_status
+ *
+ * description: Check the link, then figure out the current state
+ *   by comparing what we advertise with what the link partner
+ *   advertises.  Start by checking the gigabit possibilities,
+ *   then move on to 10/100.
+ */
+int genphy_read_status(struct phy_device *phydev)
+{
+	int adv;
+	int err;
+	int lpa;
+	int lpagb = 0;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		if (phydev->supported & (SUPPORTED_1000baseT_Half
+					| SUPPORTED_1000baseT_Full)) {
+			lpagb = phy_read(phydev, MII_STAT1000);
+
+			if (lpagb < 0)
+				return lpagb;
+
+			adv = phy_read(phydev, MII_CTRL1000);
+
+			if (adv < 0)
+				return adv;
+
+			lpagb &= adv << 2;
+		}
+
+		lpa = phy_read(phydev, MII_LPA);
+
+		if (lpa < 0)
+			return lpa;
+
+		adv = phy_read(phydev, MII_ADVERTISE);
+
+		if (adv < 0)
+			return adv;
+
+		lpa &= adv;
+
+		phydev->speed = SPEED_10;
+		phydev->duplex = DUPLEX_HALF;
+		phydev->pause = phydev->asym_pause = 0;
+
+		if (lpagb & (LPA_1000FULL | LPA_1000HALF)) {
+			phydev->speed = SPEED_1000;
+
+			if (lpagb & LPA_1000FULL)
+				phydev->duplex = DUPLEX_FULL;
+		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
+			phydev->speed = SPEED_100;
+			
+			if (lpa & LPA_100FULL)
+				phydev->duplex = DUPLEX_FULL;
+		} else
+			if (lpa & LPA_10FULL)
+				phydev->duplex = DUPLEX_FULL;
+
+		if (phydev->duplex == DUPLEX_FULL){
+			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
+			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
+		}
+	} else {
+		int bmcr = phy_read(phydev, MII_BMCR);
+		if (bmcr < 0)
+			return bmcr;
+
+		if (bmcr & BMCR_FULLDPLX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		if (bmcr & BMCR_SPEED1000)
+			phydev->speed = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+
+		phydev->pause = phydev->asym_pause = 0;
+	}
+
+	return 0;
+}
+
+
+static int genphy_probe(struct phy_device *phydev)
+{
+	u32 val;
+	u32 features;
+
+	/* For now, I'll claim that the generic driver supports
+	 * all possible port types */
+	features = (SUPPORTED_TP | SUPPORTED_MII
+			| SUPPORTED_AUI | SUPPORTED_FIBRE |
+			SUPPORTED_BNC);
+
+	/* Do we support autonegotiation? */
+	val = phy_read(phydev, MII_BMSR);
+
+	if (val < 0)
+		return val;
+
+	if (val & BMSR_ANEGCAPABLE)
+		features |= SUPPORTED_Autoneg;
+
+	if (val & BMSR_100FULL)
+		features |= SUPPORTED_100baseT_Full;
+	if (val & BMSR_100HALF)
+		features |= SUPPORTED_100baseT_Half;
+	if (val & BMSR_10FULL)
+		features |= SUPPORTED_10baseT_Full;
+	if (val & BMSR_10HALF)
+		features |= SUPPORTED_10baseT_Half;
+
+	if (val & BMSR_ESTATEN) {
+		val = phy_read(phydev, MII_ESTATUS);
+
+		if (val < 0)
+			return val;
+
+		if (val & ESTATUS_1000_TFULL)
+			features |= SUPPORTED_1000baseT_Full;
+		if (val & ESTATUS_1000_THALF)
+			features |= SUPPORTED_1000baseT_Half;
+	}
+
+	phydev->supported = features;
+	phydev->advertising = features;
+
+	return 0;
+}
+
+
+/* phy_probe
+ * dev: The device belonging to a PHY device
+ *
+ * description: Take care of setting up the phy_device structure,
+ *   set the state to READY (the driver's probe function should
+ *   set it to STARTING if needed).
+ */
+int phy_probe(struct device *dev)
+{
+	struct phy_device *phydev;
+	struct phy_driver *phydrv;
+	struct device_driver *drv;
+	int err = 0;
+
+	phydev = to_phy_device(dev);
+
+	/* Make sure the driver is held.
+	 * XXX -- Is this correct? */
+	drv = get_driver(phydev->dev.driver);
+	phydrv = to_phy_driver(drv);
+	phydev->drv = phydrv;
+
+	/* Disable the interrupt if the PHY doesn't support it */
+	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
+		phydev->irq = -1;
+
+	spin_lock(&phydev->lock);
+
+	/* Start out supporting everything. Eventually,
+	 * a controller will attach, and may modify one
+	 * or both of these values */
+	phydev->supported = phydrv->features;
+	phydev->advertising = phydrv->features;
+
+	/* Set the state to READY by default */
+	phydev->state = PHY_READY;
+
+	if (phydev->drv->probe)
+		err = phydev->drv->probe(phydev);
+
+	spin_unlock(&phydev->lock);
+
+	return err;
+}
+
+int phy_remove(struct device *dev)
+{
+	struct phy_device *phydev;
+
+	phydev = to_phy_device(dev);
+
+	spin_lock(&phydev->lock);
+	phydev->state = PHY_DOWN;
+	spin_unlock(&phydev->lock);
+
+	if (phydev->drv->remove)
+		phydev->drv->remove(phydev);
+
+	put_driver(phydev->dev.driver);
+	phydev->drv = NULL;
+
+	return 0;
+}
+
+int phy_driver_register(struct phy_driver *new_driver)
+{
+	int retval;
+
+	memset(&new_driver->driver, 0, sizeof(new_driver->driver));
+	new_driver->driver.name = new_driver->name;
+	new_driver->driver.bus = &mdio_bus_type;
+	new_driver->driver.probe = phy_probe;
+	new_driver->driver.remove = phy_remove;
+
+	retval = driver_register(&new_driver->driver);
+
+	if (!retval)
+		pr_info("%s: Registered new driver\n", new_driver->name);
+	else
+		printk(KERN_ERR "%s: Error %d in registering driver\n",
+				new_driver->name, retval);
+
+	return retval;
+}
+
+void phy_driver_unregister(struct phy_driver *drv)
+{
+	driver_unregister(&drv->driver);
+}
+
+struct phy_driver genphy_driver = {
+	.phy_id		= 0xffffffff,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Generic PHY",
+	.probe		= genphy_probe,
+	.features	= 0,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+};
+
+static int __init genphy_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&genphy_driver);
+
+	return retval;
+}
+
+static void __exit genphy_exit(void)
+{
+	phy_driver_unregister(&genphy_driver);
+}
+
+module_init(genphy_init);
+module_exit(genphy_exit);
diff -Nru a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/drivers/net/phy/qsemi.c	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,143 @@
+/*
+ * drivers/net/phy/qsemi.c
+ *
+ * Driver for Quality Semiconductor PHYs
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* ------------------------------------------------------------------------- */
+/* The Quality Semiconductor QS6612 is used on the RPX CLLF                  */
+
+/* register definitions */
+
+#define MII_QS6612_MCR		17  /* Mode Control Register      */
+#define MII_QS6612_FTR		27  /* Factory Test Register      */
+#define MII_QS6612_MCO		28  /* Misc. Control Register     */
+#define MII_QS6612_ISR		29  /* Interrupt Source Register  */
+#define MII_QS6612_IMR		30  /* Interrupt Mask Register    */
+#define MII_QS6612_IMR_INIT	0x003a
+#define MII_QS6612_PCR		31  /* 100BaseTx PHY Control Reg. */
+
+#define QS6612_PCR_AN_COMPLETE	0x1000
+#define QS6612_PCR_RLBEN	0x0200
+#define QS6612_PCR_DCREN	0x0100
+#define QS6612_PCR_4B5BEN	0x0040
+#define QS6612_PCR_TX_ISOLATE	0x0020
+#define QS6612_PCR_MLT3_DIS	0x0002
+#define QS6612_PCR_SCRM_DESCRM	0x0001
+
+
+/* Returns 0, unless there's a write error */
+int qs6612_probe(struct phy_device *phydev)
+{
+	/* The PHY powers up isolated on the RPX,
+	 * so send a command to allow operation.
+	 * XXX - My docs indicate this should be 0x0940
+	 * ...or something.  The current value sets three
+	 * reserved bits, bit 11, which specifies it should be
+	 * set to one, bit 10, which specifies it should be set
+	 * to 0, and bit 7, which doesn't specify.  However, my
+	 * docs are preliminary, and I will leave it like this
+	 * until someone more knowledgable corrects me or it.
+	 * -- Andy Fleming
+	 */
+	return phy_write(phydev, MII_QS6612_PCR, 0x0dc0);
+}
+
+int qs6612_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, MII_QS6612_ISR);
+
+	if (err < 0)
+		return err;
+
+	err = phy_read(phydev, MII_BMSR);
+
+	if (err < 0)
+		return err;
+
+	err = phy_read(phydev, MII_EXPANSION);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+int qs6612_config_intr(struct phy_device *phydev)
+{
+	int err;
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_QS6612_IMR,
+				MII_QS6612_IMR_INIT);
+	else
+		err = phy_write(phydev, MII_QS6612_IMR, 0);
+
+	return err;
+
+}
+
+static struct phy_driver qs6612_driver = {
+	.phy_id		= 0x00181440,
+	.name		= "QS6612",
+	.phy_id_mask	= 0xfffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.probe		= qs6612_probe,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= qs6612_ack_interrupt,
+	.config_intr	= qs6612_config_intr,
+};
+
+int __init qs6612_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&qs6612_driver);
+
+	return retval;
+}
+
+static void __exit qs6612_exit(void)
+{
+	phy_driver_unregister(&qs6612_driver);
+}
+
+module_init(qs6612_init);
+module_exit(qs6612_exit);
diff -Nru a/include/linux/ethtool.h b/include/linux/ethtool.h
--- a/include/linux/ethtool.h	2005-03-08 19:12:44 -06:00
+++ b/include/linux/ethtool.h	2005-03-08 19:12:44 -06:00
@@ -389,6 +389,7 @@
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
 
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
@@ -407,6 +408,8 @@
 #define SUPPORTED_FIBRE			(1 << 10)
 #define SUPPORTED_BNC			(1 << 11)
 #define SUPPORTED_10000baseT_Full	(1 << 12)
+#define SUPPORTED_Pause			(1 << 13)
+#define SUPPORTED_Asym_Pause		(1 << 14)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -422,6 +425,8 @@
 #define ADVERTISED_FIBRE		(1 << 10)
 #define ADVERTISED_BNC			(1 << 11)
 #define ADVERTISED_10000baseT_Full	(1 << 12)
+#define ADVERTISED_Pause		(1 << 13)
+#define ADVERTISED_Asym_Pause		(1 << 14)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
diff -Nru a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
--- a/include/linux/fsl_devices.h	2005-03-08 19:12:45 -06:00
+++ b/include/linux/fsl_devices.h	2005-03-08 19:12:45 -06:00
@@ -47,13 +47,19 @@
 struct gianfar_platform_data {
 	/* device specific information */
 	u32 device_flags;
-	u32 phy_reg_addr;
 
 	/* board specific information */
 	u32 board_flags;
-	u32 phyid;
-	u32 interruptPHY;
+	const char *bus_id;
 	u8 mac_addr[6];
+};
+
+struct gianfar_mdio_data {
+	/* device specific information */
+	u32 paddr;
+
+	/* board specific information */
+	int irq[32];
 };
 
 /* Flags related to gianfar device features */
diff -Nru a/include/linux/mii.h b/include/linux/mii.h
--- a/include/linux/mii.h	2005-03-08 19:12:44 -06:00
+++ b/include/linux/mii.h	2005-03-08 19:12:44 -06:00
@@ -22,6 +22,7 @@
 #define MII_EXPANSION       0x06        /* Expansion register          */
 #define MII_CTRL1000        0x09        /* 1000BASE-T control          */
 #define MII_STAT1000        0x0a        /* 1000BASE-T status           */
+#define MII_ESTATUS	    0x0f	/* Extended Status */
 #define MII_DCOUNTER        0x12        /* Disconnect counter          */
 #define MII_FCSCOUNTER      0x13        /* False carrier counter       */
 #define MII_NWAYTEST        0x14        /* N-way auto-neg test reg     */
@@ -54,7 +55,10 @@
 #define BMSR_ANEGCAPABLE        0x0008  /* Able to do auto-negotiation */
 #define BMSR_RFAULT             0x0010  /* Remote fault detected       */
 #define BMSR_ANEGCOMPLETE       0x0020  /* Auto-negotiation complete   */
-#define BMSR_RESV               0x07c0  /* Unused...                   */
+#define BMSR_RESV               0x00c0  /* Unused...                   */
+#define BMSR_ESTATEN		0x0100	/* Extended Status in R15 */
+#define BMSR_100FULL2		0x0200	/* Can do 100BASE-T2 HDX */
+#define BMSR_100HALF2		0x0400	/* Can do 100BASE-T2 FDX */
 #define BMSR_10HALF             0x0800  /* Can do 10mbps, half-duplex  */
 #define BMSR_10FULL             0x1000  /* Can do 10mbps, full-duplex  */
 #define BMSR_100HALF            0x2000  /* Can do 100mbps, half-duplex */
@@ -105,6 +109,9 @@
 #define EXPANSION_NPCAPABLE     0x0008  /* Link partner supports npage */
 #define EXPANSION_MFAULTS       0x0010  /* Multiple faults detected    */
 #define EXPANSION_RESV          0xffe0  /* Unused...                   */
+
+#define ESTATUS_1000_TFULL	0x2000	/* Can do 1000BT Full */
+#define ESTATUS_1000_THALF	0x1000	/* Can do 1000BT Half */
 
 /* N-way test register. */
 #define NWAYTEST_RESV1          0x00ff  /* Unused...                   */
diff -Nru a/include/linux/phy.h b/include/linux/phy.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/linux/phy.h	2005-03-08 19:12:45 -06:00
@@ -0,0 +1,352 @@
+/*
+ * include/linux/phy.h
+ *
+ * Framework and drivers for configuring and reading different PHYs
+ * Based on code in sungem_phy.c and gianfar_phy.c
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#ifndef __PHY_H
+#define __PHY_H
+
+#include <linux/spinlock.h>
+#include <linux/device.h>
+
+#define PHY_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
+				 SUPPORTED_10baseT_Full | \
+				 SUPPORTED_100baseT_Half | \
+				 SUPPORTED_100baseT_Full | \
+				 SUPPORTED_Autoneg | \
+				 SUPPORTED_TP | \
+				 SUPPORTED_MII)
+
+#define PHY_GBIT_FEATURES	(PHY_BASIC_FEATURES | \
+				 SUPPORTED_1000baseT_Half | \
+				 SUPPORTED_1000baseT_Full)
+
+#define PHY_HAS_INTERRUPT	0x00000001
+#define PHY_HAS_MAGICANEG	0x00000002
+
+#define MII_BUS_MAX 4
+
+
+#define PHY_INIT_TIMEOUT 100000
+#define PHY_STATE_TIME		1
+#define PHY_FORCE_TIMEOUT	10
+#define PHY_AN_TIMEOUT		10
+
+#define PHY_MAX_ADDR 32
+
+/* The Bus class for PHYs.  Devices which provide access to
+ * PHYs should register using this structure */
+struct mii_bus {
+	const char *name;
+	int id;
+	void *priv;
+	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
+	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
+	int (*reset)(struct mii_bus *bus);
+
+	/* A lock to ensure that only one thing can read/write
+	 * the MDIO bus at a time */
+	spinlock_t mdio_lock;
+
+	struct device *dev;
+
+	/* list of all PHYs on bus */
+	struct phy_device *phy_map[PHY_MAX_ADDR];
+
+	/* Pointer to an array of interrupts, each PHY's
+	 * interrupt at the index matching its address */
+	int *irq;
+};
+
+#define PHY_INTERRUPT_DISABLED 0x0
+#define PHY_INTERRUPT_ENABLED 0x80000000
+
+/* PHY state machine states:
+ *
+ * DOWN: PHY device and driver are not ready for anything.  probe
+ * should be called if and only if the PHY is in this state,
+ * given that the PHY device exists.
+ * - PHY driver probe function will, depending on the PHY, set
+ * the state to STARTING or READY
+ *
+ * STARTING:  PHY device is coming up, and the ethernet driver is
+ * not ready.  PHY drivers may set this in the probe function.
+ * If they do, they are responsible for making sure the state is
+ * eventually set to indicate whether the PHY is UP or READY,
+ * depending on the state when the PHY is done starting up.
+ * - PHY driver will set the state to READY
+ * - start will set the state to PENDING
+ *
+ * READY: PHY is ready to send and receive packets, but the
+ * controller is not.  By default, PHYs which do not implement
+ * probe will be set to this state by phy_probe().  If the PHY
+ * driver knows the PHY is ready, and the PHY state is STARTING,
+ * then it sets this STATE.
+ * - start will set the state to UP
+ *
+ * PENDING: PHY device is coming up, but the ethernet driver is
+ * ready.  phy_start will set this state if the PHY state is
+ * STARTING.
+ * - PHY driver will set the state to UP when the PHY is ready
+ *
+ * UP: The PHY and attached device are ready to do work.
+ * Interrupts should be started here.
+ * - timer moves to AN
+ *
+ * AN: The PHY is currently negotiating the link state.  Link is
+ * therefore down for now.  phy_timer will set this state when it
+ * detects the state is UP.  config_aneg will set this state
+ * whenever called with phydev->autoneg set to AUTONEG_ENABLE.
+ * - If autonegotiation finishes, but there's no link, it sets
+ *   the state to NOLINK.
+ * - If aneg finishes with link, it sets the state to RUNNING,
+ *   and calls adjust_link
+ * - If autonegotiation did not finish after an arbitrary amount
+ *   of time, autonegotiation should be tried again if the PHY
+ *   supports "magic" autonegotiation (back to AN)
+ * - If it didn't finish, and no magic_aneg, move to FORCING.
+ *
+ * NOLINK: PHY is up, but not currently plugged in.
+ * - If the timer notes that the link comes back, we move to RUNNING
+ * - config_aneg moves to AN
+ * - phy_stop moves to HALTED
+ *
+ * FORCING: PHY is being configured with forced settings
+ * - if link is up, move to RUNNING
+ * - If link is down, we drop to the next highest setting, and
+ *   retry (FORCING) after a timeout
+ * - phy_stop moves to HALTED
+ *
+ * RUNNING: PHY is currently up, running, and possibly sending
+ * and/or receiving packets
+ * - timer will set CHANGELINK if we're polling (this ensures the
+ *   link state is polled every other cycle of this state machine,
+ *   which makes it every other second)
+ * - irq will set CHANGELINK
+ * - config_aneg will set AN
+ * - phy_stop moves to HALTED
+ *
+ * CHANGELINK: PHY experienced a change in link state
+ * - timer moves to RUNNING if link
+ * - timer moves to NOLINK if the link is down
+ * - phy_stop moves to HALTED
+ *
+ * HALTED: PHY is up, but no polling or interrupts are done. Or
+ * PHY is in an error state.
+ *
+ * - phy_start moves to RESUMING
+ *
+ * RESUMING: PHY was halted, but now wants to run again.
+ * - If we are forcing, or aneg is done, timer moves to RUNNING
+ * - If aneg is not done, timer moves to AN
+ * - phy_stop moves to HALTED
+ */
+enum phy_state {
+	PHY_DOWN=0,
+	PHY_STARTING,
+	PHY_READY,
+	PHY_PENDING,
+	PHY_UP,
+	PHY_AN,
+	PHY_RUNNING,
+	PHY_NOLINK,
+	PHY_FORCING,
+	PHY_CHANGELINK,
+	PHY_HALTED,
+	PHY_RESUMING
+};
+
+/* phy_device: An instance of a PHY
+ *
+ * drv: Pointer to the driver for this PHY instance
+ * bus: Pointer to the bus this PHY is on
+ * dev: driver model device structure for this PHY
+ * phy_id: UID for this device found during discovery
+ * state: state of the PHY for management purposes
+ * addr: Bus address of PHY
+ * link_timeout: The number of timer firings to wait before the
+ * giving up on the current attempt at acquiring a link
+ * irq: IRQ number of the PHY's interrupt (-1 if none)
+ * phy_timer: The timer for handling the state machine
+ * phy_queue: A work_queue for the interrupt
+ * attached_dev: The attached enet driver's device instance ptr
+ * adjust_link: Callback for the enet controller to respond to
+ * changes in the link state.
+ * adjust_state: Callback for the enet driver to respond to
+ * changes in the state machine.
+ *
+ * speed, duplex, pause, supported, advertising, and
+ * autoneg are used like in mii_if_info
+ *
+ * interrupts currently only supports enabled or disabled,
+ * but could be changed in the future to support enabling
+ * and disabling specific interrupts
+ *
+ * Contains some infrastructure for polling and interrupt
+ * handling, as well as handling shifts in PHY hardware state
+ */
+struct phy_device {
+	/* Information about the PHY type */
+	/* And management functions */
+	struct phy_driver *drv;
+
+	struct mii_bus *bus;
+
+	struct device dev;
+
+	u32 phy_id;
+
+	enum phy_state state;
+
+	/* Bus address of the PHY (0-32) */
+	int addr;
+
+	/* forced speed & duplex (no autoneg)
+	 * partner speed & duplex & pause (autoneg)
+	 */
+	int speed;
+	int duplex;
+	int pause;
+	int asym_pause;
+
+	/* The most recently read link state */
+	int link;
+
+	/* Enabled Interrupts */
+	u32 interrupts;
+
+	/* Union of PHY and Attached devices' supported modes */
+	/* See mii.h for more info */
+	u32 supported;
+	u32 advertising;
+
+	int autoneg;
+
+	int link_timeout;
+
+	/* Interrupt number for this PHY
+	 * -1 means no interrupt */
+	int irq;
+
+	/* private data pointer */
+	/* For use by PHYs to maintain extra state */
+	void *priv;
+
+	/* Interrupt and Polling infrastructure */
+	struct work_struct phy_queue;
+	struct timer_list phy_timer;
+
+	spinlock_t lock;
+
+	struct device *attached_dev;
+
+	void (*adjust_link)(struct device *dev);
+
+	void (*adjust_state)(struct device *dev);
+};
+#define to_phy_device(d) container_of(d, struct phy_device, dev)
+
+/* struct phy_driver: Driver structure for a particular PHY type
+ *
+ * phy_id: The result of reading the UID registers of this PHY
+ *   type, and ANDing them with the phy_id_mask.  This driver
+ *   only works for PHYs with IDs which match this field
+ * name: The friendly name of this PHY type
+ * phy_id_mask: Defines the important bits of the phy_id
+ * features: A list of features (speed, duplex, etc) supported
+ *   by this PHY
+ * flags: A bitfield defining certain other features this PHY
+ *   supports (like interrupts)
+ *
+ * The drivers must implement config_aneg and read_status.  All
+ * other functions are optional. Note that none of these
+ * functions should be called from interrupt time.  The goal is
+ * for the bus read/write functions to be able to block when the
+ * bus transaction is happening, and be freed up by an interrupt
+ * (The MPC85xx has this ability, though it is not currently
+ * supported in the driver).
+ */
+struct phy_driver {
+	u32 phy_id;
+	char *name;
+	unsigned int phy_id_mask;
+	u32 features;
+	u32 flags;
+
+	/* Called to initialize the PHY */
+	int (*probe)(struct phy_device *phydev);
+
+	/* PHY Power Management */
+	int (*suspend)(struct phy_device *phydev);
+	int (*resume)(struct phy_device *phydev);
+
+	/* Configures the advertisement and resets
+	 * autonegotiation if phydev->autoneg is on,
+	 * forces the speed to the current settings in phydev
+	 * if phydev->autoneg is off */
+	int (*config_aneg)(struct phy_device *phydev);
+
+	/* Determines the negotiated speed and duplex */
+	int (*read_status)(struct phy_device *phydev);
+
+	/* Clears any pending interrupts */
+	int (*ack_interrupt)(struct phy_device *phydev);
+
+	/* Enables or disables interrupts */
+	int (*config_intr)(struct phy_device *phydev);
+
+	/* Clears up any memory if needed */
+	void (*remove)(struct phy_device *phydev);
+
+	struct device_driver driver;
+};
+#define to_phy_driver(d) container_of(d, struct phy_driver, driver)
+
+int phy_read(struct phy_device *phydev, u16 regnum);
+int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+struct phy_device* get_phy_device(struct mii_bus *bus, uint addr);
+int phy_clear_interrupt(struct phy_device *phydev);
+int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
+struct phy_device * phy_attach(struct device *dev, const char *phy_id);
+struct phy_device * phy_connect(struct device *dev, const char *phy_id,
+		void (*handler)(struct device *));
+void phy_disconnect(struct phy_device *phydev);
+void phy_detach(struct phy_device *phydev);
+void phy_start(struct phy_device *phydev);
+void phy_stop(struct phy_device *phydev);
+int phy_start_aneg(struct phy_device *phydev);
+int register_mdiobus(struct mii_bus *bus);
+void phy_change(void *data);
+void phy_timer(unsigned long data);
+void phy_sanitize_settings(struct phy_device *phydev);
+
+int genphy_config_advert(struct phy_device *phydev);
+int genphy_setup_forced(struct phy_device *phydev);
+int genphy_restart_aneg(struct phy_device *phydev);
+int gbit_config_aneg(struct phy_device *phydev);
+int genphy_config_aneg(struct phy_device *phydev);
+int genphy_update_link(struct phy_device *phydev);
+int genphy_read_status(struct phy_device *phydev);
+void phy_driver_unregister(struct phy_driver *drv);
+int phy_driver_register(struct phy_driver *new_driver);
+void phy_prepare_link(struct phy_device *phydev,
+		void (*adjust_link)(struct device *));
+void phy_start_machine(struct phy_device *phydev,
+		void (*handler)(struct device *));
+void phy_stop_machine(struct phy_device *phydev);
+
+extern struct bus_type mdio_bus_type;
+extern struct phy_driver genphy_driver;
+#endif /* __PHY_H */

--Apple-Mail-3-1029171143
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed



Andy Fleming
Open Source Team
Freescale Semiconductor, Inc
--Apple-Mail-3-1029171143--
