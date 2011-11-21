From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 2/5] eeprom_93cx6: Add write support
Date: Mon, 21 Nov 2011 10:57:57 -0800
Message-ID: <1321901880-12883-3-git-send-email-sboyd@codeaurora.org>
References: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Cc: Ben Dooks <ben@simtec.co.uk>, linux-kernel@vger.kernel.org,
	Sebastien Jan <s-jan@ti.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Jean Delvare <khali@linux-fr.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:18945 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824Ab1KUS6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 13:58:04 -0500
In-Reply-To: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben@simtec.co.uk>

Add support for writing data to EEPROM.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Cc: Wolfram Sang <w.sang@pengutronix.de>
Cc: Jean Delvare <khali@linux-fr.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/misc/eeprom/eeprom_93cx6.c |   85 ++++++++++++++++++++++++++++++++++++
 include/linux/eeprom_93cx6.h       |    6 +++
 2 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/drivers/misc/eeprom/eeprom_93cx6.c b/drivers/misc/eeprom/eeprom_93cx6.c
index a6037af..0ff4b02 100644
--- a/drivers/misc/eeprom/eeprom_93cx6.c
+++ b/drivers/misc/eeprom/eeprom_93cx6.c
@@ -234,3 +234,88 @@ void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom, const u8 word,
 }
 EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
 
+/**
+ * eeprom_93cx6_wren - set the write enable state
+ * @eeprom: Pointer to eeprom structure
+ * @enable: true to enable writes, otherwise disable writes
+ *
+ * Set the EEPROM write enable state to either allow or deny
+ * writes depending on the @enable value.
+ */
+void eeprom_93cx6_wren(struct eeprom_93cx6 *eeprom, bool enable)
+{
+	u16 command;
+
+	/* start the command */
+	eeprom_93cx6_startup(eeprom);
+
+	/* create command to enable/disable */
+
+	command = enable ? PCI_EEPROM_EWEN_OPCODE : PCI_EEPROM_EWDS_OPCODE;
+	command <<= (eeprom->width - 2);
+
+	eeprom_93cx6_write_bits(eeprom, command,
+				PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
+
+	eeprom_93cx6_cleanup(eeprom);
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_wren);
+
+/**
+ * eeprom_93cx6_write - write data to the EEPROM
+ * @eeprom: Pointer to eeprom structure
+ * @addr: Address to write data to.
+ * @data: The data to write to address @addr.
+ *
+ * Write the @data to the specified @addr in the EEPROM and
+ * waiting for the device to finish writing.
+ *
+ * Note, since we do not expect large number of write operations
+ * we delay in between parts of the operation to avoid using excessive
+ * amounts of CPU time busy waiting.
+ */
+void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom, u8 addr, u16 data)
+{
+	int timeout = 100;
+	u16 command;
+
+	/* start the command */
+	eeprom_93cx6_startup(eeprom);
+
+	command = PCI_EEPROM_WRITE_OPCODE << eeprom->width;
+	command |= addr;
+
+	/* send write command */
+	eeprom_93cx6_write_bits(eeprom, command,
+				PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
+
+	/* send data */
+	eeprom_93cx6_write_bits(eeprom, data, 16);
+
+	/* get ready to check for busy */
+	eeprom->drive_data = 0;
+	eeprom->reg_chip_select = 1;
+	eeprom->register_write(eeprom);
+
+	/* wait at-least 250ns to get DO to be the busy signal */
+	usleep_range(1000, 2000);
+
+	/* wait for DO to go high to signify finish */
+
+	while (true) {
+		eeprom->register_read(eeprom);
+
+		if (eeprom->reg_data_out)
+			break;
+
+		usleep_range(1000, 2000);
+
+		if (--timeout <= 0) {
+			printk(KERN_ERR "%s: timeout\n", __func__);
+			break;
+		}
+	}
+
+	eeprom_93cx6_cleanup(eeprom);
+}
+EXPORT_SYMBOL_GPL(eeprom_93cx6_write);
diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
index e04546e..e50f98b 100644
--- a/include/linux/eeprom_93cx6.h
+++ b/include/linux/eeprom_93cx6.h
@@ -33,6 +33,7 @@
 #define PCI_EEPROM_WIDTH_93C86	8
 #define PCI_EEPROM_WIDTH_OPCODE	3
 #define PCI_EEPROM_WRITE_OPCODE	0x05
+#define PCI_EEPROM_ERASE_OPCODE 0x07
 #define PCI_EEPROM_READ_OPCODE	0x06
 #define PCI_EEPROM_EWDS_OPCODE	0x10
 #define PCI_EEPROM_EWEN_OPCODE	0x13
@@ -74,3 +75,8 @@ extern void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom,
 	const u8 word, u16 *data);
 extern void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom,
 	const u8 word, __le16 *data, const u16 words);
+
+extern void eeprom_93cx6_wren(struct eeprom_93cx6 *eeprom, bool enable);
+
+extern void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom,
+			       u8 addr, u16 data);
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
