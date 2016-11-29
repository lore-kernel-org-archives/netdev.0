From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 2/5] net: ethernet: ti: davinci_cpdma: add set rate for a channel
Date: Tue, 29 Nov 2016 17:00:48 +0200
Message-ID: <1480431651-6081-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpdma has 8 rate limited tx channels. This patch adds
ability for cpdma driver to use 8 tx h/w shapers. If at least one
channel is not rate limited then it must have higher number, this
is because the rate limited channels have to have higher priority
then not rate limited channels. The channel priority is set in low-hi
direction already, so that when a new channel is added with ethtool
and it doesn't have rate yet, it cannot affect on rate limited
channels. It can be useful for TSN streams and just in cases when
h/w rate limited channels are needed.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 329 +++++++++++++++++++++++++++-----
 drivers/net/ethernet/ti/davinci_cpdma.h |   5 +
 2 files changed, 289 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 87456a9..c776e45 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -32,6 +32,7 @@
 #define CPDMA_RXCONTROL		0x14
 #define CPDMA_SOFTRESET		0x1c
 #define CPDMA_RXTEARDOWN	0x18
+#define CPDMA_TX_PRI0_RATE	0x30
 #define CPDMA_TXINTSTATRAW	0x80
 #define CPDMA_TXINTSTATMASKED	0x84
 #define CPDMA_TXINTMASKSET	0x88
@@ -68,6 +69,8 @@
 
 #define CPDMA_TEARDOWN_VALUE	0xfffffffc
 
