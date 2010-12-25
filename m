From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2 7/9] can: janz-ican3: cleanup of ican3_to_can_frame and can_frame_to_ican3
Date: Sat, 25 Dec 2010 17:55:15 +0100
Message-ID: <1293296117-27624-8-git-send-email-mkl@pengutronix.de>
References: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57443 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab0LYQz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 11:55:26 -0500
In-Reply-To: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the ICAN3 to Linux CAN frame and vice versa
conversion functions:

- RX: Use get_can_dlc() to limit the dlc value.
- TX: Drop invalid skbs wiht can_dropped_invalid_skb
- both: Don't copy the whole frame, only copy the amount of bytes specified
  in cf->can_dlc.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/janz-ican3.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index b9a6d7a..810345f 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -812,10 +812,10 @@ static void ican3_to_can_frame(struct ican3_dev *mod,
 
 		cf->can_id |= desc->data[0] << 3;
 		cf->can_id |= (desc->data[1] & 0xe0) >> 5;
-		cf->can_dlc = desc->data[1] & ICAN3_CAN_DLC_MASK;
-		memcpy(cf->data, &desc->data[2], sizeof(cf->data));
+		cf->can_dlc = get_can_dlc(desc->data[1] & ICAN3_CAN_DLC_MASK);
+		memcpy(cf->data, &desc->data[2], cf->can_dlc);
 	} else {
-		cf->can_dlc = desc->data[0] & ICAN3_CAN_DLC_MASK;
+		cf->can_dlc = get_can_dlc(desc->data[0] & ICAN3_CAN_DLC_MASK);
 		if (desc->data[0] & ICAN3_EFF_RTR)
 			cf->can_id |= CAN_RTR_FLAG;
 
@@ -830,7 +830,7 @@ static void ican3_to_can_frame(struct ican3_dev *mod,
 			cf->can_id |= desc->data[3] >> 5;  /* 2-0   */
 		}
 
-		memcpy(cf->data, &desc->data[6], sizeof(cf->data));
+		memcpy(cf->data, &desc->data[6], cf->can_dlc);
 	}
 }
 
@@ -862,7 +862,7 @@ static void can_frame_to_ican3(struct ican3_dev *mod,
 	}
 
 	/* copy the data bits into the descriptor */
-	memcpy(&desc->data[6], cf->data, sizeof(cf->data));
+	memcpy(&desc->data[6], cf->data, cf->can_dlc);
 }
 
 /*
@@ -1421,6 +1421,9 @@ static int ican3_xmit(struct sk_buff *skb, struct net_device *ndev)
 	void __iomem *desc_addr;
 	unsigned long flags;
 
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
 	spin_lock_irqsave(&mod->lock, flags);
 
 	/* check that we can actually transmit */
-- 
1.7.2.3

