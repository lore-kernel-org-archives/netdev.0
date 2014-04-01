From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 13/16] can: c_can: Reduce register access
Date: Tue,  1 Apr 2014 23:42:27 +0200
Message-ID: <1396388550-23081-14-git-send-email-mkl@pengutronix.de>
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

commit 4ce78a838c (can: c_can: Speed up rx_poll function) hyped a
performance improvement by reducing the access to the interrupt
pending register from a dual 16 bit to a single 16 bit access. Wow!

Thereby it crippled the driver to cast the 16 msg objects in stone,
which is completly braindead as contemporary hardware has up to 128
message objects. Supporting larger object buffers is a major surgery,
but it'd be definitely worth it especially as the driver does not
support HW message filtering ....

The logic of the "FIFO" implementation is to split the FIFO in half.

For the lower half we read the buffers and clear the interrupt pending
bit, but keep the newdat bit set, so the HW will queue above those
buffers.

When we read out the last low buffer then we reenable all the low half
buffers by clearing the newdat bit.

The upper half buffers clear the newdat and the interrupt pending bit
right away as we know that the lower half bits are clear and give us a
headstart against the hardware.

Now the implementation is:

    transfer_message_object()
    read_object_and_put_into_skb();

    if (obj < END_OF_LOW_BUF)
       clear_intpending(obj)
    else if (obj > END_OF_LOW_BUF)
       clear_intpending_and_newdat(obj)
    else if (obj == END_OF_LOW_BUF)
       clear_newdat_of_all_low_objects()

The hardware allows to avoid most of the mess simply because we can
tell the transfer_message_object() function to clear bits right away.

So we can be clever and do:

   if (obj <= END_OF_LOW_BUF)
      ctrl = TRANSFER_MSG | CLEAR_INTPND;
   else
      ctrl = TRANSFER_MSG | CLEAR_INTPND | CLEAR_NEWDAT;

    transfer_message_object(ctrl)
    read_object_and_put_into_skb();

    if (obj == END_OF_LOW_BUF)
       clear_newdat_of_all_low_objects()

So we save a complete control operation on all message objects except
the one which is the end of the low buffer. That's a few micro seconds
per object.

I'm not adding a boasting profile to that, simply because it's self
explaining.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[mkl: adjusted subject and commit message]
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 49 +++++++++++++------------------------------
 1 file changed, 15 insertions(+), 34 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index bd7234e..8ea1379 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -114,6 +114,14 @@
 				IF_COMM_CONTROL | IF_COMM_TXRQST | \
 				IF_COMM_DATAA | IF_COMM_DATAB)
 
+/* For the low buffers we clear the interrupt bit, but keep newdat */
+#define IF_COMM_RCV_LOW		(IF_COMM_MASK | IF_COMM_ARB | \
+				 IF_COMM_CONTROL | IF_COMM_CLR_INT_PND | \
+				 IF_COMM_DATAA | IF_COMM_DATAB)
+
+/* For the high buffers we clear the interrupt bit and newdat */
+#define IF_COMM_RCV_HIGH	(IF_COMM_RCV_LOW | IF_COMM_TXRQST)
+
 /* IFx arbitration */
 #define IF_ARB_MSGVAL		BIT(15)
 #define IF_ARB_MSGXTD		BIT(14)
@@ -371,18 +379,6 @@ static void c_can_write_msg_object(struct net_device *dev,
 	c_can_object_put(dev, iface, objno, IF_COMM_ALL);
 }
 
-static inline void c_can_mark_rx_msg_obj(struct net_device *dev,
-						int iface, int ctrl_mask,
-						int obj)
-{
-	struct c_can_priv *priv = netdev_priv(dev);
-
-	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
-			ctrl_mask & ~(IF_MCONT_MSGLST | IF_MCONT_INTPND));
-	c_can_object_put(dev, iface, obj, IF_COMM_CONTROL);
-
-}
-
 static inline void c_can_activate_all_lower_rx_msg_obj(struct net_device *dev,
 						int iface,
 						int ctrl_mask)
@@ -392,24 +388,11 @@ static inline void c_can_activate_all_lower_rx_msg_obj(struct net_device *dev,
 
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i <= C_CAN_MSG_RX_LOW_LAST; i++) {
 		priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
-				ctrl_mask & ~(IF_MCONT_MSGLST |
-					IF_MCONT_INTPND | IF_MCONT_NEWDAT));
+				ctrl_mask & ~IF_MCONT_NEWDAT);
 		c_can_object_put(dev, iface, i, IF_COMM_CONTROL);
 	}
 }
 
-static inline void c_can_activate_rx_msg_obj(struct net_device *dev,
-						int iface, int ctrl_mask,
-						int obj)
-{
-	struct c_can_priv *priv = netdev_priv(dev);
-
-	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
-			ctrl_mask & ~(IF_MCONT_MSGLST |
-				IF_MCONT_INTPND | IF_MCONT_NEWDAT));
-	c_can_object_put(dev, iface, obj, IF_COMM_CONTROL);
-}
-
 static int c_can_handle_lost_msg_obj(struct net_device *dev,
 				     int iface, int objno, u32 ctrl)
 {
@@ -852,12 +835,15 @@ static u32 c_can_adjust_pending(u32 pend)
 static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
 			      u32 pend, int quota)
 {
-	u32 pkts = 0, ctrl, obj;
+	u32 pkts = 0, ctrl, obj, mcmd;
 
 	while ((obj = ffs(pend)) && quota > 0) {
 		pend &= ~BIT(obj - 1);
 
-		c_can_object_get(dev, IF_RX, obj, IF_COMM_ALL &	~IF_COMM_TXRQST);
+		mcmd = obj < C_CAN_MSG_RX_LOW_LAST ?
+			IF_COMM_RCV_LOW : IF_COMM_RCV_HIGH;
+
+		c_can_object_get(dev, IF_RX, obj, mcmd);
 		ctrl = priv->read_reg(priv, C_CAN_IFACE(MSGCTRL_REG, IF_RX));
 
 		if (ctrl & IF_MCONT_MSGLST) {
@@ -879,12 +865,7 @@ static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
 		/* read the data from the message object */
 		c_can_read_msg_object(dev, IF_RX, ctrl);
 
-		if (obj < C_CAN_MSG_RX_LOW_LAST)
-			c_can_mark_rx_msg_obj(dev, IF_RX, ctrl, obj);
-		else if (obj > C_CAN_MSG_RX_LOW_LAST)
-			/* activate this msg obj */
-			c_can_activate_rx_msg_obj(dev, IF_RX, ctrl, obj);
-		else if (obj == C_CAN_MSG_RX_LOW_LAST)
+		if (obj == C_CAN_MSG_RX_LOW_LAST)
 			/* activate all lower message objects */
 			c_can_activate_all_lower_rx_msg_obj(dev, IF_RX, ctrl);
 
-- 
1.9.0.279.gdc9e3eb

