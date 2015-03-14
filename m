From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v4 2/3] can: kvaser_usb: Utilize all possible tx URBs
Date: Sat, 14 Mar 2015 09:09:52 -0400
Message-ID: <20150314130952.GB20796@linux>
References: <20150226152011.GA6075@linux>
 <20150314130249.GA20796@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150314130249.GA20796@linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

The driver currently limits the number of outstanding, not yet
ACKed, transfers to 16 URBs. Meanwhile, the Kvaser firmware
provides its actual max supported number of outstanding
transmissions in its reply to the CMD_GET_SOFTWARE_INFO message.

One example is the UsbCan-II HS/LS device which reports support
of up to 48 tx URBs instead of just 16, increasing the driver
throughput by two-fold and reducing the possibility of -ENOBUFs.

Dynamically set the max tx URBs value according to firmware
replies.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c | 64 ++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 25 deletions(-)

Changelog v4: Allocate the now-dynamically-sized tx_contexts[]
array as a C99 "flexible array member", insuring automatic proper
de-allocation on driver exit.

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index e97a08c..60eadf5 100644
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
@@ -1928,7 +1940,7 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 		return err;
 	}
 
-	netdev_dbg(netdev, "device registered\n");
+	netdev_info(netdev, "device registered\n");
 
 	return 0;
 }
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
1.9.1
