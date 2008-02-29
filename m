From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] ssb: Add Gigabit Ethernet driver
Date: Fri, 29 Feb 2008 11:36:12 +0100
Message-ID: <200802291136.12415.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:48733 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757593AbYB2Kn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 05:43:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the Gigabit Ethernet driver for the SSB
Gigabit Ethernet core. This driver actually is a frontend to
the Tigon3 driver. So the real work is done by tg3.
This device is used in the Linksys WRT350N.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

For 2.6.26


Index: wireless-testing/drivers/ssb/Kconfig
===================================================================
--- wireless-testing.orig/drivers/ssb/Kconfig	2008-02-29 11:14:27.000000000 +0100
+++ wireless-testing/drivers/ssb/Kconfig	2008-02-29 11:19:31.000000000 +0100
@@ -125,4 +125,13 @@ config SSB_DRIVER_EXTIF
 
 	  If unsure, say N
 
+config SSB_DRIVER_GIGE
+	bool "SSB Broadcom Gigabit Ethernet driver"
+	depends on SSB_PCIHOST_POSSIBLE && SSB_EMBEDDED && MIPS
+	help
+	  Driver for the Sonics Silicon Backplane attached
+	  Broadcom Gigabit Ethernet.
+
+	  If unsure, say N
+
 endmenu
Index: wireless-testing/drivers/ssb/Makefile
===================================================================
--- wireless-testing.orig/drivers/ssb/Makefile	2008-02-29 11:14:27.000000000 +0100
+++ wireless-testing/drivers/ssb/Makefile	2008-02-29 11:19:31.000000000 +0100
@@ -11,6 +11,7 @@ ssb-y					+= driver_chipcommon.o
 ssb-$(CONFIG_SSB_DRIVER_MIPS)		+= driver_mipscore.o
 ssb-$(CONFIG_SSB_DRIVER_EXTIF)		+= driver_extif.o
 ssb-$(CONFIG_SSB_DRIVER_PCICORE)	+= driver_pcicore.o
+ssb-$(CONFIG_SSB_DRIVER_GIGE)		+= driver_gige.o
 
 # b43 pci-ssb-bridge driver
 # Not strictly a part of SSB, but kept here for convenience
