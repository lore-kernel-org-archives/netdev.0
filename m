From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Wed, 18 Jun 2008 17:29:31 +0100
Message-ID: <1213806571.26255.1317.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <18518.37862.812419.353804@jaguar.mkp.net>
	 <1213636990.26255.822.camel@pmac.infradead.org>
	 <18519.60265.235564.200017@jaguar.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jaswinder@infradead.org
To: Jes Sorensen <jes@trained-monkey.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:35526 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbYFRQ3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:29:35 -0400
In-Reply-To: <18519.60265.235564.200017@jaguar.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-17 at 12:50 -0400, Jes Sorensen wrote:
> I'm not really biased, the card isn't in production anymore and
> there's fewer and fewer of them out there. As long as it works it's
> fine with me, but I guess I have a slight preference for staying as
> close to the original format as possible.

OK, here's the relevant part again, adjusted to handle the firmware in
its original big-endian form. As before, this is Obviously Correct=E2=84=
=A2 on
both big-endian and little-endian hosts, but hasn't been tested.

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 6c19265..167aa59 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -67,6 +67,7 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/sockios.h>
+#include <linux/firmware.h>
=20
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_vlan.h>
@@ -187,8 +188,6 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl);
 #define MAX_RODATA_LEN	8*1024
 #define MAX_DATA_LEN	2*1024
=20
-#include "acenic_firmware.h"
-
 #ifndef tigon2FwReleaseLocal
 #define tigon2FwReleaseLocal 0
 #endif
@@ -418,6 +417,10 @@ static int dis_pci_mem_inval[ACE_MAX_MOD_PARMS] =3D=
 {1, 1, 1, 1, 1, 1, 1, 1};
 MODULE_AUTHOR("Jes Sorensen <jes@trained-monkey.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AceNIC/3C985/GA620 Gigabit Ethernet driver");
+#ifndef CONFIG_ACENIC_OMIT_TIGON_I
+MODULE_FIRMWARE("acenic/tg1.bin");
+#endif
+MODULE_FIRMWARE("acenic/tg2.bin");
=20
 module_param_array_named(link, link_state, int, NULL, 0);
 module_param_array(trace, int, NULL, 0);
@@ -939,8 +942,8 @@ static int __devinit ace_init(struct net_device *de=
v)
 	case 4:
 	case 5:
 		printk(KERN_INFO "  Tigon I  (Rev. %i), Firmware: %i.%i.%i, ",
-		       tig_ver, tigonFwReleaseMajor, tigonFwReleaseMinor,
-		       tigonFwReleaseFix);
+		       tig_ver, ap->firmware_major, ap->firmware_minor,
+		       ap->firmware_fix);
 		writel(0, &regs->LocalCtrl);
 		ap->version =3D 1;
 		ap->tx_ring_entries =3D TIGON_I_TX_RING_ENTRIES;
@@ -948,8 +951,8 @@ static int __devinit ace_init(struct net_device *de=
v)
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
@@ -1201,7 +1204,9 @@ static int __devinit ace_init(struct net_device *=
dev)
 	memset(ap->info, 0, sizeof(struct ace_info));
 	memset(ap->skb, 0, sizeof(struct ace_skb));
=20
-	ace_load_firmware(dev);
+	if (ace_load_firmware(dev))
+		goto init_error;
+
 	ap->fw_running =3D 0;
=20
 	tmp_ptr =3D ap->info_dma;
@@ -1437,10 +1442,7 @@ static int __devinit ace_init(struct net_device =
*dev)
 	if (ap->version >=3D 2)
 		writel(tmp, &regs->TuneFastLink);
=20
-	if (ACE_IS_TIGON_I(ap))
-		writel(tigonFwStartAddr, &regs->Pc);
-	if (ap->version =3D=3D 2)
-		writel(tigon2FwStartAddr, &regs->Pc);
+	writel(ap->firmware_start, &regs->Pc);
=20
 	writel(0, &regs->Mb0Lo);
=20
@@ -2763,8 +2765,8 @@ static void ace_get_drvinfo(struct net_device *de=
v,
=20
 	strlcpy(info->driver, "acenic", sizeof(info->driver));
 	snprintf(info->version, sizeof(info->version), "%i.%i.%i",
-		tigonFwReleaseMajor, tigonFwReleaseMinor,
-		tigonFwReleaseFix);
+		 ap->firmware_major, ap->firmware_minor,
+		 ap->firmware_fix);
=20
 	if (ap->pdev)
 		strlcpy(info->bus_info, pci_name(ap->pdev),
@@ -2871,11 +2873,10 @@ static struct net_device_stats *ace_get_stats(s=
truct net_device *dev)
 }
