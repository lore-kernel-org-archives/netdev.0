From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/8] tg3: Fix SEEPROM accesses
Date: Mon, 20 Apr 2009 09:52:49 -0700
Message-ID: <1240247953.7009@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2380 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbZDTRS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:18:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent NVRAM patches sanitized how the driver deals with NVRAM
data, but they failed to bring the SEEPROM interfaces inline with
the new strategy.  This patch brings the SEEPROM interfaces up to date.
This patch also reverts commit 0d489ffb76de0fe804cf06a9d4d11fa7342d74b9.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Tested-by: Robin Holt <holt@sgi.com>
Tested-by: James Bottomley <james.bottomley@HansenPartnership.com>
---
 drivers/net/tg3.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7a837c4..201be42 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2190,7 +2190,14 @@ static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
 	if (!(tmp & EEPROM_ADDR_COMPLETE))
 		return -EBUSY;
 
-	*val = tr32(GRC_EEPROM_DATA);
+	tmp = tr32(GRC_EEPROM_DATA);
+
+	/*
+	 * The data will always be opposite the native endian
+	 * format.  Perform a blind byteswap to compensate.
+	 */
+	*val = swab32(tmp);
+
 	return 0;
 }
 
@@ -10663,7 +10670,13 @@ static int tg3_nvram_write_block_using_eeprom(struct tg3 *tp,
 
 		memcpy(&data, buf + i, 4);
 
-		tw32(GRC_EEPROM_DATA, be32_to_cpu(data));
+		/*
+		 * The SEEPROM interface expects the data to always be opposite
+		 * the native endian format.  We accomplish this by reversing
+		 * all the operations that would have been performed on the
+		 * data from a call to tg3_nvram_read_be32().
+		 */
+		tw32(GRC_EEPROM_DATA, swab32(be32_to_cpu(data)));
 
 		val = tr32(GRC_EEPROM_ADDR);
 		tw32(GRC_EEPROM_ADDR, val | EEPROM_ADDR_COMPLETE);
@@ -12443,13 +12456,8 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 		/* Next, try NVRAM. */
 		if (!tg3_nvram_read_be32(tp, mac_offset + 0, &hi) &&
 		    !tg3_nvram_read_be32(tp, mac_offset + 4, &lo)) {
-			dev->dev_addr[0] = ((hi >> 16) & 0xff);
-			dev->dev_addr[1] = ((hi >> 24) & 0xff);
-			dev->dev_addr[2] = ((lo >>  0) & 0xff);
-			dev->dev_addr[3] = ((lo >>  8) & 0xff);
-			dev->dev_addr[4] = ((lo >> 16) & 0xff);
-			dev->dev_addr[5] = ((lo >> 24) & 0xff);
-
+			memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
+			memcpy(&dev->dev_addr[2], (char *)&lo, sizeof(lo));
 		}
 		/* Finally just fetch it out of the MAC control regs. */
 		else {
-- 
1.6.0.6


