From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 04/16] can: c_can: check return value to users of c_can_set_bittiming()
Date: Tue,  1 Apr 2014 23:42:18 +0200
Message-ID: <1396388550-23081-5-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds return value checking to all direct and indirect users of
c_can_set_bittiming().

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 6c03731..6883938 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -631,7 +631,7 @@ static void c_can_configure_msg_objects(struct net_device *dev)
  * - set operating mode
  * - configure message objects
  */
-static void c_can_chip_config(struct net_device *dev)
+static int c_can_chip_config(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
@@ -668,15 +668,18 @@ static void c_can_chip_config(struct net_device *dev)
 	priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
 
 	/* set bittiming params */
-	c_can_set_bittiming(dev);
+	return c_can_set_bittiming(dev);
 }
 
-static void c_can_start(struct net_device *dev)
+static int c_can_start(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
+	int err;
 
 	/* basic c_can configuration */
-	c_can_chip_config(dev);
+	err = c_can_chip_config(dev);
+	if (err)
+		return err;
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
@@ -685,6 +688,8 @@ static void c_can_start(struct net_device *dev)
 
 	/* enable status change, error and module interrupts */
 	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
+
+	return 0;
 }
 
 static void c_can_stop(struct net_device *dev)
@@ -700,9 +705,13 @@ static void c_can_stop(struct net_device *dev)
 
 static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
 {
+	int err;
+
 	switch (mode) {
 	case CAN_MODE_START:
-		c_can_start(dev);
+		err = c_can_start(dev);
+		if (err)
+			return err;
 		netif_wake_queue(dev);
 		break;
 	default:
@@ -1133,17 +1142,20 @@ static int c_can_open(struct net_device *dev)
 		goto exit_irq_fail;
 	}
 
-	napi_enable(&priv->napi);
+	/* start the c_can controller */
+	err = c_can_start(dev);
+	if (err)
+		goto exit_start_fail;
 
 	can_led_event(dev, CAN_LED_EVENT_OPEN);
 
-	/* start the c_can controller */
-	c_can_start(dev);
-
+	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
 	return 0;
 
+exit_start_fail:
+	free_irq(dev->irq, dev);
 exit_irq_fail:
 	close_candev(dev);
 exit_open_fail:
@@ -1260,9 +1272,7 @@ int c_can_power_up(struct net_device *dev)
 	if (time_after(jiffies, time_out))
 		return -ETIMEDOUT;
 
-	c_can_start(dev);
-
-	return 0;
+	return c_can_start(dev);
 }
 EXPORT_SYMBOL_GPL(c_can_power_up);
 #endif
-- 
1.9.0.279.gdc9e3eb

