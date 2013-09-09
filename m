From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 11/16] c_can: stop netqueue if hardware is busy
Date: Mon,  9 Sep 2013 09:25:08 +0200
Message-ID: <1378711513-2548-12-git-send-email-b.spranger@linutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38029 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab3IIHn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 03:43:27 -0400
In-Reply-To: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike other network devices the FlexCard do not support interrupts on TX.
Emulate the TX interrupt by polling the MOTRX registers and restart the
netqueue if one or more message object is available for transtition of CAN
frames.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/can/c_can/c_can.c | 61 ++++++++++++++++++++++++++++++++++++++++---
 drivers/net/can/c_can/c_can.h |  4 +++
 2 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 46d741d..02f7c89 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -550,18 +550,66 @@ static void c_can_inval_msg_object(struct net_device *dev, int iface, int objno)
 
 static inline int c_can_is_next_tx_obj_busy(struct c_can_priv *priv, int objno)
 {
-	int val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG);
+	int val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG + (objno / 32) * 4);
 
 	/*
 	 * as transmission request register's bit n-1 corresponds to
 	 * message object n, we need to handle the same properly.
 	 */
-	if (val & (1 << (objno - 1)))
+	if (val & (1 << ((objno % 32) - 1)))
 		return 1;
 
 	return 0;
 }
 
+static void c_can_motrx_add_timer(struct net_device *dev)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	priv->timer.expires = round_jiffies_relative(1);
+	add_timer(&priv->timer);
+}
+
+static void c_can_motrx_poll(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct c_can_priv *priv = netdev_priv(dev);
+	u32 val, empty = 0;
+	int i;
+
+	for (i = 0; i < C_CAN_MOTRX_NR; i++) {
+		val = c_can_read_reg32(priv, C_CAN_TXRQST1_REG + i * 4);
+
+		if (val < priv->motrx[i]) {
+			netif_wake_queue(dev);
+			return;
+		}
+
+		empty |= val;
+	}
+
+	if (!empty) {
+		netif_wake_queue(dev);
+		return;
+	}
+
+	c_can_motrx_add_timer(dev);
+}
+
+static void c_can_motrx_monitor(struct net_device *dev)
+{
+	struct c_can_priv *priv = netdev_priv(dev);
+	int i;
+
+	if (priv->type != BOSCH_D_CAN_FLEXCARD)
+		return;
+
+	for (i = 0; i < C_CAN_MOTRX_NR; i++)
+		priv->motrx[i] = c_can_read_reg32(priv,
+				C_CAN_TXRQST1_REG + i * 4);
+	c_can_motrx_add_timer(dev);
+}
+
 static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 					struct net_device *dev)
 {
@@ -582,6 +630,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 		if (readl(priv->base + FC_TXFIFO_STAT) &
 				FC_TXFIFO_STAT_FULL) {
 			netif_stop_queue(dev);
+			c_can_motrx_monitor(dev);
 			return NETDEV_TX_BUSY;
 		}
 
@@ -619,8 +668,10 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
 		 * if the next TX message object is still in use
 		 */
 		if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv))
-			|| ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0))
+			|| ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0)) {
 			netif_stop_queue(dev);
+			c_can_motrx_monitor(dev);
+		}
 	}
 
 	return NETDEV_TX_OK;
@@ -1272,6 +1323,7 @@ static int c_can_close(struct net_device *dev)
 {
 	struct c_can_priv *priv = netdev_priv(dev);
 
+	del_timer_sync(&priv->timer);
 	netif_stop_queue(dev);
 	napi_disable(&priv->napi);
 	c_can_stop(dev);
@@ -1306,6 +1358,9 @@ struct net_device *alloc_c_can_dev(void)
 					CAN_CTRLMODE_LISTENONLY |
 					CAN_CTRLMODE_BERR_REPORTING;
 	spin_lock_init(&priv->lock);
+	priv->timer.function = c_can_motrx_poll;
+	priv->timer.data = (unsigned long) dev;
+	init_timer_deferrable(&priv->timer);
 
 	return dev;
 }
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index beea437..6d0f805 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -153,6 +153,8 @@ enum c_can_dev_id {
 	BOSCH_D_CAN_FLEXCARD,
 };
 
+#define C_CAN_MOTRX_NR	1
+
 /* c_can private data structure */
 struct c_can_priv {
 	struct can_priv can;	/* must be the first member */
@@ -176,6 +178,8 @@ struct c_can_priv {
 	unsigned int instance;
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
 	spinlock_t lock;
+	struct timer_list timer;
+	u32 motrx[C_CAN_MOTRX_NR];
 };
 
 struct net_device *alloc_c_can_dev(void);
-- 
1.8.4.rc3
