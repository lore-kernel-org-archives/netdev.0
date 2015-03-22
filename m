From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/7] can: kvaser_usb: Comply with firmware max tx URBs value
Date: Sun, 22 Mar 2015 20:13:32 +0100
Message-ID: <1427051618-28318-2-git-send-email-mkl@pengutronix.de>
References: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38539 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbbCVTNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 15:13:43 -0400
In-Reply-To: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

Current driver code arbitrarily assumes a max outstanding tx
value of 16 parallel transmissions. Meanwhile, the device
firmware provides its actual maximum inside its reply to the
CMD_GET_SOFTWARE_INFO message.

Under heavy tx traffic, if the interleaved transmissions count
increases above the limit reported by firmware, the firmware
breaks up badly, reports a massive list of internal errors, and
the candump traces hardly matches the actual frames sent and
received.

On the other hand, in certain models, the firmware can support
up to 48 tx URBs instead of just 16, increasing the driver
throughput by two-fold and reducing the possibility of -ENOBUFs.

Thus dynamically set the driver's max tx URBs value according
to firmware replies.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 62 ++++++++++++++++++++++++----------------
 1 file changed, 38 insertions(+), 24 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index e97a08ce0b90..2f9733a8e125 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -25,7 +25,6 @@
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
-#define MAX_TX_URBS			16
 #define MAX_RX_URBS			4
 #define START_TIMEOUT			1000 /* msecs */
 #define STOP_TIMEOUT			1000 /* msecs */
@@ -443,6 +442,7 @@ struct kvaser_usb_error_summary {
 	};
 };
 
