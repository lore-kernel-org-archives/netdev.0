From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v6 6/7] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Mon, 26 Jan 2015 07:29:15 +0200
Message-ID: <20150126052915.GG3014@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150126051755.GA3014@Darwish.PC>
 <20150126052039.GB3014@Darwish.PC>
 <20150126052254.GC3014@Darwish.PC>
 <20150126052406.GD3014@Darwish.PC>
 <20150126052543.GE3014@Darwish.PC>
 <20150126052719.GF3014@Darwish.PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150126052719.GF3014@Darwish.PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Replace most of the can interface's state and error counters
handling with the new can-dev can_change_state() mechanism.

Suggested-by: Andri Yngvason <andri.yngvason@marel.com>
Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c |  113 ++++++++++++++++---------------------
 1 files changed, 49 insertions(+), 64 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index f57ce55..ddc2954 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -620,39 +620,44 @@ static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
 }
 
 static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *priv,
-						 const struct kvaser_usb_error_summary *es)
+						 const struct kvaser_usb_error_summary *es,
+						 struct can_frame *cf)
 {
 	struct net_device_stats *stats;
-	enum can_state new_state;
-
-	stats = &priv->netdev->stats;
-	new_state = priv->can.state;
+	enum can_state cur_state, new_state, tx_state, rx_state;
 
 	netdev_dbg(priv->netdev, "Error status: 0x%02x\n", es->status);
 
-	if (es->status & (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET)) {
-		priv->can.can_stats.bus_off++;
+	stats = &priv->netdev->stats;
+	new_state = cur_state = priv->can.state;
+
+	if (es->status & (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET))
 		new_state = CAN_STATE_BUS_OFF;
-	} else if (es->status & M16C_STATE_BUS_PASSIVE) {
-		if (priv->can.state != CAN_STATE_ERROR_PASSIVE)
-			priv->can.can_stats.error_passive++;
+	else if (es->status & M16C_STATE_BUS_PASSIVE)
 		new_state = CAN_STATE_ERROR_PASSIVE;
-	} else if (es->status & M16C_STATE_BUS_ERROR) {
-		if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
-		    ((es->txerr >= 96) || (es->rxerr >= 96))) {
-			priv->can.can_stats.error_warning++;
+	else if (es->status & M16C_STATE_BUS_ERROR) {
+		if ((es->txerr >= 256) || (es->rxerr >= 256))
+			new_state = CAN_STATE_BUS_OFF;
+		else if ((es->txerr >= 128) || (es->rxerr >= 128))
+			new_state = CAN_STATE_ERROR_PASSIVE;
+		else if ((es->txerr >= 96) || (es->rxerr >= 96))
 			new_state = CAN_STATE_ERROR_WARNING;
-		} else if ((priv->can.state > CAN_STATE_ERROR_ACTIVE) &&
-			   ((es->txerr < 96) && (es->rxerr < 96))) {
+		else if (cur_state > CAN_STATE_ERROR_ACTIVE)
 			new_state = CAN_STATE_ERROR_ACTIVE;
-		}
 	}
 
 	if (!es->status)
 		new_state = CAN_STATE_ERROR_ACTIVE;
 
+	if (new_state != cur_state) {
+		tx_state = (es->txerr >= es->rxerr) ? new_state : 0;
+		rx_state = (es->txerr <= es->rxerr) ? new_state : 0;
+
+		can_change_state(priv->netdev, cf, tx_state, rx_state);
+	}
+
 	if (priv->can.restart_ms &&
-	    (priv->can.state >= CAN_STATE_BUS_OFF) &&
+	    (cur_state >= CAN_STATE_BUS_OFF) &&
 	    (new_state < CAN_STATE_BUS_OFF)) {
 		priv->can.can_stats.restarts++;
 	}
@@ -664,18 +669,17 @@ static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *pri
 
 	priv->bec.txerr = es->txerr;
 	priv->bec.rxerr = es->rxerr;
-	priv->can.state = new_state;
 }
 
 static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 				const struct kvaser_msg *msg)
 {
-	struct can_frame *cf;
+	struct can_frame *cf, tmp_cf = { .can_id = CAN_ERR_FLAG, .can_dlc = CAN_ERR_DLC };
 	struct sk_buff *skb;
 	struct net_device_stats *stats;
 	struct kvaser_usb_net_priv *priv;
 	struct kvaser_usb_error_summary es = { };
-	enum can_state old_state;
+	enum can_state old_state, new_state;
 
 	switch (msg->id) {
 	case CMD_CAN_ERROR_EVENT:
@@ -715,59 +719,40 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 	stats = &priv->netdev->stats;
 
 	/* Update all of the can interface's state and error counters before
-	 * trying any skb allocation that can actually fail with -ENOMEM.
+	 * trying any memory allocation that can actually fail with -ENOMEM.
+	 *
+	 * We send a temporary stack-allocated error can frame to
+	 * can_change_state() for the very same reason.
+	 *
+	 * TODO: Split can_change_state() responsibility between updating the
+	 * can interface's state and counters, and the setting up of can error
+	 * frame ID and data to userspace. Remove stack allocation afterwards.
 	 */
 	old_state = priv->can.state;
-	kvaser_usb_rx_error_update_can_state(priv, &es);
+	kvaser_usb_rx_error_update_can_state(priv, &es, &tmp_cf);
+	new_state = priv->can.state;
 
 	skb = alloc_can_err_skb(priv->netdev, &cf);
 	if (!skb) {
 		stats->rx_dropped++;
 		return;
 	}
-
-	if (es.status & (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET)) {
-		cf->can_id |= CAN_ERR_BUSOFF;
-
-		if (!priv->can.restart_ms)
-			kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
-		netif_carrier_off(priv->netdev);
-	} else if (es.status & M16C_STATE_BUS_PASSIVE) {
-		if (old_state != CAN_STATE_ERROR_PASSIVE) {
-			cf->can_id |= CAN_ERR_CRTL;
-
-			if (es.txerr || es.rxerr)
-				cf->data[1] = (es.txerr > es.rxerr)
-						? CAN_ERR_CRTL_TX_PASSIVE
-						: CAN_ERR_CRTL_RX_PASSIVE;
-			else
-				cf->data[1] = CAN_ERR_CRTL_TX_PASSIVE |
-					      CAN_ERR_CRTL_RX_PASSIVE;
-		}
-	} else if (es.status & M16C_STATE_BUS_ERROR) {
-		if ((old_state < CAN_STATE_ERROR_WARNING) &&
-		    ((es.txerr >= 96) || (es.rxerr >= 96))) {
-			cf->can_id |= CAN_ERR_CRTL;
-			cf->data[1] = (es.txerr > es.rxerr)
-					? CAN_ERR_CRTL_TX_WARNING
-					: CAN_ERR_CRTL_RX_WARNING;
-		} else if ((old_state > CAN_STATE_ERROR_ACTIVE) &&
-			   ((es.txerr < 96) && (es.rxerr < 96))) {
-			cf->can_id |= CAN_ERR_PROT;
-			cf->data[2] = CAN_ERR_PROT_ACTIVE;
+	memcpy(cf, &tmp_cf, sizeof(*cf));
+
+	if (new_state != old_state) {
+		if (es.status &
+		    (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET)) {
+			if (!priv->can.restart_ms)
+				kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
+			netif_carrier_off(priv->netdev);
 		}
-	}
-
-	if (!es.status) {
-		cf->can_id |= CAN_ERR_PROT;
-		cf->data[2] = CAN_ERR_PROT_ACTIVE;
-	}
 
-	if (priv->can.restart_ms &&
-	    (old_state >= CAN_STATE_BUS_OFF) &&
-	    (priv->can.state < CAN_STATE_BUS_OFF)) {
-		cf->can_id |= CAN_ERR_RESTARTED;
-		netif_carrier_on(priv->netdev);
+		if (priv->can.restart_ms &&
+		    (old_state >= CAN_STATE_BUS_OFF) &&
+		    (new_state < CAN_STATE_BUS_OFF)) {
+			cf->can_id |= CAN_ERR_RESTARTED;
+			netif_carrier_on(priv->netdev);
+		}
 	}
 
 	if (es.error_factor) {
-- 
1.7.7.6
