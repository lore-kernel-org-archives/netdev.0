From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 10/26] can: c_can: Get rid of pointless interrupts
Date: Fri, 25 Apr 2014 00:00:13 +0200
Message-ID: <1398376829-6771-11-git-send-email-mkl@pengutronix.de>
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

The driver handles pointlessly TWO interrupts per packet. The reason
is that it enables the status interrupt which fires for each rx and tx
packet and it enables the per message object interrupts as well.

The status interrupt merily acks or in case of D_CAN ignores the TX/RX
state and then the message object interrupt fires.

The message objects interrupts are only useful if all message objects
have hardware filters activated.

But we don't have that and its not simple to implement in that driver
without rewriting it completely.

So we can ditch the message object interrupts and handle the RX/TX
right away from the status interrupt. Instead of TWO we handle ONE.

Note: We must keep the TXIE/RXIE bits in the message buffers because
the status interrupt alone is not reliable enough in corner cases.

If we ever have the need for HW filtering, then this code needs a
complete overhaul and we can think about it then. For now we prefer a
lower interrupt load.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 122 ++++++++++++++++--------------------------
 drivers/net/can/c_can/c_can.h |   3 +-
 2 files changed, 48 insertions(+), 77 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index b381f7b..09cb687 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -593,7 +593,7 @@ static void c_can_configure_msg_objects(struct net_device *dev)
 	/* setup receive message objects */
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
 		c_can_setup_receive_object(dev, IF_RX, i, 0, 0,
-			(IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB);
+					   IF_MCONT_RXIE | IF_MCONT_UMASK);
 
 	c_can_setup_receive_object(dev, IF_RX, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
 			IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
@@ -649,8 +649,9 @@ static int c_can_start(struct net_device *dev)
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
-	/* reset tx helper pointers */
+	/* reset tx helper pointers and the rx mask */
 	priv->tx_next = priv->tx_echo = 0;
+	priv->rxmasked = 0;
 
 	return 0;
 }
