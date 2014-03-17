From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V3 3/8] net: sxgbe: add TSO support for Samsung sxgbe
Date: Mon, 17 Mar 2014 13:43:37 -0700
Message-ID: <00be01cf4221$941609e0$bc421da0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vipul.pandya@samsung.com,
	ilho215.lee@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vipul Pandya <vipul.pandya@samsung.com>

Enable TSO during initialization for each DMA channels

Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Neatening-by: Joe Perches <joe@perches.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h |   17 +++--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c  |   10 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h  |    2 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |   75 ++++++++++++++++++++---
 4 files changed, 91 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
index 41844d4..547edf3 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
@@ -167,8 +167,9 @@ struct sxgbe_desc_ops {
 	void (*init_tx_desc)(struct sxgbe_tx_norm_desc *p);
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
-	void (*tx_enable_tse)(struct sxgbe_tx_norm_desc *p, u8 is_tse,
-				u32 hdr_len, u32 payload_len);
+	void (*tx_desc_enable_tse)(struct sxgbe_tx_norm_desc *p, u8 is_tse,
+				   u32 total_hdr_len, u32 tcp_hdr_len,
+				   u32 tcp_payload_len);
 
 	/* Assign buffer lengths for descriptor */
 	void (*prepare_tx_desc)(struct sxgbe_tx_norm_desc *p, u8 is_fd,
@@ -207,20 +208,26 @@ struct sxgbe_desc_ops {
 	int (*get_tx_timestamp_status)(struct sxgbe_tx_norm_desc *p);
 
 	/* TX Context Descripto Specific */
-	void (*init_tx_ctxt_desc)(struct sxgbe_tx_ctxt_desc *p);
+	void (*tx_ctxt_desc_set_ctxt)(struct sxgbe_tx_ctxt_desc *p);
 
 	/* Set the owner of the TX context descriptor */
-	void (*set_tx_ctxt_owner)(struct sxgbe_tx_ctxt_desc *p);
+	void (*tx_ctxt_desc_set_owner)(struct sxgbe_tx_ctxt_desc *p);
 
 	/* Get the owner of the TX context descriptor */
 	int (*get_tx_ctxt_owner)(struct sxgbe_tx_ctxt_desc *p);
 
 	/* Set TX mss */
-	void (*tx_ctxt_desc_setmss)(struct sxgbe_tx_ctxt_desc *p, int mss);
+	void (*tx_ctxt_desc_set_mss)(struct sxgbe_tx_ctxt_desc *p, u16 mss);
 
 	/* Set TX mss */
 	int (*tx_ctxt_desc_get_mss)(struct sxgbe_tx_ctxt_desc *p);
 
+	/* Set TX tcmssv */
+	void (*tx_ctxt_desc_set_tcmssv)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Reset TX ostc */
+	void (*tx_ctxt_desc_reset_ostc)(struct sxgbe_tx_ctxt_desc *p);
+
 	/* Set IVLAN information */
 	void (*tx_ctxt_desc_set_ivlantag)(struct sxgbe_tx_ctxt_desc *p,
 					  int is_ivlanvalid, int ivlan_tag,
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
index 1e68ef3..1edc451 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
@@ -354,6 +354,15 @@ static void sxgbe_dma_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 	}
 }
 
+static void sxgbe_enable_tso(void __iomem *ioaddr, u8 chan_num)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(chan_num));
+	ctrl |= SXGBE_DMA_CHA_TXCTL_TSE_ENABLE;
+	writel(ctrl, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(chan_num));
+}
+
 static const struct sxgbe_dma_ops sxgbe_dma_ops = {
 	.init = sxgbe_dma_init,
 	.cha_init = sxgbe_dma_channel_init,
@@ -369,6 +378,7 @@ static const struct sxgbe_dma_ops sxgbe_dma_ops = {
 	.tx_dma_int_status = sxgbe_tx_dma_int_status,
 	.rx_dma_int_status = sxgbe_rx_dma_int_status,
 	.rx_watchdog = sxgbe_dma_rx_watchdog,
+	.enable_tso = sxgbe_enable_tso,
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
index 50c8054..6c070ac 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
@@ -42,6 +42,8 @@ struct sxgbe_dma_ops {
 				 struct sxgbe_extra_stats *x);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
+	/* Enable TSO for each DMA channel */
+	void (*enable_tso)(void __iomem *ioaddr, u8 chan_num);
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void);
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 5bea4b4..ad6611f 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1123,6 +1123,28 @@ static int sxgbe_release(struct net_device *dev)
 	return 0;
 }
 
