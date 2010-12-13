From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v9 18/20] pch_can: Optimize "if" condition in rx/tx processing
Date: Mon, 13 Dec 2010 15:24:24 +0900
Message-ID: <1292221467-8039-18-git-send-email-tomoya-linux@dsn.okisemi.com>
References: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-2-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-3-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-4-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-5-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-6-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-7-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-8-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-9-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-10-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-11-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-12-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-13-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-14-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-15-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-16-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-17-git-send-email-tomoya-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
To: wg@grandegger.com, w.sang@pengutronix.de, chripell@fsfe.org,
	21cnbao@gmail.com, sameo@linux.intel.com,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kerne
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292221467-8039-17-git-send-email-tomoya-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For reduce "if" condition, easy to read/understand the code,
optimize "if" condition in rx/tx processing.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/pch_can.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 8efbe35..dcd8f00 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -746,19 +746,16 @@ static int pch_can_poll(struct napi_struct *napi, int quota)
 
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
@@ -900,14 +897,13 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
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
 
@@ -926,9 +922,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
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
