From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 08/12 V2] can: c_can: Makethe code readable
Date: Tue, 18 Mar 2014 19:27:42 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403181924440.18573@ionos.tec.linutronix.de>
References: <20140318171007.528610837@linutronix.de>  <20140318171127.430027680@linutronix.de> <1395164220.2812.59.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1395164220.2812.59.camel@joe-AO722>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If every other line contains line breaks, that's a clear sign for
indentation level madness. Split out the inner loop and move the code
to a separate function. gcc creates slightly worse code for that, but
we'll fix that in the next step.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 V2: Remove the pointless multiwhile. Noted by Joe Perches

     Sorry for the noise.

 drivers/net/can/c_can/c_can.c |  107 +++++++++++++++++++++---------------------
 1 file changed, 56 insertions(+), 51 deletions(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
@@ -840,6 +840,52 @@ static u32 c_can_adjust_pending(u32 pend
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
@@ -864,10 +910,8 @@ static u32 c_can_adjust_pending(u32 pend
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
@@ -877,65 +921,26 @@ static int c_can_do_rx_poll(struct net_d
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
