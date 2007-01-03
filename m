From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH RESEND 1/4] eeprom_93cx6
Date: Wed, 3 Jan 2007 21:29:35 +0100
Message-ID: <200701032129.35572.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:54978 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbXACUaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 15:30:08 -0500
Received: by nf-out-0910.google.com with SMTP id o25so7801018nfa
        for <netdev@vger.kernel.org>; Wed, 03 Jan 2007 12:30:07 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the eeprom_93cx6 module to the lib folder.
This module provides a generic approach for reading and
writing words from the eeprom chipsets 93c46 and 93c66.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rNU3 wireless-dev/include/linux/eeprom_93cx6.h wireless-dev_eeprom/include/linux/eeprom_93cx6.h
--- wireless-dev/include/linux/eeprom_93cx6.h	1970-01-01 01:00:00.000000000 +0100
+++ wireless-dev_eeprom/include/linux/eeprom_93cx6.h	2006-12-30 16:49:02.000000000 +0100
@@ -0,0 +1,77 @@
+/*
+	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
+	<http://rt2x00.serialmonkey.com>
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	Module: eeprom_93cx6
+	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
+	Supported chipsets: 93c46 & 93c66.
+ */
+
+/*
+ * EEPROM operation defines.
+ */
+#define PCI_EEPROM_WIDTH_93C46	6
+#define PCI_EEPROM_WIDTH_93C66	8
+#define PCI_EEPROM_WIDTH_OPCODE	3
+#define PCI_EEPROM_WRITE_OPCODE	0x05
+#define PCI_EEPROM_READ_OPCODE	0x06
+#define PCI_EEPROM_EWDS_OPCODE	0x10
+#define PCI_EEPROM_EWEN_OPCODE	0x13
+
+/**
+ * struct eeprom_93cx6 - control structure for setting the commands
+ * for reading the eeprom data.
+ * @data: private pointer for the driver.
+ * @register_read(struct eeprom_93cx6 *eeprom): handler to
+ * read the eeprom register, this function should set all reg_* fields.
+ * @register_write(struct eeprom_93cx6 *eeprom): handler to
+ * write to the eeprom register by using all reg_* fields.
+ * @width: eeprom width, should be one of the PCI_EEPROM_WIDTH_* defines
+ * @reg_data_in: register field to indicate data input
+ * @reg_data_out: register field to indicate data output
+ * @reg_data_clock: register field to set the data clock
+ * @reg_chip_select: register field to set the chip select
+ *
+ * This structure is used for the communication between the driver
+ * and the eeprom_93cx6 handlers for reading the eeprom.
+ */
+struct eeprom_93cx6 {
+	void *data;
+
+	void (*register_read)(struct eeprom_93cx6 *eeprom);
+	void (*register_write)(struct eeprom_93cx6 *eeprom);
+
+	int width;
+
+	char reg_data_in;
+	char reg_data_out;
+	char reg_data_clock;
+	char reg_chip_select;
+};
+
+extern void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data);
+extern void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data, const u16 words);
+
+extern void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data);
+extern void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data, const u16 words);
diff -rNU3 wireless-dev/lib/Kconfig wireless-dev_eeprom/lib/Kconfig
--- wireless-dev/lib/Kconfig	2007-01-03 20:54:00.000000000 +0100
+++ wireless-dev_eeprom/lib/Kconfig	2007-01-03 21:04:42.000000000 +0100
@@ -38,6 +38,14 @@
 	  require M here.  See Castagnoli93.
 	  Module will be libcrc32c.
 
+config EEPROM_93CX6
+	tristate "EEPROM 93CX6 support"
+	---help---
+	This is a driver for the EEPROM chipsets 93c46 and 93c66.
+	The driver supports both read as well as write commands.
+
+	When compiled as a module, this driver will be called "eeprom_93c6.ko".
+
 config AUDIT_GENERIC
 	bool
 	depends on AUDIT && !AUDIT_ARCH
diff -rNU3 wireless-dev/lib/Makefile wireless-dev_eeprom/lib/Makefile
--- wireless-dev/lib/Makefile	2007-01-03 20:54:00.000000000 +0100
+++ wireless-dev_eeprom/lib/Makefile	2007-01-03 21:05:01.000000000 +0100
@@ -53,6 +53,8 @@
 obj-$(CONFIG_SMP) += percpu_counter.o
 obj-$(CONFIG_AUDIT_GENERIC) += audit.o
 
