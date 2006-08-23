From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 1/2] Add Sonics Silicon Backplane driver
Date: Wed, 23 Aug 2006 11:59:58 +0200
Message-ID: <200608231159.59363.mb@bu3sch.de>
References: <200608231158.06178.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
In-Reply-To: <200608231158.06178.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a Sonics Silicon Backplane driver backend
that can be used by ssb based device drivers auch as bcm43xx
and b44.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/misc/Kconfig
===================================================================
--- wireless-dev.orig/drivers/misc/Kconfig	2006-08-21 22:45:56.000000000 +0200
+++ wireless-dev/drivers/misc/Kconfig	2006-08-22 21:07:01.000000000 +0200
@@ -28,5 +28,9 @@
 
 	  If unsure, say N.
 
+config SONICS_SILICON_BACKPLANE
+	tristate
+	depends on PCI
+
 endmenu
 
Index: wireless-dev/drivers/misc/Makefile
===================================================================
--- wireless-dev.orig/drivers/misc/Makefile	2006-08-21 22:45:56.000000000 +0200
+++ wireless-dev/drivers/misc/Makefile	2006-08-21 22:47:10.000000000 +0200
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
+++ wireless-dev/drivers/misc/ssb.c	2006-08-23 10:58:06.000000000 +0200
@@ -0,0 +1,1015 @@
+/*
+ * Sonics Silicon Backplane backend.
+ *
+ * Copyright (C) 2005-2006 Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
+ * Copyright (C) 2005 Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>
+ * Copyright (C) 2005 Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
+ * Copyright (C) 2005 Danny van Dyk <kugelfang-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
+ * Copyright (C) 2005 Andreas Jaggi <andreas.jaggi-xegAWGFB9mQXXHkOk0aIfQ@public.gmane.org>
+ *
+ * Derived from the Broadcom 4400 device driver.
+ * Copyright (C) 2002 David S. Miller (davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)
+ * Fixed by Pekka Pietikainen (pp-YuCZbdju05vHOG6cAo2yLw@public.gmane.org)
+ * Copyright (C) 2006 Broadcom Corporation.
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#include <linux/ssb.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+
+
+#define SSB_DEBUG	0
+#define PFX		"ssb: "
+
+
+#if SSB_DEBUG
+# define dprintk(f, x...)	do { printk(f ,##x); } while (0)
+# define assert(expr) \
+	do {									\
+		if (unlikely(!(expr))) {					\
+		printk(KERN_ERR PFX "ASSERTION FAILED (%s) at: %s:%d:%s()\n",	\
+			#expr, __FILE__, __LINE__, __FUNCTION__);		\
+		}								\
+	} while (0)
+#else
+# define dprintk(f, x...)	do { /* nothing */ } while (0)
+# define assert(expr)		do { if (expr) { /* nothing */ } } while (0)
+#endif
+
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
+static inline u16 ssb_read16(struct ssb *ssb, u16 offset)
+{
+	return ioread16(ssb->mmio + offset + ssb_core_offset(ssb));
+}
+
+static inline void ssb_write16(struct ssb *ssb, u16 offset,
+			       u16 value)
+{
+	iowrite16(value, ssb->mmio + offset + ssb_core_offset(ssb));
+}
+
+
+static inline u8 ssb_crc8(u8 crc, u8 data)
+{
+	/* Polynomial:   x^8 + x^7 + x^6 + x^4 + x^2 + 1   */
+	static const u8 t[] = {
+		0x00, 0xF7, 0xB9, 0x4E, 0x25, 0xD2, 0x9C, 0x6B,
+		0x4A, 0xBD, 0xF3, 0x04, 0x6F, 0x98, 0xD6, 0x21,
+		0x94, 0x63, 0x2D, 0xDA, 0xB1, 0x46, 0x08, 0xFF,
+		0xDE, 0x29, 0x67, 0x90, 0xFB, 0x0C, 0x42, 0xB5,
+		0x7F, 0x88, 0xC6, 0x31, 0x5A, 0xAD, 0xE3, 0x14,
+		0x35, 0xC2, 0x8C, 0x7B, 0x10, 0xE7, 0xA9, 0x5E,
+		0xEB, 0x1C, 0x52, 0xA5, 0xCE, 0x39, 0x77, 0x80,
+		0xA1, 0x56, 0x18, 0xEF, 0x84, 0x73, 0x3D, 0xCA,
+		0xFE, 0x09, 0x47, 0xB0, 0xDB, 0x2C, 0x62, 0x95,
+		0xB4, 0x43, 0x0D, 0xFA, 0x91, 0x66, 0x28, 0xDF,
+		0x6A, 0x9D, 0xD3, 0x24, 0x4F, 0xB8, 0xF6, 0x01,
+		0x20, 0xD7, 0x99, 0x6E, 0x05, 0xF2, 0xBC, 0x4B,
+		0x81, 0x76, 0x38, 0xCF, 0xA4, 0x53, 0x1D, 0xEA,
+		0xCB, 0x3C, 0x72, 0x85, 0xEE, 0x19, 0x57, 0xA0,
+		0x15, 0xE2, 0xAC, 0x5B, 0x30, 0xC7, 0x89, 0x7E,
+		0x5F, 0xA8, 0xE6, 0x11, 0x7A, 0x8D, 0xC3, 0x34,
+		0xAB, 0x5C, 0x12, 0xE5, 0x8E, 0x79, 0x37, 0xC0,
+		0xE1, 0x16, 0x58, 0xAF, 0xC4, 0x33, 0x7D, 0x8A,
+		0x3F, 0xC8, 0x86, 0x71, 0x1A, 0xED, 0xA3, 0x54,
+		0x75, 0x82, 0xCC, 0x3B, 0x50, 0xA7, 0xE9, 0x1E,
+		0xD4, 0x23, 0x6D, 0x9A, 0xF1, 0x06, 0x48, 0xBF,
+		0x9E, 0x69, 0x27, 0xD0, 0xBB, 0x4C, 0x02, 0xF5,
+		0x40, 0xB7, 0xF9, 0x0E, 0x65, 0x92, 0xDC, 0x2B,
+		0x0A, 0xFD, 0xB3, 0x44, 0x2F, 0xD8, 0x96, 0x61,
+		0x55, 0xA2, 0xEC, 0x1B, 0x70, 0x87, 0xC9, 0x3E,
+		0x1F, 0xE8, 0xA6, 0x51, 0x3A, 0xCD, 0x83, 0x74,
+		0xC1, 0x36, 0x78, 0x8F, 0xE4, 0x13, 0x5D, 0xAA,
+		0x8B, 0x7C, 0x32, 0xC5, 0xAE, 0x59, 0x17, 0xE0,
+		0x2A, 0xDD, 0x93, 0x64, 0x0F, 0xF8, 0xB6, 0x41,
+		0x60, 0x97, 0xD9, 0x2E, 0x45, 0xB2, 0xFC, 0x0B,
+		0xBE, 0x49, 0x07, 0xF0, 0x9B, 0x6C, 0x22, 0xD5,
+		0xF4, 0x03, 0x4D, 0xBA, 0xD1, 0x26, 0x68, 0x9F,
+	};
+	return t[crc ^ data];
+}
+
+#define SPOFF(offset)	(((offset) - SSB_SPROM_BASE) / sizeof(u16))
+
+static u8 ssb_sprom_crc(const u16 *sprom)
+{
+	int word;
+	u8 crc = 0xFF;
+
+	for (word = 0; word < SSB_SPROMSIZE_WORDS - 1; word++) {
+		crc = ssb_crc8(crc, sprom[word] & 0x00FF);
+		crc = ssb_crc8(crc, (sprom[word] & 0xFF00) >> 8);
+	}
+	crc = ssb_crc8(crc, sprom[SPOFF(SSB_SPROM_REVISION)] & 0x00FF);
+	crc ^= 0xFF;
+
+	return crc;
+}
+
+static void sprom_do_read(struct ssb *ssb, u16 *sprom)
+{
+	int i;
+
+	for (i = 0; i < SSB_SPROMSIZE_WORDS; i++)
+		sprom[i] = ssb_read16(ssb, SSB_SPROM_BASE + (i * 2));
+}
+
+static int sprom_do_write(struct ssb *ssb, const u16 *sprom)
+{
+	int i, err;
+	u32 spromctl;
+
+	printk(KERN_INFO PFX "Writing SPROM. Do NOT turn off the power! Please stand by...\n");
+	err = ssb_pci_read_config32(ssb, SSB_SPROMCTL, &spromctl);
+	if (err)
+		goto err_ctlreg;
+	spromctl |= SSB_SPROMCTL_WE;
+	ssb_pci_write_config32(ssb, SSB_SPROMCTL, spromctl);
+	if (err)
+		goto err_ctlreg;
+	printk(KERN_INFO PFX "[ 0%%");
+	msleep(500);
+	for (i = 0; i < SSB_SPROMSIZE_WORDS; i++) {
+		if (i == SSB_SPROMSIZE_WORDS / 4)
+			printk("25%%");
+		else if (i == SSB_SPROMSIZE_WORDS / 2)
+			printk("50%%");
+		else if (i == (SSB_SPROMSIZE_WORDS / 4) * 3)
+			printk("75%%");
+		else if (i % 2)
+			printk(".");
+		ssb_write16(ssb, SSB_SPROM_BASE + (i * 2), sprom[i]);
+		mmiowb();
+		msleep(20);
+	}
+	err = ssb_pci_read_config32(ssb, SSB_SPROMCTL, &spromctl);
+	if (err)
+		goto err_ctlreg;
+	spromctl &= ~SSB_SPROMCTL_WE;
+	err = ssb_pci_write_config32(ssb, SSB_SPROMCTL, spromctl);
+	if (err)
+		goto err_ctlreg;
+	msleep(500);
+	printk("100%% ]\n");
+	printk(KERN_INFO PFX "SPROM written.\n");
+
+out:
+	return err;
+err_ctlreg:
+	printk(KERN_ERR PFX "Could not access SPROM control register.\n");
+	goto out;
+}
+
+static int sprom_check_crc(const u16 *sprom)
+{
+	u8 crc;
+	u8 expected_crc;
+	u16 tmp;
+
+	crc = ssb_sprom_crc(sprom);
+	tmp = sprom[SPOFF(SSB_SPROM_REVISION)] & SSB_SPROM_REVISION_CRC;
+	expected_crc = tmp >> SSB_SPROM_REVISION_CRC_SHIFT;
+	if (crc != expected_crc)
+		return -EPROTO;
+
+	return 0;
+}
+
+static void sprom_extract_r1(struct ssb_sprom_r1 *out, const u16 *in)
+{
+	int i;
+	u16 v;
+
+#define SPEX(_outvar, _offset, _mask, _shift)	\
+	out->_outvar = ((in[SPOFF(_offset)] & (_mask)) >> (_shift))
+
+	SPEX(pci_spid, SSB_SPROM1_SPID, 0xFFFF, 0);
+	SPEX(pci_svid, SSB_SPROM1_SVID, 0xFFFF, 0);
+	SPEX(pci_pid, SSB_SPROM1_PID, 0xFFFF, 0);
+	for (i = 0; i < 3; i++) {
+		v = in[SPOFF(SSB_SPROM1_IL0MAC) + i];
+		*(((u16 *)out->il0mac) + i) = cpu_to_be16(v);
+	}
+	for (i = 0; i < 3; i++) {
+		v = in[SPOFF(SSB_SPROM1_ET0MAC) + i];
+		*(((u16 *)out->et0mac) + i) = cpu_to_be16(v);
+	}
+	for (i = 0; i < 3; i++) {
+		v = in[SPOFF(SSB_SPROM1_ET1MAC) + i];
+		*(((u16 *)out->et1mac) + i) = cpu_to_be16(v);
+	}
+	SPEX(et0phyaddr, SSB_SPROM1_ETHPHY, SSB_SPROM1_ETHPHY_ET0A, 0);
+	SPEX(et1phyaddr, SSB_SPROM1_ETHPHY, SSB_SPROM1_ETHPHY_ET1A,
+	     SSB_SPROM1_ETHPHY_ET1A_SHIFT);
+	SPEX(et0mdcport, SSB_SPROM1_ETHPHY, SSB_SPROM1_ETHPHY_ET0M, 14);
+	SPEX(et1mdcport, SSB_SPROM1_ETHPHY, SSB_SPROM1_ETHPHY_ET1M, 15);
+	SPEX(board_rev, SSB_SPROM1_BINF, SSB_SPROM1_BINF_BREV, 0);
+	SPEX(country_code, SSB_SPROM1_BINF, SSB_SPROM1_BINF_CCODE,
+	     SSB_SPROM1_BINF_CCODE_SHIFT);
+	SPEX(antenna_a, SSB_SPROM1_BINF, SSB_SPROM1_BINF_ANTA,
+	     SSB_SPROM1_BINF_ANTA_SHIFT);
+	SPEX(antenna_bg, SSB_SPROM1_BINF, SSB_SPROM1_BINF_ANTBG,
+	     SSB_SPROM1_BINF_ANTBG_SHIFT);
+	SPEX(pa0b0, SSB_SPROM1_PA0B0, 0xFFFF, 0);
+	SPEX(pa0b1, SSB_SPROM1_PA0B1, 0xFFFF, 0);
+	SPEX(pa0b2, SSB_SPROM1_PA0B2, 0xFFFF, 0);
+	SPEX(pa1b0, SSB_SPROM1_PA1B0, 0xFFFF, 0);
+	SPEX(pa1b1, SSB_SPROM1_PA1B1, 0xFFFF, 0);
+	SPEX(pa1b2, SSB_SPROM1_PA1B2, 0xFFFF, 0);
+	SPEX(gpio0, SSB_SPROM1_GPIOA, SSB_SPROM1_GPIOA_P0, 0);
+	SPEX(gpio1, SSB_SPROM1_GPIOA, SSB_SPROM1_GPIOA_P1,
+	     SSB_SPROM1_GPIOA_P1_SHIFT);
+	SPEX(gpio2, SSB_SPROM1_GPIOB, SSB_SPROM1_GPIOB_P2, 0);
+	SPEX(gpio3, SSB_SPROM1_GPIOB, SSB_SPROM1_GPIOB_P3,
+	     SSB_SPROM1_GPIOB_P3_SHIFT);
+	SPEX(maxpwr_a, SSB_SPROM1_MAXPWR, SSB_SPROM1_MAXPWR_A, 0);
+	SPEX(maxpwr_bg, SSB_SPROM1_MAXPWR, SSB_SPROM1_MAXPWR_BG,
+	     SSB_SPROM1_MAXPWR_BG_SHIFT);
+	SPEX(itssi_a, SSB_SPROM1_ITSSI, SSB_SPROM1_ITSSI_A, 0);
+	SPEX(itssi_bg, SSB_SPROM1_ITSSI, SSB_SPROM1_ITSSI_BG,
+	     SSB_SPROM1_ITSSI_BG_SHIFT);
+	SPEX(boardflags_lo, SSB_SPROM1_BFLLO, 0xFFFF, 0);
+	SPEX(antenna_gain_a, SSB_SPROM1_AGAIN, SSB_SPROM1_AGAIN_A, 0);
+	SPEX(antenna_gain_bg, SSB_SPROM1_AGAIN, SSB_SPROM1_AGAIN_BG,
+	     SSB_SPROM1_AGAIN_BG_SHIFT);
+	for (i = 0; i < 4; i++) {
+		v = in[SPOFF(SSB_SPROM1_OEM) + i];
+		*(((u16 *)out->oem) + i) = cpu_to_le16(v);
+	}
+}
+
+static void sprom_extract_r2(struct ssb_sprom_r2 *out, const u16 *in)
+{
+	int i;
+	u16 v;
+
+	SPEX(boardflags_hi, SSB_SPROM2_BFLHI,  0xFFFF, 0);
+	SPEX(maxpwr_a_hi, SSB_SPROM2_MAXP_A, SSB_SPROM2_MAXP_A_HI, 0);
+	SPEX(maxpwr_a_lo, SSB_SPROM2_MAXP_A, SSB_SPROM2_MAXP_A_LO,
+	     SSB_SPROM2_MAXP_A_LO_SHIFT);
+	SPEX(pa1lob0, SSB_SPROM2_PA1LOB0, 0xFFFF, 0);
+	SPEX(pa1lob1, SSB_SPROM2_PA1LOB1, 0xFFFF, 0);
+	SPEX(pa1lob2, SSB_SPROM2_PA1LOB2, 0xFFFF, 0);
+	SPEX(pa1hib0, SSB_SPROM2_PA1HIB0, 0xFFFF, 0);
+	SPEX(pa1hib1, SSB_SPROM2_PA1HIB1, 0xFFFF, 0);
+	SPEX(pa1hib2, SSB_SPROM2_PA1HIB2, 0xFFFF, 0);
+	SPEX(ofdm_pwr_off, SSB_SPROM2_OPO, SSB_SPROM2_OPO_VALUE, 0);
+	for (i = 0; i < 4; i++) {
+		v = in[SPOFF(SSB_SPROM2_CCODE) + i];
+		*(((u16 *)out->country_str) + i) = cpu_to_le16(v);
+	}
+}
+
+static void sprom_extract_r3(struct ssb_sprom_r3 *out, const u16 *in)
+{
+	out->ofdmapo  = (in[SPOFF(SSB_SPROM3_OFDMAPO) + 0] & 0xFF00) >> 8;
+	out->ofdmapo |= (in[SPOFF(SSB_SPROM3_OFDMAPO) + 0] & 0x00FF) << 8;
+	out->ofdmapo <<= 16;
+	out->ofdmapo |= (in[SPOFF(SSB_SPROM3_OFDMAPO) + 1] & 0xFF00) >> 8;
+	out->ofdmapo |= (in[SPOFF(SSB_SPROM3_OFDMAPO) + 1] & 0x00FF) << 8;
+
+	out->ofdmalpo  = (in[SPOFF(SSB_SPROM3_OFDMALPO) + 0] & 0xFF00) >> 8;
+	out->ofdmalpo |= (in[SPOFF(SSB_SPROM3_OFDMALPO) + 0] & 0x00FF) << 8;
+	out->ofdmalpo <<= 16;
+	out->ofdmalpo |= (in[SPOFF(SSB_SPROM3_OFDMALPO) + 1] & 0xFF00) >> 8;
+	out->ofdmalpo |= (in[SPOFF(SSB_SPROM3_OFDMALPO) + 1] & 0x00FF) << 8;
+
+	out->ofdmahpo  = (in[SPOFF(SSB_SPROM3_OFDMAHPO) + 0] & 0xFF00) >> 8;
+	out->ofdmahpo |= (in[SPOFF(SSB_SPROM3_OFDMAHPO) + 0] & 0x00FF) << 8;
+	out->ofdmahpo <<= 16;
+	out->ofdmahpo |= (in[SPOFF(SSB_SPROM3_OFDMAHPO) + 1] & 0xFF00) >> 8;
+	out->ofdmahpo |= (in[SPOFF(SSB_SPROM3_OFDMAHPO) + 1] & 0x00FF) << 8;
+
+	SPEX(gpioldc_on_cnt, SSB_SPROM3_GPIOLDC, SSB_SPROM3_GPIOLDC_ON,
+	     SSB_SPROM3_GPIOLDC_ON_SHIFT);
+	SPEX(gpioldc_off_cnt, SSB_SPROM3_GPIOLDC, SSB_SPROM3_GPIOLDC_OFF,
+	     SSB_SPROM3_GPIOLDC_OFF_SHIFT);
+	SPEX(cckpo_1M, SSB_SPROM3_CCKPO, SSB_SPROM3_CCKPO_1M, 0);
+	SPEX(cckpo_2M, SSB_SPROM3_CCKPO, SSB_SPROM3_CCKPO_2M,
+	     SSB_SPROM3_CCKPO_2M_SHIFT);
+	SPEX(cckpo_55M, SSB_SPROM3_CCKPO, SSB_SPROM3_CCKPO_55M,
+	     SSB_SPROM3_CCKPO_55M_SHIFT);
+	SPEX(cckpo_11M, SSB_SPROM3_CCKPO, SSB_SPROM3_CCKPO_11M,
+	     SSB_SPROM3_CCKPO_11M_SHIFT);
+
+	out->ofdmgpo  = (in[SPOFF(SSB_SPROM3_OFDMGPO) + 0] & 0xFF00) >> 8;
+	out->ofdmgpo |= (in[SPOFF(SSB_SPROM3_OFDMGPO) + 0] & 0x00FF) << 8;
+	out->ofdmgpo <<= 16;
+	out->ofdmgpo |= (in[SPOFF(SSB_SPROM3_OFDMGPO) + 1] & 0xFF00) >> 8;
+	out->ofdmgpo |= (in[SPOFF(SSB_SPROM3_OFDMGPO) + 1] & 0x00FF) << 8;
+}
+
+static int sprom_extract(struct ssb_sprom *out, const u16 *in)
+{
+	memset(out, 0, sizeof(*out));
+
+	SPEX(revision, SSB_SPROM_REVISION, SSB_SPROM_REVISION_REV, 0);
+	SPEX(crc, SSB_SPROM_REVISION, SSB_SPROM_REVISION_CRC,
+	     SSB_SPROM_REVISION_CRC_SHIFT);
+
+	if (out->revision == 0)
+		return -EOPNOTSUPP;
+	if (out->revision >= 1 && out->revision <= 3)
+		sprom_extract_r1(&out->r1, in);
+	if (out->revision >= 2 && out->revision <= 3)
+		sprom_extract_r2(&out->r2, in);
+	if (out->revision == 3)
+		sprom_extract_r3(&out->r3, in);
+	if (out->revision >= 4)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
+int ssb_sprom_read(struct ssb *ssb, struct ssb_sprom *sprom, int force)
+{
+	int err = -ENOMEM;
+	u16 *buf;
+
+	buf = kcalloc(SSB_SPROMSIZE_WORDS, sizeof(u16), GFP_KERNEL);
+	if (!buf)
+		goto out;
+	sprom_do_read(ssb, buf);
+	err = sprom_check_crc(buf);
+	if (err) {
+		printk(KERN_ERR PFX "Invalid SPROM CRC (corrupt SPROM)\n");
+		if (!force)
+			goto out_kfree;
+	}
+	err = sprom_extract(sprom, buf);
+	if (err)
+		goto out_kfree;
+
+out_kfree:
+	kfree(buf);
+out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(ssb_sprom_read);
+
+
+static struct list_head ssb_list = LIST_HEAD_INIT(ssb_list);
+static DEFINE_MUTEX(ssb_list_mutex);
+
+static struct ssb * device_to_ssb(struct device *dev)
+{
+	struct ssb *ssb = NULL;
+
+	mutex_lock(&ssb_list_mutex);
+	list_for_each_entry(ssb, &ssb_list, list) {
+		if (&ssb->pci_dev->dev == dev)
+			break;
+	}
+	mutex_unlock(&ssb_list_mutex);
+
+	return ssb;
+}
+
+static int sprom2hex(const u16 *sprom, char *buf, size_t buf_len)
+{
+	int i, pos = 0;
+
+	for (i = 0; i < SSB_SPROMSIZE_WORDS; i++) {
+		pos += snprintf(buf + pos, buf_len - pos - 1,
+				"%04X", swab16(sprom[i]) & 0xFFFF);
+	}
+	pos += snprintf(buf + pos, buf_len - pos - 1, "\n");
+
+	return pos + 1;
+}
+
+static int hex2sprom(u16 *sprom, const char *dump, size_t len)
+{
+	char tmp[5] = { 0 };
+	int cnt = 0;
+	unsigned long parsed;
+
+	if (len < SSB_SPROMSIZE_BYTES * 2)
+		return -EINVAL;
+
+	while (cnt < SSB_SPROMSIZE_WORDS) {
+		memcpy(tmp, dump, 4);
+		dump += 4;
+		parsed = simple_strtoul(tmp, NULL, 16);
+		sprom[cnt++] = swab16((u16)parsed);
+	}
+
+	return 0;
+}
+
+static ssize_t ssb_attr_sprom_show(struct device *dev,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct ssb *ssb;
+	int err = -ENODEV;
+	ssize_t count = 0;
+	u16 *sprom;
+
+	ssb = device_to_ssb(dev);
+	if (!ssb)
+		goto out;
+	err = -ENOMEM;
+	sprom = kcalloc(SSB_SPROMSIZE_WORDS, sizeof(u16), GFP_KERNEL);
+	if (!sprom)
+		goto out;
+
+	err = -ERESTARTSYS;
+	if (mutex_lock_interruptible(&ssb->mutex))
+		goto out_kfree;
+	sprom_do_read(ssb, sprom);
+	mutex_unlock(&ssb->mutex);
+
+	count = sprom2hex(sprom, buf, PAGE_SIZE);
+	err = 0;
+
+out_kfree:
+	kfree(sprom);
+out:
+	return (err ? err : count);
+}
+
+static ssize_t ssb_attr_sprom_store(struct device *dev,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	struct ssb *ssb;
+	int err = -ENODEV;
+	u16 *sprom;
+
+	ssb = device_to_ssb(dev);
+	if (!ssb)
+		goto out;
+	err = -ENOMEM;
+	sprom = kcalloc(SSB_SPROMSIZE_WORDS, sizeof(u16), GFP_KERNEL);
+	if (!sprom)
+		goto out;
+	err = hex2sprom(sprom, buf, count);
+	if (err)
+		goto out_kfree;
+	err = sprom_check_crc(sprom);
+	if (err) {
+		err = -EINVAL;
+		goto out_kfree;
+	}
+
+	err = -ERESTARTSYS;
+	if (mutex_lock_interruptible(&ssb->suspend_mutex))
+		goto out_kfree;
+	err = ssb->device_suspend(ssb);
+	if (err)
+		goto out_unlock_susp;
+	err = -ERESTARTSYS;
+	if (mutex_lock_interruptible(&ssb->mutex))
+		goto out_unlock_susp;
+	err = sprom_do_write(ssb, sprom);
+	mutex_unlock(&ssb->mutex);
+	err = ssb->device_resume(ssb);
+	if (err)
+		goto out_unlock_susp;
+out_unlock_susp:
+	mutex_unlock(&ssb->suspend_mutex);
+out_kfree:
+	kfree(sprom);
+out:
+	return (err ? err : count);
+}
+
+static DEVICE_ATTR(ssb_sprom, 0600,
+		   ssb_attr_sprom_show,
+		   ssb_attr_sprom_store);
+
+int ssb_init(struct ssb *ssb,
+	     struct pci_dev *pci_dev,
+	     void __iomem *mmio,
+	     int (*device_suspend)(struct ssb *ssb),
+	     int (*device_resume)(struct ssb *ssb))
+{
+	int err;
+
+	if (!ssb || !pci_dev || !device_suspend || !device_resume)
+		return -EINVAL;
+
+	memset(ssb, 0, sizeof(*ssb));
+	ssb->pci_dev = pci_dev;
+	ssb->mmio = mmio;
+	ssb->device_suspend = device_suspend;
+	ssb->device_resume = device_resume;
+	mutex_init(&ssb->mutex);
+	mutex_init(&ssb->suspend_mutex);
+	INIT_LIST_HEAD(&ssb->list);
+
+	mutex_lock(&ssb_list_mutex);
+	list_add(&ssb->list, &ssb_list);
+	mutex_unlock(&ssb_list_mutex);
+
+	err = device_create_file(&pci_dev->dev, &dev_attr_ssb_sprom);
+	if (err)
+		goto out;
+
+out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(ssb_init);
+
+void ssb_exit(struct ssb *ssb)
+{
+	device_remove_file(&ssb->pci_dev->dev, &dev_attr_ssb_sprom);
+
+	mutex_lock(&ssb_list_mutex);
+	list_del(&ssb->list);
+	mutex_unlock(&ssb_list_mutex);
+
+	kfree(ssb->cores);
+	if (SSB_DEBUG)
+		memset(ssb, 0x5B, sizeof(*ssb));
+}
+EXPORT_SYMBOL_GPL(ssb_exit);
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
+		msleep(1);
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
+int ssb_switch_core_locked(struct ssb *ssb,
+			   struct ssb_core *new_core)
+{
+	int err = 0;
+
+	if (unlikely(!new_core))
+		return -EINVAL;
+	if (ssb->current_core != new_core) {
+		err = do_switch_core(ssb, new_core->index);
+		if (likely(!err))
+			ssb->current_core = new_core;
+	}
+
+	return err;
+}
+
+int ssb_switch_core(struct ssb *ssb,
+		    struct ssb_core *new_core)
+{
+	int err;
+
+	mutex_lock(&ssb->mutex);
+	err = ssb_switch_core_locked(ssb, new_core);
+	mutex_unlock(&ssb->mutex);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(ssb_switch_core);
+
+int ssb_probe_cores(struct ssb *ssb,
+		    u16 chipid_fallback,
+		    const struct ssb_nrcores_elem *nrcores_fallback,
+		    size_t nrcores_fb_size)
+{
+	struct ssb_core *core;
+	int err;
+	u32 idhi;
+	u32 cc, rev;
+	u32 tmp;
+	int i;
+
+	WARN_ON(ssb->cores);
+
+	mutex_lock(&ssb->mutex);
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
+		tmp = ssb_read32(ssb, SSB_CHIPCOMMON_CAP);
+		ssb->chipcommon_capabilities = tmp;
+	} else {
+		u16 revtmp;
+
+		if (chipid_fallback == 0) {
+			printk(KERN_ERR PFX "No ChipCommon rev >= 4 present and "
+					    "chipid_fallback == 0\n");
+			err = -EINVAL;
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
+			err = -EINVAL;
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
+		err = -ESRCH;
+		goto error;
+	}
+
+	err = -ENOMEM;
+	ssb->cores = kcalloc(ssb->nr_cores, sizeof(struct ssb_core),
+			     GFP_KERNEL);
+	if (!ssb->cores)
+		goto error;
+
+	for (i = 0; i < ssb->nr_cores; i++) {
+		err = do_switch_core(ssb, i);
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
+	err = 0;
+out_unlock:
+	mutex_unlock(&ssb->mutex);
+
+	return err;
+error:
+	printk(KERN_ERR PFX "Failed to probe cores\n");
+	goto out_unlock;
+}
+EXPORT_SYMBOL_GPL(ssb_probe_cores);
+
+int ssb_core_is_enabled(struct ssb *ssb)
+{
+	u32 val;
+
+	mutex_lock(&ssb->mutex);
+	val = ssb_read32(ssb, SSB_TMSLOW);
+	mutex_unlock(&ssb->mutex);
+	val &= SSB_TMSLOW_CLOCK | SSB_TMSLOW_RESET | SSB_TMSLOW_REJECT;
+
+	return (val == SSB_TMSLOW_CLOCK);
+}
+EXPORT_SYMBOL_GPL(ssb_core_is_enabled);
+
+static void ssb_flush_bus(struct ssb *ssb, u16 dummyreg)
+{
+	ssb_read32(ssb, dummyreg); /* dummy read */
+	udelay(1);
+}
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
+		msleep(1);
+	}
+	printk(KERN_ERR PFX "Timeout waiting for bitmask %08X on "
+			    "register %04X to %s.\n",
+	       bitmask, reg, (set ? "set" : "clear"));
+
+	return -ETIMEDOUT;
+}
+
+static void ssb_core_disable_locked(struct ssb *ssb,
+				    u32 core_specific_flags)
+{
+	if (ssb_read32(ssb, SSB_TMSLOW) & SSB_TMSLOW_RESET)
+		return;
+
+	ssb_write32(ssb, SSB_TMSLOW, SSB_TMSLOW_REJECT | SSB_TMSLOW_CLOCK);
+	ssb_wait_bit(ssb, SSB_TMSLOW, SSB_TMSLOW_REJECT, 100, 1);
+	ssb_wait_bit(ssb, SSB_TMSHIGH, SSB_TMSHIGH_BUSY, 100, 0);
+	ssb_write32(ssb, SSB_TMSLOW,
+		    SSB_TMSLOW_FGC | SSB_TMSLOW_CLOCK |
+		    SSB_TMSLOW_REJECT | SSB_TMSLOW_RESET |
+		    core_specific_flags);
+	ssb_flush_bus(ssb, SSB_TMSLOW);
+
+	ssb_write32(ssb, SSB_TMSLOW,
+		    SSB_TMSLOW_REJECT | SSB_TMSLOW_RESET |
+		    core_specific_flags);
+	ssb_flush_bus(ssb, SSB_TMSLOW);
+}
+
+void ssb_core_enable(struct ssb *ssb, u32 core_specific_flags)
+{
+	u32 val;
+
+	mutex_lock(&ssb->mutex);
+
+	ssb_core_disable_locked(ssb, core_specific_flags);
+	ssb_write32(ssb, SSB_TMSLOW,
+		    SSB_TMSLOW_RESET | SSB_TMSLOW_CLOCK |
+		    SSB_TMSLOW_FGC | core_specific_flags);
+	ssb_flush_bus(ssb, SSB_TMSLOW);
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
+	ssb_flush_bus(ssb, SSB_TMSLOW);
+
+	ssb_write32(ssb, SSB_TMSLOW, SSB_TMSLOW_CLOCK |
+		    core_specific_flags);
+	ssb_flush_bus(ssb, SSB_TMSLOW);
+
+	mutex_unlock(&ssb->mutex);
+}
+EXPORT_SYMBOL_GPL(ssb_core_enable);
+
+void ssb_core_disable(struct ssb *ssb, u32 core_specific_flags)
+{
+	mutex_lock(&ssb->mutex);
+	ssb_core_disable_locked(ssb, core_specific_flags);
+	mutex_unlock(&ssb->mutex);
+}
+EXPORT_SYMBOL_GPL(ssb_core_disable);
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
+	BUILD_BUG_ON(SSB_PCICORE_BCAST_ADDR != SSB_CHIPCOMMON_BCAST_ADDR);
+	BUILD_BUG_ON(SSB_PCICORE_BCAST_DATA != SSB_CHIPCOMMON_BCAST_DATA);
+
+	ssb_write32(ssb, SSB_PCICORE_BCAST_ADDR, address);
+	ssb_flush_bus(ssb, 0x0);
+	ssb_write32(ssb, SSB_PCICORE_BCAST_DATA, data);
+	ssb_flush_bus(ssb, 0x0);
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
+		err = ssb_switch_core_locked(ssb, chipcommon_core);
+		if (err)
+			goto out;
+	}
+	/* This forces an update of the cached registers. */
+	ssb_broadcast_value(ssb, 0xFD8, 0);
+	if (old_core) {
+		err = ssb_switch_core_locked(ssb, old_core);
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
+	mutex_lock(&ssb->mutex);
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
+	err = ssb_switch_core_locked(ssb, pci_core);
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
+		value = ssb_read32(ssb, SSB_PCICORE_TRANS2);
+		value |= SSB_PCICORE_TRANS2_PREF;
+		value |= SSB_PCICORE_TRANS2_BURST;
+		ssb_write32(ssb, SSB_PCICORE_TRANS2, value);
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
+			value = ssb_read32(ssb, SSB_PCICORE_TRANS2);
+			value |= SSB_PCICORE_TRANS2_MRM;
+			ssb_write32(ssb, SSB_PCICORE_TRANS2, value);
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
+	err = ssb_switch_core_locked(ssb, old_core);
+out:
+	mutex_unlock(&ssb->mutex);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(ssb_cores_connect);
+
+
+MODULE_DESCRIPTION("Sonics Silicon Backplane driver");
+MODULE_LICENSE("GPL");
Index: wireless-dev/include/linux/ssb.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/include/linux/ssb.h	2006-08-23 10:52:21.000000000 +0200
@@ -0,0 +1,577 @@
+#ifndef LINUX__SONICS_SILICON_BACKPLANE_H_
+#define LINUX__SONICS_SILICON_BACKPLANE_H_
+
+/* Sonics SiliconBackplane support routines. */
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+
+/* SSB PCI config space registers. */
+#define	SSB_BAR0_WIN		0x80	/* Backplane address space 0 */
+#define	SSB_BAR1_WIN		0x84	/* Backplane address space 1 */
+#define	SSB_SPROMCTL		0x88	/* SPROM control */
+#define  SSB_SPROMCTL_WE	0x10	/* SPROM write enable */
+#define	SSB_BAR1_CONTROL	0x8c	/* Address space 1 burst control */
+#define SSB_PCI_IRQS		0x90	/* PCI interrupts */
+#define SSB_PCI_IRQMASK		0x94	/* PCI IRQ control and mask (pcirev >= 6 only) */
+#define SSB_BACKPLANE_IRQS	0x98	/* Backplane Interrupts */
+#define SSB_GPIO_IN		0xB0	/* GPIO Input (pcirev >= 3 only) */
+#define SSB_GPIO_OUT		0xB4	/* GPIO Output (pcirev >= 3 only) */
+#define SSB_GPIO_OUT_ENABLE	0xB8	/* GPIO Output Enable/Disable (pcirev >= 3 only) */
+
+#define SSB_BAR0_MAX_RETRIES	50
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
+#define  SSB_TMSHIGH_TO		0x00000020 /* Timeout. Backplane rev >= 2.3 only */
+#define  SSB_TMSHIGH_COREFL	0x1FFF0000 /* Core specific flags */
+#define  SSB_TMSHIGH_COREFL_SHIFT	16
+#define  SSB_TMSHIGH_DMA64	0x10000000 /* 64bit DMA supported */
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
+#define  SSB_IDLOW_CFGSP	0x00000003 /* Config Space */
+#define  SSB_IDLOW_ADDRNGE	0x00000038 /* Address Ranges supported */
+#define  SSB_IDLOW_ADDRNGE_SHIFT	3
+#define  SSB_IDLOW_SYNC		0x00000040
+#define  SSB_IDLOW_INITIATOR	0x00000080
+#define  SSB_IDLOW_MIBL		0x00000F00 /* Minimum Backplane latency */
+#define  SSB_IDLOW_MIBL_SHIFT	8
+#define  SSB_IDLOW_MABL		0x0000F000 /* Maximum Backplane latency */
+#define  SSB_IDLOW_MABL_SHIFT	12
+#define  SSB_IDLOW_TIF		0x00010000 /* This Initiator is first */
+#define  SSB_IDLOW_CCW		0x000C0000 /* Cycle counter width */
+#define  SSB_IDLOW_CCW_SHIFT	18
+#define  SSB_IDLOW_TPT		0x00F00000 /* Target ports */
+#define  SSB_IDLOW_TPT_SHIFT	20
+#define  SSB_IDLOW_INITP	0x0F000000 /* Initiator ports */
+#define  SSB_IDLOW_INITP_SHIFT	24
+#define  SSB_IDLOW_SSBREV	0xF0000000 /* Sonics Backplane Revision code */
+#define  SSB_IDLOW_SSBREV_22	0x00000000 /* <= 2.2 */
+#define  SSB_IDLOW_SSBREV_23	0x10000000 /* 2.3 */
+#define SSB_IDHIGH		0x0FFC     /* SB Identification High */
+#define  SSB_IDHIGH_RC_MASK	0x0000000f /* Revision Code */
+#define  SSB_IDHIGH_CC_MASK	0x0000fff0 /* Core Code */
+#define  SSB_IDHIGH_CC_SHIFT	4
+#define  SSB_IDHIGH_VC_MASK	0xffff0000 /* Vendor Code */
+#define  SSB_IDHIGH_VC_SHIFT	16
+
+/* SPROM shadow area. If not otherwise noted, fields are
+ * two bytes wide. Note that the SPROM can _only_ be read
+ * in two-byte quantinies.
+ */
+#define SSB_SPROMSIZE_WORDS		64
+#define SSB_SPROMSIZE_BYTES		(SSB_SPROMSIZE_WORDS * sizeof(u16))
+#define SSB_SPROM_BASE			0x1000
+#define SSB_SPROM_REVISION		0x107E
+#define  SSB_SPROM_REVISION_REV		0x00FF	/* SPROM Revision number */
+#define  SSB_SPROM_REVISION_CRC		0xFF00	/* SPROM CRC8 value */
+#define  SSB_SPROM_REVISION_CRC_SHIFT	8
+/* SPROM Revision 1 */
+#define SSB_SPROM1_SPID			0x1004	/* Subsystem Product ID for PCI */
+#define SSB_SPROM1_SVID			0x1006	/* Subsystem Vendor ID for PCI */
+#define SSB_SPROM1_PID			0x1008	/* Product ID for PCI */
+#define SSB_SPROM1_IL0MAC		0x1048	/* 6 bytes MAC address for 802.11b/g */
+#define SSB_SPROM1_ET0MAC		0x104E	/* 6 bytes MAC address for Ethernet */
+#define SSB_SPROM1_ET1MAC		0x1054	/* 6 bytes MAC address for 802.11a */
+#define SSB_SPROM1_ETHPHY		0x105A	/* Ethernet PHY settings */
+#define  SSB_SPROM1_ETHPHY_ET0A		0x001F	/* MII Address for enet0 */
+#define  SSB_SPROM1_ETHPHY_ET1A		0x03E0	/* MII Address for enet1 */
+#define  SSB_SPROM1_ETHPHY_ET1A_SHIFT	5
+#define  SSB_SPROM1_ETHPHY_ET0M		(1<<14)	/* MDIO for enet0 */
+#define  SSB_SPROM1_ETHPHY_ET1M		(1<<15)	/* MDIO for enet1 */
+#define SSB_SPROM1_BINF			0x105C	/* Board info */
+#define  SSB_SPROM1_BINF_BREV		0x00FF	/* Board Revision */
+#define  SSB_SPROM1_BINF_CCODE		0x0F00	/* Country Code */
+#define  SSB_SPROM1_BINF_CCODE_SHIFT	8
+#define  SSB_SPROM1_BINF_ANTA		0x3000	/* Available A-PHY antennas */
+#define  SSB_SPROM1_BINF_ANTA_SHIFT	12
+#define  SSB_SPROM1_BINF_ANTBG		0xC000	/* Available B-PHY antennas */
+#define  SSB_SPROM1_BINF_ANTBG_SHIFT	14
+#define SSB_SPROM1_PA0B0		0x105E
+#define SSB_SPROM1_PA0B1		0x1060
+#define SSB_SPROM1_PA0B2		0x1062
+#define SSB_SPROM1_GPIOA		0x1064	/* General Purpose IO pins 0 and 1 */
+#define  SSB_SPROM1_GPIOA_P0		0x00FF	/* Pin 0 */
+#define  SSB_SPROM1_GPIOA_P1		0xFF00	/* Pin 1 */
+#define  SSB_SPROM1_GPIOA_P1_SHIFT	8
+#define SSB_SPROM1_GPIOB		0x1066	/* General Purpuse IO pins 2 and 3 */
+#define  SSB_SPROM1_GPIOB_P2		0x00FF	/* Pin 2 */
+#define  SSB_SPROM1_GPIOB_P3		0xFF00	/* Pin 3 */
+#define  SSB_SPROM1_GPIOB_P3_SHIFT	8
+#define SSB_SPROM1_MAXPWR		0x1068	/* Power Amplifier Max Power */
+#define  SSB_SPROM1_MAXPWR_A		0x00FF	/* A-PHY (in dBm Q5.2) */
+#define  SSB_SPROM1_MAXPWR_BG		0xFF00	/* B-PHY and G-PHY (in dBm Q5.2) */
+#define  SSB_SPROM1_MAXPWR_BG_SHIFT	8
+#define SSB_SPROM1_PA1B0		0x106A
+#define SSB_SPROM1_PA1B1		0x106C
+#define SSB_SPROM1_PA1B2		0x106E
+#define SSB_SPROM1_ITSSI		0x1070	/* Idle TSSI Target */
+#define  SSB_SPROM1_ITSSI_A		0x00FF	/* A-PHY */
+#define  SSB_SPROM1_ITSSI_BG		0xFF00	/* B-PHY and G-PHY */
+#define  SSB_SPROM1_ITSSI_BG_SHIFT	8
+#define SSB_SPROM1_BFLLO		0x1072	/* Boardflags (low 16 bits) */
+#define SSB_SPROM1_AGAIN		0x1074	/* Antenna Gain (in dBm Q5.2) */
+#define  SSB_SPROM1_AGAIN_A		0x00FF	/* A-PHY */
+#define  SSB_SPROM1_AGAIN_BG		0xFF00	/* B-PHY and G-PHY */
+#define  SSB_SPROM1_AGAIN_BG_SHIFT	8
+#define SSB_SPROM1_OEM			0x1076	/* 8 bytes OEM string (rev 1 only) */
+/* SPROM Revision 2 (inherits from rev 1) */
+#define SSB_SPROM2_BFLHI		0x1038	/* Boardflags (high 16 bits) */
+#define SSB_SPROM2_MAXP_A		0x103A	/* A-PHY Max Power */
+#define  SSB_SPROM2_MAXP_A_HI		0x00FF	/* Max Power High */
+#define  SSB_SPROM2_MAXP_A_LO		0x1100	/* Max Power Low */
+#define  SSB_SPROM2_MAXP_A_LO_SHIFT	8
+#define SSB_SPROM2_PA1LOB0		0x103C	/* A-PHY PowerAmplifier Low Settings */
+#define SSB_SPROM2_PA1LOB1		0x103E	/* A-PHY PowerAmplifier Low Settings */
+#define SSB_SPROM2_PA1LOB2		0x1040	/* A-PHY PowerAmplifier Low Settings */
+#define SSB_SPROM2_PA1HIB0		0x1042	/* A-PHY PowerAmplifier High Settings */
+#define SSB_SPROM2_PA1HIB1		0x1044	/* A-PHY PowerAmplifier High Settings */
+#define SSB_SPROM2_PA1HIB2		0x1046	/* A-PHY PowerAmplifier High Settings */
+#define SSB_SPROM2_OPO			0x1078	/* OFDM Power Offset from CCK Level */
+#define  SSB_SPROM2_OPO_VALUE		0x00FF
+#define  SSB_SPROM2_OPO_UNUSED		0xFF00
+#define SSB_SPROM2_CCODE		0x107C	/* Two char Country Code */
+/* SPROM Revision 3 (inherits from rev 2) */
+#define SSB_SPROM3_OFDMAPO		0x102C	/* A-PHY OFDM Mid Power Offset (4 bytes, BigEndian) */
+#define SSB_SPROM3_OFDMALPO		0x1030	/* A-PHY OFDM Low Power Offset (4 bytes, BigEndian) */
+#define SSB_SPROM3_OFDMAHPO		0x1034	/* A-PHY OFDM High Power Offset (4 bytes, BigEndian) */
+#define SSB_SPROM3_GPIOLDC		0x1042	/* GPIO LED Powersave Duty Cycle (4 bytes, BigEndian) */
+#define  SSB_SPROM3_GPIOLDC_OFF		0x0000FF00	/* Off Count */
+#define  SSB_SPROM3_GPIOLDC_OFF_SHIFT	8
+#define  SSB_SPROM3_GPIOLDC_ON		0x00FF0000	/* On Count */
+#define  SSB_SPROM3_GPIOLDC_ON_SHIFT	16
+#define SSB_SPROM3_CCKPO		0x1078	/* CCK Power Offset */
+#define  SSB_SPROM3_CCKPO_1M		0x000F	/* 1M Rate PO */
+#define  SSB_SPROM3_CCKPO_2M		0x00F0	/* 2M Rate PO */
+#define  SSB_SPROM3_CCKPO_2M_SHIFT	4
+#define  SSB_SPROM3_CCKPO_55M		0x0F00	/* 5.5M Rate PO */
+#define  SSB_SPROM3_CCKPO_55M_SHIFT	8
+#define  SSB_SPROM3_CCKPO_11M		0xF000	/* 11M Rate PO */
+#define  SSB_SPROM3_CCKPO_11M_SHIFT	12
+#define  SSB_SPROM3_OFDMGPO		0x107A	/* G-PHY OFDM Power Offset (4 bytes, BigEndian) */
+
+/* Values for SSB_SPROM1_BINF_CCODE */
+enum {
+	SSB_SPROM1CCODE_WORLD = 0,
+	SSB_SPROM1CCODE_THAILAND,
+	SSB_SPROM1CCODE_ISRAEL,
+	SSB_SPROM1CCODE_JORDAN,
+	SSB_SPROM1CCODE_CHINA,
+	SSB_SPROM1CCODE_JAPAN,
+	SSB_SPROM1CCODE_USA_CANADA_ANZ,
+	SSB_SPROM1CCODE_EUROPE,
+	SSB_SPROM1CCODE_USA_LOW,
+	SSB_SPROM1CCODE_JAPAN_HIGH,
+	SSB_SPROM1CCODE_ALL,
+	SSB_SPROM1CCODE_NONE,
+};
+
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
+
+/* ChipCommon core registers. */
+#define SSB_CHIPCOMMON_CHIPID		0x0000
+#define  SSB_CHIPCOMMON_IDMASK		0x0000FFFF
+#define  SSB_CHIPCOMMON_REVMASK		0x000F0000
+#define  SSB_CHIPCOMMON_REVSHIFT	16
+#define  SSB_CHIPCOMMON_PACKMASK	0x00F00000
+#define  SSB_CHIPCOMMON_PACKSHIFT	20
+#define  SSB_CHIPCOMMON_NRCORESMASK	0x0F000000
+#define  SSB_CHIPCOMMON_NRCORESSHIFT	24
+#define SSB_CHIPCOMMON_CAP	 	0x0004		/* Capabilities */
+#define  SSB_CHIPCOMMON_CAP_NRUART	0x00000003	/* # of UARTs */
+#define  SSB_CHIPCOMMON_CAP_MIPSEB	0x00000004	/* MIPS in BigEndian Mode */
+#define  SSB_CHIPCOMMON_CAP_UARTCLK	0x00000018	/* UART clock select */
+#define  SSB_CHIPCOMMON_CAP_UARTGPIO	0x00000020	/* UARTs on GPIO 15-12 */
+#define  SSB_CHIPCOMMON_CAP_EXTBUS	0x000000C0	/* External buses present */
+#define  SSB_CHIPCOMMON_CAP_FLASHT	0x00000700	/* Flash Type */
+#define  SSB_CHIPCOMMON_CAP_PLLT	0x00038000	/* PLL Type */
+#define  SSB_CHIPCOMMON_CAP_PCTL	0x00040000	/* Power Control */
+#define  SSB_CHIPCOMMON_CAP_OTPS	0x00380000	/* OTP size */
+#define  SSB_CHIPCOMMON_CAP_JTAGM	0x00400000	/* JTAG master present */
+#define  SSB_CHIPCOMMON_CAP_BROM	0x00800000	/* Internal boot ROM active */
+#define  SSB_CHIPCOMMON_CAP_64BIT	0x08000000	/* 64-bit Backplane */
+#define SSB_CHIPCOMMON_CORECTL		0x0008
+#define SSB_CHIPCOMMON_BIST		0x000C
+#define SSB_CHIPCOMMON_BCAST_ADDR	0x0050
+#define SSB_CHIPCOMMON_BCAST_DATA	0x0054
+#define SSB_CHIPCOMMON_PLLONDELAY	0x00B0
+#define SSB_CHIPCOMMON_FREFSELDELAY	0x00B4
+#define SSB_CHIPCOMMON_SLOWCLKCTL	0x00B8
+#define SSB_CHIPCOMMON_SYSCLKCTL	0x00C0
+
+/* PCI core registers. */
+#define SSB_PCICORE_CTL		0x0000	/* PCI Control */
+#define SSB_PCICORE_ARBCTL	0x0010	/* PCI Arbiter Control */
+#define SSB_PCICORE_ISTAT	0x0020	/* Interrupt status */
+#define SSB_PCICORE_IMASK	0x0024	/* Interrupt mask */
+#define SSB_PCICORE_MBOX	0x0028	/* Backplane to PCI Mailbox */
+#define SSB_PCICORE_BCAST_ADDR	0x0050	/* Backplane Broadcast Address */
+#define SSB_PCICORE_BCAST_DATA	0x0054	/* Backplane Broadcast Data */
+#define SSB_PCICORE_GPIO_IN	0x0060	/* rev >= 2 only */
+#define SSB_PCICORE_GPIO_OUT	0x0064	/* rev >= 2 only */
+#define SSB_PCICORE_GPIO_ENABLE	0x0068	/* rev >= 2 only */
+#define SSB_PCICORE_GPIO_CTL	0x006C	/* rev >= 2 only */
+#define SSB_PCICORE_TRANS0	0x0100	/* Backplane to PCI translation 0 (sbtopci0) */
+#define SSB_PCICORE_TRANS1	0x0104	/* Backplane to PCI translation 1 (sbtopci1) */
+#define SSB_PCICORE_TRANS2	0x0108	/* Backplane to PCI translation 2 (dbtopci2) */
+#define  SSB_PCICORE_TRANS2_MEM		0x00000000
+#define  SSB_PCICORE_TRANS2_IO		0x00000001
+#define  SSB_PCICORE_TRANS2_CFG0	0x00000002
+#define  SSB_PCICORE_TRANS2_CFG1	0x00000003
+#define  SSB_PCICORE_TRANS2_PREF	0x00000004	/* Prefetch enable */
+#define  SSB_PCICORE_TRANS2_BURST	0x00000008	/* Burst enable */
+#define  SSB_PCICORE_TRANS2_MRM		0x00000020	/* Memory Read Multiple */
+#define  SSB_PCICORE_TRANS2_MASK0	0xfc000000
+#define  SSB_PCICORE_TRANS2_MASK1	0xfc000000
+#define  SSB_PCICORE_TRANS2_MASK2	0xc0000000
+
+
+
+struct pci_dev;
+
+
+struct ssb_sprom_r1 {
+	u16 pci_spid;		/* Subsystem Product ID for PCI */
+	u16 pci_svid;		/* Subsystem Vendor ID for PCI */
+	u16 pci_pid;		/* Product ID for PCI */
+	u8 il0mac[6];		/* MAC address for 802.11b/g */
+	u8 et0mac[6];		/* MAC address for Ethernet */
+	u8 et1mac[6];		/* MAC address for 802.11a */
+	u8 et0phyaddr:5;	/* MII address for enet0 */
+	u8 et1phyaddr:5;	/* MII address for enet1 */
+	u8 et0mdcport:1;	/* MDIO for enet0 */
+	u8 et1mdcport:1;	/* MDIO for enet1 */
+	u8 board_rev;		/* Board revision */
+	u8 country_code:4;	/* Country Code */
+	u8 antenna_a:2;		/* Antenna 0/1 available for A-PHY */
+	u8 antenna_bg:2;	/* Antenna 0/1 available for B-PHY and G-PHY */
+	u16 pa0b0;
+	u16 pa0b1;
+	u16 pa0b2;
+	u16 pa1b0;
+	u16 pa1b1;
+	u16 pa1b2;
+	u8 gpio0;		/* GPIO pin 0 */
+	u8 gpio1;		/* GPIO pin 1 */
+	u8 gpio2;		/* GPIO pin 2 */
+	u8 gpio3;		/* GPIO pin 3 */
+	u16 maxpwr_a;		/* A-PHY Power Amplifier Max Power (in dBm Q5.2) */
+	u16 maxpwr_bg;		/* B/G-PHY Power Amplifier Max Power (in dBm Q5.2) */
+	u8 itssi_a;		/* Idle TSSI Target for A-PHY */
+	u8 itssi_bg;		/* Idle TSSI Target for B/G-PHY */
+	u16 boardflags_lo;	/* Boardflags (low 16 bits) */
+	u8 antenna_gain_a;	/* A-PHY Antenna gain (in dBm Q5.2) */
+	u8 antenna_gain_bg;	/* B/G-PHY Antenna gain (in dBm Q5.2) */
+	u8 oem[8];		/* OEM string (rev 1 only) */
+};
+
+struct ssb_sprom_r2 {
+	u16 boardflags_hi;	/* Boardflags (high 16 bits) */
+	u8 maxpwr_a_lo;		/* A-PHY Max Power Low */
+	u8 maxpwr_a_hi;		/* A-PHY Max Power High */
+	u16 pa1lob0;		/* A-PHY PA Low Settings */
+	u16 pa1lob1;		/* A-PHY PA Low Settings */
+	u16 pa1lob2;		/* A-PHY PA Low Settings */
+	u16 pa1hib0;		/* A-PHY PA High Settings */
+	u16 pa1hib1;		/* A-PHY PA High Settings */
+	u16 pa1hib2;		/* A-PHY PA High Settings */
+	u8 ofdm_pwr_off;	/* OFDM Power Offset from CCK Level */
+	u8 country_str[2];	/* Two char Country Code */
+};
+
+struct ssb_sprom_r3 {
+	u32 ofdmapo;		/* A-PHY OFDM Mid Power Offset */
+	u32 ofdmalpo;		/* A-PHY OFDM Low Power Offset */
+	u32 ofdmahpo;		/* A-PHY OFDM High Power Offset */
+	u8 gpioldc_on_cnt;	/* GPIO LED Powersave Duty Cycle ON count */
+	u8 gpioldc_off_cnt;	/* GPIO LED Powersave Duty Cycle OFF count */
+	u8 cckpo_1M:4;		/* CCK Power Offset for Rate 1M */
+	u8 cckpo_2M:4;		/* CCK Power Offset for Rate 2M */
+	u8 cckpo_55M:4;		/* CCK Power Offset for Rate 5.5M */
+	u8 cckpo_11M:4;		/* CCK Power Offset for Rate 11M */
+	u32 ofdmgpo;		/* G-PHY OFDM Power Offset */
+};
+
+struct ssb_sprom_r4 {
+	/* TODO */
+};
+
+struct ssb_sprom {
+	u8 revision;
+	u8 crc;
+	/* The valid r# fields are selected by the "revision".
+	 * Revision 3 and lower inherit from lower revisions.
+	 */
+	union {
+		struct {
+			struct ssb_sprom_r1 r1;
+			struct ssb_sprom_r2 r2;
+			struct ssb_sprom_r3 r3;
+		};
+		struct ssb_sprom_r4 r4;
+	};
+};
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
+ * @chipcommon_capabilities	ChipCommon capabilities are stored here
+ * 				for convenience (if available).
+ * @chip_id:			Chip ID.
+ * @chip_rev:			Chip Revision.
+ * @chip_package:		Chip Package.
+ * @nr_cores:			Arraysize of "cores".
+ * @cores:			Array of all available cores.
+ * @current_core:		Pointer to the currently mapped core. Don't
+ * 				modify directly. Use ssb_switch_core().
+ *
+ * @current_core_offset:	Internal. Use ssb_core_offset().
+ */
+struct ssb {
+	u32 chipcommon_capabilities;
+	u16 chip_id;
+	u8 chip_rev;
+	u8 chip_package;
+
+	u8 nr_cores;
+	struct ssb_core	*cores;
+	struct ssb_core *current_core;
+
+	/* The following stuff is considered
+	 * to be internal to ssb. */
+
+#ifdef CONFIG_BCM947XX
+	u32 current_core_offset;
+#endif
+	struct pci_dev *pci_dev;
+	void __iomem *mmio;
+
+	int (*device_suspend)(struct ssb *ssb);
+	int (*device_resume)(struct ssb *ssb);
+	struct mutex suspend_mutex;
+
+	struct mutex mutex;
+	struct list_head list;
+};
+
+/**
+ * ssb_core_offset - Get the MMIO core-specific offset.
+ * Add this offset to all MMIO offsets on every MMIO
+ * access to the core.
+ * @ssb:	Pointer to struct ssb.
+ */
+static inline u32 ssb_core_offset(struct ssb *ssb)
+{
+#ifdef CONFIG_BCM947XX
+	return ssb->current_core_offset;
+#else
+	return 0;
+#endif
+}
+
+/**
+ * ssb_init - Initialize struct ssb.
+ * This does not init hardware. May fail and return NULL.
+ * @ssb:	Pointer to struct ssb to init. This will usually
+ * 		be embedded in the device's private struct.
+ * @pci_dev:	Pointer to the PCI device.
+ * @mmio:	Pointer to the MMIO area of the device.
+ * @device_suspend:	This callback suspends any device activity (IRQ...)
+ * @device_resume:	This callback resumes the device activity again.
+ */
+int ssb_init(struct ssb *ssb,
+	     struct pci_dev *pci_dev,
+	     void __iomem *mmio,
+	     int (*device_suspend)(struct ssb *ssb),
+	     int (*device_resume)(struct ssb *ssb));
+/** ssb_exit - Clean up and destroy ssb. */
+void ssb_exit(struct ssb *ssb);
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
+ * Current core IRQs must be disabled when calling this.
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
+ * Current core IRQs must be disabled when calling this.
+ * @ssb:	Pointer to struct ssb.
+ * @core_specific_flags:	Additional SSB_TMSLOW flags for
+ * 				this core. Pass 0 for none.
+ */
+void ssb_core_enable(struct ssb *ssb, u32 core_specific_flags);
+/**
+ * ssb_core_disable - Disable current_core.
+ * Current core IRQs must be disabled when calling this.
+ * @ssb:	Pointer to struct ssb.
+ * @core_specific_flags:	Additional SSB_TMSLOW flags for
+ * 				this core. Pass 0 for none.
+ */
+void ssb_core_disable(struct ssb *ssb, u32 core_specific_flags);
+/**
+ * ssb_cores_connect - Connect I/O cores to the backplane.
+ * Cores need to be connected to the backplane in order
+ * to route interrupts, for example.
+ * Current core IRQs must be disabled when calling this.
+ * Returns 0 on success or an error code on failure.
+ * @ssb:	Pointer to struct ssb.
+ * @coremask:	Bitmask of cores to connect.
+ */
+int ssb_cores_connect(struct ssb *ssb, u32 coremask);
+
+/**
+ * ssb_sprom_read - Read the SPROM from the chip,
+ * interpret the information and put it into "sprom".
+ * This function checks the CRC after reading.
+ * Returns 0 on success or an error code on failure.
+ * @ssb:	Pointer to struct ssb.
+ * @sprom:	Pointer to the buffer.
+ * @force:	If true, don't error out on a bad CRC.
+ */
+int ssb_sprom_read(struct ssb *ssb, struct ssb_sprom *sprom, int force);
+
+#endif /* LINUX__SONICS_SILICON_BACKPLANE_H_ */


-- 
Greetings Michael.
