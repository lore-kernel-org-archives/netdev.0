From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2 9/9] can: pch_can: don't copy data to rx'ed RTR frames
Date: Sat, 25 Dec 2010 17:55:17 +0100
Message-ID: <1293296117-27624-10-git-send-email-mkl@pengutronix.de>
References: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Tomoya <tomoya-linux@dsn.okisemi.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57450 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab0LYQz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 11:55:28 -0500
In-Reply-To: <1293296117-27624-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Tomoya <tomoya-linux@dsn.okisemi.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---

Changes since v1:
- fix data copy: copy if rtr is _not_ set (thanks Oliver)

 drivers/net/can/pch_can.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index c42e972..cd6b27d 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -692,16 +692,17 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int quota)
 			cf->can_id = id;
 		}
 
-		if (id2 & PCH_ID2_DIR)
-			cf->can_id |= CAN_RTR_FLAG;
-
 		cf->can_dlc = get_can_dlc((ioread32(&priv->regs->
 						    ifregs[0].mcont)) & 0xF);
 
-		for (i = 0; i < cf->can_dlc; i += 2) {
-			data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
-			cf->data[i] = data_reg;
-			cf->data[i + 1] = data_reg >> 8;
+		if (id2 & PCH_ID2_DIR)
+			cf->can_id |= CAN_RTR_FLAG;
+		else {
+			for (i = 0; i < cf->can_dlc; i += 2) {
+				data_reg = ioread16(&priv->regs->ifregs[0].data[i / 2]);
+				cf->data[i] = data_reg;
+				cf->data[i + 1] = data_reg >> 8;
+			}
 		}
 
 		netif_receive_skb(skb);
-- 
1.7.2.3

