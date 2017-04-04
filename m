From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 4/4] net: stmmac: adding multiple napi mechanism
Date: Tue,  4 Apr 2017 18:54:27 +0100
Message-ID: <7af29adf8064bf5bb55b5a4e9fb2a3f325c873a2.1491328304.git.jpinto@synopsys.com>
References: <cover.1491327063.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net, clabbe.montjoie@gmail.com, treding@nvidia.com,
        niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:41727 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932351AbdDDRyw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:54:52 -0400
In-Reply-To: <cover.1491327063.git.jpinto@synopsys.com>
In-Reply-To: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
References: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the napi variable to the stmmac_rx_queue
structure and forces that operations like netif_queue_stopped,
netif_wake_queue, netif_stop_queue, netdev_reset_queue and
netdev_sent_queue be made by queue.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 193 ++++++++++++++++------
 2 files changed, 139 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 359f8fd..33efe70 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -72,6 +72,7 @@ struct stmmac_rx_queue {
 	u32 rx_zeroc_thresh;
 	dma_addr_t dma_rx_phy;
 	u32 rx_tail_addr;
+	struct napi_struct napi ____cacheline_aligned_in_smp;
 };
 
 struct stmmac_priv {
@@ -91,8 +92,6 @@ struct stmmac_priv {
 	u32 rx_riwt;
 	int hwts_rx_en;
 
-	struct napi_struct napi ____cacheline_aligned_in_smp;
-
 	void __iomem *ioaddr;
 	struct net_device *dev;
 	struct device *device;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f3e0e8f..eae610a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -139,6 +139,64 @@ static void stmmac_verify_args(void)
 }
 
 /**
+ * stmmac_disable_all_queues - Disable all queues
+ * @priv: driver private structure
+ */
+static void stmmac_disable_all_queues(struct stmmac_priv *priv)
+{
+	u32 rx_queues_cnt = priv->plat->rx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_queues_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		napi_disable(&rx_q->napi);
+	}
+}
+
+/**
+ * stmmac_enable_all_queues - Enable all queues
+ * @priv: driver private structure
+ */
+static void stmmac_enable_all_queues(struct stmmac_priv *priv)
+{
+	u32 rx_queues_cnt = priv->plat->rx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_queues_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		napi_enable(&rx_q->napi);
+	}
+}
+
+/**
+ * stmmac_stop_all_queues - Stop all queues
+ * @priv: driver private structure
+ */
+static void stmmac_stop_all_queues(struct stmmac_priv *priv)
+{
+	u32 tx_queues_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < tx_queues_cnt; queue++)
+		netif_tx_stop_queue(netdev_get_tx_queue(priv->dev, queue));
+}
+
+/**
+ * stmmac_start_all_queues - Start all queues
+ * @priv: driver private structure
+ */
+static void stmmac_start_all_queues(struct stmmac_priv *priv)
+{
+	u32 tx_queues_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < tx_queues_cnt; queue++)
+		netif_tx_start_queue(netdev_get_tx_queue(priv->dev, queue));
+}
+
+/**
  * stmmac_clk_csr_set - dynamically set the MDC clock
  * @priv: driver private structure
  * Description: this is to dynamically set the MDC clock according to the csr
@@ -1259,7 +1317,6 @@ static int init_dma_tx_desc_rings(struct net_device *dev)
 		/* TX INITIALIZATION */
 		for (i = 0; i < DMA_TX_SIZE; i++) {
 			struct dma_desc *p;
-
 			if (priv->extend_desc)
 				p = &((tx_q->dma_etx + i)->basic);
 			else
@@ -1283,9 +1340,9 @@ static int init_dma_tx_desc_rings(struct net_device *dev)
 
 		tx_q->dirty_tx = 0;
 		tx_q->cur_tx = 0;
-	}
 
-	netdev_reset_queue(priv->dev);
+		netdev_tx_reset_queue(netdev_get_tx_queue(priv->dev, queue));
+	}
 
 	return 0;
 }
@@ -1805,13 +1862,16 @@ static void stmmac_tx_clean(struct stmmac_priv *priv, u32 queue)
 	}
 	tx_q->dirty_tx = entry;
 
-	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
+	netdev_tx_completed_queue(netdev_get_tx_queue(priv->dev, queue),
+				  pkts_compl, bytes_compl);
+
+	if (unlikely(netif_tx_queue_stopped(netdev_get_tx_queue(priv->dev,
+								queue))) &&
+	    stmmac_tx_avail(priv, queue) > STMMAC_TX_THRESH) {
 
-	if (unlikely(netif_queue_stopped(priv->dev) &&
-	    stmmac_tx_avail(priv, queue) > STMMAC_TX_THRESH)) {
 		netif_dbg(priv, tx_done, priv->dev,
 			  "%s: restart transmit\n", __func__);
-		netif_wake_queue(priv->dev);
+		netif_tx_wake_queue(netdev_get_tx_queue(priv->dev, queue));
 	}
 
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
@@ -1843,7 +1903,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv, u32 chan)
 	struct stmmac_tx_queue *tx_q = &priv->tx_queue[chan];
 	int i;
 
