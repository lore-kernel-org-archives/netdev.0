From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/14] tg3: Correct NVRAM stream endian notations
Date: Wed, 25 Feb 2009 16:25:30 -0800
Message-ID: <1235616374.16013@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3710 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754013AbZBZCq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any software requesting NVRAM data as it exists on NVRAM is necessarily
requesting that the results be returned as a bytestream.  A bytestream
data read in from the device can also be thought to be in big endian
format.  Therefore, all the LE notations in the driver are mislabeled.
This patch converts all LE notations to BE notations, carefully
evaluating the surrounding code in the process.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   55 +++++++++++++++++++++++++++-------------------------
 1 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a2ca6ab..baa1f0e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2293,12 +2293,13 @@ static int tg3_nvram_read_swab(struct tg3 *tp, u32 offset, u32 *val)
 	return err;
 }
 
-static int tg3_nvram_read_le(struct tg3 *tp, u32 offset, __le32 *val)
+/* Ensures NVRAM data is in bytestream format. */
+static int tg3_nvram_read_be32(struct tg3 *tp, u32 offset, __be32 *val)
 {
 	u32 v;
-	int res = tg3_nvram_read_swab(tp, offset, &v);
+	int res = tg3_nvram_read(tp, offset, &v);
 	if (!res)
-		*val = cpu_to_le32(v);
+		*val = cpu_to_be32(v);
 	return res;
 }
 
@@ -8539,7 +8540,7 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	int ret;
 	u8  *pd;
 	u32 i, offset, len, b_offset, b_count;
-	__le32 val;
+	__be32 val;
 
 	if (tp->link_config.phy_is_low_power)
 		return -EAGAIN;
@@ -8558,7 +8559,7 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 			/* i.e. offset=1 len=2 */
 			b_count = len;
 		}
-		ret = tg3_nvram_read_le(tp, offset-b_offset, &val);
+		ret = tg3_nvram_read_be32(tp, offset-b_offset, &val);
 		if (ret)
 			return ret;
 		memcpy(data, ((char*)&val) + b_offset, b_count);
