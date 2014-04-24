From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 20/26] can: c_can: Remove tx locking
Date: Fri, 25 Apr 2014 00:00:23 +0200
Message-ID: <1398376829-6771-21-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46134 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932561AbaDXWAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:00:44 -0400
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

Mark suggested to use one IF for the softirq and the other for the
xmit function to avoid the xmit lock.

That requires to write the frame into the interface first, then handle
the echo skb and store the dlc before committing the TX request to the
message ram.

We use an atomic to handle the active buffers instead of reading the
MSGVAL register as thats way faster especially on PCH/x86.

Suggested-by: Mark <mark5@del-llc.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 127 ++++++++++++++----------------------------
 drivers/net/can/c_can/c_can.h |   8 +--
 2 files changed, 43 insertions(+), 92 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 61fde41..99d36bf 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -237,24 +237,6 @@ static inline void c_can_reset_ram(const struct c_can_priv *priv, bool enable)
 		priv->raminit(priv, enable);
 }
 
-static inline int get_tx_next_msg_obj(const struct c_can_priv *priv)
-{
-	return (priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) +
-			C_CAN_MSG_OBJ_TX_FIRST;
-}
-
-static inline int get_tx_echo_msg_obj(int txecho)
-{
-	return (txecho & C_CAN_NEXT_MSG_OBJ_MASK) + C_CAN_MSG_OBJ_TX_FIRST;
-}
-
-static u32 c_can_read_reg32(struct c_can_priv *priv, enum reg index)
-{
-	u32 val = priv->read_reg(priv, index);
-	val |= ((u32) priv->read_reg(priv, index + 1)) << 16;
-	return val;
-}
-
 static void c_can_irq_control(struct c_can_priv *priv, bool enable)
 {
 	u32 ctrl = priv->read_reg(priv,	C_CAN_CTRL_REG) & ~CONTROL_IRQMSK;
@@ -294,8 +276,8 @@ static inline void c_can_object_put(struct net_device *dev, int iface,
 	c_can_obj_update(dev, iface, cmd | IF_COMM_WR, obj);
 }
 
-static void c_can_write_msg_object(struct net_device *dev, int iface,
-				   struct can_frame *frame, int obj)
+static void c_can_setup_tx_object(struct net_device *dev, int iface,
+				  struct can_frame *frame, int obj)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 	u16 ctrl = IF_MCONT_TX | frame->can_dlc;
@@ -321,8 +303,6 @@ static void c_can_write_msg_object(struct net_device *dev, int iface,
 		priv->write_reg(priv, C_CAN_IFACE(DATA1_REG, iface) + i / 2,
 				frame->data[i] | (frame->data[i + 1] << 8));
 	}
-
-	c_can_object_put(dev, iface, obj, IF_COMM_TX);
 }
 
 static inline void c_can_activate_all_lower_rx_msg_obj(struct net_device *dev,
@@ -432,47 +412,38 @@ static void c_can_inval_msg_object(struct net_device *dev, int iface, int obj)
 	c_can_object_put(dev, iface, obj, IF_COMM_INVAL);
 }
 
-static inline int c_can_is_next_tx_obj_busy(struct c_can_priv *priv, int objno)
-{
-	int val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG);
-
-	/*
-	 * as transmission request register's bit n-1 corresponds to
-	 * message object n, we need to handle the same properly.
-	 */
-	if (val & (1 << (objno - 1)))
-		return 1;
-
-	return 0;
-}
-
 static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
-					struct net_device *dev)
+				    struct net_device *dev)
 {
-	u32 msg_obj_no;
-	struct c_can_priv *priv = netdev_priv(dev);
 	struct can_frame *frame = (struct can_frame *)skb->data;
+	struct c_can_priv *priv = netdev_priv(dev);
+	u32 idx, obj;
 
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
-
-	spin_lock_bh(&priv->xmit_lock);
-	msg_obj_no = get_tx_next_msg_obj(priv);
-
-	/* prepare message object for transmission */
-	c_can_write_msg_object(dev, IF_TX, frame, msg_obj_no);
-	priv->dlc[msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST] = frame->can_dlc;
-	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
-
 	/*
-	 * we have to stop the queue in case of a wrap around or
-	 * if the next TX message object is still in use
+	 * This is not a FIFO. C/D_CAN sends out the buffers
+	 * prioritized. The lowest buffer number wins.
 	 */
-	priv->tx_next++;
-	if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv)) ||
-			(priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0)
+	idx = fls(atomic_read(&priv->tx_active));
+	obj = idx + C_CAN_MSG_OBJ_TX_FIRST;
+
+	/* If this is the last buffer, stop the xmit queue */
+	if (idx == C_CAN_MSG_OBJ_TX_NUM - 1)
 		netif_stop_queue(dev);