-	netif_stop_queue(priv->dev);
+	netif_tx_stop_queue(netdev_get_tx_queue(priv->dev, chan));
 
 	stmmac_stop_tx_dma(priv, chan);
 	dma_free_tx_skbufs(priv, chan);
@@ -1858,11 +1918,11 @@ static void stmmac_tx_err(struct stmmac_priv *priv, u32 chan)
 						     (i == DMA_TX_SIZE - 1));
 	tx_q->dirty_tx = 0;
 	tx_q->cur_tx = 0;
-	netdev_reset_queue(priv->dev);
+	netdev_tx_reset_queue(netdev_get_tx_queue(priv->dev, chan));
 	stmmac_start_tx_dma(priv, chan);
 
 	priv->dev->stats.tx_errors++;
-	netif_wake_queue(priv->dev);
+	netif_tx_wake_queue(netdev_get_tx_queue(priv->dev, chan));
 }
 
 /**
@@ -1907,12 +1967,14 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	u32 chan;
 
 	for (chan = 0; chan < tx_channel_count; chan++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[chan];
+
 		status = priv->hw->dma->dma_interrupt(priv->ioaddr,
 						      &priv->xstats, chan);
 		if (likely((status & handle_rx)) || (status & handle_tx)) {
-			if (likely(napi_schedule_prep(&priv->napi))) {
+			if (likely(napi_schedule_prep(&rx_q->napi))) {
 				stmmac_disable_dma_irq(priv, chan);
-				__napi_schedule(&priv->napi);
+				__napi_schedule(&rx_q->napi);
 			}
 		}
 
@@ -2492,23 +2554,8 @@ static int stmmac_open(struct net_device *dev)
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
 
-	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
 	priv->rx_copybreak = STMMAC_RX_COPYBREAK;
 
-	ret = alloc_dma_desc_resources(priv);
-	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n",
-			   __func__);
-		goto dma_desc_error;
-	}
-
-	ret = init_dma_desc_rings(dev, GFP_KERNEL);
-	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA descriptors initialization failed\n",
-			   __func__);
-		goto init_error;
-	}
-
 	ret = stmmac_hw_setup(dev, true);
 	if (ret < 0) {
 		netdev_err(priv->dev, "%s: Hw setup failed\n", __func__);
@@ -2554,8 +2601,8 @@ static int stmmac_open(struct net_device *dev)
 		}
 	}
 
-	napi_enable(&priv->napi);
-	netif_start_queue(dev);
+	stmmac_enable_all_queues(priv);
+	stmmac_start_all_queues(priv);
 
 	return 0;
 
@@ -2572,7 +2619,7 @@ static int stmmac_open(struct net_device *dev)
 	stmmac_hw_teardown(dev);
 init_error:
 	free_dma_desc_resources(priv);
-dma_desc_error:
+
 	if (dev->phydev)
 		phy_disconnect(dev->phydev);
 
@@ -2598,9 +2645,9 @@ static int stmmac_release(struct net_device *dev)
 		phy_disconnect(dev->phydev);
 	}
 
-	netif_stop_queue(dev);
+	stmmac_stop_all_queues(priv);
 
-	napi_disable(&priv->napi);
+	stmmac_disable_all_queues(priv);
 
 	del_timer_sync(&priv->txtimer);
 
@@ -2717,8 +2764,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Desc availability based on threshold should be enough safe */
 	if (unlikely(stmmac_tx_avail(priv, queue) <
 		(((skb->len - proto_hdr_len) / TSO_MAX_BUFF_SIZE + 1)))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, queue))) {
+			netif_tx_stop_queue(netdev_get_tx_queue(priv->dev,
+								queue));
 			/* This is a hard error, log it. */
 			netdev_err(priv->dev,
 				   "%s: Tx Ring full when queue awake\n",
@@ -2798,7 +2846,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(stmmac_tx_avail(priv, queue) <= (MAX_SKB_FRAGS + 1))) {
 		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
 			  __func__);
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(netdev_get_tx_queue(priv->dev, queue));
 	}
 
 	dev->stats.tx_bytes += skb->len;
@@ -2855,7 +2903,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 		print_pkt(skb->data, skb_headlen(skb));
 	}
 
-	netdev_sent_queue(dev, skb->len);
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, queue), skb->len);
 
 	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, tx_q->tx_tail_addr,
 				       queue);
@@ -2899,8 +2947,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (unlikely(stmmac_tx_avail(priv, queue) < nfrags + 1)) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, queue))) {
+			netif_tx_stop_queue(netdev_get_tx_queue(priv->dev,
+								queue));
 			/* This is a hard error, log it. */
 			netdev_err(priv->dev,
 				   "%s: Tx Ring full when queue awake\n",
@@ -2998,7 +3047,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(stmmac_tx_avail(priv, queue) <= (MAX_SKB_FRAGS + 1))) {
 		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
 			  __func__);
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(netdev_get_tx_queue(priv->dev, queue));
 	}
 
 	dev->stats.tx_bytes += skb->len;
