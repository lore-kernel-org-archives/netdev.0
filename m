From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 09/13] at86rf230: rework state change and start/stop
Date: Sat, 28 Jun 2014 20:33:47 +0200
Message-ID: <1403980431-6201-10-git-send-email-alex.aring@gmail.com>
References: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, werner@almesberger.net,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:47320 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbaF1Sep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 14:34:45 -0400
Received: by mail-wg0-f41.google.com with SMTP id a1so6471919wgh.12
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 11:34:44 -0700 (PDT)
In-Reply-To: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the current synchron state change function and add a
new function for a state assert. Change the start and stop callbacks to
use this new synchron state change behaviour. It's a wrapper around the
async state change function.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 126 ++++++++++++++++++++-----------------
 1 file changed, 67 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 4ac7c4b..9829248 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -44,6 +44,8 @@ struct at86rf230_local;
  * All timings are in us.
  */
 struct at86rf2xx_chip_data {
+	u16 t_off_to_aack;
+	u16 t_off_to_tx_on;
 	u16 t_frame;
 	u16 t_p_ack;
 	/* short interframe spacing time */
@@ -79,6 +81,9 @@ struct at86rf230_local {
 	struct at86rf2xx_chip_data *data;
 	struct regmap *regmap;
 
+	struct completion state_complete;
+	struct at86rf230_state_change state;
+
 	struct at86rf230_state_change irq;
 
 	bool tx_aret;
@@ -549,6 +554,19 @@ at86rf230_async_state_delay(void *context)
 	}
 
 	switch (ctx->from_state) {
+	case STATE_TRX_OFF:
+		switch (ctx->to_state) {
+		case STATE_RX_AACK_ON:
+			usleep_range(c->t_off_to_aack, c->t_off_to_aack + 10);
+			goto change;
+		case STATE_TX_ON:
+			usleep_range(c->t_off_to_tx_on,
+				     c->t_off_to_tx_on + 10);
+			goto change;
+		default:
+			break;
+		}
+		break;
 	case STATE_BUSY_RX_AACK:
 		switch (ctx->to_state) {
 		case STATE_TX_ON:
@@ -634,6 +652,39 @@ at86rf230_async_state_change(struct at86rf230_local *lp,
 }
 
 static void
+at86rf230_sync_state_change_complete(void *context)
+{
+	struct at86rf230_state_change *ctx = context;
+	struct at86rf230_local *lp = ctx->lp;
+
+	complete(&lp->state_complete);
+}
+
+/* This function do a sync framework above the async state change.
+ * Some callbacks of the IEEE 802.15.4 driver interface need to be
+ * handled synchronously.
+ */
+static int
+at86rf230_sync_state_change(struct at86rf230_local *lp, unsigned int state)
+{
+	int rc;
+
+	rc = at86rf230_async_state_change(lp, &lp->state, state,
+					  at86rf230_sync_state_change_complete);
+	if (rc) {
+		at86rf230_async_error(lp, &lp->state, rc);
+		return rc;
+	}
+
+	rc = wait_for_completion_timeout(&lp->state_complete,
+					 msecs_to_jiffies(100));
+	if (!rc)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static void
 at86rf230_tx_complete(void *context)
 {
 	struct at86rf230_state_change *ctx = context;
@@ -959,72 +1010,15 @@ at86rf230_ed(struct ieee802154_dev *dev, u8 *level)
 }
 
 static int
-at86rf230_state(struct ieee802154_dev *dev, int state)
-{
-	struct at86rf230_local *lp = dev->priv;
-	int rc;
-	unsigned int val;
-	u8 desired_status;
-
-	might_sleep();
-
-	if (state == STATE_FORCE_TX_ON)
-		desired_status = STATE_TX_ON;
-	else if (state == STATE_FORCE_TRX_OFF)
-		desired_status = STATE_TRX_OFF;
-	else
-		desired_status = state;
-
-	do {
-		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &val);
-		if (rc)
-			goto err;
-	} while (val == STATE_TRANSITION_IN_PROGRESS);
-
-	if (val == desired_status)
-		return 0;
-
-	/* state is equal to phy states */
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, state);
-	if (rc)
-		goto err;
-
-	do {
-		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &val);
-		if (rc)
-			goto err;
-	} while (val == STATE_TRANSITION_IN_PROGRESS);
-
-
-	if (val == desired_status ||
-	    (desired_status == STATE_RX_ON && val == STATE_BUSY_RX) ||
-	    (desired_status == STATE_RX_AACK_ON && val == STATE_BUSY_RX_AACK))
-		return 0;
-
-	pr_err("unexpected state change: %d, asked for %d\n", val, state);
-	return -EBUSY;
-
-err:
-	pr_err("error: %d\n", rc);
-	return rc;
-}
-
-static int
 at86rf230_start(struct ieee802154_dev *dev)
 {
-	u8 rc;
-
-	rc = at86rf230_state(dev, STATE_TX_ON);
-	if (rc)
-		return rc;
-
-	return at86rf230_state(dev, STATE_RX_AACK_ON);
+	return at86rf230_sync_state_change(dev->priv, STATE_RX_AACK_ON);
 }
 
 static void
 at86rf230_stop(struct ieee802154_dev *dev)
 {
-	at86rf230_state(dev, STATE_FORCE_TRX_OFF);
+	at86rf230_sync_state_change(dev->priv, STATE_FORCE_TRX_OFF);
 }
 
 static int
@@ -1244,6 +1238,8 @@ static struct ieee802154_ops at86rf230_ops = {
 };
 
 static struct at86rf2xx_chip_data at86rf233_data = {
+	.t_off_to_aack = 80,
+	.t_off_to_tx_on = 80,
 	.t_frame = 4096,
 	.t_p_ack = 545,
 	.t_sifs = 192,
@@ -1255,6 +1251,8 @@ static struct at86rf2xx_chip_data at86rf233_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf231_data = {
+	.t_off_to_aack = 110,
+	.t_off_to_tx_on = 110,
 	.t_frame = 4096,
 	.t_p_ack = 545,
 	.t_sifs = 192,
@@ -1266,6 +1264,8 @@ static struct at86rf2xx_chip_data at86rf231_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf212_data = {
+	.t_off_to_aack = 200,
+	.t_off_to_tx_on = 200,
 	.t_frame = 4096,
 	.t_p_ack = 545,
 	.t_sifs = 192,
@@ -1429,6 +1429,13 @@ at86rf230_detect_device(struct at86rf230_local *lp)
 static void
 at86rf230_setup_spi_messages(struct at86rf230_local *lp)
 {
+	lp->state.lp = lp;
+	spi_message_init(&lp->state.msg);
+	lp->state.msg.context = &lp->state;
+	lp->state.trx.tx_buf = lp->state.buf;
+	lp->state.trx.rx_buf = lp->state.buf;
+	spi_message_add_tail(&lp->state.trx, &lp->state.msg);
+
 	lp->irq.lp = lp;
 	spi_message_init(&lp->irq.msg);
 	lp->irq.msg.context = &lp->irq;
@@ -1511,6 +1518,7 @@ static int at86rf230_probe(struct spi_device *spi)
 
 	spin_lock_init(&lp->lock);
 	init_completion(&lp->tx_complete);
+	init_completion(&lp->state_complete);
 
 	spi_set_drvdata(spi, lp);
 
-- 
2.0.1