@@ -8570,7 +8571,7 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	/* read bytes upto the last 4 byte boundary */
 	pd = &data[eeprom->len];
 	for (i = 0; i < (len - (len & 3)); i += 4) {
-		ret = tg3_nvram_read_le(tp, offset + i, &val);
+		ret = tg3_nvram_read_be32(tp, offset + i, &val);
 		if (ret) {
 			eeprom->len += i;
 			return ret;
@@ -8584,7 +8585,7 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		pd = &data[eeprom->len];
 		b_count = len & 3;
 		b_offset = offset + len - b_count;
-		ret = tg3_nvram_read_le(tp, b_offset, &val);
+		ret = tg3_nvram_read_be32(tp, b_offset, &val);
 		if (ret)
 			return ret;
 		memcpy(pd, &val, b_count);
@@ -8601,7 +8602,7 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	int ret;
 	u32 offset, len, b_offset, odd_len;
 	u8 *buf;
-	__le32 start, end;
+	__be32 start, end;
 
 	if (tp->link_config.phy_is_low_power)
 		return -EAGAIN;
@@ -8614,7 +8615,7 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 
 	if ((b_offset = (offset & 3))) {
 		/* adjustments to start on required 4 byte boundary */
-		ret = tg3_nvram_read_le(tp, offset-b_offset, &start);
+		ret = tg3_nvram_read_be32(tp, offset-b_offset, &start);
 		if (ret)
 			return ret;
 		len += b_offset;
@@ -8628,7 +8629,7 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		/* adjustments to end on required 4 byte boundary */
 		odd_len = 1;
 		len = (len + 3) & ~3;
-		ret = tg3_nvram_read_le(tp, offset+len-4, &end);
+		ret = tg3_nvram_read_be32(tp, offset+len-4, &end);
 		if (ret)
 			return ret;
 	}
@@ -9200,7 +9201,7 @@ static void tg3_get_ethtool_stats (struct net_device *dev,
 static int tg3_test_nvram(struct tg3 *tp)
 {
 	u32 csum, magic;
-	__le32 *buf;
+	__be32 *buf;
 	int i, j, k, err = 0, size;
 
 	if (tg3_nvram_read(tp, 0, &magic) != 0)
@@ -9237,14 +9238,15 @@ static int tg3_test_nvram(struct tg3 *tp)
 
 	err = -EIO;
 	for (i = 0, j = 0; i < size; i += 4, j++) {
-		if ((err = tg3_nvram_read_le(tp, i, &buf[j])) != 0)
+		err = tg3_nvram_read_be32(tp, i, &buf[j]);
+		if (err)
 			break;
 	}
 	if (i < size)
 		goto out;
 
 	/* Selfboot format */
-	magic = swab32(le32_to_cpu(buf[0]));
+	magic = be32_to_cpu(buf[0]);
 	if ((magic & TG3_EEPROM_MAGIC_FW_MSK) ==
 	    TG3_EEPROM_MAGIC_FW) {
 		u8 *buf8 = (u8 *) buf, csum8 = 0;
@@ -9273,7 +9275,7 @@ static int tg3_test_nvram(struct tg3 *tp)
 	if ((magic & TG3_EEPROM_MAGIC_HW_MSK) ==
 	    TG3_EEPROM_MAGIC_HW) {
 		u8 data[NVRAM_SELFBOOT_DATA_SIZE];
-	       	u8 parity[NVRAM_SELFBOOT_DATA_SIZE];
+		u8 parity[NVRAM_SELFBOOT_DATA_SIZE];
 		u8 *buf8 = (u8 *) buf;
 
 		/* Separate the parity bits and the data bytes.  */
@@ -9316,13 +9318,13 @@ static int tg3_test_nvram(struct tg3 *tp)
 
 	/* Bootstrap checksum at offset 0x10 */
 	csum = calc_crc((unsigned char *) buf, 0x10);
-	if(csum != le32_to_cpu(buf[0x10/4]))
+	if (csum != be32_to_cpu(buf[0x10/4]))
 		goto out;
 
 	/* Manufacturing block starts at offset 0x74, checksum at 0xfc */
 	csum = calc_crc((unsigned char *) &buf[0x74/4], 0x88);
-	if (csum != le32_to_cpu(buf[0xfc/4]))
-		 goto out;
+	if (csum != be32_to_cpu(buf[0xfc/4]))
+		goto out;
 
 	err = 0;
 
@@ -10654,13 +10656,13 @@ static int tg3_nvram_write_block_using_eeprom(struct tg3 *tp,
 
 	for (i = 0; i < len; i += 4) {
 		u32 addr;
-		__le32 data;
+		__be32 data;
 
 		addr = offset + i;
 
 		memcpy(&data, buf + i, 4);
 
-		tw32(GRC_EEPROM_DATA, le32_to_cpu(data));
+		tw32(GRC_EEPROM_DATA, be32_to_cpu(data));
 
 		val = tr32(GRC_EEPROM_ADDR);
 		tw32(GRC_EEPROM_ADDR, val | EEPROM_ADDR_COMPLETE);
@@ -10710,8 +10712,9 @@ static int tg3_nvram_write_block_unbuffered(struct tg3 *tp, u32 offset, u32 len,
 		phy_addr = offset & ~pagemask;
 
 		for (j = 0; j < pagesize; j += 4) {
-			if ((ret = tg3_nvram_read_le(tp, phy_addr + j,
-						(__le32 *) (tmp + j))))
+			ret = tg3_nvram_read_be32(tp, phy_addr + j,
+						  (__be32 *) (tmp + j));
+			if (ret)
 				break;
 		}
 		if (ret)
@@ -10758,7 +10761,7 @@ static int tg3_nvram_write_block_unbuffered(struct tg3 *tp, u32 offset, u32 len,
 			__be32 data;
 
 			data = *((__be32 *) (tmp + j));
-			/* swab32(le32_to_cpu(data)), actually */
+
 			tw32(NVRAM_WRDATA, be32_to_cpu(data));
 
 			tw32(NVRAM_ADDR, phy_addr + j);
@@ -11529,8 +11532,8 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 
 	offset = offset + ver_offset - start;
 	for (i = 0; i < 16; i += 4) {
-		__le32 v;
-		if (tg3_nvram_read_le(tp, offset + i, &v))
+		__be32 v;
+		if (tg3_nvram_read_be32(tp, offset + i, &v))
 			return;
 
 		memcpy(tp->fw_ver + i, &v, 4);
@@ -11571,8 +11574,8 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	tp->fw_ver[bcnt++] = ' ';
 
 	for (i = 0; i < 4; i++) {
-		__le32 v;
-		if (tg3_nvram_read_le(tp, offset, &v))
+		__be32 v;
+		if (tg3_nvram_read_be32(tp, offset, &v))
 			return;
 
 		offset += sizeof(v);
-- 
1.6.0.6


