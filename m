From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 net-next 06/13] at86rf230: rework
	transmit and receive handling
Date: Thu,  3 Jul 2014 00:20:48 +0200
Message-ID: <1404339655-8456-7-git-send-email-alex.aring@gmail.com>
References: <1404339655-8456-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1404339655-8456-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is a complete reimplementation of transmit and receive
handling for the at86rf230 driver.

It solves also six bugs:

First:

The RX_SAFE_MODE is enabled and the transceiver doesn't leave the
receive state while the framebuffer isn't read by a CMD_FB command.
This is useful to read out the frame and don't get into another receive
or transmit state, otherwise the frame would be overwritten.
The current driver do twice CMD_FB calls, the first one leaves this
protection.

Second:

Sometimes the CRC calculation is correct and the length field is greater
127. The current mac802154 layer and filter of a at86rf2xx doesn't check
on this and the kernel crashes. In this case the frame is corrupted, we
send the whole receive buffer to the next layer which can be useful for
sniffing.

Thrid:
There is a undocumented race condition. When we are go into the
RX_AACK_ON state the transceiver could be changed into RX_AACK_BUSY
state. This is a normal behaviour. In this case the transceiver received
a SHR while assert wasn't finished.

Fourth:
It also handle some more "correct" state changes. In aret mode the
transceiver need to go to TX_ON before the transceiver go into
RX_AACK_ON.

Fifth:
The programming model [0] describes also a error handling in ARET mode
if the trac status is different than zero. This is patch adds support
for handling this.

Sixth:
In receive handling the transceiver should also get the trac status
according [0]. The driver could use the trac status as error statistic
handling, but the driver doesn't use this currently. There is maybe some
timing behaviour or the read of this register change some transceiver
states.

In addition the irqworker is removed. Instead we do async spi calls and
no scheduling is involved anymore. The transmit function is also
asynchron but with a wait_for_completion handling. The mac802154 layer
doesn't support asynchron transmit handling right now.

The state change behaviour is now changes, before it was:

1. assert while(!STATE_TRANSITION_IN_PROGRESS)
2. state change
3. assert while(!STATE_TRANSITION_IN_PROGRESS)
4. assert once(wanted state != current state)

Sometimes a unexcepted state change occurs when 4. assert was violated.
The new state change behaviour is:

1. assert while(!STATE_TRANSITION_IN_PROGRESS)
2. state change
3. wait state change timing according datasheet
4. assert once(wanted state != current state)

This behaviour is described in the at86rf231 software programming model [0].
The state change documentation in this programming guide should also valid for
at86rf212 and at86rf233 chips.

The transceiver don't do a FORCE_TX_ON while we want to transmit a PDU.
The new behaviour is a TX_ON and wait a receiving time (tFrame + tPAck).
If we are still in RX_AACK_BUSY then we transmit a FORCE_TX_ON as timeout
handling. The different is that FORCE_TX_ON aborts receiving and TX_ON
waits if RX_AACK_BUSY is finished. This should decrease the drop rate of
packets.

[0] http://www.atmel.com/Images/AVR2022_swpm231-2.0.zip

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 839 +++++++++++++++++++++++++------------
 1 file changed, 571 insertions(+), 268 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 6556fece..39c3c11 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -26,8 +26,6 @@
 #include <linux/irq.h>
 #include <linux/gpio.h>
 #include <linux/delay.h>
-#include <linux/mutex.h>
-#include <linux/workqueue.h>
 #include <linux/spinlock.h>
 #include <linux/spi/spi.h>
 #include <linux/spi/at86rf230.h>
@@ -35,6 +33,7 @@
 #include <linux/skbuff.h>
 #include <linux/of_gpio.h>
 
+#include <net/ieee802154.h>
 #include <net/mac802154.h>
 #include <net/wpan-phy.h>
 
@@ -43,30 +42,50 @@ struct at86rf230_local;
  * All timings are in us.
  */
 struct at86rf2xx_chip_data {
+	u16 t_frame;
+	u16 t_p_ack;
+	/* short interframe spacing time */
+	u16 t_sifs;
+	/* long interframe spacing time */
+	u16 t_lifs;
+	/* completion timeout for tx in msecs */
+	u16 t_tx_timeout;
 	int rssi_base_val;
 
 	int (*set_channel)(struct at86rf230_local *, int, int);
 	int (*get_desense_steps)(struct at86rf230_local *, s32);
 };
 
