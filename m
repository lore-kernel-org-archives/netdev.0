From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Wed, 18 Jun 2008 17:43:59 +0100
Message-ID: <1213807439.26255.1327.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <4856CE43.4020706@garzik.org>
	 <1213652749.26255.842.camel@pmac.infradead.org>
	 <4856E50C.5050908@garzik.org>
	 <1213699220.26255.977.camel@pmac.infradead.org>
	 <1213805681.26255.1312.camel@pmac.infradead.org>
	 <4859371F.8090404@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45851 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbYFRQoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:44:04 -0400
In-Reply-To: <4859371F.8090404@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-18 at 12:26 -0400, Jeff Garzik wrote:
> So, if you get an unhappy review, the reviewer must do your work for 
> you?  That doesn't work for university students, and that doesn't fly here.
> 
> We are in the part of the Linux kernel coding process called 'taking 
> feedback'.

I've taken your feedback.
I've considered it.
I've observed that it matches some of the thoughts I originally had.
And I've explained why I think you're wrong.

> The onus is on YOU to make your work friendly to both users and developers.

Indeed so. And by doing it the way we're doing it, I believe I _am_
making it friendly to both users and developers. In the patch I just
sent, you can see exactly what's changing. Now, just for fun, let's try
splitting it into two pointlessly separate patches as you seem to want.

First we add the 'new' code path...

--- drivers/net/acenic.c	2008-03-21 19:35:32.000000000 +0000
+++ drivers/net/acenic.c	2008-06-18 17:40:10.000000000 +0100
@@ -67,6 +67,7 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/sockios.h>
+#include <linux/firmware.h>
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_vlan.h>
@@ -187,8 +188,6 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl)
 #define MAX_RODATA_LEN	8*1024
 #define MAX_DATA_LEN	2*1024
 
-#include "acenic_firmware.h"
-
 #ifndef tigon2FwReleaseLocal
 #define tigon2FwReleaseLocal 0
 #endif
