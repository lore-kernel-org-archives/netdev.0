From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 05/26] can: c_can: Handle state change correctly
Date: Fri, 25 Apr 2014 00:00:08 +0200
Message-ID: <1398376829-6771-6-git-send-email-mkl@pengutronix.de>
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

If the allocation of an error skb fails, the state change handling
returns w/o doing any work. That leaves the interface in a wreckaged
state as the internal status is wrong.

Split the interface handling and the skb handling.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 6038761..246bcf9 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -914,6 +914,26 @@ static int c_can_handle_state_change(struct net_device *dev,
 	struct sk_buff *skb;
 	struct can_berr_counter bec;
 
+	switch (error_type) {
+	case C_CAN_ERROR_WARNING:
+		/* error warning state */
+		priv->can.can_stats.error_warning++;
+		priv->can.state = CAN_STATE_ERROR_WARNING;
+		break;
+	case C_CAN_ERROR_PASSIVE:
+		/* error passive state */
+		priv->can.can_stats.error_passive++;
+		priv->can.state = CAN_STATE_ERROR_PASSIVE;
+		break;
+	case C_CAN_BUS_OFF:
+		/* bus-off state */
+		priv->can.state = CAN_STATE_BUS_OFF;
+		can_bus_off(dev);
+		break;
+	default:
+		break;
+	}
+
 	/* propagate the error condition to the CAN stack */
 	skb = alloc_can_err_skb(dev, &cf);
 	if (unlikely(!skb))
@@ -927,8 +947,6 @@ static int c_can_handle_state_change(struct net_device *dev,
 	switch (error_type) {
 	case C_CAN_ERROR_WARNING:
 		/* error warning state */
-		priv->can.can_stats.error_warning++;
-		priv->can.state = CAN_STATE_ERROR_WARNING;
 		cf->can_id |= CAN_ERR_CRTL;
 		cf->data[1] = (bec.txerr > bec.rxerr) ?
 			CAN_ERR_CRTL_TX_WARNING :
@@ -939,8 +957,6 @@ static int c_can_handle_state_change(struct net_device *dev,
 		break;
 	case C_CAN_ERROR_PASSIVE:
 		/* error passive state */
-		priv->can.can_stats.error_passive++;
-		priv->can.state = CAN_STATE_ERROR_PASSIVE;
 		cf->can_id |= CAN_ERR_CRTL;
 		if (rx_err_passive)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
@@ -952,7 +968,6 @@ static int c_can_handle_state_change(struct net_device *dev,
 		break;
 	case C_CAN_BUS_OFF:
 		/* bus-off state */
-		priv->can.state = CAN_STATE_BUS_OFF;
 		cf->can_id |= CAN_ERR_BUSOFF;
 		can_bus_off(dev);
 		break;
-- 
1.9.0.279.gdc9e3eb

