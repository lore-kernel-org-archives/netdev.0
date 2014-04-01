From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 08/16] can: c_can: Fix buffer ordering
Date: Tue,  1 Apr 2014 23:42:22 +0200
Message-ID: <1396388550-23081-9-git-send-email-mkl@pengutronix.de>
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

The buffer handling of c_can has been broken forever. That leads to
message reordering:

ksoftirqd/0-3     [000] ..s.    79.123776: c_can_poll: rx_poll: val: 00007fff
ksoftirqd/0-3     [000] ..s.    79.124101: c_can_poll: rx_poll: val: 00008001

What happens is:

CPU				HW
				queue new packet into obj 16 (0-15 are busy)
read obj 1-15
return because pending is 0
				set pending obj 16 -> pending reg 8000
				queue new packet into obj 1
				set pending obj 1 -> pending reg 8001

So the current algorithmus reads the newest message first, which
violates the ordering rules of CAN.

Add proper handling of that situation by analyzing the contents of the
pending register for gaps.

This does NOT fix the message object corruption which can lead to
interrupt storms. Thats addressed in the next patches.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[mkl: adjusted subject]
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 52 +++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 50 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 38f9ada..cef9967 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -817,6 +817,38 @@ static void c_can_do_tx(struct net_device *dev)
 }
 
 /*
+ * If we have a gap in the pending bits, that means we either
+ * raced with the hardware or failed to readout all upper
+ * objects in the last run due to quota limit.
+ */
+static u32 c_can_adjust_pending(u32 pend)
+{
+	u32 weight, lasts;
+
+	if (pend == RECEIVE_OBJECT_BITS)
+		return pend;
+
+	/*
+	 * If the last set bit is larger than the number of pending
+	 * bits we have a gap.
+	 */
+	weight = hweight32(pend);
+	lasts = fls(pend);
+
+	/* If the bits are linear, nothing to do */
+	if (lasts == weight)
+		return pend;
+
+	/*
+	 * Find the first set bit after the gap. We walk backwards
+	 * from the last set bit.
+	 */
+	for (lasts--; pend & (1 << (lasts - 1)); lasts--);
+
+	return pend & ~((1 << lasts) - 1);
+}
+
+/*
  * theory of operation:
  *
  * c_can core saves a received CAN message into the first free message
@@ -843,7 +875,7 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 	u32 num_rx_pkts = 0;
 	unsigned int msg_obj, msg_ctrl_save;
 	struct c_can_priv *priv = netdev_priv(dev);
-	u16 val;
+	u32 val, pend = 0;
 
 	/*
 	 * It is faster to read only one 16bit register. This is only possible
@@ -852,7 +884,23 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 	BUILD_BUG_ON_MSG(C_CAN_MSG_OBJ_RX_LAST > 16,
 			"Implementation does not support more message objects than 16");
 
-	while (quota > 0 && (val = priv->read_reg(priv, C_CAN_INTPND1_REG))) {
+	while (quota > 0) {
+
+		if (!pend) {
+			pend = priv->read_reg(priv, C_CAN_INTPND1_REG);
+			if (!pend)
+				return num_rx_pkts;
+			/*
+			 * If the pending field has a gap, handle the
+			 * bits above the gap first.
+			 */
+			val = c_can_adjust_pending(pend);
+		} else {
+			val = pend;
+		}
+		/* Remove the bits from pend */
+		pend &= ~val;
+
 		while ((msg_obj = ffs(val)) && quota > 0) {
 			val &= ~BIT(msg_obj - 1);
 
-- 
1.9.0.279.gdc9e3eb