@@ -418,6 +417,10 @@ static int dis_pci_mem_inval[ACE_MAX_MOD
 MODULE_AUTHOR("Jes Sorensen <jes@trained-monkey.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AceNIC/3C985/GA620 Gigabit Ethernet driver");
+#ifndef CONFIG_ACENIC_OMIT_TIGON_I
+MODULE_FIRMWARE("acenic/tg1.bin");
+#endif
+MODULE_FIRMWARE("acenic/tg2.bin");
 
 module_param_array_named(link, link_state, int, NULL, 0);
 module_param_array(trace, int, NULL, 0);
@@ -939,8 +942,8 @@ static int __devinit ace_init(struct net
 	case 4:
 	case 5:
 		printk(KERN_INFO "  Tigon I  (Rev. %i), Firmware: %i.%i.%i, ",
-		       tig_ver, tigonFwReleaseMajor, tigonFwReleaseMinor,
-		       tigonFwReleaseFix);
+		       tig_ver, ap->firmware_major, ap->firmware_minor,
+		       ap->firmware_fix);
 		writel(0, &regs->LocalCtrl);
 		ap->version = 1;
 		ap->tx_ring_entries = TIGON_I_TX_RING_ENTRIES;
@@ -948,8 +951,8 @@ static int __devinit ace_init(struct net
 #endif
 	case 6:
 		printk(KERN_INFO "  Tigon II (Rev. %i), Firmware: %i.%i.%i, ",
-		       tig_ver, tigon2FwReleaseMajor, tigon2FwReleaseMinor,
-		       tigon2FwReleaseFix);
+		       tig_ver, ap->firmware_major, ap->firmware_minor,
+		       ap->firmware_fix);
 		writel(readl(&regs->CpuBCtrl) | CPU_HALT, &regs->CpuBCtrl);
 		readl(&regs->CpuBCtrl);		/* PCI write posting */
 		/*
@@ -1201,7 +1204,9 @@ static int __devinit ace_init(struct net
 	memset(ap->info, 0, sizeof(struct ace_info));
 	memset(ap->skb, 0, sizeof(struct ace_skb));
 
-	ace_load_firmware(dev);
+	if (ace_load_firmware(dev))
+		goto init_error;
+
 	ap->fw_running = 0;
 
 	tmp_ptr = ap->info_dma;
@@ -1437,10 +1442,7 @@ static int __devinit ace_init(struct net
 	if (ap->version >= 2)
 		writel(tmp, &regs->TuneFastLink);
 
-	if (ACE_IS_TIGON_I(ap))
-		writel(tigonFwStartAddr, &regs->Pc);
-	if (ap->version == 2)
-		writel(tigon2FwStartAddr, &regs->Pc);
+	writel(ap->firmware_start, &regs->Pc);
 
 	writel(0, &regs->Mb0Lo);
 
@@ -2763,8 +2765,8 @@ static void ace_get_drvinfo(struct net_d
 
 	strlcpy(info->driver, "acenic", sizeof(info->driver));
 	snprintf(info->version, sizeof(info->version), "%i.%i.%i",
-		tigonFwReleaseMajor, tigonFwReleaseMinor,
-		tigonFwReleaseFix);
+		 ap->firmware_major, ap->firmware_minor,
+		 ap->firmware_fix);
 
 	if (ap->pdev)
 		strlcpy(info->bus_info, pci_name(ap->pdev),
@@ -2904,6 +2906,33 @@ static void __devinit ace_copy(struct ac
 }
 
 
+static void __devinit ace_copy_be(struct ace_regs __iomem *regs, const __be32 *src,
+			       u32 dest, int size)
+{
+	void __iomem *tdest;
+	short tsize, i;
+
+	if (size <= 0)
+		return;
+
+	while (size > 0) {
+		tsize = min_t(u32, ((~dest & (ACE_WINDOW_SIZE - 1)) + 1),
+			    min_t(u32, size, ACE_WINDOW_SIZE));
+		tdest = (void __iomem *) &regs->Window +
+			(dest & (ACE_WINDOW_SIZE - 1));
+		writel(dest & ~(ACE_WINDOW_SIZE - 1), &regs->WinBase);
+		for (i = 0; i < (tsize / 4); i++) {
+			/* Firmware is big-endian */
+			writel(be32_to_cpup(src), tdest);
+			src++;
+			tdest += 4;
+			dest += 4;
+			size -= 4;
+		}
+	}
+}
+
+
 static void __devinit ace_clear(struct ace_regs __iomem *regs, u32 dest, int size)
 {
 	void __iomem *tdest;
@@ -2930,30 +2959,27 @@ static void __devinit ace_clear(struct a
 	return;
 }
 
-
 /*
  * Download the firmware into the SRAM on the NIC
  *
  * This operation requires the NIC to be halted and is performed with
  * interrupts disabled and with the spinlock hold.
  */
-static int __devinit ace_load_firmware(struct net_device *dev)
+static int __devinit ace_load_static_firmware(struct net_device *dev)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
 
-	if (!(readl(&regs->CpuCtrl) & CPU_HALTED)) {
-		printk(KERN_ERR "%s: trying to download firmware while the "
-		       "CPU is running!\n", ap->name);
-		return -EFAULT;
-	}
-
 	/*
 	 * Do not try to clear more than 512KB or we end up seeing
 	 * funny things on NICs with only 512KB SRAM
 	 */
 	ace_clear(regs, 0x2000, 0x80000-0x2000);
 	if (ACE_IS_TIGON_I(ap)) {
+		ap->firmware_major = tigonFwReleaseMajor;
+		ap->firmware_minor = tigonFwReleaseMinor;
+		ap->firmware_fix = tigonFwReleaseFix;
+		ap->firmware_start = tigonFwStartAddr;
 		ace_copy(regs, tigonFwText, tigonFwTextAddr, tigonFwTextLen);
 		ace_copy(regs, tigonFwData, tigonFwDataAddr, tigonFwDataLen);
 		ace_copy(regs, tigonFwRodata, tigonFwRodataAddr,
@@ -2961,6 +2987,10 @@ static int __devinit ace_load_firmware(s
 		ace_clear(regs, tigonFwBssAddr, tigonFwBssLen);
 		ace_clear(regs, tigonFwSbssAddr, tigonFwSbssLen);
 	}else if (ap->version == 2) {
+		ap->firmware_major = tigon2FwReleaseMajor;
+		ap->firmware_minor = tigon2FwReleaseMinor;
+		ap->firmware_fix = tigon2FwReleaseFix;
+		ap->firmware_start = tigon2FwStartAddr;
 		ace_clear(regs, tigon2FwBssAddr, tigon2FwBssLen);
 		ace_clear(regs, tigon2FwSbssAddr, tigon2FwSbssLen);
 		ace_copy(regs, tigon2FwText, tigon2FwTextAddr,tigon2FwTextLen);
@@ -2972,6 +3002,70 @@ static int __devinit ace_load_firmware(s
 	return 0;
 }
 
+static int __devinit ace_load_firmware(struct net_device *dev)
+{
+	const struct firmware *fw;
+	const char *fw_name = "acenic/tg2.bin";
+	struct ace_private *ap = netdev_priv(dev);
+	struct ace_regs __iomem *regs = ap->regs;
+	const __be32 *fw_data;
+	u32 load_addr;
+	int ret;
+
+	if (!(readl(&regs->CpuCtrl) & CPU_HALTED)) {
+		printk(KERN_ERR "%s: trying to download firmware while the "
+		       "CPU is running!\n", ap->name);
+		return -EFAULT;
+	}
+
+	if (ACE_IS_TIGON_I(ap))
+		fw_name = "acenic/tg1.bin";
+
+	ret = request_firmware(&fw, fw_name, &ap->pdev->dev);
+	if (ret) {
+		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
+		       ap->name, fw_name);
+		return ace_load_static_firmware(dev);
+	}
+
+	fw_data = (void *)fw->data;
+
+	/* Firmware blob starts with version numbers, followed by
+	   load and start address. Remainder is the blob to be loaded
+	   contiguously from load address. We don't bother to represent
+	   the BSS/SBSS sections any more, since we were clearing the
+	   whole thing anyway. */
+	ap->firmware_major = fw->data[0];
+	ap->firmware_minor = fw->data[1];
+	ap->firmware_fix = fw->data[2];
+
+	ap->firmware_start = be32_to_cpu(fw_data[1]);
+	if (ap->firmware_start < 0x4000 || ap->firmware_start >= 0x80000) {
+		printk(KERN_ERR "%s: bogus load address %08x in \"%s\"\n",
+		       ap->name, ap->firmware_start, fw_name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	load_addr = be32_to_cpu(fw_data[2]);
+	if (load_addr < 0x4000 || load_addr >= 0x80000) {
+		printk(KERN_ERR "%s: bogus load address %08x in \"%s\"\n",
+		       ap->name, load_addr, fw_name);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/*
+	 * Do not try to clear more than 512KiB or we end up seeing
+	 * funny things on NICs with only 512KiB SRAM
+	 */
+	ace_clear(regs, 0x2000, 0x80000-0x2000);
+	ace_copy_be(regs, &fw_data[3], load_addr, fw->size-12);
+ out:
+	release_firmware(fw);
+	return ret;
+}
+
 
 /*
  * The eeprom on the AceNIC is an Atmel i2c EEPROM.


-- 
dwmw2