-struct at86rf230_local {
-	struct spi_device *spi;
+#define AT86RF2XX_MAX_BUF (127 + 3)
 
-	u8 buf[2];
-	struct mutex bmux;
+struct at86rf230_state_change {
+	struct at86rf230_local *lp;
 
-	struct work_struct irqwork;
-	struct completion tx_complete;
+	struct spi_message msg;
+	struct spi_transfer trx;
+	u8 buf[AT86RF2XX_MAX_BUF];
+
+	void (*complete)(void *context);
+	u8 from_state;
+	u8 to_state;
+};
+
+struct at86rf230_local {
+	struct spi_device *spi;
 
 	struct ieee802154_dev *dev;
+	struct at86rf2xx_chip_data *data;
 	struct regmap *regmap;
 
-	spinlock_t lock;
-	bool irq_busy;
-	bool is_tx;
+	struct at86rf230_state_change irq;
 
-	struct at86rf2xx_chip_data *data;
 	bool tx_aret;
+	bool is_tx;
+	/* spinlock for is_tx protection */
+	spinlock_t lock;
+	struct completion tx_complete;
+	struct sk_buff *tx_skb;
+	struct at86rf230_state_change tx;
 };
 
 #define	RG_TRX_STATUS	(0x01)
@@ -263,6 +282,11 @@ struct at86rf230_local {
 
 #define AT86RF2XX_NUMREGS 0x3F
 
+static int
+at86rf230_async_state_change(struct at86rf230_local *lp,
+			     struct at86rf230_state_change *ctx,
+			     const u8 state, void (*complete)(void *context));
+
 static inline int
 __at86rf230_write(struct at86rf230_local *lp,
 		  unsigned int addr, unsigned int data)
@@ -412,104 +436,515 @@ static struct regmap_config at86rf230_regmap_spi_config = {
 	.precious_reg = at86rf230_reg_precious,
 };
 
+static void
+at86rf230_async_error_recover(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+
+	at86rf230_async_state_change(lp, ctx, STATE_RX_AACK_ON, NULL);
+}
+
+static void
+at86rf230_async_error(struct at86rf230_local *lp,
+		      struct at86rf230_state_change *ctx, int rc)
+{
+	dev_err(&lp->spi->dev, "spi_async error %d\n", rc);
+
+	at86rf230_async_state_change(lp, ctx, STATE_FORCE_TRX_OFF,
+				     at86rf230_async_error_recover);
+}
+
+/* Generic function to get some register value in async mode */
 static int
-at86rf230_write_fbuf(struct at86rf230_local *lp, u8 *data, u8 len)
+at86rf230_async_read_reg(struct at86rf230_local *lp, const u8 reg,
+			 struct at86rf230_state_change *ctx,
+			 void (*complete)(void *context))
 {
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer_head = {
-		.len		= 2,
-		.tx_buf		= buf,
-
-	};
-	struct spi_transfer xfer_buf = {
-		.len		= len,
-		.tx_buf		= data,
-	};
-
-	mutex_lock(&lp->bmux);
-	buf[0] = CMD_WRITE | CMD_FB;
-	buf[1] = len + 2; /* 2 bytes for CRC that isn't written */
-
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer_head, &msg);
-	spi_message_add_tail(&xfer_buf, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	if (msg.status)
-		status = msg.status;
-
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	mutex_unlock(&lp->bmux);
-	return status;
+	u8 *tx_buf = ctx->buf;
+
+	tx_buf[0] = (reg & CMD_REG_MASK) | CMD_REG;
+	ctx->trx.len = 2;
+	ctx->msg.complete = complete;
+	return spi_async(lp->spi, &ctx->msg);
+}
+
+static void
+at86rf230_async_state_assert(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	const u8 *buf = ctx->buf;
+	const u8 trx_state = buf[1] & 0x1f;
+
+	/* Assert state change */
+	if (trx_state != ctx->to_state) {
+		/* Special handling if transceiver state is in
+		 * STATE_BUSY_RX_AACK and a SHR was detected.
+		 */
+		if  (trx_state == STATE_BUSY_RX_AACK) {
+			/* Undocumented race condition. If we send a state
+			 * change to STATE_RX_AACK_ON the transceiver could
+			 * change his state automatically to STATE_BUSY_RX_AACK
+			 * if a SHR was detected. This is not an error, but we
+			 * can't assert this.
+			 */
+			if (ctx->to_state == STATE_RX_AACK_ON)
+				goto done;
+
+			/* If we change to STATE_TX_ON without forcing and
+			 * transceiver state is STATE_BUSY_RX_AACK, we wait
+			 * 'tFrame + tPAck' receiving time. In this time the
+			 * PDU should be received. If the transceiver is still
+			 * in STATE_BUSY_RX_AACK, we run a force state change
+			 * to STATE_TX_ON. This is a timeout handling, if the
+			 * transceiver stucks in STATE_BUSY_RX_AACK.
+			 */
+			if (ctx->to_state == STATE_TX_ON) {
+				at86rf230_async_state_change(lp, ctx,
+							     STATE_FORCE_TX_ON,
+							     ctx->complete);
+				return;
+			}
+		}
+
+
+		dev_warn(&lp->spi->dev, "unexcept state change from 0x%02x to 0x%02x. Actual state: 0x%02x\n",
+			 ctx->from_state, ctx->to_state, trx_state);
+	}
+
+done:
+	if (ctx->complete)
+		ctx->complete(context);
+}
+
+/* Do state change timing delay. */
+static void
+at86rf230_async_state_delay(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	struct at86rf2xx_chip_data *c = lp->data;
+	bool force = false;
+	int rc;
+
+	/* The force state changes are will show as normal states in the
+	 * state status subregister. We change the to_state to the
+	 * corresponding one and remember if it was a force change, this
+	 * differs if we do a state change from STATE_BUSY_RX_AACK.
+	 */
+	switch (ctx->to_state) {
+	case STATE_FORCE_TX_ON:
+		ctx->to_state = STATE_TX_ON;
+		force = true;
+		break;
+	case STATE_FORCE_TRX_OFF:
+		ctx->to_state = STATE_TRX_OFF;
+		force = true;
+		break;
+	default:
+		break;
+	}
+
+	switch (ctx->from_state) {
+	case STATE_BUSY_RX_AACK:
+		switch (ctx->to_state) {
+		case STATE_TX_ON:
+			/* Wait for worst case receiving time if we
+			 * didn't make a force change from BUSY_RX_AACK
+			 * to TX_ON.
+			 */
+			if (!force) {
+				usleep_range(c->t_frame + c->t_p_ack,
+					     c->t_frame + c->t_p_ack + 1000);
+				goto change;
+			}
+			break;
+		default:
+			break;
+		}
+		break;
+	default:
+		break;
+	}
+
+	/* Default delay is 1us in the most cases */
+	udelay(1);
+
+change:
+	rc = at86rf230_async_read_reg(lp, RG_TRX_STATUS, ctx,
+				      at86rf230_async_state_assert);
+	if (rc)
+		dev_err(&lp->spi->dev, "spi_async error %d\n", rc);
+}
+
+static void
+at86rf230_async_state_change_start(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	u8 *buf = ctx->buf;
+	const u8 trx_state = buf[1] & 0x1f;
+	int rc;
+
+	/* Check for "possible" STATE_TRANSITION_IN_PROGRESS */
+	if (trx_state == STATE_TRANSITION_IN_PROGRESS) {
+		udelay(1);
+		rc = at86rf230_async_read_reg(lp, RG_TRX_STATUS, ctx,
+					      at86rf230_async_state_change_start);
+		if (rc)
+			dev_err(&lp->spi->dev, "spi_async error %d\n", rc);
+		return;
+	}
+
+	/* Check if we already are in the state which we change in */
+	if (trx_state == ctx->to_state) {
+		if (ctx->complete)
+			ctx->complete(context);
+		return;
+	}
+
+	/* Set current state to the context of state change */
+	ctx->from_state = trx_state;
+
+	/* Going into the next step for a state change which do a timing
+	 * relevant delay.
+	 */
+	buf[0] = (RG_TRX_STATE & CMD_REG_MASK) | CMD_REG | CMD_WRITE;
+	buf[1] = ctx->to_state;
+	ctx->trx.len = 2;
+	ctx->msg.complete = at86rf230_async_state_delay;
+	rc = spi_async(lp->spi, &ctx->msg);
+	if (rc)
+		dev_err(&lp->spi->dev, "spi_async error %d\n", rc);
 }
 
 static int
-at86rf230_read_fbuf(struct at86rf230_local *lp, u8 *data, u8 *len, u8 *lqi)
+at86rf230_async_state_change(struct at86rf230_local *lp,
+			     struct at86rf230_state_change *ctx,
+			     const u8 state, void (*complete)(void *context))
 {
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer_head = {
-		.len		= 2,
-		.tx_buf		= buf,
-		.rx_buf		= buf,
-	};
-	struct spi_transfer xfer_head1 = {
-		.len		= 2,
-		.tx_buf		= buf,
-		.rx_buf		= buf,
-	};
-	struct spi_transfer xfer_buf = {
-		.len		= 0,
-		.rx_buf		= data,
-	};
-
-	mutex_lock(&lp->bmux);
+	/* Initialization for the state change context */
+	ctx->to_state = state;
+	ctx->complete = complete;
+	return at86rf230_async_read_reg(lp, RG_TRX_STATUS, ctx,
+					at86rf230_async_state_change_start);
+}
 
-	buf[0] = CMD_FB;
-	buf[1] = 0x00;
+static void
+at86rf230_tx_complete(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+
+	complete(&lp->tx_complete);
+}
+
+static void
+at86rf230_tx_on(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	int rc;
+
+	rc = at86rf230_async_state_change(lp, &lp->irq, STATE_RX_AACK_ON,
+					  at86rf230_tx_complete);
+	if (rc)
+		at86rf230_async_error(lp, ctx, rc);
+}
+
+static void
+at86rf230_tx_trac_error(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	int rc;
+
+	rc = at86rf230_async_state_change(lp, ctx, STATE_TX_ON,
+					  at86rf230_tx_on);
+	if (rc)
+		at86rf230_async_error(lp, ctx, rc);
+}
+
+static void
+at86rf230_tx_trac_check(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	const u8 *buf = ctx->buf;
+	const u8 trac = (buf[1] & 0xe0) >> 5;
+	int rc;
+
+	/* If trac status is different than zero we need to do a state change
+	 * to STATE_FORCE_TRX_OFF then STATE_TX_ON to recover the transceiver
+	 * state to TX_ON.
+	 */
+	if (trac) {
+		rc = at86rf230_async_state_change(lp, ctx, STATE_FORCE_TRX_OFF,
+						  at86rf230_tx_trac_error);
+		if (rc)
+			at86rf230_async_error(lp, ctx, rc);
+		return;
+	}
+
+	at86rf230_tx_on(context);
+}
+
+
+static void
+at86rf230_tx_trac_status(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	int rc;
+
+	rc = at86rf230_async_read_reg(lp, RG_TRX_STATE, ctx,
+				      at86rf230_tx_trac_check);
+	if (rc)
+		at86rf230_async_error(lp, ctx, rc);
+}
+
+static void
+at86rf230_rx(struct at86rf230_local *lp,
+	     const u8 *data, u8 len)
+{
+	u8 lqi;
+	struct sk_buff *skb;
+	u8 rx_local_buf[AT86RF2XX_MAX_BUF];
+
+	if (len < 2)
+		return;
+
+	/* read full frame buffer and invalid lqi value to lowest
+	 * indicator if frame was is in a corrupted state.
+	 */
+	if (len > IEEE802154_MTU) {
+		lqi = 0;
+		len = IEEE802154_MTU;
+		dev_vdbg(&lp->spi->dev, "corrupted frame received\n");
+	} else {
+		lqi = data[len];
+	}
+
+	memcpy(rx_local_buf, data, len);
+	enable_irq(lp->spi->irq);
+
+	skb = alloc_skb(IEEE802154_MTU, GFP_ATOMIC);
+	if (!skb) {
+		dev_vdbg(&lp->spi->dev, "failed to allocate sk_buff\n");
+		return;
+	}
+
+	memcpy(skb_put(skb, len), rx_local_buf, len);
+
+	/* We do not put CRC into the frame */
+	skb_trim(skb, len - 2);
 
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer_head, &msg);
+	ieee802154_rx_irqsafe(lp->dev, skb, lqi);
+}
 
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+static void
+at86rf230_rx_read_frame_complete(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	const u8 *buf = lp->irq.buf;
+	const u8 len = buf[1];
 
-	xfer_buf.len = *(buf + 1) + 1;
-	*len = buf[1];
+	at86rf230_rx(lp, buf + 2, len);
+}
+
+static int
+at86rf230_rx_read_frame(struct at86rf230_local *lp)
+{
+	u8 *buf = lp->irq.buf;
 
 	buf[0] = CMD_FB;
-	buf[1] = 0x00;
+	lp->irq.trx.len = AT86RF2XX_MAX_BUF;
+	lp->irq.msg.complete = at86rf230_rx_read_frame_complete;
+	return spi_async(lp->spi, &lp->irq.msg);
+}
+
+static void
+at86rf230_rx_trac_check(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	int rc;
+
+	/* Possible check on trac status here. This could be useful to make
+	 * some stats why receive is failed. Not used at the moment, but it's
+	 * maybe timing relevant. Datasheet doesn't say anything about this.
+	 * The programming guide say do it so.
+	 */
+
+	rc = at86rf230_rx_read_frame(lp);
+	if (rc) {
+		enable_irq(lp->spi->irq);
+		at86rf230_async_error(lp, ctx, rc);
+	}
+}
+
+static int
+at86rf230_irq_trx_end(struct at86rf230_local *lp)
+{
+	spin_lock(&lp->lock);
+	if (lp->is_tx) {
+		lp->is_tx = 0;
+		spin_unlock(&lp->lock);
+		enable_irq(lp->spi->irq);
+
+		if (lp->tx_aret)
+			return at86rf230_async_state_change(lp, &lp->irq,
+							    STATE_FORCE_TX_ON,
+							    at86rf230_tx_trac_status);
+		else
+			return at86rf230_async_state_change(lp, &lp->irq,
+							    STATE_RX_AACK_ON,
+							    at86rf230_tx_complete);
+	} else {
+		spin_unlock(&lp->lock);
+		return at86rf230_async_read_reg(lp, RG_TRX_STATE, &lp->irq,
+						at86rf230_rx_trac_check);
+	}
+}
+
+static void
+at86rf230_irq_status(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	const u8 *buf = lp->irq.buf;
+	const u8 irq = buf[1];
+	int rc;
+
+	if (irq & IRQ_TRX_END) {
+		rc = at86rf230_irq_trx_end(lp);
+		if (rc)
+			at86rf230_async_error(lp, ctx, rc);
+	} else {
+		enable_irq(lp->spi->irq);
+		dev_err(&lp->spi->dev, "not supported irq %02x received\n",
+			irq);
+	}
+}
+
+static irqreturn_t at86rf230_isr(int irq, void *data)
+{
+	struct at86rf230_local *lp = data;
+	struct at86rf230_state_change *ctx = &lp->irq;
+	u8 *buf = ctx->buf;
+	int rc;
+
+	disable_irq_nosync(lp->spi->irq);
+
+	buf[0] = (RG_IRQ_STATUS & CMD_REG_MASK) | CMD_REG;
+	ctx->trx.len = 2;
+	ctx->msg.complete = at86rf230_irq_status;
+	rc = spi_async(lp->spi, &ctx->msg);
+	if (rc) {
+		at86rf230_async_error(lp, ctx, rc);
+		return IRQ_NONE;
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void
+at86rf230_write_frame_complete(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	u8 *buf = ctx->buf;
+	int rc;
+
+	buf[0] = (RG_TRX_STATE & CMD_REG_MASK) | CMD_REG | CMD_WRITE;
+	buf[1] = STATE_BUSY_TX;
+	ctx->trx.len = 2;
+	ctx->msg.complete = NULL;
+	rc = spi_async(lp->spi, &ctx->msg);
+	if (rc)
+		at86rf230_async_error(lp, ctx, rc);
+}
+
+static void
+at86rf230_write_frame(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	struct sk_buff *skb = lp->tx_skb;
+	u8 *buf = lp->tx.buf;
+	int rc;
+
+	spin_lock(&lp->lock);
+	lp->is_tx = 1;
+	spin_unlock(&lp->lock);
+
+	buf[0] = CMD_FB | CMD_WRITE;
+	buf[1] = skb->len + 2;
+	memcpy(buf + 2, skb->data, skb->len);
+	lp->tx.trx.len = skb->len + 2;
+	lp->tx.msg.complete = at86rf230_write_frame_complete;
+	rc = spi_async(lp->spi, &lp->tx.msg);
+	if (rc)
+		at86rf230_async_error(lp, ctx, rc);
+}
+
+static void
+at86rf230_xmit_tx_on(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+	int rc;
 
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer_head1, &msg);
-	spi_message_add_tail(&xfer_buf, &msg);
+	rc = at86rf230_async_state_change(lp, ctx, STATE_TX_ARET_ON,
+					  at86rf230_write_frame);
+	if (rc)
+		at86rf230_async_error(lp, ctx, rc);
+}
+
+static int
+at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
+{
+	struct at86rf230_local *lp = dev->priv;
+	struct at86rf230_state_change *ctx = &lp->tx;
 
-	status = spi_sync(lp->spi, &msg);
+	void (*tx_complete)(void *context) = at86rf230_write_frame;
+	int rc;
 
-	if (msg.status)
-		status = msg.status;
+	lp->tx_skb = skb;
 
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
+	/* In ARET mode we need to go into STATE_TX_ARET_ON after we
+	 * are in STATE_TX_ON. The pfad differs here, so we change
+	 * the complete handler.
+	 */
+	if (lp->tx_aret)
+		tx_complete = at86rf230_xmit_tx_on;
 
-	if (status) {
-		if (lqi && (*len > lp->buf[1]))
-			*lqi = data[lp->buf[1]];
+	rc = at86rf230_async_state_change(lp, ctx, STATE_TX_ON,
+					  tx_complete);
+	if (rc) {
+		at86rf230_async_error(lp, ctx, rc);
+		return rc;
+	}
+	rc = wait_for_completion_interruptible_timeout(&lp->tx_complete,
+						       msecs_to_jiffies(lp->data->t_tx_timeout));
+	if (!rc) {
+		at86rf230_async_error(lp, ctx, rc);
+		return -ETIMEDOUT;
 	}
-	mutex_unlock(&lp->bmux);
 
-	return status;
+	/* Interfame spacing time, which is phy depend.
+	 * TODO
+	 * Move this handling in MAC 802.15.4 layer.
+	 * This is currently a workaround to avoid fragmenation issues.
+	 */
+	if (skb->len > 18)
+		usleep_range(lp->data->t_lifs, lp->data->t_lifs + 10);
+	else
+		usleep_range(lp->data->t_sifs, lp->data->t_sifs + 10);
+
+	return 0;
 }
 
 static int
@@ -652,92 +1087,6 @@ at86rf230_channel(struct ieee802154_dev *dev, int page, int channel)
 }
 
 static int
-at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
-{
-	struct at86rf230_local *lp = dev->priv;
-	int rc;
-	unsigned long flags;
-
-	spin_lock_irqsave(&lp->lock, flags);
-	if  (lp->irq_busy) {
-		spin_unlock_irqrestore(&lp->lock, flags);
-		return -EBUSY;
-	}
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	might_sleep();
-
-	rc = at86rf230_state(dev, STATE_FORCE_TX_ON);
-	if (rc)
-		goto err;
-
-	spin_lock_irqsave(&lp->lock, flags);
-	lp->is_tx = 1;
-	reinit_completion(&lp->tx_complete);
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	rc = at86rf230_write_fbuf(lp, skb->data, skb->len);
-	if (rc)
-		goto err_rx;
-
-	if (lp->tx_aret) {
-		rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_TX_ARET_ON);
-		if (rc)
-			goto err_rx;
-	}
-
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_BUSY_TX);
-	if (rc)
-		goto err_rx;
-
-	rc = wait_for_completion_interruptible(&lp->tx_complete);
-	if (rc < 0)
-		goto err_rx;
-
-	return at86rf230_start(dev);
-err_rx:
-	at86rf230_start(dev);
-err:
-	pr_err("error: %d\n", rc);
-
-	spin_lock_irqsave(&lp->lock, flags);
-	lp->is_tx = 0;
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	return rc;
-}
-
-static int at86rf230_rx(struct at86rf230_local *lp)
-{
-	u8 len = 128, lqi = 0;
-	struct sk_buff *skb;
-
-	skb = alloc_skb(len, GFP_KERNEL);
-
-	if (!skb)
-		return -ENOMEM;
-
-	if (at86rf230_read_fbuf(lp, skb_put(skb, len), &len, &lqi))
-		goto err;
-
-	if (len < 2)
-		goto err;
-
-	skb_trim(skb, len - 2); /* We do not put CRC into the frame */
-
-	ieee802154_rx_irqsafe(lp->dev, skb, lqi);
-
-	dev_dbg(&lp->spi->dev, "READ_FBUF: %d %x\n", len, lqi);
-
-	return 0;
-err:
-	pr_debug("received frame is too small\n");
-
-	kfree_skb(skb);
-	return -EINVAL;
-}
-
-static int
 at86rf230_set_hw_addr_filt(struct ieee802154_dev *dev,
 			   struct ieee802154_hw_addr_filt *filt,
 			   unsigned long changed)
