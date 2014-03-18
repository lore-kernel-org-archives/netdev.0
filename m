From: Thomas Gleixner <tglx@linutronix.de>
Subject: can: c_can: Reduce interrupt load by 50%
Date: Tue, 18 Mar 2014 21:18:15 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403182114470.18573@ionos.tec.linutronix.de>
References: <20140318171007.528610837@linutronix.de> <20140318171127.923041002@linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140318171127.923041002@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver handles pointlessly TWO interrupts per packet. The reason
is that it enables the status interrupt which fires for each rx and tx
packet and it enables the per message object interrupts as well.

The status interrupt merily acks the TX/RX state and then the
message object interrupt fires.

The message objects interrupts are only useful if all message objects
have hardware filters activated.

But we don't have that and its not simple to implement in that driver
without rewriting it completely.

So we can ditch the message object interrupts and handle the RX/TX
right away from the status interrupt. Instead of TWO we handle
ONE. That's a whopping performance improment, right?

If we ever have the need for HW filtering, then this code needs a
complete overhaul and we can think about it then. For now we prefer a
lower interrupt load.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---

Applies on top of the previous series.

 drivers/net/can/c_can/c_can.c |  129 ++++++++++++++++++------------------------
 drivers/net/can/c_can/c_can.h |    2 
 2 files changed, 57 insertions(+), 74 deletions(-)

Index: linux/drivers/net/can/c_can/c_can.c
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.c
+++ linux/drivers/net/can/c_can/c_can.c
@@ -346,8 +346,7 @@ static void c_can_write_msg_object(struc
 
 	/* enable interrupt for this message object */
 	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
-			IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB |
-			frame->can_dlc);
+			IF_MCONT_TXRQST | IF_MCONT_EOB | frame->can_dlc);
 	c_can_object_put(dev, iface, objno, IF_COMM_ALL);
 }
 
