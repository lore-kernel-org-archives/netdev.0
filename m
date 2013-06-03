From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] net: can: kvaser_usb: fix reception on "USBcan Pro" and "USBcan R" type hardware.
Date: Mon,  3 Jun 2013 14:15:31 +0200
Message-ID: <1370261733-22935-2-git-send-email-mkl@pengutronix.de>
References: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, davem@davemloft.net,
	Jonas Peterson <jonas.peterson@gmail.com>,
	stable@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36600 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab3FCMQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 08:16:21 -0400
In-Reply-To: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Peterson <jonas.peterson@gmail.com>

Unlike Kvaser Leaf light devices, some other Kvaser devices (like USBcan
Pro, USBcan R) receive CAN messages in CMD_LOG_MESSAGE frames. This
patch adds support for it.

Cc: linux-stable <stable@vger.kernel.org> # >= v3.8
Signed-off-by: Jonas Peterson <jonas.peterson@gmail.com>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 64 +++++++++++++++++++++++++++-------------
 1 file changed, 43 insertions(+), 21 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 45cb9f3..3b95465 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -136,6 +136,9 @@
 #define KVASER_CTRL_MODE_SELFRECEPTION	3
 #define KVASER_CTRL_MODE_OFF		4
 
+/* log message */
+#define KVASER_EXTENDED_FRAME		BIT(31)
+
 struct kvaser_msg_simple {
 	u8 tid;
 	u8 channel;
@@ -817,8 +820,13 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
 	priv = dev->nets[channel];
 	stats = &priv->netdev->stats;
 
-	if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME | MSG_FLAG_NERR |
-				  MSG_FLAG_OVERRUN)) {
+	if ((msg->u.rx_can.flag & MSG_FLAG_ERROR_FRAME) &&
+	    (msg->id == CMD_LOG_MESSAGE)) {
+		kvaser_usb_rx_error(dev, msg);
+		return;
+	} else if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
+					 MSG_FLAG_NERR |
+					 MSG_FLAG_OVERRUN)) {
 		kvaser_usb_rx_can_err(priv, msg);
 		return;
 	} else if (msg->u.rx_can.flag & ~MSG_FLAG_REMOTE_FRAME) {
@@ -834,22 +842,40 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
 		return;
 	}
 
-	cf->can_id = ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
-		     (msg->u.rx_can.msg[1] & 0x3f);
-	cf->can_dlc = get_can_dlc(msg->u.rx_can.msg[5]);
+	if (msg->id == CMD_LOG_MESSAGE) {
+		cf->can_id = le32_to_cpu(msg->u.log_message.id);
+		if (cf->can_id & KVASER_EXTENDED_FRAME)
+			cf->can_id &= CAN_EFF_MASK | CAN_EFF_FLAG;
+		else
+			cf->can_id &= CAN_SFF_MASK;
 
-	if (msg->id == CMD_RX_EXT_MESSAGE) {
-		cf->can_id <<= 18;
-		cf->can_id |= ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
-			      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
-			      (msg->u.rx_can.msg[4] & 0x3f);
-		cf->can_id |= CAN_EFF_FLAG;
-	}
+		cf->can_dlc = get_can_dlc(msg->u.log_message.dlc);
 
-	if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME)
-		cf->can_id |= CAN_RTR_FLAG;
-	else
-		memcpy(cf->data, &msg->u.rx_can.msg[6], cf->can_dlc);
+		if (msg->u.log_message.flags & MSG_FLAG_REMOTE_FRAME)
+			cf->can_id |= CAN_RTR_FLAG;
+		else
+			memcpy(cf->data, &msg->u.log_message.data,
+			       cf->can_dlc);
+	} else {
+		cf->can_id = ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
+			     (msg->u.rx_can.msg[1] & 0x3f);
+
+		if (msg->id == CMD_RX_EXT_MESSAGE) {
+			cf->can_id <<= 18;
+			cf->can_id |= ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
+				      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
+				      (msg->u.rx_can.msg[4] & 0x3f);
+			cf->can_id |= CAN_EFF_FLAG;
+		}
+
+		cf->can_dlc = get_can_dlc(msg->u.rx_can.msg[5]);
+
+		if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME)
+			cf->can_id |= CAN_RTR_FLAG;
+		else
+			memcpy(cf->data, &msg->u.rx_can.msg[6],
+			       cf->can_dlc);
+	}
 
 	netif_rx(skb);
 
@@ -911,6 +937,7 @@ static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
 
 	case CMD_RX_STD_MESSAGE:
 	case CMD_RX_EXT_MESSAGE:
+	case CMD_LOG_MESSAGE:
 		kvaser_usb_rx_can_msg(dev, msg);
 		break;
 
@@ -919,11 +946,6 @@ static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
 		kvaser_usb_rx_error(dev, msg);
 		break;
 
-	case CMD_LOG_MESSAGE:
-		if (msg->u.log_message.flags & MSG_FLAG_ERROR_FRAME)
-			kvaser_usb_rx_error(dev, msg);
-		break;
-
 	case CMD_TX_ACKNOWLEDGE:
 		kvaser_usb_tx_acknowledge(dev, msg);
 		break;
-- 
1.8.2.rc2
