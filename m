From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 03/16] c_can: simplify arbitration register handling
Date: Mon,  9 Sep 2013 09:25:00 +0200
Message-ID: <1378711513-2548-4-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37922 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3IIHZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:32 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IF1/2 Arbitration register of the C_CAN/D_CAN ip core is internaly
a 32bit register. Do not use two different 16bit variables to handle
the IF1/2 Arbitration register.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 081620b..bdb7bcd 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -117,9 +117,9 @@
 				IF_COMM_DATAA | IF_COMM_DATAB)
 
 /* IFx arbitration */
-#define IF_ARB_MSGVAL		BIT(15)
-#define IF_ARB_MSGXTD		BIT(14)
-#define IF_ARB_TRANSMIT		BIT(13)
+#define IF_ARB_MSGVAL		BIT(31)
+#define IF_ARB_MSGXTD		BIT(30)
+#define IF_ARB_TRANSMIT		BIT(29)
 
 /* IFx message control */
 #define IF_MCONT_NEWDAT		BIT(15)
@@ -133,6 +133,7 @@
 #define IF_MCONT_TXRQST		BIT(8)
 #define IF_MCONT_EOB		BIT(7)
 #define IF_MCONT_DLC_MASK	0xf
+#define IF_MCONT_DLC_MAX	8
 
 /*
  * IFx register masks:
@@ -336,7 +337,7 @@ static void c_can_write_msg_object(struct net_device *dev,
 			int iface, struct can_frame *frame, int objno)
 {
 	int i;
-	u16 flags = 0;
+	u32 flags = IF_ARB_MSGVAL;
 	unsigned int id;
 	struct c_can_priv *priv = netdev_priv(dev);
 
@@ -349,11 +350,11 @@ static void c_can_write_msg_object(struct net_device *dev,
 	} else
 		id = ((frame->can_id & CAN_SFF_MASK) << 18);
 
-	flags |= IF_ARB_MSGVAL;
+	id |= flags;
 
 	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
 				IFX_WRITE_LOW_16BIT(id));
-	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface), flags |
+	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
 				IFX_WRITE_HIGH_16BIT(id));
 
 	for (i = 0; i < frame->can_dlc; i += 2) {
@@ -439,7 +440,7 @@ static void c_can_handle_lost_msg_obj(struct net_device *dev,
 
 static int c_can_read_msg_object(struct net_device *dev, int iface, int ctrl)
 {
-	u16 flags, data;
+	u16 data;
 	int i;
 	unsigned int val;
 	struct c_can_priv *priv = netdev_priv(dev);
@@ -455,16 +456,15 @@ static int c_can_read_msg_object(struct net_device *dev, int iface, int ctrl)
 
 	frame->can_dlc = get_can_dlc(ctrl & 0x0F);
 
-	flags =	priv->read_reg(priv, C_CAN_IFACE(ARB2_REG, iface));
-	val = priv->read_reg(priv, C_CAN_IFACE(ARB1_REG, iface)) |
-		(flags << 16);
+	val = (priv->read_reg(priv, C_CAN_IFACE(ARB2_REG, iface)) << 16);
+	val |= priv->read_reg(priv, C_CAN_IFACE(ARB1_REG, iface));
 
-	if (flags & IF_ARB_MSGXTD)
+	if (val & IF_ARB_MSGXTD)
 		frame->can_id = (val & CAN_EFF_MASK) | CAN_EFF_FLAG;
 	else
 		frame->can_id = (val >> 18) & CAN_SFF_MASK;
 
-	if (flags & IF_ARB_TRANSMIT)
+	if (val & IF_ARB_TRANSMIT)
 		frame->can_id |= CAN_RTR_FLAG;
 	else {
 		for (i = 0; i < frame->can_dlc; i += 2) {
@@ -500,10 +500,11 @@ static void c_can_setup_receive_object(struct net_device *dev, int iface,
 	priv->write_reg(priv, C_CAN_IFACE(MASK2_REG, iface),
 			IFX_WRITE_HIGH_16BIT(mask) | BIT(13));
 
+	id |= IF_ARB_MSGVAL;
 	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
 			IFX_WRITE_LOW_16BIT(id));
 	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
-			(IF_ARB_MSGVAL | IFX_WRITE_HIGH_16BIT(id)));
+			(IFX_WRITE_HIGH_16BIT(id)));
 
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), mcont);
 	c_can_object_put(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
-- 
1.8.4.rc3
