From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 03/12] can: c_can: Make it SMP safe
Date: Tue, 18 Mar 2014 17:19:09 -0000
Message-ID: <20140318171126.844179673@linutronix.de>
References: <20140318171007.528610837@linutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=can-c_can-use-if1-2.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hardware has two message control interfaces, but the code only
uses the first one. So on SMP the following can be observed:

CPU0 	       	CPU1
rx_poll()
  write IF1	xmit()
		write IF1
  write IF1			

That results in corrupted message object configurations. The TX/RX is
not globally serialized it's only serialized on a core.

Simple solution: Let RX use IF1 and TX use IF2 and all is good.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/net/can/c_can/c_can.c |   36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
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
@@ -420,7 +426,7 @@ static void c_can_handle_lost_msg_obj(st
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
 			IF_MCONT_CLR_MSGLST);
 
-	c_can_object_put(dev, 0, objno, IF_COMM_CONTROL);
+	c_can_object_put(dev, iface, objno, IF_COMM_CONTROL);
 
 	/* create an error msg */
 	skb = alloc_can_err_skb(dev, &frame);
@@ -551,7 +557,7 @@ static netdev_tx_t c_can_start_xmit(stru
 	msg_obj_no = get_tx_next_msg_obj(priv);
 
 	/* prepare message object for transmission */
-	c_can_write_msg_object(dev, 0, frame, msg_obj_no);
+	c_can_write_msg_object(dev, IF_TX, frame, msg_obj_no);
 	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
 
 	/*
@@ -634,14 +640,14 @@ static void c_can_configure_msg_objects(
 
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
 
@@ -783,13 +789,13 @@ static void c_can_do_tx(struct net_devic
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
@@ -841,13 +847,13 @@ static int c_can_do_rx_poll(struct net_d
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
@@ -860,19 +866,19 @@ static int c_can_do_rx_poll(struct net_d
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
