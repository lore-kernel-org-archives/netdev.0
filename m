From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2 8/9] can: janz-ican3: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:55:16 +0100
Message-ID: <1293296117-27624-9-git-send-email-mkl@pengutronix.de>
References: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57445 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab0LYQz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 11:55:27 -0500
In-Reply-To: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Ira W. Snyder <iws@ovro.caltech.edu>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/janz-ican3.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 810345f..77c8413 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -807,18 +807,15 @@ static void ican3_to_can_frame(struct ican3_dev *mod,
 			       struct can_frame *cf)
 {
 	if ((desc->command & ICAN3_CAN_TYPE_MASK) == ICAN3_CAN_TYPE_SFF) {
-		if (desc->data[1] & ICAN3_SFF_RTR)
-			cf->can_id |= CAN_RTR_FLAG;
-
 		cf->can_id |= desc->data[0] << 3;
 		cf->can_id |= (desc->data[1] & 0xe0) >> 5;
+
 		cf->can_dlc = get_can_dlc(desc->data[1] & ICAN3_CAN_DLC_MASK);
-		memcpy(cf->data, &desc->data[2], cf->can_dlc);
-	} else {
-		cf->can_dlc = get_can_dlc(desc->data[0] & ICAN3_CAN_DLC_MASK);
-		if (desc->data[0] & ICAN3_EFF_RTR)
+		if (desc->data[1] & ICAN3_SFF_RTR)
 			cf->can_id |= CAN_RTR_FLAG;
-
+		else
+			memcpy(cf->data, &desc->data[2], cf->can_dlc);
+	} else {
 		if (desc->data[0] & ICAN3_EFF) {
 			cf->can_id |= CAN_EFF_FLAG;
 			cf->can_id |= desc->data[2] << 21; /* 28-21 */
@@ -830,7 +827,11 @@ static void ican3_to_can_frame(struct ican3_dev *mod,
 			cf->can_id |= desc->data[3] >> 5;  /* 2-0   */
 		}
 
-		memcpy(cf->data, &desc->data[6], cf->can_dlc);
+		cf->can_dlc = get_can_dlc(desc->data[0] & ICAN3_CAN_DLC_MASK);
+		if (desc->data[0] & ICAN3_EFF_RTR)
+			cf->can_id |= CAN_RTR_FLAG;
+		else
+			memcpy(cf->data, &desc->data[6], cf->can_dlc);
 	}
 }
 
-- 
1.7.2.3

