From: Andy Duan <fugang.duan@nxp.com>
Subject: [PATCH net 1/1] net: fec: fix multicast filtering hardware setup
Date: Mon, 13 Feb 2017 10:01:25 +0800
Message-ID: <1486951285-30668-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <festevam@gmail.com>,
        <stephen@networkplumber.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0055.outbound.protection.outlook.com ([104.47.40.55]:1728
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751193AbdBMCDC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 21:03:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rui Sousa <rui.sousa@nxp.com>

Fix hardware setup of multicast address hash:
- Never clear the hardware hash (to avoid packet loss)
- Construct the hash register values in software and then write once
to hardware

Signed-off-by: Rui Sousa <rui.sousa@nxp.com>
Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 2cc552d..91a1664 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2910,6 +2910,7 @@ static void set_multicast_list(struct net_device *ndev)
 	struct netdev_hw_addr *ha;
 	unsigned int i, bit, data, crc, tmp;
 	unsigned char hash;
+	unsigned int hash_high = 0, hash_low = 0;
 
 	if (ndev->flags & IFF_PROMISC) {
 		tmp = readl(fep->hwp + FEC_R_CNTRL);
@@ -2932,11 +2933,7 @@ static void set_multicast_list(struct net_device *ndev)
 		return;
 	}
 
-	/* Clear filter and add the addresses in hash register
-	 */
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-
+	/* Add the addresses in hash register */
 	netdev_for_each_mc_addr(ha, ndev) {
 		/* calculate crc32 value of mac address */
 		crc = 0xffffffff;
@@ -2954,16 +2951,14 @@ static void set_multicast_list(struct net_device *ndev)
 		 */
 		hash = (crc >> (32 - FEC_HASH_BITS)) & 0x3f;
 
-		if (hash > 31) {
-			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-			tmp |= 1 << (hash - 32);
-			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-		} else {
-			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-			tmp |= 1 << hash;
-			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-		}
+		if (hash > 31)
+			hash_high |= 1 << (hash - 32);
+		else
+			hash_low |= 1 << hash;
 	}
+
+	writel(hash_high, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+	writel(hash_low, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 }
 
 /* Set a MAC change in hardware. */
-- 
1.9.1
