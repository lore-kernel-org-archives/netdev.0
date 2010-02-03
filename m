From: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: [PATCH net-next-2.6 v3] can: mcp251x: Move to threaded interrupts
	instead of workqueues.
Date: Wed,  3 Feb 2010 18:39:54 +0100
Message-ID: <1265218794-25808-1-git-send-email-chripell@fsfe.org>
References: <cabda6421002030939w3788a40en38955d31dd765583@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <cabda6421002030939w3788a40en38955d31dd765583-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch addresses concerns about efficiency of handling incoming
packets. Handling of interrupts is done in a threaded interrupt handler
which has a smaller latency than workqueues. This change needed a rework
of the locking scheme that was much simplified. Some other (more or less
longstanding) bugs are fixed: utilization of just half of the RX
buffers, useless wait for interrupt on open, more reliable reset
sequence. The MERR interrupt is not used anymore: it overloads the CPU
in error-passive state without any additional information. One shot mode
is disabled because it's not clear if it can be handled efficiently on
this CAN controller.

Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
---
 drivers/net/can/mcp251x.c |  421 ++++++++++++++++++++++-----------------------
 1 files changed, 203 insertions(+), 218 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index bbe186b..f8cc168 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -180,6 +180,14 @@
 #define RXBEID0_OFF 4
 #define RXBDLC_OFF  5
 #define RXBDAT_OFF  6
+#define RXFSIDH(n) ((n) * 4)
+#define RXFSIDL(n) ((n) * 4 + 1)
+#define RXFEID8(n) ((n) * 4 + 2)
+#define RXFEID0(n) ((n) * 4 + 3)
+#define RXMSIDH(n) ((n) * 4 + 0x20)
+#define RXMSIDL(n) ((n) * 4 + 0x21)
+#define RXMEID8(n) ((n) * 4 + 0x22)
+#define RXMEID0(n) ((n) * 4 + 0x23)
 
 #define GET_BYTE(val, byte)			\
 	(((val) >> ((byte) * 8)) & 0xff)
@@ -219,7 +227,8 @@ struct mcp251x_priv {
 	struct net_device *net;
 	struct spi_device *spi;
 
-	struct mutex spi_lock; /* SPI buffer lock */
+	struct mutex mcp_lock; /* SPI device lock */
+
 	u8 *spi_tx_buf;
 	u8 *spi_rx_buf;
 	dma_addr_t spi_tx_dma;
@@ -227,11 +236,11 @@ struct mcp251x_priv {
 
 	struct sk_buff *tx_skb;
 	int tx_len;
+
 	struct workqueue_struct *wq;
 	struct work_struct tx_work;
-	struct work_struct irq_work;
-	struct completion awake;
-	int wake;
+	struct work_struct restart_work;
+
 	int force_quit;
 	int after_suspend;
 #define AFTER_SUSPEND_UP 1
@@ -245,7 +254,8 @@ static void mcp251x_clean(struct net_device *net)
 {
 	struct mcp251x_priv *priv = netdev_priv(net);
 
-	net->stats.tx_errors++;
+	if (priv->tx_skb || priv->tx_len)
+		net->stats.tx_errors++;
 	if (priv->tx_skb)
 		dev_kfree_skb(priv->tx_skb);
 	if (priv->tx_len)
@@ -300,16 +310,12 @@ static u8 mcp251x_read_reg(struct spi_device *spi, uint8_t reg)
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 	u8 val = 0;
 
-	mutex_lock(&priv->spi_lock);
-
 	priv->spi_tx_buf[0] = INSTRUCTION_READ;
 	priv->spi_tx_buf[1] = reg;
 
 	mcp251x_spi_trans(spi, 3);
 	val = priv->spi_rx_buf[2];
 
-	mutex_unlock(&priv->spi_lock);
-
 	return val;
 }
 
@@ -317,15 +323,11 @@ static void mcp251x_write_reg(struct spi_device *spi, u8 reg, uint8_t val)
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 
-	mutex_lock(&priv->spi_lock);
-
 	priv->spi_tx_buf[0] = INSTRUCTION_WRITE;
 	priv->spi_tx_buf[1] = reg;
 	priv->spi_tx_buf[2] = val;
 
 	mcp251x_spi_trans(spi, 3);
-
-	mutex_unlock(&priv->spi_lock);
 }
 
 static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
@@ -333,16 +335,12 @@ static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 
-	mutex_lock(&priv->spi_lock);
-
 	priv->spi_tx_buf[0] = INSTRUCTION_BIT_MODIFY;
 	priv->spi_tx_buf[1] = reg;
 	priv->spi_tx_buf[2] = mask;
 	priv->spi_tx_buf[3] = val;
 
 	mcp251x_spi_trans(spi, 4);
-
-	mutex_unlock(&priv->spi_lock);
 }
 
 static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
