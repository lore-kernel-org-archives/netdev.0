From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 37/52] sfc: Rework the bitfield header so that we can identify fields by bit number
Date: Mon, 1 Sep 2008 12:48:55 +0100
Message-ID: <20080901114854.GE7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42041 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758820AbYIALs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:58 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will support register self-tests.

From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/bitfield.h      |  159 +++++++++++++++++++++++----------------
 drivers/net/sfc/falcon_hwdefs.h |    4 +-
 2 files changed, 95 insertions(+), 68 deletions(-)

diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index 2c79d27..b757a39 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -52,9 +52,9 @@
  *
  * The maximum width mask that can be generated is 64 bits.
  */
-#define EFX_MASK64(field)					\
-	(EFX_WIDTH(field) == 64 ? ~((u64) 0) :		\
-	 (((((u64) 1) << EFX_WIDTH(field))) - 1))
+#define EFX_MASK64(width)			\
+	((width) == 64 ? ~((u64) 0) :		\
+	 (((((u64) 1) << (width))) - 1))
 
 /* Mask equal in width to the specified field.
  *
@@ -63,9 +63,9 @@
  * The maximum width mask that can be generated is 32 bits.  Use
  * EFX_MASK64 for higher width fields.
  */
-#define EFX_MASK32(field)					\
-	(EFX_WIDTH(field) == 32 ? ~((u32) 0) :		\
-	 (((((u32) 1) << EFX_WIDTH(field))) - 1))
+#define EFX_MASK32(width)			\
+	((width) == 32 ? ~((u32) 0) :		\
+	 (((((u32) 1) << (width))) - 1))
 
 /* A doubleword (i.e. 4 byte) datatype - little-endian in HW */
 typedef union efx_dword {
@@ -138,44 +138,49 @@ typedef union efx_oword {
 	EFX_EXTRACT_NATIVE(le32_to_cpu(element), min, max, low, high)
 
 #define EFX_EXTRACT_OWORD64(oword, low, high)				\
-	(EFX_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
-	 EFX_EXTRACT64((oword).u64[1], 64, 127, low, high))
+	((EFX_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
+	  EFX_EXTRACT64((oword).u64[1], 64, 127, low, high)) &		\
+	 EFX_MASK64(high + 1 - low))
 
 #define EFX_EXTRACT_QWORD64(qword, low, high)				\
-	EFX_EXTRACT64((qword).u64[0], 0, 63, low, high)
+	(EFX_EXTRACT64((qword).u64[0], 0, 63, low, high) &		\
+	 EFX_MASK64(high + 1 - low))
 
 #define EFX_EXTRACT_OWORD32(oword, low, high)				\
-	(EFX_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
-	 EFX_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
-	 EFX_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
-	 EFX_EXTRACT32((oword).u32[3], 96, 127, low, high))
+	((EFX_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
+	  EFX_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
+	  EFX_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
+	  EFX_EXTRACT32((oword).u32[3], 96, 127, low, high)) &		\
+	 EFX_MASK32(high + 1 - low))
 
 #define EFX_EXTRACT_QWORD32(qword, low, high)				\
-	(EFX_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
-	 EFX_EXTRACT32((qword).u32[1], 32, 63, low, high))
+	((EFX_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
+	  EFX_EXTRACT32((qword).u32[1], 32, 63, low, high)) &		\
+	 EFX_MASK32(high + 1 - low))
 
-#define EFX_EXTRACT_DWORD(dword, low, high)				\
-	EFX_EXTRACT32((dword).u32[0], 0, 31, low, high)
+#define EFX_EXTRACT_DWORD(dword, low, high)			\
+	(EFX_EXTRACT32((dword).u32[0], 0, 31, low, high) &	\
+	 EFX_MASK32(high + 1 - low))
 
-#define EFX_OWORD_FIELD64(oword, field)					\
-	(EFX_EXTRACT_OWORD64(oword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
-	 & EFX_MASK64(field))
+#define EFX_OWORD_FIELD64(oword, field)				\
+	EFX_EXTRACT_OWORD64(oword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
 
-#define EFX_QWORD_FIELD64(qword, field)					\
-	(EFX_EXTRACT_QWORD64(qword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
-	 & EFX_MASK64(field))
+#define EFX_QWORD_FIELD64(qword, field)				\
+	EFX_EXTRACT_QWORD64(qword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
 
-#define EFX_OWORD_FIELD32(oword, field)					\
-	(EFX_EXTRACT_OWORD32(oword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
-	 & EFX_MASK32(field))
+#define EFX_OWORD_FIELD32(oword, field)				\
+	EFX_EXTRACT_OWORD32(oword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
 
-#define EFX_QWORD_FIELD32(qword, field)					\
-	(EFX_EXTRACT_QWORD32(qword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
-	 & EFX_MASK32(field))
+#define EFX_QWORD_FIELD32(qword, field)				\
+	EFX_EXTRACT_QWORD32(qword, EFX_LOW_BIT(field),		\
+			    EFX_HIGH_BIT(field))
 
-#define EFX_DWORD_FIELD(dword, field)					   \
-	(EFX_EXTRACT_DWORD(dword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
-	 & EFX_MASK32(field))
+#define EFX_DWORD_FIELD(dword, field)				\
+	EFX_EXTRACT_DWORD(dword, EFX_LOW_BIT(field),		\
+			  EFX_HIGH_BIT(field))
 
 #define EFX_OWORD_IS_ZERO64(oword)					\
 	(((oword).u64[0] | (oword).u64[1]) == (__force __le64) 0)
@@ -417,63 +422,85 @@ typedef union efx_oword {
 	(oword).u64[1] = ~((oword).u64[1]);	\
 	} while (0)
 
-#define EFX_INSERT_FIELD64(...)					\
-	cpu_to_le64(EFX_INSERT_FIELD_NATIVE(__VA_ARGS__))
+#define EFX_INSERT64(min, max, low, high, value)			\
+	cpu_to_le64(EFX_INSERT_NATIVE(min, max, low, high, value))
 
-#define EFX_INSERT_FIELD32(...)					\
-	cpu_to_le32(EFX_INSERT_FIELD_NATIVE(__VA_ARGS__))
+#define EFX_INSERT32(min, max, low, high, value)			\
+	cpu_to_le32(EFX_INSERT_NATIVE(min, max, low, high, value))
 
-#define EFX_INPLACE_MASK64(min, max, field)			\
-	EFX_INSERT_FIELD64(min, max, field, EFX_MASK64(field))
+#define EFX_INPLACE_MASK64(min, max, low, high)				\
+	EFX_INSERT64(min, max, low, high, EFX_MASK64(high + 1 - low))
 
-#define EFX_INPLACE_MASK32(min, max, field)			\
-	EFX_INSERT_FIELD32(min, max, field, EFX_MASK32(field))
+#define EFX_INPLACE_MASK32(min, max, low, high)				\
+	EFX_INSERT32(min, max, low, high, EFX_MASK32(high + 1 - low))
 
-#define EFX_SET_OWORD_FIELD64(oword, field, value) do {			\
+#define EFX_SET_OWORD64(oword, low, high, value) do {			\
 	(oword).u64[0] = (((oword).u64[0] 				\
-			   & ~EFX_INPLACE_MASK64(0,  63, field))	\
-			  | EFX_INSERT_FIELD64(0,  63, field, value));  \
+			   & ~EFX_INPLACE_MASK64(0,  63, low, high))	\
+			  | EFX_INSERT64(0,  63, low, high, value));	\
 	(oword).u64[1] = (((oword).u64[1] 				\
-			   & ~EFX_INPLACE_MASK64(64, 127, field))	\
-			  | EFX_INSERT_FIELD64(64, 127, field, value)); \
+			   & ~EFX_INPLACE_MASK64(64, 127, low, high))	\
+			  | EFX_INSERT64(64, 127, low, high, value));	\
 	} while (0)
 
-#define EFX_SET_QWORD_FIELD64(qword, field, value) do {			\
+#define EFX_SET_QWORD64(qword, low, high, value) do {			\
 	(qword).u64[0] = (((qword).u64[0] 				\
-			   & ~EFX_INPLACE_MASK64(0, 63, field))		\
-			  | EFX_INSERT_FIELD64(0, 63, field, value));	\
+			   & ~EFX_INPLACE_MASK64(0, 63, low, high))	\
+			  | EFX_INSERT64(0, 63, low, high, value));	\
 	} while (0)
 
-#define EFX_SET_OWORD_FIELD32(oword, field, value) do {			\
+#define EFX_SET_OWORD32(oword, low, high, value) do {			\
 	(oword).u32[0] = (((oword).u32[0] 				\
-			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
-			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+			   & ~EFX_INPLACE_MASK32(0, 31, low, high))	\
+			  | EFX_INSERT32(0, 31, low, high, value));	\
 	(oword).u32[1] = (((oword).u32[1] 				\
-			   & ~EFX_INPLACE_MASK32(32, 63, field))	\
-			  | EFX_INSERT_FIELD32(32, 63, field, value));	\
+			   & ~EFX_INPLACE_MASK32(32, 63, low, high))	\
+			  | EFX_INSERT32(32, 63, low, high, value));	\
 	(oword).u32[2] = (((oword).u32[2] 				\
-			   & ~EFX_INPLACE_MASK32(64, 95, field))	\
-			  | EFX_INSERT_FIELD32(64, 95, field, value));	\
+			   & ~EFX_INPLACE_MASK32(64, 95, low, high))	\
+			  | EFX_INSERT32(64, 95, low, high, value));	\
 	(oword).u32[3] = (((oword).u32[3] 				\
-			   & ~EFX_INPLACE_MASK32(96, 127, field))	\
-			  | EFX_INSERT_FIELD32(96, 127, field, value));	\
+			   & ~EFX_INPLACE_MASK32(96, 127, low, high))	\
+			  | EFX_INSERT32(96, 127, low, high, value));	\
 	} while (0)
 
