From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.30 1/3] netdev: Merge UCC and gianfar MDIO bus drivers
Date: Tue,  3 Feb 2009 19:17:01 -0600
Message-ID: <1233710223-17808-3-git-send-email-afleming@freescale.com>
References: <1233710223-17808-1-git-send-email-afleming@freescale.com>
 <1233710223-17808-2-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57477 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbZBDBR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 20:17:27 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n141H9cw004750
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:17:09 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id n141H4YR016784
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 19:17:04 -0600 (CST)
In-Reply-To: <1233710223-17808-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO bus drivers for the UCC and gianfar ethernet controllers are
essentially the same.  There's no reason to duplicate that much code.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/Kconfig            |    9 +
 drivers/net/Makefile           |    5 +-
 drivers/net/fsl_pq_mdio.c      |  463 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/fsl_pq_mdio.h      |   45 ++++
 drivers/net/gianfar.c          |   23 +--
 drivers/net/gianfar.h          |   13 +-
 drivers/net/gianfar_mii.h      |   54 -----
 drivers/net/ucc_geth.c         |   16 +-
 drivers/net/ucc_geth.h         |   14 +-
 drivers/net/ucc_geth_ethtool.c |    1 -
 drivers/net/ucc_geth_mii.c     |  295 -------------------------
 drivers/net/ucc_geth_mii.h     |  101 ---------
 12 files changed, 549 insertions(+), 490 deletions(-)
 create mode 100644 drivers/net/fsl_pq_mdio.c
 create mode 100644 drivers/net/fsl_pq_mdio.h
 delete mode 100644 drivers/net/gianfar_mii.h
 delete mode 100644 drivers/net/ucc_geth_mii.c
 delete mode 100644 drivers/net/ucc_geth_mii.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6bdfd47..ff84fb0 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2273,9 +2273,17 @@ config GELIC_WIRELESS_OLD_PSK_INTERFACE
 
           If unsure, say N.
 
+config FSL_PQ_MDIO
+	tristate "Freescale PQ MDIO"
+	depends on FSL_SOC
+	select PHYLIB
+	help
+	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
+
 config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on FSL_SOC
+	select FSL_PQ_MDIO
 	select PHYLIB
 	select CRC32
 	help
@@ -2285,6 +2293,7 @@ config GIANFAR
 config UCC_GETH
 	tristate "Freescale QE Gigabit Ethernet"
 	depends on QUICC_ENGINE
+	select FSL_PQ_MDIO
 	select PHYLIB
 	help
 	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index a3c5c00..ad87ba7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -24,11 +24,12 @@ obj-$(CONFIG_JME) += jme.o
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
-		gianfar_mii.o \
 		gianfar_sysfs.o
 
 obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
-ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o ucc_geth_ethtool.o
+ucc_geth_driver-objs := ucc_geth.o ucc_geth_ethtool.o
+
+obj-$(CONFIG_FSL_PQ_MDIO) += fsl_pq_mdio.o
 
 #
 # link order important here
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
new file mode 100644
index 0000000..c434a15
--- /dev/null
+++ b/drivers/net/fsl_pq_mdio.c
@@ -0,0 +1,463 @@
+/*
+ * Freescale PowerQUICC Ethernet Driver -- MIIM bus implementation
+ * Provides Bus interface for MIIM regs
+ *
+ * Author: Andy Fleming <afleming@freescale.com>
+ *
+ * Copyright (c) 2002-2004,2008 Freescale Semiconductor, Inc.
+ *
+ * Based on gianfar_mii.c and ucc_geth_mii.c (Li Yang, Kim Phillips)
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/kernel.h>
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
+#include <linux/platform_device.h>
+#include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <asm/ucc.h>
+
+#include "gianfar.h"
+#include "fsl_pq_mdio.h"
+
+/*
+ * Write value to the PHY at mii_id at register regnum,
+ * on the bus attached to the local interface, which may be different from the
+ * generic mdio bus (tied to a single interface), waiting until the write is
+ * done before returning. This is helpful in programming interfaces like
+ * the TBI which control interfaces like onchip SERDES and are always tied to
+ * the local mdio pins, which may not be the same as system mdio bus, used for
+ * controlling the external PHYs, for example.
+ */
+int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
+		int regnum, u16 value)
+{
+	/* Set the PHY address and the register address we want to write */
+	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
+
+	/* Write out the value we want */
+	out_be32(&regs->miimcon, value);
+
+	/* Wait for the transaction to finish */
+	while (in_be32(&regs->miimind) & MIIMIND_BUSY)
+		cpu_relax();
+
+	return 0;
+}
+
+/*
+ * Read the bus for PHY at addr mii_id, register regnum, and
+ * return the value.  Clears miimcom first.  All PHY operation
+ * done on the bus attached to the local interface,
+ * which may be different from the generic mdio bus
+ * This is helpful in programming interfaces like
+ * the TBI which, in turn, control interfaces like onchip SERDES
+ * and are always tied to the local mdio pins, which may not be the
+ * same as system mdio bus, used for controlling the external PHYs, for eg.
+ */
+int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
+		int mii_id, int regnum)
+{
+	u16 value;
+
+	/* Set the PHY address and the register address we want to read */
+	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
+
+	/* Clear miimcom, and then initiate a read */
+	out_be32(&regs->miimcom, 0);
+	out_be32(&regs->miimcom, MII_READ_COMMAND);
+
+	/* Wait for the transaction to finish */
+	while (in_be32(&regs->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
+		cpu_relax();
+
+	/* Grab the value of the register from miimstat */
+	value = in_be32(&regs->miimstat);
+
+	return value;
+}
+
+/*
+ * Write value to the PHY at mii_id at register regnum,
+ * on the bus, waiting until the write is done before returning.
+ */
+int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+{
+	struct fsl_pq_mdio __iomem *regs = (void __iomem *)bus->priv;
+
+	/* Write to the local MII regs */
+	return(fsl_pq_local_mdio_write(regs, mii_id, regnum, value));
+}
+
+/*
+ * Read the bus for PHY at addr mii_id, register regnum, and
+ * return the value.  Clears miimcom first.
+ */
+int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct fsl_pq_mdio __iomem *regs = (void __iomem *)bus->priv;
+
+	/* Read the local MII regs */
+	return(fsl_pq_local_mdio_read(regs, mii_id, regnum));
+}
+
+/* Reset the MIIM registers, and wait for the bus to free */
+static int fsl_pq_mdio_reset(struct mii_bus *bus)
+{
+	struct fsl_pq_mdio __iomem *regs = (void __iomem *)bus->priv;
+	unsigned int timeout = PHY_INIT_TIMEOUT;
+
+	mutex_lock(&bus->mdio_lock);
+
+	/* Reset the management interface */
+	out_be32(&regs->miimcfg, MIIMCFG_RESET);
+
+	/* Setup the MII Mgmt clock speed */
+	out_be32(&regs->miimcfg, MIIMCFG_INIT_VALUE);
+
+	/* Wait until the bus is free */
+	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
+		cpu_relax();
+
+	mutex_unlock(&bus->mdio_lock);
+
+	if(timeout == 0) {
+		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
+				bus->name);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+/* Allocate an array which provides irq #s for each PHY on the given bus */
+static int *create_irq_map(struct device_node *np)
+{
+	int *irqs;
+	int i;
+	struct device_node *child = NULL;
+
+	irqs = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
+
+	if (!irqs)
+		return NULL;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		irqs[i] = PHY_POLL;
+
+	while ((child = of_get_next_child(np, child)) != NULL) {
+		int irq = irq_of_parse_and_map(child, 0);
+		const u32 *id;
+
+		if (irq == NO_IRQ)
+			continue;
+
+		id = of_get_property(child, "reg", NULL);
+
+		if (!id)
+			continue;
+
+		if (*id < PHY_MAX_ADDR && *id >= 0)
+			irqs[*id] = irq;
+		else
+			printk(KERN_WARNING "%s: "
+					"%d is not a valid PHY address\n",
+					np->full_name, *id);
+	}
+
+	return irqs;
+}
+
+void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
+{
+	const u32 *reg;
+
+	reg = of_get_property(np, "reg", NULL);
+
+	snprintf(name, MII_BUS_ID_SIZE, "%s@%x", np->name, reg ? *reg : 0);
+}
+
+/* Scan the bus in reverse, looking for an empty spot */
+static int fsl_pq_mdio_find_free(struct mii_bus *new_bus)
+{
+	int i;
+
+	for (i = PHY_MAX_ADDR; i > 0; i--) {
+		u32 phy_id;
+
+		if (get_phy_id(new_bus, i, &phy_id))
+			return -1;
+
+		if (phy_id == 0xffffffff)
+			break;
+	}
+
+	return i;
+}
+
+
+#ifdef CONFIG_GIANFAR
+static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs)
+{
+	struct gfar __iomem *enet_regs;
+
+	/*
+	 * This is mildly evil, but so is our hardware for doing this.
+	 * Also, we have to cast back to struct gfar because of
+	 * definition weirdness done in gianfar.h.
+	 */
+	enet_regs = (struct gfar __iomem *)
+		((char __iomem *)regs - offsetof(struct gfar, gfar_mii_regs));
+
+	return &enet_regs->tbipa;
+}
+#endif
+
+
+#ifdef CONFIG_UCC_GETH
+static int get_ucc_id_for_range(u64 start, u64 end, u32 *ucc_id)
+{
+	struct device_node *np = NULL;
+	int err = 0;
+
+	for_each_compatible_node(np, NULL, "ucc_geth") {
+		struct resource tempres;
+
+		err = of_address_to_resource(np, 0, &tempres);
+		if (err)
+			continue;
+
+		/* if our mdio regs fall within this UCC regs range */
+		if ((start >= tempres.start) && (end <= tempres.end)) {
+			/* Find the id of the UCC */
+			const u32 *id;
+
+			id = of_get_property(np, "cell-index", NULL);
+			if (!id) {
+				id = of_get_property(np, "device-id", NULL);
+				if (!id)
+					continue;
+			}
+
+			*ucc_id = *id;
+
+			return 0;
+		}
+	}
+
+	if (err)
+		return err;
+	else
+		return -EINVAL;
+}
+#endif
+
+
+static int fsl_pq_mdio_probe(struct of_device *ofdev,
+		const struct of_device_id *match)
+{
+	struct device_node *np = ofdev->node;
+	struct device_node *tbi;
+	struct fsl_pq_mdio __iomem *regs;
+	u32 __iomem *tbipa;
+	struct mii_bus *new_bus;
+	int tbiaddr = -1;
+	u64 addr, size;
+	int err = 0;
+
+	new_bus = mdiobus_alloc();
+	if (NULL == new_bus)
+		return -ENOMEM;
+
+	new_bus->name = "Freescale PowerQUICC MII Bus",
+	new_bus->read = &fsl_pq_mdio_read,
+	new_bus->write = &fsl_pq_mdio_write,
+	new_bus->reset = &fsl_pq_mdio_reset,
+	fsl_pq_mdio_bus_name(new_bus->id, np);
+
+	/* Set the PHY base address */
+	addr = of_translate_address(np, of_get_address(np, 0, &size, NULL));
+	regs = ioremap(addr, size);
+
+	if (NULL == regs) {
+		err = -ENOMEM;
+		goto err_free_bus;
+	}
+
+	new_bus->priv = (void __force *)regs;
+
+	new_bus->irq = create_irq_map(np);
+
+	if (NULL == new_bus->irq) {
+		err = -ENOMEM;
+		goto err_unmap_regs;
+	}
+
+	new_bus->parent = &ofdev->dev;
+	dev_set_drvdata(&ofdev->dev, new_bus);
+
+	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
+			of_device_is_compatible(np, "gianfar")) {
+#ifdef CONFIG_GIANFAR
+		tbipa = get_gfar_tbipa(regs);
+#else
+		err = -ENODEV;
+		goto err_free_irqs;
+#endif
+	} else if (of_device_is_compatible(np, "fsl,ucc-mdio") ||
+			of_device_is_compatible(np, "ucc_geth_phy")) {
+#ifdef CONFIG_UCC_GETH
+		u32 id;
+
+		tbipa = &regs->utbipar;
+
+		if ((err = get_ucc_id_for_range(addr, addr + size, &id)))
+			goto err_free_irqs;
+
+		ucc_set_qe_mux_mii_mng(id - 1);
+#else
+		err = -ENODEV;
+		goto err_free_irqs;
+#endif
+	} else {
+		err = -ENODEV;
+		goto err_free_irqs;
+	}
+
+	for_each_child_of_node(np, tbi) {
+		if (!strncmp(tbi->type, "tbi-phy", 8))
+			break;
+	}
+
+	if (tbi) {
+		const u32 *prop = of_get_property(tbi, "reg", NULL);
+
+		if (prop)
+			tbiaddr = *prop;
+	}
+
+	if (tbiaddr == -1) {
+		out_be32(tbipa, 0);
+
+		tbiaddr = fsl_pq_mdio_find_free(new_bus);
+	}
+
+	/*
+	 * We define TBIPA at 0 to be illegal, opting to fail for boards that
+	 * have PHYs at 1-31, rather than change tbipa and rescan.
+	 */
+	if (tbiaddr == 0) {
+		err = -EBUSY;
+
+		goto err_free_irqs;
+	}
+
+	out_be32(tbipa, tbiaddr);
+
+	/*
+	 * The TBIPHY-only buses will find PHYs at every address,
+	 * so we mask them all but the TBI
+	 */
+	if (!of_device_is_compatible(np, "fsl,gianfar-mdio"))
+		new_bus->phy_mask = ~(1 << tbiaddr);
+
+	err = mdiobus_register(new_bus);
+
+	if (err) {
+		printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
+				new_bus->name);
+		goto err_free_irqs;
+	}
+
+	return 0;
+
+err_free_irqs:
+	kfree(new_bus->irq);
+err_unmap_regs:
+	iounmap(regs);
+err_free_bus:
+	kfree(new_bus);
+
+	return err;
+}
+
+
+static int fsl_pq_mdio_remove(struct of_device *ofdev)
+{
+	struct device *device = &ofdev->dev;
+	struct mii_bus *bus = dev_get_drvdata(device);
+
+	mdiobus_unregister(bus);
+
+	dev_set_drvdata(device, NULL);
+
+	iounmap((void __iomem *)bus->priv);
+	bus->priv = NULL;
+	mdiobus_free(bus);
+
+	return 0;
+}
+
+static struct of_device_id fsl_pq_mdio_match[] = {
+	{
+		.type = "mdio",
+		.compatible = "ucc_geth_phy",
+	},
+	{
+		.type = "mdio",
+		.compatible = "gianfar",
+	},
+	{
+		.compatible = "fsl,ucc-mdio",
+	},
+	{
+		.compatible = "fsl,gianfar-tbi",
+	},
+	{
+		.compatible = "fsl,gianfar-mdio",
+	},
+	{},
+};
+
+static struct of_platform_driver fsl_pq_mdio_driver = {
+	.name = "fsl-pq_mdio",
+	.probe = fsl_pq_mdio_probe,
+	.remove = fsl_pq_mdio_remove,
+	.match_table = fsl_pq_mdio_match,
+};
+
+int __init fsl_pq_mdio_init(void)
+{
+	return of_register_platform_driver(&fsl_pq_mdio_driver);
+}
+
+void fsl_pq_mdio_exit(void)
+{
+	of_unregister_platform_driver(&fsl_pq_mdio_driver);
+}
+subsys_initcall_sync(fsl_pq_mdio_init);
+module_exit(fsl_pq_mdio_exit);
diff --git a/drivers/net/fsl_pq_mdio.h b/drivers/net/fsl_pq_mdio.h
new file mode 100644
index 0000000..36dad52
--- /dev/null
+++ b/drivers/net/fsl_pq_mdio.h
@@ -0,0 +1,45 @@
+/*
+ * Freescale PowerQUICC MDIO Driver -- MII Management Bus Implementation
+ * Driver for the MDIO bus controller on Freescale PowerQUICC processors
+ *
+ * Author: Andy Fleming
+ *
+ * Copyright (c) 2002-2004,2008 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#ifndef __FSL_PQ_MDIO_H
+#define __FSL_PQ_MDIO_H
+
+#define MIIMIND_BUSY            0x00000001
+#define MIIMIND_NOTVALID        0x00000004
+#define MIIMCFG_INIT_VALUE	0x00000007
+#define MIIMCFG_RESET           0x80000000
+
+#define MII_READ_COMMAND       0x00000001
+
+struct fsl_pq_mdio {
+	u32 miimcfg;		/* MII management configuration reg */
+	u32 miimcom;		/* MII management command reg */
+	u32 miimadd;		/* MII management address reg */
+	u32 miimcon;		/* MII management control reg */
+	u32 miimstat;		/* MII management status reg */
+	u32 miimind;		/* MII management indication reg */
+	u8 reserved[28];	/* Space holder */
+	u32 utbipar;		/* TBI phy address reg (only on UCC) */
+} __attribute__ ((packed));
+
+
+int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
+int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
+			  int regnum, u16 value);
+int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs, int mii_id, int regnum);
+int __init fsl_pq_mdio_init(void);
+void fsl_pq_mdio_exit(void);
+void fsl_pq_mdio_bus_name(char *name, struct device_node *np);
+#endif /* FSL_PQ_MDIO_H */
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index acae2d8..1085e71 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -93,7 +93,7 @@
 #include <linux/of.h>
 
 #include "gianfar.h"
