From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/5] tg3: Add support for extended VPD blocks
Date: Wed, 13 Apr 2011 14:05:08 -0700
Message-ID: <1302728708-1797-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1623 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932835Ab1DMU4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 16:56:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some devices, the VPD block is relocated to a different area in
NVRAM.  The original location can still contain old, but still valid VPD
data.  This patch changes the code to look for an extended VPD block in
NVRAM.  If one is found, that block is used for all VPD operations
instead.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  125 ++++++++++++++++++++++++++++++++++-------------------
 drivers/net/tg3.h |    2 +
 2 files changed, 83 insertions(+), 44 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 52dd516..10fa476 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10416,6 +10416,81 @@ static void tg3_get_ethtool_stats(struct net_device *dev,
 	memcpy(tmp_stats, tg3_get_estats(tp), sizeof(tp->estats));
 }
 
+static __be32 * tg3_vpd_readblock(struct tg3 *tp)
+{
+	int i;
+	__be32 *buf;
+	u32 offset = 0, len = 0;
+	u32 magic, val;
+
+	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
+	    tg3_nvram_read(tp, 0, &magic))
+		return NULL;
+
+	if (magic == TG3_EEPROM_MAGIC) {
+		for (offset = TG3_NVM_DIR_START;
+		     offset < TG3_NVM_DIR_END;
+		     offset += TG3_NVM_DIRENT_SIZE) {
+			if (tg3_nvram_read(tp, offset, &val))
+				return NULL;
+
+			if ((val >> TG3_NVM_DIRTYPE_SHIFT) ==
+			    TG3_NVM_DIRTYPE_EXTVPD)
+				break;
+		}
+
+		if (offset != TG3_NVM_DIR_END) {
+			len = (val & TG3_NVM_DIRTYPE_LENMSK) * 4;
+			if (tg3_nvram_read(tp, offset + 4, &offset))
+				return NULL;
+
+			offset = tg3_nvram_logical_addr(tp, offset);
+		}
+	}
+
+	if (!offset || !len) {
+		offset = TG3_NVM_VPD_OFF;
+		len = TG3_NVM_VPD_LEN;
+	}
+
+	buf = kmalloc(len, GFP_KERNEL);
+	if (buf == NULL)
+		return NULL;
+
+	if (magic == TG3_EEPROM_MAGIC) {
+		for (i = 0; i < len; i += 4) {
+			/* The data is in little-endian format in NVRAM.
+			 * Use the big-endian read routines to preserve
+			 * the byte order as it exists in NVRAM.
+			 */
+			if (tg3_nvram_read_be32(tp, offset + i, &buf[i/4]))
+				goto error;
+		}
+	} else {
+		u8 *ptr;
+		ssize_t cnt;
+		unsigned int pos = 0;
+
+		ptr = (u8 *)&buf[0];
+		for (i = 0; pos < len && i < 3; i++, pos += cnt, ptr += cnt) {
+			cnt = pci_read_vpd(tp->pdev, pos,
+					   len - pos, ptr);
+			if (cnt == -ETIMEDOUT || cnt == -EINTR)
+				cnt = 0;
+			else if (cnt < 0)
+				goto error;
+		}
+		if (pos != len)
+			goto error;
+	}
+
+	return buf;
+
+error:
+	kfree(buf);
+	return NULL;
+}
+
 #define NVRAM_TEST_SIZE 0x100
 #define NVRAM_SELFBOOT_FORMAT1_0_SIZE	0x14
 #define NVRAM_SELFBOOT_FORMAT1_2_SIZE	0x18
@@ -10555,14 +10630,11 @@ static int tg3_test_nvram(struct tg3 *tp)
 	if (csum != le32_to_cpu(buf[0xfc/4]))
 		goto out;
 
-	for (i = 0; i < TG3_NVM_VPD_LEN; i += 4) {
-		/* The data is in little-endian format in NVRAM.
-		 * Use the big-endian read routines to preserve
-		 * the byte order as it exists in NVRAM.
-		 */
-		if (tg3_nvram_read_be32(tp, TG3_NVM_VPD_OFF + i, &buf[i/4]))
-			goto out;
-	}
+	kfree(buf);
+
+	buf = tg3_vpd_readblock(tp);
+	if (!buf)
+		return -ENOMEM;
 
 	i = pci_vpd_find_tag((u8 *)buf, 0, TG3_NVM_VPD_LEN,
 			     PCI_VPD_LRDT_RO_DATA);
@@ -12905,46 +12977,11 @@ static void __devinit tg3_read_vpd(struct tg3 *tp)
 	u8 *vpd_data;
 	unsigned int block_end, rosize, len;
 	int j, i = 0;
-	u32 magic;
-
-	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
-	    tg3_nvram_read(tp, 0x0, &magic))
-		goto out_no_vpd;
 
-	vpd_data = kmalloc(TG3_NVM_VPD_LEN, GFP_KERNEL);
+	vpd_data = (u8 *)tg3_vpd_readblock(tp);
 	if (!vpd_data)
 		goto out_no_vpd;
 
-	if (magic == TG3_EEPROM_MAGIC) {
-		for (i = 0; i < TG3_NVM_VPD_LEN; i += 4) {
-			u32 tmp;
-
-			/* The data is in little-endian format in NVRAM.
-			 * Use the big-endian read routines to preserve
-			 * the byte order as it exists in NVRAM.
-			 */
-			if (tg3_nvram_read_be32(tp, TG3_NVM_VPD_OFF + i, &tmp))
-				goto out_not_found;
-
-			memcpy(&vpd_data[i], &tmp, sizeof(tmp));
-		}
-	} else {
-		ssize_t cnt;
-		unsigned int pos = 0;
-
-		for (; pos < TG3_NVM_VPD_LEN && i < 3; i++, pos += cnt) {
-			cnt = pci_read_vpd(tp->pdev, pos,
-					   TG3_NVM_VPD_LEN - pos,
-					   &vpd_data[pos]);
-			if (cnt == -ETIMEDOUT || cnt == -EINTR)
-				cnt = 0;
-			else if (cnt < 0)
-				goto out_not_found;
-		}
-		if (pos != TG3_NVM_VPD_LEN)
-			goto out_not_found;
-	}
-
 	i = pci_vpd_find_tag(vpd_data, 0, TG3_NVM_VPD_LEN,
 			     PCI_VPD_LRDT_RO_DATA);
 	if (i < 0)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b3ccfcc..224c3e0 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2009,7 +2009,9 @@
 #define TG3_NVM_DIR_END			0x78
 #define TG3_NVM_DIRENT_SIZE		0xc
 #define TG3_NVM_DIRTYPE_SHIFT		24
+#define TG3_NVM_DIRTYPE_LENMSK		0x003fffff
 #define TG3_NVM_DIRTYPE_ASFINI		1
+#define TG3_NVM_DIRTYPE_EXTVPD		20
 #define TG3_NVM_PTREV_BCVER		0x94
 #define TG3_NVM_BCVER_MAJMSK		0x0000ff00
 #define TG3_NVM_BCVER_MAJSFT		8
-- 
1.7.3.4


