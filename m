From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 12/16] can: c_can: Make the code readable
Date: Tue,  1 Apr 2014 23:42:26 +0200
Message-ID: <1396388550-23081-13-git-send-email-mkl@pengutronix.de>
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

If every other line contains line breaks, that's a clear sign for
indentation level madness. Split out the inner loop and move the code
to a separate function. gcc creates slightly worse code for that, but
we'll fix that in the next step.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[mkl: adjusted subject]
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 107 ++++++++++++++++++++++--------------------
 1 file changed, 56 insertions(+), 51 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 1fe79ce..bd7234e 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -849,6 +849,52 @@ static u32 c_can_adjust_pending(u32 pend)
 	return pend & ~((1 << lasts) - 1);
 }
 
+static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
+			      u32 pend, int quota)
+{
+	u32 pkts = 0, ctrl, obj;
+
+	while ((obj = ffs(pend)) && quota > 0) {
+		pend &= ~BIT(obj - 1);
+
+		c_can_object_get(dev, IF_RX, obj, IF_COMM_ALL &	~IF_COMM_TXRQST);
+		ctrl = priv->read_reg(priv, C_CAN_IFACE(MSGCTRL_REG, IF_RX));
+
+		if (ctrl & IF_MCONT_MSGLST) {
+			int n = c_can_handle_lost_msg_obj(dev, IF_RX, obj, ctrl);
+
+			pkts += n;
+			quota -= n;
+			continue;
+		}
+
+		/*
+		 * This really should not happen, but this covers some
+		 * odd HW behaviour. Do not remove that unless you
+		 * want to brick your machine.
+		 */
+		if (!(ctrl & IF_MCONT_NEWDAT))
+			continue;
+
+		/* read the data from the message object */
+		c_can_read_msg_object(dev, IF_RX, ctrl);
+
+		if (obj < C_CAN_MSG_RX_LOW_LAST)
+			c_can_mark_rx_msg_obj(dev, IF_RX, ctrl, obj);
+		else if (obj > C_CAN_MSG_RX_LOW_LAST)
+			/* activate this msg obj */
+			c_can_activate_rx_msg_obj(dev, IF_RX, ctrl, obj);
+		else if (obj == C_CAN_MSG_RX_LOW_LAST)
+			/* activate all lower message objects */
+			c_can_activate_all_lower_rx_msg_obj(dev, IF_RX, ctrl);
+
+		pkts++;
+		quota--;
+	}
+
+	return pkts;
+}
+
 /*
  * theory of operation:
  *
@@ -873,10 +919,8 @@ static u32 c_can_adjust_pending(u32 pend)
  */
 static int c_can_do_rx_poll(struct net_device *dev, int quota)
 {
-	u32 num_rx_pkts = 0;
-	unsigned int msg_obj, msg_ctrl_save;
 	struct c_can_priv *priv = netdev_priv(dev);
-	u32 val, pend = 0;
+	u32 pkts = 0, pend = 0, toread, n;
 
 	/*
 	 * It is faster to read only one 16bit register. This is only possible
@@ -886,65 +930,26 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 			"Implementation does not support more message objects than 16");
 
 	while (quota > 0) {
-
 		if (!pend) {
 			pend = priv->read_reg(priv, C_CAN_INTPND1_REG);
 			if (!pend)
-				return num_rx_pkts;
+				break;
 			/*
 			 * If the pending field has a gap, handle the
 			 * bits above the gap first.
 			 */
-			val = c_can_adjust_pending(pend);
+			toread = c_can_adjust_pending(pend);
 		} else {
-			val = pend;
+			toread = pend;
 		}
 		/* Remove the bits from pend */
-		pend &= ~val;
-
-		while ((msg_obj = ffs(val)) && quota > 0) {
-			val &= ~BIT(msg_obj - 1);
-
-			c_can_object_get(dev, IF_RX, msg_obj, IF_COMM_ALL &
-					~IF_COMM_TXRQST);
-			msg_ctrl_save = priv->read_reg(priv,
-					C_CAN_IFACE(MSGCTRL_REG, IF_RX));
-
-			if (msg_ctrl_save & IF_MCONT_MSGLST) {
-				int n;
-
-				n = c_can_handle_lost_msg_obj(dev, IF_RX,
-							      msg_obj,
-							      msg_ctrl_save);
-				num_rx_pkts += n;
-				quota -=n;
-				continue;
-			}
-
-			if (!(msg_ctrl_save & IF_MCONT_NEWDAT))
-				continue;
-
-			/* read the data from the message object */
-			c_can_read_msg_object(dev, IF_RX, msg_ctrl_save);
-
-			if (msg_obj < C_CAN_MSG_RX_LOW_LAST)
-				c_can_mark_rx_msg_obj(dev, IF_RX,
-						msg_ctrl_save, msg_obj);
-			else if (msg_obj > C_CAN_MSG_RX_LOW_LAST)
-				/* activate this msg obj */
-				c_can_activate_rx_msg_obj(dev, IF_RX,
-						msg_ctrl_save, msg_obj);
-			else if (msg_obj == C_CAN_MSG_RX_LOW_LAST)
-				/* activate all lower message objects */
-				c_can_activate_all_lower_rx_msg_obj(dev,
-						IF_RX, msg_ctrl_save);
-
-			num_rx_pkts++;
-			quota--;
-		}
+		pend &= ~toread;
+		/* Read the objects */
+		n = c_can_read_objects(dev, priv, toread, quota);
+		pkts += n;
+		quota -= n;
 	}
-
-	return num_rx_pkts;
+	return pkts;
 }
 
 static inline int c_can_has_and_handle_berr(struct c_can_priv *priv)
-- 
1.9.0.279.gdc9e3eb