-#include "gianfar_mii.h"
+#include "fsl_pq_mdio.h"
 
 #define TX_TIMEOUT      (1*HZ)
 #undef BRIEF_GFAR_ERRORS
@@ -255,7 +255,7 @@ static int gfar_of_init(struct net_device *dev)
 		of_node_put(phy);
 		of_node_put(mdio);
 
-		gfar_mdio_bus_name(bus_name, mdio);
+		fsl_pq_mdio_bus_name(bus_name, mdio);
 		snprintf(priv->phy_bus_id, sizeof(priv->phy_bus_id), "%s:%02x",
 				bus_name, *id);
 	}
@@ -425,7 +425,7 @@ static int gfar_probe(struct of_device *ofdev,
 		priv->hash_width = 8;
 
 		priv->hash_regs[0] = &priv->regs->gaddr0;
-                priv->hash_regs[1] = &priv->regs->gaddr1;
+		priv->hash_regs[1] = &priv->regs->gaddr1;
 		priv->hash_regs[2] = &priv->regs->gaddr2;
 		priv->hash_regs[3] = &priv->regs->gaddr3;
 		priv->hash_regs[4] = &priv->regs->gaddr4;
@@ -838,7 +838,7 @@ void stop_gfar(struct net_device *dev)
 		free_irq(priv->interruptTransmit, dev);
 		free_irq(priv->interruptReceive, dev);
 	} else {
- 		free_irq(priv->interruptTransmit, dev);
+		free_irq(priv->interruptTransmit, dev);
 	}
 
 	free_skb_resources(priv);
