From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/14] tg3: Invert nvram_read() and nvram_read_swab()
Date: Wed, 25 Feb 2009 16:25:00 -0800
Message-ID: <1235616373.16010@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1837 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912AbZBZCq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the blind byteswap of NVRAM data as it is read in.
To preserve the logic at the call sites, this patch also inverts every
call to tg3_nvram_read() and tg3_nvram_read_swab().  The call swap gets
confusing within tg3_nvram_read_le() (LE is a misnomer), but the reader
should be able to convince himself / herself that the resulting behavior
is still unchanged.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   50 ++++++++++++++++++++++++++++----------------------
 1 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d32b3ef..a2ca6ab 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2245,6 +2245,12 @@ static u32 tg3_nvram_logical_addr(struct tg3 *tp, u32 addr)
 	return addr;
 }
 
+/* NOTE: Data read in from NVRAM is byteswapped according to
+ * the byteswapping settings for all other register accesses.
+ * tg3 devices are BE devices, so on a BE machine, the data
+ * returned will be exactly as it is seen in NVRAM.  On a LE
+ * machine, the 32-bit value will be byteswapped.
+ */
 static int tg3_nvram_read(struct tg3 *tp, u32 offset, u32 *val)
 {
 	int ret;
@@ -2268,7 +2274,7 @@ static int tg3_nvram_read(struct tg3 *tp, u32 offset, u32 *val)
 		NVRAM_CMD_FIRST | NVRAM_CMD_LAST | NVRAM_CMD_DONE);
 
 	if (ret == 0)
-		*val = swab32(tr32(NVRAM_RDDATA));
+		*val = tr32(NVRAM_RDDATA);
 
 	tg3_disable_nvram_access(tp);
 