@@ -358,10 +356,8 @@ static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
 			mcp251x_write_reg(spi, TXBCTRL(tx_buf_idx) + i,
 					  buf[i]);
 	} else {
-		mutex_lock(&priv->spi_lock);
 		memcpy(priv->spi_tx_buf, buf, TXBDAT_OFF + len);
 		mcp251x_spi_trans(spi, TXBDAT_OFF + len);
-		mutex_unlock(&priv->spi_lock);
 	}
 }
 
@@ -408,13 +404,9 @@ static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
 		for (; i < (RXBDAT_OFF + len); i++)
 			buf[i] = mcp251x_read_reg(spi, RXBCTRL(buf_idx) + i);
 	} else {
-		mutex_lock(&priv->spi_lock);
-
 		priv->spi_tx_buf[RXBCTRL_OFF] = INSTRUCTION_READ_RXB(buf_idx);
 		mcp251x_spi_trans(spi, SPI_TRANSFER_BUF_LEN);
 		memcpy(buf, priv->spi_rx_buf, SPI_TRANSFER_BUF_LEN);
-
-		mutex_unlock(&priv->spi_lock);
 	}
 }
 
@@ -467,21 +459,6 @@ static void mcp251x_hw_sleep(struct spi_device *spi)
 	mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_SLEEP);
 }
 
-static void mcp251x_hw_wakeup(struct spi_device *spi)
-{
-	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
-
-	priv->wake = 1;
-
-	/* Can only wake up by generating a wake-up interrupt. */
-	mcp251x_write_bits(spi, CANINTE, CANINTE_WAKIE, CANINTE_WAKIE);
-	mcp251x_write_bits(spi, CANINTF, CANINTF_WAKIF, CANINTF_WAKIF);
-
-	/* Wait until the device is awake */
-	if (!wait_for_completion_timeout(&priv->awake, HZ))
-		dev_err(&spi->dev, "MCP251x didn't wake-up\n");
-}
-
 static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
 					   struct net_device *net)
 {
@@ -490,7 +467,6 @@ static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
 
 	if (priv->tx_skb || priv->tx_len) {
 		dev_warn(&spi->dev, "hard_xmit called while tx busy\n");
-		netif_stop_queue(net);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -511,12 +487,13 @@ static int mcp251x_do_set_mode(struct net_device *net, enum can_mode mode)
 
 	switch (mode) {
 	case CAN_MODE_START:
+		mcp251x_clean(net);
 		/* We have to delay work since SPI I/O may sleep */
 		priv->can.state = CAN_STATE_ERROR_ACTIVE;
 		priv->restart_tx = 1;
 		if (priv->can.restart_ms == 0)
 			priv->after_suspend = AFTER_SUSPEND_RESTART;
-		queue_work(priv->wq, &priv->irq_work);
+		queue_work(priv->wq, &priv->restart_work);
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -525,7 +502,7 @@ static int mcp251x_do_set_mode(struct net_device *net, enum can_mode mode)
 	return 0;
 }
 
-static void mcp251x_set_normal_mode(struct spi_device *spi)
+static int mcp251x_set_normal_mode(struct spi_device *spi)
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 	unsigned long timeout;
@@ -533,8 +510,7 @@ static void mcp251x_set_normal_mode(struct spi_device *spi)
 	/* Enable interrupts */
 	mcp251x_write_reg(spi, CANINTE,
 			  CANINTE_ERRIE | CANINTE_TX2IE | CANINTE_TX1IE |
-			  CANINTE_TX0IE | CANINTE_RX1IE | CANINTE_RX0IE |
-			  CANINTF_MERRF);
+			  CANINTE_TX0IE | CANINTE_RX1IE | CANINTE_RX0IE);
 
 	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
 		/* Put device into loopback mode */
@@ -544,9 +520,7 @@ static void mcp251x_set_normal_mode(struct spi_device *spi)
 		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_LISTEN_ONLY);
 	} else {
 		/* Put device into normal mode */
-		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_NORMAL |
-				  (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT ?
-				   CANCTRL_OSM : 0));
+		mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_NORMAL);
 
 		/* Wait for the device to enter normal mode */
 		timeout = jiffies + HZ;
