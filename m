From: Michael Buesch <mb@bu3sch.de>
Subject: [patch RFC 1/3] add Sonics Silicon Backplane module
Date: Tue, 15 Aug 2006 00:15:37 +0200
Message-ID: <200608150015.38510.mb@bu3sch.de>
References: <200608150014.19661.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:10473
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965014AbWHNWXl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 18:23:41 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200608150014.19661.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/misc/Kconfig
===================================================================
--- wireless-dev.orig/drivers/misc/Kconfig	2006-08-14 15:31:50.000000000 +0200
+++ wireless-dev/drivers/misc/Kconfig	2006-08-14 22:02:07.000000000 +0200
@@ -28,5 +28,16 @@
 
 	  If unsure, say N.
 
+config SONICS_SILICON_BACKPLANE
+	tristate "Sonics Silicon Backplane support"
+	depends on PCI && EXPERIMENTAL
+	default m
+	---help---
+	  The Sonics Silicon Backplane is used in some chips such
+	  as the Broadcom 43xx and 44xx series.
+	  The Backplane ties several chip-cores together.
+
+	  If unsure, say M.
+
 endmenu
 
Index: wireless-dev/drivers/misc/Makefile
===================================================================
--- wireless-dev.orig/drivers/misc/Makefile	2006-08-14 15:31:50.000000000 +0200
+++ wireless-dev/drivers/misc/Makefile	2006-08-14 22:02:07.000000000 +0200
@@ -3,5 +3,6 @@
 #
 obj- := misc.o	# Dummy rule to force built-in.o to be made
 
