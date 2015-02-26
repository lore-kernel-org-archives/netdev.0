From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 5/5] can: kvaser_usb: Fix tx queue start/stop race conditions
Date: Thu, 26 Feb 2015 10:29:22 -0500
Message-ID: <20150226152922.GE6075@linux>
References: <20150226152011.GA6075@linux>
 <20150226152202.GB6075@linux>
 <20150226152436.GC6075@linux>
 <20150226152558.GD6075@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150226152558.GD6075@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

A number of tx queue wake-up events went missing due to the
outlined scenario below. Start state is a pool of 16 tx URBs,
active tx_urbs count = 15, with the netdev tx queue open.

start_xmit()                             tx_acknowledge()
............                             ................
atomic_inc(&tx_urbs);
if (atomic_read(&tx_urbs) >= 16) {
                        URB completion IRQ!
                        -->
                                         atomic_dec(&tx_urbs);
                                         netif_wake_queue();
                                         return;
                        <--
                        end of IRQ!
    netif_stop_queue();
}

At the end, the correct state expected is a 15 tx_urbs count
value with the tx queue state _open_. Due to the race, we get
the same tx_urbs value but with the tx queue state _stopped_.
The wake-up event is completely lost.

Thus avoid hand-rolled concurrency mechanisms and use a proper
lock for contexts protection.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c | 82 +++++++++++++++++++++++++---------------
 1 file changed, 51 insertions(+), 31 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 13bae86..807ab0c 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -14,6 +14,7 @@
  * Copyright (C) 2015 Valeo S.A.
  */
 
+#include <linux/spinlock.h>
 #include <linux/kernel.h>
 #include <linux/completion.h>
 #include <linux/module.h>
@@ -471,10 +472,12 @@ struct kvaser_usb {
 struct kvaser_usb_net_priv {
 	struct can_priv can;
 
-	atomic_t active_tx_urbs;
-	struct usb_anchor tx_submitted;
+	spinlock_t tx_contexts_lock;
+	int active_tx_contexts;
 	struct kvaser_usb_tx_urb_context *tx_contexts;
 
+	struct usb_anchor tx_submitted;
+
 	struct completion start_comp, stop_comp;
 
 	struct kvaser_usb *dev;
@@ -702,6 +705,7 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
 	struct kvaser_usb_net_priv *priv;
 	struct sk_buff *skb;
 	struct can_frame *cf;
+	unsigned long flags;
 	u8 channel, tid;
 
 	channel = msg->u.tx_acknowledge_header.channel;
@@ -745,12 +749,15 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
 
 	stats->tx_packets++;
 	stats->tx_bytes += context->dlc;
-	can_get_echo_skb(priv->netdev, context->echo_index);
 
-	context->echo_index = dev->max_tx_urbs;
-	atomic_dec(&priv->active_tx_urbs);
+	spin_lock_irqsave(&priv->tx_contexts_lock, flags);
 
+	can_get_echo_skb(priv->netdev, context->echo_index);
+	context->echo_index = dev->max_tx_urbs;
+	--priv->active_tx_contexts;
 	netif_wake_queue(priv->netdev);
+
+	spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);
 }
 
 static void kvaser_usb_simple_msg_callback(struct urb *urb)
@@ -811,18 +818,6 @@ static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
 	return 0;
 }
 
-static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
-{
-	struct kvaser_usb *dev = priv->dev;
-	int i;
-
-	usb_kill_anchored_urbs(&priv->tx_submitted);
-	atomic_set(&priv->active_tx_urbs, 0);
-
-	for (i = 0; i < dev->max_tx_urbs; i++)
-		priv->tx_contexts[i].echo_index = dev->max_tx_urbs;
-}
-
 static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *priv,
 						 const struct kvaser_usb_error_summary *es,
 						 struct can_frame *cf)
@@ -1524,6 +1519,26 @@ error:
 	return err;
 }
 
+static void kvaser_usb_reset_tx_urb_contexts(struct kvaser_usb_net_priv *priv)
+{
+	int i, max_tx_urbs;
+
+	max_tx_urbs = priv->dev->max_tx_urbs;
+
+	priv->active_tx_contexts = 0;
+	for (i = 0; i < max_tx_urbs; i++)
+		priv->tx_contexts[i].echo_index = max_tx_urbs;
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
@@ -1643,6 +1658,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	struct kvaser_msg *msg;
 	int i, err, ret = NETDEV_TX_OK;
 	u8 *msg_tx_can_flags = NULL;		/* GCC */
+	unsigned long flags;
 
 	if (can_dropped_invalid_skb(netdev, skb))
 		return NETDEV_TX_OK;
@@ -1696,12 +1712,21 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	if (cf->can_id & CAN_RTR_FLAG)
 		*msg_tx_can_flags |= MSG_FLAG_REMOTE_FRAME;
 
+	spin_lock_irqsave(&priv->tx_contexts_lock, flags);
 	for (i = 0; i < dev->max_tx_urbs; i++) {
 		if (priv->tx_contexts[i].echo_index ==  dev->max_tx_urbs) {
 			context = &priv->tx_contexts[i];
+
+			context->echo_index = i;
+			can_put_echo_skb(skb, netdev, context->echo_index);
+			++priv->active_tx_contexts;
+			if (priv->active_tx_contexts >= dev->max_tx_urbs)
+				netif_stop_queue(netdev);
+
 			break;
 		}
 	}
+	spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);
 
 	/* This should never happen; it implies a flow control bug */
 	if (!context) {
@@ -1713,7 +1738,6 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	}
 
 	context->priv = priv;
-	context->echo_index = i;
 	context->dlc = cf->can_dlc;
 
 	msg->u.tx_can.tid = context->echo_index;
@@ -1725,18 +1749,17 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 			  kvaser_usb_write_bulk_callback, context);
 	usb_anchor_urb(urb, &priv->tx_submitted);
 
-	can_put_echo_skb(skb, netdev, context->echo_index);
-
-	atomic_inc(&priv->active_tx_urbs);
-
-	if (atomic_read(&priv->active_tx_urbs) >= dev->max_tx_urbs)
-		netif_stop_queue(netdev);
-
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (unlikely(err)) {
+		spin_lock_irqsave(&priv->tx_contexts_lock, flags);
+
 		can_free_echo_skb(netdev, context->echo_index);
+		context->echo_index = dev->max_tx_urbs;
+		--priv->active_tx_contexts;
+		netif_wake_queue(netdev);
+
+		spin_unlock_irqrestore(&priv->tx_contexts_lock, flags);
 
-		atomic_dec(&priv->active_tx_urbs);
 		usb_unanchor_urb(urb);
 
 		stats->tx_dropped++;
@@ -1863,7 +1886,7 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 	struct kvaser_usb *dev = usb_get_intfdata(intf);
 	struct net_device *netdev;
 	struct kvaser_usb_net_priv *priv;
-	int i, err;
+	int err;
 
 	err = kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, channel);
 	if (err)
@@ -1892,10 +1915,7 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 	priv->channel = channel;
 
 	init_usb_anchor(&priv->tx_submitted);
-	atomic_set(&priv->active_tx_urbs, 0);
-
-	for (i = 0; i < dev->max_tx_urbs; i++)
-		priv->tx_contexts[i].echo_index = dev->max_tx_urbs;
+	kvaser_usb_reset_tx_urb_contexts(priv);
 
 	priv->can.state = CAN_STATE_STOPPED;
 	priv->can.clock.freq = CAN_USB_CLOCK;
-- 
1.9.1

