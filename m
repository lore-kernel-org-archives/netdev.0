From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/2] can: bfin_can: simplify xmit id1 setup
Date: Thu, 23 Jun 2011 16:36:19 -0400
Message-ID: <1308861380-27485-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: socketcan-core@lists.berlios.de,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55042 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933927Ab1FWUgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 16:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we look closely, the 4 writes to TRANSMIT_CHL.id1 can be collapsed
down into much simpler code.  So do just that.

This also fixes a build failure due to the I/O macros no longer
getting pulled in.  Their minor (and accidental) usage here gets
dropped as part of the unification.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/can/bfin_can.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index b6e890d..dc6ef4a 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -243,21 +243,12 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* fill id */
 	if (id & CAN_EFF_FLAG) {
 		bfin_write16(&reg->chl[TRANSMIT_CHL].id0, id);
-		if (id & CAN_RTR_FLAG)
-			writew(((id & 0x1FFF0000) >> 16) | IDE | AME | RTR,
-					&reg->chl[TRANSMIT_CHL].id1);
-		else
-			writew(((id & 0x1FFF0000) >> 16) | IDE | AME,
-					&reg->chl[TRANSMIT_CHL].id1);
-
-	} else {
-		if (id & CAN_RTR_FLAG)
-			writew((id << 2) | AME | RTR,
-				&reg->chl[TRANSMIT_CHL].id1);
-		else
-			bfin_write16(&reg->chl[TRANSMIT_CHL].id1,
-					(id << 2) | AME);
-	}
+		val = ((id & 0x1FFF0000) >> 16) | IDE;
+	} else
+		val = (id << 2);
+	if (id & CAN_RTR_FLAG)
+		val |= RTR;
+	bfin_write16(&reg->chl[TRANSMIT_CHL].id1, val | AME);
 
 	/* fill payload */
 	for (i = 0; i < 8; i += 2) {
-- 
1.7.5.3

