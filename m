From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 4/19 v4] can: EG20T PCH: Add Tx Flow Control
Date: Fri, 26 Nov 2010 09:35:53 +0900
Message-ID: <4CEF00E9.3080809__30412.4221009717$1290731820$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:11156 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752815Ab0KZAgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 19:36:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add flow control processing.
 Currently, there is no flow control processing.
 Thus, Add flow control processing as
 when there is no empty of tx buffer,
 netif_stop_queue is called.
 When there is empty buffer, netif_wake_queue is called.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   27 ++++++++-------------------
 1 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 2d4ab0f..8686d93 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -899,6 +899,8 @@ MSG_OBJ:
 			dlc = 8;
 		stats->tx_bytes += dlc;
 		stats->tx_packets++;
+		if (int_stat == PCH_TX_OBJ_END)
+			netif_wake_queue(ndev);
 	}

 	int_stat = pch_can_int_pending(priv);
@@ -1037,18 +1039,6 @@ static int pch_close(struct net_device *ndev)
 	return 0;
 }

-static int pch_get_msg_obj_sts(struct net_device *ndev, u32 obj_id)
-{
-	u32 buffer_status = 0;
-	struct pch_can_priv *priv = netdev_priv(ndev);
-
-	/* Getting the message object status. */
-	buffer_status = (u32) pch_can_get_buffer_status(priv);
-
-	return buffer_status & obj_id;
-}
-
-
 static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	int i, j;
@@ -1060,17 +1050,16 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb,
struct net_device *ndev)
 	if (can_dropped_invalid_skb(ndev, skb))
 		return NETDEV_TX_OK;

-	if (priv->tx_obj == PCH_TX_OBJ_END) { /* Point tail Obj */
-		while (pch_get_msg_obj_sts(ndev, (((1 << PCH_TX_OBJ_NUM)-1) <<
-					   PCH_RX_OBJ_NUM)))
-			udelay(500);
+	if (priv->tx_obj == PCH_TX_OBJ_END) {
+		if (ioread32(&priv->regs->treq2) & 0xfc00)
+			netif_stop_queue(ndev);

-		priv->tx_obj = PCH_TX_OBJ_START; /* Point head of Tx Obj ID */
-		tx_buffer_avail = priv->tx_obj; /* Point Tail of Tx Obj */
+		tx_buffer_avail = priv->tx_obj;
+		priv->tx_obj = PCH_TX_OBJ_START;
 	} else {
 		tx_buffer_avail = priv->tx_obj;
+		priv->tx_obj++;
 	}
-	priv->tx_obj++;

 	/* Attaining the lock. */
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-- 
1.6.0.6
