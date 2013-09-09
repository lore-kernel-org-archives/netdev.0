From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 08/16] c_can: Add FlexCard CAN TX fifo support
Date: Mon,  9 Sep 2013 09:25:05 +0200
Message-ID: <1378711513-2548-9-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37937 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231Ab3IIHZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:25:35 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FlexCard DCAN implementation contains a specialized TX fifo function.
Add the TX support for this function.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 77 ++++++++++++++++++++++++++++++++++++-------
 1 file changed, 65 insertions(+), 12 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 39e2bb0..4b94f2d 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -41,6 +41,7 @@
 #include <linux/can/error.h>
 #include <linux/can/led.h>
 
+#include <linux/flexcard.h>
 #include "c_can.h"
 
 /* Number of interface registers */
@@ -566,24 +567,60 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 	u32 msg_obj_no;
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct can_frame *frame = (struct can_frame *)skb->data;
+	int tx_fifo;
 
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
 
-	msg_obj_no = get_tx_next_msg_obj(priv);
+	tx_fifo = frame->can_dlc & FC_TXFIFO_FLAG;
+	frame->can_dlc &= FC_TXFIFO_DLC_MASK;
 
-	/* prepare message object for transmission */
-	c_can_write_msg_object(dev, 0, frame, msg_obj_no);
-	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
+	if (tx_fifo) {
+		u32 id, *data, ctrl;
 
-	/*
-	 * we have to stop the queue in case of a wrap around or
-	 * if the next TX message object is still in use
-	 */
-	priv->tx_next++;
-	if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv)) ||
-			(priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0)
-		netif_stop_queue(dev);
+		if (readl(priv->base + FC_TXFIFO_STAT) &
+				FC_TXFIFO_STAT_FULL) {
+			netif_stop_queue(dev);
+			return NETDEV_TX_BUSY;
+		}
+
+		if (frame->can_id & CAN_EFF_FLAG) {
+			id = frame->can_id & CAN_EFF_MASK;
+			id |= FC_TXFIFO_MSGID_EXT;
+		} else {
+			id = frame->can_id & CAN_SFF_MASK;
+			/* StdID is left alligned */
+			id <<= FC_TXFIFO_MSGID_STDID_SHIFT;
+		}
+
+		writel(id, priv->base + FC_TXFIFO_MSGID);
+		writel(frame->can_dlc, priv->base + FC_TXFIFO_MSGCTRL);
+
+		if (frame->can_dlc) {
+			data = (u32 *) frame->data;
+			writel(data[0], priv->base + FC_TXFIFO_MSGDA);
+			writel(data[1], priv->base + FC_TXFIFO_MSGDB);
+		}
+
+		ctrl = readl(priv->base + FC_TXFIFO_CTRL);
+		ctrl |= FC_TXFIFO_CTRL_REQ;
+		writel(ctrl, priv->base + FC_TXFIFO_CTRL);
+		kfree_skb(skb);
+	} else {
+		msg_obj_no = get_tx_next_msg_obj(priv);
+
+		/* prepare message object for transmission */
+		c_can_write_msg_object(dev, 0, frame, msg_obj_no);
+		priv->tx_next++;
+
+		can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
+		/* we have to stop the queue in case of a wrap around or
+		 * if the next TX message object is still in use
+		 */
+		if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv))
+			|| ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0))
+			netif_stop_queue(dev);
+	}
 
 	return NETDEV_TX_OK;
 }
@@ -683,6 +720,8 @@ static void c_can_configure_msg_objects(struct net_device *dev, int invalidate)
 				   IF_MASK_MDIR | IF_MASK_RES, 0,
 				   IF_MCONT_UMASK | IF_MCONT_EOB |
 				   IF_MCONT_RXIE | IF_MCONT_DLC_MAX);
+
+	c_can_inval_msg_object(dev, 0, FC_TXFIFO_MO);
 }
 
 /*
@@ -740,8 +779,13 @@ static int c_can_chip_config(struct net_device *dev)
 static int c_can_start(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
+	u32 conf;
 	int ret;
 
+	conf = readl(priv->base + FC_TXFIFO_CONF);
+	conf |= FC_TXFIFO_CONF_EN;
+	writel(conf, priv->base + FC_TXFIFO_CONF);
+
 	/* basic c_can configuration */
 	ret = c_can_chip_config(dev);
 	if (ret)
@@ -762,6 +806,11 @@ out:
 static void c_can_stop(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
+	u32 conf;
+
+	conf = readl(priv->base + FC_TXFIFO_CONF);
+	conf &= ~FC_TXFIFO_CONF_EN;
+	writel(conf, priv->base + FC_TXFIFO_CONF);
 
 	/* disable all interrupts */
 	c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
@@ -1350,6 +1399,8 @@ int register_c_can_dev(struct net_device *dev)
 	struct c_can_priv *priv = netdev_priv(dev);
 	int err;
 
+	writel(0, priv->base + FC_TXFIFO_CONF);
+
 	c_can_pm_runtime_enable(priv);
 
 	dev->flags |= IFF_ECHO;	/* we support local echo */
@@ -1369,6 +1420,8 @@ void unregister_c_can_dev(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
+	writel(0, priv->base + FC_TXFIFO_CONF);
+
 	unregister_candev(dev);
 
 	c_can_pm_runtime_disable(priv);
-- 
1.8.4.rc3
