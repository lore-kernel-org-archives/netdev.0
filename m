From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/14] tg3: Eliminate tg3_nvram_read_swab()
Date: Wed, 25 Feb 2009 16:25:52 -0800
Message-ID: <1235616375.16016@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3730 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017AbZBZCqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The remaining uses of tg3_nvram_read_swab() either intended to read the
data from NVRAM exactly as tg3_nvram_read_be32() did or hide deeper
interpretations of the data.  For the former case, a direct replacement
of tg3_nvram_read_swab() with tg3_nvram_read_be32() is in order.  For
the latter case, we remove tg3_nvram_read_swab() and document what the
code is really doing.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   52 +++++++++++++++++++++++++---------------------------
 1 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index baa1f0e..9453918 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2283,16 +2283,6 @@ static int tg3_nvram_read(struct tg3 *tp, u32 offset, u32 *val)
 	return ret;
 }
 
-static int tg3_nvram_read_swab(struct tg3 *tp, u32 offset, u32 *val)
-{
-	int err;
-	u32 tmp;
-
-	err = tg3_nvram_read(tp, offset, &tmp);
-	*val = swab32(tmp);
-	return err;
-}
-
 /* Ensures NVRAM data is in bytestream format. */
 static int tg3_nvram_read_be32(struct tg3 *tp, u32 offset, __be32 *val)
 {
@@ -10195,9 +10185,20 @@ static void __devinit tg3_get_nvram_size(struct tg3 *tp)
 		return;
 	}
 
-	if (tg3_nvram_read_swab(tp, 0xf0, &val) == 0) {
+	if (tg3_nvram_read(tp, 0xf0, &val) == 0) {
 		if (val != 0) {
-			tp->nvram_size = (val >> 16) * 1024;
+			/* This is confusing.  We want to operate on the
+			 * 16-bit value at offset 0xf2.  The tg3_nvram_read()
+			 * call will read from NVRAM and byteswap the data
+			 * according to the byteswapping settings for all
+			 * other register accesses.  This ensures the data we
+			 * want will always reside in the lower 16-bits.
+			 * However, the data in NVRAM is in LE format, which
+			 * means the data from the NVRAM read will always be
+			 * opposite the endianness of the CPU.  The 16-bit
+			 * byteswap then brings the data to CPU endianness.
+			 */
+			tp->nvram_size = swab16((u16)(val & 0x0000ffff)) * 1024;
 			return;
 		}
 	}
@@ -11347,7 +11348,7 @@ skip_phy_reset:
 
 static void __devinit tg3_read_partno(struct tg3 *tp)
 {
-	unsigned char vpd_data[256];
+	unsigned char vpd_data[256];   /* in little-endian format */
 	unsigned int i;
 	u32 magic;
 
@@ -11358,13 +11359,14 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		for (i = 0; i < 256; i += 4) {
 			u32 tmp;
 
-			if (tg3_nvram_read_swab(tp, 0x100 + i, &tmp))
+			/* The data is in little-endian format in NVRAM.
+			 * Use the big-endian read routines to preserve
+			 * the byte order as it exists in NVRAM.
+			 */
+			if (tg3_nvram_read_be32(tp, 0x100 + i, &tmp))
 				goto out_not_found;
 
-			vpd_data[i + 0] = ((tmp >>  0) & 0xff);
-			vpd_data[i + 1] = ((tmp >>  8) & 0xff);
-			vpd_data[i + 2] = ((tmp >> 16) & 0xff);
-			vpd_data[i + 3] = ((tmp >> 24) & 0xff);
+			memcpy(&vpd_data[i], &tmp, sizeof(tmp));
 		}
 	} else {
 		int vpd_cap;
@@ -11390,7 +11392,7 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 			pci_read_config_dword(tp->pdev, vpd_cap + PCI_VPD_DATA,
 					      &tmp);
 			v = cpu_to_le32(tmp);
-			memcpy(&vpd_data[i], &v, 4);
+			memcpy(&vpd_data[i], &v, sizeof(v));
 		}
 	}
 
@@ -12358,14 +12360,10 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 	}
 	if (!addr_ok) {
 		/* Next, try NVRAM. */
-		if (!tg3_nvram_read_swab(tp, mac_offset + 0, &hi) &&
-		    !tg3_nvram_read_swab(tp, mac_offset + 4, &lo)) {
-			dev->dev_addr[0] = ((hi >> 16) & 0xff);
-			dev->dev_addr[1] = ((hi >> 24) & 0xff);
-			dev->dev_addr[2] = ((lo >>  0) & 0xff);
-			dev->dev_addr[3] = ((lo >>  8) & 0xff);
-			dev->dev_addr[4] = ((lo >> 16) & 0xff);
-			dev->dev_addr[5] = ((lo >> 24) & 0xff);
+		if (!tg3_nvram_read_be32(tp, mac_offset + 0, &hi) &&
+		    !tg3_nvram_read_be32(tp, mac_offset + 4, &lo)) {
+			memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
+			memcpy(&dev->dev_addr[2], (char *)&lo, sizeof(lo));
 		}
 		/* Finally just fetch it out of the MAC control regs. */
 		else {
-- 
1.6.0.6


