From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v6 18/20] can: EG20T PCH: Optimize "if" condition
Date: Tue, 30 Nov 2010 13:39:26 +0900
Message-ID: <4CF47FFE.2060003__40316.2648356103$1291092026$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34657 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751418Ab0K3Ej7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:39:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For reduce "if" condition, easy to read/understand the code,
optimize "if" condition in rx/tx processing.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 743385b..e11ec36 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -752,19 +752,16 @@ static int pch_can_poll(struct napi_struct *napi, int quota)
 
 	if (int_stat == PCH_STATUS_INT) {
 		reg_stat = ioread32(&priv->regs->stat);
-		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
-			if (reg_stat & PCH_BUS_OFF ||
-			   (reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL) {
-				pch_can_error(ndev, reg_stat);
-				quota--;
-			}
-		}
 
-		if (reg_stat & PCH_TX_OK)
-			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
+		if ((reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) &&
+		   ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL)) {
+			pch_can_error(ndev, reg_stat);
+			quota--;
+		}
 
-		if (reg_stat & PCH_RX_OK)
-			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
+		if (reg_stat & (PCH_TX_OK | PCH_RX_OK))
+			pch_can_bit_clear(&priv->regs->stat,
+					  reg_stat & (PCH_TX_OK | PCH_RX_OK));
 
 		int_stat = pch_can_int_pending(priv);
 	}
@@ -906,14 +903,13 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;
 
+	tx_obj_no = priv->tx_obj;
 	if (priv->tx_obj == PCH_TX_OBJ_END) {
 		if (ioread32(&priv->regs->treq2) & PCH_TREQ2_TX_MASK)
 			netif_stop_queue(ndev);
 
-		tx_obj_no = priv->tx_obj;
 		priv->tx_obj = PCH_TX_OBJ_START;
 	} else {
-		tx_obj_no = priv->tx_obj;
 		priv->tx_obj++;
 	}
 
@@ -932,9 +928,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	id2 |= PCH_ID_MSGVAL;
 
 	/* If remote frame has to be transmitted.. */
-	if (cf->can_id & CAN_RTR_FLAG)
-		id2 &= ~PCH_ID2_DIR;
-	else
+	if (!(cf->can_id & CAN_RTR_FLAG))
 		id2 |= PCH_ID2_DIR;
 
 	iowrite32(id2, &priv->regs->ifregs[1].id2);
-- 
1.6.0.6
