From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 07/16] can: c_can: Make it SMP safe
Date: Tue,  1 Apr 2014 23:42:21 +0200
Message-ID: <1396388550-23081-8-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42641 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbaDAVmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 17:42:38 -0400
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

The hardware has two message control interfaces, but the code only uses the
first one. So on SMP the following can be observed:

CPU0 	       	CPU1
rx_poll()
  write IF1	xmit()
		write IF1
  write IF1

That results in corrupted message object configurations. The TX/RX is not
globally serialized it's only serialized on a core.

Simple solution: Let RX use IF1 and TX use IF2 and all is good.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 4d08a32..38f9ada 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -133,6 +133,12 @@
 #define IF_MCONT_DLC_MASK	0xf
 
 /*
+ * Use IF1 for RX and IF2 for TX
+ */
+#define IF_RX			0
+#define IF_TX			1
+
+/*
  * IFx register masks:
  * allow easy operation on 16-bit registers when the
  * argument is 32-bit instead
@@ -420,7 +426,7 @@ static void c_can_handle_lost_msg_obj(struct net_device *dev,
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
 			IF_MCONT_CLR_MSGLST);
 
-	c_can_object_put(dev, 0, objno, IF_COMM_CONTROL);
+	c_can_object_put(dev, iface, objno, IF_COMM_CONTROL);
 
 	/* create an error msg */
 	skb = alloc_can_err_skb(dev, &frame);
@@ -551,7 +557,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 	msg_obj_no = get_tx_next_msg_obj(priv);
 
 	/* prepare message object for transmission */
-	c_can_write_msg_object(dev, 0, frame, msg_obj_no);
+	c_can_write_msg_object(dev, IF_TX, frame, msg_obj_no);
 	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
 
 	/*
@@ -634,14 +640,14 @@ static void c_can_configure_msg_objects(struct net_device *dev)
 
 	/* first invalidate all message objects */
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i <= C_CAN_NO_OF_OBJECTS; i++)
-		c_can_inval_msg_object(dev, 0, i);
+		c_can_inval_msg_object(dev, IF_RX, i);
 
 	/* setup receive message objects */
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
-		c_can_setup_receive_object(dev, 0, i, 0, 0,
+		c_can_setup_receive_object(dev, IF_RX, i, 0, 0,
 			(IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB);
 
-	c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
+	c_can_setup_receive_object(dev, IF_RX, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
 			IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
 }
 
@@ -792,13 +798,13 @@ static void c_can_do_tx(struct net_device *dev)
 		if (!(val & (1 << (msg_obj_no - 1)))) {
 			can_get_echo_skb(dev,
 					msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
-			c_can_object_get(dev, 0, msg_obj_no, IF_COMM_ALL);
+			c_can_object_get(dev, IF_TX, msg_obj_no, IF_COMM_ALL);
 			stats->tx_bytes += priv->read_reg(priv,
-					C_CAN_IFACE(MSGCTRL_REG, 0))
+					C_CAN_IFACE(MSGCTRL_REG, IF_TX))
 					& IF_MCONT_DLC_MASK;
 			stats->tx_packets++;
 			can_led_event(dev, CAN_LED_EVENT_TX);
-			c_can_inval_msg_object(dev, 0, msg_obj_no);
+			c_can_inval_msg_object(dev, IF_TX, msg_obj_no);
 		} else {
 			break;
 		}
@@ -850,13 +856,13 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 		while ((msg_obj = ffs(val)) && quota > 0) {
 			val &= ~BIT(msg_obj - 1);
 
-			c_can_object_get(dev, 0, msg_obj, IF_COMM_ALL &
+			c_can_object_get(dev, IF_RX, msg_obj, IF_COMM_ALL &
 					~IF_COMM_TXRQST);
 			msg_ctrl_save = priv->read_reg(priv,
-					C_CAN_IFACE(MSGCTRL_REG, 0));
+					C_CAN_IFACE(MSGCTRL_REG, IF_RX));
 
 			if (msg_ctrl_save & IF_MCONT_MSGLST) {
-				c_can_handle_lost_msg_obj(dev, 0, msg_obj);
+				c_can_handle_lost_msg_obj(dev, IF_RX, msg_obj);
 				num_rx_pkts++;
 				quota--;
 				continue;
@@ -869,19 +875,19 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 				continue;
 
 			/* read the data from the message object */
-			c_can_read_msg_object(dev, 0, msg_ctrl_save);
+			c_can_read_msg_object(dev, IF_RX, msg_ctrl_save);
 
 			if (msg_obj < C_CAN_MSG_RX_LOW_LAST)
-				c_can_mark_rx_msg_obj(dev, 0,
+				c_can_mark_rx_msg_obj(dev, IF_RX,
 						msg_ctrl_save, msg_obj);
 			else if (msg_obj > C_CAN_MSG_RX_LOW_LAST)
 				/* activate this msg obj */
-				c_can_activate_rx_msg_obj(dev, 0,
+				c_can_activate_rx_msg_obj(dev, IF_RX,
 						msg_ctrl_save, msg_obj);
 			else if (msg_obj == C_CAN_MSG_RX_LOW_LAST)
 				/* activate all lower message objects */
 				c_can_activate_all_lower_rx_msg_obj(dev,
-						0, msg_ctrl_save);
+						IF_RX, msg_ctrl_save);
 
 			num_rx_pkts++;
 			quota--;
-- 
1.9.0.279.gdc9e3eb
