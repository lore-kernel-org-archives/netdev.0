From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 07/16] c_can: reconfigre message objects after leaving init state
Date: Mon,  9 Sep 2013 09:25:04 +0200
Message-ID: <1378711513-2548-8-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37934 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab3IIHZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:34 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The D_CAN controler invalidates the message buffer objects while leaving init.
Reconfigure the message buffer objects after leaving init.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 3fa5347..39e2bb0 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -662,13 +662,15 @@ static int c_can_set_bittiming(struct net_device *dev)
  * See user guide document for further details on configuring message
  * objects.
  */
-static void c_can_configure_msg_objects(struct net_device *dev)
+static void c_can_configure_msg_objects(struct net_device *dev, int invalidate)
 {
 	int i;
 
-	/* first invalidate all message objects */
-	for (i = C_CAN_MSG_OBJ_RX_FIRST; i <= C_CAN_NO_OF_OBJECTS; i++)
-		c_can_inval_msg_object(dev, 0, i);
+	if (invalidate) {
+		/* first invalidate all message objects */
+		for (i = C_CAN_MSG_OBJ_RX_FIRST; i <= C_CAN_NO_OF_OBJECTS; i++)
+			c_can_inval_msg_object(dev, 0, i);
+	}
 
 	/* setup receive message objects */
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
@@ -721,7 +723,7 @@ static int c_can_chip_config(struct net_device *dev)
 				CONTROL_EIE | CONTROL_SIE | CONTROL_IE);
 
 	/* configure message objects */
-	c_can_configure_msg_objects(dev);
+	c_can_configure_msg_objects(dev, 1);
 
 	/* set a `lec` value so that we can check for updates later */
 	priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
@@ -729,6 +731,9 @@ static int c_can_chip_config(struct net_device *dev)
 	/* set bittiming params */
 	ret = c_can_set_bittiming(dev);
 
+	/* reconfigure message objects */
+	c_can_configure_msg_objects(dev, 0);
+
 	return ret;
 }
 
-- 
1.8.4.rc3