@@ -823,9 +824,13 @@ static int c_can_read_objects(struct net_device *dev, struct c_can_priv *priv,
 		/* read the data from the message object */
 		c_can_read_msg_object(dev, IF_RX, ctrl);
 
-		if (obj == C_CAN_MSG_RX_LOW_LAST)
+		if (obj < C_CAN_MSG_RX_LOW_LAST)
+			priv->rxmasked |= BIT(obj - 1);
+		else if (obj == C_CAN_MSG_RX_LOW_LAST) {
+			priv->rxmasked = 0;
 			/* activate all lower message objects */
 			c_can_activate_all_lower_rx_msg_obj(dev, IF_RX);
+		}
 
 		pkts++;
 		quota--;
@@ -870,7 +875,8 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
 
 	while (quota > 0) {
 		if (!pend) {
-			pend = priv->read_reg(priv, C_CAN_INTPND1_REG);
+			pend = priv->read_reg(priv, C_CAN_NEWDAT1_REG);
+			pend &= ~priv->rxmasked;
 			if (!pend)
 				break;
 			/*
@@ -1040,10 +1046,6 @@ static int c_can_handle_bus_err(struct net_device *dev,
 		break;
 	}
 
-	/* set a `lec` value so that we can check for updates later */
-	if (priv->type != BOSCH_D_CAN)
-		priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
-
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
 	netif_receive_skb(skb);
@@ -1052,79 +1054,50 @@ static int c_can_handle_bus_err(struct net_device *dev,
 
 static int c_can_poll(struct napi_struct *napi, int quota)
 {
-	u16 irqstatus;
-	int work_done = 0;
 	struct net_device *dev = napi->dev;
 	struct c_can_priv *priv = netdev_priv(dev);
+	u16 curr, last = priv->last_status;
+	int work_done = 0;
 
-	irqstatus = priv->irqstatus;
-	if (!irqstatus)
-		goto end;
+	priv->last_status = curr = priv->read_reg(priv, C_CAN_STS_REG);
+	/* Ack status on C_CAN. D_CAN is self clearing */
+	if (priv->type != BOSCH_D_CAN)
+		priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
 
-	/* status events have the highest priority */
-	if (irqstatus == STATUS_INTERRUPT) {
-		priv->current_status = priv->read_reg(priv,
-					C_CAN_STS_REG);
-
-		/* handle Tx/Rx events */
-		if (priv->current_status & STATUS_TXOK &&
-		    priv->type != BOSCH_D_CAN)
-			priv->write_reg(priv, C_CAN_STS_REG,
-					priv->current_status & ~STATUS_TXOK);
-
-		if (priv->current_status & STATUS_RXOK &&
-		    priv->type != BOSCH_D_CAN)
-			priv->write_reg(priv, C_CAN_STS_REG,
-					priv->current_status & ~STATUS_RXOK);
-
-		/* handle state changes */
-		if ((priv->current_status & STATUS_EWARN) &&
-				(!(priv->last_status & STATUS_EWARN))) {
-			netdev_dbg(dev, "entered error warning state\n");
-			work_done += c_can_handle_state_change(dev,
-						C_CAN_ERROR_WARNING);
-		}
-		if ((priv->current_status & STATUS_EPASS) &&
-				(!(priv->last_status & STATUS_EPASS))) {
-			netdev_dbg(dev, "entered error passive state\n");
-			work_done += c_can_handle_state_change(dev,
-						C_CAN_ERROR_PASSIVE);
-		}
-		if ((priv->current_status & STATUS_BOFF) &&
-				(!(priv->last_status & STATUS_BOFF))) {
-			netdev_dbg(dev, "entered bus off state\n");
-			work_done += c_can_handle_state_change(dev,
-						C_CAN_BUS_OFF);
-			goto end;
-		}
+	/* handle state changes */
+	if ((curr & STATUS_EWARN) && (!(last & STATUS_EWARN))) {
+		netdev_dbg(dev, "entered error warning state\n");
+		work_done += c_can_handle_state_change(dev, C_CAN_ERROR_WARNING);
+	}
 
-		/* handle bus recovery events */
-		if ((!(priv->current_status & STATUS_BOFF)) &&
-				(priv->last_status & STATUS_BOFF)) {
-			netdev_dbg(dev, "left bus off state\n");
-			priv->can.state = CAN_STATE_ERROR_ACTIVE;
-		}
-		if ((!(priv->current_status & STATUS_EPASS)) &&
-				(priv->last_status & STATUS_EPASS)) {
-			netdev_dbg(dev, "left error passive state\n");
-			priv->can.state = CAN_STATE_ERROR_ACTIVE;
-		}
+	if ((curr & STATUS_EPASS) && (!(last & STATUS_EPASS))) {
+		netdev_dbg(dev, "entered error passive state\n");
+		work_done += c_can_handle_state_change(dev, C_CAN_ERROR_PASSIVE);
+	}
 
-		priv->last_status = priv->current_status;
-
-		/* handle lec errors on the bus */
-		work_done += c_can_handle_bus_err(dev,
-					priv->current_status & LEC_MASK);
-	} else if ((irqstatus >= C_CAN_MSG_OBJ_RX_FIRST) &&
-			(irqstatus <= C_CAN_MSG_OBJ_RX_LAST)) {
-		/* handle events corresponding to receive message objects */
-		work_done += c_can_do_rx_poll(dev, (quota - work_done));
-	} else if ((irqstatus >= C_CAN_MSG_OBJ_TX_FIRST) &&
-			(irqstatus <= C_CAN_MSG_OBJ_TX_LAST)) {
-		/* handle events corresponding to transmit message objects */
-		c_can_do_tx(dev);
+	if ((curr & STATUS_BOFF) && (!(last & STATUS_BOFF))) {
+		netdev_dbg(dev, "entered bus off state\n");
+		work_done += c_can_handle_state_change(dev, C_CAN_BUS_OFF);
+		goto end;
 	}
 
+	/* handle bus recovery events */
+	if ((!(curr & STATUS_BOFF)) && (last & STATUS_BOFF)) {
+		netdev_dbg(dev, "left bus off state\n");
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+	}
+	if ((!(curr & STATUS_EPASS)) && (last & STATUS_EPASS)) {
+		netdev_dbg(dev, "left error passive state\n");
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+	}
+
+	/* handle lec errors on the bus */
+	work_done += c_can_handle_bus_err(dev, curr & LEC_MASK);
+
+	/* Handle Tx/Rx events. We do this unconditionally */
+	work_done += c_can_do_rx_poll(dev, (quota - work_done));
+	c_can_do_tx(dev);
+
 end:
 	if (work_done < quota) {
 		napi_complete(napi);
@@ -1141,8 +1114,7 @@ static irqreturn_t c_can_isr(int irq, void *dev_id)
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct c_can_priv *priv = netdev_priv(dev);
 
-	priv->irqstatus = priv->read_reg(priv, C_CAN_INT_REG);
-	if (!priv->irqstatus)
+	if (!priv->read_reg(priv, C_CAN_INT_REG))
 		return IRQ_NONE;
 
 	/* disable all interrupts and schedule the NAPI */
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index faa8404..cd91960 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -185,7 +185,6 @@ struct c_can_priv {
 	struct device *device;
 	spinlock_t xmit_lock;
 	int tx_object;
-	int current_status;
 	int last_status;
 	u16 (*read_reg) (struct c_can_priv *priv, enum reg index);
 	void (*write_reg) (struct c_can_priv *priv, enum reg index, u16 val);
@@ -195,11 +194,11 @@ struct c_can_priv {
 	unsigned int tx_next;
 	unsigned int tx_echo;
 	void *priv;		/* for board-specific data */
-	u16 irqstatus;
 	enum c_can_dev_id type;
 	u32 __iomem *raminit_ctrlreg;
 	unsigned int instance;
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
+	u32 rxmasked;
 	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
 };
 
-- 
1.9.0.279.gdc9e3eb

