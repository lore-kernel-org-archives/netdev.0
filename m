From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/9] can: bfin_can: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 15:40:27 +0100
Message-ID: <1293288034-22428-3-git-send-email-mkl@pengutronix.de>
References: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Barry Song <21cnbao@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57217 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab0LYOkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 09:40:45 -0500
In-Reply-To: <1293288034-22428-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Barry Song <21cnbao@gmail.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/bfin_can.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index b6e890d..07222ca 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -306,18 +306,19 @@ static void bfin_can_rx(struct net_device *dev, u16 isrc)
 			     & 0x1ffc) >> 2;
 		obj = RECEIVE_STD_CHL;
 	}
-	if (bfin_read16(&reg->chl[obj].id1) & RTR)
-		cf->can_id |= CAN_RTR_FLAG;
 
 	/* get data length code */
 	cf->can_dlc = get_can_dlc(bfin_read16(&reg->chl[obj].dlc) & 0xF);
 
-	/* get payload */
-	for (i = 0; i < 8; i += 2) {
-		val = bfin_read16(&reg->chl[obj].data[i]);
-		cf->data[7 - i] = (7 - i) < cf->can_dlc ? val : 0;
-		cf->data[6 - i] = (6 - i) < cf->can_dlc ? (val >> 8) : 0;
-	}
+	if (bfin_read16(&reg->chl[obj].id1) & RTR)
+		cf->can_id |= CAN_RTR_FLAG;
+	else	/* get payload */
+		for (i = 0; i < 8; i += 2) {
+			val = bfin_read16(&reg->chl[obj].data[i]);
+			cf->data[7 - i] = (7 - i) < cf->can_dlc ? val : 0;
+			cf->data[6 - i] = (6 - i) < cf->can_dlc ?
+				(val >> 8) : 0;
+		}
 
 	netif_rx(skb);
 
-- 
1.7.2.3

