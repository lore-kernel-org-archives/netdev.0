From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Subject: [PATCH -net-next 2/4] firmware: convert acenic driver to
	request_firmware() -- without firmware data
Date: Tue, 30 Dec 2008 16:44:54 +0530
Message-ID: <1230635694.10603.20.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: davem@redhat.com, netdev <netdev@vger.kernel.org>, jes@sgi.com,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=EF=BB=BFacenic is having huge firmware data so mailing lists are rejec=
ting complete patch.

So I removed acenic firmware data from this patch.

and data is available in:
http://git.kernel.org/?p=3Dlinux/kernel/git/sfr/linux-next.git;a=3Dcomm=
it;h=3De39c0e190f52331b35931fbe5e34a07114d66171


Subject: [PATCH] firmware: convert acenic driver to request_firmware()

We store the firmware in its native big-endian form now, so the loop in
ace_copy() is modified to use be32_to_cpup() when writing it out.

We can forget the BSS,SBSS sections of the firmware, since we were
clearing all the device's RAM anyway. And the text,rodata,data sections
can all be loaded as a single chunk since they're contiguous (give or
take a few dozen bytes in between).

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/acenic.c          |  122 +-
 drivers/net/acenic.h          |    4 +
 drivers/net/acenic_firmware.h | 9456 ---------------------------------=
--------
 firmware/Makefile             |    7 +
 firmware/WHENCE               |   12 +
 firmware/acenic/tg1.bin.ihex  | 4573 ++++++++++++++++++++
 firmware/acenic/tg2.bin.ihex  | 4844 +++++++++++++++++++++
 7 files changed, 9516 insertions(+), 9502 deletions(-)
 delete mode 100644 drivers/net/acenic_firmware.h
 create mode 100644 firmware/acenic/tg1.bin.ihex
 create mode 100644 firmware/acenic/tg2.bin.ihex

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 517fce4..4835eee 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -66,6 +66,7 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/sockios.h>
+#include <linux/firmware.h>
=20
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_vlan.h>
@@ -95,8 +96,11 @@
 #else
 #define ACE_IS_TIGON_I(ap)	(ap->version =3D=3D 1)
 #define ACE_TX_RING_ENTRIES(ap)	ap->tx_ring_entries
+#define FIRMWARE_TG1		"acenic/tg1.bin"
 #endif
=20
+#define FIRMWARE_TG2		"acenic/tg2.bin"
+
 #ifndef PCI_VENDOR_ID_ALTEON
 #define PCI_VENDOR_ID_ALTEON		0x12ae
 #endif
@@ -186,8 +190,6 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl);
 #define MAX_RODATA_LEN	8*1024
 #define MAX_DATA_LEN	2*1024
=20
-#include "acenic_firmware.h"
-
 #ifndef tigon2FwReleaseLocal
 #define tigon2FwReleaseLocal 0
 #endif
@@ -417,6 +419,10 @@ static int dis_pci_mem_inval[ACE_MAX_MOD_PARMS] =3D=
 {1, 1, 1, 1, 1, 1, 1, 1};
 MODULE_AUTHOR("Jes Sorensen <jes@trained-monkey.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AceNIC/3C985/GA620 Gigabit Ethernet driver");
+#ifndef CONFIG_ACENIC_OMIT_TIGON_I
+MODULE_FIRMWARE(FIRMWARE_TG1);
+#endif
+MODULE_FIRMWARE(FIRMWARE_TG2);
=20
 module_param_array_named(link, link_state, int, NULL, 0);
 module_param_array(trace, int, NULL, 0);
@@ -943,8 +949,8 @@ static int __devinit ace_init(struct net_device *de=
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
@@ -952,8 +958,8 @@ static int __devinit ace_init(struct net_device *de=
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
@@ -1205,7 +1211,9 @@ static int __devinit ace_init(struct net_device *=
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
@@ -1441,10 +1449,7 @@ static int __devinit ace_init(struct net_device =
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
@@ -2761,8 +2766,8 @@ static void ace_get_drvinfo(struct net_device *de=
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
@@ -2869,11 +2874,10 @@ static struct net_device_stats *ace_get_stats(s=
truct net_device *dev)
 }
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
@@ -2885,20 +2889,15 @@ static void __devinit ace_copy(struct ace_regs =
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

@@ -2937,8 +2936,13 @@ static void __devinit ace_clear(struct ace_regs =
__iomem *regs, u32 dest, int siz
  */
 static int __devinit ace_load_firmware(struct net_device *dev)
 {
+	const struct firmware *fw;
+	const char *fw_name =3D FIRMWARE_TG2;
 	struct ace_private *ap =3D netdev_priv(dev);
 	struct ace_regs __iomem *regs =3D ap->regs;
+	const __be32 *fw_data;
+	u32 load_addr;
+	int ret;
=20
 	if (!(readl(&regs->CpuCtrl) & CPU_HALTED)) {
 		printk(KERN_ERR "%s: trying to download firmware while the "
@@ -2946,28 +2950,54 @@ static int __devinit ace_load_firmware(struct n=
et_device *dev)
 		return -EFAULT;
 	}
=20
+#ifndef CONFIG_ACENIC_OMIT_TIGON_I
+	if (ACE_IS_TIGON_I(ap))
+		fw_name =3D FIRMWARE_TG1;
+#endif
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
+	ace_copy(regs, &fw_data[3], load_addr, fw->size - 12);
+out:
+	release_firmware(fw);
+	return ret;
 }
=20

diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 4487f32..c987c9b 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -694,6 +694,10 @@ struct ace_private
 	u32			last_tx, last_std_rx, last_mini_rx;
 #endif
 	int			pci_using_dac;
+	u8			firmware_major;
+	u8			firmware_minor;
+	u8			firmware_fix;
+	u32			firmware_start;
 };
=20

diff --git a/firmware/Makefile b/firmware/Makefile
index d99000d..8a9eba2 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -20,6 +20,13 @@ fw-external-y :=3D $(subst ",,$(CONFIG_EXTRA_FIRMWAR=
E))
 # accurate. In the latter case it doesn't matter -- it'll use $(fw-shi=
pped-all).
 # But be aware that the config file might not be included at all.
=20
+ifdef CONFIG_ACENIC_OMIT_TIGON_I
+acenic-objs :=3D acenic/tg2.bin
+fw-shipped- +=3D acenic/tg1.bin
+else
+acenic-objs :=3D acenic/tg1.bin acenic/tg2.bin
+endif
+fw-shipped-$(CONFIG_ACENIC) +=3D $(acenic-objs)
 fw-shipped-$(CONFIG_ATARI_DSP56K) +=3D dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) +=3D atmsar11.fw
 fw-shipped-$(CONFIG_CASSINI) +=3D sun/cassini.bin
diff --git a/firmware/WHENCE b/firmware/WHENCE
index 040967f..e315a33 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -371,3 +371,15 @@ Licence: Unknown
 Found in hex form in kernel source.
=20
 ----------------------------------------------------------------------=
----
+
+Driver: acenic -- Alteon AceNIC Gigabit Ethernet card
+
+File: acenic/tg1.bin
+File: acenic/tg2.bin
+
+Licence: Unknown
+
+Found in hex form in kernel source, but source allegedly available at
+http://alteon.shareable.org/
+
+----------------------------------------------------------------------=
----
