From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 07/12] can: c_can: Provide protection in the xmit path
Date: Tue, 18 Mar 2014 17:19:12 -0000
Message-ID: <20140318171127.306582080@linutronix.de>
References: <20140318171007.528610837@linutronix.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=can-c_can-fix-xmit.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 drivers/net/can/c_can/c_can.c |    9 ++++++++-
 drivers/net/can/c_can/c_can.h |    1 +
 2 files changed, 9 insertions(+), 1 deletion(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
@@ -549,6 +549,7 @@ static netdev_tx_t c_can_start_xmit(stru
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
 
+	spin_lock_bh(&priv->xmit_lock);
 	msg_obj_no = get_tx_next_msg_obj(priv);
 
 	/* prepare message object for transmission */
@@ -563,6 +564,7 @@ static netdev_tx_t c_can_start_xmit(stru
 	if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv)) ||
 			(priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0)
 		netif_stop_queue(dev);
+	spin_unlock_bh(&priv->xmit_lock);
 
 	return NETDEV_TX_OK;
 }
@@ -778,7 +780,9 @@ static void c_can_do_tx(struct net_devic
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 
-	for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
+	spin_lock_bh(&priv->xmit_lock);
+
+	for (; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
 		msg_obj_no = get_tx_echo_msg_obj(priv);
 		val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG);
 		if (!(val & (1 << (msg_obj_no - 1)))) {
@@ -800,6 +804,8 @@ static void c_can_do_tx(struct net_devic
 	if (((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) != 0) ||
 			((priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) == 0))
 		netif_wake_queue(dev);
+
+	spin_unlock_bh(&priv->xmit_lock);
 }
 
 /*
@@ -1250,6 +1256,7 @@ struct net_device *alloc_c_can_dev(void)
 		return NULL;
 
 	priv = netdev_priv(dev);
+	spin_lock_init(&priv->xmit_lock);
 	netif_napi_add(dev, &priv->napi, c_can_poll, C_CAN_NAPI_WEIGHT);
 
 	priv->dev = dev;
Index: linux/drivers/net/can/c_can/c_can.h
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.h
+++ linux/drivers/net/can/c_can/c_can.h
@@ -156,6 +156,7 @@ struct c_can_priv {
 	struct napi_struct napi;
 	struct net_device *dev;
 	struct device *device;
+	spinlock_t xmit_lock;
 	int tx_object;
 	int current_status;
 	int last_status;