@@ -1829,6 +1829,8 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 				skb_put(skb, pkt_len);
 				dev->stats.rx_bytes += pkt_len;
 
+				if (in_irq() || irqs_disabled())
+					printk("Interrupt problem!\n");
 				gfar_process_frame(dev, skb, amount_pull);
 
 			} else {
@@ -2302,23 +2304,12 @@ static struct of_platform_driver gfar_driver = {
 
 static int __init gfar_init(void)
 {
-	int err = gfar_mdio_init();
-
-	if (err)
-		return err;
-
-	err = of_register_platform_driver(&gfar_driver);
-
-	if (err)
-		gfar_mdio_exit();
-
-	return err;
+	return of_register_platform_driver(&gfar_driver);
 }
 
 static void __exit gfar_exit(void)
 {
 	of_unregister_platform_driver(&gfar_driver);
-	gfar_mdio_exit();
 }
 
 module_init(gfar_init);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index eaa8689..e5ed2cc 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -46,7 +46,6 @@
 #include <linux/workqueue.h>
 #include <linux/ethtool.h>
 #include <linux/fsl_devices.h>
-#include "gianfar_mii.h"
 
 /* The maximum number of packets to be handled in one call of gfar_poll */
 #define GFAR_DEV_WEIGHT 64
@@ -126,9 +125,12 @@ extern const char gfar_driver_version[];
 #define DEFAULT_RX_COALESCE 0
 #define DEFAULT_RXCOUNT	0
 
-#define MIIMCFG_INIT_VALUE	0x00000007
-#define MIIMCFG_RESET           0x80000000
-#define MIIMIND_BUSY            0x00000001
+#define GFAR_SUPPORTED (SUPPORTED_10baseT_Half \
+		| SUPPORTED_10baseT_Full \
+		| SUPPORTED_100baseT_Half \
+		| SUPPORTED_100baseT_Full \
+		| SUPPORTED_Autoneg \
+		| SUPPORTED_MII)
 
 /* TBI register addresses */
 #define MII_TBICON		0x11
@@ -826,8 +828,5 @@ extern void gfar_halt(struct net_device *dev);
 extern void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev,
 		int enable, u32 regnum, u32 read);
 void gfar_init_sysfs(struct net_device *dev);