Index: wireless-testing/drivers/ssb/driver_gige.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-testing/drivers/ssb/driver_gige.c	2008-02-29 11:19:31.000000000 +0100
@@ -0,0 +1,294 @@
+/*
+ * Sonics Silicon Backplane
+ * Broadcom Gigabit Ethernet core driver
+ *
+ * Copyright 2008, Broadcom Corporation
+ * Copyright 2008, Michael Buesch <mb@bu3sch.de>
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#include <linux/ssb/ssb.h>
+#include <linux/ssb/ssb_driver_gige.h>
+#include <linux/pci.h>
+#include <linux/pci_regs.h>
+
+
+/*
+MODULE_DESCRIPTION("SSB Broadcom Gigabit Ethernet driver");
+MODULE_AUTHOR("Michael Buesch");
+MODULE_LICENSE("GPL");
+*/
+
+static const struct ssb_device_id ssb_gige_tbl[] = {
+	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_ETHERNET_GBIT, SSB_ANY_REV),
+	SSB_DEVTABLE_END
+};
+/* MODULE_DEVICE_TABLE(ssb, ssb_gige_tbl); */
+
+
+static inline u8 gige_read8(struct ssb_gige *dev, u16 offset)
+{
+	return ssb_read8(dev->dev, offset);
+}
+
+static inline u16 gige_read16(struct ssb_gige *dev, u16 offset)
+{
+	return ssb_read16(dev->dev, offset);
+}
+
+static inline u32 gige_read32(struct ssb_gige *dev, u16 offset)
+{
+	return ssb_read32(dev->dev, offset);
+}
+
+static inline void gige_write8(struct ssb_gige *dev,
+			       u16 offset, u8 value)
+{
+	ssb_write8(dev->dev, offset, value);
+}
+
+static inline void gige_write16(struct ssb_gige *dev,
+				u16 offset, u16 value)
+{
+	ssb_write16(dev->dev, offset, value);
+}
+
+static inline void gige_write32(struct ssb_gige *dev,
+				u16 offset, u32 value)
+{
+	ssb_write32(dev->dev, offset, value);
+}
+
+static inline
+u8 gige_pcicfg_read8(struct ssb_gige *dev, unsigned int offset)
+{
+	BUG_ON(offset >= 256);
+	return gige_read8(dev, SSB_GIGE_PCICFG + offset);
+}
+
+static inline
+u16 gige_pcicfg_read16(struct ssb_gige *dev, unsigned int offset)
+{
+	BUG_ON(offset >= 256);
+	return gige_read16(dev, SSB_GIGE_PCICFG + offset);
+}
+
+static inline
+u32 gige_pcicfg_read32(struct ssb_gige *dev, unsigned int offset)
+{
+	BUG_ON(offset >= 256);
+	return gige_read32(dev, SSB_GIGE_PCICFG + offset);
+}
+
+static inline
+void gige_pcicfg_write8(struct ssb_gige *dev,
+			unsigned int offset, u8 value)
+{
+	BUG_ON(offset >= 256);
+	gige_write8(dev, SSB_GIGE_PCICFG + offset, value);
+}
+
+static inline
+void gige_pcicfg_write16(struct ssb_gige *dev,
+			 unsigned int offset, u16 value)
+{
+	BUG_ON(offset >= 256);
+	gige_write16(dev, SSB_GIGE_PCICFG + offset, value);
+}
+
+static inline
+void gige_pcicfg_write32(struct ssb_gige *dev,
+			 unsigned int offset, u32 value)
+{
+	BUG_ON(offset >= 256);
+	gige_write32(dev, SSB_GIGE_PCICFG + offset, value);
+}
+
+static int ssb_gige_pci_read_config(struct pci_bus *bus, unsigned int devfn,
+				    int reg, int size, u32 *val)
+{
+	struct ssb_gige *dev = container_of(bus->ops, struct ssb_gige, pci_ops);
+	unsigned long flags;
+
+	if ((PCI_SLOT(devfn) > 0) || (PCI_FUNC(devfn) > 0))
+		return PCIBIOS_DEVICE_NOT_FOUND;
+	if (reg >= 256)
+		return PCIBIOS_DEVICE_NOT_FOUND;
+
+	spin_lock_irqsave(&dev->lock, flags);
+	switch (size) {
+	case 1:
+		*val = gige_pcicfg_read8(dev, reg);
+		break;
+	case 2:
+		*val = gige_pcicfg_read16(dev, reg);
+		break;
+	case 4:
+		*val = gige_pcicfg_read32(dev, reg);
+		break;
+	default:
+		WARN_ON(1);
+	}
+	spin_unlock_irqrestore(&dev->lock, flags);
+
+	return PCIBIOS_SUCCESSFUL;
+}
+
+static int ssb_gige_pci_write_config(struct pci_bus *bus, unsigned int devfn,
+				     int reg, int size, u32 val)
+{
+	struct ssb_gige *dev = container_of(bus->ops, struct ssb_gige, pci_ops);
+	unsigned long flags;
+
+	if ((PCI_SLOT(devfn) > 0) || (PCI_FUNC(devfn) > 0))
+		return PCIBIOS_DEVICE_NOT_FOUND;
+	if (reg >= 256)
+		return PCIBIOS_DEVICE_NOT_FOUND;
+
+	spin_lock_irqsave(&dev->lock, flags);
+	switch (size) {
+	case 1:
+		gige_pcicfg_write8(dev, reg, val);
+		break;
+	case 2:
+		gige_pcicfg_write16(dev, reg, val);
+		break;
+	case 4:
+		gige_pcicfg_write32(dev, reg, val);
+		break;
+	default:
+		WARN_ON(1);
+	}
+	spin_unlock_irqrestore(&dev->lock, flags);
+
+	return PCIBIOS_SUCCESSFUL;
+}
+
+static int ssb_gige_probe(struct ssb_device *sdev, const struct ssb_device_id *id)
+{
+	struct ssb_gige *dev;
+	u32 base, tmslow, tmshigh;
+
+	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return -ENOMEM;
+	dev->dev = sdev;
+
+	spin_lock_init(&dev->lock);
+	dev->pci_controller.pci_ops = &dev->pci_ops;
+	dev->pci_controller.io_resource = &dev->io_resource;
+	dev->pci_controller.mem_resource = &dev->mem_resource;
+	dev->pci_controller.io_map_base = 0x800;
+	dev->pci_ops.read = ssb_gige_pci_read_config;
+	dev->pci_ops.write = ssb_gige_pci_write_config;
+
+	dev->io_resource.name = SSB_GIGE_IO_RES_NAME;
+	dev->io_resource.start = 0x800;
+	dev->io_resource.end = 0x8FF;
+	dev->io_resource.flags = IORESOURCE_IO | IORESOURCE_PCI_FIXED;
+
+	if (!ssb_device_is_enabled(sdev))
+		ssb_device_enable(sdev, 0);
+
+	/* Setup BAR0. This is a 64k MMIO region. */
+	base = ssb_admatch_base(ssb_read32(sdev, SSB_ADMATCH1));
+	gige_pcicfg_write32(dev, PCI_BASE_ADDRESS_0, base);
+	gige_pcicfg_write32(dev, PCI_BASE_ADDRESS_1, 0);
+
+	dev->mem_resource.name = SSB_GIGE_MEM_RES_NAME;
+	dev->mem_resource.start = base;
+	dev->mem_resource.end = base + 0x10000 - 1;
+	dev->mem_resource.flags = IORESOURCE_MEM | IORESOURCE_PCI_FIXED;
+
+	/* Enable the memory region. */
+	gige_pcicfg_write16(dev, PCI_COMMAND,
+			    gige_pcicfg_read16(dev, PCI_COMMAND)
+			    | PCI_COMMAND_MEMORY);
+
+	/* Write flushing is controlled by the Flush Status Control register.
+	 * We want to flush every register write with a timeout and we want
+	 * to disable the IRQ mask while flushing to avoid concurrency.
+	 * Note that automatic write flushing does _not_ work from
+	 * an IRQ handler. The driver must flush manually by reading a register.
+	 */
+	gige_write32(dev, SSB_GIGE_SHIM_FLUSHSTAT, 0x00000068);
+
+	/* Check if we have an RGMII or GMII PHY-bus.
+	 * On RGMII do not bypass the DLLs */
+	tmslow = ssb_read32(sdev, SSB_TMSLOW);
+	tmshigh = ssb_read32(sdev, SSB_TMSHIGH);
+	if (tmshigh & SSB_GIGE_TMSHIGH_RGMII) {
+		tmslow &= ~SSB_GIGE_TMSLOW_TXBYPASS;
+		tmslow &= ~SSB_GIGE_TMSLOW_RXBYPASS;
+		dev->has_rgmii = 1;
+	} else {
+		tmslow |= SSB_GIGE_TMSLOW_TXBYPASS;
+		tmslow |= SSB_GIGE_TMSLOW_RXBYPASS;
+		dev->has_rgmii = 0;
+	}
+	tmslow |= SSB_GIGE_TMSLOW_DLLEN;
+	ssb_write32(sdev, SSB_TMSLOW, tmslow);
+
+	ssb_set_drvdata(sdev, dev);
+	register_pci_controller(&dev->pci_controller);
+
+	return 0;
+}
+
+bool pdev_is_ssb_gige_core(struct pci_dev *pdev)
+{
+	if (!pdev->resource[0].name)
+		return 0;
+	return (strcmp(pdev->resource[0].name, SSB_GIGE_MEM_RES_NAME) == 0);
+}
+EXPORT_SYMBOL(pdev_is_ssb_gige_core);
+
+int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
+				   struct pci_dev *pdev)
+{
+	struct ssb_gige *dev = ssb_get_drvdata(sdev);
+	struct resource *res;
+
+	if (pdev->bus->ops != &dev->pci_ops) {
+		/* The PCI device is not on this SSB GigE bridge device. */
+		return -ENODEV;
+	}
+
+	/* Fixup the PCI resources. */
+	res = &(pdev->resource[0]);
+	res->flags = IORESOURCE_MEM | IORESOURCE_PCI_FIXED;
+	res->name = dev->mem_resource.name;
+	res->start = dev->mem_resource.start;
+	res->end = dev->mem_resource.end;
+
+	/* Fixup interrupt lines. */
+	pdev->irq = ssb_mips_irq(sdev) + 2;
+	pci_write_config_byte(pdev, PCI_INTERRUPT_LINE, pdev->irq);
+
+	return 0;
+}
+
+int ssb_gige_map_irq(struct ssb_device *sdev,
+		     const struct pci_dev *pdev)
+{
+	struct ssb_gige *dev = ssb_get_drvdata(sdev);
+
+	if (pdev->bus->ops != &dev->pci_ops) {
+		/* The PCI device is not on this SSB GigE bridge device. */
+		return -ENODEV;
+	}
+
+	return ssb_mips_irq(sdev) + 2;
+}
+
+static struct ssb_driver ssb_gige_driver = {
+	.name		= "BCM-GigE",
+	.id_table	= ssb_gige_tbl,
+	.probe		= ssb_gige_probe,
+};
+
+int ssb_gige_init(void)
+{
+	return ssb_driver_register(&ssb_gige_driver);
+}
Index: wireless-testing/include/linux/ssb/ssb_driver_gige.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-testing/include/linux/ssb/ssb_driver_gige.h	2008-02-29 11:19:31.000000000 +0100
@@ -0,0 +1,174 @@
+#ifndef LINUX_SSB_DRIVER_GIGE_H_
+#define LINUX_SSB_DRIVER_GIGE_H_
+
+#include <linux/ssb/ssb.h>
+#include <linux/pci.h>
+#include <linux/spinlock.h>
+
+
+#ifdef CONFIG_SSB_DRIVER_GIGE
+
+
+#define SSB_GIGE_PCIIO			0x0000 /* PCI I/O Registers (1024 bytes) */
+#define SSB_GIGE_RESERVED		0x0400 /* Reserved (1024 bytes) */
+#define SSB_GIGE_PCICFG			0x0800 /* PCI config space (256 bytes) */
+#define SSB_GIGE_SHIM_FLUSHSTAT		0x0C00 /* PCI to OCP: Flush status control (32bit) */
+#define SSB_GIGE_SHIM_FLUSHRDA		0x0C04 /* PCI to OCP: Flush read address (32bit) */
+#define SSB_GIGE_SHIM_FLUSHTO		0x0C08 /* PCI to OCP: Flush timeout counter (32bit) */
+#define SSB_GIGE_SHIM_BARRIER		0x0C0C /* PCI to OCP: Barrier register (32bit) */
+#define SSB_GIGE_SHIM_MAOCPSI		0x0C10 /* PCI to OCP: MaocpSI Control (32bit) */
+#define SSB_GIGE_SHIM_SIOCPMA		0x0C14 /* PCI to OCP: SiocpMa Control (32bit) */
+
+/* TM Status High flags */
+#define SSB_GIGE_TMSHIGH_RGMII		0x00010000 /* Have an RGMII PHY-bus */
+/* TM Status Low flags */
+#define SSB_GIGE_TMSLOW_TXBYPASS	0x00080000 /* TX bypass (no delay) */
+#define SSB_GIGE_TMSLOW_RXBYPASS	0x00100000 /* RX bypass (no delay) */
+#define SSB_GIGE_TMSLOW_DLLEN		0x01000000 /* Enable DLL controls */
+
+/* Boardflags (low) */
+#define SSB_GIGE_BFL_ROBOSWITCH		0x0010
+
+
+#define SSB_GIGE_MEM_RES_NAME		"SSB Broadcom 47xx GigE memory"
+#define SSB_GIGE_IO_RES_NAME		"SSB Broadcom 47xx GigE I/O"
+
+struct ssb_gige {
+	struct ssb_device *dev;
+
+	spinlock_t lock;
+
+	/* True, if the device has an RGMII bus.
+	 * False, if the device has a GMII bus. */
+	bool has_rgmii;
+
+	/* The PCI controller device. */
+	struct pci_controller pci_controller;
+	struct pci_ops pci_ops;
+	struct resource mem_resource;
+	struct resource io_resource;
+};
+
+/* Check whether a PCI device is a SSB Gigabit Ethernet core. */
+extern bool pdev_is_ssb_gige_core(struct pci_dev *pdev);
+
+/* Convert a pci_dev pointer to a ssb_gige pointer. */
+static inline struct ssb_gige * pdev_to_ssb_gige(struct pci_dev *pdev)
+{
+	if (!pdev_is_ssb_gige_core(pdev))
+		return NULL;
+	return container_of(pdev->bus->ops, struct ssb_gige, pci_ops);
+}
+
+/* Returns whether the PHY is connected by an RGMII bus. */
+static inline bool ssb_gige_is_rgmii(struct pci_dev *pdev)
+{
+	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
+	return (dev ? dev->has_rgmii : 0);
+}
+
+/* Returns whether we have a Roboswitch. */
+static inline bool ssb_gige_have_roboswitch(struct pci_dev *pdev)
+{
+	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
+	if (dev)
+		return !!(dev->dev->bus->sprom.boardflags_lo &
+			  SSB_GIGE_BFL_ROBOSWITCH);
+	return 0;
+}
+
+/* Returns whether we can only do one DMA at once. */
+static inline bool ssb_gige_one_dma_at_once(struct pci_dev *pdev)
+{
+	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
+	if (dev)
+		return ((dev->dev->bus->chip_id == 0x4785) &&
+			(dev->dev->bus->chip_rev < 2));
+	return 0;
+}
+
+/* Returns whether we must flush posted writes. */
+static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
+{
+	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
+	if (dev)
+		return (dev->dev->bus->chip_id == 0x4785);
+	return 0;
+}
+
+extern char * nvram_get(const char *name);
+/* Get the device MAC address */
+static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
+{
+#ifdef CONFIG_BCM947XX
+	char *res = nvram_get("et0macaddr");
+	if (res)
+		memcpy(macaddr, res, 6);
+#endif
+}
+
+extern int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
+					  struct pci_dev *pdev);
+extern int ssb_gige_map_irq(struct ssb_device *sdev,
+			    const struct pci_dev *pdev);
+
+/* The GigE driver is not a standalone module, because we don't have support
+ * for unregistering the driver. So we could not unload the module anyway. */
+extern int ssb_gige_init(void);
+static inline void ssb_gige_exit(void)
+{
+	/* Currently we can not unregister the GigE driver,
+	 * because we can not unregister the PCI bridge. */
+	BUG();
+}
+
+
+#else /* CONFIG_SSB_DRIVER_GIGE */
+/* Gigabit Ethernet driver disabled */
+
+
+static inline int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
+						 struct pci_dev *pdev)
+{
+	return -ENOSYS;
+}
+static inline int ssb_gige_map_irq(struct ssb_device *sdev,
+				   const struct pci_dev *pdev)
+{
+	return -ENOSYS;
+}
+static inline int ssb_gige_init(void)
+{
+	return 0;
+}
+static inline void ssb_gige_exit(void)
+{
+}
+
+static inline bool pdev_is_ssb_gige_core(struct pci_dev *pdev)
+{
+	return 0;
+}
+static inline struct ssb_gige * pdev_to_ssb_gige(struct pci_dev *pdev)
+{
+	return NULL;
+}
+static inline bool ssb_gige_is_rgmii(struct pci_dev *pdev)
+{
+	return 0;
+}
+static inline bool ssb_gige_have_roboswitch(struct pci_dev *pdev)
+{
+	return 0;
+}
+static inline bool ssb_gige_one_dma_at_once(struct pci_dev *pdev)
+{
+	return 0;
+}
+static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
+{
+	return 0;
+}
+
+#endif /* CONFIG_SSB_DRIVER_GIGE */
+#endif /* LINUX_SSB_DRIVER_GIGE_H_ */
Index: wireless-testing/drivers/ssb/driver_pcicore.c
===================================================================
--- wireless-testing.orig/drivers/ssb/driver_pcicore.c	2008-02-29 11:18:59.000000000 +0100
+++ wireless-testing/drivers/ssb/driver_pcicore.c	2008-02-29 11:21:48.000000000 +0100
@@ -60,77 +60,6 @@ static DEFINE_SPINLOCK(cfgspace_lock);
 /* Core to access the external PCI config space. Can only have one. */
 static struct ssb_pcicore *extpci_core;
 
