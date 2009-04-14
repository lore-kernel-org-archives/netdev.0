From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: SEEPROM test patch
Date: Tue, 14 Apr 2009 10:21:23 -0700
Message-ID: <20090414172123.GA12319@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, netdev@vger.kernel.org,
	"Parisc List" <linux-parisc@vger.kernel.org>
To: "Robin Holt" <holt@sgi.com>,
	"James Bottomley" <James.Bottomley@HansenPartnership.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James, Robin.  I looked through the patches again and found that the
SEEPROM routines were not being adjusted correctly along with the flash
NVRAM access routines.  The patch below should shore up the difference.
The patch works on both BE and LE systems.

Can you apply the patch below and see if it fixes your problem?  (You
may have to back out David's changes for the mac addresses to be
restored, but 'eeprom -e' dumps should be fixed.)  If it does, I'll
post a replacement patch that documents why the code is doing what it's
doing.


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6a736dd..3ef43c2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2190,7 +2190,10 @@ static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
 	if (!(tmp & EEPROM_ADDR_COMPLETE))
 		return -EBUSY;
 
-	*val = tr32(GRC_EEPROM_DATA);
+	tmp = tr32(GRC_EEPROM_DATA);
+
+	*val = swab32(tmp);
+
 	return 0;
 }
 
@@ -10657,13 +10660,13 @@ static int tg3_nvram_write_block_using_eeprom(struct tg3 *tp,
 
 	for (i = 0; i < len; i += 4) {
 		u32 addr;
-		__be32 data;
+		__le32 data;
 
 		addr = offset + i;
 
 		memcpy(&data, buf + i, 4);
 
-		tw32(GRC_EEPROM_DATA, be32_to_cpu(data));
+		tw32(GRC_EEPROM_DATA, le32_to_cpu(data));
 
 		val = tr32(GRC_EEPROM_ADDR);
 		tw32(GRC_EEPROM_ADDR, val | EEPROM_ADDR_COMPLETE);

