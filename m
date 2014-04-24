From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 21/26] can: c_can: Speed up tx buffer invalidation
Date: Fri, 25 Apr 2014 00:00:24 +0200
Message-ID: <1398376829-6771-22-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46137 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932565AbaDXWAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:00:44 -0400
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

It's suffcient to kill the TXIE bit in the message control register
even if the documentation of C and D CAN says that it's not allowed to
do that while MSGVAL is set. Reality tells a different story and this
change gives us another 2% of CPU back for not waiting on I/O.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 54 +++++++++++++++++++++++++++++++------------
 drivers/net/can/c_can/c_can.h |  1 +
 2 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 99d36bf..a2ca820 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -276,11 +276,34 @@ static inline void c_can_object_put(struct net_device *dev, int iface,
 	c_can_obj_update(dev, iface, cmd | IF_COMM_WR, obj);
 }
 
+/*
+ * Note: According to documentation clearing TXIE while MSGVAL is set
+ * is not allowed, but works nicely on C/DCAN. And that lowers the I/O
+ * load significantly.
+ */
+static void c_can_inval_tx_object(struct net_device *dev, int iface, int obj)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), 0);
+	c_can_object_put(dev, iface, obj, IF_COMM_INVAL);
+}
+
+static void c_can_inval_msg_object(struct net_device *dev, int iface, int obj)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface), 0);
+	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface), 0);
+	c_can_inval_tx_object(dev, iface, obj);
+}
+
 static void c_can_setup_tx_object(struct net_device *dev, int iface,
-				  struct can_frame *frame, int obj)
+				  struct can_frame *frame, int idx)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 	u16 ctrl = IF_MCONT_TX | frame->can_dlc;
+	bool rtr = frame->can_id & CAN_RTR_FLAG;
 	u32 arb = IF_ARB_MSGVAL;
 	int i;
 
@@ -291,9 +314,20 @@ static void c_can_setup_tx_object(struct net_device *dev, int iface,
 		arb |= (frame->can_id & CAN_SFF_MASK) << 18;
 	}
 
-	if (!(frame->can_id & CAN_RTR_FLAG))
+	if (!rtr)
 		arb |= IF_ARB_TRANSMIT;
 
+	/*
+	 * If we change the DIR bit, we need to invalidate the buffer
+	 * first, i.e. clear the MSGVAL flag in the arbiter.
+	 */
+	if (rtr != (bool)test_bit(idx, &priv->tx_dir)) {
+		u32 obj = idx + C_CAN_MSG_OBJ_TX_FIRST;
+
+		c_can_inval_msg_object(dev, iface, obj);
+		change_bit(idx, &priv->tx_dir);
+	}
+
 	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface), arb);
 	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface), arb >> 16);
 
@@ -401,17 +435,6 @@ static void c_can_setup_receive_object(struct net_device *dev, int iface,
 	c_can_object_put(dev, iface, obj, IF_COMM_RCV_SETUP);
 }
 
-static void c_can_inval_msg_object(struct net_device *dev, int iface, int obj)
-{
-	struct c_can_priv *priv = netdev_priv(dev);
-
-	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface), 0);
-	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface), 0);
-	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), 0);
-
-	c_can_object_put(dev, iface, obj, IF_COMM_INVAL);
-}
-
 static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 				    struct net_device *dev)
 {
@@ -436,7 +459,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 	 * can_put_echo_skb(). We must do this before we enable
 	 * transmit as we might race against do_tx().
 	 */
-	c_can_setup_tx_object(dev, IF_TX, frame, obj);
+	c_can_setup_tx_object(dev, IF_TX, frame, idx);
 	priv->dlc[idx] = frame->can_dlc;
 	can_put_echo_skb(skb, dev, idx);
 
@@ -563,6 +586,7 @@ static int c_can_chip_config(struct net_device *dev)
 	/* Clear all internal status */
 	atomic_set(&priv->tx_active, 0);
 	priv->rxmasked = 0;
+	priv->tx_dir = 0;
 
 	/* set bittiming params */
 	return c_can_set_bittiming(dev);
@@ -654,7 +678,7 @@ static void c_can_do_tx(struct net_device *dev)
 		idx--;
 		pend &= ~(1 << idx);
 		obj = idx + C_CAN_MSG_OBJ_TX_FIRST;
-		c_can_inval_msg_object(dev, IF_RX, obj);
+		c_can_inval_tx_object(dev, IF_RX, obj);
 		can_get_echo_skb(dev, idx);
 		bytes += priv->dlc[idx];
 		pkts++;
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index a5f10a0..e7de2b9 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -174,6 +174,7 @@ struct c_can_priv {
 	struct net_device *dev;
 	struct device *device;
 	atomic_t tx_active;
+	unsigned long tx_dir;
 	int last_status;
 	u16 (*read_reg) (struct c_can_priv *priv, enum reg index);
 	void (*write_reg) (struct c_can_priv *priv, enum reg index, u16 val);
-- 
1.9.0.279.gdc9e3eb
