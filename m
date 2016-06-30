From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 2/4] net: ethernet: ti: cpsw: add multi queue support
Date: Thu, 30 Jun 2016 22:04:36 +0300
Message-ID: <1467313478-22919-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, nsekhar@ti.com,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:36505 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbcF3TEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 15:04:51 -0400
Received: by mail-lf0-f42.google.com with SMTP id q132so62141861lfe.3
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 12:04:50 -0700 (PDT)
In-Reply-To: <1467313478-22919-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cpsw h/w supports up to 8 tx and 8 rx channels.This patch adds
multi-queue support to the driver. An ability to configure h/w
shaper will be added with separate patch. Default shaper mode, as
before, priority mode.

The poll function handles all unprocessed channels, till all of
them are free, beginning from hi priority channel.

The statistic for every channel can be read with:
ethtool -S ethX

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          | 334 +++++++++++++++++++++-----------
 drivers/net/ethernet/ti/davinci_cpdma.c |  12 ++
 drivers/net/ethernet/ti/davinci_cpdma.h |   2 +
 3 files changed, 237 insertions(+), 111 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a713336..14d53eb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -140,6 +140,8 @@ do {								\
 #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
 #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
 
+#define CPSW_MAX_QUEUES		8
+
 #define cpsw_slave_index(priv)				\
 		((priv->data.dual_emac) ? priv->emac_port :	\
 		priv->data.active_slave)
@@ -383,7 +385,8 @@ struct cpsw_priv {
 	u8				mac_addr[ETH_ALEN];
 	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
-	struct cpdma_chan		*txch, *rxch;
+	struct cpdma_chan		*txch[CPSW_MAX_QUEUES];
+	struct cpdma_chan		*rxch[CPSW_MAX_QUEUES];
 	struct cpsw_ale			*ale;
 	bool				rx_pause;
 	bool				tx_pause;
@@ -395,6 +398,7 @@ struct cpsw_priv {
 	u32 num_irqs;
 	struct cpts *cpts;
 	u32 emac_port;
+	int rx_ch_num, tx_ch_num;
 };
 
 struct cpsw_stats {
@@ -455,35 +459,26 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 	{ "Rx Start of Frame Overruns", CPSW_STAT(rxsofoverruns) },
 	{ "Rx Middle of Frame Overruns", CPSW_STAT(rxmofoverruns) },
 	{ "Rx DMA Overruns", CPSW_STAT(rxdmaoverruns) },
-	{ "Rx DMA chan: head_enqueue", CPDMA_RX_STAT(head_enqueue) },
-	{ "Rx DMA chan: tail_enqueue", CPDMA_RX_STAT(tail_enqueue) },
-	{ "Rx DMA chan: pad_enqueue", CPDMA_RX_STAT(pad_enqueue) },
-	{ "Rx DMA chan: misqueued", CPDMA_RX_STAT(misqueued) },
-	{ "Rx DMA chan: desc_alloc_fail", CPDMA_RX_STAT(desc_alloc_fail) },
-	{ "Rx DMA chan: pad_alloc_fail", CPDMA_RX_STAT(pad_alloc_fail) },
-	{ "Rx DMA chan: runt_receive_buf", CPDMA_RX_STAT(runt_receive_buff) },
-	{ "Rx DMA chan: runt_transmit_buf", CPDMA_RX_STAT(runt_transmit_buff) },
-	{ "Rx DMA chan: empty_dequeue", CPDMA_RX_STAT(empty_dequeue) },
-	{ "Rx DMA chan: busy_dequeue", CPDMA_RX_STAT(busy_dequeue) },
-	{ "Rx DMA chan: good_dequeue", CPDMA_RX_STAT(good_dequeue) },
-	{ "Rx DMA chan: requeue", CPDMA_RX_STAT(requeue) },
-	{ "Rx DMA chan: teardown_dequeue", CPDMA_RX_STAT(teardown_dequeue) },
-	{ "Tx DMA chan: head_enqueue", CPDMA_TX_STAT(head_enqueue) },
-	{ "Tx DMA chan: tail_enqueue", CPDMA_TX_STAT(tail_enqueue) },
-	{ "Tx DMA chan: pad_enqueue", CPDMA_TX_STAT(pad_enqueue) },
-	{ "Tx DMA chan: misqueued", CPDMA_TX_STAT(misqueued) },
-	{ "Tx DMA chan: desc_alloc_fail", CPDMA_TX_STAT(desc_alloc_fail) },
-	{ "Tx DMA chan: pad_alloc_fail", CPDMA_TX_STAT(pad_alloc_fail) },
-	{ "Tx DMA chan: runt_receive_buf", CPDMA_TX_STAT(runt_receive_buff) },
-	{ "Tx DMA chan: runt_transmit_buf", CPDMA_TX_STAT(runt_transmit_buff) },
-	{ "Tx DMA chan: empty_dequeue", CPDMA_TX_STAT(empty_dequeue) },
-	{ "Tx DMA chan: busy_dequeue", CPDMA_TX_STAT(busy_dequeue) },
-	{ "Tx DMA chan: good_dequeue", CPDMA_TX_STAT(good_dequeue) },
-	{ "Tx DMA chan: requeue", CPDMA_TX_STAT(requeue) },
-	{ "Tx DMA chan: teardown_dequeue", CPDMA_TX_STAT(teardown_dequeue) },
 };
 
-#define CPSW_STATS_LEN	ARRAY_SIZE(cpsw_gstrings_stats)
+static const struct cpsw_stats cpsw_gstrings_ch_stats[] = {
+	{ "head_enqueue", CPDMA_RX_STAT(head_enqueue) },
+	{ "tail_enqueue", CPDMA_RX_STAT(tail_enqueue) },
+	{ "pad_enqueue", CPDMA_RX_STAT(pad_enqueue) },
+	{ "misqueued", CPDMA_RX_STAT(misqueued) },
+	{ "desc_alloc_fail", CPDMA_RX_STAT(desc_alloc_fail) },
+	{ "pad_alloc_fail", CPDMA_RX_STAT(pad_alloc_fail) },
+	{ "runt_receive_buf", CPDMA_RX_STAT(runt_receive_buff) },
+	{ "runt_transmit_buf", CPDMA_RX_STAT(runt_transmit_buff) },
+	{ "empty_dequeue", CPDMA_RX_STAT(empty_dequeue) },
+	{ "busy_dequeue", CPDMA_RX_STAT(busy_dequeue) },
+	{ "good_dequeue", CPDMA_RX_STAT(good_dequeue) },
+	{ "requeue", CPDMA_RX_STAT(requeue) },
+	{ "teardown_dequeue", CPDMA_RX_STAT(teardown_dequeue) },
+};
+
+#define CPSW_STATS_COMMON_LEN	ARRAY_SIZE(cpsw_gstrings_stats)
+#define CPSW_STATS_CH_LEN	ARRAY_SIZE(cpsw_gstrings_ch_stats)
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
 #define for_each_slave(priv, func, arg...)				\
@@ -676,12 +671,15 @@ static void cpsw_tx_handler(void *token, int len, int status)
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
 	struct cpsw_priv	*priv = netdev_priv(ndev);
+	struct netdev_queue	*txq;
 
 	/* Check whether the queue is stopped due to stalled tx dma, if the
 	 * queue is stopped then start the queue as we have free desc for tx
 	 */
-	if (unlikely(netif_queue_stopped(ndev)))
-		netif_wake_queue(ndev);
+	txq = netdev_get_tx_queue(ndev, skb_get_queue_mapping(skb));
+	if (unlikely(netif_tx_queue_stopped(txq)))
+		netif_tx_wake_queue(txq);
+
 	cpts_tx_timestamp(priv->cpts, skb);
 	ndev->stats.tx_packets++;
 	ndev->stats.tx_bytes += len;
@@ -695,6 +693,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	struct net_device	*ndev = skb->dev;
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 	int			ret = 0;
+	struct cpdma_chan	*ch;
 
 	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
 
@@ -728,6 +727,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 
 	new_skb = netdev_alloc_skb_ip_align(ndev, priv->rx_packet_max);
 	if (new_skb) {
+		skb_copy_queue_mapping(new_skb, skb);
 		skb_put(skb, len);
 		cpts_rx_timestamp(priv->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
@@ -740,8 +740,9 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	}
 
 requeue:
-	ret = cpdma_chan_submit(priv->rxch, new_skb, new_skb->data,
-			skb_tailroom(new_skb), 0);
+	ch = priv->rxch[skb_get_queue_mapping(new_skb)];
+	ret = cpdma_chan_submit(ch, new_skb, new_skb->data,
+				skb_tailroom(new_skb), 0);
 	if (WARN_ON(ret < 0))
 		dev_kfree_skb_any(new_skb);
 }
@@ -781,9 +782,26 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 {
 	struct cpsw_priv	*priv = napi_to_priv(napi_tx);
-	int			num_tx;
+	int			num_tx, ch;
+	u32			ch_map;
+
+	/* process every unprocessed channel */
+	ch_map = cpdma_ctrl_txchs_state(priv->dma);
+	for (ch = 0, num_tx = 0; num_tx < budget; ch_map >>= 1, ch++) {
+		if (!ch_map) {
+			ch_map = cpdma_ctrl_txchs_state(priv->dma);
+			if (!ch_map)
+				break;
+
+			ch = 0;
+		}
+
+		if (!(ch_map & 0x01))
+			continue;
+
+		num_tx += cpdma_chan_process(priv->txch[ch], budget - num_tx);
+	}
 
-	num_tx = cpdma_chan_process(priv->txch, budget);
 	if (num_tx < budget) {
 		napi_complete(napi_tx);
 		writel(0xff, &priv->wr_regs->tx_en);
@@ -802,9 +820,26 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 {
 	struct cpsw_priv	*priv = napi_to_priv(napi_rx);
-	int			num_rx;
+	int			num_rx, ch;
+	u32			ch_map;
+
+	/* process every unprocessed channel */
+	ch_map = cpdma_ctrl_rxchs_state(priv->dma);
+	for (ch = 0, num_rx = 0; num_rx < budget; ch_map >>= 1, ch++) {
+		if (!ch_map) {
+			ch_map = cpdma_ctrl_rxchs_state(priv->dma);
+			if (!ch_map)
+				break;
+
+			ch = 0;
+		}
+
+		if (!(ch_map & 0x01))
+			continue;
+
+		num_rx += cpdma_chan_process(priv->rxch[ch], budget - num_rx);
+	}
 
-	num_rx = cpdma_chan_process(priv->rxch, budget);
 	if (num_rx < budget) {
 		napi_complete(napi_rx);
 		writel(0xff, &priv->wr_regs->rx_en);
@@ -905,10 +940,10 @@ static void cpsw_adjust_link(struct net_device *ndev)
 	if (link) {
 		netif_carrier_on(ndev);
 		if (netif_running(ndev))
-			netif_wake_queue(ndev);
+			netif_tx_wake_all_queues(ndev);
 	} else {
 		netif_carrier_off(ndev);
-		netif_stop_queue(ndev);
+		netif_tx_stop_all_queues(ndev);
 	}
 }
 
@@ -989,26 +1024,50 @@ update_return:
 
 static int cpsw_get_sset_count(struct net_device *ndev, int sset)
 {
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
 	switch (sset) {
 	case ETH_SS_STATS:
-		return CPSW_STATS_LEN;
+		return (CPSW_STATS_COMMON_LEN +
+		       (priv->rx_ch_num + priv->tx_ch_num) *
+		       CPSW_STATS_CH_LEN);
 	default:
 		return -EOPNOTSUPP;
 	}
 }
 
+static void cpsw_add_ch_strings(u8 **p, int ch_num, int rx_dir)
+{
+	int ch_stats_len;
+	int line;
+	int i;
+
+	ch_stats_len = CPSW_STATS_CH_LEN * ch_num;
+	for (i = 0; i < ch_stats_len; i++) {
+		line = i % CPSW_STATS_CH_LEN;
+		sprintf(*p, "%s DMA chan %d: %s", rx_dir ? "Rx" : "Tx",
+			i / CPSW_STATS_CH_LEN,
+			cpsw_gstrings_ch_stats[line].stat_string);
+		*p += ETH_GSTRING_LEN;
+	}
+}
+
 static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 {
+	struct cpsw_priv *priv = netdev_priv(ndev);
 	u8 *p = data;
 	int i;
 
 	switch (stringset) {
 	case ETH_SS_STATS:
-		for (i = 0; i < CPSW_STATS_LEN; i++) {
+		for (i = 0; i < CPSW_STATS_COMMON_LEN; i++) {
 			memcpy(p, cpsw_gstrings_stats[i].stat_string,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
+
+		cpsw_add_ch_strings(&p, priv->rx_ch_num, 1);
+		cpsw_add_ch_strings(&p, priv->tx_ch_num, 0);
 		break;
 	}
 }
@@ -1017,35 +1076,38 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 				    struct ethtool_stats *stats, u64 *data)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	struct cpdma_chan_stats rx_stats;
-	struct cpdma_chan_stats tx_stats;
-	u32 val;
+	struct cpdma_chan_stats ch_stats;
+	int i, l, ch, ret;
 	u8 *p;
-	int i;
+
+	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&priv->pdev->dev);
+		return;
+	}
 
 	/* Collect Davinci CPDMA stats for Rx and Tx Channel */
-	cpdma_chan_get_stats(priv->rxch, &rx_stats);
-	cpdma_chan_get_stats(priv->txch, &tx_stats);
-
-	for (i = 0; i < CPSW_STATS_LEN; i++) {
-		switch (cpsw_gstrings_stats[i].type) {
-		case CPSW_STATS:
-			val = readl(priv->hw_stats +
-				    cpsw_gstrings_stats[i].stat_offset);
-			data[i] = val;
-			break;
+	for (l = 0; l < CPSW_STATS_COMMON_LEN; l++)
+		data[l] = readl(priv->hw_stats +
+				cpsw_gstrings_stats[l].stat_offset);
 
-		case CPDMA_RX_STATS:
-			p = (u8 *)&rx_stats +
-				cpsw_gstrings_stats[i].stat_offset;
-			data[i] = *(u32 *)p;
-			break;
+	pm_runtime_put(&priv->pdev->dev);
 
-		case CPDMA_TX_STATS:
-			p = (u8 *)&tx_stats +
-				cpsw_gstrings_stats[i].stat_offset;
-			data[i] = *(u32 *)p;
-			break;
+	for (ch = 0; ch < priv->rx_ch_num; ch++) {
+		cpdma_chan_get_stats(priv->rxch[ch], &ch_stats);
+		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
+			p = (u8 *)&ch_stats +
+				cpsw_gstrings_ch_stats[i].stat_offset;
+			data[l] = *(u32 *)p;
+		}
+	}
+
+	for (ch = 0; ch < priv->tx_ch_num; ch++) {
+		cpdma_chan_get_stats(priv->txch[ch], &ch_stats);
+		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
+			p = (u8 *)&ch_stats +
+				cpsw_gstrings_ch_stats[i].stat_offset;
+			data[l] = *(u32 *)p;
 		}
 	}
 }
@@ -1065,19 +1127,29 @@ static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
 	return usage_count;
 }
 
+static inline struct cpdma_chan *
+cpsw_tx_queue_mapping(struct cpsw_priv *priv, struct sk_buff *skb)
+{
+	unsigned int q_idx = skb_get_queue_mapping(skb);
+
+	if (q_idx >= priv->tx_ch_num)
+		q_idx = q_idx % priv->tx_ch_num;
+
+	return priv->txch[q_idx];
+}
+
 static inline int cpsw_tx_packet_submit(struct net_device *ndev,
-			struct cpsw_priv *priv, struct sk_buff *skb)
+					struct cpsw_priv *priv,
+					struct sk_buff *skb,
+					struct cpdma_chan *txch)
 {
 	if (!priv->data.dual_emac)
-		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 0);
+		return cpdma_chan_submit(txch, skb, skb->data, skb->len, 0);
 
 	if (ndev == cpsw_get_slave_ndev(priv, 0))
-		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 1);
+		return cpdma_chan_submit(txch, skb, skb->data, skb->len, 1);
 	else
-		return cpdma_chan_submit(priv->txch, skb, skb->data,
-				  skb->len, 2);
+		return cpdma_chan_submit(txch, skb, skb->data, skb->len, 2);
 }
 
 static inline void cpsw_add_dual_emac_def_ale_entries(
@@ -1234,33 +1306,38 @@ static int cpsw_fill_rx_channels(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct sk_buff *skb;
-	int ch_buf_num;
-	int i, ret;
-
-	ch_buf_num = cpdma_chan_get_rx_buf_num(priv->rxch);
-	for (i = 0; i < ch_buf_num; i++) {
-		skb = __netdev_alloc_skb_ip_align(ndev,
-						  priv->rx_packet_max,
-						  GFP_KERNEL);
-		if (!skb) {
-			dev_err(priv->dev, "cannot allocate skb\n");
-			return -ENOMEM;
-		}
+	int ch, i, ret;
+
+	for (ch = 0; ch < priv->rx_ch_num; ch++) {
+		int ch_buf_num;
+
+		ch_buf_num = cpdma_chan_get_rx_buf_num(priv->rxch[ch]);
+		for (i = 0; i < ch_buf_num; i++) {
+			skb = __netdev_alloc_skb_ip_align(ndev,
+							  priv->rx_packet_max,
+							  GFP_KERNEL);
+			if (!skb) {
+				dev_err(priv->dev, "cannot allocate skb\n");
+				return -ENOMEM;
+			}
 
-		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), 0);
-		if (ret < 0) {
-			dev_err(priv->dev,
-				"cannot submit skb to rx channel, error %d\n",
-				ret);
-			kfree_skb(skb);
-			return ret;
+			skb_set_queue_mapping(skb, ch);
+			ret = cpdma_chan_submit(priv->rxch[ch], skb, skb->data,
+						skb_tailroom(skb), 0);
+			if (ret < 0) {
+				dev_err(priv->dev,
+					"cannot submit skb to channel %d rx, error %d\n",
+					ch, ret);
+				kfree_skb(skb);
+				return ret;
+			}
 		}
-	}
 
-	cpsw_info(priv, ifup, "submitted %d rx descriptors\n", ch_buf_num);
+		cpsw_info(priv, ifup, "ch %d rx, submitted %d descriptors\n",
+			  ch, ch_buf_num);
+	}
 
-	return ch_buf_num;
+	return 0;
 }
 
 static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
