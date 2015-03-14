From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: kvaser_usb: Fix tx queue start/stop race conditions
Date: Sat, 14 Mar 2015 15:17:19 +0100
Message-ID: <1426342639-14894-3-git-send-email-mkl@pengutronix.de>
References: <1426342639-14894-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38645 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904AbbCNOR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 10:17:26 -0400
In-Reply-To: <1426342639-14894-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

A number of tx queue wake-up events went missing due to the
outlined scenario below. Start state is a pool of 16 tx URBs,
active tx_urbs count = 15, with the netdev tx queue open.

CPU #1 [softirq]                         CPU #2 [softirq]
start_xmit()                             tx_acknowledge()
................                         ................

atomic_inc(&tx_urbs);
if (atomic_read(&tx_urbs) >= 16) {
                        -->
                                         atomic_dec(&tx_urbs);
                                         netif_wake_queue();
                                         return;
                        <--
    netif_stop_queue();
}

At the end, the correct state expected is a 15 tx_urbs count
value with the tx queue state _open_. Due to the race, we get
the same tx_urbs value but with the tx queue state _stopped_.
The wake-up event is completely lost.

Thus avoid hand-rolled concurrency mechanisms and use a proper
lock for contexts and tx queue protection.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 83 ++++++++++++++++++++++++----------------
 1 file changed, 51 insertions(+), 32 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index a316fa4b91ab..e97a08ce0b90 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -14,6 +14,7 @@
  * Copyright (C) 2015 Valeo S.A.
  */
 
+#include <linux/spinlock.h>
 #include <linux/kernel.h>
 #include <linux/completion.h>
 #include <linux/module.h>
@@ -467,10 +468,11 @@ struct kvaser_usb {
 struct kvaser_usb_net_priv {
 	struct can_priv can;
 
-	atomic_t active_tx_urbs;
-	struct usb_anchor tx_submitted;
+	spinlock_t tx_contexts_lock;
+	int active_tx_contexts;
 	struct kvaser_usb_tx_urb_context tx_contexts[MAX_TX_URBS];
 
+	struct usb_anchor tx_submitted;
 	struct completion start_comp, stop_comp;
 
 	struct kvaser_usb *dev;
@@ -694,6 +696,7 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
 	struct kvaser_usb_net_priv *priv;
 	struct sk_buff *skb;
 	struct can_frame *cf;
+	unsigned long flags;
 	u8 channel, tid;
 
 	channel = msg->u.tx_acknowledge_header.channel;
@@ -737,12 +740,15 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
 
 	stats->tx_packets++;
 	stats->tx_bytes += context->dlc;
-	can_get_echo_skb(priv->netdev, context->echo_index);
 
-	context->echo_index = MAX_TX_URBS;
-	atomic_dec(&priv->active_tx_urbs);
+	spin_lock_irqsave(&priv->tx_contexts_lock, flags);
 
+	can_get_echo_skb(priv->netdev, context->echo_index);
+	context->echo_index = MAX_TX_URBS;
+	--priv->active_tx_contexts;
 	netif_wake_queue(priv->netdev);
+
+	spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);
 }
 
 static void kvaser_usb_simple_msg_callback(struct urb *urb)
@@ -803,17 +809,6 @@ static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
 	return 0;
 }
 
-static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
-{
-	int i;
-
-	usb_kill_anchored_urbs(&priv->tx_submitted);
-	atomic_set(&priv->active_tx_urbs, 0);
-
-	for (i = 0; i < MAX_TX_URBS; i++)
-		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
-}
-
 static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *priv,
 						 const struct kvaser_usb_error_summary *es,
 						 struct can_frame *cf)
@@ -1515,6 +1510,24 @@ error:
 	return err;
 }
 
+static void kvaser_usb_reset_tx_urb_contexts(struct kvaser_usb_net_priv *priv)
+{
+	int i;
+
+	priv->active_tx_contexts = 0;
+	for (i = 0; i < MAX_TX_URBS; i++)
+		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
+}
+
+/* This method might sleep. Do not call it in the atomic context
+ * of URB completions.
+ */
+static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
+{
+	usb_kill_anchored_urbs(&priv->tx_submitted);
+	kvaser_usb_reset_tx_urb_contexts(priv);
+}
+
 static void kvaser_usb_unlink_all_urbs(struct kvaser_usb *dev)
 {
 	int i;
@@ -1634,6 +1647,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	struct kvaser_msg *msg;
 	int i, err, ret = NETDEV_TX_OK;
 	u8 *msg_tx_can_flags = NULL;		/* GCC */
+	unsigned long flags;
 
 	if (can_dropped_invalid_skb(netdev, skb))
 		return NETDEV_TX_OK;
@@ -1687,12 +1701,21 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	if (cf->can_id & CAN_RTR_FLAG)
 		*msg_tx_can_flags |= MSG_FLAG_REMOTE_FRAME;
 
+	spin_lock_irqsave(&priv->tx_contexts_lock, flags);
 	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
 		if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
 			context = &priv->tx_contexts[i];
+
+			context->echo_index = i;
+			can_put_echo_skb(skb, netdev, context->echo_index);
+			++priv->active_tx_contexts;
+			if (priv->active_tx_contexts >= MAX_TX_URBS)
+				netif_stop_queue(netdev);
+
 			break;
 		}
 	}
+	spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);
 
 	/* This should never happen; it implies a flow control bug */
 	if (!context) {
@@ -1704,7 +1727,6 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	}
 
 	context->priv = priv;
-	context->echo_index = i;
 	context->dlc = cf->can_dlc;
 
 	msg->u.tx_can.tid = context->echo_index;
@@ -1716,18 +1738,17 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 			  kvaser_usb_write_bulk_callback, context);
 	usb_anchor_urb(urb, &priv->tx_submitted);
 
-	can_put_echo_skb(skb, netdev, context->echo_index);
-
-	atomic_inc(&priv->active_tx_urbs);
-
-	if (atomic_read(&priv->active_tx_urbs) >= MAX_TX_URBS)
-		netif_stop_queue(netdev);
-
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (unlikely(err)) {
+		spin_lock_irqsave(&priv->tx_contexts_lock, flags);
+
 		can_free_echo_skb(netdev, context->echo_index);
+		context->echo_index = MAX_TX_URBS;
+		--priv->active_tx_contexts;
+		netif_wake_queue(netdev);
+
+		spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);
 
-		atomic_dec(&priv->active_tx_urbs);
 		usb_unanchor_urb(urb);
 
 		stats->tx_dropped++;
@@ -1854,7 +1875,7 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 	struct kvaser_usb *dev = usb_get_intfdata(intf);
 	struct net_device *netdev;
 	struct kvaser_usb_net_priv *priv;
-	int i, err;
+	int err;
 
 	err = kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, channel);
 	if (err)
@@ -1868,19 +1889,17 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 
 	priv = netdev_priv(netdev);
 
+	init_usb_anchor(&priv->tx_submitted);
 	init_completion(&priv->start_comp);
 	init_completion(&priv->stop_comp);
 
-	init_usb_anchor(&priv->tx_submitted);
-	atomic_set(&priv->active_tx_urbs, 0);
-
-	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++)
-		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
-
 	priv->dev = dev;
 	priv->netdev = netdev;
 	priv->channel = channel;
 
+	spin_lock_init(&priv->tx_contexts_lock);
+	kvaser_usb_reset_tx_urb_contexts(priv);
+
 	priv->can.state = CAN_STATE_STOPPED;
 	priv->can.clock.freq = CAN_USB_CLOCK;
 	priv->can.bittiming_const = &kvaser_usb_bittiming_const;
-- 
2.1.4
