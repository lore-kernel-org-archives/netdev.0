From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2 6/9] can: ti_hecc: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:55:14 +0100
Message-ID: <1293296117-27624-7-git-send-email-mkl@pengutronix.de>
References: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57440 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab0LYQzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 11:55:25 -0500
In-Reply-To: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While there, remove clearing of data if the dlc isn't longer as 4.
can frames have data initializes to zero.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc:Anant Gole <anantgole@ti.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/ti_hecc.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 4d07f1e..b33581b 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -560,18 +560,20 @@ static int ti_hecc_rx_pkt(struct ti_hecc_priv *priv, int mbxno)
 		cf->can_id = (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
 	else
 		cf->can_id = (data >> 18) & CAN_SFF_MASK;
+
 	data = hecc_read_mbx(priv, mbxno, HECC_CANMCF);
+	cf->can_dlc = get_can_dlc(data & 0xF);
 	if (data & HECC_CANMCF_RTR)
 		cf->can_id |= CAN_RTR_FLAG;
-	cf->can_dlc = get_can_dlc(data & 0xF);
-	data = hecc_read_mbx(priv, mbxno, HECC_CANMDL);
-	*(u32 *)(cf->data) = cpu_to_be32(data);
-	if (cf->can_dlc > 4) {
-		data = hecc_read_mbx(priv, mbxno, HECC_CANMDH);
-		*(u32 *)(cf->data + 4) = cpu_to_be32(data);
-	} else {
-		*(u32 *)(cf->data + 4) = 0;
+	else {
+		data = hecc_read_mbx(priv, mbxno, HECC_CANMDL);
+		*(u32 *)(cf->data) = cpu_to_be32(data);
+		if (cf->can_dlc > 4) {
+			data = hecc_read_mbx(priv, mbxno, HECC_CANMDH);
+			*(u32 *)(cf->data + 4) = cpu_to_be32(data);
+		}
 	}
+
 	spin_lock_irqsave(&priv->mbx_lock, flags);
 	hecc_clear_bit(priv, HECC_CANME, mbx_mask);
 	hecc_write(priv, HECC_CANRMP, mbx_mask);
-- 
1.7.2.3

