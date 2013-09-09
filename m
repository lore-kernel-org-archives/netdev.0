From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 09/16] c_can: expicit 32bit access on D_CAN to message buffer data register
Date: Mon,  9 Sep 2013 09:25:06 +0200
Message-ID: <1378711513-2548-10-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37940 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336Ab3IIHZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:36 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change the 16bit access of ARB1_REG and DATA1/2_REG to a 32bit access.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 4b94f2d..c573399 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -360,7 +360,6 @@ static inline void c_can_object_put(struct net_device *dev,
 static void c_can_write_msg_object(struct net_device *dev,
 			int iface, struct can_frame *frame, int objno)
 {
-	int i;
 	u32 flags = IF_ARB_MSGVAL;
 	unsigned int id;
 	struct c_can_priv *priv = netdev_priv(dev);
@@ -376,15 +375,17 @@ static void c_can_write_msg_object(struct net_device *dev,
 
 	id |= flags;
 
-	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
-				IFX_WRITE_LOW_16BIT(id));
-	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
-				IFX_WRITE_HIGH_16BIT(id));
+	c_can_writereg32(priv, C_CAN_IFACE(ARB1_REG, iface),
+			IFX_WRITE_HIGH_16BIT(id),
+			IFX_WRITE_LOW_16BIT(id));
+
+	c_can_writereg32(priv, C_CAN_IFACE(DATA1_REG, iface),
+			 frame->data[2] | frame->data[3] << 8,
+			 frame->data[0] | frame->data[1] << 8);
 
-	for (i = 0; i < frame->can_dlc; i += 2) {
-		priv->write_reg(priv, C_CAN_IFACE(DATA1_REG, iface) + i / 2,
-				frame->data[i] | (frame->data[i + 1] << 8));
-	}
+	c_can_writereg32(priv, C_CAN_IFACE(DATA3_REG, iface),
+			 frame->data[6] | frame->data[7] << 8,
+			 frame->data[4] | frame->data[5] << 8);
 
 	/* enable interrupt for this message object */
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
-- 
1.8.4.rc3
