From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V2 RE-SEND 2/7] net: sxgbe: add TSO support for Samsung sxgbe
Date: Thu, 13 Mar 2014 15:55:46 +0900
Message-ID: <007b01cf3e89$4289ea10$c79dbe30$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ilho215.lee@samsung.com,
	vipul.pandya@samsung.com, 'Joe Perches' <joe@perches.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:48922 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaCMGz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 02:55:58 -0400
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul.pandya@samsung.com>

Enable TSO during initialization for each DMA channels

Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Neatening-by: Joe Perches <joe@perches.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe_desc.c |   47 +++++++++++++++---
 drivers/net/ethernet/samsung/sxgbe_desc.h |   17 +++++--
 drivers/net/ethernet/samsung/sxgbe_dma.c  |   10 ++++
 drivers/net/ethernet/samsung/sxgbe_dma.h  |    2 +
 drivers/net/ethernet/samsung/sxgbe_main.c |   75 ++++++++++++++++++++++++++---
 5 files changed, 130 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe_desc.c b/drivers/net/ethernet/samsung/sxgbe_desc.c
index 9a93553..fa21236 100644
--- a/drivers/net/ethernet/samsung/sxgbe_desc.c
+++ b/drivers/net/ethernet/samsung/sxgbe_desc.c
@@ -28,6 +28,16 @@ static void sxgbe_init_tx_desc(struct sxgbe_tx_norm_desc *p)
 	p->tdes23.tx_rd_des23.own_bit = 0;
 }
 
+static void sxgbe_tx_desc_enable_tse(struct sxgbe_tx_norm_desc *p, u8 is_tse,
+				     u32 total_hdr_len, u32 tcp_hdr_len,
+				     u32 tcp_payload_len)
+{
+	p->tdes23.tx_rd_des23.tse_bit = is_tse;
+	p->tdes23.tx_rd_des23.buf1_size = total_hdr_len;
+	p->tdes23.tx_rd_des23.tcp_hdr_len = tcp_hdr_len / 4;
+	p->tdes23.tx_rd_des23.tx_pkt_len.tcp_payload_len  = tcp_payload_len;
+}
+
 /* Assign buffer lengths for descriptor */
 static void sxgbe_prepare_tx_desc(struct sxgbe_tx_norm_desc *p, u8 is_fd,
 				  int buf1_len, int pkt_len, int cksum)
@@ -102,36 +112,47 @@ static int sxgbe_get_tx_timestamp_status(struct sxgbe_tx_norm_desc *p)
 }
 
 /* TX Context Descripto Specific */
-static void sxgbe_init_tx_ctxtdesc(struct sxgbe_tx_ctxt_desc *p)
+static void sxgbe_tx_ctxt_desc_set_ctxt(struct sxgbe_tx_ctxt_desc *p)
 {
 	p->ctxt_bit = 1;
-	p->own_bit = 0;
 }
 
 /* Set the owner of TX context descriptor */
-static void sxgbe_set_tx_ctxt_owner(struct sxgbe_tx_ctxt_desc *p)
+static void sxgbe_tx_ctxt_desc_set_owner(struct sxgbe_tx_ctxt_desc *p)
 {
 	p->own_bit = 1;
 }
 
 /* Get the owner of TX context descriptor */
-static int sxgbe_get_tx_ctxt_owner(struct sxgbe_tx_ctxt_desc *p)
+static int sxgbe_tx_ctxt_desc_get_owner(struct sxgbe_tx_ctxt_desc *p)
 {
 	return p->own_bit;
 }
 
 /* Set TX mss in TX context Descriptor */
-static void sxgbe_tx_ctxt_desc_setmss(struct sxgbe_tx_ctxt_desc *p, int mss)
+static void sxgbe_tx_ctxt_desc_set_mss(struct sxgbe_tx_ctxt_desc *p, u16 mss)
 {
 	p->maxseg_size = mss;
 }
 
 /* Get TX mss from TX context Descriptor */
-static int sxgbe_tx_ctxt_desc_getmss(struct sxgbe_tx_ctxt_desc *p)
+static int sxgbe_tx_ctxt_desc_get_mss(struct sxgbe_tx_ctxt_desc *p)
 {
 	return p->maxseg_size;
 }
 
+/* Set TX tcmssv in TX context Descriptor */
+static void sxgbe_tx_ctxt_desc_set_tcmssv(struct sxgbe_tx_ctxt_desc *p)
+{
+	p->tcmssv = 1;
+}
+
+/* Reset TX ostc in TX context Descriptor */
+static void sxgbe_tx_ctxt_desc_reset_ostc(struct sxgbe_tx_ctxt_desc *p)
+{
+	p->ostc = 0;
+}
+
 /* Set IVLAN information */
 static void sxgbe_tx_ctxt_desc_set_ivlantag(struct sxgbe_tx_ctxt_desc *p,
 					    int is_ivlanvalid, int ivlan_tag,
@@ -177,13 +198,13 @@ static void sxgbe_tx_ctxt_desc_set_tstamp(struct sxgbe_tx_ctxt_desc *p,
 	}
 }
 /* Close TX context descriptor */
-static void sxgbe_close_tx_ctxt_desc(struct sxgbe_tx_ctxt_desc *p)
+static void sxgbe_tx_ctxt_desc_close(struct sxgbe_tx_ctxt_desc *p)
 {
 	p->own_bit = 1;
 }
 
 /* WB status of context descriptor */