+#define CPDMA_MAX_RLIM_CNT	16384
+
 struct cpdma_desc {
 	/* hardware fields */
 	u32			hw_next;
@@ -123,6 +126,8 @@ struct cpdma_chan {
 	/* offsets into dmaregs */
 	int	int_set, int_clear, td;
 	int				weight;
+	u32				rate_factor;
+	u32				rate;
 };
 
 struct cpdma_control_info {
@@ -135,6 +140,7 @@ struct cpdma_control_info {
 };
 
 static struct cpdma_control_info controls[] = {
+	[CPDMA_TX_RLIM]		  = {CPDMA_DMACONTROL,	8,  0xffff, ACCESS_RW},
 	[CPDMA_CMD_IDLE]	  = {CPDMA_DMACONTROL,	3,  1,      ACCESS_WO},
 	[CPDMA_COPY_ERROR_FRAMES] = {CPDMA_DMACONTROL,	4,  1,      ACCESS_RW},
 	[CPDMA_RX_OFF_LEN_UPDATE] = {CPDMA_DMACONTROL,	2,  1,      ACCESS_RW},
@@ -302,6 +308,186 @@ static int _cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
 	return 0;
 }
 
+static int _cpdma_control_get(struct cpdma_ctlr *ctlr, int control)
+{
+	struct cpdma_control_info *info = &controls[control];
+	int ret;
+
+	if (!ctlr->params.has_ext_regs)
+		return -ENOTSUPP;
+
+	if (ctlr->state != CPDMA_STATE_ACTIVE)
+		return -EINVAL;
+
+	if (control < 0 || control >= ARRAY_SIZE(controls))
+		return -ENOENT;
+
+	if ((info->access & ACCESS_RO) != ACCESS_RO)
+		return -EPERM;
+
+	ret = (dma_reg_read(ctlr, info->reg) >> info->shift) & info->mask;
+	return ret;
+}
+
+/* cpdma_chan_set_chan_shaper - set shaper for a channel
+ * Has to be called under ctlr lock
+ */
+static int cpdma_chan_set_chan_shaper(struct cpdma_chan *chan)
+{
+	struct cpdma_ctlr *ctlr = chan->ctlr;
+	u32 rate_reg;
+	u32 rmask;
+	int ret;
+
+	if (!chan->rate)
+		return 0;
+
+	rate_reg = CPDMA_TX_PRI0_RATE + 4 * chan->chan_num;
+	dma_reg_write(ctlr, rate_reg, chan->rate_factor);
+
+	rmask = _cpdma_control_get(ctlr, CPDMA_TX_RLIM);
+	rmask |= chan->mask;
+
+	ret = _cpdma_control_set(ctlr, CPDMA_TX_RLIM, rmask);
+	return ret;
+}
+
+static int cpdma_chan_on(struct cpdma_chan *chan)
+{
+	struct cpdma_ctlr *ctlr = chan->ctlr;
+	struct cpdma_desc_pool	*pool = ctlr->pool;
+	unsigned long flags;
+
+	spin_lock_irqsave(&chan->lock, flags);
+	if (chan->state != CPDMA_STATE_IDLE) {
+		spin_unlock_irqrestore(&chan->lock, flags);
+		return -EBUSY;
+	}
+	if (ctlr->state != CPDMA_STATE_ACTIVE) {
+		spin_unlock_irqrestore(&chan->lock, flags);
+		return -EINVAL;
+	}
+	dma_reg_write(ctlr, chan->int_set, chan->mask);
+	chan->state = CPDMA_STATE_ACTIVE;
+	if (chan->head) {
+		chan_write(chan, hdp, desc_phys(pool, chan->head));
+		if (chan->rxfree)
+			chan_write(chan, rxfree, chan->count);
+	}
+
+	spin_unlock_irqrestore(&chan->lock, flags);
+	return 0;
+}
+
+/* cpdma_chan_fit_rate - set rate for a channel and check if it's possible.
+ * rmask - mask of rate limited channels
+ * Returns min rate in Kb/s
+ */
+static int cpdma_chan_fit_rate(struct cpdma_chan *ch, u32 rate,
+			       u32 *rmask, int *prio_mode)
+{
+	struct cpdma_ctlr *ctlr = ch->ctlr;
+	struct cpdma_chan *chan;
+	u32 old_rate = ch->rate;
+	u32 new_rmask = 0;
+	int rlim = 1;
+	int i;
+
+	*prio_mode = 0;
+	for (i = tx_chan_num(0); i < tx_chan_num(CPDMA_MAX_CHANNELS); i++) {
+		chan = ctlr->channels[i];
+		if (!chan) {
+			rlim = 0;
+			continue;
+		}
+
+		if (chan == ch)
+			chan->rate = rate;
+
+		if (chan->rate) {
+			if (rlim) {
+				new_rmask |= chan->mask;
+			} else {
+				ch->rate = old_rate;
+				dev_err(ctlr->dev, "Prev channel of %dch is not rate limited\n",
+					chan->chan_num);
+				return -EINVAL;
+			}
+		} else {
+			*prio_mode = 1;
+			rlim = 0;
+		}
+	}
+
+	*rmask = new_rmask;
+	return 0;
+}
+
+static u32 cpdma_chan_set_factors(struct cpdma_ctlr *ctlr,
+				  struct cpdma_chan *ch)
+{
+	u32 delta = UINT_MAX, prev_delta = UINT_MAX, best_delta = UINT_MAX;
+	u32 best_send_cnt = 0, best_idle_cnt = 0;
+	u32 new_rate, best_rate = 0, rate_reg;
+	u64 send_cnt, idle_cnt;
+	u32 min_send_cnt, freq;
+	u64 divident, divisor;
+
+	if (!ch->rate) {
+		ch->rate_factor = 0;
+		goto set_factor;
+	}
+
+	freq = ctlr->params.bus_freq_mhz * 1000 * 32;
+	if (!freq) {
+		dev_err(ctlr->dev, "The bus frequency is not set\n");
+		return -EINVAL;
+	}
+
+	min_send_cnt = freq - ch->rate;
+	send_cnt = DIV_ROUND_UP(min_send_cnt, ch->rate);
+	while (send_cnt <= CPDMA_MAX_RLIM_CNT) {
+		divident = ch->rate * send_cnt;
+		divisor = min_send_cnt;
+		idle_cnt = DIV_ROUND_CLOSEST_ULL(divident, divisor);
+
+		divident = freq * idle_cnt;
+		divisor = idle_cnt + send_cnt;
+		new_rate = DIV_ROUND_CLOSEST_ULL(divident, divisor);
+
+		delta = new_rate >= ch->rate ? new_rate - ch->rate : delta;
+		if (delta < best_delta) {
+			best_delta = delta;
+			best_send_cnt = send_cnt;
+			best_idle_cnt = idle_cnt;
+			best_rate = new_rate;
+
+			if (!delta)
+				break;
+		}
+
+		if (prev_delta >= delta) {
+			prev_delta = delta;
+			send_cnt++;
+			continue;
+		}
+
+		idle_cnt++;
+		divident = freq * idle_cnt;
+		send_cnt = DIV_ROUND_CLOSEST_ULL(divident, ch->rate);
+		send_cnt -= idle_cnt;
+		prev_delta = UINT_MAX;
+	}
+
+	ch->rate = best_rate;
+	ch->rate_factor = best_send_cnt | (best_idle_cnt << 16);
+
+set_factor:
+	rate_reg = CPDMA_TX_PRI0_RATE + 4 * ch->chan_num;
+	dma_reg_write(ctlr, rate_reg, ch->rate_factor);
+	return 0;
+}
+
 struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 {
 	struct cpdma_ctlr *ctlr;
@@ -332,8 +518,9 @@ EXPORT_SYMBOL_GPL(cpdma_ctlr_create);
 
 int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 {
+	struct cpdma_chan *chan;
 	unsigned long flags;
-	int i;
+	int i, prio_mode;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
 	if (ctlr->state != CPDMA_STATE_IDLE) {
@@ -369,12 +556,20 @@ int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 
 	ctlr->state = CPDMA_STATE_ACTIVE;
 
+	prio_mode = 0;
 	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
-		if (ctlr->channels[i])
-			cpdma_chan_start(ctlr->channels[i]);
+		chan = ctlr->channels[i];
+		if (chan) {
+			cpdma_chan_set_chan_shaper(chan);
+			cpdma_chan_on(chan);
+
+			/* off prio mode if all tx channels are rate limited */
+			if (is_tx_chan(chan) && !chan->rate)
+				prio_mode = 1;
+		}
 	}
 
-	_cpdma_control_set(ctlr, CPDMA_TX_PRIO_FIXED, 1);
+	_cpdma_control_set(ctlr, CPDMA_TX_PRIO_FIXED, prio_mode);
 	_cpdma_control_set(ctlr, CPDMA_RX_BUFFER_OFFSET, 0);
 
 	spin_unlock_irqrestore(&ctlr->lock, flags);
@@ -602,6 +797,75 @@ int cpdma_chan_set_weight(struct cpdma_chan *ch, int weight)
 	return ret;
 }
 
+/* cpdma_chan_get_min_rate - get minimum allowed rate for channel
+ * Should be called before cpdma_chan_set_rate.
+ * Returns min rate in Kb/s
+ */
+u32 cpdma_chan_get_min_rate(struct cpdma_ctlr *ctlr)
+{
+	unsigned int divident, divisor;
+
+	divident = ctlr->params.bus_freq_mhz * 32 * 1000;
+	divisor = 1 + CPDMA_MAX_RLIM_CNT;
+
+	return DIV_ROUND_UP(divident, divisor);
+}
+
+/* cpdma_chan_set_rate - limits bandwidth for transmit channel.
+ * The bandwidth * limited channels have to be in order beginning from lowest.
+ * ch - transmit channel the bandwidth is configured for
+ * rate - bandwidth in Kb/s, if 0 - then off shaper
+ */
+int cpdma_chan_set_rate(struct cpdma_chan *ch, u32 rate)
+{
+	struct cpdma_ctlr *ctlr = ch->ctlr;
+	unsigned long flags, ch_flags;
+	int ret, prio_mode;
+	u32 rmask;
+
+	if (!ch || !is_tx_chan(ch))
+		return -EINVAL;
+
+	if (ch->rate == rate)
+		return rate;
+
+	spin_lock_irqsave(&ctlr->lock, flags);
+	spin_lock_irqsave(&ch->lock, ch_flags);
+
+	ret = cpdma_chan_fit_rate(ch, rate, &rmask, &prio_mode);
+	if (ret)
+		goto err;
+
+	ret = cpdma_chan_set_factors(ctlr, ch);
+	if (ret)
+		goto err;
+
+	spin_unlock_irqrestore(&ch->lock, ch_flags);
+
+	/* on shapers */
+	_cpdma_control_set(ctlr, CPDMA_TX_RLIM, rmask);
+	_cpdma_control_set(ctlr, CPDMA_TX_PRIO_FIXED, prio_mode);
+	spin_unlock_irqrestore(&ctlr->lock, flags);
+	return ret;
+
+err:
+	spin_unlock_irqrestore(&ch->lock, ch_flags);
+	spin_unlock_irqrestore(&ctlr->lock, flags);
+	return ret;
+}
+
+u32 cpdma_chan_get_rate(struct cpdma_chan *ch)
+{
+	unsigned long flags;
+	u32 rate;
+
+	spin_lock_irqsave(&ch->lock, flags);
+	rate = ch->rate;
+	spin_unlock_irqrestore(&ch->lock, flags);
+
+	return rate;
+}
+
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler, int rx_type)
 {
@@ -629,6 +893,7 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 	chan->state	= CPDMA_STATE_IDLE;
 	chan->chan_num	= chan_num;
 	chan->handler	= handler;
+	chan->rate	= 0;
 	chan->desc_num = ctlr->pool->num_desc / 2;
 	chan->weight	= 0;
 
@@ -924,28 +1189,20 @@ EXPORT_SYMBOL_GPL(cpdma_chan_process);
 
 int cpdma_chan_start(struct cpdma_chan *chan)
 {
-	struct cpdma_ctlr	*ctlr = chan->ctlr;
-	struct cpdma_desc_pool	*pool = ctlr->pool;
-	unsigned long		flags;
+	struct cpdma_ctlr *ctlr = chan->ctlr;
+	unsigned long flags;
+	int ret;
 
-	spin_lock_irqsave(&chan->lock, flags);
-	if (chan->state != CPDMA_STATE_IDLE) {
-		spin_unlock_irqrestore(&chan->lock, flags);
-		return -EBUSY;
-	}
-	if (ctlr->state != CPDMA_STATE_ACTIVE) {
-		spin_unlock_irqrestore(&chan->lock, flags);
-		return -EINVAL;
-	}
-	dma_reg_write(ctlr, chan->int_set, chan->mask);
-	chan->state = CPDMA_STATE_ACTIVE;
-	if (chan->head) {
-		chan_write(chan, hdp, desc_phys(pool, chan->head));
-		if (chan->rxfree)
-			chan_write(chan, rxfree, chan->count);
-	}
+	spin_lock_irqsave(&ctlr->lock, flags);
+	ret = cpdma_chan_set_chan_shaper(chan);
+	spin_unlock_irqrestore(&ctlr->lock, flags);
+	if (ret)
+		return ret;
+
+	ret = cpdma_chan_on(chan);
+	if (ret)
+		return ret;
 
-	spin_unlock_irqrestore(&chan->lock, flags);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_start);
@@ -1033,31 +1290,12 @@ int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable)
 int cpdma_control_get(struct cpdma_ctlr *ctlr, int control)
 {
 	unsigned long flags;
-	struct cpdma_control_info *info = &controls[control];
 	int ret;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
-
-	ret = -ENOTSUPP;
-	if (!ctlr->params.has_ext_regs)
-		goto unlock_ret;
-
-	ret = -EINVAL;
-	if (ctlr->state != CPDMA_STATE_ACTIVE)
-		goto unlock_ret;
-
-	ret = -ENOENT;
-	if (control < 0 || control >= ARRAY_SIZE(controls))
-		goto unlock_ret;
-
-	ret = -EPERM;
-	if ((info->access & ACCESS_RO) != ACCESS_RO)
-		goto unlock_ret;
-
-	ret = (dma_reg_read(ctlr, info->reg) >> info->shift) & info->mask;
-
-unlock_ret:
+	ret = _cpdma_control_get(ctlr, control);
 	spin_unlock_irqrestore(&ctlr->lock, flags);
+
 	return ret;
 }
 
@@ -1069,6 +1307,7 @@ int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
 	spin_lock_irqsave(&ctlr->lock, flags);
 	ret = _cpdma_control_set(ctlr, control, value);
 	spin_unlock_irqrestore(&ctlr->lock, flags);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cpdma_control_set);
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 629020c..4a167db 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -36,6 +36,7 @@ struct cpdma_params {
 	u32			desc_hw_addr;
 	int			desc_mem_size;
 	int			desc_align;
+	u32			bus_freq_mhz;
 
 	/*
 	 * Some instances of embedded cpdma controllers have extra control and
@@ -91,8 +92,12 @@ u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr);
 u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr);
 bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
 int cpdma_chan_set_weight(struct cpdma_chan *ch, int weight);
+int cpdma_chan_set_rate(struct cpdma_chan *ch, u32 rate);
+u32 cpdma_chan_get_rate(struct cpdma_chan *ch);
+u32 cpdma_chan_get_min_rate(struct cpdma_ctlr *ctlr);
 
 enum cpdma_control {
+	CPDMA_TX_RLIM,			/* read-write */
 	CPDMA_CMD_IDLE,			/* write-only */
 	CPDMA_COPY_ERROR_FRAMES,	/* read-write */
 	CPDMA_RX_OFF_LEN_UPDATE,	/* read-write */
-- 
2.7.4
