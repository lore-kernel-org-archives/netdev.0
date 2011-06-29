From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: depca: Omit check for multicast bit in netdev_for_each_mc_addr
Date: Wed, 29 Jun 2011 14:15:15 +0200
Message-ID: <1309349715-1604-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:40097 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369Ab1F2MZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2011 08:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to check for the address being a multicast address in
the netdev_for_each_mc_addr loop, so remove it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/depca.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index d54a0e9..a7ccaa6 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1270,7 +1270,6 @@ static void SetMulticastFilter(struct net_device *dev)
 {
 	struct depca_private *lp = netdev_priv(dev);
 	struct netdev_hw_addr *ha;
-	char *addrs;
 	int i, j, bit, byte;
 	u16 hashcode;
 	u32 crc;
@@ -1285,19 +1284,15 @@ static void SetMulticastFilter(struct net_device *dev)
 		}
 		/* Add multicast addresses */
 		netdev_for_each_mc_addr(ha, dev) {
-			addrs = ha->addr;
-			if ((*addrs & 0x01) == 1) {	/* multicast address? */
-				crc = ether_crc(ETH_ALEN, addrs);
-				hashcode = (crc & 1);	/* hashcode is 6 LSb of CRC ... */
-				for (j = 0; j < 5; j++) {	/* ... in reverse order. */
-					hashcode = (hashcode << 1) | ((crc >>= 1) & 1);
-				}
-
-
-				byte = hashcode >> 3;	/* bit[3-5] -> byte in filter */
-				bit = 1 << (hashcode & 0x07);	/* bit[0-2] -> bit in byte */
-				lp->init_block.mcast_table[byte] |= bit;
+			crc = ether_crc(ETH_ALEN, ha->addr);
+			hashcode = (crc & 1);	/* hashcode is 6 LSb of CRC ... */
+			for (j = 0; j < 5; j++) {	/* ... in reverse order. */
+				hashcode = (hashcode << 1) | ((crc >>= 1) & 1);
 			}
+
+			byte = hashcode >> 3;	/* bit[3-5] -> byte in filter */
+			bit = 1 << (hashcode & 0x07);	/* bit[0-2] -> bit in byte */
+			lp->init_block.mcast_table[byte] |= bit;
 		}
 	}
 }
-- 
1.7.5.4