@@ -3061,7 +3110,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		dma_wmb();
 	}
 
-	netdev_sent_queue(dev, skb->len);
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, queue), skb->len);
 
 	if (priv->synopsys_id < DWMAC_CORE_4_00)
 		priv->hw->dma->enable_dma_transmission(priv->ioaddr);
@@ -3361,7 +3410,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 			else
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-			napi_gro_receive(&priv->napi, skb);
+			napi_gro_receive(&rx_q->napi, skb);
 
 			priv->dev->stats.rx_packets++;
 			priv->dev->stats.rx_bytes += frame_len;
@@ -3386,11 +3435,13 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
  */
 static int stmmac_poll(struct napi_struct *napi, int budget)
 {
-	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
+	struct stmmac_rx_queue *rx_q =
+		container_of(napi, struct stmmac_rx_queue, napi);
+	struct stmmac_priv *priv = rx_q->priv_data;
 	u32 tx_count = priv->plat->tx_queues_to_use;
-	u32 chan = STMMAC_CHAN0;
+	u32 chan = rx_q->queue_index;
 	int work_done = 0;
-	u32 queue = chan;
+	u32 queue;
 
 	priv->xstats.napi_poll++;
 
@@ -3398,9 +3449,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 	for (queue = 0; queue < tx_count; queue++)
 		stmmac_tx_clean(priv, queue);
 
-	queue = chan;
-
-	work_done = stmmac_rx(priv, budget, queue);
+	work_done = stmmac_rx(priv, budget, rx_q->queue_index);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
 		stmmac_enable_dma_irq(priv, chan);
@@ -3989,11 +4038,14 @@ int stmmac_dvr_probe(struct device *device,
 		     struct plat_stmmacenet_data *plat_dat,
 		     struct stmmac_resources *res)
 {
-	int ret = 0;
 	struct net_device *ndev = NULL;
 	struct stmmac_priv *priv;
+	int ret = 0;
+	u32 queue;
 
-	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
+	ndev = alloc_etherdev_mqs(sizeof(struct stmmac_priv),
+				  MTL_MAX_TX_QUEUES,
+				  MTL_MAX_RX_QUEUES);
 	if (!ndev)
 		return -ENOMEM;
 
@@ -4035,6 +4087,12 @@ int stmmac_dvr_probe(struct device *device,
 	if (ret)
 		goto error_hw_init;
 
+	/* Configure real RX and TX queues */
+	ndev->real_num_rx_queues = priv->plat->rx_queues_to_use;
+	ndev->real_num_tx_queues = priv->plat->tx_queues_to_use;
+
+	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
+
 	ndev->netdev_ops = &stmmac_netdev_ops;
 
 	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
@@ -4084,7 +4142,26 @@ int stmmac_dvr_probe(struct device *device,
 			 "Enable RX Mitigation via HW Watchdog Timer\n");
 	}
 
-	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
+	ret = alloc_dma_desc_resources(priv);
+	if (ret < 0) {
+		netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n",
+			   __func__);
+		goto init_dma_error;
+	}
+
+	ret = init_dma_desc_rings(priv->dev, GFP_KERNEL);
+	if (ret < 0) {
+		netdev_err(priv->dev, "%s: DMA descriptors initialization failed\n",
+			   __func__);
+		goto init_dma_error;
+	}
+
+	for (queue = 0; queue < priv->plat->rx_queues_to_use; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		netif_napi_add(ndev, &rx_q->napi, stmmac_poll,
+			       (8 * priv->plat->rx_queues_to_use));
+	}
 
 	spin_lock_init(&priv->lock);
 
@@ -4129,7 +4206,13 @@ int stmmac_dvr_probe(struct device *device,
 	    priv->hw->pcs != STMMAC_PCS_RTBI)
 		stmmac_mdio_unregister(ndev);
 error_mdio_register:
-	netif_napi_del(&priv->napi);
+	for (queue = 0; queue < priv->plat->rx_queues_to_use; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		netif_napi_del(&rx_q->napi);
+	}
+init_dma_error:
+	free_dma_desc_resources(priv);
 error_hw_init:
 	free_netdev(ndev);
 
@@ -4191,9 +4274,9 @@ int stmmac_suspend(struct device *dev)
 	spin_lock_irqsave(&priv->lock, flags);
 
 	netif_device_detach(ndev);
-	netif_stop_queue(ndev);
+	stmmac_stop_all_queues(priv);
 
-	napi_disable(&priv->napi);
+	stmmac_disable_all_queues(priv);
 
 	/* Stop TX/RX DMA */
 	stmmac_stop_all_dma(priv);
@@ -4296,9 +4379,9 @@ int stmmac_resume(struct device *dev)
 	stmmac_init_tx_coalesce(priv);
 	stmmac_set_rx_mode(ndev);
 
-	napi_enable(&priv->napi);
+	stmmac_enable_all_queues(priv);
 
-	netif_start_queue(ndev);
+	stmmac_start_all_queues(priv);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-- 
2.9.3
