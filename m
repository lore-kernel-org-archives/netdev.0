From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 5/5] net: ethernet: ti: cpsw: split tx budget according between channels
Date: Tue, 29 Nov 2016 17:00:51 +0200
Message-ID: <1480431651-6081-6-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split device budget between channels according to channel rate.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 159 +++++++++++++++++++++++++++++++++--------
 1 file changed, 130 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8a70298..ec4873f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -365,6 +365,11 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
 	__raw_writel(val, slave->regs + offset);
 }
 
+struct cpsw_vector {
+	struct cpdma_chan *ch;
+	int budget;
+};
+
 struct cpsw_common {
 	struct device			*dev;
 	struct cpsw_platform_data	data;
@@ -380,8 +385,8 @@ struct cpsw_common {
 	int				rx_packet_max;
 	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
-	struct cpdma_chan		*txch[CPSW_MAX_QUEUES];
-	struct cpdma_chan		*rxch[CPSW_MAX_QUEUES];
+	struct cpsw_vector		txv[CPSW_MAX_QUEUES];
+	struct cpsw_vector		rxv[CPSW_MAX_QUEUES];
 	struct cpsw_ale			*ale;
 	bool				quirk_irq;
 	bool				rx_irq_disabled;
@@ -741,7 +746,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 		return;
 	}
 
-	ch = cpsw->rxch[skb_get_queue_mapping(new_skb)];
+	ch = cpsw->rxv[skb_get_queue_mapping(new_skb)].ch;
 	ret = cpdma_chan_submit(ch, new_skb, new_skb->data,
 				skb_tailroom(new_skb), 0);
 	if (WARN_ON(ret < 0))
@@ -783,8 +788,9 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 {
 	u32			ch_map;
-	int			num_tx, ch;
+	int			num_tx, cur_budget, ch;
 	struct cpsw_common	*cpsw = napi_to_cpsw(napi_tx);
+	struct cpsw_vector	*txv;
 
 	/* process every unprocessed channel */
 	ch_map = cpdma_ctrl_txchs_state(cpsw->dma);
@@ -792,7 +798,13 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 		if (!(ch_map & 0x01))
 			continue;
 
-		num_tx += cpdma_chan_process(cpsw->txch[ch], budget - num_tx);
+		txv = &cpsw->txv[ch];
+		if (unlikely(txv->budget > budget - num_tx))
+			cur_budget = budget - num_tx;
+		else
+			cur_budget = txv->budget;
+
+		num_tx += cpdma_chan_process(txv->ch, cur_budget);
 		if (num_tx >= budget)
 			break;
 	}
@@ -812,8 +824,9 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 {
 	u32			ch_map;
-	int			num_rx, ch;
+	int			num_rx, cur_budget, ch;
 	struct cpsw_common	*cpsw = napi_to_cpsw(napi_rx);
+	struct cpsw_vector	*rxv;
 
 	/* process every unprocessed channel */
 	ch_map = cpdma_ctrl_rxchs_state(cpsw->dma);
@@ -821,7 +834,13 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 		if (!(ch_map & 0x01))
 			continue;
 
-		num_rx += cpdma_chan_process(cpsw->rxch[ch], budget - num_rx);
+		rxv = &cpsw->rxv[ch];
+		if (unlikely(rxv->budget > budget - num_rx))
+			cur_budget = budget - num_rx;
+		else
+			cur_budget = rxv->budget;
+
+		num_rx += cpdma_chan_process(rxv->ch, cur_budget);
 		if (num_rx >= budget)
 			break;
 	}
@@ -1063,7 +1082,7 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 				cpsw_gstrings_stats[l].stat_offset);
 
 	for (ch = 0; ch < cpsw->rx_ch_num; ch++) {
-		cpdma_chan_get_stats(cpsw->rxch[ch], &ch_stats);
+		cpdma_chan_get_stats(cpsw->rxv[ch].ch, &ch_stats);
 		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
 			p = (u8 *)&ch_stats +
 				cpsw_gstrings_ch_stats[i].stat_offset;
@@ -1072,7 +1091,7 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	}
 
 	for (ch = 0; ch < cpsw->tx_ch_num; ch++) {
-		cpdma_chan_get_stats(cpsw->txch[ch], &ch_stats);
+		cpdma_chan_get_stats(cpsw->txv[ch].ch, &ch_stats);
 		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
 			p = (u8 *)&ch_stats +
 				cpsw_gstrings_ch_stats[i].stat_offset;
@@ -1261,6 +1280,82 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	}
 }
 
