From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Remove addressing abstraction
Date: Tue, 12 Dec 2006 01:26:11 +0000 (GMT)
Message-ID: <20061212012611.5B0B97B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:45908 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbWLLB0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:26:16 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of passing our own custom 32-bit addresses around and
translating them, this patch makes all our register address constants
absolute and removes the translation.

There are two ugly parts:
 - fw_reg_addr() is needed to compute addresses of firmware registers, as this
   is dynamic based upon firmware
 - inc_addr() needs a small hack to handle byte vs word addressing

However, both of those are only small, and we don't use fw_regs a whole
lot anyway.

The bonuses here include simplicity and improved driver readability. Also, the
fact that registers are now referenced by 16-bit absolute addresses (as
opposed to 32-bit pseudo addresses) means that over 2kb compiled code size has
been shaved off.

Includes some touchups and sparse fixes from Ulrich Kunitz.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -84,6 +84,18 @@ static void print_id(struct zd_chip *chi
 	dev_info(zd_chip_dev(chip), "%s\n", buffer);
 }
 
+static zd_addr_t inc_addr(zd_addr_t addr)
+{
+	u16 a = (u16)addr;
+	/* Control registers use byte addressing, but everything else uses word
+	 * addressing. */
+	if ((a & 0xf000) == CR_START)
+		a += 2;
+	else
+		a += 1;
+	return (zd_addr_t)a;
+}
+
 /* Read a variable number of 32-bit values. Parameter count is not allowed to
  * exceed USB_MAX_IOREAD32_COUNT.
  */