@@ -898,87 +1247,38 @@ static struct ieee802154_ops at86rf230_ops = {
 };
 
 static struct at86rf2xx_chip_data at86rf233_data = {
+	.t_frame = 4096,
+	.t_p_ack = 545,
+	.t_sifs = 192,
+	.t_lifs = 480,
+	.t_tx_timeout = 2000,
 	.rssi_base_val = -91,
 	.set_channel = at86rf23x_set_channel,
 	.get_desense_steps = at86rf23x_get_desens_steps
 };
 
 static struct at86rf2xx_chip_data at86rf231_data = {
+	.t_frame = 4096,
+	.t_p_ack = 545,
+	.t_sifs = 192,
+	.t_lifs = 480,
+	.t_tx_timeout = 2000,
 	.rssi_base_val = -91,
 	.set_channel = at86rf23x_set_channel,
 	.get_desense_steps = at86rf23x_get_desens_steps
 };
 
 static struct at86rf2xx_chip_data at86rf212_data = {
+	.t_frame = 4096,
+	.t_p_ack = 545,
+	.t_sifs = 192,
+	.t_lifs = 480,
+	.t_tx_timeout = 2000,
 	.rssi_base_val = -100,
 	.set_channel = at86rf212_set_channel,
 	.get_desense_steps = at86rf212_get_desens_steps
 };
 
