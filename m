From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 11/16] can: c_can: Provide protection in the xmit path
Date: Tue,  1 Apr 2014 23:42:25 +0200
Message-ID: <1396388550-23081-12-git-send-email-mkl@pengutronix.de>
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

The network core does not serialize the access to the hardware. The
xmit related code lets the following happen:

CPU0 	     	       CPU1
interrupt()
 do_poll()
   c_can_do_tx()
    Fiddle with HW and	xmit()
    internal data	  Fiddle with HW and
    	     		  internal data

due the complete lack of serialization.

Add proper locking.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 9 ++++++++-
 drivers/net/can/c_can/c_can.h | 1 +
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 30a85aa..1fe79ce 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -549,6 +549,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
 
+	spin_lock_bh(&priv->xmit_lock);
 	msg_obj_no = get_tx_next_msg_obj(priv);
 
 	/* prepare message object for transmission */
@@ -563,6 +564,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 	if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv)) ||
 			(priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0)
 		netif_stop_queue(dev);
+	spin_unlock_bh(&priv->xmit_lock);
 
 	return NETDEV_TX_OK;
 }
@@ -787,7 +789,9 @@ static void c_can_do_tx(struct net_device *dev)
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 
-	for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
+	spin_lock_bh(&priv->xmit_lock);
+
+	for (; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
 		msg_obj_no = get_tx_echo_msg_obj(priv);
 		val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG);
 		if (!(val & (1 << (msg_obj_no - 1)))) {
@@ -809,6 +813,8 @@ static void c_can_do_tx(struct net_device *dev)
 	if (((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) != 0) ||
 			((priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) == 0))
 		netif_wake_queue(dev);
+
+	spin_unlock_bh(&priv->xmit_lock);
 }
 
 /*
@@ -1262,6 +1268,7 @@ struct net_device *alloc_c_can_dev(void)
 		return NULL;
 
 	priv = netdev_priv(dev);
+	spin_lock_init(&priv->xmit_lock);
 	netif_napi_add(dev, &priv->napi, c_can_poll, C_CAN_NAPI_WEIGHT);
 
 	priv->dev = dev;
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index d2e1c21..5097c80 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -156,6 +156,7 @@ struct c_can_priv {
 	struct napi_struct napi;
 	struct net_device *dev;
 	struct device *device;
+	spinlock_t xmit_lock;
 	int tx_object;
 	int current_status;
 	int last_status;
-- 
1.9.0.279.gdc9e3eb