@@ -594,11 +593,10 @@ static void c_can_configure_msg_objects(
 
 	/* setup receive message objects */
 	for (i = C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
-		c_can_setup_receive_object(dev, IF_RX, i, 0, 0,
-			(IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB);
+		c_can_setup_receive_object(dev, IF_RX, i, 0, 0, IF_MCONT_UMASK);
 
 	c_can_setup_receive_object(dev, IF_RX, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
-			IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
+				   IF_MCONT_EOB | IF_MCONT_UMASK);
 }
 
 /*
@@ -656,8 +654,9 @@ static void c_can_start(struct net_devic
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
-	/* reset tx helper pointers */
+	/* reset tx helper pointers and the rx mask */
 	priv->tx_next = priv->tx_echo = 0;
+	priv->rxmasked = 0;
 
 	/* enable status change, error and module interrupts */
 	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
@@ -824,9 +823,13 @@ static int c_can_read_objects(struct net
 		/* read the data from the message object */
 		c_can_read_msg_object(dev, IF_RX, ctrl);
 
-		if (obj == C_CAN_MSG_RX_LOW_LAST)
+		if (obj < C_CAN_MSG_RX_LOW_LAST)
+			priv->rxmasked |= BIT(obj - 1);
+		else if (obj == C_CAN_MSG_RX_LOW_LAST) {
+			priv->rxmasked = 0;
 			/* activate all lower message objects */
 			c_can_activate_all_lower_rx_msg_obj(dev, IF_RX, ctrl);
+		}
 
 		pkts++;
 		quota--;
@@ -871,7 +874,8 @@ static int c_can_do_rx_poll(struct net_d
 
 	while (quota > 0) {
 		if (!pend) {
-			pend = priv->read_reg(priv, C_CAN_INTPND1_REG);
+			pend = priv->read_reg(priv, C_CAN_NEWDAT1_REG);
+			pend &= ~priv->rxmasked;
 			if (!pend)
 				break;
 			/*
@@ -1046,79 +1050,58 @@ static int c_can_handle_bus_err(struct n
 
 static int c_can_poll(struct napi_struct *napi, int quota)
 {
-	u16 irqstatus;
-	int lec_type = 0;
-	int work_done = 0;
 	struct net_device *dev = napi->dev;
 	struct c_can_priv *priv = netdev_priv(dev);
+	u16 curr = priv->current_status, last = priv->last_status;
+	int lec_type = 0, work_done = 0;
 
-	irqstatus = priv->irqstatus;
-	if (!irqstatus)
-		goto end;
-
-	/* status events have the highest priority */
-	if (irqstatus == STATUS_INTERRUPT) {
-		priv->current_status = priv->read_reg(priv,
-					C_CAN_STS_REG);
-
-		/* handle Tx/Rx events */
-		if (priv->current_status & STATUS_TXOK)
-			priv->write_reg(priv, C_CAN_STS_REG,
-					priv->current_status & ~STATUS_TXOK);
-
-		if (priv->current_status & STATUS_RXOK)
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
-		}
+	curr = priv->current_status = priv->read_reg(priv, C_CAN_STS_REG);
 
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
+	/* handle state changes */
+	if ((curr & STATUS_EWARN) && (!(last & STATUS_EWARN))) {
+		netdev_dbg(dev, "entered error warning state\n");
+		work_done += c_can_handle_state_change(dev, C_CAN_ERROR_WARNING);
+	}
+
+	if ((curr & STATUS_EPASS) && (!(last & STATUS_EPASS))) {
+		netdev_dbg(dev, "entered error passive state\n");
+		work_done += c_can_handle_state_change(dev, C_CAN_ERROR_PASSIVE);
+	}
 
-		priv->last_status = priv->current_status;
+	if ((curr & STATUS_BOFF) && (!(last & STATUS_BOFF))) {
+		netdev_dbg(dev, "entered bus off state\n");
+		work_done += c_can_handle_state_change(dev, C_CAN_BUS_OFF);
+	}
+
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
+	priv->last_status = curr;
 
-		/* handle lec errors on the bus */
-		lec_type = c_can_has_and_handle_berr(priv);
-		if (lec_type)
-			work_done += c_can_handle_bus_err(dev, lec_type);
-	} else if ((irqstatus >= C_CAN_MSG_OBJ_RX_FIRST) &&
-			(irqstatus <= C_CAN_MSG_OBJ_RX_LAST)) {
-		/* handle events corresponding to receive message objects */
+	/* handle lec errors on the bus */
+	lec_type = c_can_has_and_handle_berr(priv);
+	if (lec_type)
+		work_done += c_can_handle_bus_err(dev, lec_type);
+
+
+	/* handle Tx/Rx events */
+	if (curr & STATUS_RXOK) {
+		priv->write_reg(priv, C_CAN_STS_REG, curr & ~STATUS_RXOK);
 		work_done += c_can_do_rx_poll(dev, (quota - work_done));
-	} else if ((irqstatus >= C_CAN_MSG_OBJ_TX_FIRST) &&
-			(irqstatus <= C_CAN_MSG_OBJ_TX_LAST)) {
-		/* handle events corresponding to transmit message objects */
+	}
+
+	if (curr & STATUS_TXOK) {
+		priv->write_reg(priv, C_CAN_STS_REG, curr & ~STATUS_TXOK);
 		c_can_do_tx(dev);
 	}
 
-end:
 	if (work_done < quota) {
 		napi_complete(napi);
 		/* enable all IRQs */
@@ -1132,9 +1115,9 @@ static irqreturn_t c_can_isr(int irq, vo
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct c_can_priv *priv = netdev_priv(dev);
+	u32 stat = priv->read_reg(priv, C_CAN_INT_REG);
 
-	priv->irqstatus = priv->read_reg(priv, C_CAN_INT_REG);
-	if (!priv->irqstatus)
+	if (!stat)
 		return IRQ_NONE;
 
 	/* disable all interrupts and schedule the NAPI */
Index: linux/drivers/net/can/c_can/c_can.h
===================================================================
--- linux.orig/drivers/net/can/c_can/c_can.h
+++ linux/drivers/net/can/c_can/c_can.h
@@ -195,11 +195,11 @@ struct c_can_priv {
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
 
