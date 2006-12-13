From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] eeprom_93cx6: Add write support
Date: Wed, 13 Dec 2006 19:56:50 +0100
Message-ID: <200612131956.51000.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:43392 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965067AbWLMS5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 13:57:01 -0500
Received: by ug-out-1314.google.com with SMTP id 44so257655uga
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 10:57:00 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch addes support for writing to the eeprom,
this also moves some duplicate code into seperate functions.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rNU3 wireless-dev/include/linux/eeprom_93cx6.h wireless-dev-eeprom/include/linux/eeprom_93cx6.h
--- wireless-dev/include/linux/eeprom_93cx6.h	2006-12-13 19:04:44.000000000 +0100
+++ wireless-dev-eeprom/include/linux/eeprom_93cx6.h	2006-12-13 18:28:36.000000000 +0100
@@ -32,6 +32,8 @@
 #define PCI_EEPROM_WIDTH_OPCODE	3
 #define PCI_EEPROM_WRITE_OPCODE	0x05
 #define PCI_EEPROM_READ_OPCODE	0x06
+#define PCI_EEPROM_EWDS_OPCODE	0x10
+#define PCI_EEPROM_EWEN_OPCODE	0x13
 
 /**
  * struct eeprom_93cx6 - control structure for setting the commands
@@ -68,3 +70,8 @@
 	const u8 word, __le16 *data);
 extern void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom,
 	const u8 word, __le16 *data, const u16 words);
+
+extern void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data);
+extern void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom,
+	const u8 word, __le16 *data, const u16 words);
diff -rNU3 wireless-dev/lib/eeprom_93cx6.c wireless-dev-eeprom/lib/eeprom_93cx6.c
--- wireless-dev/lib/eeprom_93cx6.c	2006-12-13 19:04:44.000000000 +0100
+++ wireless-dev-eeprom/lib/eeprom_93cx6.c	2006-12-13 18:50:25.000000000 +0100
@@ -49,6 +49,42 @@
 	udelay(1);
 }
 
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
 static void eeprom_93cx6_write_bits(struct eeprom_93cx6 *eeprom,
 	const u16 data, const u16 count)
 {
@@ -123,6 +159,44 @@
 	}
 }
 
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
 /**
  * eeprom_93cx6_read - Read multiple words from eeprom
  * @eeprom: Pointer to eeprom structure
@@ -139,20 +213,9 @@
 	u16 buffer = 0;
 
 	/*
-	 * Clear all flags, and enable chip select.
+	 * Initialize the eeprom register
 	 */
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
+	eeprom_93cx6_startup(eeprom);
 
 	/*
 	 * Select the read opcode and the word to be read.
@@ -167,18 +230,9 @@
 	eeprom_93cx6_read_bits(eeprom, &buffer, 16);
 
 	/*
-	 * Clear chip_select and data_in flags.
-	 */
-	eeprom->register_read(eeprom);
-	eeprom->reg_data_in = 0;
-	eeprom->reg_chip_select = 0;
-	eeprom->register_write(eeprom);
-
-	/*
-	 * kick a pulse.
+	 * Cleanup eeprom register.
 	 */
-	eeprom_93cx6_pulse_high(eeprom);
-	eeprom_93cx6_pulse_low(eeprom);
+	eeprom_93cx6_cleanup(eeprom);
 
 	/*
 	 * The data from the eeprom is stored as little endian,
@@ -208,3 +262,82 @@
 		eeprom_93cx6_read(eeprom, word + i, data++);
 }
 EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
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
+	eeprom_93cx6_write_bits(eeprom, *data, 16);
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