-obj-$(CONFIG_IBM_ASM)	+= ibmasm/
-obj-$(CONFIG_HDPU_FEATURES)	+= hdpuftrs/
+obj-$(CONFIG_IBM_ASM)			+= ibmasm/
+obj-$(CONFIG_HDPU_FEATURES)		+= hdpuftrs/
+obj-$(CONFIG_SONICS_SILICON_BACKPLANE)	+= ssb.o
Index: wireless-dev/drivers/misc/ssb.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/drivers/misc/ssb.c	2006-08-14 23:19:34.000000000 +0200
@@ -0,0 +1,502 @@
+/*
+ * Sonics Silicon Backplane backend.
+ *
+ * Copyright (C) 2005-2006 Michael Buesch <mb@bu3sch.de>
+ * Copyright (C) 2005 Martin Langer <martin-langer@gmx.de>
+ * Copyright (C) 2005 Stefano Brivio <st3@riseup.net>
+ * Copyright (C) 2005 Danny van Dyk <kugelfang@gentoo.org>
+ * Copyright (C) 2005 Andreas Jaggi <andreas.jaggi@waterwave.ch>
+ *
+ * Derived from the Broadcom 4400 device driver.
+ * Copyright (C) 2002 David S. Miller (davem@redhat.com)
+ * Fixed by Pekka Pietikainen (pp@ee.oulu.fi)
+ * Copyright (C) 2006 Broadcom Corporation.
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#include <linux/ssb.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+
+#define SSB_DEBUG	1
+#define PFX		"ssb: "
+
+#if SSB_DEBUG
+# define dprintk(f, x...)	do { printk(f ,##x); } while (0)
+#else
+# define dprintk(f, x...)	do { /* nothing */ } while (0)
+#endif
+
+static inline int ssb_pci_read_config32(struct ssb *ssb, int offset,
+					u32 *value)
+{
+	return pci_read_config_dword(ssb->pci_dev, offset, value);
+}
+
+static inline int ssb_pci_read_config16(struct ssb *ssb, int offset,
+					u16 *value)
+{
+	return pci_read_config_word(ssb->pci_dev, offset, value);
+}
+
+static inline int ssb_pci_write_config32(struct ssb *ssb, int offset,
+					 u32 value)
+{
+	return pci_write_config_dword(ssb->pci_dev, offset, value);
+}
+
+static inline u32 ssb_read32(struct ssb *ssb, u16 offset)
+{
+	return ioread32(ssb->mmio + offset + ssb_core_offset(ssb));
+}
+
+static inline void ssb_write32(struct ssb *ssb, u16 offset,
+			       u32 value)
+{
+	iowrite32(value, ssb->mmio + offset + ssb_core_offset(ssb));
+}
+
+
+struct ssb * ssb_alloc(struct pci_dev *pci_dev,
+		       void __iomem *mmio)
+{
+	struct ssb *ssb;
+
+	ssb = kzalloc(sizeof(*ssb), GFP_KERNEL);
+	if (!ssb)
+		return NULL;
+
+	ssb->pci_dev = pci_dev;
+	ssb->mmio = mmio;
+
+	return ssb;
+}
+EXPORT_SYMBOL(ssb_alloc);
+
+void ssb_free(struct ssb *ssb)
+{
+	kfree(ssb->cores);
+	kfree(ssb);
+}
+EXPORT_SYMBOL(ssb_free);
+
+static int do_switch_core(struct ssb *ssb, u8 coreidx)
+{
+	int err;
+	int attempts = 0;
+	u32 cur_core;
+
+	while (1) {
+		err = ssb_pci_write_config32(ssb, SSB_BAR0_WIN,
+					     (coreidx * 0x1000) + 0x18000000);
+		if (unlikely(err))
+			goto error;
+		err = ssb_pci_read_config32(ssb, SSB_BAR0_WIN,
+					    &cur_core);
+		if (unlikely(err))
+			goto error;
+		cur_core = (cur_core - 0x18000000) / 0x1000;
+		if (cur_core == coreidx)
+			break;
+
+		if (unlikely(attempts++ > SSB_BAR0_MAX_RETRIES))
+			goto error;
+		udelay(10);
+	}
+#ifdef CONFIG_BCM947XX
+	ssb->current_core_offset = 0;
+	if (ssb->pci_dev->bus->number == 0)
+		ssb->current_core_offset = 0x1000 * coreidx;
+#endif /* CONFIG_BCM947XX */
+
+	return 0;
+error:
+	printk(KERN_ERR PFX "Failed to switch to core %u\n", coreidx);
+	return -ENODEV;
+}
+
+int ssb_switch_core(struct ssb *ssb,
+		    struct ssb_core *new_core)
+{
+	int err;
+
+	if (unlikely(!new_core))
+		return -EINVAL;
+	if (ssb->current_core == new_core)
+		return 0;
+	err = do_switch_core(ssb, new_core->index);
+	if (likely(!err))
+		ssb->current_core = new_core;
+
+	return err;
+}
+EXPORT_SYMBOL(ssb_switch_core);
+
+int ssb_probe_cores(struct ssb *ssb,
+		    u16 chipid_fallback,
+		    const struct ssb_nrcores_elem *nrcores_fallback,
+		    size_t nrcores_fb_size)
+{
+	struct ssb_core *core;
+	int err = -ENODEV;
+	u32 idhi;
+	u32 cc, rev;
+	u32 tmp;
+	int i;
+
+	WARN_ON(ssb->cores);
+
+	err = do_switch_core(ssb, 0);
+	if (err)
+		goto error;
+
+	idhi = ssb_read32(ssb, SSB_IDHIGH);
+	cc = (idhi & SSB_IDHIGH_CC_MASK) >> SSB_IDHIGH_CC_SHIFT;
+	rev = (idhi & SSB_IDHIGH_RC_MASK);
+
+	ssb->chipcommon_capabilities = 0;
+	ssb->nr_cores = 0;
+	if (cc == SSB_CC_CHIPCOMMON) {
+		tmp = ssb_read32(ssb, SSB_CHIPCOMMON_CHIPID);
+
+		ssb->chip_id = (tmp & SSB_CHIPCOMMON_IDMASK);
+		ssb->chip_rev = (tmp & SSB_CHIPCOMMON_REVMASK) >>
+				SSB_CHIPCOMMON_REVSHIFT;
+		ssb->chip_package = (tmp & SSB_CHIPCOMMON_PACKMASK) >>
+				    SSB_CHIPCOMMON_PACKSHIFT;
+		if (rev >= 4) {
+			ssb->nr_cores = (tmp & SSB_CHIPCOMMON_NRCORESMASK) >>
+					SSB_CHIPCOMMON_NRCORESSHIFT;
+		}
+		tmp = ssb_read32(ssb, SSB_CHIPCOMMON_CAPABILITIES);
+		ssb->chipcommon_capabilities = tmp;
+	} else {
+		u16 revtmp;
+
+		if (chipid_fallback == 0) {
+			printk(KERN_ERR PFX "No ChipCommon rev >= 4 present and "
+					    "chipid_fallback == 0\n");
+			goto error;
+		}
+		ssb->chip_id = chipid_fallback;
+		err = ssb_pci_read_config16(ssb, PCI_REVISION_ID, &revtmp);
+		if (err)
+			goto error;
+		ssb->chip_rev = revtmp;
+		ssb->chip_package = 0;
+	}
+	if (!ssb->nr_cores) {
+		const struct ssb_nrcores_elem *elem;
+
+		/* Search the fallback array. */
+		if (!nrcores_fallback) {
+			printk(KERN_ERR PFX "Could not read number of cores from "
+					    "ChipCommon and no nrcores_fallback "
+					    "available\n");
+			goto error;
+		}
+		for (i = 0; i < nrcores_fb_size; i++) {
+			elem = &(nrcores_fallback[i]);
+			if (elem->chip_id_key == ssb->chip_id) {
+				ssb->nr_cores = elem->nr_cores_value;
+				break;
+			}
+		}
+	}
+	if (!ssb->nr_cores) {
+		printk(KERN_ERR PFX "Could not determine number of cores.\n");
+		goto error;
+	}
+
+	ssb->cores = kcalloc(ssb->nr_cores, sizeof(struct ssb_core),
+			     GFP_KERNEL);
+	if (!ssb->cores)
+		goto error;
+
+	for (i = 0; i < ssb->nr_cores; i++) {
+		err == do_switch_core(ssb, i);
+		if (err)
+			goto error;
+		core = &(ssb->cores[i]);
+
+		idhi = ssb_read32(ssb, SSB_IDHIGH);
+		core->cc = (idhi & SSB_IDHIGH_CC_MASK) >> SSB_IDHIGH_CC_SHIFT;
+		core->rev = (idhi & SSB_IDHIGH_RC_MASK);
+		core->vendor = (idhi & SSB_IDHIGH_VC_MASK) >> SSB_IDHIGH_VC_SHIFT;
+		core->index = i;
+
+		dprintk(KERN_DEBUG PFX "Core %d found: "
+				       "cc %04X, rev %02X, vendor %04X\n",
+			i, core->cc, core->rev, core->vendor);
+	}
+
+	return 0;
+error:
+	printk(KERN_ERR PFX "Failed to probe cores\n");
+	return err;
+}
+EXPORT_SYMBOL(ssb_probe_cores);
+
+int ssb_core_is_enabled(struct ssb *ssb)
+{
+	u32 val;
+
+	val = ssb_read32(ssb, SSB_TMSLOW);
+	val &= SSB_TMSLOW_CLOCK | SSB_TMSLOW_RESET | SSB_TMSLOW_REJECT;
+
+	return (val == SSB_TMSLOW_CLOCK);
+}
+EXPORT_SYMBOL(ssb_core_is_enabled);
+
+void ssb_core_enable(struct ssb *ssb, u32 core_specific_flags)
+{
+	u32 val;
+
+	ssb_core_disable(ssb, core_specific_flags);
+	ssb_write32(ssb, SSB_TMSLOW,
+		    SSB_TMSLOW_RESET | SSB_TMSLOW_CLOCK |
+		    SSB_TMSLOW_FGC | core_specific_flags);
+	/* flush */
+	ssb_read32(ssb, SSB_TMSLOW);
+	udelay(1);
+
+	/* Clear SERR if set. This is a hw bug workaround. */
+	if (ssb_read32(ssb, SSB_TMSHIGH) & SSB_TMSHIGH_SERR)
+		ssb_write32(ssb, SSB_TMSHIGH, 0);
+
+	val = ssb_read32(ssb, SSB_IMSTATE);
+	if (val & (SSB_IMSTATE_IBE | SSB_IMSTATE_TO)) {
+		val &= ~(SSB_IMSTATE_IBE | SSB_IMSTATE_TO);
+		ssb_write32(ssb, SSB_IMSTATE, val);
+	}
+
+	ssb_write32(ssb, SSB_TMSLOW,
+		    SSB_TMSLOW_CLOCK | SSB_TMSLOW_FGC |
+		    core_specific_flags);
+	/* flush */
+	ssb_read32(ssb, SSB_TMSLOW);
+	udelay(1);
+
+	ssb_write32(ssb, SSB_TMSLOW, SSB_TMSLOW_CLOCK |
+		    core_specific_flags);
+	/* flush */
+	ssb_read32(ssb, SSB_TMSLOW);
+	udelay(1);
+}
+EXPORT_SYMBOL(ssb_core_enable);
+
+static int ssb_wait_bit(struct ssb *ssb, u16 reg, u32 bitmask,
+			int timeout, int set)
+{
+	int i;
+	u32 val;
+
+	for (i = 0; i < timeout; i++) {
+		val = ssb_read32(ssb, reg);
+		if (set) {
+			if (val & bitmask)
+				return 0;
+		} else {
+			if (!(val & bitmask))
+				return 0;
+		}
+		udelay(10);
+	}
+	printk(KERN_ERR PFX "Timeout waiting for bitmask %08X on "
+			    "register %04X to %s.\n",
+	       bitmask, reg, (set ? "set" : "clear"));
+
+	return -ETIMEDOUT;
+}
+
+void ssb_core_disable(struct ssb *ssb, u32 core_specific_flags)
+{
+	if (ssb_read32(ssb, SSB_TMSLOW) & SSB_TMSLOW_RESET)
+		return;
+
+	ssb_write32(ssb, SSB_TMSLOW, SSB_TMSLOW_REJECT | SSB_TMSLOW_CLOCK);
+	ssb_wait_bit(ssb, SSB_TMSLOW, SSB_TMSLOW_REJECT, 1000, 1);
+	ssb_wait_bit(ssb, SSB_TMSHIGH, SSB_TMSHIGH_BUSY, 1000, 0);
+	ssb_write32(ssb, SSB_TMSLOW,
+		    SSB_TMSLOW_FGC | SSB_TMSLOW_CLOCK |
+		    SSB_TMSLOW_REJECT | SSB_TMSLOW_RESET |
+		    core_specific_flags);
+	/* flush */
+	ssb_read32(ssb, SSB_TMSLOW);
+	udelay(1);
+
+	ssb_write32(ssb, SSB_TMSLOW,
+		    SSB_TMSLOW_REJECT | SSB_TMSLOW_RESET |
+		    core_specific_flags);
+	/* flush */
+	ssb_read32(ssb, SSB_TMSLOW);
+	udelay(1);
+}
+EXPORT_SYMBOL(ssb_core_disable);
+
+static u32 ssb_pcie_read(struct ssb *ssb, u32 address)
+{
+	ssb_write32(ssb, 0x130, address);
+	return ssb_read32(ssb, 0x134);
+}
+
+static void ssb_pcie_write(struct ssb *ssb, u32 address, u32 data)
+{
+	ssb_write32(ssb, 0x130, address);
+	ssb_write32(ssb, 0x134, data);
+}
+
+static void ssb_pcie_mdio_write(struct ssb *ssb, u8 device,
+				u8 address, u16 data)
+{
+	const u16 mdio_control = 0x128;
+	const u16 mdio_data = 0x12C;
+	u32 v;
+	int i;
+
+	v = 0x80; /* Enable Preamble Sequence */
+	v |= 0x2; /* MDIO Clock Divisor */
+	ssb_write32(ssb, mdio_control, v);
+
+	v = (1 << 30); /* Start of Transaction */
+	v |= (1 << 28); /* Write Transaction */
+	v |= (1 << 17); /* Turnaround */
+	v |= (u32)device << 22;
+	v |= (u32)address << 18;
+	v |= data;
+	ssb_write32(ssb, mdio_data, v);
+	udelay(10);
+	for (i = 0; i < 10; i++) {
+		v = ssb_read32(ssb, mdio_control);
+		if (v & 0x100 /* Trans complete */)
+			break;
+		msleep(1);
+	}
+	ssb_write32(ssb, mdio_control, 0);
+}
+
+static void ssb_broadcast_value(struct ssb *ssb,
+				u32 address, u32 data)
+{
+	/* This is for both, PCI and ChipCommon core, so be careful. */
+	ssb_write32(ssb, 0x50, address);
+	ssb_read32(ssb, 0x0); /* flush */
+	ssb_write32(ssb, 0x54, data);
+	ssb_read32(ssb, 0x0); /* flush */
+}
+
+static int ssb_pcicore_commit_settings(struct ssb *ssb,
+				       struct ssb_core *chipcommon_core)
+{
+	struct ssb_core *old_core = NULL;
+	int err;
+
+	if (chipcommon_core) {
+		old_core = ssb->current_core;
+		err = ssb_switch_core(ssb, chipcommon_core);
+		if (err)
+			goto out;
+	}
+	/* This forces an update of the cached registers. */
+	ssb_broadcast_value(ssb, 0xFD8, 0);
+	if (old_core) {
+		err = ssb_switch_core(ssb, old_core);
+		if (err)
+			goto out;
+	}
+out:
+	return err;
+}
+
+int ssb_cores_connect(struct ssb *ssb, u32 coremask)
+{
+	struct ssb_core *old_core;
+	struct ssb_core *pci_core = NULL;
+	struct ssb_core *chipcommon_core = NULL;
+	u32 backplane_flag_nr;
+	u32 value;
+	int i, err;
+
+	might_sleep();
+
+	for (i = 0; i < ssb->nr_cores; i++) {
+		if (ssb->cores[i].cc == SSB_CC_PCI ||
+		    ssb->cores[i].cc == SSB_CC_PCIE)
+			pci_core = &(ssb->cores[i]);
+		else if (ssb->cores[i].cc == SSB_CC_CHIPCOMMON)
+			chipcommon_core = &(ssb->cores[i]);
+	}
+
+	value = ssb_read32(ssb, SSB_TPSFLAG);
+	backplane_flag_nr = value & SSB_TPSFLAG_BPFLAG;
+
+	old_core = ssb->current_core;
+	err = ssb_switch_core(ssb, pci_core);
+	if (err)
+		goto out;
+	if ((pci_core->rev >= 6) || (pci_core->cc == SSB_CC_PCIE)) {
+		err = ssb_pci_read_config32(ssb, SSB_PCI_IRQMASK, &value);
+		if (err)
+			goto out_switch_back;
+		value |= coremask << 8;
+		err = ssb_pci_write_config32(ssb, SSB_PCI_IRQMASK, value);
+		if (err)
+			goto out_switch_back;
+	} else {
+		value = ssb_read32(ssb, SSB_INTVEC);
+		value |= (1 << backplane_flag_nr);
+		ssb_write32(ssb, SSB_INTVEC, value);
+	}
+	if (pci_core->cc == SSB_CC_PCI) {
+		value = ssb_read32(ssb, 0x108 /* sbtopci2 */);
+		value |= 0x4 /* prefetch */ | 0x8 /* burst */;
+		ssb_write32(ssb, 0x108, value);
+		if (pci_core->rev < 5) {
+			value = ssb_read32(ssb, SSB_IMCFGLO);
+			value &= ~SSB_IMCFGLO_SERTO;
+			value |= 2;
+			value &= ~SSB_IMCFGLO_REQTO;
+			value |= 3 << SSB_IMCFGLO_REQTO_SHIFT;
+			ssb_write32(ssb, SSB_IMCFGLO, value);
+			err = ssb_pcicore_commit_settings(ssb, chipcommon_core);
+			if (err)
+				goto out_switch_back;
+		} else if (pci_core->rev >= 11) {
+			value = ssb_read32(ssb, 0x108 /* sbtopci2 */);
+			value |= 0x20 /* Memory Read Multiple */;
+			ssb_write32(ssb, 0x108, value);
+		}
+	} else {
+		if ((pci_core->rev == 0) || (pci_core->rev == 1)) {
+			/* TLP Workaround register. */
+			value = ssb_pcie_read(ssb, 0x4);
+			value |= 0x8;
+			ssb_pcie_write(ssb, 0x4, value);
+		}
+		if (pci_core->rev == 0) {
+			const u8 serdes_rx_device = 0x1F;
+
+			ssb_pcie_mdio_write(ssb, serdes_rx_device,
+					    2 /* Timer */, 0x8128);
+			ssb_pcie_mdio_write(ssb, serdes_rx_device,
+					    6 /* CDR */, 0x0100);
+			ssb_pcie_mdio_write(ssb, serdes_rx_device,
+					    7 /* CDR BW */, 0x1466);
+		} else if (pci_core->rev == 1) {
+			/* DLLP Link Control register. */
+			value = ssb_pcie_read(ssb, 0x100);
+			value |= 0x40;
+			ssb_pcie_write(ssb, 0x100, value);
+		}
+	}
+out_switch_back:
+	err = ssb_switch_core(ssb, old_core);
+out:
+	return err;
+}
+EXPORT_SYMBOL(ssb_cores_connect);
+
+
+MODULE_DESCRIPTION("Sonics Silicon Backplane driver");
+MODULE_LICENSE("GPL");
Index: wireless-dev/include/linux/ssb.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/linux/ssb.h	2006-08-14 23:15:38.000000000 +0200
@@ -0,0 +1,309 @@
+#ifndef LINUX__SONICS_SILICON_BACKPLANE_H_
+#define LINUX__SONICS_SILICON_BACKPLANE_H_
+
+/* Sonics SiliconBackplane support routines. */
+
+#include <linux/types.h>
+
+/* SSB PCI config space registers. */
+#define SSB_PMCSR		0x44
+#define  SSB_PE			0x100
+#define	SSB_BAR0_WIN		0x80
+#define	SSB_BAR1_WIN		0x84
+#define	SSB_SPROM_CONTROL	0x88
+#define	SSB_BAR1_CONTROL	0x8c
+#define SSB_PCI_IRQS		0x90
+#define SSB_PCI_IRQMASK		0x94
+#define SSB_BACKPLANE_IRQS	0x98
+#define SSB_GPIO_IN		0xB0
+#define SSB_GPIO_OUT		0xB4
+#define SSB_GPIO_OUT_ENABLE	0xB8
+
+#define SSB_BAR0_MAX_RETRIES	50
+
+/* SSB core and host control registers. */
+#define SSB_CONTROL		0x0000
+#define SSB_ARBCONTROL		0x0010
+#define SSB_ISTAT		0x0020
+#define SSB_IMASK		0x0024
+#define SSB_MBOX		0x0028
+#define SSB_BCAST_ADDR		0x0050
+#define SSB_BCAST_DATA		0x0054
+#define SSB_PCI_TRANS_0		0x0100
+#define SSB_PCI_TRANS_1		0x0104
+#define SSB_PCI_TRANS_2		0x0108
+#define SSB_SPROM		0x0800
+
+#define SSB_PCI_MEM		0x00000000
+#define SSB_PCI_IO		0x00000001
+#define SSB_PCI_CFG0		0x00000002
+#define SSB_PCI_CFG1		0x00000003
+#define SSB_PCI_PREF		0x00000004
+#define SSB_PCI_BURST		0x00000008
+#define SSB_PCI_MASK0		0xfc000000
+#define SSB_PCI_MASK1		0xfc000000
+#define SSB_PCI_MASK2		0xc0000000
+
+/* Silicon backplane register definitions */
+#define SSB_IPSFLAG		0x0F08
+#define SSB_TPSFLAG		0x0F18
+#define  SSB_TPSFLAG_BPFLAG	0x0000003F /* Backplane flag # */
+#define  SSB_TPSFLAG_ALWAYSIRQ	0x00000040 /* IRQ is always sent on the Backplane */
+#define SSB_TMERRLOGA		0x0F48
+#define SSB_TMERRLOG		0x0F50
+#define SSB_ADMATCH3		0x0F60
+#define SSB_ADMATCH2		0x0F68
+#define SSB_ADMATCH1		0x0F70
+#define SSB_IMSTATE		0x0F90     /* SB Initiator Agent State */
+#define  SSB_IMSTATE_PC		0x0000000f /* Pipe Count */
+#define  SSB_IMSTATE_AP_MASK	0x00000030 /* Arbitration Priority */
+#define  SSB_IMSTATE_AP_BOTH	0x00000000 /* Use both timeslices and token */
+#define  SSB_IMSTATE_AP_TS	0x00000010 /* Use timeslices only */
+#define  SSB_IMSTATE_AP_TK	0x00000020 /* Use token only */
+#define  SSB_IMSTATE_AP_RSV	0x00000030 /* Reserved */
+#define  SSB_IMSTATE_IBE	0x00020000 /* In Band Error */
+#define  SSB_IMSTATE_TO		0x00040000 /* Timeout */
+#define SSB_INTVEC		0x0F94     /* SB Interrupt Mask */
+#define  SSB_INTVEC_PCI		0x00000001 /* Enable interrupts for PCI */
+#define  SSB_INTVEC_ENET0	0x00000002 /* Enable interrupts for enet 0 */
+#define  SSB_INTVEC_ILINE20	0x00000004 /* Enable interrupts for iline20 */
+#define  SSB_INTVEC_CODEC	0x00000008 /* Enable interrupts for v90 codec */
+#define  SSB_INTVEC_USB		0x00000010 /* Enable interrupts for usb */
+#define  SSB_INTVEC_EXTIF	0x00000020 /* Enable interrupts for external i/f */
+#define  SSB_INTVEC_ENET1	0x00000040 /* Enable interrupts for enet 1 */
+#define SSB_TMSLOW		0x0F98     /* SB Target State Low */
+#define  SSB_TMSLOW_RESET	0x00000001 /* Reset */
+#define  SSB_TMSLOW_REJECT	0x00000002 /* Reject */
+#define  SSB_TMSLOW_CLOCK	0x00010000 /* Clock Enable */
+#define  SSB_TMSLOW_FGC		0x00020000 /* Force Gated Clocks On */
+#define  SSB_TMSLOW_PE		0x40000000 /* Power Management Enable */
+#define  SSB_TMSLOW_BE		0x80000000 /* BIST Enable */
+#define SSB_TMSHIGH		0x0F9C     /* SB Target State High */
+#define  SSB_TMSHIGH_SERR	0x00000001 /* S-error */
+#define  SSB_TMSHIGH_INT	0x00000002 /* Interrupt */
+#define  SSB_TMSHIGH_BUSY	0x00000004 /* Busy */
+#define  SSB_TMSHIGH_GCR	0x20000000 /* Gated Clock Request */
+#define  SSB_TMSHIGH_BISTF	0x40000000 /* BIST Failed */
+#define  SSB_TMSHIGH_BISTD	0x80000000 /* BIST Done */
+#define SSB_BWA0		0x0FA0
+#define SSB_IMCFGLO		0x0FA8
+#define  SSB_IMCFGLO_SERTO	0x00000007 /* Service timeout */
+#define  SSB_IMCFGLO_REQTO	0x00000070 /* Request timeout */
+#define  SSB_IMCFGLO_REQTO_SHIFT	4
+#define  SSB_IMCFGLO_CONNID	0x00FF0000 /* Connection ID */
+#define  SSB_IMCFGLO_CONNID_SHIFT	16
+#define SSB_IMCFGHI		0x0FAC
+#define SSB_BCONFIG		0x0FC0
+#define SSB_BSTATE		0x0FC8
+#define SSB_ACTCFG		0x0FD8
+#define SSB_FLAGST		0x0FE8
+#define SSB_IDLOW		0x0FF8
+//TODO
+#define SSB_IDHIGH		0x0FFC     /* SB Identification High */
+#define  SSB_IDHIGH_RC_MASK	0x0000000f /* Revision Code */
+#define  SSB_IDHIGH_CC_MASK	0x0000fff0 /* Core Code */
+#define  SSB_IDHIGH_CC_SHIFT	4
+#define  SSB_IDHIGH_VC_MASK	0xffff0000 /* Vendor Code */
+#define  SSB_IDHIGH_VC_SHIFT	16
+
+/* Core Code values. */
+#define SSB_CC_CHIPCOMMON	0x800
+#define SSB_CC_ILINE20		0x801
+#define SSB_CC_SDRAM		0x803
+#define SSB_CC_PCI		0x804
+#define SSB_CC_MIPS		0x805
+#define SSB_CC_ETHERNET		0x806
+#define SSB_CC_V90		0x807
+#define SSB_CC_USB11_HOSTDEV	0x808
+#define SSB_CC_ADSL		0x809
+#define SSB_CC_ILINE100		0x80A
+#define SSB_CC_IPSEC		0x80B
+#define SSB_CC_PCMCIA		0x80D
+#define SSB_CC_INTERNAL_MEM	0x80E
+#define SSB_CC_MEMC_SDRAM	0x80F
+#define SSB_CC_EXTIF		0x811
+#define SSB_CC_80211		0x812
+#define SSB_CC_MIPS_3302	0x816
+#define SSB_CC_USB11_HOST	0x817
+#define SSB_CC_USB11_DEV	0x818
+#define SSB_CC_USB20_HOST	0x819
+#define SSB_CC_USB20_DEV	0x81A
+#define SSB_CC_SDIO_HOST	0x81B
+#define SSB_CC_ROBOSWITCH	0x81C
+#define SSB_CC_PARA_ATA		0x81D
+#define SSB_CC_SATA_XORDMA	0x81E
+#define SSB_CC_ETHERNET_GBIT	0x81F
+#define SSB_CC_PCIE		0x820
+#define SSB_CC_MIMO_PHY		0x821
+#define SSB_CC_SRAM_CTRLR	0x822
+#define SSB_CC_MINI_MACPHY	0x823
+#define SSB_CC_ARM_1176		0x824
+#define SSB_CC_ARM_7TDMI	0x825
+
+/* ChipCommon registers. */
+#define SSB_CHIPCOMMON_CHIPID		0x0000
+#define  SSB_CHIPCOMMON_IDMASK		0x0000FFFF
+#define  SSB_CHIPCOMMON_REVMASK		0x000F0000
+#define  SSB_CHIPCOMMON_REVSHIFT	16
+#define  SSB_CHIPCOMMON_PACKMASK	0x00F00000
+#define  SSB_CHIPCOMMON_PACKSHIFT	20
+#define  SSB_CHIPCOMMON_NRCORESMASK	0x0F000000
+#define  SSB_CHIPCOMMON_NRCORESSHIFT	24
+#define SSB_CHIPCOMMON_CAPABILITIES 	0x0004
+#define SSB_CHIPCOMMON_CORECTL		0x0008
+#define SSB_CHIPCOMMON_BIST		0x000C
+#define SSB_CHIPCOMMON_PLLONDELAY	0x00B0
+#define SSB_CHIPCOMMON_FREFSELDELAY	0x00B4
+#define SSB_CHIPCOMMON_SLOWCLKCTL	0x00B8
+#define SSB_CHIPCOMMON_SYSCLKCTL	0x00C0
+
+
+struct pci_dev;
+
+
+/**
+ * struct ssb_core - Sonics Silicon Backplane core
+ * @cc:		CoreCode ID. See SSB_CC_???
+ * @vendor:	Core vendor ID number.
+ * @rev:	Core revision code.
+ * @index:	Index in the ssb->cores array.
+ * @priv:	Private data for use by the driver.
+ * 		This is not touched by the ssb subsystem (except
+ * 		initialized to NULL in ssb_probe_cores()).
+ */
+struct ssb_core {
+	u16 cc;
+	u16 vendor;
+	u8 rev;
+	u8 index;
+
+	void *priv;
+};
+
+/**
+ * struct ssb - Sonics Silicon Backplane
+ * @chip_id:			Chip ID. Assigned by the ssb subsystem.
+ * @chip_rev:			Chip Revision. Assigned by the ssb subsystem.
+ * @chip_package:		Chip Package. Assigned by the ssb subsystem.
+ * @cores:			Array of all available cores.
+ * @nr_cores:			Arraysize of "cores".
+ * @current_core:		Pointer to the currently mapped core. Don't
+ * 				modify directly. Use ssb_switch_core().
+ *
+ * @current_core_offset:	Internal. Use ssb_core_offset().
+ * @pci_dev:			Internal.
+ * @mmio:			Internal. Pointer to the MMIO area.
+ */
+struct ssb {
+	u16 chip_id;
+	u8 chip_rev;
+	u8 chip_package;
+	u32 chipcommon_capabilities;
+
+	struct ssb_core	*cores;
+	int nr_cores;
+	struct ssb_core *current_core;
+#ifdef CONFIG_BCM947XX
+	u16 current_core_offset;
+#endif
+	struct pci_dev *pci_dev;
+	void __iomem *mmio;
+};
+
+/**
+ * ssb_core_offset - Get the MMIO corespecific offset.
+ * Add this offset to all MMIO offsets on every MMIO
+ * access on the core.
+ * @ssb:	Pointer to struct ssb.
+ */
+static inline u16 ssb_core_offset(struct ssb *ssb)
+{
+#ifdef CONFIG_BCM947XX
+	return ssb->current_core_offset;
+#else
+	return 0;
+#endif
+}
+
+/**
+ * ssb_alloc - Allocate struct ssb.
+ * This does not init hardware. May fail and return NULL.
+ * @pci_dev:	Pointer to the PCI device.
+ * @mmio:	Pointer to the MMIO area of the device.
+ */
+struct ssb * ssb_alloc(struct pci_dev *pci_dev,
+		       void __iomem *mmio);
+/** ssb_free - Free struct ssb. */
+void ssb_free(struct ssb *ssb);
+
+/**
+ * struct ssb_nrcores_elem - Array element of the
+ * "number of cores" fallback array.
+ * This array is browsed, if there is no ChipCommon rev >= 4
+ * core available.
+ * @chip_id_key:	The CHIPID key value for browsing the array.
+ * @nr_cores_value:	The number of available cores on this CHIPID.
+ */
+struct ssb_nrcores_elem {
+	u16 chip_id_key;
+	u8 nr_cores_value;
+};
+
+/**
+ * ssb_probe_cores - Search and probe all available cores.
+ * Returns 0 on success or an error code on failure.
+ * @ssb:		Pointer to struct ssb.
+ * @chipid_fallback:	Fallback CHIPID value. This is only used,
+ * 			if there is no ChipCommon to read the
+ * 			CHIPID from.
+ * @nrcores_fallback:	An array of struct ssb_nrcores_elem to determine
+ * 			the number of cores on a given CHIPID, if there
+ * 			is no ChipCommon rev >= 4.
+ * @nrcores_fb_size:	ARRAY_SIZE(nrcores_fallback)
+ */
+int ssb_probe_cores(struct ssb *ssb,
+		    u16 chipid_fallback,
+		    const struct ssb_nrcores_elem *nrcores_fallback,
+		    size_t nrcores_fb_size);
+/**
+ * ssb_switch_core - Switch the "current_core" to another
+ * one out of the ssb->cores array.
+ * Returns 0 on success or an error code on failure.
+ * @ssb:	Pointer to struct ssb.
+ * @new_core:	The new core to switch to.
+ */
+int ssb_switch_core(struct ssb *ssb,
+		    struct ssb_core *new_core);
+
+/**
+ * ssb_core_is_enabled - Check if current_core is enabled in hardware.
+ * Returns a boolean.
+ * @ssb:	Pointer to struct ssb.
+ */
+int ssb_core_is_enabled(struct ssb *ssb);
+/**
+ * ssb_core_enable - Reset and enable current_core.
+ * @ssb:	Pointer to struct ssb.
+ * @core_specific_flags:	Additional SSB_TMSLOW flags for
+ * 				this core. Pass 0 for none.
+ */
+void ssb_core_enable(struct ssb *ssb, u32 core_specific_flags);
+/**
+ * ssb_core_disable - Disable current_core.
+ * @ssb:	Pointer to struct ssb.
+ * @core_specific_flags:	Additional SSB_TMSLOW flags for
+ * 				this core. Pass 0 for none.
+ */
+void ssb_core_disable(struct ssb *ssb, u32 core_specific_flags);
+/**
+ * ssb_cores_connect - Connect I/O cores to the backplane.
+ * Cores need to be connected to the backplane in order
+ * to route interrupts, for example.
+ * This function might sleep.
+ * Returns 0 on success or an error code on failure.
+ * @ssb:	Pointer to struct ssb.
+ * @coremask:	Bitmask of cores to connect.
+ */
+int ssb_cores_connect(struct ssb *ssb, u32 coremask);
+
+#endif /* LINUX__SONICS_SILICON_BACKPLANE_H_ */


-- 
Greetings Michael.
