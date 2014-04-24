From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 14/26] can: c_can: Cleanup c_can_read_msg_object()
Date: Fri, 25 Apr 2014 00:00:17 +0200
Message-ID: <1398376829-6771-15-git-send-email-mkl@pengutronix.de>
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

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 562faef..d0daef8 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -380,15 +380,13 @@ static int c_can_handle_lost_msg_obj(struct net_device *dev,
 	return 1;
 }
 
-static int c_can_read_msg_object(struct net_device *dev, int iface, int ctrl)
+static int c_can_read_msg_object(struct net_device *dev, int iface, u32 ctrl)
 {
-	u16 flags, data;
-	int i;
-	unsigned int val;
-	struct c_can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
-	struct sk_buff *skb;
+	struct c_can_priv *priv = netdev_priv(dev);
 	struct can_frame *frame;
+	struct sk_buff *skb;
+	u32 arb, data;
 
 	skb = alloc_can_skb(dev, &frame);
 	if (!skb) {
@@ -398,21 +396,21 @@ static int c_can_read_msg_object(struct net_device *dev, int iface, int ctrl)
 
 	frame->can_dlc = get_can_dlc(ctrl & 0x0F);
 
-	flags =	priv->read_reg(priv, C_CAN_IFACE(ARB2_REG, iface));
-	val = priv->read_reg(priv, C_CAN_IFACE(ARB1_REG, iface)) |
-		(flags << 16);
+	arb = priv->read_reg(priv, C_CAN_IFACE(ARB1_REG, iface));
+	arb |= priv->read_reg(priv, C_CAN_IFACE(ARB2_REG, iface)) << 16;
 
-	if (flags & IF_ARB_MSGXTD)
-		frame->can_id = (val & CAN_EFF_MASK) | CAN_EFF_FLAG;
+	if (arb & (IF_ARB_MSGXTD << 16))
+		frame->can_id = (arb & CAN_EFF_MASK) | CAN_EFF_FLAG;
 	else
-		frame->can_id = (val >> 18) & CAN_SFF_MASK;
+		frame->can_id = (arb >> 18) & CAN_SFF_MASK;
 
-	if (flags & IF_ARB_TRANSMIT)
+	if (arb & (IF_ARB_TRANSMIT << 16)) {
 		frame->can_id |= CAN_RTR_FLAG;
-	else {
-		for (i = 0; i < frame->can_dlc; i += 2) {
-			data = priv->read_reg(priv,
-				C_CAN_IFACE(DATA1_REG, iface) + i / 2);
+	} else {
+		int i, dreg = C_CAN_IFACE(DATA1_REG, iface);
+
+		for (i = 0; i < frame->can_dlc; i += 2, dreg ++) {
+			data = priv->read_reg(priv, dreg);
 			frame->data[i] = data;
 			frame->data[i + 1] = data >> 8;
 		}
-- 
1.9.0.279.gdc9e3eb

