From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 06/16] c_can: consider set bittiming may fail
Date: Mon,  9 Sep 2013 09:25:03 +0200
Message-ID: <1378711513-2548-7-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37931 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab3IIHZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:34 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While setting the bittiming the C_CAN/D_CAN may fail. Do not bring up the
CAN interface in this case.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index b3cfb85..3fa5347 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -689,9 +689,10 @@ static void c_can_configure_msg_objects(struct net_device *dev)
  * - set operating mode
  * - configure message objects
  */
-static void c_can_chip_config(struct net_device *dev)
+static int c_can_chip_config(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
+	int ret;
 
 	/* enable automatic retransmission */
 	priv->write_reg(priv, C_CAN_CTRL_REG,
@@ -726,15 +727,20 @@ static void c_can_chip_config(struct net_device *dev)
 	priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
 
 	/* set bittiming params */
-	c_can_set_bittiming(dev);
+	ret = c_can_set_bittiming(dev);
+
+	return ret;
 }
 
-static void c_can_start(struct net_device *dev)
+static int c_can_start(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
+	int ret;
 
 	/* basic c_can configuration */
-	c_can_chip_config(dev);
+	ret = c_can_chip_config(dev);
+	if (ret)
+		goto out;
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
@@ -743,6 +749,9 @@ static void c_can_start(struct net_device *dev)
 
 	/* enable status change, error and module interrupts */
 	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
+
+out:
+	return ret;
 }
 
 static void c_can_stop(struct net_device *dev)
@@ -758,9 +767,15 @@ static void c_can_stop(struct net_device *dev)
 
 static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
 {
+	int ret;
+
 	switch (mode) {
 	case CAN_MODE_START:
-		c_can_start(dev);
+		ret = c_can_start(dev);
+		if (ret) {
+			c_can_stop(dev);
+			return ret;
+		}
 		netif_wake_queue(dev);
 		break;
 	default:
-- 
1.8.4.rc3
