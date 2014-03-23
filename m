From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V13 3/7] net: sxgbe: add TSO support for Samsung sxgbe
Date: Sun, 23 Mar 2014 13:46:16 -0700
Message-ID: <009f01cf46d8$f321c2b0$d9654810$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org
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
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h |    1 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c   |    2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h   |    4 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c    |   10 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h    |    2 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c   |   84 +++++++++++++++++++--
 6 files changed, 92 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
index 3e36ae1..ec5271d 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
@@ -327,6 +327,7 @@ struct sxgbe_tx_queue {
 	u32 tx_coal_frames;
 	u32 tx_coal_timer;
 	int hwts_tx_en;
+	u16 prev_mss;
 	u8 queue_no;
 };
 
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
index 7cb5520..e896dbb 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
@@ -133,7 +133,7 @@ static int sxgbe_tx_ctxt_desc_get_owner(struct sxgbe_tx_ctxt_desc *p)
 }
 
 /* Set TX mss in TX context Descriptor */
-static void sxgbe_tx_ctxt_desc_set_mss(struct sxgbe_tx_ctxt_desc *p, int mss)
+static void sxgbe_tx_ctxt_desc_set_mss(struct sxgbe_tx_ctxt_desc *p, u16 mss)
 {
 	p->maxseg_size = mss;
 }
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
index 2caef1a..6d44b9f 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
@@ -168,7 +168,7 @@ struct sxgbe_desc_ops {
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*tx_desc_enable_tse)(struct sxgbe_tx_norm_desc *p, u8 is_tse,
-				   u32 total_hdr_len, u32 payload_len,
+				   u32 total_hdr_len, u32 tcp_hdr_len,
 				   u32 tcp_payload_len);
 
 	/* Assign buffer lengths for descriptor */
@@ -217,7 +217,7 @@ struct sxgbe_desc_ops {
 	int (*get_tx_ctxt_owner)(struct sxgbe_tx_ctxt_desc *p);
 
 	/* Set TX mss */
-	void (*tx_ctxt_desc_set_mss)(struct sxgbe_tx_ctxt_desc *p, int mss);
+	void (*tx_ctxt_desc_set_mss)(struct sxgbe_tx_ctxt_desc *p, u16 mss);
 
 	/* Set TX mss */
 	int (*tx_ctxt_desc_get_mss)(struct sxgbe_tx_ctxt_desc *p);
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
index 59d2d39..28f89c4 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
@@ -349,6 +349,15 @@ static void sxgbe_dma_rx_watchdog(void __iomem *ioaddr, u32 riwt)
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
 	.init				= sxgbe_dma_init,
 	.cha_init			= sxgbe_dma_channel_init,
@@ -364,6 +373,7 @@ static const struct sxgbe_dma_ops sxgbe_dma_ops = {
 	.tx_dma_int_status		= sxgbe_tx_dma_int_status,
 	.rx_dma_int_status		= sxgbe_rx_dma_int_status,
 	.rx_watchdog			= sxgbe_dma_rx_watchdog,
+	.enable_tso			= sxgbe_enable_tso,
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
index bbf167e..1607b54 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
@@ -41,6 +41,8 @@ struct sxgbe_dma_ops {
 				 struct sxgbe_extra_stats *x);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
+	/* Enable TSO for each DMA channel */
+	void (*enable_tso)(void __iomem *ioaddr, u8 chan_num);
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void);
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index b932175..7b38bd0 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1096,6 +1096,28 @@ static int sxgbe_release(struct net_device *dev)
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
@@ -1113,13 +1135,24 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int tx_rsize = priv->dma_tx_size;
 	struct sxgbe_tx_queue *tqueue = priv->txq[txq_index];
 	struct sxgbe_tx_norm_desc *tx_desc, *first_desc;
+	struct sxgbe_tx_ctxt_desc *ctxt_desc = NULL;
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int no_pagedlen = skb_headlen(skb);
 	int is_jumbo = 0;
+	u16 cur_mss = skb_shinfo(skb)->gso_size;
+	u32 ctxt_desc_req = 0;
 
 	/* get the TX queue handle */
 	dev_txq = netdev_get_tx_queue(dev, txq_index);
 
+	if (unlikely(skb_is_gso(skb) && tqueue->prev_mss != cur_mss))
+		ctxt_desc_req = 1;
+
+	if (unlikely(vlan_tx_tag_present(skb) ||
+		     ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		      tqueue->hwts_tx_en)))
+		ctxt_desc_req = 1;
+
 	/* get the spinlock */
 	spin_lock(&tqueue->tx_lock);
 
@@ -1138,18 +1171,43 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
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
-						no_pagedlen, 0);
+		if (likely(skb_is_gso(skb))) {
+			/* TSO support */
+			if (unlikely(tqueue->prev_mss != cur_mss)) {
+				priv->hw->desc->tx_ctxt_desc_set_mss(
+						ctxt_desc, cur_mss);
+				priv->hw->desc->tx_ctxt_desc_set_tcmssv(
+						ctxt_desc);
+				priv->hw->desc->tx_ctxt_desc_reset_ostc(
+						ctxt_desc);
+				priv->hw->desc->tx_ctxt_desc_set_ctxt(
+						ctxt_desc);
+				priv->hw->desc->tx_ctxt_desc_set_owner(
+						ctxt_desc);
+
+				entry = (++tqueue->cur_tx) % tx_rsize;
+				first_desc = tqueue->dma_tx + entry;
+
+				tqueue->prev_mss = cur_mss;
+			}
+			sxgbe_tso_prepare(priv, first_desc, skb);
+		} else {
+			tx_desc->tdes01 = dma_map_single(priv->device,
+							 skb->data, no_pagedlen, DMA_TO_DEVICE);
+			if (dma_mapping_error(priv->device, tx_desc->tdes01))
+				netdev_err(dev, "%s: TX dma mapping failed!!\n",
+					   __func__);
+
+			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
+							no_pagedlen, 0);
+		}
 	}
 
 	for (frag_num = 0; frag_num < nr_frags; frag_num++) {
@@ -1858,6 +1916,7 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	struct sxgbe_priv_data *priv;
 	struct net_device *ndev;
 	int ret;
+	u8 queue_num;
 
 	ndev = alloc_etherdev_mqs(sizeof(struct sxgbe_priv_data),
 				  SXGBE_TX_QUEUES, SXGBE_RX_QUEUES);
@@ -1888,7 +1947,9 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 
 	ndev->netdev_ops = &sxgbe_netdev_ops;
 
-	ndev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM;
+	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_GRO;
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(TX_TIMEO);
 
@@ -1897,6 +1958,13 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 
 	priv->msg_enable = netif_msg_init(debug, default_msg_level);
 
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
