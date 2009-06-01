From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 01/10] crc-itu-t: add bit-reversed calculation
Date: Mon,  1 Jun 2009 18:54:42 +0400
Message-ID: <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	slapin@ossfans.org, maxim.osipov@siemens.com,
	dmitry.baryshkov@siemens.com, oliver.fendt@siemens.com,
	Darren Salt <linux@youmustbejoking.demon.co.uk>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:41670 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbZFAOzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 10:55:13 -0400
In-Reply-To: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Darren Salt <linux@youmustbejoking.demon.co.uk>

Signed-off-by: Darren Salt <linux@youmustbejoking.demon.co.uk>
---
 include/linux/crc-itu-t.h |   10 ++++++++++
 lib/crc-itu-t.c           |   18 ++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/crc-itu-t.h b/include/linux/crc-itu-t.h
index 84920f3..7b2b7ba 100644
--- a/include/linux/crc-itu-t.h
+++ b/include/linux/crc-itu-t.h
@@ -6,6 +6,9 @@
  *   Poly  0x0x1021 (x^16 + x^12 + x^15 + 1)
  *   Init  0
  *
+ * The bit-reversed buffer variants may be non-standard, but some firmware
+ * loaders require them.
+ *
  * This source code is licensed under the GNU General Public License,
  * Version 2. See the file COPYING for more details.
  */
@@ -14,15 +17,22 @@
 #define CRC_ITU_T_H
 
 #include <linux/types.h>
+#include <linux/bitrev.h>
 
 extern u16 const crc_itu_t_table[256];
 
 extern u16 crc_itu_t(u16 crc, const u8 *buffer, size_t len);
+extern u16 crc_itu_t_bitreversed(u16 crc, const u8 *buffer, size_t len);
 
 static inline u16 crc_itu_t_byte(u16 crc, const u8 data)
 {
 	return (crc << 8) ^ crc_itu_t_table[((crc >> 8) ^ data) & 0xff];
 }
 
+static inline u16 crc_itu_t_bitreversed_byte(u16 crc, const u8 data)
+{
+	return (crc << 8) ^ crc_itu_t_table[((crc >> 8) ^ bitrev8(data)) & 0xff];
+}
+
 #endif /* CRC_ITU_T_H */
 
diff --git a/lib/crc-itu-t.c b/lib/crc-itu-t.c
index a63472b..5562fdd 100644
--- a/lib/crc-itu-t.c
+++ b/lib/crc-itu-t.c
@@ -64,6 +64,24 @@ u16 crc_itu_t(u16 crc, const u8 *buffer, size_t len)
 }
 EXPORT_SYMBOL(crc_itu_t);
 
+/**
+ * crc_itu_t_bitreversed - Compute the CRC-ITU-T for the data buffer;
+ * the buffer content is assumed to be bit-reversed
+ *
+ * @crc:     previous CRC value
+ * @buffer:  data pointer
+ * @len:     number of bytes in the buffer
+ *
+ * Returns the updated CRC value
+ */
+u16 crc_itu_t_bitreversed(u16 crc, const u8 *buffer, size_t len)
+{
+	while (len--)
+		crc = crc_itu_t_bitreversed_byte(crc, *buffer++);
+	return crc;
+}
+EXPORT_SYMBOL(crc_itu_t_bitreversed);
+
 MODULE_DESCRIPTION("CRC ITU-T V.41 calculations");
 MODULE_LICENSE("GPL");
 
-- 
1.6.2.4