@@ -114,7 +126,7 @@ int zd_ioread32v_locked(struct zd_chip *
 	for (i = 0; i < count; i++) {
 		int j = 2*i;
 		/* We read the high word always first. */
-		a16[j] = zd_inc_word(addr[i]);
+		a16[j] = inc_addr(addr[i]);
 		a16[j+1] = addr[i];
 	}
 
@@ -163,7 +175,7 @@ int _zd_iowrite32v_locked(struct zd_chip
 		j = 2*i;
 		/* We write the high word always first. */
 		ioreqs16[j].value   = ioreqs[i].value >> 16;
-		ioreqs16[j].addr    = zd_inc_word(ioreqs[i].addr);
+		ioreqs16[j].addr    = inc_addr(ioreqs[i].addr);
 		ioreqs16[j+1].value = ioreqs[i].value;
 		ioreqs16[j+1].addr  = ioreqs[i].addr;
 	}
@@ -466,7 +478,8 @@ static int read_values(struct zd_chip *c
 
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
 	for (i = 0;;) {
-		r = zd_ioread32_locked(chip, &v, e2p_addr+i/2);
+		r = zd_ioread32_locked(chip, &v,
+			               (zd_addr_t)((u16)e2p_addr+i/2));
 		if (r)
 			return r;
 		v -= guard;
@@ -953,6 +966,11 @@ static int hw_init(struct zd_chip *chip)
 	return set_beacon_interval(chip, 100);
 }
 
+static zd_addr_t fw_reg_addr(struct zd_chip *chip, u16 offset)
+{
+	return (zd_addr_t)((u16)chip->fw_regs_base + offset);
+}
+
 #ifdef DEBUG
 static int dump_cr(struct zd_chip *chip, const zd_addr_t addr,
 	           const char *addr_string)
@@ -987,9 +1005,11 @@ static int test_init(struct zd_chip *chi
 
 static void dump_fw_registers(struct zd_chip *chip)
 {
-	static const zd_addr_t addr[4] = {
-		FW_FIRMWARE_VER, FW_USB_SPEED, FW_FIX_TX_RATE,
-		FW_LINK_STATUS
+	const zd_addr_t addr[4] = {
+		fw_reg_addr(chip, FW_REG_FIRMWARE_VER),
+		fw_reg_addr(chip, FW_REG_USB_SPEED),
+		fw_reg_addr(chip, FW_REG_FIX_TX_RATE),
+		fw_reg_addr(chip, FW_REG_LED_LINK_STATUS),
 	};
 
 	int r;
@@ -1015,7 +1035,8 @@ static int print_fw_version(struct zd_ch
 	int r;
 	u16 version;
 
-	r = zd_ioread16_locked(chip, &version, FW_FIRMWARE_VER);
+	r = zd_ioread16_locked(chip, &version,
+		fw_reg_addr(chip, FW_REG_FIRMWARE_VER));
 	if (r)
 		return r;
 
@@ -1095,6 +1116,22 @@ int zd_chip_disable_hwint(struct zd_chip
 	return r;
 }
 
+static int read_fw_regs_offset(struct zd_chip *chip)
+{
+	int r;
+
+	ZD_ASSERT(mutex_is_locked(&chip->mutex));
+	r = zd_ioread16_locked(chip, (u16*)&chip->fw_regs_base,
+		               FWRAW_REGS_ADDR);
+	if (r)
+		return r;
+	dev_dbg_f(zd_chip_dev(chip), "fw_regs_base: %#06hx\n",
+		  (u16)chip->fw_regs_base);
+
+	return 0;
+}
+
+
 int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 {
 	int r;
@@ -1114,7 +1151,7 @@ int zd_chip_init_hw(struct zd_chip *chip
 	if (r)
 		goto out;
 
-	r = zd_usb_init_hw(&chip->usb);
+	r = read_fw_regs_offset(chip);
 	if (r)
 		goto out;
 
@@ -1294,15 +1331,15 @@ u8 zd_chip_get_channel(struct zd_chip *c
 
 int zd_chip_control_leds(struct zd_chip *chip, enum led_status status)
 {
-	static const zd_addr_t a[] = {
-		FW_LINK_STATUS,
+	const zd_addr_t a[] = {
+		fw_reg_addr(chip, FW_REG_LED_LINK_STATUS),
 		CR_LED,
 	};
 
 	int r;
 	u16 v[ARRAY_SIZE(a)];
 	struct zd_ioreq16 ioreqs[ARRAY_SIZE(a)] = {
-		[0] = { FW_LINK_STATUS },
+		[0] = { fw_reg_addr(chip, FW_REG_LED_LINK_STATUS) },
 		[1] = { CR_LED },
 	};
 	u16 other_led;
Index: linux/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -18,7 +18,6 @@
 #ifndef _ZD_CHIP_H
 #define _ZD_CHIP_H
 
-#include "zd_types.h"
 #include "zd_rf.h"
 #include "zd_usb.h"
 
@@ -27,6 +26,37 @@
  * adds a processor for handling the USB protocol.
  */
 
+/* Address space */
+enum {
+	/* CONTROL REGISTERS */
+	CR_START			= 0x9000,
+
+
+	/* FIRMWARE */
+	FW_START			= 0xee00,
+
+
+	/* EEPROM */
+	E2P_START			= 0xf800,
+	E2P_LEN				= 0x800,
+
+	/* EEPROM layout */
+	E2P_LOAD_CODE_LEN		= 0xe,		/* base 0xf800 */
+	E2P_LOAD_VECT_LEN		= 0x9,		/* base 0xf80e */
+	/* E2P_DATA indexes into this */
+	E2P_DATA_LEN			= 0x7e,		/* base 0xf817 */
+	E2P_BOOT_CODE_LEN		= 0x760,	/* base 0xf895 */
+	E2P_INTR_VECT_LEN		= 0xb,		/* base 0xfff5 */
+
+	/* Some precomputed offsets into the EEPROM */
+	E2P_DATA_OFFSET			= E2P_LOAD_CODE_LEN + E2P_LOAD_VECT_LEN,
+	E2P_BOOT_CODE_OFFSET		= E2P_DATA_OFFSET + E2P_DATA_LEN,
+};
+
+#define CTL_REG(offset) ((zd_addr_t)(CR_START + (offset)))
+#define E2P_DATA(offset) ((zd_addr_t)(E2P_START + E2P_DATA_OFFSET + (offset)))
+#define FWRAW_DATA(offset) ((zd_addr_t)(FW_START + (offset)))
+
 /* 8-bit hardware registers */
 #define CR0   CTL_REG(0x0000)
 #define CR1   CTL_REG(0x0004)
@@ -302,7 +332,7 @@
 
 #define CR_MAX_PHY_REG 255
 
-/* Taken from the ZYDAS driver, not all of them are relevant for the ZSD1211
+/* Taken from the ZYDAS driver, not all of them are relevant for the ZD1211
  * driver.
  */
 
@@ -638,50 +668,27 @@
 #define E2P_54M_INT_VALUE3	E2P_DATA(0x54)
 #define E2P_54M_INT_VALUE4	E2P_DATA(0x56)
 
-/* All 16 bit values */
-#define FW_FIRMWARE_VER         FW_REG(0)
-/* non-zero if USB high speed connection */
-#define FW_USB_SPEED            FW_REG(1)
-#define FW_FIX_TX_RATE          FW_REG(2)
-/* Seems to be able to control LEDs over the firmware */
-#define FW_LINK_STATUS          FW_REG(3)
-#define FW_SOFT_RESET           FW_REG(4)
-#define FW_FLASH_CHK            FW_REG(5)
+/* This word contains the base address of the FW_REG_ registers below */
+#define FWRAW_REGS_ADDR		FWRAW_DATA(0x1d)
+
+/* All 16 bit values, offset from the address in FWRAW_REGS_ADDR */
+enum {
+	FW_REG_FIRMWARE_VER	= 0,
+	/* non-zero if USB high speed connection */
+	FW_REG_USB_SPEED	= 1,
+	FW_REG_FIX_TX_RATE	= 2,
+	/* Seems to be able to control LEDs over the firmware */
+	FW_REG_LED_LINK_STATUS	= 3,
+	FW_REG_SOFT_RESET	= 4,
+	FW_REG_FLASH_CHK	= 5,
+};
 
+/* Values for FW_LINK_STATUS */
 #define FW_LINK_OFF		0x0
 #define FW_LINK_TX		0x1
 /* 0x2 - link led on? */
 
 enum {
-	/* CONTROL REGISTERS */
-	CR_START			= 0x9000,
-
-	/* FIRMWARE */
-	FW_START			= 0xee00,
-
-	/* The word at this offset contains the base address of the FW_REG
-	 * registers */
-	FW_REGS_ADDR_OFFSET		= 0x1d,
-
-
-	/* EEPROM */
-	E2P_START			= 0xf800,
-	E2P_LEN				= 0x800,
-
-	/* EEPROM layout */
-	E2P_LOAD_CODE_LEN		= 0xe,		/* base 0xf800 */
-	E2P_LOAD_VECT_LEN		= 0x9,		/* base 0xf80e */
-	/* E2P_DATA indexes into this */
-	E2P_DATA_LEN			= 0x7e,		/* base 0xf817 */
-	E2P_BOOT_CODE_LEN		= 0x760,	/* base 0xf895 */
-	E2P_INTR_VECT_LEN		= 0xb,		/* base 0xfff5 */
-
-	/* Some precomputed offsets into the EEPROM */
-	E2P_DATA_OFFSET			= E2P_LOAD_CODE_LEN + E2P_LOAD_VECT_LEN,
-	E2P_BOOT_CODE_OFFSET		= E2P_DATA_OFFSET + E2P_DATA_LEN,
-};
-
-enum {
 	/* indices for ofdm_cal_values */
 	OFDM_36M_INDEX = 0,
 	OFDM_48M_INDEX = 1,
@@ -692,6 +699,8 @@ struct zd_chip {
 	struct zd_usb usb;
 	struct zd_rf rf;
 	struct mutex mutex;
+	/* Base address of FW_REG_ registers */
+	zd_addr_t fw_regs_base;
 	u8 e2p_mac[ETH_ALEN];
 	/* EepSetPoint in the vendor driver */
 	u8 pwr_cal_values[E2P_CHANNEL_COUNT];
Index: linux/drivers/net/wireless/zd1211rw/zd_def.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_def.h
+++ linux/drivers/net/wireless/zd1211rw/zd_def.h
@@ -23,6 +23,8 @@
 #include <linux/device.h>
 #include <linux/kernel.h>
 
+typedef u16 __nocast zd_addr_t;
+
 #define dev_printk_f(level, dev, fmt, args...) \
 	dev_printk(level, dev, "%s() " fmt, __func__, ##args)
 
Index: linux/drivers/net/wireless/zd1211rw/zd_ieee80211.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ linux/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -2,7 +2,6 @@
 #define _ZD_IEEE80211_H
 
 #include <net/ieee80211.h>
-#include "zd_types.h"
 
 /* Additional definitions from the standards.
  */
Index: linux/drivers/net/wireless/zd1211rw/zd_rf.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_rf.h
+++ linux/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -18,8 +18,6 @@
 #ifndef _ZD_RF_H
 #define _ZD_RF_H
 
-#include "zd_types.h"
-
 #define UW2451_RF			0x2
 #define UCHIP_RF			0x3
 #define AL2230_RF			0x4
Index: linux/drivers/net/wireless/zd1211rw/zd_types.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_types.h
+++ /dev/null
@@ -1,71 +0,0 @@
-/* zd_types.h
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- */
-
-#ifndef _ZD_TYPES_H
-#define _ZD_TYPES_H
-
-#include <linux/types.h>
-
-/* We have three register spaces mapped into the overall USB address space of
- * 64K words (16-bit values). There is the control register space of
- * double-word registers, the eeprom register space and the firmware register
- * space. The control register space is byte mapped, the others are word
- * mapped.
- *
- * For that reason, we are using byte offsets for control registers and word
- * offsets for everything else.
- */
-
-typedef u32 __nocast zd_addr_t;
-
-enum {
-	ADDR_BASE_MASK		= 0xff000000,
-	ADDR_OFFSET_MASK	= 0x0000ffff,
-	ADDR_ZERO_MASK		= 0x00ff0000,
-	NULL_BASE		= 0x00000000,
-	USB_BASE		= 0x01000000,
-	CR_BASE			= 0x02000000,
-	CR_MAX_OFFSET		= 0x0b30,
-	E2P_BASE		= 0x03000000,
-	E2P_MAX_OFFSET		= 0x007e,
-	FW_BASE			= 0x04000000,
-	FW_MAX_OFFSET		= 0x0005,
-};
-
-#define ZD_ADDR_BASE(addr) ((u32)(addr) & ADDR_BASE_MASK)
-#define ZD_OFFSET(addr) ((u32)(addr) & ADDR_OFFSET_MASK)
-
-#define ZD_ADDR(base, offset) \
-	((zd_addr_t)(((base) & ADDR_BASE_MASK) | ((offset) & ADDR_OFFSET_MASK)))
-
-#define ZD_NULL_ADDR    ((zd_addr_t)0)
-#define USB_REG(offset)  ZD_ADDR(USB_BASE, offset)	/* word addressing */
-#define CTL_REG(offset)  ZD_ADDR(CR_BASE, offset)	/* byte addressing */
-#define E2P_DATA(offset)  ZD_ADDR(E2P_BASE, offset)	/* word addressing */
-#define FW_REG(offset)   ZD_ADDR(FW_BASE, offset)	/* word addressing */
-
-static inline zd_addr_t zd_inc_word(zd_addr_t addr)
-{
-	u32 base = ZD_ADDR_BASE(addr);
-	u32 offset = ZD_OFFSET(addr);
-
-	offset += base == CR_BASE ? 2 : 1;
-
-	return base | offset;
-}
-
-#endif /* _ZD_TYPES_H */
Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -75,96 +75,6 @@ MODULE_DEVICE_TABLE(usb, usb_ids);
 #define FW_ZD1211_PREFIX	"zd1211/zd1211_"
 #define FW_ZD1211B_PREFIX	"zd1211/zd1211b_"
 
-/* register address handling */
-
-#ifdef DEBUG
-static int check_addr(struct zd_usb *usb, zd_addr_t addr)
-{
-	u32 base = ZD_ADDR_BASE(addr);
-	u32 offset = ZD_OFFSET(addr);
-
-	if ((u32)addr & ADDR_ZERO_MASK)
-		goto invalid_address;
-	switch (base) {
-	case USB_BASE:
-		break;
-	case CR_BASE:
-		if (offset > CR_MAX_OFFSET) {
-			dev_dbg(zd_usb_dev(usb),
-				"CR offset %#010x larger than"
-				" CR_MAX_OFFSET %#10x\n",
-				offset, CR_MAX_OFFSET);
-			goto invalid_address;
-		}
-		if (offset & 1) {
-			dev_dbg(zd_usb_dev(usb),
-				"CR offset %#010x is not a multiple of 2\n",
-				offset);
-			goto invalid_address;
-		}
-		break;
-	case E2P_BASE:
-		if (offset > E2P_MAX_OFFSET) {
-			dev_dbg(zd_usb_dev(usb),
-				"E2P offset %#010x larger than"
-				" E2P_MAX_OFFSET %#010x\n",
-				offset, E2P_MAX_OFFSET);
-			goto invalid_address;
-		}
-		break;
-	case FW_BASE:
-		if (!usb->fw_base_offset) {
-			dev_dbg(zd_usb_dev(usb),
-			       "ERROR: fw base offset has not been set\n");
-			return -EAGAIN;
-		}
-		if (offset > FW_MAX_OFFSET) {
-			dev_dbg(zd_usb_dev(usb),
-				"FW offset %#10x is larger than"
-				" FW_MAX_OFFSET %#010x\n",
-				offset, FW_MAX_OFFSET);
-			goto invalid_address;
-		}
-		break;
-	default:
-		dev_dbg(zd_usb_dev(usb),
-			"address has unsupported base %#010x\n", addr);
-		goto invalid_address;
-	}
-
-	return 0;
-invalid_address:
-	dev_dbg(zd_usb_dev(usb),
-		"ERROR: invalid address: %#010x\n", addr);
-	return -EINVAL;
-}
-#endif /* DEBUG */
-
-static u16 usb_addr(struct zd_usb *usb, zd_addr_t addr)
-{
-	u32 base;
-	u16 offset;
-
-	base = ZD_ADDR_BASE(addr);
-	offset = ZD_OFFSET(addr);
-
-	ZD_ASSERT(check_addr(usb, addr) == 0);
-
-	switch (base) {
-	case CR_BASE:
-		offset += CR_START;
-		break;
-	case E2P_BASE:
-		offset += E2P_START + E2P_DATA_OFFSET;
-		break;
-	case FW_BASE:
-		offset += usb->fw_base_offset;
-		break;
-	}
-
-	return offset;
-}
-
 /* USB device initialization */
 
 static int request_fw_file(
@@ -858,7 +768,7 @@ static inline void init_usb_interrupt(st
 	spin_lock_init(&intr->lock);
 	intr->interval = int_urb_interval(zd_usb_to_usbdev(usb));
 	init_completion(&intr->read_regs.completion);
-	intr->read_regs.cr_int_addr = cpu_to_le16(usb_addr(usb, CR_INTERRUPT));
+	intr->read_regs.cr_int_addr = cpu_to_le16((u16)CR_INTERRUPT);
 }
 
 static inline void init_usb_rx(struct zd_usb *usb)
@@ -890,22 +800,6 @@ void zd_usb_init(struct zd_usb *usb, str
 	init_usb_rx(usb);
 }
 
-int zd_usb_init_hw(struct zd_usb *usb)
-{
-	int r;
-	struct zd_chip *chip = zd_usb_to_chip(usb);
-
-	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	r = zd_ioread16_locked(chip, &usb->fw_base_offset,
-		        USB_REG(FW_START + FW_REGS_ADDR_OFFSET));
-	if (r)
-		return r;
-	dev_dbg_f(zd_usb_dev(usb), "fw_base_offset: %#06hx\n",
-		 usb->fw_base_offset);
-
-	return 0;
-}
-
 void zd_usb_clear(struct zd_usb *usb)
 {
 	usb_set_intfdata(usb->intf, NULL);
@@ -1253,7 +1147,7 @@ int zd_usb_ioread16v(struct zd_usb *usb,
 		return -ENOMEM;
 	req->id = cpu_to_le16(USB_REQ_READ_REGS);
 	for (i = 0; i < count; i++)
-		req->addr[i] = cpu_to_le16(usb_addr(usb, addresses[i]));
+		req->addr[i] = cpu_to_le16((u16)addresses[i]);
 
 	udev = zd_usb_to_usbdev(usb);
 	prepare_read_regs_int(usb);
@@ -1318,7 +1212,7 @@ int zd_usb_iowrite16v(struct zd_usb *usb
 	req->id = cpu_to_le16(USB_REQ_WRITE_REGS);
 	for (i = 0; i < count; i++) {
 		struct reg_data *rw  = &req->reg_writes[i];
-		rw->addr = cpu_to_le16(usb_addr(usb, ioreqs[i].addr));
+		rw->addr = cpu_to_le16((u16)ioreqs[i].addr);
 		rw->value = cpu_to_le16(ioreqs[i].value);
 	}
 
Index: linux/drivers/net/wireless/zd1211rw/zd_usb.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.h
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -25,7 +25,6 @@
 #include <linux/usb.h>
 
 #include "zd_def.h"
-#include "zd_types.h"
 
 enum devicetype {
 	DEVICE_ZD1211  = 0,
@@ -181,15 +180,14 @@ struct zd_usb_tx {
 	spinlock_t lock;
 };
 
-/* Contains the usb parts. The structure doesn't require a lock, because intf
- * and fw_base_offset, will not be changed after initialization.
+/* Contains the usb parts. The structure doesn't require a lock because intf
+ * will not be changed after initialization.
  */
 struct zd_usb {
 	struct zd_usb_interrupt intr;
 	struct zd_usb_rx rx;
 	struct zd_usb_tx tx;
 	struct usb_interface *intf;
-	u16 fw_base_offset;
 };
 
 #define zd_usb_dev(usb) (&usb->intf->dev)