+/* Prepare first Tx descriptor for doing TSO operation */
+void sxgbe_tso_prepare(struct sxgbe_priv_data *priv,
+		       struct sxgbe_tx_norm_desc *first_desc,
+		       struct sk_buff *skb)
+{
+	unsigned int total_hdr_len, tcp_hdr_len;
+
+	/* Write first Tx descriptor with appropriate value */
+	tcp_hdr_len = tcp_hdrlen(skb);
+	total_hdr_len = skb_transport_offset(skb) + tcp_hdr_len;
+
+	first_desc->tdes01 = dma_map_single(priv->device, skb->data,
+					    total_hdr_len, DMA_TO_DEVICE);
+	if (dma_mapping_error(priv->device, first_desc->tdes01))
+		pr_err("%s: TX dma mapping failed!!\n", __func__);
+
+	first_desc->tdes23.tx_rd_des23.first_desc = 1;
+	priv->hw->desc->tx_desc_enable_tse(first_desc, 1, total_hdr_len,
+					   tcp_hdr_len,
+					   skb->len - total_hdr_len);
+}
+
 /**
  *  sxgbe_xmit: Tx entry point of the driver
  *  @skb : the socket buffer
@@ -1140,13 +1162,22 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int tx_rsize = priv->dma_tx_size;
 	struct sxgbe_tx_queue *tqueue = priv->txq[txq_index];
 	struct sxgbe_tx_norm_desc *tx_desc, *first_desc;
+	struct sxgbe_tx_ctxt_desc *ctxt_desc = NULL;
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int no_pagedlen = skb_headlen(skb);
 	int is_jumbo = 0;
+	u16 mss;
+	u32 ctxt_desc_req = 0;
 
 	/* get the TX queue handle */
 	dev_txq = netdev_get_tx_queue(dev, txq_index);
 
+	if (likely(skb_is_gso(skb) ||
+		   vlan_tx_tag_present(skb) ||
+		   ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		    tqueue->hwts_tx_en)))
+		ctxt_desc_req = 1;
+
 	/* get the spinlock */
 	spin_lock(&tqueue->tx_lock);
 
@@ -1165,18 +1196,36 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_desc = tqueue->dma_tx + entry;
 
 	first_desc = tx_desc;
+	if (ctxt_desc_req)
+		ctxt_desc = (struct sxgbe_tx_ctxt_desc *)first_desc;
 
 	/* save the skb address */
 	tqueue->tx_skbuff[entry] = skb;
 
 	if (!is_jumbo) {
-		tx_desc->tdes01 = dma_map_single(priv->device, skb->data,
-						   no_pagedlen, DMA_TO_DEVICE);
-		if (dma_mapping_error(priv->device, tx_desc->tdes01))
-			pr_err("%s: TX dma mapping failed!!\n", __func__);
-
-		priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
-						no_pagedlen);
+		if (likely(skb_is_gso(skb))) {
+			/* TSO support */
+			mss = skb_shinfo(skb)->gso_size;
+			priv->hw->desc->tx_ctxt_desc_set_mss(ctxt_desc, mss);
+			priv->hw->desc->tx_ctxt_desc_set_tcmssv(ctxt_desc);
+			priv->hw->desc->tx_ctxt_desc_reset_ostc(ctxt_desc);
+			priv->hw->desc->tx_ctxt_desc_set_ctxt(ctxt_desc);
+			priv->hw->desc->tx_ctxt_desc_set_owner(ctxt_desc);
+
+			entry = (++tqueue->cur_tx) % tx_rsize;
+			first_desc = tqueue->dma_tx + entry;
+
+			sxgbe_tso_prepare(priv, first_desc, skb);
+		} else {
+			tx_desc->tdes01 = dma_map_single(priv->device,
+							 skb->data, no_pagedlen, DMA_TO_DEVICE);
+			if (dma_mapping_error(priv->device, tx_desc->tdes01))
+				netdev_err(dev, "%s: TX dma mapping failed!!\n",
+					   __func__);
+
+			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
+							no_pagedlen);
+		}
 	}
 
 	for (frag_num = 0; frag_num < nr_frags; frag_num++) {
@@ -1870,6 +1919,7 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
 	int ret = 0;
 	struct net_device *ndev = NULL;
 	struct sxgbe_priv_data *priv;
+	u8 queue_num;
 
 	ndev = alloc_etherdev_mqs(sizeof(struct sxgbe_priv_data),
 				  SXGBE_TX_QUEUES, SXGBE_RX_QUEUES);
@@ -1905,7 +1955,9 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
 
 	ndev->netdev_ops = &sxgbe_netdev_ops;
 
-	ndev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM;
+	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_GRO;
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(TX_TIMEO);
 
@@ -1917,6 +1969,13 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
 	if (flow_ctrl)
 		priv->flow_ctrl = SXGBE_FLOW_AUTO;	/* RX/TX pause on */
 
+	/* Enable TCP segmentation offload for all DMA channels */
+	if (priv->hw_cap.tcpseg_offload) {
+		SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+			priv->hw->dma->enable_tso(priv->ioaddr, queue_num);
+		}
+	}
+
 	/* Rx Watchdog is available, enable depend on platform data */
 	if (!priv->plat->riwt_off) {
 		priv->use_riwt = 1;
-- 
1.7.10.4