@@ -555,11 +529,12 @@ static void mcp251x_set_normal_mode(struct spi_device *spi)
 			if (time_after(jiffies, timeout)) {
 				dev_err(&spi->dev, "MCP251x didn't"
 					" enter in normal mode\n");
-				return;
+				return -EBUSY;
 			}
 		}
 	}
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+	return 0;
 }
 
 static int mcp251x_do_set_bittiming(struct net_device *net)
@@ -590,33 +565,39 @@ static int mcp251x_setup(struct net_device *net, struct mcp251x_priv *priv,
 {
 	mcp251x_do_set_bittiming(net);
 
-	/* Enable RX0->RX1 buffer roll over and disable filters */
-	mcp251x_write_bits(spi, RXBCTRL(0),
-			   RXBCTRL_BUKT | RXBCTRL_RXM0 | RXBCTRL_RXM1,
-			   RXBCTRL_BUKT | RXBCTRL_RXM0 | RXBCTRL_RXM1);
-	mcp251x_write_bits(spi, RXBCTRL(1),
-			   RXBCTRL_RXM0 | RXBCTRL_RXM1,
-			   RXBCTRL_RXM0 | RXBCTRL_RXM1);
+	mcp251x_write_reg(spi, RXBCTRL(0),
+			  RXBCTRL_BUKT | RXBCTRL_RXM0 | RXBCTRL_RXM1);
+	mcp251x_write_reg(spi, RXBCTRL(1),
+			  RXBCTRL_RXM0 | RXBCTRL_RXM1);
 	return 0;
 }
 
-static void mcp251x_hw_reset(struct spi_device *spi)
+static int mcp251x_hw_reset(struct spi_device *spi)
 {
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 	int ret;
-
-	mutex_lock(&priv->spi_lock);
+	unsigned long timeout;
 
 	priv->spi_tx_buf[0] = INSTRUCTION_RESET;
-
 	ret = spi_write(spi, priv->spi_tx_buf, 1);
-
-	mutex_unlock(&priv->spi_lock);
-
-	if (ret)
+	if (ret) {
 		dev_err(&spi->dev, "reset failed: ret = %d\n", ret);
+		return -EIO;
+	}
+
 	/* Wait for reset to finish */
+	timeout = jiffies + HZ;
 	mdelay(10);
+	while ((mcp251x_read_reg(spi, CANSTAT) & CANCTRL_REQOP_MASK)
+	       != CANCTRL_REQOP_CONF) {
+		schedule();
+		if (time_after(jiffies, timeout)) {
+			dev_err(&spi->dev, "MCP251x didn't"
+				" enter in conf mode after reset\n");
+			return -EBUSY;
+		}
+	}
+	return 0;
 }
 
 static int mcp251x_hw_probe(struct spi_device *spi)
@@ -640,63 +621,17 @@ static int mcp251x_hw_probe(struct spi_device *spi)
 	return (st1 == 0x80 && st2 == 0x07) ? 1 : 0;
 }
 