-	spin_unlock_bh(&priv->xmit_lock);
+	/*
+	 * Store the message in the interface so we can call
+	 * can_put_echo_skb(). We must do this before we enable
+	 * transmit as we might race against do_tx().
+	 */
+	c_can_setup_tx_object(dev, IF_TX, frame, obj);
+	priv->dlc[idx] = frame->can_dlc;
+	can_put_echo_skb(skb, dev, idx);
+
+	/* Update the active bits */
+	atomic_add((1 << idx), &priv->tx_active);
+	/* Start transmission */
+	c_can_object_put(dev, IF_TX, obj, IF_COMM_TX);
 
 	return NETDEV_TX_OK;
 }
@@ -589,6 +560,10 @@ static int c_can_chip_config(struct net_device *dev)
 	/* set a `lec` value so that we can check for updates later */
 	priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
 
+	/* Clear all internal status */
+	atomic_set(&priv->tx_active, 0);
+	priv->rxmasked = 0;
+
 	/* set bittiming params */
 	return c_can_set_bittiming(dev);
 }
@@ -609,10 +584,6 @@ static int c_can_start(struct net_device *dev)
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
-	/* reset tx helper pointers and the rx mask */
-	priv->tx_next = priv->tx_echo = 0;
-	priv->rxmasked = 0;
-
 	return 0;
 }
 
@@ -671,42 +642,29 @@ static int c_can_get_berr_counter(const struct net_device *dev,
 	return err;
 }
 
-/*
- * priv->tx_echo holds the number of the oldest can_frame put for
- * transmission into the hardware, but not yet ACKed by the CAN tx
- * complete IRQ.
- *
- * We iterate from priv->tx_echo to priv->tx_next and check if the
- * packet has been transmitted, echo it back to the CAN framework.
- * If we discover a not yet transmitted packet, stop looking for more.
- */
 static void c_can_do_tx(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
-	u32 val, obj, pkts = 0, bytes = 0;
+	u32 idx, obj, pkts = 0, bytes = 0, pend, clr;
 
-	spin_lock_bh(&priv->xmit_lock);
+	clr = pend = priv->read_reg(priv, C_CAN_INTPND2_REG);
 
-	for (; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
-		obj = get_tx_echo_msg_obj(priv->tx_echo);
-		val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG);
-
-		if (val & (1 << (obj - 1)))
-			break;
-
-		can_get_echo_skb(dev, obj - C_CAN_MSG_OBJ_TX_FIRST);
-		bytes += priv->dlc[obj - C_CAN_MSG_OBJ_TX_FIRST];
+	while ((idx = ffs(pend))) {
+		idx--;
+		pend &= ~(1 << idx);
+		obj = idx + C_CAN_MSG_OBJ_TX_FIRST;
+		c_can_inval_msg_object(dev, IF_RX, obj);
+		can_get_echo_skb(dev, idx);
+		bytes += priv->dlc[idx];
 		pkts++;
-		c_can_inval_msg_object(dev, IF_TX, obj);
 	}
 
-	/* restart queue if wrap-up or if queue stalled on last pkt */
-	if (((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) != 0) ||
-			((priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) == 0))
-		netif_wake_queue(dev);
+	/* Clear the bits in the tx_active mask */
+	atomic_sub(clr, &priv->tx_active);
 
-	spin_unlock_bh(&priv->xmit_lock);
+	if (clr & (1 << (C_CAN_MSG_OBJ_TX_NUM - 1)))
+		netif_wake_queue(dev);
 
 	if (pkts) {
 		stats->tx_bytes += bytes;
@@ -1192,7 +1150,6 @@ struct net_device *alloc_c_can_dev(void)
 		return NULL;
 
 	priv = netdev_priv(dev);
-	spin_lock_init(&priv->xmit_lock);
 	netif_napi_add(dev, &priv->napi, c_can_poll, C_CAN_NAPI_WEIGHT);
 
 	priv->dev = dev;
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index d9f59cc4..a5f10a0 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -37,8 +37,6 @@
 
 #define C_CAN_MSG_OBJ_RX_SPLIT	9
 #define C_CAN_MSG_RX_LOW_LAST	(C_CAN_MSG_OBJ_RX_SPLIT - 1)
-
-#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
 #define RECEIVE_OBJECT_BITS	0x0000ffff
 
 enum reg {
@@ -175,16 +173,12 @@ struct c_can_priv {
 	struct napi_struct napi;
 	struct net_device *dev;
 	struct device *device;
-	spinlock_t xmit_lock;
-	int tx_object;
+	atomic_t tx_active;
 	int last_status;
 	u16 (*read_reg) (struct c_can_priv *priv, enum reg index);
 	void (*write_reg) (struct c_can_priv *priv, enum reg index, u16 val);
 	void __iomem *base;
 	const u16 *regs;
-	unsigned long irq_flags; /* for request_irq() */
-	unsigned int tx_next;
-	unsigned int tx_echo;
 	void *priv;		/* for board-specific data */
 	enum c_can_dev_id type;
 	u32 __iomem *raminit_ctrlreg;
-- 
1.9.0.279.gdc9e3eb