-static int sxgbe_get_tx_ctxt_cde(struct sxgbe_tx_ctxt_desc *p)
+static int sxgbe_tx_ctxt_desc_get_cde(struct sxgbe_tx_ctxt_desc *p)
 {
 	return p->ctxt_desc_err;
 }
@@ -432,6 +453,7 @@ static u64 sxgbe_get_rx_timestamp(struct sxgbe_rx_ctxt_desc *p)
 
 static const struct sxgbe_desc_ops desc_ops = {
 	.init_tx_desc = sxgbe_init_tx_desc,
+	.tx_desc_enable_tse = sxgbe_tx_desc_enable_tse,
 	.prepare_tx_desc = sxgbe_prepare_tx_desc,
 	.tx_vlanctl_desc = sxgbe_tx_vlanctl_desc,
 	.set_tx_owner = sxgbe_set_tx_owner,
@@ -443,11 +465,20 @@ static const struct sxgbe_desc_ops desc_ops = {
 	.get_tx_len = sxgbe_get_tx_len,
 	.tx_enable_tstamp = sxgbe_tx_enable_tstamp,
 	.get_tx_timestamp_status = sxgbe_get_tx_timestamp_status,
+	.tx_ctxt_desc_set_ctxt = sxgbe_tx_ctxt_desc_set_ctxt,
+	.tx_ctxt_desc_set_owner =  sxgbe_tx_ctxt_desc_set_owner,
+	.get_tx_ctxt_owner = sxgbe_tx_ctxt_desc_get_owner,
+	.tx_ctxt_desc_set_mss = sxgbe_tx_ctxt_desc_set_mss,
+	.tx_ctxt_desc_get_mss = sxgbe_tx_ctxt_desc_get_mss,
+	.tx_ctxt_desc_set_tcmssv = sxgbe_tx_ctxt_desc_set_tcmssv,
+	.tx_ctxt_desc_reset_ostc = sxgbe_tx_ctxt_desc_reset_ostc,
 	.tx_ctxt_desc_set_ivlantag = sxgbe_tx_ctxt_desc_set_ivlantag,
 	.tx_ctxt_desc_get_ivlantag = sxgbe_tx_ctxt_desc_get_ivlantag,
 	.tx_ctxt_desc_set_vlantag = sxgbe_tx_ctxt_desc_set_vlantag,
 	.tx_ctxt_desc_get_vlantag = sxgbe_tx_ctxt_desc_get_vlantag,
 	.tx_ctxt_set_tstamp = sxgbe_tx_ctxt_desc_set_tstamp,
+	.close_tx_ctxt_desc = sxgbe_tx_ctxt_desc_close,
+	.get_tx_ctxt_cde = sxgbe_tx_ctxt_desc_get_cde,
 	.init_rx_desc = sxgbe_init_rx_desc,
 	.get_rx_owner = sxgbe_get_rx_owner,
 	.set_rx_owner = sxgbe_set_rx_owner,
diff --git a/drivers/net/ethernet/samsung/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe_desc.h
index 761b521..976d5ac 100644
--- a/drivers/net/ethernet/samsung/sxgbe_desc.h
+++ b/drivers/net/ethernet/samsung/sxgbe_desc.h
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
diff --git a/drivers/net/ethernet/samsung/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe_dma.c
index 9ee4a3c..61fa64e 100644
--- a/drivers/net/ethernet/samsung/sxgbe_dma.c
+++ b/drivers/net/ethernet/samsung/sxgbe_dma.c
@@ -353,6 +353,15 @@ static void sxgbe_dma_rx_watchdog(void __iomem *ioaddr, u32 riwt)
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
@@ -368,6 +377,7 @@ static const struct sxgbe_dma_ops sxgbe_dma_ops = {
 	.tx_dma_int_status = sxgbe_tx_dma_int_status,
 	.rx_dma_int_status = sxgbe_rx_dma_int_status,
 	.rx_watchdog = sxgbe_dma_rx_watchdog,
+	.enable_tso = sxgbe_enable_tso,
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe_dma.h b/drivers/net/ethernet/samsung/sxgbe_dma.h
index 50c8054..6c070ac 100644
--- a/drivers/net/ethernet/samsung/sxgbe_dma.h
+++ b/drivers/net/ethernet/samsung/sxgbe_dma.h
@@ -42,6 +42,8 @@ struct sxgbe_dma_ops {
 				 struct sxgbe_extra_stats *x);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
+	/* Enable TSO for each DMA channel */
+	void (*enable_tso)(void __iomem *ioaddr, u8 chan_num);
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void);
diff --git a/drivers/net/ethernet/samsung/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe_main.c
index 7b5a6bd..857048e 100644
--- a/drivers/net/ethernet/samsung/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe_main.c
@@ -1168,6 +1168,28 @@ static int sxgbe_release(struct net_device *dev)
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
@@ -1185,13 +1207,22 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
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
 
@@ -1210,18 +1241,36 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -1913,6 +1962,7 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
 	int ret = 0;
 	struct net_device *ndev = NULL;
 	struct sxgbe_priv_data *priv;
+	u8 queue_num;
 
 	ndev = alloc_etherdev_mqs(sizeof(struct sxgbe_priv_data),
 				  SXGBE_TX_QUEUES, SXGBE_RX_QUEUES);
@@ -1957,7 +2007,9 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
 
 	ndev->netdev_ops = &sxgbe_netdev_ops;
 
-	ndev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM;
+	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_GRO;
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 
@@ -1969,6 +2021,13 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
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