-static u32 ssb_pcicore_pcibus_iobase = 0x100;
-static u32 ssb_pcicore_pcibus_membase = SSB_PCI_DMA;
-
-int pcibios_plat_dev_init(struct pci_dev *d)
-{
-	struct resource *res;
-	int pos, size;
-	u32 *base;
-
-	ssb_printk(KERN_INFO "PCI: Fixing up device %s\n",
-		   pci_name(d));
-
-	/* Fix up resource bases */
-	for (pos = 0; pos < 6; pos++) {
-		res = &d->resource[pos];
-		if (res->flags & IORESOURCE_IO)
-			base = &ssb_pcicore_pcibus_iobase;
-		else
-			base = &ssb_pcicore_pcibus_membase;
-		res->flags |= IORESOURCE_PCI_FIXED;
-		if (res->end) {
-			size = res->end - res->start + 1;
-			if (*base & (size - 1))
-				*base = (*base + size) & ~(size - 1);
-			res->start = *base;
-			res->end = res->start + size - 1;
-			*base += size;
-			pci_write_config_dword(d, PCI_BASE_ADDRESS_0 + (pos << 2), res->start);
-		}
-		/* Fix up PCI bridge BAR0 only */
-		if (d->bus->number == 0 && PCI_SLOT(d->devfn) == 0)
-			break;
-	}
-	/* Fix up interrupt lines */
-	d->irq = ssb_mips_irq(extpci_core->dev) + 2;
-	pci_write_config_byte(d, PCI_INTERRUPT_LINE, d->irq);
-
-	return 0;
-}
-
-static void __init ssb_fixup_pcibridge(struct pci_dev *dev)
-{
-	u8 lat;
-
-	if (dev->bus->number != 0 || PCI_SLOT(dev->devfn) != 0)
-		return;
-
-	ssb_printk(KERN_INFO "PCI: Fixing up bridge %s\n", pci_name(dev));
-
-	/* Enable PCI bridge bus mastering and memory space */
-	pci_set_master(dev);
-	if (pcibios_enable_device(dev, ~0) < 0) {
-		ssb_printk(KERN_ERR "PCI: SSB bridge enable failed\n");
-		return;
-	}
-
-	/* Enable PCI bridge BAR1 prefetch and burst */
-	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
-
-	/* Make sure our latency is high enough to handle the devices behind us */
-	lat = 168;
-	ssb_printk(KERN_INFO "PCI: Fixing latency timer of device %s to %u\n",
-		   pci_name(dev), lat);
-	pci_write_config_byte(dev, PCI_LATENCY_TIMER, lat);
-}
-DECLARE_PCI_FIXUP_EARLY(PCI_ANY_ID, PCI_ANY_ID, ssb_fixup_pcibridge);
-
-int __init pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin)
-{
-	return ssb_mips_irq(extpci_core->dev) + 2;
-}
 
 static u32 get_cfgspace_addr(struct ssb_pcicore *pc,
 			     unsigned int bus, unsigned int dev,
@@ -320,6 +249,95 @@ static struct pci_controller ssb_pcicore
 	.mem_offset	= 0x24000000,
 };
 
