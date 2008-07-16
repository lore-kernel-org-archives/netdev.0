From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 05/10] mv643xx_eth: don't fiddle with maximum receive packet size setting
Date: Wed, 16 Jul 2008 12:32:29 +0200
Message-ID: <20080716103229.GF8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44734 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756509AbYGPKcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:32:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum receive packet size field in the Port Serial Control
register controls at what size received packets are flagged
overlength in the receive descriptor, but it doesn't prevent
overlength packets from being DMAd to memory and signaled to the
host like other received packets.

mv643xx_eth does not support receiving jumbo frames in 10/100 mode,
but setting the packet threshold to larger than 1522 bytes in 10/100
mode won't cause breakage by itself.

If we really want to enforce maximum packet size on the receiving
end instead of on the sending end where it should be done, we can
always just add a length check to the software receive handler
instead of relying on the hardware to do the comparison for us.

What's more, changing the maximum packet size field requires
temporarily disabling the RX/TX paths.  So once the link comes
up in 10/100 Mb/s mode or 1000 Mb/s mode, we'd have to disable it
again just to set the right maximum packet size field (1522 in
10/100 Mb/s mode or 9700 in 1000 Mb/s mode), just so that we can
offload one comparison operation to hardware that we might as well
do in software, assuming that we'd want to do it at all.

Contrary to what the documentation suggests, there is no harm in
just setting a 9700 byte maximum packet size in 10/100 mode, so use
the maximum maximum packet size for all modes.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3211369..207d439 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -154,7 +154,6 @@ static char mv643xx_eth_driver_version[] = "1.1";
 #define SET_MII_SPEED_TO_100			(1 << 24)
 #define SET_GMII_SPEED_TO_1000			(1 << 23)
 #define SET_FULL_DUPLEX_MODE			(1 << 21)
-#define MAX_RX_PACKET_1522BYTE			(1 << 17)
 #define MAX_RX_PACKET_9700BYTE			(5 << 17)
 #define MAX_RX_PACKET_MASK			(7 << 17)
 #define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
@@ -1674,13 +1673,12 @@ static void update_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 			    SET_FULL_DUPLEX_MODE   |
 			    MAX_RX_PACKET_MASK);
 
-	if (speed == SPEED_1000) {
-		pscr_n |= SET_GMII_SPEED_TO_1000 | MAX_RX_PACKET_9700BYTE;
-	} else {
-		if (speed == SPEED_100)
-			pscr_n |= SET_MII_SPEED_TO_100;
-		pscr_n |= MAX_RX_PACKET_1522BYTE;
-	}
+	pscr_n |= MAX_RX_PACKET_9700BYTE;
+
+	if (speed == SPEED_1000)
+		pscr_n |= SET_GMII_SPEED_TO_1000;
+	else if (speed == SPEED_100)
+		pscr_n |= SET_MII_SPEED_TO_100;
 
 	if (duplex == DUPLEX_FULL)
 		pscr_n |= SET_FULL_DUPLEX_MODE;
-- 
1.5.3.4
