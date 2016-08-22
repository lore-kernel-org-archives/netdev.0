From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v4 3/5] net: ethernet: ti: cpsw: add multi queue support
Date: Mon, 22 Aug 2016 21:18:26 +0300
Message-ID: <1471889908-29983-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        nsekhar@ti.com, dlide@ti.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com,
        grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:35093 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754243AbcHVSSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 14:18:41 -0400
Received: by mail-lf0-f51.google.com with SMTP id f93so84070343lfi.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:18:39 -0700 (PDT)
In-Reply-To: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cpsw h/w supports up to 8 tx and 8 rx channels. This patch adds
multi-queue support to the driver only, shaper configuration will
be added with separate patch series. Default shaper mode, as
before, priority mode, but with corrected priority order, 0 - is
highest priority, 7 - lowest.

The poll function handles all unprocessed channels, till all of
them are free, beginning from hi priority channel.

In dual_emac mode the channels are shared between two network devices,
as it's with single-queue default mode.

The statistic for every channel can be read with:
$ ethtool -S ethX

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c          | 301 +++++++++++++++++++++-----------
 drivers/net/ethernet/ti/davinci_cpdma.c |  12 ++
 drivers/net/ethernet/ti/davinci_cpdma.h |   2 +
 3 files changed, 210 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4065f96..28cc716 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -124,7 +124,7 @@ do {								\
 
 #define RX_PRIORITY_MAPPING	0x76543210
 #define TX_PRIORITY_MAPPING	0x33221100
-#define CPDMA_TX_PRIORITY_MAP	0x76543210
+#define CPDMA_TX_PRIORITY_MAP	0x01234567
 
 #define CPSW_VLAN_AWARE		BIT(1)
 #define CPSW_ALE_VLAN_AWARE	1
@@ -144,6 +144,7 @@ do {								\
 		((cpsw->data.dual_emac) ? priv->emac_port :	\
 		cpsw->data.active_slave)
 #define IRQ_NUM			2
+#define CPSW_MAX_QUEUES		8
 
 static int debug_level;
 module_param(debug_level, int, 0);
@@ -379,13 +380,15 @@ struct cpsw_common {
 	int				rx_packet_max;
 	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
-	struct cpdma_chan		*txch, *rxch;
+	struct cpdma_chan		*txch[CPSW_MAX_QUEUES];
+	struct cpdma_chan		*rxch[CPSW_MAX_QUEUES];
 	struct cpsw_ale			*ale;
 	bool				quirk_irq;
 	bool				rx_irq_disabled;
 	bool				tx_irq_disabled;
 	u32 irqs_table[IRQ_NUM];
 	struct cpts			*cpts;
+	int				rx_ch_num, tx_ch_num;
 };
 
 struct cpsw_priv {
@@ -457,35 +460,26 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
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
 
 #define ndev_to_cpsw(ndev) (((struct cpsw_priv *)netdev_priv(ndev))->cpsw)
 #define napi_to_cpsw(napi)	container_of(napi, struct cpsw_common, napi)
@@ -669,6 +663,7 @@ static void cpsw_intr_disable(struct cpsw_common *cpsw)
 
 static void cpsw_tx_handler(void *token, int len, int status)
 {
+	struct netdev_queue	*txq;
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
 	struct cpsw_common	*cpsw = ndev_to_cpsw(ndev);
@@ -676,8 +671,10 @@ static void cpsw_tx_handler(void *token, int len, int status)
 	/* Check whether the queue is stopped due to stalled tx dma, if the
 	 * queue is stopped then start the queue as we have free desc for tx
 	 */
-	if (unlikely(netif_queue_stopped(ndev)))
-		netif_wake_queue(ndev);
+	txq = netdev_get_tx_queue(ndev, skb_get_queue_mapping(skb));
+	if (unlikely(netif_tx_queue_stopped(txq)))
+		netif_tx_wake_queue(txq);
+
 	cpts_tx_timestamp(cpsw->cpts, skb);
 	ndev->stats.tx_packets++;
 	ndev->stats.tx_bytes += len;
@@ -686,6 +683,7 @@ static void cpsw_tx_handler(void *token, int len, int status)
 
 static void cpsw_rx_handler(void *token, int len, int status)
 {
+	struct cpdma_chan	*ch;
 	struct sk_buff		*skb = token;
 	struct sk_buff		*new_skb;
 	struct net_device	*ndev = skb->dev;
@@ -724,6 +722,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 
 	new_skb = netdev_alloc_skb_ip_align(ndev, cpsw->rx_packet_max);
 	if (new_skb) {
+		skb_copy_queue_mapping(new_skb, skb);
 		skb_put(skb, len);
 		cpts_rx_timestamp(cpsw->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
@@ -737,7 +736,8 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	}
 
 requeue:
-	ret = cpdma_chan_submit(cpsw->rxch, new_skb, new_skb->data,
+	ch = cpsw->rxch[skb_get_queue_mapping(new_skb)];
+	ret = cpdma_chan_submit(ch, new_skb, new_skb->data,
 				skb_tailroom(new_skb), 0);
 	if (WARN_ON(ret < 0))
 		dev_kfree_skb_any(new_skb);
@@ -777,10 +777,27 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 
 static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 {
+	u32			ch_map;
+	int			num_tx, ch;
 	struct cpsw_common	*cpsw = napi_to_cpsw(napi_tx);
-	int			num_tx;
 
-	num_tx = cpdma_chan_process(cpsw->txch, budget);
+	/* process every unprocessed channel */
+	ch_map = cpdma_ctrl_txchs_state(cpsw->dma);
+	for (ch = 0, num_tx = 0; num_tx < budget; ch_map >>= 1, ch++) {
+		if (!ch_map) {
+			ch_map = cpdma_ctrl_txchs_state(cpsw->dma);
+			if (!ch_map)
+				break;
+
+			ch = 0;
+		}
+
+		if (!(ch_map & 0x01))
+			continue;
+
+		num_tx += cpdma_chan_process(cpsw->txch[ch], budget - num_tx);
+	}
+
 	if (num_tx < budget) {
 		napi_complete(napi_tx);
 		writel(0xff, &cpsw->wr_regs->tx_en);
@@ -795,10 +812,27 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 
 static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 {
+	u32			ch_map;
+	int			num_rx, ch;
 	struct cpsw_common	*cpsw = napi_to_cpsw(napi_rx);
-	int			num_rx;
 
-	num_rx = cpdma_chan_process(cpsw->rxch, budget);
+	/* process every unprocessed channel */
+	ch_map = cpdma_ctrl_rxchs_state(cpsw->dma);
+	for (ch = 0, num_rx = 0; num_rx < budget; ch_map >>= 1, ch++) {
+		if (!ch_map) {
+			ch_map = cpdma_ctrl_rxchs_state(cpsw->dma);
+			if (!ch_map)
+				break;
+
+			ch = 0;
+		}
+
+		if (!(ch_map & 0x01))
+			continue;
+
+		num_rx += cpdma_chan_process(cpsw->rxch[ch], budget - num_rx);
+	}
+
 	if (num_rx < budget) {
 		napi_complete(napi_rx);
 		writel(0xff, &cpsw->wr_regs->rx_en);
@@ -897,10 +931,10 @@ static void cpsw_adjust_link(struct net_device *ndev)
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
 
@@ -973,26 +1007,51 @@ update_return:
 
 static int cpsw_get_sset_count(struct net_device *ndev, int sset)
 {
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
+
 	switch (sset) {
 	case ETH_SS_STATS:
-		return CPSW_STATS_LEN;
+		return (CPSW_STATS_COMMON_LEN +
+		       (cpsw->rx_ch_num + cpsw->tx_ch_num) *
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
+		snprintf(*p, ETH_GSTRING_LEN,
+			 "%s DMA chan %d: %s", rx_dir ? "Rx" : "Tx",
+			 i / CPSW_STATS_CH_LEN,
+			 cpsw_gstrings_ch_stats[line].stat_string);
+		*p += ETH_GSTRING_LEN;
+	}
+}
+
 static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 {
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
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
+		cpsw_add_ch_strings(&p, cpsw->rx_ch_num, 1);
+		cpsw_add_ch_strings(&p, cpsw->tx_ch_num, 0);
 		break;
 	}
 }
@@ -1000,36 +1059,31 @@ static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 static void cpsw_get_ethtool_stats(struct net_device *ndev,
 				    struct ethtool_stats *stats, u64 *data)
 {
-	struct cpdma_chan_stats rx_stats;
-	struct cpdma_chan_stats tx_stats;
-	u32 val;
 	u8 *p;
-	int i;
 	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
+	struct cpdma_chan_stats ch_stats;
+	int i, l, ch;
 
 	/* Collect Davinci CPDMA stats for Rx and Tx Channel */
-	cpdma_chan_get_stats(cpsw->rxch, &rx_stats);
-	cpdma_chan_get_stats(cpsw->txch, &tx_stats);
-
-	for (i = 0; i < CPSW_STATS_LEN; i++) {
-		switch (cpsw_gstrings_stats[i].type) {
-		case CPSW_STATS:
-			val = readl(cpsw->hw_stats +
-				    cpsw_gstrings_stats[i].stat_offset);
-			data[i] = val;
-			break;
-
-		case CPDMA_RX_STATS:
-			p = (u8 *)&rx_stats +
-				cpsw_gstrings_stats[i].stat_offset;
-			data[i] = *(u32 *)p;
-			break;
+	for (l = 0; l < CPSW_STATS_COMMON_LEN; l++)
+		data[l] = readl(cpsw->hw_stats +
+				cpsw_gstrings_stats[l].stat_offset);
+
+	for (ch = 0; ch < cpsw->rx_ch_num; ch++) {
+		cpdma_chan_get_stats(cpsw->rxch[ch], &ch_stats);
+		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
+			p = (u8 *)&ch_stats +
+				cpsw_gstrings_ch_stats[i].stat_offset;
+			data[l] = *(u32 *)p;
+		}
+	}
 
-		case CPDMA_TX_STATS:
-			p = (u8 *)&tx_stats +
-				cpsw_gstrings_stats[i].stat_offset;
-			data[i] = *(u32 *)p;
-			break;
+	for (ch = 0; ch < cpsw->tx_ch_num; ch++) {
+		cpdma_chan_get_stats(cpsw->txch[ch], &ch_stats);
+		for (i = 0; i < CPSW_STATS_CH_LEN; i++, l++) {
+			p = (u8 *)&ch_stats +
+				cpsw_gstrings_ch_stats[i].stat_offset;
+			data[l] = *(u32 *)p;
 		}
 	}
 }
@@ -1050,11 +1104,12 @@ static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
 }
 
 static inline int cpsw_tx_packet_submit(struct cpsw_priv *priv,
-					struct sk_buff *skb)
+					struct sk_buff *skb,
+					struct cpdma_chan *txch)
 {
 	struct cpsw_common *cpsw = priv->cpsw;
 
-	return cpdma_chan_submit(cpsw->txch, skb, skb->data, skb->len,
+	return cpdma_chan_submit(txch, skb, skb->data, skb->len,
 				 priv->emac_port + cpsw->data.dual_emac);
 }
 
@@ -1218,33 +1273,37 @@ static int cpsw_fill_rx_channels(struct cpsw_priv *priv)
 	struct cpsw_common *cpsw = priv->cpsw;
 	struct sk_buff *skb;
 	int ch_buf_num;
-	int i, ret;
-
-	ch_buf_num = cpdma_chan_get_rx_buf_num(cpsw->rxch);
-	for (i = 0; i < ch_buf_num; i++) {
-		skb = __netdev_alloc_skb_ip_align(priv->ndev,
-						  cpsw->rx_packet_max,
-						  GFP_KERNEL);
-		if (!skb) {
-			cpsw_err(priv, ifup, "cannot allocate skb\n");
-			return -ENOMEM;
-		}
+	int ch, i, ret;
+
+	for (ch = 0; ch < cpsw->rx_ch_num; ch++) {
+		ch_buf_num = cpdma_chan_get_rx_buf_num(cpsw->rxch[ch]);
+		for (i = 0; i < ch_buf_num; i++) {
+			skb = __netdev_alloc_skb_ip_align(priv->ndev,
+							  cpsw->rx_packet_max,
+							  GFP_KERNEL);
+			if (!skb) {
+				cpsw_err(priv, ifup, "cannot allocate skb\n");
+				return -ENOMEM;
+			}
 
-		ret = cpdma_chan_submit(cpsw->rxch, skb, skb->data,
-					skb_tailroom(skb), 0);
-		if (ret < 0) {
-			cpsw_err(priv, ifup,
-				 "cannot submit skb to rx channel, error %d\n",
-				 ret);
-			kfree_skb(skb);
-			return ret;
+			skb_set_queue_mapping(skb, ch);
+			ret = cpdma_chan_submit(cpsw->rxch[ch], skb, skb->data,
+						skb_tailroom(skb), 0);
+			if (ret < 0) {
+				cpsw_err(priv, ifup,
+					 "cannot submit skb to channel %d rx, error %d\n",
+					 ch, ret);
+				kfree_skb(skb);
+				return ret;
+			}
+			kmemleak_not_leak(skb);
 		}
-		kmemleak_not_leak(skb);
-	}
 
-	cpsw_info(priv, ifup, "submitted %d rx descriptors\n", ch_buf_num);
+		cpsw_info(priv, ifup, "ch %d rx, submitted %d descriptors\n",
+			  ch, ch_buf_num);
+	}
 
-	return ch_buf_num;
+	return 0;
 }
 
 static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_common *cpsw)
@@ -1280,6 +1339,19 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_intr_disable(cpsw);
 	netif_carrier_off(ndev);
 
+	/* Notify the stack of the actual queue counts. */
+	ret = netif_set_real_num_tx_queues(ndev, cpsw->tx_ch_num);
+	if (ret) {
+		dev_err(priv->dev, "cannot set real number of tx queues\n");
+		goto err_cleanup;
+	}
+
+	ret = netif_set_real_num_rx_queues(ndev, cpsw->rx_ch_num);
+	if (ret) {
+		dev_err(priv->dev, "cannot set real number of rx queues\n");
+		goto err_cleanup;
+	}
+
 	reg = cpsw->version;
 
 	dev_info(priv->dev, "initializing cpsw version %d.%d (%d)\n",
@@ -1349,6 +1421,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 	if (cpsw->data.dual_emac)
 		cpsw->slaves[priv->emac_port].open_stat = true;
+
+	netif_tx_start_all_queues(ndev);
+
 	return 0;
 
 err_cleanup:
@@ -1365,7 +1440,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	struct cpsw_common *cpsw = priv->cpsw;
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
-	netif_stop_queue(priv->ndev);
+	netif_tx_stop_all_queues(priv->ndev);
 	netif_carrier_off(priv->ndev);
 
 	if (cpsw_common_res_usage_state(cpsw) <= 1) {
@@ -1387,8 +1462,10 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 				       struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	int ret;
 	struct cpsw_common *cpsw = priv->cpsw;
+	struct netdev_queue *txq;
+	struct cpdma_chan *txch;
+	int ret, q_idx;
 
 	netif_trans_update(ndev);
 
@@ -1404,7 +1481,12 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	ret = cpsw_tx_packet_submit(priv, skb);
+	q_idx = skb_get_queue_mapping(skb);
+	if (q_idx >= cpsw->tx_ch_num)
+		q_idx = q_idx % cpsw->tx_ch_num;
+
+	txch = cpsw->txch[q_idx];
+	ret = cpsw_tx_packet_submit(priv, skb, txch);
 	if (unlikely(ret != 0)) {
 		cpsw_err(priv, tx_err, "desc submit failed\n");
 		goto fail;
@@ -1413,13 +1495,16 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	/* If there is no more tx desc left free then we need to
 	 * tell the kernel to stop sending us tx frames.
 	 */
-	if (unlikely(!cpdma_check_free_tx_desc(cpsw->txch)))
-		netif_stop_queue(ndev);
+	if (unlikely(!cpdma_check_free_tx_desc(txch))) {
+		txq = netdev_get_tx_queue(ndev, q_idx);
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
 
@@ -1601,12 +1686,16 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
+	int ch;
 
 	cpsw_err(priv, tx_err, "transmit timeout, restarting dma\n");
 	ndev->stats.tx_errors++;
 	cpsw_intr_disable(cpsw);
-	cpdma_chan_stop(cpsw->txch);
-	cpdma_chan_start(cpsw->txch);
+	for (ch = 0; ch < cpsw->tx_ch_num; ch++) {
+		cpdma_chan_stop(cpsw->txch[ch]);
+		cpdma_chan_start(cpsw->txch[ch]);
+	}
+
 	cpsw_intr_enable(cpsw);
 }
 
@@ -2178,7 +2267,7 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 	struct cpsw_priv		*priv_sl2;
 	int ret = 0;
 
-	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
+	ndev = alloc_etherdev_mq(sizeof(struct cpsw_priv), CPSW_MAX_QUEUES);
 	if (!ndev) {
 		dev_err(cpsw->dev, "cpsw: error allocating net_device\n");
 		return -ENOMEM;
@@ -2279,7 +2368,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	cpsw = devm_kzalloc(&pdev->dev, sizeof(struct cpsw_common), GFP_KERNEL);
 	cpsw->dev = &pdev->dev;
 
-	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
+	ndev = alloc_etherdev_mq(sizeof(struct cpsw_priv), CPSW_MAX_QUEUES);
 	if (!ndev) {
 		dev_err(&pdev->dev, "error allocating net_device\n");
 		return -ENOMEM;
@@ -2320,6 +2409,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 	data = &cpsw->data;
+	cpsw->rx_ch_num = 1;
+	cpsw->tx_ch_num = 1;
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
@@ -2444,12 +2535,12 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 
-	cpsw->txch = cpdma_chan_create(cpsw->dma, tx_chan_num(0),
-				       cpsw_tx_handler);
-	cpsw->rxch = cpdma_chan_create(cpsw->dma, rx_chan_num(0),
-				       cpsw_rx_handler);
+	cpsw->txch[0] = cpdma_chan_create(cpsw->dma, tx_chan_num(0),
+					  cpsw_tx_handler);
+	cpsw->rxch[0] = cpdma_chan_create(cpsw->dma, rx_chan_num(0),
+					  cpsw_rx_handler);
 
-	if (WARN_ON(!cpsw->txch || !cpsw->rxch)) {
+	if (WARN_ON(!cpsw->rxch[0] || !cpsw->txch[0])) {
 		dev_err(priv->dev, "error initializing dma channels\n");
 		ret = -ENOMEM;
 		goto clean_dma_ret;
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index ffb32af..4b578b1 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -403,6 +403,18 @@ void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value)
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
index 9119b43..070f1d0 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -94,6 +94,8 @@ int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
 void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value);
 int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
+u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr);
+u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr);
 bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
 
 enum cpdma_control {
-- 
1.9.1