+static u32 ssb_pcicore_pcibus_iobase = 0x100;
+static u32 ssb_pcicore_pcibus_membase = SSB_PCI_DMA;
+
+/* This function is called when doing a pci_enable_device().
+ * We must first check if the device is a device on the PCI-core bridge. */
+int ssb_pcicore_plat_dev_init(struct pci_dev *d)
+{
+	struct resource *res;
+	int pos, size;
+	u32 *base;
+
+	if (d->bus->ops != &ssb_pcicore_pciops) {
+		/* This is not a device on the PCI-core bridge. */
+		return -ENODEV;
+	}
+
+	ssb_printk(KERN_INFO "PCI: Fixing up device %s\n",
+		   pci_name(d));
+
+	/* Fix up resource bases */
+	for (pos = 0; pos < 6; pos++) {
+		res = &d->resource[pos];
+		if (res->flags & IORESOURCE_IO)
+			base = &ssb_pcicore_pcibus_iobase;
+		else
+			base = &ssb_pcicore_pcibus_membase;
+		res->flags |= IORESOURCE_PCI_FIXED;
+		if (res->end) {
+			size = res->end - res->start + 1;
+			if (*base & (size - 1))
+				*base = (*base + size) & ~(size - 1);
+			res->start = *base;
+			res->end = res->start + size - 1;
+			*base += size;
+			pci_write_config_dword(d, PCI_BASE_ADDRESS_0 + (pos << 2), res->start);
+		}
+		/* Fix up PCI bridge BAR0 only */
+		if (d->bus->number == 0 && PCI_SLOT(d->devfn) == 0)
+			break;
+	}
+	/* Fix up interrupt lines */
+	d->irq = ssb_mips_irq(extpci_core->dev) + 2;
+	pci_write_config_byte(d, PCI_INTERRUPT_LINE, d->irq);
+
+	return 0;
+}
+
+/* Early PCI fixup for a device on the PCI-core bridge. */
+static void ssb_pcicore_fixup_pcibridge(struct pci_dev *dev)
+{
+	u8 lat;
+
+	if (dev->bus->ops != &ssb_pcicore_pciops) {
+		/* This is not a device on the PCI-core bridge. */
+		return;
+	}
+	if (dev->bus->number != 0 || PCI_SLOT(dev->devfn) != 0)
+		return;
+
+	ssb_printk(KERN_INFO "PCI: Fixing up bridge %s\n", pci_name(dev));
+
+	/* Enable PCI bridge bus mastering and memory space */
+	pci_set_master(dev);
+	if (pcibios_enable_device(dev, ~0) < 0) {
+		ssb_printk(KERN_ERR "PCI: SSB bridge enable failed\n");
+		return;
+	}
+
+	/* Enable PCI bridge BAR1 prefetch and burst */
+	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
+
+	/* Make sure our latency is high enough to handle the devices behind us */
+	lat = 168;
+	ssb_printk(KERN_INFO "PCI: Fixing latency timer of device %s to %u\n",
+		   pci_name(dev), lat);
+	pci_write_config_byte(dev, PCI_LATENCY_TIMER, lat);
+}
+DECLARE_PCI_FIXUP_EARLY(PCI_ANY_ID, PCI_ANY_ID, ssb_pcicore_fixup_pcibridge);
+
+/* PCI device IRQ mapping. */
+int ssb_pcicore_pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin)
+{
+	if (dev->bus->ops != &ssb_pcicore_pciops) {
+		/* This is not a device on the PCI-core bridge. */
+		return -ENODEV;
+	}
+	return ssb_mips_irq(extpci_core->dev) + 2;
+}
+
 static void ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
 {
 	u32 val;
Index: wireless-testing/drivers/ssb/embedded.c
===================================================================
--- wireless-testing.orig/drivers/ssb/embedded.c	2008-02-24 14:23:51.000000000 +0100
+++ wireless-testing/drivers/ssb/embedded.c	2008-02-29 11:19:31.000000000 +0100
@@ -10,6 +10,9 @@
 
 #include <linux/ssb/ssb.h>
 #include <linux/ssb/ssb_embedded.h>
+#include <linux/ssb/ssb_driver_pci.h>
+#include <linux/ssb/ssb_driver_gige.h>
+#include <linux/pci.h>
 
 #include "ssb_private.h"
 
@@ -130,3 +133,90 @@ u32 ssb_gpio_polarity(struct ssb_bus *bu
 	return res;
 }
 EXPORT_SYMBOL(ssb_gpio_polarity);
+
+#ifdef CONFIG_SSB_DRIVER_GIGE
+static int gige_pci_init_callback(struct ssb_bus *bus, unsigned long data)
+{
+	struct pci_dev *pdev = (struct pci_dev *)data;
+	struct ssb_device *dev;
+	unsigned int i;
+	int res;
+
+	for (i = 0; i < bus->nr_devices; i++) {
+		dev = &(bus->devices[i]);
+		if (dev->id.coreid != SSB_DEV_ETHERNET_GBIT)
+			continue;
+		if (!dev->dev ||
+		    !dev->dev->driver ||
+		    !device_is_registered(dev->dev))
+			continue;
+		res = ssb_gige_pcibios_plat_dev_init(dev, pdev);
+		if (res >= 0)
+			return res;
+	}
+
+	return -ENODEV;
+}
+#endif /* CONFIG_SSB_DRIVER_GIGE */
+
+int ssb_pcibios_plat_dev_init(struct pci_dev *dev)
+{
+	int err;
+
+	err = ssb_pcicore_plat_dev_init(dev);
+	if (!err)
+		return 0;
+#ifdef CONFIG_SSB_DRIVER_GIGE
+	err = ssb_for_each_bus_call((unsigned long)dev, gige_pci_init_callback);
+	if (err >= 0)
+		return err;
+#endif
+	/* This is not a PCI device on any SSB device. */
+
+	return -ENODEV;
+}
+
+#ifdef CONFIG_SSB_DRIVER_GIGE
+static int gige_map_irq_callback(struct ssb_bus *bus, unsigned long data)
+{
+	const struct pci_dev *pdev = (const struct pci_dev *)data;
+	struct ssb_device *dev;
+	unsigned int i;
+	int res;
+
+	for (i = 0; i < bus->nr_devices; i++) {
+		dev = &(bus->devices[i]);
+		if (dev->id.coreid != SSB_DEV_ETHERNET_GBIT)
+			continue;
+		if (!dev->dev ||
+		    !dev->dev->driver ||
+		    !device_is_registered(dev->dev))
+			continue;
+		res = ssb_gige_map_irq(dev, pdev);
+		if (res >= 0)
+			return res;
+	}
+
+	return -ENODEV;
+}
+#endif /* CONFIG_SSB_DRIVER_GIGE */
+
+int ssb_pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin)
+{
+	int res;
+
+	/* Check if this PCI device is a device on a SSB bus or device
+	 * and return the IRQ number for it. */
+
+	res = ssb_pcicore_pcibios_map_irq(dev, slot, pin);
+	if (res >= 0)
+		return res;
+#ifdef CONFIG_SSB_DRIVER_GIGE
+	res = ssb_for_each_bus_call((unsigned long)dev, gige_map_irq_callback);
+	if (res >= 0)
+		return res;
+#endif
+	/* This is not a PCI device on any SSB device. */
+
+	return -ENODEV;
+}
Index: wireless-testing/include/linux/ssb/ssb.h
===================================================================
--- wireless-testing.orig/include/linux/ssb/ssb.h	2008-02-24 14:23:51.000000000 +0100
+++ wireless-testing/include/linux/ssb/ssb.h	2008-02-29 11:19:31.000000000 +0100
@@ -422,5 +422,12 @@ extern int ssb_bus_powerup(struct ssb_bu
 extern u32 ssb_admatch_base(u32 adm);
 extern u32 ssb_admatch_size(u32 adm);
 
+/* PCI device mapping and fixup routines.
+ * Called from the architecture pcibios init code.
+ * These are only available on SSB_EMBEDDED configurations. */
+#ifdef CONFIG_SSB_EMBEDDED
+int ssb_pcibios_plat_dev_init(struct pci_dev *dev);
+int ssb_pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin);
+#endif /* CONFIG_SSB_EMBEDDED */
 
 #endif /* LINUX_SSB_H_ */
