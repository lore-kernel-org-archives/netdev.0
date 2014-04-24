From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 02/26] can: c_can: Fix startup logic
Date: Fri, 25 Apr 2014 00:00:05 +0200
Message-ID: <1398376829-6771-3-git-send-email-mkl@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

c_can_start() enables interrupts way too early. The first enabling
happens when setting the control mode in c_can_chip_config() and then
again at the end of the function.

But that happens before napi_enable() and that means that an interrupt
which comes in will disable interrupts again and call napi_schedule,
which ignores the request and the later napi_enable() is not making
thinks work either. So the interface is up with all device interrupts
disabled.

Move the device interrupt after napi_enable() and add it to the other
callsites of c_can_start() in c_can_set_mode() and c_can_power_up()

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index a5c8dcf..b1629a4 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -612,30 +612,22 @@ static int c_can_chip_config(struct net_device *dev)
 	struct c_can_priv *priv = netdev_priv(dev);
 
 	/* enable automatic retransmission */
-	priv->write_reg(priv, C_CAN_CTRL_REG,
-			CONTROL_ENABLE_AR);
+	priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_ENABLE_AR);
 
 	if ((priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) &&
 	    (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)) {
 		/* loopback + silent mode : useful for hot self-test */
-		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
-				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
-		priv->write_reg(priv, C_CAN_TEST_REG,
-				TEST_LBACK | TEST_SILENT);
+		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_TEST);
+		priv->write_reg(priv, C_CAN_TEST_REG, TEST_LBACK | TEST_SILENT);
 	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
 		/* loopback mode : useful for self-test function */
-		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
-				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
+		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_TEST);
 		priv->write_reg(priv, C_CAN_TEST_REG, TEST_LBACK);
 	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
 		/* silent mode : bus-monitoring mode */
-		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
-				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
+		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_TEST);
 		priv->write_reg(priv, C_CAN_TEST_REG, TEST_SILENT);
-	} else
-		/* normal mode*/
-		priv->write_reg(priv, C_CAN_CTRL_REG,
-				CONTROL_EIE | CONTROL_SIE | CONTROL_IE);
+	}
 
 	/* configure message objects */
 	c_can_configure_msg_objects(dev);
@@ -662,9 +654,6 @@ static int c_can_start(struct net_device *dev)
 	/* reset tx helper pointers */
 	priv->tx_next = priv->tx_echo = 0;
 
-	/* enable status change, error and module interrupts */
-	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
-
 	return 0;
 }
 
@@ -681,6 +670,7 @@ static void c_can_stop(struct net_device *dev)
 
 static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
 {
+	struct c_can_priv *priv = netdev_priv(dev);
 	int err;
 
 	switch (mode) {
@@ -689,6 +679,8 @@ static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
 		if (err)
 			return err;
 		netif_wake_queue(dev);
+		/* enable status change, error and module interrupts */
+		c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -1184,6 +1176,8 @@ static int c_can_open(struct net_device *dev)
 	can_led_event(dev, CAN_LED_EVENT_OPEN);
 
 	napi_enable(&priv->napi);
+	/* enable status change, error and module interrupts */
+	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
 	netif_start_queue(dev);
 
 	return 0;
@@ -1281,6 +1275,7 @@ int c_can_power_up(struct net_device *dev)
 	u32 val;
 	unsigned long time_out;
 	struct c_can_priv *priv = netdev_priv(dev);
+	int ret;
 
 	if (!(dev->flags & IFF_UP))
 		return 0;
@@ -1307,7 +1302,11 @@ int c_can_power_up(struct net_device *dev)
 	if (time_after(jiffies, time_out))
 		return -ETIMEDOUT;
 
-	return c_can_start(dev);
+	ret = c_can_start(dev);
+	if (!ret)
+		c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(c_can_power_up);
 #endif
-- 
1.9.0.279.gdc9e3eb