-static irqreturn_t mcp251x_can_isr(int irq, void *dev_id)
-{
-	struct net_device *net = (struct net_device *)dev_id;
-	struct mcp251x_priv *priv = netdev_priv(net);
-
-	/* Schedule bottom half */
-	if (!work_pending(&priv->irq_work))
-		queue_work(priv->wq, &priv->irq_work);
-
-	return IRQ_HANDLED;
-}
-
-static int mcp251x_open(struct net_device *net)
+static void mcp251x_open_clean(struct net_device *net)
 {
 	struct mcp251x_priv *priv = netdev_priv(net);
 	struct spi_device *spi = priv->spi;
 	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
-	int ret;
-
-	ret = open_candev(net);
-	if (ret) {
-		dev_err(&spi->dev, "unable to set initial baudrate!\n");
-		return ret;
-	}
 
+	free_irq(spi->irq, priv);
+	mcp251x_hw_sleep(spi);
 	if (pdata->transceiver_enable)
-		pdata->transceiver_enable(1);
-
-	priv->force_quit = 0;
-	priv->tx_skb = NULL;
-	priv->tx_len = 0;
-
-	ret = request_irq(spi->irq, mcp251x_can_isr,
-			  IRQF_TRIGGER_FALLING, DEVICE_NAME, net);
-	if (ret) {
-		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
-		if (pdata->transceiver_enable)
-			pdata->transceiver_enable(0);
-		close_candev(net);
-		return ret;
-	}
-
-	mcp251x_hw_wakeup(spi);
-	mcp251x_hw_reset(spi);
-	ret = mcp251x_setup(net, priv, spi);
-	if (ret) {
-		free_irq(spi->irq, net);
-		mcp251x_hw_sleep(spi);
-		if (pdata->transceiver_enable)
-			pdata->transceiver_enable(0);
-		close_candev(net);
-		return ret;
-	}
-	mcp251x_set_normal_mode(spi);
-	netif_wake_queue(net);
-
-	return 0;
+		pdata->transceiver_enable(0);
+	close_candev(net);
 }
 
 static int mcp251x_stop(struct net_device *net)
@@ -707,17 +642,19 @@ static int mcp251x_stop(struct net_device *net)
 
 	close_candev(net);
 
+	priv->force_quit = 1;
+	free_irq(spi->irq, priv);
+	destroy_workqueue(priv->wq);
+	priv->wq = NULL;
+
+	mutex_lock(&priv->mcp_lock);
+
 	/* Disable and clear pending interrupts */
 	mcp251x_write_reg(spi, CANINTE, 0x00);
 	mcp251x_write_reg(spi, CANINTF, 0x00);
 
-	priv->force_quit = 1;
-	free_irq(spi->irq, net);
-	flush_workqueue(priv->wq);
-
 	mcp251x_write_reg(spi, TXBCTRL(0), 0);
-	if (priv->tx_skb || priv->tx_len)
-		mcp251x_clean(net);
+	mcp251x_clean(net);
 
 	mcp251x_hw_sleep(spi);
 
@@ -726,9 +663,27 @@ static int mcp251x_stop(struct net_device *net)
 
 	priv->can.state = CAN_STATE_STOPPED;
 
+	mutex_unlock(&priv->mcp_lock);
+
 	return 0;
 }
 
