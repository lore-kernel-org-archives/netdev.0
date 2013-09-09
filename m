From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 12/16] c_can: Add flag to disable automatic retransmission of CAN frames
Date: Mon,  9 Sep 2013 09:25:09 +0200
Message-ID: <1378711513-2548-13-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38028 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab3IIHn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:43:26 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The C_CAN/D_CAN controler can automatic retransmit CAN after arbitration loss.
Add a flag to CAN ctrlmode set the appropiate behaivior of this feature.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c    | 16 +++++++++-------
 include/uapi/linux/can/netlink.h |  2 ++
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 02f7c89..51ca2a6 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -785,33 +785,35 @@ static void c_can_configure_msg_objects(struct net_device *dev, int invalidate)
 static int c_can_chip_config(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
+	u16 reg;
 	int ret;
 
-	/* enable automatic retransmission */
-	priv->write_reg(priv, C_CAN_CTRL_REG,
-			CONTROL_ENABLE_AR);
+	if (priv->can.ctrlmode & CAN_CTRLMODE_DAR)
+		reg = CONTROL_DISABLE_AR;
+	else
+		reg = CONTROL_ENABLE_AR;
 
 	if ((priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) &&
 	    (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)) {
 		/* loopback + silent mode : useful for hot self-test */
 		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
-				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
+				reg | CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
 		priv->write_reg(priv, C_CAN_TEST_REG,
 				TEST_LBACK | TEST_SILENT);
 	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
 		/* loopback mode : useful for self-test function */
 		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
-				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
+				reg | CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
 		priv->write_reg(priv, C_CAN_TEST_REG, TEST_LBACK);
 	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
 		/* silent mode : bus-monitoring mode */
 		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
-				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
+				reg | CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
 		priv->write_reg(priv, C_CAN_TEST_REG, TEST_SILENT);
 	} else
 		/* normal mode*/
 		priv->write_reg(priv, C_CAN_CTRL_REG,
-				CONTROL_EIE | CONTROL_SIE | CONTROL_IE);
+				reg | CONTROL_EIE | CONTROL_SIE | CONTROL_IE);
 
 	/* configure message objects */
 	c_can_configure_msg_objects(dev, 1);
diff --git a/include/uapi/linux/can/netlink.h b/include/uapi/linux/can/netlink.h
index 14966dd..fdce5af 100644
--- a/include/uapi/linux/can/netlink.h
+++ b/include/uapi/linux/can/netlink.h
@@ -88,6 +88,8 @@ struct can_ctrlmode {
 #define CAN_CTRLMODE_3_SAMPLES		0x04	/* Triple sampling mode */
 #define CAN_CTRLMODE_ONE_SHOT		0x08	/* One-Shot mode */
 #define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
+#define CAN_CTRLMODE_DAR		0x20	/* Disable Automatic
+						 * Retransmission */
 
 /*
  * CAN device statistics
-- 
1.8.4.rc3