Index: wireless-testing/include/linux/ssb/ssb_driver_pci.h
===================================================================
--- wireless-testing.orig/include/linux/ssb/ssb_driver_pci.h	2008-02-24 14:23:51.000000000 +0100
+++ wireless-testing/include/linux/ssb/ssb_driver_pci.h	2008-02-29 11:19:31.000000000 +0100
@@ -1,6 +1,11 @@
 #ifndef LINUX_SSB_PCICORE_H_
 #define LINUX_SSB_PCICORE_H_
 
+#include <linux/types.h>
+
+struct pci_dev;
+
+
 #ifdef CONFIG_SSB_DRIVER_PCICORE
 
 /* PCI core registers. */
@@ -88,6 +93,9 @@ extern void ssb_pcicore_init(struct ssb_
 extern int ssb_pcicore_dev_irqvecs_enable(struct ssb_pcicore *pc,
 					  struct ssb_device *dev);
 
+int ssb_pcicore_plat_dev_init(struct pci_dev *d);
+int ssb_pcicore_pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin);
+
 
 #else /* CONFIG_SSB_DRIVER_PCICORE */
 
@@ -107,5 +115,16 @@ int ssb_pcicore_dev_irqvecs_enable(struc
 	return 0;
 }
 
+static inline
+int ssb_pcicore_plat_dev_init(struct pci_dev *d)
+{
+	return -ENODEV;
+}
+static inline
+int ssb_pcicore_pcibios_map_irq(const struct pci_dev *dev, u8 slot, u8 pin)
+{
+	return -ENODEV;
+}
+
 #endif /* CONFIG_SSB_DRIVER_PCICORE */
 #endif /* LINUX_SSB_PCICORE_H_ */