-int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
-			  int regnum, u16 value);
-int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
deleted file mode 100644
index 65c242c..0000000
--- a/drivers/net/gianfar_mii.h
+++ /dev/null
@@ -1,54 +0,0 @@
-/*
- * drivers/net/gianfar_mii.h
- *
- * Gianfar Ethernet Driver -- MII Management Bus Implementation
- * Driver for the MDIO bus controller in the Gianfar register space
- *
- * Author: Andy Fleming
- * Maintainer: Kumar Gala
- *
- * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __GIANFAR_MII_H
-#define __GIANFAR_MII_H
-
-struct gfar_private; /* forward ref */
-
-#define MIIMIND_BUSY            0x00000001
-#define MIIMIND_NOTVALID        0x00000004
-
-#define MII_READ_COMMAND       0x00000001
-
-#define GFAR_SUPPORTED (SUPPORTED_10baseT_Half \
-		| SUPPORTED_10baseT_Full \
-		| SUPPORTED_100baseT_Half \
-		| SUPPORTED_100baseT_Full \
-		| SUPPORTED_Autoneg \
-		| SUPPORTED_MII)
-
-struct gfar_mii {
-	u32	miimcfg;	/* 0x.520 - MII Management Config Register */
-	u32	miimcom;	/* 0x.524 - MII Management Command Register */
-	u32	miimadd;	/* 0x.528 - MII Management Address Register */
-	u32	miimcon;	/* 0x.52c - MII Management Control Register */
-	u32	miimstat;	/* 0x.530 - MII Management Status Register */
-	u32	miimind;	/* 0x.534 - MII Management Indicator Register */
-};
-
-int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
-int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
-int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
-			  int regnum, u16 value);
-int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
-struct mii_bus *gfar_get_miibus(const struct gfar_private *priv);
-int __init gfar_mdio_init(void);
-void gfar_mdio_exit(void);
-
-void gfar_mdio_bus_name(char *name, struct device_node *np);
-#endif /* GIANFAR_PHY_H */
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e879868..f792637 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -39,7 +39,7 @@
 #include <asm/ucc_fast.h>
 
 #include "ucc_geth.h"
-#include "ucc_geth_mii.h"
+#include "fsl_pq_mdio.h"
 
 #undef DEBUG
 
@@ -1557,7 +1557,7 @@ static int init_phy(struct net_device *dev)
 	of_node_put(phy);
 	of_node_put(mdio);
 
-	uec_mdio_bus_name(bus_name, mdio);
+	fsl_pq_mdio_bus_name(bus_name, mdio);
 	snprintf(phy_id, sizeof(phy_id), "%s:%02x",
                                 bus_name, *id);
 
@@ -3657,7 +3657,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		if (err)
 			return -1;
 
-		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "%x", res.start);
+		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "%x",
+				res.start&0xfffff);
 	}
 
 	/* get the phy interface type, or default to MII */
@@ -3803,11 +3804,6 @@ static int __init ucc_geth_init(void)
 {
 	int i, ret;
 
-	ret = uec_mdio_init();
-
-	if (ret)
-		return ret;
-
 	if (netif_msg_drv(&debug))
 		printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
 	for (i = 0; i < 8; i++)
@@ -3816,16 +3812,12 @@ static int __init ucc_geth_init(void)
 
 	ret = of_register_platform_driver(&ucc_geth_driver);
 
-	if (ret)
-		uec_mdio_exit();
-
 	return ret;
 }
 
 static void __exit ucc_geth_exit(void)
 {
 	of_unregister_platform_driver(&ucc_geth_driver);
-	uec_mdio_exit();
 }
 
 module_init(ucc_geth_init);
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 16cbe42..66d1897 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -28,8 +28,6 @@
 #include <asm/ucc.h>
 #include <asm/ucc_fast.h>
 
