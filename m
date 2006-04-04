From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/tg3.c: fix a memory leak
Date: Tue, 4 Apr 2006 21:09:35 +0200
Message-ID: <20060404190935.GB6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750818AbWDDTJh@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a memory leak (buf wasn't freed) spotted by the 
Coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/tg3.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

--- linux-2.6.17-rc1-mm1-full/drivers/net/tg3.c.old	2006-04-04 19:53:24.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/drivers/net/tg3.c	2006-04-04 19:54:40.000000000 +0200
@@ -8031,15 +8031,19 @@ static int tg3_test_nvram(struct tg3 *tp
 	if (cpu_to_be32(buf[0]) != TG3_EEPROM_MAGIC) {
 		u8 *buf8 = (u8 *) buf, csum8 = 0;
 
 		for (i = 0; i < size; i++)
 			csum8 += buf8[i];
 
-		if (csum8 == 0)
-			return 0;
-		return -EIO;
+		if (csum8 == 0) {
+			err = 0;
+			goto out;
+		}
+
+		err = -EIO;
+		goto out;
 	}
 
 	/* Bootstrap checksum at offset 0x10 */
 	csum = calc_crc((unsigned char *) buf, 0x10);
 	if(csum != cpu_to_le32(buf[0x10/4]))
 		goto out;
