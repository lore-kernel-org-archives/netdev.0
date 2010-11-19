From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 4/17] can: EG20T PCH: Add Tx Flow Control
Date: Fri, 19 Nov 2010 14:45:12 +0900
Message-ID: <4CE60EE8.2060906__32815.634008921$1290145560$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:30414 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750951Ab0KSFpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 00:45:31 -0500
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
 drivers/net/can/pch_can.c |   37 +++++++++++++------------------------
 1 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 5c21f5c..7c182b8 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -900,6 +900,8 @@ MSG_OBJ:
 			dlc = 8;
 		stats->tx_bytes += dlc;
 		stats->tx_packets++;
+		if (int_stat == PCH_TX_OBJ_END)
+			netif_wake_queue(ndev);
 	}
 
 	int_stat = pch_can_int_pending(priv);
@@ -1038,47 +1040,34 @@ static int pch_close(struct net_device *ndev)
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
 	unsigned long flags;
 	struct pch_can_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf = (struct can_frame *)skb->data;
-	int tx_buffer_avail = 0;
+	int tx_obj_no = 0;
 
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
+		tx_obj_no = priv->tx_obj;
+		priv->tx_obj = PCH_TX_OBJ_START;
 	} else {
-		tx_buffer_avail = priv->tx_obj;
+		tx_obj_no = priv->tx_obj;
+		priv->tx_obj++;
 	}
-	priv->tx_obj++;
 
 	/* Attaining the lock. */
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 
 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
 	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);
+	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_obj_no);
 
 	/* Setting the CMASK register. */
 	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);
@@ -1110,7 +1099,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 			 (&priv->regs->ifregs[1].dataa1) + j*4);
 	}
 
-	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_END - 1);
+	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);
 
 	/* Updating the size of the data. */
 	pch_can_bit_clear(&priv->regs->ifregs[1].mcont, 0x0f);
@@ -1125,7 +1114,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	pch_can_bit_set(&priv->regs->ifregs[1].mcont,
 			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);
 
-	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);
+	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_obj_no);
 
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 
-- 
1.6.0.6