+/* split budget depending on channel rates */
+static void cpsw_split_budget(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_vector *txv = cpsw->txv;
+	u32 consumed_rate, bigest_rate = 0;
+	int budget, bigest_rate_ch = 0;
+	struct cpsw_slave *slave;
+	int i, rlim_ch_num = 0;
+	u32 ch_rate, max_rate;
+	int ch_budget = 0;
+
+	if (cpsw->data.dual_emac)
+		slave = &cpsw->slaves[priv->emac_port];
+	else
+		slave = &cpsw->slaves[cpsw->data.active_slave];
+
+	max_rate = slave->phy->speed * 1000;
+
+	consumed_rate = 0;
+	for (i = 0; i < cpsw->tx_ch_num; i++) {
+		ch_rate = cpdma_chan_get_rate(txv[i].ch);
+		if (!ch_rate)
+			continue;
+
+		rlim_ch_num++;
+		consumed_rate += ch_rate;
+	}
+
+	if (cpsw->tx_ch_num == rlim_ch_num) {
+		max_rate = consumed_rate;
+	} else {
+		ch_budget = (consumed_rate * CPSW_POLL_WEIGHT) / max_rate;
+		ch_budget = (CPSW_POLL_WEIGHT - ch_budget) /
+			    (cpsw->tx_ch_num - rlim_ch_num);
+		bigest_rate = (max_rate - consumed_rate) /
+			      (cpsw->tx_ch_num - rlim_ch_num);
+	}
+
+	/* split tx budget */
+	budget = CPSW_POLL_WEIGHT;
+	for (i = 0; i < cpsw->tx_ch_num; i++) {
+		ch_rate = cpdma_chan_get_rate(txv[i].ch);
+		if (ch_rate) {
+			txv[i].budget = (ch_rate * CPSW_POLL_WEIGHT) / max_rate;
+			if (!txv[i].budget)
+				txv[i].budget = 1;
+			if (ch_rate > bigest_rate) {
+				bigest_rate_ch = i;
+				bigest_rate = ch_rate;
+			}
+		} else {
+			txv[i].budget = ch_budget;
+			if (!bigest_rate_ch)
+				bigest_rate_ch = i;
+		}
+
+		budget -= txv[i].budget;
+	}
+
+	if (budget)
+		txv[bigest_rate_ch].budget += budget;
+
+	/* split rx budget */
+	budget = CPSW_POLL_WEIGHT;
+	ch_budget = budget / cpsw->rx_ch_num;
+	for (i = 0; i < cpsw->rx_ch_num; i++) {
+		cpsw->rxv[i].budget = ch_budget;
+		budget -= ch_budget;
+	}
+
+	if (budget)
+		cpsw->rxv[0].budget += budget;
+}
+
 static int cpsw_fill_rx_channels(struct cpsw_priv *priv)
 {
 	struct cpsw_common *cpsw = priv->cpsw;
@@ -1269,7 +1364,7 @@ static int cpsw_fill_rx_channels(struct cpsw_priv *priv)
 	int ch, i, ret;
 
 	for (ch = 0; ch < cpsw->rx_ch_num; ch++) {
-		ch_buf_num = cpdma_chan_get_rx_buf_num(cpsw->rxch[ch]);
+		ch_buf_num = cpdma_chan_get_rx_buf_num(cpsw->rxv[ch].ch);
 		for (i = 0; i < ch_buf_num; i++) {
 			skb = __netdev_alloc_skb_ip_align(priv->ndev,
 							  cpsw->rx_packet_max,
@@ -1280,8 +1375,9 @@ static int cpsw_fill_rx_channels(struct cpsw_priv *priv)
 			}
 
 			skb_set_queue_mapping(skb, ch);
-			ret = cpdma_chan_submit(cpsw->rxch[ch], skb, skb->data,
-						skb_tailroom(skb), 0);
+			ret = cpdma_chan_submit(cpsw->rxv[ch].ch, skb,
+						skb->data, skb_tailroom(skb),
+						0);
 			if (ret < 0) {
 				cpsw_err(priv, ifup,
 					 "cannot submit skb to channel %d rx, error %d\n",
@@ -1405,6 +1501,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
+	cpsw_split_budget(ndev);
 	cpdma_ctlr_start(cpsw->dma);
 	cpsw_intr_enable(cpsw);
 
@@ -1474,7 +1571,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	if (q_idx >= cpsw->tx_ch_num)
 		q_idx = q_idx % cpsw->tx_ch_num;
 
-	txch = cpsw->txch[q_idx];
+	txch = cpsw->txv[q_idx].ch;
 	ret = cpsw_tx_packet_submit(priv, skb, txch);
 	if (unlikely(ret != 0)) {
 		cpsw_err(priv, tx_err, "desc submit failed\n");
@@ -1681,8 +1778,8 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 	ndev->stats.tx_errors++;
 	cpsw_intr_disable(cpsw);
 	for (ch = 0; ch < cpsw->tx_ch_num; ch++) {
-		cpdma_chan_stop(cpsw->txch[ch]);
-		cpdma_chan_start(cpsw->txch[ch]);
+		cpdma_chan_stop(cpsw->txv[ch].ch);
+		cpdma_chan_start(cpsw->txv[ch].ch);
 	}
 
 	cpsw_intr_enable(cpsw);
@@ -1887,7 +1984,6 @@ static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
 			ch_rate = rate;
 		else
 			ch_rate = netdev_get_tx_queue(ndev, i)->tx_maxrate;
-
 		if (!ch_rate)
 			continue;
 
@@ -1935,9 +2031,12 @@ static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
 		max_rate = consumed_rate;
 
 	weight = (rate * 100) / (max_rate * 1000);
-	cpdma_chan_set_weight(cpsw->txch[queue], weight);
+	cpdma_chan_set_weight(cpsw->txv[queue].ch, weight);
+	ret = cpdma_chan_set_rate(cpsw->txv[queue].ch, rate);
 
-	ret = cpdma_chan_set_rate(cpsw->txch[queue], rate);
+	/* re-split budget between channels */
+	if (!rate)
+		cpsw_split_budget(ndev);
 	pm_runtime_put(cpsw->dev);
 	return ret;
 }
@@ -2172,30 +2271,30 @@ static int cpsw_update_channels_res(struct cpsw_priv *priv, int ch_num, int rx)
 	struct cpsw_common *cpsw = priv->cpsw;
 	void (*handler)(void *, int, int);
 	struct netdev_queue *queue;
-	struct cpdma_chan **chan;
+	struct cpsw_vector *vec;
 	int ret, *ch;
 
 	if (rx) {
 		ch = &cpsw->rx_ch_num;
-		chan = cpsw->rxch;
+		vec = cpsw->rxv;
 		handler = cpsw_rx_handler;
 		poll = cpsw_rx_poll;
 	} else {
 		ch = &cpsw->tx_ch_num;
-		chan = cpsw->txch;
+		vec = cpsw->txv;
 		handler = cpsw_tx_handler;
 		poll = cpsw_tx_poll;
 	}
 
 	while (*ch < ch_num) {
-		chan[*ch] = cpdma_chan_create(cpsw->dma, *ch, handler, rx);
+		vec[*ch].ch = cpdma_chan_create(cpsw->dma, *ch, handler, rx);
 		queue = netdev_get_tx_queue(priv->ndev, *ch);
 		queue->tx_maxrate = 0;
 
-		if (IS_ERR(chan[*ch]))
-			return PTR_ERR(chan[*ch]);
+		if (IS_ERR(vec[*ch].ch))
+			return PTR_ERR(vec[*ch].ch);
 
-		if (!chan[*ch])
+		if (!vec[*ch].ch)
 			return -EINVAL;
 
 		cpsw_info(priv, ifup, "created new %d %s channel\n", *ch,
@@ -2206,7 +2305,7 @@ static int cpsw_update_channels_res(struct cpsw_priv *priv, int ch_num, int rx)
 	while (*ch > ch_num) {
 		(*ch)--;
 
-		ret = cpdma_chan_destroy(chan[*ch]);
+		ret = cpdma_chan_destroy(vec[*ch].ch);
 		if (ret)
 			return ret;
 
@@ -2293,6 +2392,8 @@ static int cpsw_set_channels(struct net_device *ndev,
 		if (ret)
 			goto err;
 
+		cpsw_split_budget(ndev);
+
 		/* After this receive is started */
 		cpdma_ctlr_start(cpsw->dma);
 		cpsw_intr_enable(cpsw);
@@ -2835,9 +2936,9 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_dt_ret;
 	}
 
-	cpsw->txch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_tx_handler, 0);
-	cpsw->rxch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_rx_handler, 1);
-	if (WARN_ON(!cpsw->rxch[0] || !cpsw->txch[0])) {
+	cpsw->txv[0].ch = cpdma_chan_create(cpsw->dma, 0, cpsw_tx_handler, 0);
+	cpsw->rxv[0].ch = cpdma_chan_create(cpsw->dma, 0, cpsw_rx_handler, 1);
+	if (WARN_ON(!cpsw->rxv[0].ch || !cpsw->txv[0].ch)) {
 		dev_err(priv->dev, "error initializing dma channels\n");
 		ret = -ENOMEM;
 		goto clean_dma_ret;
-- 
2.7.4
