From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 11/26] can: c_can: Disable rx split as workaround
Date: Fri, 25 Apr 2014 00:00:14 +0200
Message-ID: <1398376829-6771-12-git-send-email-mkl@pengutronix.de>
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

The RX buffer split causes packet loss in the hardware:

What happens is:

RX Packet 1 --> message buffer 1 (newdat bit is not cleared)
RX Packet 2 --> message buffer 2 (newdat bit is not cleared)
RX Packet 3 --> message buffer 3 (newdat bit is not cleared)
RX Packet 4 --> message buffer 4 (newdat bit is not cleared)
RX Packet 5 --> message buffer 5 (newdat bit is not cleared)
RX Packet 6 --> message buffer 6 (newdat bit is not cleared)
RX Packet 7 --> message buffer 7 (newdat bit is not cleared)
RX Packet 8 --> message buffer 8 (newdat bit is not cleared)

Clear newdat bit in message buffer 1
Clear newdat bit in message buffer 2
Clear newdat bit in message buffer 3
Clear newdat bit in message buffer 4
Clear newdat bit in message buffer 5
Clear newdat bit in message buffer 6
Clear newdat bit in message buffer 7
Clear newdat bit in message buffer 8

Now if during that clearing of newdat bits, a new message comes in,
the HW gets confused and drops it.

It does not matter how many of them you clear. I put a delay between
clear of buffer 1 and buffer 2 which was long enough that the message
should have been queued either in buffer 1 or buffer 9. But it did not
show up anywhere. The next message ended up in buffer 1. So the
hardware lost a packet of course without telling it via one of the
error handlers.

That does not happen on all clear newdat bit events. I see one of 10k
packets dropped in the scenario which allows us to reproduce. But the
trace looks always the same.

Not splitting the RX Buffer avoids the packet loss but can cause
reordering. It's hard to trigger, but it CAN happen.

With that mode we use the HW as it was probably designed for. We read
from the buffer 1 upwards and clear the buffer as we get the
message. That's how all microcontrollers use it. So I assume that the
way we handle the buffers was never really tested. According to the
public documentation it should just work :)

Let the user decide which evil is the lesser one.

[ Oliver Hartkopp: Provided a sane config option and help text and
  made me switch to favour potential and unlikely reordering over
  packet loss ]

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/Kconfig |  7 +++++
 drivers/net/can/c_can/c_can.c | 62 +++++++++++++++++++++++++++++++++----------
 2 files changed, 55 insertions(+), 14 deletions(-)

diff --git a/drivers/net/can/c_can/Kconfig b/drivers/net/can/c_can/Kconfig
index 61ffc12..8ab7103 100644
--- a/drivers/net/can/c_can/Kconfig
+++ b/drivers/net/can/c_can/Kconfig
@@ -14,6 +14,13 @@ config CAN_C_CAN_PLATFORM
 	  SPEAr1310 and SPEAr320 evaluation boards & TI (www.ti.com)
 	  boards like am335x, dm814x, dm813x and dm811x.
 
+config CAN_C_CAN_STRICT_FRAME_ORDERING
+	bool "Force a strict RX CAN frame order (may cause frame loss)"
+	---help---
+	  The RX split buffer prevents packet reordering but can cause packet
+	  loss. Only enable this option when you accept to lose CAN frames
+	  in favour of getting the received CAN frames in the correct order.
+
 config CAN_C_CAN_PCI
 	tristate "Generic PCI Bus based C_CAN/D_CAN driver"
 	depends on PCI
diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 09cb687..c1a8684 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -791,18 +791,39 @@ static u32 c_can_adjust_pending(u32 pend)
 	return pend & ~((1 << lasts) - 1);
 }
 
