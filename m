From: Andy Fleming <afleming@freescale.com>
Subject: [RFC PATCH 2/4]: PHY Abstraction Layer III (now with more
	splitiness)
Date: Mon, 25 Jul 2005 14:51:01 -0500 (CDT)
Message-ID: <Pine.LNX.4.61.0507251448000.15537@cde-tx32-ldt113.sps.mot.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Netdev <netdev@vger.kernel.org>,
	linuxppc-embedded <linuxppc-embedded@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch contains the PHY drivers


diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/cicada.c
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
+MODULE_DESCRIPTION("Cicadia PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
+
+static int cis820x_config_init(struct phy_device *phydev)
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
+	.phy_id		= 0x000fc440,
+	.name		= "Cicada Cis8204",
+	.phy_id_mask	= 0x000fffc0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &cis820x_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &cis820x_ack_interrupt,
+	.config_intr	= &cis820x_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init cis8204_init(void)
+{
+	return phy_driver_register(&cis8204_driver);
+}
+
+static void __exit cis8204_exit(void)
+{
+	phy_driver_unregister(&cis8204_driver);
+}
+
+module_init(cis8204_init);
+module_exit(cis8204_exit);
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/davicom.c
@@ -0,0 +1,195 @@
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
+MODULE_DESCRIPTION("Davicom PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
+
+
+#define DM9161_DELAY 1
+static int dm9161_config_intr(struct phy_device *phydev)
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
+	err = genphy_config_aneg(phydev);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int dm9161_config_init(struct phy_device *phydev)
+{
+	int err;
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
+	return 0;
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
+	.config_init	= dm9161_config_init,
+	.config_aneg	= dm9161_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver 	= { .owner = THIS_MODULE,},
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
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init davicom_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&dm9161_driver);
+	if (ret)
+		goto err1;
+
+	ret = phy_driver_register(&dm9131_driver);
+	if (ret)
+		goto err2;
+	return 0;
+
+ err2:	
+	phy_driver_unregister(&dm9161_driver);
+ err1:
+	return ret;
+}
+
+static void __exit davicom_exit(void)
+{
+	phy_driver_unregister(&dm9161_driver);
+	phy_driver_unregister(&dm9131_driver);
+}
+
+module_init(davicom_init);
+module_exit(davicom_exit);
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/lxt.c
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
+MODULE_DESCRIPTION("Intel LXT PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
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
+static int lxt970_config_init(struct phy_device *phydev)
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
+	.config_init	= lxt970_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= lxt970_ack_interrupt,
+	.config_intr	= lxt970_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
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
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init lxt_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&lxt970_driver);
+	if (ret)
+		goto err1;
+
+	ret = phy_driver_register(&lxt971_driver);
+	if (ret)
+		goto err2;
+	return 0;
+
+ err2:	
+	phy_driver_unregister(&lxt970_driver);
+ err1:
+	return ret;
+}
+
+static void __exit lxt_exit(void)
+{
+	phy_driver_unregister(&lxt970_driver);
+	phy_driver_unregister(&lxt971_driver);
+}
+
+module_init(lxt_init);
+module_exit(lxt_exit);
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/marvell.c
@@ -0,0 +1,140 @@
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
+MODULE_DESCRIPTION("Marvell PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
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
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init marvell_init(void)
+{
+	return phy_driver_register(&m88e1101_driver);
+}
+
+static void __exit marvell_exit(void)
+{
+	phy_driver_unregister(&m88e1101_driver);
+}
+
+module_init(marvell_init);
+module_exit(marvell_exit);
diff --git a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/phy/qsemi.c
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
+MODULE_DESCRIPTION("Quality Semiconductor PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
+
+/* Returns 0, unless there's a write error */
+static int qs6612_config_init(struct phy_device *phydev)
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
+static int qs6612_ack_interrupt(struct phy_device *phydev)
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
+static int qs6612_config_intr(struct phy_device *phydev)
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
+	.config_init	= qs6612_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= qs6612_ack_interrupt,
+	.config_intr	= qs6612_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init qs6612_init(void)
+{
+	return phy_driver_register(&qs6612_driver);
+}
+
+static void __exit qs6612_exit(void)
+{
+	phy_driver_unregister(&qs6612_driver);
+}
+
+module_init(qs6612_init);
+module_exit(qs6612_exit);
diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
new file mode 100644
--- /dev/null
+++ b/Documentation/networking/phy.txt
@@ -0,0 +1,288 @@
+
+-------
+PHY Abstraction Layer
+(Updated 2005-07-21)
+
+Purpose
+
+ Most network devices consist of set of registers which provide an interface
+ to a MAC layer, which communicates with the physical connection through a
+ PHY.  The PHY concerns itself with negotiating link parameters with the link
+ partner on the other side of the network connection (typically, an ethernet
+ cable), and provides a register interface to allow drivers to determine what
+ settings were chosen, and to configure what settings are allowed.
+
+ While these devices are distinct from the network devices, and conform to a
+ standard layout for the registers, it has been common practice to integrate
+ the PHY management code with the network driver.  This has resulted in large
+ amounts of redundant code.  Also, on embedded systems with multiple (and
+ sometimes quite different) ethernet controllers connected to the same 
+ management bus, it is difficult to ensure safe use of the bus.
+
+ Since the PHYs are devices, and the management busses through which they are
+ accessed are, in fact, busses, the PHY Abstraction Layer treats them as such.
+ In doing so, it has these goals:
+
+   1) Increase code-reuse
+   2) Increase overall code-maintainability
+   3) Speed development time for new network drivers, and for new systems
+ 
+ Basically, this layer is meant to provide an interface to PHY devices which
+ allows network driver writers to write as little code as possible, while
+ still providing a full feature set.
+
+The MDIO bus
+
+ Most network devices are connected to a PHY by means of a management bus.
+ Different devices use different busses (though some share common interfaces).
+ In order to take advantage of the PAL, each bus interface needs to be
+ registered as a distinct device.
+
+ 1) read and write functions must be implemented.  Their prototypes are:
+
+     int write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+     int read(struct mii_bus *bus, int mii_id, int regnum);
+
+   mii_id is the address on the bus for the PHY, and regnum is the register
+   number.  These functions are guaranteed not to be called from interrupt
+   time, so it is safe for them to block, waiting for an interrupt to signal
+   the operation is complete
+ 
+ 2) A reset function is necessary.  This is used to return the bus to an
+   initialized state.
+
+ 3) A probe function is needed.  This function should set up anything the bus
+   driver needs, setup the mii_bus structure, and register with the PAL using
+   mdiobus_register.  Similarly, there's a remove function to undo all of
+   that (use mdiobus_unregister).
+ 
+ 4) Like any driver, the device_driver structure must be configured, and init
+   exit functions are used to register the driver.
+
+ 5) The bus must also be declared somewhere as a device, and registered.
+
+ As an example for how one driver implemented an mdio bus driver, see
+ drivers/net/gianfar_mii.c and arch/ppc/syslib/mpc85xx_devices.c
+
+Connecting to a PHY
+
+ Sometime during startup, the network driver needs to establish a connection
+ between the PHY device, and the network device.  At this time, the PHY's bus
+ and drivers need to all have been loaded, so it is ready for the connection.
+ At this point, there are several ways to connect to the PHY:
+
+ 1) The PAL handles everything, and only calls the network driver when
+   the link state changes, so it can react.
+
+ 2) The PAL handles everything except interrupts (usually because the
+   controller has the interrupt registers).
+
+ 3) The PAL handles everything, but checks in with the driver every second,
+   allowing the network driver to react first to any changes before the PAL
+   does.
+ 
+ 4) The PAL serves only as a library of functions, with the network device
+   manually calling functions to update status, and configure the PHY
+
+
+Letting the PHY Abstraction Layer do Everything
+
+ If you choose option 1 (The hope is that every driver can, but to still be
+ useful to drivers that can't), connecting to the PHY is simple:
+
+ First, you need a function to react to changes in the link state.  This
+ function follows this protocol:
+
+   static void adjust_link(struct net_device *dev);
+ 
+ Next, you need to know the device name of the PHY connected to this device. 
+ The name will look something like, "phy0:0", where the first number is the
+ bus id, and the second is the PHY's address on that bus.
+ 
+ Now, to connect, just call this function:
+ 
+   phydev = phy_connect(dev, phy_name, &adjust_link, flags);
+
+ phydev is a pointer to the phy_device structure which represents the PHY.  If
+ phy_connect is successful, it will return the pointer.  dev, here, is the
+ pointer to your net_device.  Once done, this function will have started the
+ PHY's software state machine, and registered for the PHY's interrupt, if it
+ has one.  The phydev structure will be populated with information about the
+ current state, though the PHY will not yet be truly operational at this
+ point.
+
+ flags is a u32 which can optionally contain phy-specific flags.
+ This is useful if the system has put hardware restrictions on
+ the PHY/controller, of which the PHY needs to be aware.
+
+ Now just make sure that phydev->supported and phydev->advertising have any
+ values pruned from them which don't make sense for your controller (a 10/100
+ controller may be connected to a gigabit capable PHY, so you would need to
+ mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for definitions
+ for these bitfields. Note that you should not SET any bits, or the PHY may
+ get put into an unsupported state.
+
+ Lastly, once the controller is ready to handle network traffic, you call
+ phy_start(phydev).  This tells the PAL that you are ready, and configures the
+ PHY to connect to the network.  If you want to handle your own interrupts,
+ just set phydev->irq to PHY_IGNORE_INTERRUPT before you call phy_start.
+ Similarly, if you don't want to use interrupts, set phydev->irq to PHY_POLL.
+
+ When you want to disconnect from the network (even if just briefly), you call
+ phy_stop(phydev).
+
+Keeping Close Tabs on the PAL
+
+ It is possible that the PAL's built-in state machine needs a little help to
+ keep your network device and the PHY properly in sync.  If so, you can
+ register a helper function when connecting to the PHY, which will be called
+ every second before the state machine reacts to any changes.  To do this, you
+ need to manually call phy_attach() and phy_prepare_link(), and then call
+ phy_start_machine() with the second argument set to point to your special
+ handler.
+
+ Currently there are no examples of how to use this functionality, and testing
+ on it has been limited because the author does not have any drivers which use
+ it (they all use option 1).  So Caveat Emptor.
+
+Doing it all yourself
+
+ There's a remote chance that the PAL's built-in state machine cannot track
+ the complex interactions between the PHY and your network device.  If this is
+ so, you can simply call phy_attach(), and not call phy_start_machine or
+ phy_prepare_link().  This will mean that phydev->state is entirely yours to
+ handle (phy_start and phy_stop toggle between some of the states, so you
+ might need to avoid them).
+
+ An effort has been made to make sure that useful functionality can be
+ accessed without the state-machine running, and most of these functions are
+ descended from functions which did not interact with a complex state-machine.
+ However, again, no effort has been made so far to test running without the
+ state machine, so tryer beware.
+
+ Here is a brief rundown of the functions:
+
+ int phy_read(struct phy_device *phydev, u16 regnum);
+ int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
+
+   Simple read/write primitives.  They invoke the bus's read/write function
+   pointers.
+
+ void phy_print_status(struct phy_device *phydev);
+ 
+   A convenience function to print out the PHY status neatly.
+
+ int phy_clear_interrupt(struct phy_device *phydev);
+ int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
+   
+   Clear the PHY's interrupt, and configure which ones are allowed,
+   respectively.  Currently only supports all on, or all off.
+ 
+ int phy_enable_interrupts(struct phy_device *phydev);
+ int phy_disable_interrupts(struct phy_device *phydev);
+
+   Functions which enable/disable PHY interrupts, clearing them
+   before and after, respectively.
+
+ int phy_start_interrupts(struct phy_device *phydev);
+ int phy_stop_interrupts(struct phy_device *phydev);
+
+   Requests the IRQ for the PHY interrupts, then enables them for
+   start, or disables then frees them for stop.
+
+ struct phy_device * phy_attach(struct net_device *dev, const char *phy_id,
+		 u32 flags);
+
+   Attaches a network device to a particular PHY, binding the PHY to a generic
+   driver if none was found during bus initialization.  Passes in
+   any phy-specific flags as needed.
+
+ int phy_start_aneg(struct phy_device *phydev);
+   
+   Using variables inside the phydev structure, either configures advertising
+   and resets autonegotiation, or disables autonegotiation, and configures
+   forced settings.
+
+ static inline int phy_read_status(struct phy_device *phydev);
+
+   Fills the phydev structure with up-to-date information about the current
+   settings in the PHY.
+
+ void phy_sanitize_settings(struct phy_device *phydev)
+   
+   Resolves differences between currently desired settings, and
+   supported settings for the given PHY device.  Does not make
+   the changes in the hardware, though.
+
+ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
+ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
+
+   Ethtool convenience functions.
+
+ int phy_mii_ioctl(struct phy_device *phydev,
+                 struct mii_ioctl_data *mii_data, int cmd);
+
+   The MII ioctl.  Note that this function will completely screw up the state
+   machine if you write registers like BMCR, BMSR, ADVERTISE, etc.  Best to
+   use this only to write registers which are not standard, and don't set off
+   a renegotiation.
+
+
+PHY Device Drivers
+
+ With the PHY Abstraction Layer, adding support for new PHYs is
+ quite easy.  In some cases, no work is required at all!  However,
+ many PHYs require a little hand-holding to get up-and-running.
+
+Generic PHY driver
+
+ If the desired PHY doesn't have any errata, quirks, or special
+ features you want to support, then it may be best to not add
+ support, and let the PHY Abstraction Layer's Generic PHY Driver
+ do all of the work.  
+
+Writing a PHY driver
+
+ If you do need to write a PHY driver, the first thing to do is
+ make sure it can be matched with an appropriate PHY device.
+ This is done during bus initialization by reading the device's
+ UID (stored in registers 2 and 3), then comparing it to each
+ driver's phy_id field by ANDing it with each driver's
+ phy_id_mask field.  Also, it needs a name.  Here's an example:
+
+   static struct phy_driver dm9161_driver = {
+         .phy_id         = 0x0181b880,
+	 .name           = "Davicom DM9161E",
+	 .phy_id_mask    = 0x0ffffff0,
+	 ...
+   }
+
+ Next, you need to specify what features (speed, duplex, autoneg,
+ etc) your PHY device and driver support.  Most PHYs support
+ PHY_BASIC_FEATURES, but you can look in include/mii.h for other
+ features.
+
+ Each driver consists of a number of function pointers:
+
+   config_init: configures PHY into a sane state after a reset.
+     For instance, a Davicom PHY requires descrambling disabled.
+   probe: Does any setup needed by the driver
+   suspend/resume: power management
+   config_aneg: Changes the speed/duplex/negotiation settings
+   read_status: Reads the current speed/duplex/negotiation settings
+   ack_interrupt: Clear a pending interrupt
+   config_intr: Enable or disable interrupts
+   remove: Does any driver take-down
+
+ Of these, only config_aneg and read_status are required to be
+ assigned by the driver code.  The rest are optional.  Also, it is
+ preferred to use the generic phy driver's versions of these two
+ functions if at all possible: genphy_read_status and
+ genphy_config_aneg.  If this is not possible, it is likely that
+ you only need to perform some actions before and after invoking
+ these functions, and so your functions will wrap the generic
+ ones.
+
+ Feel free to look at the Marvell, Cicada, and Davicom drivers in
+ drivers/net/phy/ for examples (the lxt and qsemi drivers have
+ not been tested as of this writing)
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -504,6 +504,7 @@ int phy_enable_interrupts(struct phy_dev
 
 	return err;
 }
+EXPORT_SYMBOL(phy_enable_interrupts);
 
 /* Disable the PHY interrupts from the PHY side */
 int phy_disable_interrupts(struct phy_device *phydev)
@@ -529,6 +530,7 @@ phy_err:
 
 	return err;
 }
+EXPORT_SYMBOL(phy_disable_interrupts);
 
 /* phy_start_interrupts
  *
