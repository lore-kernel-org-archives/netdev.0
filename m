From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH RESEND 2/4] rt2x00 should use generic eeprom_93cx6
Date: Wed, 3 Jan 2007 21:29:36 +0100
Message-ID: <200701032129.36114.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:55122 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086AbXACUaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 15:30:09 -0500
Received: by nf-out-0910.google.com with SMTP id o25so7801012nfa
        for <netdev@vger.kernel.org>; Wed, 03 Jan 2007 12:30:08 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the eeprom_93cx6 files from rt2x00
and makes sure rt2x00 will use the generic eeprom_93cx6
implementation inside the lib folder.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rNU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/Kconfig
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig	2007-01-03 20:53:57.000000000 +0100
+++ wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/Kconfig	2007-01-03 21:02:41.000000000 +0100
@@ -82,15 +82,6 @@
 	---help---
 	Enable debugging output.
 
-config EEPROM_93CX6
-	tristate "EEPROM 93CX6 support"
-	depends on RT2x00
-	---help---
-	This is an experimental driver for EEPROM chipsets 93c46 and 93c66.
-	These chipsets are found inside the Ralink wireless cards.
-
-	When compiled as a module, this driver will be called "eeprom_93c6.ko".
-
 config CRC_ITU_T
 	tristate "CRC ITU-T V.41 functions"
 	help
diff -rNU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/Makefile wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/Makefile
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/Makefile	2007-01-03 20:53:57.000000000 +0100
+++ wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/Makefile	2007-01-03 21:08:49.000000000 +0100
@@ -4,4 +4,3 @@
 obj-$(CONFIG_RT2500USB)		+= rt2500usb.o
 obj-$(CONFIG_RT73USB)		+= rt73usb.o
 obj-$(CONFIG_CRC_ITU_T)		+= crc-itu-t.o