-static void at86rf230_irqwork(struct work_struct *work)
-{
-	struct at86rf230_local *lp =
-		container_of(work, struct at86rf230_local, irqwork);
-	unsigned int status;
-	int rc;
-	unsigned long flags;
-
-	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &status);
-
-	status &= ~IRQ_PLL_LOCK; /* ignore */
-	status &= ~IRQ_RX_START; /* ignore */
-	status &= ~IRQ_AMI; /* ignore */
-	status &= ~IRQ_TRX_UR; /* FIXME: possibly handle ???*/
-
-	if (status & IRQ_TRX_END) {
-		status &= ~IRQ_TRX_END;
-		spin_lock_irqsave(&lp->lock, flags);
-		if (lp->is_tx) {
-			lp->is_tx = 0;
-			spin_unlock_irqrestore(&lp->lock, flags);
-			complete(&lp->tx_complete);
-		} else {
-			spin_unlock_irqrestore(&lp->lock, flags);
-			at86rf230_rx(lp);
-		}
-	}
-
-	spin_lock_irqsave(&lp->lock, flags);
-	lp->irq_busy = 0;
-	spin_unlock_irqrestore(&lp->lock, flags);
-}
-
-static void at86rf230_irqwork_level(struct work_struct *work)
-{
-	struct at86rf230_local *lp =
-		container_of(work, struct at86rf230_local, irqwork);
-
-	at86rf230_irqwork(work);
-
-	enable_irq(lp->spi->irq);
-}
-
-static irqreturn_t at86rf230_isr(int irq, void *data)
-{
-	struct at86rf230_local *lp = data;
-	unsigned long flags;
-
-	spin_lock_irqsave(&lp->lock, flags);
-	lp->irq_busy = 1;
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	schedule_work(&lp->irqwork);
-
-	return IRQ_HANDLED;
-}
-
-static irqreturn_t at86rf230_isr_level(int irq, void *data)
-{
-	disable_irq_nosync(irq);
-
-	return at86rf230_isr(irq, data);
-}
-
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
 	int rc, irq_pol, irq_type;