+static void mcp251x_error_skb(struct net_device *net, int can_id, int data1)
+{
+	struct sk_buff *skb;
+	struct can_frame *frame;
+
+	skb = alloc_can_err_skb(net, &frame);
+	if (skb) {
+		frame->can_id = can_id;
+		frame->data[1] = data1;
+		netif_rx(skb);
+	} else {
+		dev_err(&net->dev,
+			"cannot allocate error skb\n");
+	}
+}
+
 static void mcp251x_tx_work_handler(struct work_struct *ws)
 {
 	struct mcp251x_priv *priv = container_of(ws, struct mcp251x_priv,
@@ -737,33 +692,32 @@ static void mcp251x_tx_work_handler(struct work_struct *ws)
 	struct net_device *net = priv->net;
 	struct can_frame *frame;
 
+	mutex_lock(&priv->mcp_lock);
 	if (priv->tx_skb) {
-		frame = (struct can_frame *)priv->tx_skb->data;
-
 		if (priv->can.state == CAN_STATE_BUS_OFF) {
 			mcp251x_clean(net);
-			netif_wake_queue(net);
-			return;
+		} else {
+			frame = (struct can_frame *)priv->tx_skb->data;
+
+			if (frame->can_dlc > CAN_FRAME_MAX_DATA_LEN)
+				frame->can_dlc = CAN_FRAME_MAX_DATA_LEN;
+			mcp251x_hw_tx(spi, frame, 0);
+			priv->tx_len = 1 + frame->can_dlc;
+			can_put_echo_skb(priv->tx_skb, net, 0);
+			priv->tx_skb = NULL;
 		}
-		if (frame->can_dlc > CAN_FRAME_MAX_DATA_LEN)
-			frame->can_dlc = CAN_FRAME_MAX_DATA_LEN;
-		mcp251x_hw_tx(spi, frame, 0);
-		priv->tx_len = 1 + frame->can_dlc;
-		can_put_echo_skb(priv->tx_skb, net, 0);
-		priv->tx_skb = NULL;
 	}
+	mutex_unlock(&priv->mcp_lock);
 }
 
-static void mcp251x_irq_work_handler(struct work_struct *ws)
+static void mcp251x_restart_work_handler(struct work_struct *ws)
 {
 	struct mcp251x_priv *priv = container_of(ws, struct mcp251x_priv,
-						 irq_work);
+						 restart_work);
 	struct spi_device *spi = priv->spi;
 	struct net_device *net = priv->net;
-	u8 txbnctrl;
-	u8 intf;
-	enum can_state new_state;
 
+	mutex_lock(&priv->mcp_lock);
 	if (priv->after_suspend) {
 		mdelay(10);
 		mcp251x_hw_reset(spi);
@@ -772,45 +726,54 @@ static void mcp251x_irq_work_handler(struct work_struct *ws)
 			mcp251x_set_normal_mode(spi);
 		} else if (priv->after_suspend & AFTER_SUSPEND_UP) {
 			netif_device_attach(net);
-			/* Clean since we lost tx buffer */
-			if (priv->tx_skb || priv->tx_len) {
-				mcp251x_clean(net);
-				netif_wake_queue(net);
-			}
+			mcp251x_clean(net);
 			mcp251x_set_normal_mode(spi);
+			netif_wake_queue(net);
 		} else {
 			mcp251x_hw_sleep(spi);
 		}
 		priv->after_suspend = 0;
+		priv->force_quit = 0;
 	}
 
-	if (priv->can.restart_ms == 0 && priv->can.state == CAN_STATE_BUS_OFF)
-		return;
+	if (priv->restart_tx) {
+		priv->restart_tx = 0;
+		mcp251x_write_reg(spi, TXBCTRL(0), 0);
+		mcp251x_clean(net);
+		netif_wake_queue(net);
+		mcp251x_error_skb(net, CAN_ERR_RESTARTED, 0);
+	}
+	mutex_unlock(&priv->mcp_lock);
+}
 