@@ -1295,6 +1372,19 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_intr_disable(priv);
 	netif_carrier_off(ndev);
 
+	/* Notify the stack of the actual queue counts. */
+	ret = netif_set_real_num_tx_queues(ndev, priv->tx_ch_num);
+	if (ret) {
+		dev_err(priv->dev, "cannot set real number of tx queues\n");
+		goto err_cleanup;
+	}
+
+	ret = netif_set_real_num_rx_queues(ndev, priv->rx_ch_num);
+	if (ret) {
+		dev_err(priv->dev, "cannot set real number of rx queues\n");
+		goto err_cleanup;
+	}
+
 	reg = priv->version;
 
 	dev_info(priv->dev, "initializing cpsw version %d.%d (%d)\n",
@@ -1366,6 +1456,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = true;
+
+	netif_tx_start_all_queues(ndev);
+
 	return 0;
 
 err_cleanup:
@@ -1381,7 +1474,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
-	netif_stop_queue(priv->ndev);
+	netif_tx_stop_all_queues(priv->ndev);
 	netif_carrier_off(priv->ndev);
 
 	if (cpsw_common_res_usage_state(priv) <= 1) {
@@ -1405,6 +1498,8 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 				       struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct netdev_queue *txq;
+	struct cpdma_chan *txch;
 	int ret;
 
 	netif_trans_update(ndev);
@@ -1421,7 +1516,8 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	ret = cpsw_tx_packet_submit(ndev, priv, skb);
+	txch = cpsw_tx_queue_mapping(priv, skb);
+	ret = cpsw_tx_packet_submit(ndev, priv, skb, txch);
 	if (unlikely(ret != 0)) {
 		cpsw_err(priv, tx_err, "desc submit failed\n");
 		goto fail;
@@ -1430,13 +1526,16 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	/* If there is no more tx desc left free then we need to
 	 * tell the kernel to stop sending us tx frames.
 	 */
-	if (unlikely(!cpdma_check_free_tx_desc(priv->txch)))
-		netif_stop_queue(ndev);
+	if (unlikely(!cpdma_check_free_tx_desc(txch))) {
+		txq = netdev_get_tx_queue(ndev, skb_get_queue_mapping(skb));
+		netif_tx_stop_queue(txq);
+	}
 
 	return NETDEV_TX_OK;
 fail:
 	ndev->stats.tx_dropped++;
-	netif_stop_queue(ndev);
+	txq = netdev_get_tx_queue(ndev, skb_get_queue_mapping(skb));
+	netif_tx_stop_queue(txq);
 	return NETDEV_TX_BUSY;
 }
 
@@ -1614,12 +1713,16 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	int ch;
 
 	cpsw_err(priv, tx_err, "transmit timeout, restarting dma\n");
 	ndev->stats.tx_errors++;
 	cpsw_intr_disable(priv);
-	cpdma_chan_stop(priv->txch);
-	cpdma_chan_start(priv->txch);
+	for (ch = 0; ch < priv->tx_ch_num; ch++) {
+		cpdma_chan_stop(priv->txch[ch]);
+		cpdma_chan_start(priv->txch[ch]);
+	}
+
 	cpsw_intr_enable(priv);
 }
 
@@ -1833,7 +1936,7 @@ static void cpsw_get_drvinfo(struct net_device *ndev,
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
 	strlcpy(info->driver, "cpsw", sizeof(info->driver));
-	strlcpy(info->version, "1.0", sizeof(info->version));
+	strlcpy(info->version, "1.1", sizeof(info->version));
 	strlcpy(info->bus_info, priv->pdev->name, sizeof(info->bus_info));
 }
 
@@ -2181,7 +2284,7 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	struct cpsw_priv		*priv_sl2;
 	int ret = 0, i;
 
-	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
+	ndev = alloc_etherdev_mq(sizeof(struct cpsw_priv), CPSW_MAX_QUEUES);
 	if (!ndev) {
 		dev_err(&pdev->dev, "cpsw: error allocating net_device\n");
 		return -ENOMEM;
@@ -2216,8 +2319,15 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	priv_sl2->wr_regs = priv->wr_regs;
 	priv_sl2->hw_stats = priv->hw_stats;
 	priv_sl2->dma = priv->dma;
-	priv_sl2->txch = priv->txch;
-	priv_sl2->rxch = priv->rxch;
+	priv_sl2->rx_ch_num = priv->rx_ch_num;
+	priv_sl2->tx_ch_num = priv->tx_ch_num;
+
+	for (i = 0; i < priv->tx_ch_num; i++)
+		priv_sl2->txch[i] = priv->txch[i];
+
+	for (i = 0; i < priv->rx_ch_num; i++)
+		priv_sl2->rxch[i] = priv->rxch[i];
+
 	priv_sl2->ale = priv->ale;
 	priv_sl2->emac_port = 1;
 	priv->slaves[1].ndev = ndev;
@@ -2298,7 +2408,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	int ret = 0, i;
 	int irq;
 
-	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
+	ndev = alloc_etherdev_mq(sizeof(struct cpsw_priv), CPSW_MAX_QUEUES);
 	if (!ndev) {
 		dev_err(&pdev->dev, "error allocating net_device\n");
 		return -ENOMEM;
@@ -2339,6 +2449,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 	data = &priv->data;
+	priv->rx_ch_num = 1;
+	priv->tx_ch_num = 1;
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
@@ -2463,12 +2575,12 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 
-	priv->txch = cpdma_chan_create(priv->dma, tx_chan_num(0),
-				       cpsw_tx_handler);
-	priv->rxch = cpdma_chan_create(priv->dma, rx_chan_num(0),
-				       cpsw_rx_handler);
+	priv->txch[0] = cpdma_chan_create(priv->dma, tx_chan_num(0),
+					  cpsw_tx_handler);
+	priv->rxch[0] = cpdma_chan_create(priv->dma, rx_chan_num(0),
+					  cpsw_rx_handler);
 
-	if (WARN_ON(!priv->txch || !priv->rxch)) {
+	if (WARN_ON(!priv->rxch[0] || !priv->txch[0])) {
 		dev_err(priv->dev, "error initializing dma channels\n");
 		ret = -ENOMEM;
 		goto clean_dma_ret;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 2f4b571..a4b299d 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -481,6 +481,18 @@ void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value)
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_eoi);
 
+u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr)
+{
+	return dma_reg_read(ctlr, CPDMA_RXINTSTATMASKED);
+}
+EXPORT_SYMBOL_GPL(cpdma_ctrl_rxchs_state);
+
+u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr)
+{
+	return dma_reg_read(ctlr, CPDMA_TXINTSTATMASKED);
+}
+EXPORT_SYMBOL_GPL(cpdma_ctrl_txchs_state);
+
 /**
  * cpdma_chan_split_pool - Splits ctrl pool between all channels.
  * Has to be called under ctlr lock
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 0308b67..3ce91a1 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -96,6 +96,8 @@ int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
 void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value);
 int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
+u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr);
+u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr);
 bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
 
 enum cpdma_control {
-- 
1.9.1
