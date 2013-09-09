From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 16/16] c_can: fix TX packet accounting
Date: Mon,  9 Sep 2013 09:25:13 +0200
Message-ID: <1378711513-2548-17-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38022 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab3IIHnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:43:24 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the integration of the FlexCard support the TX stats accounting got
lost. Readd the accounting.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 92c1444..b409cf2 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -619,6 +619,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 	u32 msg_obj_no;
 	struct c_can_priv *priv = netdev_priv(dev);
 	struct can_frame *frame = (struct can_frame *)skb->data;
+	struct net_device_stats *stats = &dev->stats;
 	int tx_fifo, txie_off;
 
 	if (can_dropped_invalid_skb(dev, skb))
@@ -664,6 +665,9 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 		ctrl = readl(priv->base + FC_TXFIFO_CTRL);
 		ctrl |= FC_TXFIFO_CTRL_REQ;
 		writel(ctrl, priv->base + FC_TXFIFO_CTRL);
+
+		stats->tx_bytes += frame->can_dlc;
+		stats->tx_packets++;
 		kfree_skb(skb);
 	} else {
 		msg_obj_no = get_tx_next_msg_obj(priv);
@@ -672,6 +676,8 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 		c_can_write_msg_object(dev, 0, frame, msg_obj_no, txie_off);
 		priv->tx_next++;
 
+		stats->tx_bytes += frame->can_dlc;
+		stats->tx_packets++;
 		can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
 		/* we have to stop the queue in case of a wrap around or
 		 * if the next TX message object is still in use
-- 
1.8.4.rc3
