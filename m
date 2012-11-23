From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2] kvaser_usb: fix "dma on the stack" errors
Date: Fri, 23 Nov 2012 14:54:43 +0100
Message-ID: <1353678883-23136-1-git-send-email-olivier@sobrie.be>
References: <20121123134027.GA32098@hposo>
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Wolfgang Grandegge <wg@grandegger.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Daniel Berglund <db@kvaser.com>,
	Olivier Sobrie <olivier@sobrie.be>
To: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38705 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912Ab2KWN4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 08:56:31 -0500
In-Reply-To: <20121123134027.GA32098@hposo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dma buffer given to usb_bulk_msg() must be allocated and not on
the stack.
See Documentation/DMA-API-HOWTO.txt section "What memory is DMA'able?"

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/can/usb/kvaser_usb.c |  111 ++++++++++++++++++++++++--------------
 1 file changed, 70 insertions(+), 41 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 8807bf8..1b159e7 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -421,14 +421,22 @@ end:
 static int kvaser_usb_send_simple_msg(const struct kvaser_usb *dev,
 				      u8 msg_id, int channel)
 {
-	struct kvaser_msg msg = {
-		.len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_simple),
-		.id = msg_id,
-		.u.simple.channel = channel,
-		.u.simple.tid = 0xff,
-	};
-
-	return kvaser_usb_send_msg(dev, &msg);
+	struct kvaser_msg *msg;
+	int rc;
+
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	msg->id = msg_id;
+	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_simple);
+	msg->u.simple.channel = channel;
+	msg->u.simple.tid = 0xff;
+
+	rc = kvaser_usb_send_msg(dev, msg);
+
+	kfree(msg);
+	return rc;
 }
 
 static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
@@ -1057,20 +1065,27 @@ static int kvaser_usb_setup_rx_urbs(struct kvaser_usb *dev)
 
 static int kvaser_usb_set_opt_mode(const struct kvaser_usb_net_priv *priv)
 {
-	struct kvaser_msg msg = {
-		.id = CMD_SET_CTRL_MODE,
-		.len = MSG_HEADER_LEN +
-		       sizeof(struct kvaser_msg_ctrl_mode),
-		.u.ctrl_mode.tid = 0xff,
-		.u.ctrl_mode.channel = priv->channel,
-	};
+	struct kvaser_msg *msg;
+	int rc;
+
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	msg->id = CMD_SET_CTRL_MODE;
+	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_ctrl_mode);
+	msg->u.ctrl_mode.tid = 0xff;
+	msg->u.ctrl_mode.channel = priv->channel;
 
 	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
-		msg.u.ctrl_mode.ctrl_mode = KVASER_CTRL_MODE_SILENT;
+		msg->u.ctrl_mode.ctrl_mode = KVASER_CTRL_MODE_SILENT;
 	else
-		msg.u.ctrl_mode.ctrl_mode = KVASER_CTRL_MODE_NORMAL;
+		msg->u.ctrl_mode.ctrl_mode = KVASER_CTRL_MODE_NORMAL;
 
-	return kvaser_usb_send_msg(priv->dev, &msg);
+	rc = kvaser_usb_send_msg(priv->dev, msg);
+
+	kfree(msg);
+	return rc;
 }
 
 static int kvaser_usb_start_chip(struct kvaser_usb_net_priv *priv)
@@ -1163,15 +1178,22 @@ static int kvaser_usb_stop_chip(struct kvaser_usb_net_priv *priv)
 
 static int kvaser_usb_flush_queue(struct kvaser_usb_net_priv *priv)
 {
-	struct kvaser_msg msg = {
-		.id = CMD_FLUSH_QUEUE,
-		.len = MSG_HEADER_LEN +
-		       sizeof(struct kvaser_msg_flush_queue),
-		.u.flush_queue.channel = priv->channel,
-		.u.flush_queue.flags = 0x00,
-	};
-
-	return kvaser_usb_send_msg(priv->dev, &msg);
+	struct kvaser_msg *msg;
+	int rc;
+
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	msg->id = CMD_FLUSH_QUEUE;
+	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_flush_queue);
+	msg->u.flush_queue.channel = priv->channel;
+	msg->u.flush_queue.flags = 0x00;
+
+	rc = kvaser_usb_send_msg(priv->dev, msg);
+
+	kfree(msg);
+	return rc;
 }
 
 static int kvaser_usb_close(struct net_device *netdev)
@@ -1364,24 +1386,31 @@ static int kvaser_usb_set_bittiming(struct net_device *netdev)
 	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
 	struct can_bittiming *bt = &priv->can.bittiming;
 	struct kvaser_usb *dev = priv->dev;
-	struct kvaser_msg msg = {
-		.id = CMD_SET_BUS_PARAMS,
-		.len = MSG_HEADER_LEN +
-		       sizeof(struct kvaser_msg_busparams),
-		.u.busparams.channel = priv->channel,
-		.u.busparams.tid = 0xff,
-		.u.busparams.bitrate = cpu_to_le32(bt->bitrate),
-		.u.busparams.sjw = bt->sjw,
-		.u.busparams.tseg1 = bt->prop_seg + bt->phase_seg1,
-		.u.busparams.tseg2 = bt->phase_seg2,
-	};
+	struct kvaser_msg *msg;
+	int rc;
+
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	msg->id = CMD_SET_BUS_PARAMS;
+	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_busparams);
+	msg->u.busparams.channel = priv->channel;
+	msg->u.busparams.tid = 0xff;
+	msg->u.busparams.bitrate = cpu_to_le32(bt->bitrate);
+	msg->u.busparams.sjw = bt->sjw;
+	msg->u.busparams.tseg1 = bt->prop_seg + bt->phase_seg1;
+	msg->u.busparams.tseg2 = bt->phase_seg2;
 
 	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
-		msg.u.busparams.no_samp = 3;
+		msg->u.busparams.no_samp = 3;
 	else
-		msg.u.busparams.no_samp = 1;
+		msg->u.busparams.no_samp = 1;
+
+	rc = kvaser_usb_send_msg(dev, msg);
 
-	return kvaser_usb_send_msg(dev, &msg);
+	kfree(msg);
+	return rc;
 }
 
 static int kvaser_usb_set_mode(struct net_device *netdev,
-- 
1.7.9.5