+obj-$(CONFIG_EEPROM_93CX6) += eeprom_93cx6.o
+
 obj-$(CONFIG_SWIOTLB) += swiotlb.o
 
 hostprogs-y	:= gen_crc32table
diff -rNU3 wireless-dev/lib/eeprom_93cx6.c wireless-dev_eeprom/lib/eeprom_93cx6.c
--- wireless-dev/lib/eeprom_93cx6.c	1970-01-01 01:00:00.000000000 +0100
+++ wireless-dev_eeprom/lib/eeprom_93cx6.c	2006-12-30 16:49:02.000000000 +0100
@@ -0,0 +1,343 @@
+/*
+	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
+	<http://rt2x00.serialmonkey.com>
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	Module: eeprom_93cx6
+	Abstract: EEPROM reader routines for 93cx6 chipsets.
+	Supported chipsets: 93c46 & 93c66.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/delay.h>
+#include <linux/eeprom_93cx6.h>
+
+MODULE_AUTHOR("http://rt2x00.serialmonkey.com");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("EEPROM 93cx6 chip driver");
+MODULE_LICENSE("GPL");
+
+static inline void eeprom_93cx6_pulse_high(struct eeprom_93cx6 *eeprom)
+{
+	eeprom->reg_data_clock = 1;
+	eeprom->register_write(eeprom);
+	udelay(1);
+}
+
+static inline void eeprom_93cx6_pulse_low(struct eeprom_93cx6 *eeprom)
+{
+	eeprom->reg_data_clock = 0;
+	eeprom->register_write(eeprom);
+	udelay(1);
+}
+
+static void eeprom_93cx6_startup(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Clear all flags, and enable chip select.
+	 */
+	eeprom->register_read(eeprom);
+	eeprom->reg_data_in = 0;
+	eeprom->reg_data_out = 0;
+	eeprom->reg_data_clock = 0;
+	eeprom->reg_chip_select = 1;
+	eeprom->register_write(eeprom);
+
+	/*
+	 * kick a pulse.
+	 */
+	eeprom_93cx6_pulse_high(eeprom);
+	eeprom_93cx6_pulse_low(eeprom);
+}
+
+static void eeprom_93cx6_cleanup(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Clear chip_select and data_in flags.
+	 */
+	eeprom->register_read(eeprom);
+	eeprom->reg_data_in = 0;
+	eeprom->reg_chip_select = 0;
+	eeprom->register_write(eeprom);
+
+	/*
+	 * kick a pulse.
+	 */
+	eeprom_93cx6_pulse_high(eeprom);
+	eeprom_93cx6_pulse_low(eeprom);
+}
+
+static void eeprom_93cx6_write_bits(struct eeprom_93cx6 *eeprom,
+	const u16 data, const u16 count)
+{
+	unsigned int i;
+
+	eeprom->register_read(eeprom);
+
+	/*
+	 * Clear data flags.
+	 */
+	eeprom->reg_data_in = 0;
+	eeprom->reg_data_out = 0;
+
+	/*
+	 * Start writing all bits.
+	 */
+	for (i = count; i > 0; i--) {
+		/*
+		 * Check if this bit needs to be set.
+		 */
+		eeprom->reg_data_in = !!(data & (1 << (i - 1)));
+
+		/*
+		 * Write the bit to the eeprom register.
+		 */
+		eeprom->register_write(eeprom);
+
+		/*
+		 * Kick a pulse.
+		 */
+		eeprom_93cx6_pulse_high(eeprom);
+		eeprom_93cx6_pulse_low(eeprom);
+	}
+
+	eeprom->reg_data_in = 0;
+	eeprom->register_write(eeprom);
+}
+
+static void eeprom_93cx6_read_bits(struct eeprom_93cx6 *eeprom,
+	u16 *data, const u16 count)
+{
+	unsigned int i;
+
+	eeprom->register_read(eeprom);
+
+	/*
+	 * Clear data flags.
+	 */
+	eeprom->reg_data_in = 0;
+	eeprom->reg_data_out = 0;
+
+	/*
+	 * Start reading all bits.
+	 */
+	for (i = count; i > 0; i--) {
+		eeprom_93cx6_pulse_high(eeprom);
+
+		eeprom->register_read(eeprom);
+
+		/*
+		 * Clear data_in flag.
+		 */
+		eeprom->reg_data_in = 0;
+
+		/*
+		 * Read if the bit has been set.
+		 */
+		if (eeprom->reg_data_out)
+			*data |= (1 << (i - 1));
+
+		eeprom_93cx6_pulse_low(eeprom);
+	}
+}
+
+static void eeprom_93cx6_ewen(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the read opcode and the word to be read.
+	 */
+	eeprom_93cx6_write_bits(eeprom, PCI_EEPROM_EWEN_OPCODE, 5);
+	eeprom_93cx6_write_bits(eeprom, 0, 6);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+}
+
+static void eeprom_93cx6_ewds(struct eeprom_93cx6 *eeprom)
+{
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the read opcode and the word to be read.
+	 */
+	eeprom_93cx6_write_bits(eeprom, PCI_EEPROM_EWDS_OPCODE, 5);
+	eeprom_93cx6_write_bits(eeprom, 0, 6);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+}
+
+/**
+ * eeprom_93cx6_read - Read multiple words from eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start reading
+ * @data: target pointer where the information will have to be stored
+ *
+ * This function will read the eeprom data as little endian word
+ * into the given data pointer.
+ */
+void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom, const u8 word,
+	__le16 *data)
+{
+	u16 command;
+	u16 buffer = 0;
+
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the read opcode and the word to be read.
+	 */
+	command = (PCI_EEPROM_READ_OPCODE << eeprom->width) | word;
+	eeprom_93cx6_write_bits(eeprom, command,
+		PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
+
+	/*
+	 * Read the requested 16 bits.
+	 */
+	eeprom_93cx6_read_bits(eeprom, &buffer, 16);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+
+	/*
+	 * The data from the eeprom is stored as little endian,
+	 * so we don't need to byteorder. To prevent sparse from
+	 * complaining we need to force the type to __le16.
+	 */
+	*data = (__force __le16)buffer;
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_read);
+
+/**
+ * eeprom_93cx6_multiread - Read multiple words from eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start reading
+ * @data: target pointer where the information will have to be stored
+ * @words: Number of words that should be read.
+ *
+ * This function will read all requested words from the eeprom,
+ * this is done by calling eeprom_93cx6_read() multiple times.
+ */
+void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom, const u8 word,
+	__le16 *data, const u16 words)
+{
+	unsigned int i;
+
+	for (i = 0; i < words; i++)
+		eeprom_93cx6_read(eeprom, word + i, data++);
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
+
+/**
+ * eeprom_93cx6_write - Write multiple words to the eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start writing
+ * @data: Pointer where the information will be read from
+ *
+ * This function will write the eeprom data as little endian word
+ * from the given data pointer.
+ */
+void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom, const u8 word,
+	__le16 *data)
+{
+	u16 command;
+
+	/*
+	 * select the ewen opcode.
+	 */
+	eeprom_93cx6_ewen(eeprom);
+
+	/*
+	 * Initialize the eeprom register
+	 */
+	eeprom_93cx6_startup(eeprom);
+
+	/*
+	 * Select the write opcode and the word to be read.
+	 */
+	command = (PCI_EEPROM_WRITE_OPCODE << eeprom->width) | word;
+	eeprom_93cx6_write_bits(eeprom, command,
+		PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
+
+	/*
+	 * Write the requested 16 bits.
+	 */
+	eeprom_93cx6_write_bits(eeprom, (__force u16)*data, 16);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+
+	/*
+	 * Take a short break.
+	 */
+	msleep(10000);
+
+	/*
+	 * select the ewen opcode.
+	 */
+	eeprom_93cx6_ewds(eeprom);
+
+	/*
+	 * Cleanup eeprom register.
+	 */
+	eeprom_93cx6_cleanup(eeprom);
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_write);
+
+
+/**
+ * eeprom_93cx6_multiwrite - Write multiple words to the eeprom
+ * @eeprom: Pointer to eeprom structure
+ * @word: Word index from where we should start writing
+ * @data: Pointer where the information will be read from
+ * @words: Number of words that should be written.
+ *
+ * This function will write all requested words to the eeprom,
+ * this is done by calling eeprom_93cx6_write() multiple times.
+ */
+void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom, const u8 word,
+	__le16 *data, const u16 words)
+{
+	unsigned int i;
+
+	for (i = 0; i < words; i++)
+		eeprom_93cx6_write(eeprom, word + i, data++);
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_multiwrite);