Index: wireless-testing/drivers/ssb/main.c
===================================================================
--- wireless-testing.orig/drivers/ssb/main.c	2008-02-24 14:23:51.000000000 +0100
+++ wireless-testing/drivers/ssb/main.c	2008-02-29 11:19:31.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/io.h>
 #include <linux/ssb/ssb.h>
 #include <linux/ssb/ssb_regs.h>
+#include <linux/ssb/ssb_driver_gige.h>
 #include <linux/dma-mapping.h>
 #include <linux/pci.h>
 
@@ -68,6 +69,25 @@ found:
 }
 #endif /* CONFIG_SSB_PCIHOST */
 
+int ssb_for_each_bus_call(unsigned long data,
+			  int (*func)(struct ssb_bus *bus, unsigned long data))
+{
+	struct ssb_bus *bus;
+	int res;
+
+	ssb_buses_lock();
+	list_for_each_entry(bus, &buses, list) {
+		res = func(bus, data);
+		if (res >= 0) {
+			ssb_buses_unlock();
+			return res;
+		}
+	}
+	ssb_buses_unlock();
+
+	return -ENODEV;
+}
+
 static struct ssb_device *ssb_device_get(struct ssb_device *dev)
 {
 	if (dev)
@@ -1171,7 +1191,14 @@ static int __init ssb_modinit(void)
 	err = b43_pci_ssb_bridge_init();
 	if (err) {
 		ssb_printk(KERN_ERR "Broadcom 43xx PCI-SSB-bridge "
-			   "initialization failed");
+			   "initialization failed\n");
+		/* don't fail SSB init because of this */
+		err = 0;
+	}
+	err = ssb_gige_init();
+	if (err) {
+		ssb_printk(KERN_ERR "SSB Broadcom Gigabit Ethernet "
+			   "driver initialization failed\n");
 		/* don't fail SSB init because of this */
 		err = 0;
 	}
