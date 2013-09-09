From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 15/16] flexcard: can: Configure CAN loopback packages (TXACK)
Date: Mon,  9 Sep 2013 09:25:12 +0200
Message-ID: <1378711513-2548-16-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38033 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab3IIHna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:43:30 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Holger Dengler <dengler@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 670a6b1..92c1444 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -358,11 +358,13 @@ static inline void c_can_object_put(struct net_device *dev,
 }
 
 static void c_can_write_msg_object(struct net_device *dev,
-			int iface, struct can_frame *frame, int objno)
+			int iface, struct can_frame *frame, int objno,
+			int txie_off)
 {
 	u32 flags = IF_ARB_MSGVAL;
 	unsigned int id;
 	struct c_can_priv *priv = netdev_priv(dev);
+	u32 int_en;
 
 	if (!(frame->can_id & CAN_RTR_FLAG))
 		flags |= IF_ARB_TRANSMIT;
@@ -388,9 +390,10 @@ static void c_can_write_msg_object(struct net_device *dev,
 			 frame->data[4] | frame->data[5] << 8);
 
 	/* enable interrupt for this message object */
-	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
-			IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB |
-			frame->can_dlc);
+	int_en = frame->can_dlc;
+	if (!txie_off)
+		int_en |= IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB;
+	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), int_en);
 	c_can_object_put(dev, iface, objno, IF_COMM_ALL);
 }
 
@@ -616,16 +619,17 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 	u32 msg_obj_no;
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct can_frame *frame = (struct can_frame *)skb->data;
-	int tx_fifo;
+	int tx_fifo, txie_off;
 
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
 
 	tx_fifo = frame->can_dlc & FC_TXFIFO_FLAG;
+	txie_off = frame->can_dlc & FC_TXACKOFF_FLAG;
 	frame->can_dlc &= FC_TXFIFO_DLC_MASK;
 
 	if (tx_fifo) {
-		u32 id, *data, ctrl;
+		u32 id, *data, ctrl, conf;
 
 		if (readl(priv->base + FC_TXFIFO_STAT) &
 				FC_TXFIFO_STAT_FULL) {
@@ -652,6 +656,11 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 			writel(data[1], priv->base + FC_TXFIFO_MSGDB);
 		}
 
+		conf = readl(priv->base + FC_TXFIFO_CONF);
+		conf &= ~FC_TXFIFO_CONF_TXACK;
+		conf |= (txie_off ? 0 : FC_TXFIFO_CONF_TXACK);
+		writel(conf, priv->base + FC_TXFIFO_CONF);
+
 		ctrl = readl(priv->base + FC_TXFIFO_CTRL);
 		ctrl |= FC_TXFIFO_CTRL_REQ;
 		writel(ctrl, priv->base + FC_TXFIFO_CTRL);
@@ -660,7 +669,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 		msg_obj_no = get_tx_next_msg_obj(priv);
 
 		/* prepare message object for transmission */
-		c_can_write_msg_object(dev, 0, frame, msg_obj_no);
+		c_can_write_msg_object(dev, 0, frame, msg_obj_no, txie_off);
 		priv->tx_next++;
 
 		can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
-- 
1.8.4.rc3