@@ -1128,14 +1428,30 @@ at86rf230_detect_device(struct at86rf230_local *lp)
 	return rc;
 }
 
+static void
+at86rf230_setup_spi_messages(struct at86rf230_local *lp)
+{
+	lp->irq.lp = lp;
+	spi_message_init(&lp->irq.msg);
+	lp->irq.msg.context = &lp->irq;
+	lp->irq.trx.tx_buf = lp->irq.buf;
+	lp->irq.trx.rx_buf = lp->irq.buf;
+	spi_message_add_tail(&lp->irq.trx, &lp->irq.msg);
+
+	lp->tx.lp = lp;
+	spi_message_init(&lp->tx.msg);
+	lp->tx.msg.context = &lp->tx;
+	lp->tx.trx.tx_buf = lp->tx.buf;
+	lp->tx.trx.rx_buf = lp->tx.buf;
+	spi_message_add_tail(&lp->tx.trx, &lp->tx.msg);
+}
+
 static int at86rf230_probe(struct spi_device *spi)
 {
 	struct at86rf230_platform_data *pdata;
 	struct ieee802154_dev *dev;
 	struct at86rf230_local *lp;
 	unsigned int status;
-	irq_handler_t irq_handler;
-	work_func_t irq_worker;
 	int rc, irq_type;
 
 	if (!spi->irq) {
@@ -1189,23 +1505,12 @@ static int at86rf230_probe(struct spi_device *spi)
 		goto free_dev;
 	}
 
+	at86rf230_setup_spi_messages(lp);
+
 	rc = at86rf230_detect_device(lp);
 	if (rc < 0)
 		goto free_dev;
 
-	irq_type = irq_get_trigger_type(spi->irq);
-	if (!irq_type)
-		irq_type = IRQF_TRIGGER_RISING;
-	if (irq_type & (IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING)) {
-		irq_worker = at86rf230_irqwork;
-		irq_handler = at86rf230_isr;
-	} else {
-		irq_worker = at86rf230_irqwork_level;
-		irq_handler = at86rf230_isr_level;
-	}
-
-	mutex_init(&lp->bmux);
-	INIT_WORK(&lp->irqwork, irq_worker);
 	spin_lock_init(&lp->lock);
 	init_completion(&lp->tx_complete);
 
@@ -1213,28 +1518,28 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	rc = at86rf230_hw_init(lp);
 	if (rc)
-		goto err_hw_init;
+		goto free_dev;
 
 	/* Read irq status register to reset irq line */
 	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &status);
 	if (rc)
