From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 15:29:54 +0000
Message-ID: <1239636594.3278.31.camel@mulgrave.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Parisc List <linux-parisc@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[sorry for repost; wrong netdev address first time around]

We noticed on parisc that our broadcoms all swapped MAC addresses going
from 2.6.29 to 2.6.30-rc1:

Apr 11 07:48:24 ion kernel: eth0: Tigon3 [partno(BCM95700A6) rev 0105] (PCI:66MHz:64-bit) MAC address 00:30:6e:4b:15:59
Apr 13 07:34:34 ion kernel: eth0: Tigon3 [partno(BCM95700A6) rev 0105] (PCI:66MHz:64-bit) MAC address 00:00:59:15:4b:6e

The problem patch is:

commit 6d348f2c1e0bb1cf7a494b51fc921095ead3f6ae
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Wed Feb 25 14:25:52 2009 +0000

    tg3: Eliminate tg3_nvram_read_swab()

With the root cause being the use of memcpy to set the mac address:

   memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
   memcpy(&dev->dev_addr[2], (char *)&lo, sizeof(lo));

This might work on little endian machines, but it can't on big endian
ones.  You have to use the original setting mechanism to be correct on
all architectures.

The attached patch fixes parisc.

Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>

---

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6a736dd..7a837c4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12443,8 +12443,13 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 		/* Next, try NVRAM. */
 		if (!tg3_nvram_read_be32(tp, mac_offset + 0, &hi) &&
 		    !tg3_nvram_read_be32(tp, mac_offset + 4, &lo)) {
-			memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
-			memcpy(&dev->dev_addr[2], (char *)&lo, sizeof(lo));
+			dev->dev_addr[0] = ((hi >> 16) & 0xff);
+			dev->dev_addr[1] = ((hi >> 24) & 0xff);
+			dev->dev_addr[2] = ((lo >>  0) & 0xff);
+			dev->dev_addr[3] = ((lo >>  8) & 0xff);
+			dev->dev_addr[4] = ((lo >> 16) & 0xff);
+			dev->dev_addr[5] = ((lo >> 24) & 0xff);
+
 		}
 		/* Finally just fetch it out of the MAC control regs. */
 		else {



