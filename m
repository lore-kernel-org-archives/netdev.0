From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 15/16] can: c_can: Simplify TX interrupt cleanup
Date: Tue,  1 Apr 2014 23:42:29 +0200
Message-ID: <1396388550-23081-16-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

The function loads the message object from the hardware to get the
payload length. The previous patch stores that information in an
array, so we can avoid the hardware access.

Remove the hardware access and move the led toggle outside of the
spinlocked region. Toggle the led only once when at least one packet
has been received.

Binary size shrinks along with the code

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 37 +++++++++++++++++--------------------
 1 file changed, 17 insertions(+), 20 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 1e75223..42c038d 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -232,10 +232,9 @@ static inline int get_tx_next_msg_obj(const struct c_can_priv *priv)
 			C_CAN_MSG_OBJ_TX_FIRST;
 }
 
-static inline int get_tx_echo_msg_obj(const struct c_can_priv *priv)
+static inline int get_tx_echo_msg_obj(int txecho)
 {
-	return (priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) +
-			C_CAN_MSG_OBJ_TX_FIRST;
+	return (txecho & C_CAN_NEXT_MSG_OBJ_MASK) + C_CAN_MSG_OBJ_TX_FIRST;
 }
 
 static u32 c_can_read_reg32(struct c_can_priv *priv, enum reg index)
@@ -729,8 +728,6 @@ static int c_can_get_berr_counter(const struct net_device *dev,
 }
 
 /*
- * theory of operation:
- *
  * priv->tx_echo holds the number of the oldest can_frame put for
  * transmission into the hardware, but not yet ACKed by the CAN tx
  * complete IRQ.
@@ -741,29 +738,23 @@ static int c_can_get_berr_counter(const struct net_device *dev,
  */
 static void c_can_do_tx(struct net_device *dev)
 {
-	u32 val;
-	u32 msg_obj_no;
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
+	u32 val, obj, pkts = 0, bytes = 0;
 
 	spin_lock_bh(&priv->xmit_lock);
 
 	for (; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
-		msg_obj_no = get_tx_echo_msg_obj(priv);
+		obj = get_tx_echo_msg_obj(priv->tx_echo);
 		val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG);
-		if (!(val & (1 << (msg_obj_no - 1)))) {
-			can_get_echo_skb(dev,
-					msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
-			c_can_object_get(dev, IF_TX, msg_obj_no, IF_COMM_ALL);
-			stats->tx_bytes += priv->read_reg(priv,
-					C_CAN_IFACE(MSGCTRL_REG, IF_TX))
-					& IF_MCONT_DLC_MASK;
-			stats->tx_packets++;
-			can_led_event(dev, CAN_LED_EVENT_TX);
-			c_can_inval_msg_object(dev, IF_TX, msg_obj_no);
-		} else {
+
+		if (val & (1 << (obj - 1)))
 			break;
-		}
+
+		can_get_echo_skb(dev, obj - C_CAN_MSG_OBJ_TX_FIRST);
+		bytes += priv->dlc[obj - C_CAN_MSG_OBJ_TX_FIRST];
+		pkts++;
+		c_can_inval_msg_object(dev, IF_TX, obj);
 	}
 
 	/* restart queue if wrap-up or if queue stalled on last pkt */
@@ -772,6 +763,12 @@ static void c_can_do_tx(struct net_device *dev)
 		netif_wake_queue(dev);
 
 	spin_unlock_bh(&priv->xmit_lock);
+
+	if (pkts) {
+		stats->tx_bytes += bytes;
+		stats->tx_packets += pkts;
+		can_led_event(dev, CAN_LED_EVENT_TX);
+	}
 }
 
 /*
-- 
1.9.0.279.gdc9e3eb