@@ -1185,6 +1212,7 @@ fs_initcall(ssb_modinit);
 
 static void __exit ssb_modexit(void)
 {
+	ssb_gige_exit();
 	b43_pci_ssb_bridge_exit();
 	bus_unregister(&ssb_bustype);
 }
Index: wireless-testing/drivers/ssb/ssb_private.h
===================================================================
--- wireless-testing.orig/drivers/ssb/ssb_private.h	2008-02-29 11:14:27.000000000 +0100
+++ wireless-testing/drivers/ssb/ssb_private.h	2008-02-29 11:19:31.000000000 +0100
@@ -118,6 +118,8 @@ extern u32 ssb_calc_clock_rate(u32 pllty
 extern int ssb_devices_freeze(struct ssb_bus *bus);
 extern int ssb_devices_thaw(struct ssb_bus *bus);
 extern struct ssb_bus *ssb_pci_dev_to_bus(struct pci_dev *pdev);
+int ssb_for_each_bus_call(unsigned long data,
+			  int (*func)(struct ssb_bus *bus, unsigned long data));
 
 /* b43_pci_bridge.c */
 #ifdef CONFIG_SSB_B43_PCI_BRIDGE
Index: wireless-testing/drivers/ssb/driver_mipscore.c
===================================================================
--- wireless-testing.orig/drivers/ssb/driver_mipscore.c	2008-02-19 13:20:45.000000000 +0100
+++ wireless-testing/drivers/ssb/driver_mipscore.c	2008-02-29 11:19:31.000000000 +0100
@@ -209,6 +209,7 @@ void ssb_mipscore_init(struct ssb_mipsco
 			/* fallthrough */
 		case SSB_DEV_PCI:
 		case SSB_DEV_ETHERNET:
+		case SSB_DEV_ETHERNET_GBIT:
 		case SSB_DEV_80211:
 		case SSB_DEV_USB20_HOST:
 			/* These devices get their own IRQ line if available, the rest goes on IRQ0 */


-- 
Greetings Michael.
