From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] eeprom_93cx6 little endian fix
Date: Sat, 3 Feb 2007 14:18:49 +0100
Message-ID: <200702031418.49975.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:47150 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbXBCNTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 08:19:09 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1560690nfa
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 05:19:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes sure the multiread/multiwrite
functions for eeprom_93cx6 work with little endian
data. The singleread still works with host endian.

Most drivers still want the multiread to work with little
endian because this is used for data like the MAC address.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
index 6cbf7c7..4b9be59 100644
--- a/include/linux/eeprom_93cx6.h
+++ b/include/linux/eeprom_93cx6.h
@@ -67,11 +67,11 @@ struct eeprom_93cx6 {
 };
 
 extern void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom,
-	const u8 word, __le16 *data);
+	const u8 word, u16 *data);
 extern void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom,
 	const u8 word, __le16 *data, const u16 words);
 
 extern void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom,
-	const u8 word, __le16 *data);
+	const u8 word, u16 data);
 extern void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom,
 	const u8 word, __le16 *data, const u16 words);
diff --git a/lib/eeprom_93cx6.c b/lib/eeprom_93cx6.c
index 122767e..e5d016b 100644
--- a/lib/eeprom_93cx6.c
+++ b/lib/eeprom_93cx6.c
@@ -203,14 +203,13 @@ static void eeprom_93cx6_ewds(struct eeprom_93cx6 *eeprom)
  * @word: Word index from where we should start reading
  * @data: target pointer where the information will have to be stored
  *
- * This function will read the eeprom data as little endian word
+ * This function will read the eeprom data as host-endian word
  * into the given data pointer.
  */
 void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom, const u8 word,
-	__le16 *data)
+	u16 *data)
 {
 	u16 command;
-	u16 buffer = 0;
 
 	/*
 	 * Initialize the eeprom register
@@ -227,19 +226,12 @@ void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom, const u8 word,
 	/*
 	 * Read the requested 16 bits.
 	 */
-	eeprom_93cx6_read_bits(eeprom, &buffer, 16);
+	eeprom_93cx6_read_bits(eeprom, data, 16);
 
 	/*
 	 * Cleanup eeprom register.
 	 */
 	eeprom_93cx6_cleanup(eeprom);
-
-	/*
-	 * The data from the eeprom is stored as little endian,
-	 * so we don't need to byteorder. To prevent sparse from
-	 * complaining we need to force the type to __le16.
-	 */
-	*data = (__force __le16)buffer;
 }
 EXPORT_SYMBOL_GPL(eeprom_93cx6_read);
 
@@ -252,14 +244,21 @@ EXPORT_SYMBOL_GPL(eeprom_93cx6_read);
  *
  * This function will read all requested words from the eeprom,
  * this is done by calling eeprom_93cx6_read() multiple times.
+ * But with the additional change that while the eeprom_93cx6_read
+ * will return host ordered bytes, this method will return little
+ * endian words.
  */
 void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom, const u8 word,
 	__le16 *data, const u16 words)
 {
 	unsigned int i;
+	u16 tmp;
 
-	for (i = 0; i < words; i++)
-		eeprom_93cx6_read(eeprom, word + i, data++);
+	for (i = 0; i < words; i++) {
+		tmp = 0;
+		eeprom_93cx6_read(eeprom, word + i, &tmp);
+		data[i] = cpu_to_le16(tmp);
+	}
 }
 EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
 
@@ -267,13 +266,13 @@ EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
  * eeprom_93cx6_write - Write multiple words to the eeprom
  * @eeprom: Pointer to eeprom structure
  * @word: Word index from where we should start writing
- * @data: Pointer where the information will be read from
+ * @data: Data that will be written
  *
- * This function will write the eeprom data as little endian word
+ * This function will write the eeprom data as host-endian word
  * from the given data pointer.
  */
 void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom, const u8 word,
-	__le16 *data)
+	u16 data)
 {
 	u16 command;
 
@@ -297,7 +296,7 @@ void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom, const u8 word,
 	/*
 	 * Write the requested 16 bits.
 	 */
-	eeprom_93cx6_write_bits(eeprom, (__force u16)*data, 16);
+	eeprom_93cx6_write_bits(eeprom, data, 16);
 
 	/*
 	 * Cleanup eeprom register.
@@ -331,6 +330,8 @@ EXPORT_SYMBOL_GPL(eeprom_93cx6_write);
  *
  * This function will write all requested words to the eeprom,
  * this is done by calling eeprom_93cx6_write() multiple times.
+ * This method accepts little endian data, so it will first be
+ * converted into host endian.
  */
 void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom, const u8 word,
 	__le16 *data, const u16 words)
@@ -338,6 +339,6 @@ void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom, const u8 word,
 	unsigned int i;
 
 	for (i = 0; i < words; i++)
-		eeprom_93cx6_write(eeprom, word + i, data++);
+		eeprom_93cx6_write(eeprom, word + i, le16_to_cpu(data[i]));
 }
 EXPORT_SYMBOL_GPL(eeprom_93cx6_multiwrite);