-obj-$(CONFIG_EEPROM_93CX6)	+= eeprom_93cx6.o
diff -rNU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.c wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.c
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.c	2007-01-03 20:53:57.000000000 +0100
+++ wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.c	1970-01-01 01:00:00.000000000 +0100
@@ -1,189 +0,0 @@
-/*
-	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
-	<http://rt2x00.serialmonkey.com>
-
-	This program is free software; you can redistribute it and/or modify
-	it under the terms of the GNU General Public License as published by
-	the Free Software Foundation; either version 2 of the License, or
-	(at your option) any later version.
-
-	This program is distributed in the hope that it will be useful,
-	but WITHOUT ANY WARRANTY; without even the implied warranty of
-	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-	GNU General Public License for more details.
-
-	You should have received a copy of the GNU General Public License
-	along with this program; if not, write to the
-	Free Software Foundation, Inc.,
-	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
- */
-
-/*
-	Module: eeprom_93cx6
-	Abstract: EEPROM reader routines for 93cx6 chipsets.
-	Supported chipsets: 93c46 & 93c66.
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/version.h>
-#include <linux/delay.h>
-
-#include "eeprom_93cx6.h"
-
-MODULE_AUTHOR("http://rt2x00.serialmonkey.com");
-MODULE_DESCRIPTION("EEPROM 93cx6 chip driver");
-MODULE_LICENSE("GPL");
-
-static inline void eeprom_93cx6_pulse_high(struct eeprom_93cx6 *eeprom)
-{
-	eeprom->reg_data_clock = 1;
-	eeprom->register_write(eeprom);
-	udelay(1);
-}
-
-static inline void eeprom_93cx6_pulse_low(struct eeprom_93cx6 *eeprom)
-{
-	eeprom->reg_data_clock = 0;
-	eeprom->register_write(eeprom);
-	udelay(1);
-}
-
-static void eeprom_93cx6_write_bits(struct eeprom_93cx6 *eeprom,
-	const u16 data, const u16 count)
-{
-	unsigned int i;
-
-	eeprom->register_read(eeprom);
-
-	/*
-	 * Clear data flags.
-	 */
-	eeprom->reg_data_in = 0;
-	eeprom->reg_data_out = 0;
-
-	/*
-	 * Start writing all bits.
-	 */
-	for (i = count; i > 0; i--) {
-		/*
-		 * Check if this bit needs to be set.
-		 */
-		eeprom->reg_data_in = !!(data & (1 << (i - 1)));
-
-		/*
-		 * Write the bit to the eeprom register.
-		 */
-		eeprom->register_write(eeprom);
-
-		/*
-		 * Kick a pulse.
-		 */
-		eeprom_93cx6_pulse_high(eeprom);
-		eeprom_93cx6_pulse_low(eeprom);
-	}
-
-	eeprom->reg_data_in = 0;
-	eeprom->register_write(eeprom);
-}
-
-static void eeprom_93cx6_read_bits(struct eeprom_93cx6 *eeprom,
-	u16 *data, const u16 count)
-{
-	unsigned int i;
-
-	eeprom->register_read(eeprom);
-
-	/*
-	 * Clear data flags.
-	 */
-	eeprom->reg_data_in = 0;
-	eeprom->reg_data_out = 0;
-
-	/*
-	 * Start reading all bits.
-	 */
-	for (i = count; i > 0; i--) {
-		eeprom_93cx6_pulse_high(eeprom);
-
-		eeprom->register_read(eeprom);
-
-		/*
-		 * Clear data_in flag.
-		 */
-		eeprom->reg_data_in = 0;
-
-		/*
-		 * Read if the bit has been set.
-		 */
-		if (eeprom->reg_data_out)
-			*data |= (1 << (i - 1));
-
-		eeprom_93cx6_pulse_low(eeprom);
-	}
-}
-
-void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom, const u8 word,
-	__le16 *data)
-{
-	u16 buffer = 0;
-
-	/*
-	 * Clear all flags, and enable chip select.
-	 */
-	eeprom->register_read(eeprom);
-	eeprom->reg_data_in = 0;
-	eeprom->reg_data_out = 0;
-	eeprom->reg_data_clock = 0;
-	eeprom->reg_chip_select = 1;
-	eeprom->register_write(eeprom);
-
-	/*
-	 * kick a pulse.
-	 */
-	eeprom_93cx6_pulse_high(eeprom);
-	eeprom_93cx6_pulse_low(eeprom);
-
-	/*
-	 * Select the read opcode and the word to be read.
-	 */
-	eeprom_93cx6_write_bits(eeprom, PCI_EEPROM_READ_OPCODE, 3);
-	eeprom_93cx6_write_bits(eeprom, word, eeprom->width);
-
-	/*
-	 * Read the requested 16 bits.
-	 */
-	eeprom_93cx6_read_bits(eeprom, &buffer, 16);
-
-	/*
-	 * Clear chip_select and data_in flags.
-	 */
-	eeprom->register_read(eeprom);
-	eeprom->reg_data_in = 0;
-	eeprom->reg_chip_select = 0;
-	eeprom->register_write(eeprom);
-
-	/*
-	 * kick a pulse.
-	 */
-	eeprom_93cx6_pulse_high(eeprom);
-	eeprom_93cx6_pulse_low(eeprom);
-
-	/*
-	 * The data from the eeprom is stored as little endian,
-	 * so we don't need to byteorder. To prevent sparse from
-	 * complaining we need to force the type to __le16.
-	 */
-	*data = (__force __le16)buffer;
-}
-EXPORT_SYMBOL_GPL(eeprom_93cx6_read);
-
-void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom, const u8 word,
-	__le16 *data, const u16 words)
-{
-	unsigned int i;
-
-	for (i = 0; i < words; i++)
-		eeprom_93cx6_read(eeprom, word + i, data++);
-}
-EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
diff -rNU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.h wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.h
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.h	2007-01-03 20:53:57.000000000 +0100
+++ wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/eeprom_93cx6.h	1970-01-01 01:00:00.000000000 +0100
@@ -1,90 +0,0 @@
-/*
-	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
-	<http://rt2x00.serialmonkey.com>
-
-	This program is free software; you can redistribute it and/or modify
-	it under the terms of the GNU General Public License as published by
-	the Free Software Foundation; either version 2 of the License, or
-	(at your option) any later version.
-
-	This program is distributed in the hope that it will be useful,
-	but WITHOUT ANY WARRANTY; without even the implied warranty of
-	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-	GNU General Public License for more details.
-
-	You should have received a copy of the GNU General Public License
-	along with this program; if not, write to the
-	Free Software Foundation, Inc.,
-	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
- */
-
-/*
-	Module: eeprom_93cx6
-	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
-	Supported chipsets: 93c46 & 93c66.
- */
-
-/*
- * EEPROM operation defines.
- */
-#define PCI_EEPROM_WIDTH_93C46	6
-#define PCI_EEPROM_WIDTH_93C66	8
-#define PCI_EEPROM_WRITE_OPCODE	0x05
-#define PCI_EEPROM_READ_OPCODE	0x06
-
-/**
- * struct eeprom_93cx6 - control structure for setting the commands
- * for reading the eeprom data.
- *
- * @data: private pointer for the driver.
- * @register_read(struct eeprom_93cx6 *eeprom): handler to
- * read the eeprom register, this function should set all reg_* fields.
- * @register_write(struct eeprom_93cx6 *eeprom): handler to
- * write to the eeprom register by using all reg_* fields.
- * @width: eeprom width, should be one of the PCI_EEPROM_WIDTH_* defines
- * @reg_data_in: register field to indicate data input
- * @reg_data_out: register field to indicate data output
- * @reg_data_clock: register field to set the data clock
- * @reg_chip_select: register field to set the chip select
- *
- * This structure is used for the communication between the driver
- * and the eeprom_93cx6 handlers for reading the eeprom.
- */
-struct eeprom_93cx6 {
-	void *data;
-
-	void (*register_read)(struct eeprom_93cx6 *eeprom);
-	void (*register_write)(struct eeprom_93cx6 *eeprom);
-
-	int width;
-
-	char reg_data_in;
-	char reg_data_out;
-	char reg_data_clock;
-	char reg_chip_select;
-};
-
-/**
- * eeprom_93cx6_read - Read multiple words from eeprom
- * @eeprom: Pointer to eeprom structure
- * @word: Word index from where we should start reading
- * @data: target pointer where the information will have to be stored
- *
- * This function will read the eeprom data as little endian word
- * into the given data pointer.
- */
-extern void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom,
-	const u8 word, __le16 *data);
-
-/**
- * eeprom_93cx6_multiread - Read multiple words from eeprom
- * @eeprom: Pointer to eeprom structure
- * @word: Word index from where we should start reading
- * @data: target pointer where the information will have to be stored
- * @words: Number of words that should be read.
- *
- * This function will read all requested words from the eeprom,
- * this is done by calling eeprom_93cx6_read() multiple times.
- */
-extern void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom,
-	const u8 word, __le16 *data, const u16 words);
diff -rNU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2007-01-03 20:53:57.000000000 +0100
+++ wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2007-01-03 21:03:30.000000000 +0100
@@ -35,6 +35,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -53,7 +54,6 @@
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2400pci.h"
-#include "eeprom_93cx6.h"
 
 /*
  * Register access.
diff -rNU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2007-01-03 20:53:57.000000000 +0100
+++ wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2007-01-03 21:03:28.000000000 +0100
@@ -35,6 +35,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -53,7 +54,6 @@
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2500pci.h"
-#include "eeprom_93cx6.h"
 
 /*
  * Register access.
diff -rNU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2007-01-03 20:53:57.000000000 +0100
+++ wireless-dev_eeprom/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2007-01-03 21:03:29.000000000 +0100
@@ -35,6 +35,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/eeprom_93cx6.h>
 #include <linux/firmware.h>
 
 #include <net/iw_handler.h>
@@ -55,7 +56,6 @@
 #include "rt2x00pci.h"
 #include "rt61pci.h"
 #include "crc-itu-t.h"
-#include "eeprom_93cx6.h"
 
 /*
  * Register access.