+static inline void c_can_rx_object_get(struct net_device *dev, u32 obj)
+{
+#ifdef CONFIG_CAN_C_CAN_STRICT_FRAME_ORDERING
+	if (obj < C_CAN_MSG_RX_LOW_LAST)
+		c_can_object_get(dev, IF_RX, obj, IF_COMM_RCV_LOW);
+	else
+#endif
+		c_can_object_get(dev, IF_RX, obj, IF_COMM_RCV_HIGH);
+}
+
+static inline void c_can_rx_finalize(struct net_device *dev,
+				     struct c_can_priv *priv, u32 obj)
+{
+#ifdef CONFIG_CAN_C_CAN_STRICT_FRAME_ORDERING
+	if (obj < C_CAN_MSG_RX_LOW_LAST)
+		priv->rxmasked |= BIT(obj - 1);
+	else if (obj == C_CAN_MSG_RX_LOW_LAST) {
+		priv->rxmasked = 0;
+		/* activate all lower message objects */
+		c_can_activate_all_lower_rx_msg_obj(dev, IF_RX);
+	}
+#endif
+}
+
 static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
 			      u32 pend, int quota)
 {
-	u32 pkts = 0, ctrl, obj, mcmd;
+	u32 pkts = 0, ctrl, obj;
 
 	while ((obj = ffs(pend)) && quota > 0) {
 		pend &= ~BIT(obj - 1);
 
-		mcmd = obj < C_CAN_MSG_RX_LOW_LAST ?
-			IF_COMM_RCV_LOW : IF_COMM_RCV_HIGH;
-
-		c_can_object_get(dev, IF_RX, obj, mcmd);
+		c_can_rx_object_get(dev, obj);
 		ctrl = priv->read_reg(priv, C_CAN_IFACE(MSGCTRL_REG, IF_RX));
 
 		if (ctrl & IF_MCONT_MSGLST) {
@@ -824,13 +845,7 @@ static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
 		/* read the data from the message object */
 		c_can_read_msg_object(dev, IF_RX, ctrl);
 
-		if (obj < C_CAN_MSG_RX_LOW_LAST)
-			priv->rxmasked |= BIT(obj - 1);
-		else if (obj == C_CAN_MSG_RX_LOW_LAST) {
-			priv->rxmasked = 0;
-			/* activate all lower message objects */
-			c_can_activate_all_lower_rx_msg_obj(dev, IF_RX);
-		}
+		c_can_rx_finalize(dev, priv, obj);
 
 		pkts++;
 		quota--;
@@ -839,6 +854,16 @@ static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
 	return pkts;
 }
 
+static inline u32 c_can_get_pending(struct c_can_priv *priv)
+{
+	u32 pend = priv->read_reg(priv, C_CAN_NEWDAT1_REG);
+
+#ifdef CONFIG_CAN_C_CAN_STRICT_FRAME_ORDERING
+	pend &= ~priv->rxmasked;
+#endif
+	return pend;
+}
+
 /*
  * theory of operation:
  *
@@ -848,6 +873,8 @@ static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
  * has arrived. To work-around this issue, we keep two groups of message
  * objects whose partitioning is defined by C_CAN_MSG_OBJ_RX_SPLIT.
  *
+ * If CONFIG_CAN_C_CAN_STRICT_FRAME_ORDERING = y
+ *
  * To ensure in-order frame reception we use the following
  * approach while re-activating a message object to receive further
  * frames:
@@ -860,6 +887,14 @@ static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
  * - if the current message object number is greater than
  *   C_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of
  *   only this message object.
+ *
+ * This can cause packet loss!
+ *
+ * If CONFIG_CAN_C_CAN_STRICT_FRAME_ORDERING = n
+ *
+ * We clear the newdat bit right away.
+ *
+ * This can result in packet reordering when the readout is slow.
  */
 static int c_can_do_rx_poll(struct net_device *dev, int quota)
 {
@@ -875,8 +910,7 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 
 	while (quota > 0) {
 		if (!pend) {
-			pend = priv->read_reg(priv, C_CAN_NEWDAT1_REG);
-			pend &= ~priv->rxmasked;
+			pend = c_can_get_pending(priv);
 			if (!pend)
 				break;
 			/*
-- 
1.9.0.279.gdc9e3eb

