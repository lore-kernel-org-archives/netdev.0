From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/5] net: ethernet: ti: davinci_cpdma: add weight function for channels
Date: Tue, 29 Nov 2016 17:00:47 +0200
Message-ID: <1480431651-6081-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The weight of a channel is needed to split descriptors between
channels. The weight can depend on maximum rate of channels, maximum
rate of an interface or other reasons. The channel weight is in
percentage and is independent for rx and tx channels.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 124 +++++++++++++++++++++++++++++---
 drivers/net/ethernet/ti/davinci_cpdma.h |   1 +
 2 files changed, 115 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 56708a7..87456a9 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -122,6 +122,7 @@ struct cpdma_chan {
 	struct cpdma_chan_stats		stats;
 	/* offsets into dmaregs */
 	int	int_set, int_clear, td;
+	int				weight;
 };
 
 struct cpdma_control_info {
@@ -474,29 +475,131 @@ u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr)
 }
 EXPORT_SYMBOL_GPL(cpdma_ctrl_txchs_state);
 
+static void cpdma_chan_set_descs(struct cpdma_ctlr *ctlr,
+				 int rx, int desc_num,
+				 int per_ch_desc)
+{
+	struct cpdma_chan *chan, *most_chan = NULL;
+	int desc_cnt = desc_num;
+	int most_dnum = 0;
+	int min, max, i;
+
+	if (!desc_num)
+		return;
+
+	if (rx) {
+		min = rx_chan_num(0);
+		max = rx_chan_num(CPDMA_MAX_CHANNELS);
+	} else {
+		min = tx_chan_num(0);
+		max = tx_chan_num(CPDMA_MAX_CHANNELS);
+	}
+
+	for (i = min; i < max; i++) {
+		chan = ctlr->channels[i];
+		if (!chan)
+			continue;
+
+		if (chan->weight)
+			chan->desc_num = (chan->weight * desc_num) / 100;
+		else
+			chan->desc_num = per_ch_desc;
+
+		desc_cnt -= chan->desc_num;
+
+		if (most_dnum < chan->desc_num) {
+			most_dnum = chan->desc_num;
+			most_chan = chan;
+		}
+	}
+	/* use remains */
+	most_chan->desc_num += desc_cnt;
+}
+
 /**
  * cpdma_chan_split_pool - Splits ctrl pool between all channels.
  * Has to be called under ctlr lock
  */
-static void cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
+static int cpdma_chan_split_pool(struct cpdma_ctlr *ctlr)
 {
+	int tx_per_ch_desc = 0, rx_per_ch_desc = 0;
 	struct cpdma_desc_pool *pool = ctlr->pool;
+	int free_rx_num = 0, free_tx_num = 0;
+	int rx_weight = 0, tx_weight = 0;
+	int tx_desc_num, rx_desc_num;
 	struct cpdma_chan *chan;
-	int ch_desc_num;
-	int i;
+	int i, tx_num = 0;
 
 	if (!ctlr->chan_num)
-		return;
-
-	/* calculate average size of pool slice */
-	ch_desc_num = pool->num_desc / ctlr->chan_num;
+		return 0;
 
-	/* split ctlr pool */
 	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
 		chan = ctlr->channels[i];
-		if (chan)
-			chan->desc_num = ch_desc_num;
+		if (!chan)
+			continue;
+
+		if (is_rx_chan(chan)) {
+			if (!chan->weight)
+				free_rx_num++;
+			rx_weight += chan->weight;
+		} else {
+			if (!chan->weight)
+				free_tx_num++;
+			tx_weight += chan->weight;
+			tx_num++;
+		}
+	}
+
+	if (rx_weight > 100 || tx_weight > 100)
+		return -EINVAL;
+
+	tx_desc_num = (tx_num * pool->num_desc) / ctlr->chan_num;
+	rx_desc_num = pool->num_desc - tx_desc_num;
+
+	if (free_tx_num) {
+		tx_per_ch_desc = tx_desc_num - (tx_weight * tx_desc_num) / 100;
+		tx_per_ch_desc /= free_tx_num;
+	}
+	if (free_rx_num) {
+		rx_per_ch_desc = rx_desc_num - (rx_weight * rx_desc_num) / 100;
+		rx_per_ch_desc /= free_rx_num;
 	}
+
+	cpdma_chan_set_descs(ctlr, 0, tx_desc_num, tx_per_ch_desc);
+	cpdma_chan_set_descs(ctlr, 1, rx_desc_num, rx_per_ch_desc);
+
+	return 0;
+}
+
+/* cpdma_chan_set_weight - set weight of a channel in percentage.
+ * Tx and Rx channels have separate weights. That is 100% for RX
+ * and 100% for Tx. The weight is used to split cpdma resources
+ * in correct proportion required by the channels, including number
+ * of descriptors. The channel rate is not enough to know the
+ * weight of a channel as the maximum rate of an interface is needed.
+ * If weight = 0, then channel uses rest of descriptors leaved by
+ * weighted channels.
+ */
+int cpdma_chan_set_weight(struct cpdma_chan *ch, int weight)
+{
+	struct cpdma_ctlr *ctlr = ch->ctlr;
+	unsigned long flags, ch_flags;
+	int ret;
+
+	spin_lock_irqsave(&ctlr->lock, flags);
+	spin_lock_irqsave(&ch->lock, ch_flags);
+	if (ch->weight == weight) {
+		spin_unlock_irqrestore(&ch->lock, ch_flags);
+		spin_unlock_irqrestore(&ctlr->lock, flags);
+		return 0;
+	}
+	ch->weight = weight;
+	spin_unlock_irqrestore(&ch->lock, ch_flags);
+
+	/* re-split pool using new channel weight */
+	ret = cpdma_chan_split_pool(ctlr);
+	spin_unlock_irqrestore(&ctlr->lock, flags);
+	return ret;
 }
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
@@ -527,6 +630,7 @@ struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 	chan->chan_num	= chan_num;
 	chan->handler	= handler;
 	chan->desc_num = ctlr->pool->num_desc / 2;
+	chan->weight	= 0;
 
 	if (is_rx_chan(chan)) {
 		chan->hdp	= ctlr->params.rxhdp + offset;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index a07b22b..629020c 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -90,6 +90,7 @@ int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
 u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr);
 u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr);
 bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
+int cpdma_chan_set_weight(struct cpdma_chan *ch, int weight);
 
 enum cpdma_control {
 	CPDMA_CMD_IDLE,			/* write-only */
-- 
2.7.4