-#include "ucc_geth_mii.h"
-
 #define DRV_DESC "QE UCC Gigabit Ethernet Controller"
 #define DRV_NAME "ucc_geth"
 #define DRV_VERSION "1.1"
@@ -184,6 +182,18 @@ struct ucc_geth {
 #define UCCE_RX_EVENTS  (UCCE_RXF | UCC_GETH_UCCE_BSY)
 #define UCCE_TX_EVENTS	(UCCE_TXB | UCC_GETH_UCCE_TXE)
 
+/* TBI defines */
+#define	ENET_TBI_MII_CR		0x00	/* Control */
+#define	ENET_TBI_MII_SR		0x01	/* Status */
+#define	ENET_TBI_MII_ANA	0x04	/* AN advertisement */
+#define	ENET_TBI_MII_ANLPBPA	0x05	/* AN link partner base page ability */
+#define	ENET_TBI_MII_ANEX	0x06	/* AN expansion */
+#define	ENET_TBI_MII_ANNPT	0x07	/* AN next page transmit */
+#define	ENET_TBI_MII_ANLPANP	0x08	/* AN link partner ability next page */
+#define	ENET_TBI_MII_EXST	0x0F	/* Extended status */
+#define	ENET_TBI_MII_JD		0x10	/* Jitter diagnostics */
+#define	ENET_TBI_MII_TBICON	0x11	/* TBI control */
+
 /* UCC GETH MACCFG1 (MAC Configuration 1 Register) */
 #define MACCFG1_FLOW_RX                         0x00000020	/* Flow Control
 								   Rx */
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 68a7f54..a755bea 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -39,7 +39,6 @@
 #include <asm/types.h>
 
 #include "ucc_geth.h"
-#include "ucc_geth_mii.h"
 
 static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"tx-64-frames",
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
deleted file mode 100644
index 5463591..0000000
--- a/drivers/net/ucc_geth_mii.c
+++ /dev/null
@@ -1,295 +0,0 @@
-/*
- * drivers/net/ucc_geth_mii.c
- *
- * QE UCC Gigabit Ethernet Driver -- MII Management Bus Implementation
- * Provides Bus interface for MII Management regs in the UCC register space
- *
- * Copyright (C) 2007 Freescale Semiconductor, Inc.
- *
- * Authors: Li Yang <leoli@freescale.com>
- *	    Kim Phillips <kim.phillips@freescale.com>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-
-#include <linux/kernel.h>
-#include <linux/sched.h>
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
-#include <linux/module.h>
-#include <linux/platform_device.h>
-#include <linux/crc32.h>
-#include <linux/mii.h>
-#include <linux/phy.h>
-#include <linux/fsl_devices.h>
-#include <linux/of_platform.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
-#include <asm/ucc.h>
-
-#include "ucc_geth_mii.h"
-#include "ucc_geth.h"
-
-#define DEBUG
-#ifdef DEBUG
-#define vdbg(format, arg...) printk(KERN_DEBUG , format "\n" , ## arg)
-#else
-#define vdbg(format, arg...) do {} while(0)
-#endif
-
-#define MII_DRV_DESC "QE UCC Ethernet Controller MII Bus"
-#define MII_DRV_NAME "fsl-uec_mdio"
-
-/* Write value to the PHY for this device to the register at regnum, */
-/* waiting until the write is done before it returns.  All PHY */
-/* configuration has to be done through the master UEC MIIM regs */
-int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
-{
-	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
-
-	/* Setting up the MII Mangement Address Register */
-	out_be32(&regs->miimadd,
-		 (mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | regnum);
-
-	/* Setting up the MII Mangement Control Register with the value */
-	out_be32(&regs->miimcon, value);
-
-	/* Wait till MII management write is complete */
-	while ((in_be32(&regs->miimind)) & MIIMIND_BUSY)
-		cpu_relax();
-
-	return 0;
-}
-
-/* Reads from register regnum in the PHY for device dev, */
-/* returning the value.  Clears miimcom first.  All PHY */
-/* configuration has to be done through the TSEC1 MIIM regs */
-int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
-{
-	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
-	u16 value;
-
-	/* Setting up the MII Mangement Address Register */
-	out_be32(&regs->miimadd,
-		 (mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | regnum);
-
-	/* Clear miimcom, perform an MII management read cycle */
-	out_be32(&regs->miimcom, 0);
-	out_be32(&regs->miimcom, MIIMCOM_READ_CYCLE);
-
-	/* Wait till MII management write is complete */
-	while ((in_be32(&regs->miimind)) & (MIIMIND_BUSY | MIIMIND_NOT_VALID))
-		cpu_relax();
-
-	/* Read MII management status  */
-	value = in_be32(&regs->miimstat);
-
-	return value;
-}
-
-/* Reset the MIIM registers, and wait for the bus to free */
-static int uec_mdio_reset(struct mii_bus *bus)
-{
-	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
-	unsigned int timeout = PHY_INIT_TIMEOUT;
-
-	mutex_lock(&bus->mdio_lock);
-
-	/* Reset the management interface */
-	out_be32(&regs->miimcfg, MIIMCFG_RESET_MANAGEMENT);
-
-	/* Setup the MII Mgmt clock speed */
-	out_be32(&regs->miimcfg, MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_112);
-
-	/* Wait until the bus is free */
-	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
-		cpu_relax();
-
-	mutex_unlock(&bus->mdio_lock);
-
-	if (timeout <= 0) {
-		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
-		return -EBUSY;
-	}
-
-	return 0;
-}
-
-static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *match)
-{
-	struct device *device = &ofdev->dev;
-	struct device_node *np = ofdev->node, *tempnp = NULL;
-	struct device_node *child = NULL;
-	struct ucc_mii_mng __iomem *regs;
-	struct mii_bus *new_bus;
-	struct resource res;
-	int k, err = 0;
-
-	new_bus = mdiobus_alloc();
-	if (NULL == new_bus)
-		return -ENOMEM;
-
-	new_bus->name = "UCC Ethernet Controller MII Bus";
-	new_bus->read = &uec_mdio_read;
-	new_bus->write = &uec_mdio_write;
-	new_bus->reset = &uec_mdio_reset;
-
-	memset(&res, 0, sizeof(res));
-
-	err = of_address_to_resource(np, 0, &res);
-	if (err)
-		goto reg_map_fail;
-
-	uec_mdio_bus_name(new_bus->id, np);
-
-	new_bus->irq = kmalloc(32 * sizeof(int), GFP_KERNEL);
-
-	if (NULL == new_bus->irq) {
-		err = -ENOMEM;
-		goto reg_map_fail;
-	}
-
-	for (k = 0; k < 32; k++)
-		new_bus->irq[k] = PHY_POLL;
-
-	while ((child = of_get_next_child(np, child)) != NULL) {
-		int irq = irq_of_parse_and_map(child, 0);
-		if (irq != NO_IRQ) {
-			const u32 *id = of_get_property(child, "reg", NULL);
-			new_bus->irq[*id] = irq;
-		}
-	}
-
-	/* Set the base address */
-	regs = ioremap(res.start, sizeof(struct ucc_mii_mng));
-
-	if (NULL == regs) {
-		err = -ENOMEM;
-		goto ioremap_fail;
-	}
-
-	new_bus->priv = (void __force *)regs;
-
-	new_bus->parent = device;
-	dev_set_drvdata(device, new_bus);
-
-	/* Read MII management master from device tree */
-	while ((tempnp = of_find_compatible_node(tempnp, "network", "ucc_geth"))
-	       != NULL) {
-		struct resource tempres;
-
-		err = of_address_to_resource(tempnp, 0, &tempres);
-		if (err)
-			goto bus_register_fail;
-
-		/* if our mdio regs fall within this UCC regs range */
-		if ((res.start >= tempres.start) &&
-		    (res.end <= tempres.end)) {
-			/* set this UCC to be the MII master */
-			const u32 *id;
-
-			id = of_get_property(tempnp, "cell-index", NULL);
-			if (!id) {
-				id = of_get_property(tempnp, "device-id", NULL);
-				if (!id)
-					goto bus_register_fail;
-			}
-
-			ucc_set_qe_mux_mii_mng(*id - 1);
-
-			/* assign the TBI an address which won't
-			 * conflict with the PHYs */
-			out_be32(&regs->utbipar, UTBIPAR_INIT_TBIPA);
-			break;
-		}
-	}
-
-	err = mdiobus_register(new_bus);
-	if (0 != err) {
-		printk(KERN_ERR "%s: Cannot register as MDIO bus\n",
-		       new_bus->name);
-		goto bus_register_fail;
-	}
-
-	return 0;
-
-bus_register_fail:
-	iounmap(regs);
-ioremap_fail:
-	kfree(new_bus->irq);
-reg_map_fail:
-	mdiobus_free(new_bus);
-
-	return err;
-}
-
-static int uec_mdio_remove(struct of_device *ofdev)
-{
-	struct device *device = &ofdev->dev;
-	struct mii_bus *bus = dev_get_drvdata(device);
-
-	mdiobus_unregister(bus);
-
-	dev_set_drvdata(device, NULL);
-
-	iounmap((void __iomem *)bus->priv);
-	bus->priv = NULL;
-	mdiobus_free(bus);
-
-	return 0;
-}
-
-static struct of_device_id uec_mdio_match[] = {
-	{
-		.type = "mdio",
-		.compatible = "ucc_geth_phy",
-	},
-	{
-		.compatible = "fsl,ucc-mdio",
-	},
-	{},
-};
-
-static struct of_platform_driver uec_mdio_driver = {
-	.name	= MII_DRV_NAME,
-	.probe	= uec_mdio_probe,
-	.remove	= uec_mdio_remove,
-	.match_table	= uec_mdio_match,
-};
-
-int __init uec_mdio_init(void)
-{
-	return of_register_platform_driver(&uec_mdio_driver);
-}
-
-/* called from __init ucc_geth_init, therefore can not be __exit */
-void uec_mdio_exit(void)
-{
-	of_unregister_platform_driver(&uec_mdio_driver);
-}
-
-void uec_mdio_bus_name(char *name, struct device_node *np)
-{
-        const u32 *reg;
-
-        reg = of_get_property(np, "reg", NULL);
-
-        snprintf(name, MII_BUS_ID_SIZE, "%s@%x", np->name, reg ? *reg : 0);
-}
-
diff --git a/drivers/net/ucc_geth_mii.h b/drivers/net/ucc_geth_mii.h
deleted file mode 100644
index 840cf80..0000000
--- a/drivers/net/ucc_geth_mii.h
+++ /dev/null
@@ -1,101 +0,0 @@
-/*
- * drivers/net/ucc_geth_mii.h
- *
- * QE UCC Gigabit Ethernet Driver -- MII Management Bus Implementation
- * Provides Bus interface for MII Management regs in the UCC register space
- *
- * Copyright (C) 2007 Freescale Semiconductor, Inc.
- *
- * Authors: Li Yang <leoli@freescale.com>
- *	    Kim Phillips <kim.phillips@freescale.com>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __UEC_MII_H
-#define __UEC_MII_H
-
-/* UCC GETH MIIMCFG (MII Management Configuration Register) */
-#define MIIMCFG_RESET_MANAGEMENT                0x80000000	/* Reset
-								   management */
-#define MIIMCFG_NO_PREAMBLE                     0x00000010	/* Preamble
-								   suppress */
-#define MIIMCFG_CLOCK_DIVIDE_SHIFT              (31 - 31)	/* clock divide
-								   << shift */
-#define MIIMCFG_CLOCK_DIVIDE_MAX                0xf	/* max clock divide */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_2    0x00000000
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_4    0x00000001
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_6    0x00000002
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_8    0x00000003
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_10   0x00000004
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_14   0x00000005
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_16   0x00000008
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_20   0x00000006
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_28   0x00000007
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_32   0x00000009
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_48   0x0000000a
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_64   0x0000000b
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_80   0x0000000c
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_112  0x0000000d
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_160  0x0000000e
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_224  0x0000000f
-
-/* UCC GETH MIIMCOM (MII Management Command Register) */
-#define MIIMCOM_SCAN_CYCLE                      0x00000002	/* Scan cycle */
-#define MIIMCOM_READ_CYCLE                      0x00000001	/* Read cycle */
-
-/* UCC GETH MIIMADD (MII Management Address Register) */
-#define MIIMADD_PHY_ADDRESS_SHIFT               (31 - 23)	/* PHY Address
-								   << shift */
-#define MIIMADD_PHY_REGISTER_SHIFT              (31 - 31)	/* PHY Register
-								   << shift */
-
-/* UCC GETH MIIMCON (MII Management Control Register) */
-#define MIIMCON_PHY_CONTROL_SHIFT               (31 - 31)	/* PHY Control
-								   << shift */
-#define MIIMCON_PHY_STATUS_SHIFT                (31 - 31)	/* PHY Status
-								   << shift */
-
-/* UCC GETH MIIMIND (MII Management Indicator Register) */
-#define MIIMIND_NOT_VALID                       0x00000004	/* Not valid */
-#define MIIMIND_SCAN                            0x00000002	/* Scan in
-								   progress */
-#define MIIMIND_BUSY                            0x00000001
-
-/* Initial TBI Physical Address */
-#define UTBIPAR_INIT_TBIPA			0x1f
-
-struct ucc_mii_mng {
-	u32 miimcfg;		/* MII management configuration reg */
-	u32 miimcom;		/* MII management command reg */
-	u32 miimadd;		/* MII management address reg */
-	u32 miimcon;		/* MII management control reg */
-	u32 miimstat;		/* MII management status reg */
-	u32 miimind;		/* MII management indication reg */
-	u8 notcare[28];		/* Space holder */
-	u32 utbipar;		/* TBI phy address reg */
-} __attribute__ ((packed));
-
-/* TBI / MII Set Register */
-enum enet_tbi_mii_reg {
-	ENET_TBI_MII_CR = 0x00,	/* Control */
-	ENET_TBI_MII_SR = 0x01,	/* Status */
-	ENET_TBI_MII_ANA = 0x04,	/* AN advertisement */
-	ENET_TBI_MII_ANLPBPA = 0x05,	/* AN link partner base page ability */
-	ENET_TBI_MII_ANEX = 0x06,	/* AN expansion */
-	ENET_TBI_MII_ANNPT = 0x07,	/* AN next page transmit */
-	ENET_TBI_MII_ANLPANP = 0x08,	/* AN link partner ability next page */
-	ENET_TBI_MII_EXST = 0x0F,	/* Extended status */
-	ENET_TBI_MII_JD = 0x10,	/* Jitter diagnostics */
-	ENET_TBI_MII_TBICON = 0x11	/* TBI control */
-};
-
-int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
-int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
-int __init uec_mdio_init(void);
-void uec_mdio_exit(void);
-void uec_mdio_bus_name(char *name, struct device_node *np);
-#endif				/* __UEC_MII_H */
-- 
1.5.4.GIT