+/* Context for an outstanding, not yet ACKed, transmission */
 struct kvaser_usb_tx_urb_context {
 	struct kvaser_usb_net_priv *priv;
 	u32 echo_index;
@@ -456,8 +456,13 @@ struct kvaser_usb {
 	struct usb_endpoint_descriptor *bulk_in, *bulk_out;
 	struct usb_anchor rx_submitted;
 
+	/* @max_tx_urbs: Firmware-reported maximum number of oustanding,
+	 * not yet ACKed, transmissions on this device. This value is
+	 * also used as a sentinel for marking free tx contexts.
+	 */
 	u32 fw_version;
 	unsigned int nchannels;
+	unsigned int max_tx_urbs;
 	enum kvaser_usb_family family;
 
 	bool rxinitdone;
@@ -467,19 +472,18 @@ struct kvaser_usb {
 
 struct kvaser_usb_net_priv {
 	struct can_priv can;
-
-	spinlock_t tx_contexts_lock;
-	int active_tx_contexts;
-	struct kvaser_usb_tx_urb_context tx_contexts[MAX_TX_URBS];
-
-	struct usb_anchor tx_submitted;
-	struct completion start_comp, stop_comp;
+	struct can_berr_counter bec;
 
 	struct kvaser_usb *dev;
 	struct net_device *netdev;
 	int channel;
 
-	struct can_berr_counter bec;
+	struct completion start_comp, stop_comp;
+	struct usb_anchor tx_submitted;
+
+	spinlock_t tx_contexts_lock;
+	int active_tx_contexts;
+	struct kvaser_usb_tx_urb_context tx_contexts[];
 };
 
 static const struct usb_device_id kvaser_usb_table[] = {
@@ -657,9 +661,13 @@ static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
 	switch (dev->family) {
 	case KVASER_LEAF:
 		dev->fw_version = le32_to_cpu(msg.u.leaf.softinfo.fw_version);
+		dev->max_tx_urbs =
+			le16_to_cpu(msg.u.leaf.softinfo.max_outstanding_tx);
 		break;
 	case KVASER_USBCAN:
 		dev->fw_version = le32_to_cpu(msg.u.usbcan.softinfo.fw_version);
+		dev->max_tx_urbs =
+			le16_to_cpu(msg.u.usbcan.softinfo.max_outstanding_tx);
 		break;
 	}
 
@@ -715,7 +723,7 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
 
 	stats = &priv->netdev->stats;
 
-	context = &priv->tx_contexts[tid % MAX_TX_URBS];
+	context = &priv->tx_contexts[tid % dev->max_tx_urbs];
 
 	/* Sometimes the state change doesn't come after a bus-off event */
 	if (priv->can.restart_ms &&
@@ -744,7 +752,7 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
 	spin_lock_irqsave(&priv->tx_contexts_lock, flags);
 
 	can_get_echo_skb(priv->netdev, context->echo_index);
-	context->echo_index = MAX_TX_URBS;
+	context->echo_index = dev->max_tx_urbs;
 	--priv->active_tx_contexts;
 	netif_wake_queue(priv->netdev);
 
@@ -1512,11 +1520,13 @@ error:
 
 static void kvaser_usb_reset_tx_urb_contexts(struct kvaser_usb_net_priv *priv)
 {
-	int i;
+	int i, max_tx_urbs;
+
+	max_tx_urbs = priv->dev->max_tx_urbs;
 
 	priv->active_tx_contexts = 0;
-	for (i = 0; i < MAX_TX_URBS; i++)
-		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
+	for (i = 0; i < max_tx_urbs; i++)
+		priv->tx_contexts[i].echo_index = max_tx_urbs;
 }
 
 /* This method might sleep. Do not call it in the atomic context
@@ -1702,14 +1712,14 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 		*msg_tx_can_flags |= MSG_FLAG_REMOTE_FRAME;
 
 	spin_lock_irqsave(&priv->tx_contexts_lock, flags);
-	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
-		if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
+	for (i = 0; i < dev->max_tx_urbs; i++) {
+		if (priv->tx_contexts[i].echo_index == dev->max_tx_urbs) {
 			context = &priv->tx_contexts[i];
 
 			context->echo_index = i;
 			can_put_echo_skb(skb, netdev, context->echo_index);
 			++priv->active_tx_contexts;
-			if (priv->active_tx_contexts >= MAX_TX_URBS)
+			if (priv->active_tx_contexts >= dev->max_tx_urbs)
 				netif_stop_queue(netdev);
 
 			break;
@@ -1743,7 +1753,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 		spin_lock_irqsave(&priv->tx_contexts_lock, flags);
 
 		can_free_echo_skb(netdev, context->echo_index);
-		context->echo_index = MAX_TX_URBS;
+		context->echo_index = dev->max_tx_urbs;
 		--priv->active_tx_contexts;
 		netif_wake_queue(netdev);
 
@@ -1881,7 +1891,9 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 	if (err)
 		return err;
 
-	netdev = alloc_candev(sizeof(*priv), MAX_TX_URBS);
+	netdev = alloc_candev(sizeof(*priv) +
+			      dev->max_tx_urbs * sizeof(*priv->tx_contexts),
+			      dev->max_tx_urbs);
 	if (!netdev) {
 		dev_err(&intf->dev, "Cannot alloc candev\n");
 		return -ENOMEM;
@@ -2009,6 +2021,13 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 		return err;
 	}
 
+	dev_dbg(&intf->dev, "Firmware version: %d.%d.%d\n",
+		((dev->fw_version >> 24) & 0xff),
+		((dev->fw_version >> 16) & 0xff),
+		(dev->fw_version & 0xffff));
+
+	dev_dbg(&intf->dev, "Max oustanding tx = %d URBs\n", dev->max_tx_urbs);
+
 	err = kvaser_usb_get_card_info(dev);
 	if (err) {
 		dev_err(&intf->dev,
@@ -2016,11 +2035,6 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 		return err;
 	}
 
-	dev_dbg(&intf->dev, "Firmware version: %d.%d.%d\n",
-		((dev->fw_version >> 24) & 0xff),
-		((dev->fw_version >> 16) & 0xff),
-		(dev->fw_version & 0xffff));
-
 	for (i = 0; i < dev->nchannels; i++) {
 		err = kvaser_usb_init_one(intf, id, i);
 		if (err) {
-- 
2.1.4
