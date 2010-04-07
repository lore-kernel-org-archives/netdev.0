From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: fix r6040_multicast_list
Date: Wed, 7 Apr 2010 13:18:48 +0200
Message-ID: <201004071318.48883.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, darkadept@hispeed.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:51356 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab0DGLT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 07:19:56 -0400
Received: by ewy20 with SMTP id 20so460698ewy.1
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 04:19:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported in <https://bugzilla.kernel.org/show_bug.cgi?id=15355>, r6040_
multicast_list currently crashes. This is due a wrong maximum of multicast
entries. This patch fixes the following issues with multicast:

- number of maximum entries if off-by-one (4 instead of 3)

- the writing of the hash table index is not necessary and leads to invalid
values being written into the MCR1 register, so the MAC is simply put in a non
coherent state

- when we exceed the maximum number of mutlticast address, writing the
broadcast address should be done in registers MID_1{L,M,H} instead of
MID_O{L,M,H}, otherwise we would loose the adapter's MAC address

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index f5a0e96..83ebc75 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -135,7 +135,7 @@
 #define RX_DESC_SIZE	(RX_DCNT * sizeof(struct r6040_descriptor))
 #define TX_DESC_SIZE	(TX_DCNT * sizeof(struct r6040_descriptor))
 #define MBCR_DEFAULT	0x012A	/* MAC Bus Control Register */
-#define MCAST_MAX	4	/* Max number multicast addresses to filter */
+#define MCAST_MAX	3	/* Max number multicast addresses to filter */
 
 /* Descriptor status */
 #define DSC_OWNER_MAC	0x8000	/* MAC is the owner of this descriptor */
@@ -983,9 +983,6 @@ static void r6040_multicast_list(struct net_device *dev)
 			crc >>= 26;
 			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
 		}
-		/* Write the index of the hash table */
-		for (i = 0; i < 4; i++)
-			iowrite16(hash_table[i] << 14, ioaddr + MCR1);
 		/* Fill the MAC hash tables with their values */
 		iowrite16(hash_table[0], ioaddr + MAR0);
 		iowrite16(hash_table[1], ioaddr + MAR1);
@@ -1001,9 +998,9 @@ static void r6040_multicast_list(struct net_device *dev)
 			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
 			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
 		} else {
-			iowrite16(0xffff, ioaddr + MID_0L + 8 * i);
-			iowrite16(0xffff, ioaddr + MID_0M + 8 * i);
-			iowrite16(0xffff, ioaddr + MID_0H + 8 * i);
+			iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
+			iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
+			iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
 		}
 		i++;
 	}