@@ -2290,7 +2296,7 @@ static int tg3_nvram_read_swab(struct tg3 *tp, u32 offset, u32 *val)
 static int tg3_nvram_read_le(struct tg3 *tp, u32 offset, __le32 *val)
 {
 	u32 v;
-	int res = tg3_nvram_read(tp, offset, &v);
+	int res = tg3_nvram_read_swab(tp, offset, &v);
 	if (!res)
 		*val = cpu_to_le32(v);
 	return res;
@@ -9197,7 +9203,7 @@ static int tg3_test_nvram(struct tg3 *tp)
 	__le32 *buf;
 	int i, j, k, err = 0, size;
 
-	if (tg3_nvram_read_swab(tp, 0, &magic) != 0)
+	if (tg3_nvram_read(tp, 0, &magic) != 0)
 		return -EIO;
 
 	if (magic == TG3_EEPROM_MAGIC)
@@ -10146,7 +10152,7 @@ static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
 
 	tp->nvram_size = EEPROM_CHIP_SIZE;
 
-	if (tg3_nvram_read_swab(tp, 0, &magic) != 0)
+	if (tg3_nvram_read(tp, 0, &magic) != 0)
 		return;
 
 	if ((magic != TG3_EEPROM_MAGIC) &&
@@ -10162,7 +10168,7 @@ static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
 	cursize = 0x10;
 
 	while (cursize < tp->nvram_size) {
-		if (tg3_nvram_read_swab(tp, cursize, &val) != 0)
+		if (tg3_nvram_read(tp, cursize, &val) != 0)
 			return;
 
 		if (val == magic)
@@ -10178,7 +10184,7 @@ static void __devinit tg3_get_nvram_size(struct tg3 *tp)
 {
 	u32 val;
 
-	if (tg3_nvram_read_swab(tp, 0, &val) != 0)
+	if (tg3_nvram_read(tp, 0, &val) != 0)
 		return;
 
 	/* Selfboot format */
@@ -10187,7 +10193,7 @@ static void __devinit tg3_get_nvram_size(struct tg3 *tp)
 		return;
 	}
 
-	if (tg3_nvram_read(tp, 0xf0, &val) == 0) {
+	if (tg3_nvram_read_swab(tp, 0xf0, &val) == 0) {
 		if (val != 0) {
 			tp->nvram_size = (val >> 16) * 1024;
 			return;
@@ -11342,14 +11348,14 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 	unsigned int i;
 	u32 magic;
 
-	if (tg3_nvram_read_swab(tp, 0x0, &magic))
+	if (tg3_nvram_read(tp, 0x0, &magic))
 		goto out_not_found;
 
 	if (magic == TG3_EEPROM_MAGIC) {
 		for (i = 0; i < 256; i += 4) {
 			u32 tmp;
 
-			if (tg3_nvram_read(tp, 0x100 + i, &tmp))
+			if (tg3_nvram_read_swab(tp, 0x100 + i, &tmp))
 				goto out_not_found;
 
 			vpd_data[i + 0] = ((tmp >>  0) & 0xff);
@@ -11441,9 +11447,9 @@ static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
 {
 	u32 val;
 
-	if (tg3_nvram_read_swab(tp, offset, &val) ||
+	if (tg3_nvram_read(tp, offset, &val) ||
 	    (val & 0xfc000000) != 0x0c000000 ||
-	    tg3_nvram_read_swab(tp, offset + 4, &val) ||
+	    tg3_nvram_read(tp, offset + 4, &val) ||
 	    val != 0)
 		return 0;
 
@@ -11475,7 +11481,7 @@ static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 		return;
 	}
 
-	if (tg3_nvram_read_swab(tp, offset, &val))
+	if (tg3_nvram_read(tp, offset, &val))
 		return;
 
 	build = (val & TG3_EEPROM_SB_EDH_BLD_MASK) >>
@@ -11501,7 +11507,7 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	u32 ver_offset;
 	int i, bcnt;
 
-	if (tg3_nvram_read_swab(tp, 0, &val))
+	if (tg3_nvram_read(tp, 0, &val))
 		return;
 
 	if (val != TG3_EEPROM_MAGIC) {
@@ -11511,14 +11517,14 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 		return;
 	}
 
-	if (tg3_nvram_read_swab(tp, 0xc, &offset) ||
-	    tg3_nvram_read_swab(tp, 0x4, &start))
+	if (tg3_nvram_read(tp, 0xc, &offset) ||
+	    tg3_nvram_read(tp, 0x4, &start))
 		return;
 
 	offset = tg3_nvram_logical_addr(tp, offset);
 
 	if (!tg3_fw_img_is_valid(tp, offset) ||
-	    tg3_nvram_read_swab(tp, offset + 8, &ver_offset))
+	    tg3_nvram_read(tp, offset + 8, &ver_offset))
 		return;
 
 	offset = offset + ver_offset - start;
@@ -11537,7 +11543,7 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	for (offset = TG3_NVM_DIR_START;
 	     offset < TG3_NVM_DIR_END;
 	     offset += TG3_NVM_DIRENT_SIZE) {
-		if (tg3_nvram_read_swab(tp, offset, &val))
+		if (tg3_nvram_read(tp, offset, &val))
 			return;
 
 		if ((val >> TG3_NVM_DIRTYPE_SHIFT) == TG3_NVM_DIRTYPE_ASFINI)
@@ -11549,12 +11555,12 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		start = 0x08000000;
-	else if (tg3_nvram_read_swab(tp, offset - 4, &start))
+	else if (tg3_nvram_read(tp, offset - 4, &start))
 		return;
 
-	if (tg3_nvram_read_swab(tp, offset + 4, &offset) ||
+	if (tg3_nvram_read(tp, offset + 4, &offset) ||
 	    !tg3_fw_img_is_valid(tp, offset) ||
-	    tg3_nvram_read_swab(tp, offset + 8, &val))
+	    tg3_nvram_read(tp, offset + 8, &val))
 		return;
 
 	offset += val - start;
@@ -12349,8 +12355,8 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 	}
 	if (!addr_ok) {
 		/* Next, try NVRAM. */
-		if (!tg3_nvram_read(tp, mac_offset + 0, &hi) &&
-		    !tg3_nvram_read(tp, mac_offset + 4, &lo)) {
+		if (!tg3_nvram_read_swab(tp, mac_offset + 0, &hi) &&
+		    !tg3_nvram_read_swab(tp, mac_offset + 4, &lo)) {
 			dev->dev_addr[0] = ((hi >> 16) & 0xff);
 			dev->dev_addr[1] = ((hi >> 24) & 0xff);
 			dev->dev_addr[2] = ((lo >>  0) & 0xff);
-- 
1.6.0.6