-		goto err_hw_init;
+		goto free_dev;
 
-	rc = devm_request_irq(&spi->dev, spi->irq, irq_handler,
-			      IRQF_SHARED | irq_type,
-			      dev_name(&spi->dev), lp);
+	irq_type = irq_get_trigger_type(spi->irq);
+	if (!irq_type)
+		irq_type = IRQF_TRIGGER_RISING;
+
+	rc = devm_request_irq(&spi->dev, spi->irq, at86rf230_isr,
+			      IRQF_SHARED | irq_type, dev_name(&spi->dev), lp);
 	if (rc)
-		goto err_hw_init;
+		goto free_dev;
 
 	rc = ieee802154_register_device(lp->dev);
 	if (rc)
-		goto err_hw_init;
+		goto free_dev;
 
 	return rc;
 
-err_hw_init:
-	flush_work(&lp->irqwork);
-	mutex_destroy(&lp->bmux);
 free_dev:
 	ieee802154_free_device(lp->dev);
 
@@ -1248,8 +1553,6 @@ static int at86rf230_remove(struct spi_device *spi)
 	/* mask all at86rf230 irq's */
 	at86rf230_write_subreg(lp, SR_IRQ_MASK, 0);
 	ieee802154_unregister_device(lp->dev);
-	flush_work(&lp->irqwork);
-	mutex_destroy(&lp->bmux);
 	ieee802154_free_device(lp->dev);
 	dev_dbg(&spi->dev, "unregistered at86rf230\n");
 
-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