-	while (!priv->force_quit && !freezing(current)) {
-		u8 eflag = mcp251x_read_reg(spi, EFLG);
-		int can_id = 0, data1 = 0;
+static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
+{
+	struct mcp251x_priv *priv = dev_id;
+	struct spi_device *spi = priv->spi;
+	struct net_device *net = priv->net;
 
-		mcp251x_write_reg(spi, EFLG, 0x00);
+	mutex_lock(&priv->mcp_lock);
+	while (!priv->force_quit) {
+		enum can_state new_state;
+		u8 intf = mcp251x_read_reg(spi, CANINTF);
+		u8 eflag;
+		int can_id = 0, data1 = 0;
 
-		if (priv->restart_tx) {
-			priv->restart_tx = 0;
-			mcp251x_write_reg(spi, TXBCTRL(0), 0);
-			if (priv->tx_skb || priv->tx_len)
-				mcp251x_clean(net);
-			netif_wake_queue(net);
-			can_id |= CAN_ERR_RESTARTED;
+		if (intf & CANINTF_RX0IF) {
+			mcp251x_hw_rx(spi, 0);
+			/* Free one buffer ASAP */
+			mcp251x_write_bits(spi, CANINTF, intf & CANINTF_RX0IF,
+					   0x00);
 		}
 
-		if (priv->wake) {
-			/* Wait whilst the device wakes up */
-			mdelay(10);
-			priv->wake = 0;
-		}
+		if (intf & CANINTF_RX1IF)
+			mcp251x_hw_rx(spi, 1);
 
-		intf = mcp251x_read_reg(spi, CANINTF);
 		mcp251x_write_bits(spi, CANINTF, intf, 0x00);
 
+		eflag = mcp251x_read_reg(spi, EFLG);
+		mcp251x_write_reg(spi, EFLG, 0x00);
+
 		/* Update can state */
 		if (eflag & EFLG_TXBO) {
 			new_state = CAN_STATE_BUS_OFF;
@@ -851,59 +814,31 @@ static void mcp251x_irq_work_handler(struct work_struct *ws)
 		}
 		priv->can.state = new_state;
 
-		if ((intf & CANINTF_ERRIF) || (can_id & CAN_ERR_RESTARTED)) {
-			struct sk_buff *skb;
-			struct can_frame *frame;
-
-			/* Create error frame */
-			skb = alloc_can_err_skb(net, &frame);
-			if (skb) {
-				/* Set error frame flags based on bus state */
-				frame->can_id = can_id;
-				frame->data[1] = data1;
-
-				/* Update net stats for overflows */
-				if (eflag & (EFLG_RX0OVR | EFLG_RX1OVR)) {
-					if (eflag & EFLG_RX0OVR)
-						net->stats.rx_over_errors++;
-					if (eflag & EFLG_RX1OVR)
-						net->stats.rx_over_errors++;
-					frame->can_id |= CAN_ERR_CRTL;
-					frame->data[1] |=
-						CAN_ERR_CRTL_RX_OVERFLOW;
-				}
-
-				netif_rx(skb);
-			} else {
-				dev_info(&spi->dev,
-					 "cannot allocate error skb\n");
+		if (intf & CANINTF_ERRIF) {
+			/* Handle overflow counters */
+			if (eflag & (EFLG_RX0OVR | EFLG_RX1OVR)) {
+				if (eflag & EFLG_RX0OVR)
+					net->stats.rx_over_errors++;
+				if (eflag & EFLG_RX1OVR)
+					net->stats.rx_over_errors++;
+				can_id |= CAN_ERR_CRTL;
+				data1 |= CAN_ERR_CRTL_RX_OVERFLOW;
 			}
+			mcp251x_error_skb(net, can_id, data1);
 		}
 
 		if (priv->can.state == CAN_STATE_BUS_OFF) {
 			if (priv->can.restart_ms == 0) {
+				priv->force_quit = 1;
 				can_bus_off(net);
 				mcp251x_hw_sleep(spi);
-				return;
+				break;
 			}
 		}
 
 		if (intf == 0)
 			break;
 
-		if (intf & CANINTF_WAKIF)
-			complete(&priv->awake);
-
-		if (intf & CANINTF_MERRF) {
-			/* If there are pending Tx buffers, restart queue */
-			txbnctrl = mcp251x_read_reg(spi, TXBCTRL(0));
-			if (!(txbnctrl & TXBCTRL_TXREQ)) {
-				if (priv->tx_skb || priv->tx_len)
-					mcp251x_clean(net);
-				netif_wake_queue(net);
-			}
-		}
-
 		if (intf & (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)) {
 			net->stats.tx_packets++;
 			net->stats.tx_bytes += priv->tx_len - 1;
@@ -914,12 +849,66 @@ static void mcp251x_irq_work_handler(struct work_struct *ws)
 			netif_wake_queue(net);
 		}
 
-		if (intf & CANINTF_RX0IF)
-			mcp251x_hw_rx(spi, 0);
+	}
+	mutex_unlock(&priv->mcp_lock);
+	return IRQ_HANDLED;
+}
 
-		if (intf & CANINTF_RX1IF)
-			mcp251x_hw_rx(spi, 1);
+static int mcp251x_open(struct net_device *net)
+{
+	struct mcp251x_priv *priv = netdev_priv(net);
+	struct spi_device *spi = priv->spi;
+	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
+	int ret;
+
+	ret = open_candev(net);
+	if (ret) {
+		dev_err(&spi->dev, "unable to set initial baudrate!\n");
+		return ret;
+	}
+
+	mutex_lock(&priv->mcp_lock);
+	if (pdata->transceiver_enable)
+		pdata->transceiver_enable(1);
+
+	priv->force_quit = 0;
+	priv->tx_skb = NULL;
+	priv->tx_len = 0;
+
+	ret = request_threaded_irq(spi->irq, NULL, mcp251x_can_ist,
+			  IRQF_TRIGGER_FALLING, DEVICE_NAME, priv);
+	if (ret) {
+		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
+		if (pdata->transceiver_enable)
+			pdata->transceiver_enable(0);
+		close_candev(net);
+		goto open_unlock;
+	}
+
+	priv->wq = create_freezeable_workqueue("mcp251x_wq");
+	INIT_WORK(&priv->tx_work, mcp251x_tx_work_handler);
+	INIT_WORK(&priv->restart_work, mcp251x_restart_work_handler);
+
+	ret = mcp251x_hw_reset(spi);
+	if (ret) {
+		mcp251x_open_clean(net);
+		goto open_unlock;
+	}
+	ret = mcp251x_setup(net, priv, spi);
+	if (ret) {
+		mcp251x_open_clean(net);
+		goto open_unlock;
 	}
+	ret = mcp251x_set_normal_mode(spi);
+	if (ret) {
+		mcp251x_open_clean(net);
+		goto open_unlock;
+	}
+	netif_wake_queue(net);
+
+open_unlock:
+	mutex_unlock(&priv->mcp_lock);
+	return ret;
 }
 
 static const struct net_device_ops mcp251x_netdev_ops = {
@@ -955,13 +944,11 @@ static int __devinit mcp251x_can_probe(struct spi_device *spi)
 	priv->can.clock.freq = pdata->oscillator_frequency / 2;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
 		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
-	if (pdata->model == CAN_MCP251X_MCP2515)
-		priv->can.ctrlmode_supported |= CAN_CTRLMODE_ONE_SHOT;
 	priv->net = net;
 	dev_set_drvdata(&spi->dev, priv);
 
 	priv->spi = spi;
-	mutex_init(&priv->spi_lock);
+	mutex_init(&priv->mcp_lock);
 
 	/* If requested, allocate DMA buffers */
 	if (mcp251x_enable_dma) {
@@ -1010,18 +997,12 @@ static int __devinit mcp251x_can_probe(struct spi_device *spi)
 
 	SET_NETDEV_DEV(net, &spi->dev);
 
-	priv->wq = create_freezeable_workqueue("mcp251x_wq");
-
-	INIT_WORK(&priv->tx_work, mcp251x_tx_work_handler);
-	INIT_WORK(&priv->irq_work, mcp251x_irq_work_handler);
-
-	init_completion(&priv->awake);
-
 	/* Configure the SPI bus */
 	spi->mode = SPI_MODE_0;
 	spi->bits_per_word = 8;
 	spi_setup(spi);
 
+	/* Here is OK to not lock the MCP, no one knows about it yet */
 	if (!mcp251x_hw_probe(spi)) {
 		dev_info(&spi->dev, "Probe failed\n");
 		goto error_probe;
@@ -1064,10 +1045,6 @@ static int __devexit mcp251x_can_remove(struct spi_device *spi)
 	unregister_candev(net);
 	free_candev(net);
 
-	priv->force_quit = 1;
-	flush_workqueue(priv->wq);
-	destroy_workqueue(priv->wq);
-
 	if (mcp251x_enable_dma) {
 		dma_free_coherent(&spi->dev, PAGE_SIZE,
 				  priv->spi_tx_buf, priv->spi_tx_dma);
@@ -1089,6 +1066,12 @@ static int mcp251x_can_suspend(struct spi_device *spi, pm_message_t state)
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
 	struct net_device *net = priv->net;
 
+	priv->force_quit = 1;
+	disable_irq(spi->irq);
+	/*
+	 * Note: at this point neither IST nor workqueues are running.
+	 * open/stop cannot be called anyway so locking is not needed
+	 */
 	if (netif_running(net)) {
 		netif_device_detach(net);
 
@@ -1115,16 +1098,18 @@ static int mcp251x_can_resume(struct spi_device *spi)
 
 	if (priv->after_suspend & AFTER_SUSPEND_POWER) {
 		pdata->power_enable(1);
-		queue_work(priv->wq, &priv->irq_work);
+		queue_work(priv->wq, &priv->restart_work);
 	} else {
 		if (priv->after_suspend & AFTER_SUSPEND_UP) {
 			if (pdata->transceiver_enable)
 				pdata->transceiver_enable(1);
-			queue_work(priv->wq, &priv->irq_work);
+			queue_work(priv->wq, &priv->restart_work);
 		} else {
 			priv->after_suspend = 0;
 		}
 	}
+	priv->force_quit = 0;
+	enable_irq(spi->irq);
 	return 0;
 }
 #else
-- 
1.5.6.5