=20
=20
-static void __devinit ace_copy(struct ace_regs __iomem *regs, void *sr=
c,
-			    u32 dest, int size)
+static void __devinit ace_copy(struct ace_regs __iomem *regs, const __=
be32 *src,
+			       u32 dest, int size)
 {
 	void __iomem *tdest;
-	u32 *wsrc;
 	short tsize, i;
=20
 	if (size <=3D 0)
@@ -2887,20 +2888,15 @@ static void __devinit ace_copy(struct ace_regs =
__iomem *regs, void *src,
 		tdest =3D (void __iomem *) &regs->Window +
 			(dest & (ACE_WINDOW_SIZE - 1));
 		writel(dest & ~(ACE_WINDOW_SIZE - 1), &regs->WinBase);
-		/*
-		 * This requires byte swapping on big endian, however
-		 * writel does that for us
-		 */
-		wsrc =3D src;
 		for (i =3D 0; i < (tsize / 4); i++) {
-			writel(wsrc[i], tdest + i*4);
+			/* Firmware is big-endian */
+			writel(be32_to_cpup(src), tdest);
+			src++;
+			tdest +=3D 4;
+			dest +=3D 4;
+			size -=3D 4;
 		}
-		dest +=3D tsize;
-		src +=3D tsize;
-		size -=3D tsize;
 	}
-
-	return;
 }
=20
=20
@@ -2939,8 +2935,13 @@ static void __devinit ace_clear(struct ace_regs =
__iomem *regs, u32 dest, int siz
  */
 static int __devinit ace_load_firmware(struct net_device *dev)
 {
+	const struct firmware *fw;
+	const char *fw_name =3D "acenic/tg2.bin";
 	struct ace_private *ap =3D netdev_priv(dev);
 	struct ace_regs __iomem *regs =3D ap->regs;
+	const __be32 *fw_data;
+	u32 load_addr;
+	int ret;
=20
 	if (!(readl(&regs->CpuCtrl) & CPU_HALTED)) {
 		printk(KERN_ERR "%s: trying to download firmware while the "
@@ -2948,28 +2949,52 @@ static int __devinit ace_load_firmware(struct n=
et_device *dev)
 		return -EFAULT;
 	}
=20
+	if (ACE_IS_TIGON_I(ap))
+		fw_name =3D "acenic/tg1.bin";
+
+	ret =3D request_firmware(&fw, fw_name, &ap->pdev->dev);
+	if (ret) {
+		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
+		       ap->name, fw_name);
+		return ret;
+	}
+
+	fw_data =3D (void *)fw->data;
+
+	/* Firmware blob starts with version numbers, followed by
+	   load and start address. Remainder is the blob to be loaded
+	   contiguously from load address. We don't bother to represent
+	   the BSS/SBSS sections any more, since we were clearing the
+	   whole thing anyway. */
+	ap->firmware_major =3D fw->data[0];
+	ap->firmware_minor =3D fw->data[1];
+	ap->firmware_fix =3D fw->data[2];
+
+	ap->firmware_start =3D be32_to_cpu(fw_data[1]);
+	if (ap->firmware_start < 0x4000 || ap->firmware_start >=3D 0x80000) {
+		printk(KERN_ERR "%s: bogus load address %08x in \"%s\"\n",
+		       ap->name, ap->firmware_start, fw_name);
+		ret =3D -EINVAL;
+		goto out;
+	}
+
+	load_addr =3D be32_to_cpu(fw_data[2]);
+	if (load_addr < 0x4000 || load_addr >=3D 0x80000) {
+		printk(KERN_ERR "%s: bogus load address %08x in \"%s\"\n",
+		       ap->name, load_addr, fw_name);
+		ret =3D -EINVAL;
+		goto out;
+	}
+
 	/*
-	 * Do not try to clear more than 512KB or we end up seeing
-	 * funny things on NICs with only 512KB SRAM
+	 * Do not try to clear more than 512KiB or we end up seeing
+	 * funny things on NICs with only 512KiB SRAM
 	 */
 	ace_clear(regs, 0x2000, 0x80000-0x2000);
-	if (ACE_IS_TIGON_I(ap)) {
-		ace_copy(regs, tigonFwText, tigonFwTextAddr, tigonFwTextLen);
-		ace_copy(regs, tigonFwData, tigonFwDataAddr, tigonFwDataLen);
-		ace_copy(regs, tigonFwRodata, tigonFwRodataAddr,
-			 tigonFwRodataLen);
-		ace_clear(regs, tigonFwBssAddr, tigonFwBssLen);
-		ace_clear(regs, tigonFwSbssAddr, tigonFwSbssLen);
-	}else if (ap->version =3D=3D 2) {
-		ace_clear(regs, tigon2FwBssAddr, tigon2FwBssLen);
-		ace_clear(regs, tigon2FwSbssAddr, tigon2FwSbssLen);
-		ace_copy(regs, tigon2FwText, tigon2FwTextAddr,tigon2FwTextLen);
-		ace_copy(regs, tigon2FwRodata, tigon2FwRodataAddr,
-			 tigon2FwRodataLen);
-		ace_copy(regs, tigon2FwData, tigon2FwDataAddr,tigon2FwDataLen);
-	}
-
-	return 0;
+	ace_copy(regs, &fw_data[3], load_addr, fw->size-12);
+ out:
+	release_firmware(fw);
+	return ret;
 }
=20
=20
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 60ed183..cf7e80e 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -695,6 +695,10 @@ struct ace_private
 #endif
 	struct net_device_stats stats;
 	int			pci_using_dac;
+	u8			firmware_major;
+	u8			firmware_minor;
+	u8			firmware_fix;
+	u32			firmware_start;
 };
=20
=20

--=20
dwmw2