-#define EFX_SET_QWORD_FIELD32(qword, field, value) do {			\
+#define EFX_SET_QWORD32(qword, low, high, value) do {			\
 	(qword).u32[0] = (((qword).u32[0] 				\
-			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
-			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+			   & ~EFX_INPLACE_MASK32(0, 31, low, high))	\
+			  | EFX_INSERT32(0, 31, low, high, value));	\
 	(qword).u32[1] = (((qword).u32[1] 				\
-			   & ~EFX_INPLACE_MASK32(32, 63, field))	\
-			  | EFX_INSERT_FIELD32(32, 63, field, value));	\
+			   & ~EFX_INPLACE_MASK32(32, 63, low, high))	\
+			  | EFX_INSERT32(32, 63, low, high, value));	\
 	} while (0)
 
-#define EFX_SET_DWORD_FIELD(dword, field, value) do {			\
-	(dword).u32[0] = (((dword).u32[0] 				\
-			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
-			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+#define EFX_SET_DWORD32(dword, low, high, value) do {			\
+	(dword).u32[0] = (((dword).u32[0]				\
+			   & ~EFX_INPLACE_MASK32(0, 31, low, high))	\
+			  | EFX_INSERT32(0, 31, low, high, value));	\
 	} while (0)
 
+#define EFX_SET_OWORD_FIELD64(oword, field, value)			\
+	EFX_SET_OWORD64(oword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_QWORD_FIELD64(qword, field, value)			\
+	EFX_SET_QWORD64(qword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_OWORD_FIELD32(oword, field, value)			\
+	EFX_SET_OWORD32(oword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_QWORD_FIELD32(qword, field, value)			\
+	EFX_SET_QWORD32(qword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+#define EFX_SET_DWORD_FIELD(dword, field, value)			\
+	EFX_SET_DWORD32(dword, EFX_LOW_BIT(field),			\
+			 EFX_HIGH_BIT(field), value)
+
+
+
 #if BITS_PER_LONG == 64
 #define EFX_SET_OWORD_FIELD EFX_SET_OWORD_FIELD64
 #define EFX_SET_QWORD_FIELD EFX_SET_QWORD_FIELD64
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 7c784f7..a3260df 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -1147,8 +1147,8 @@ struct falcon_nvconfig_board_v3 {
 #define SPI_DEV_TYPE_ERASE_SIZE_WIDTH 5
 #define SPI_DEV_TYPE_BLOCK_SIZE_LBN 24
 #define SPI_DEV_TYPE_BLOCK_SIZE_WIDTH 5
-#define SPI_DEV_TYPE_FIELD(type, field) \
-	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(field))
+#define SPI_DEV_TYPE_FIELD(type, field)					\
+	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
 
 #define NVCONFIG_BASE 0x300
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

