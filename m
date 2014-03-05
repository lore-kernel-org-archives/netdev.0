From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 2/7] net: xgmac: add TSO support for Samsung xgmac
Date: Wed, 05 Mar 2014 20:28:19 +0900
Message-ID: <007c01cf3866$02291460$067b3d20$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vipul.pandya@samsung.com,
	ilho215.lee@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58294 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbaCEL21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 06:28:27 -0500
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul.pandya@samsung.com>

Enable TSO during initialization for each DMA channels

Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/xgmac_desc.c |   47 +++++++++++++++---
 drivers/net/ethernet/samsung/xgmac_desc.h |   17 +++++--
 drivers/net/ethernet/samsung/xgmac_dma.c  |   10 ++++
 drivers/net/ethernet/samsung/xgmac_dma.h  |    2 +
 drivers/net/ethernet/samsung/xgmac_main.c |   76 ++++++++++++++++++++++++++---
 5 files changed, 131 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_desc.c b/drivers/net/ethernet/samsung/xgmac_desc.c
index 791b5ec..51b7e71 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.c
+++ b/drivers/net/ethernet/samsung/xgmac_desc.c
@@ -25,6 +25,16 @@ static void xgmac_init_tx_desc(struct xgmac_tx_norm_desc *p)
 	p->tdes23.tx_rd_des23.own_bit = 0;
 }
 
+static void xgmac_tx_desc_enable_tse(struct xgmac_tx_norm_desc *p, u8 is_tse,
+			      u32 total_hdr_len, u32 tcp_hdr_len,
+			      u32 tcp_payload_len)
+{
+	p->tdes23.tx_rd_des23.tse_bit = is_tse;
+	p->tdes23.tx_rd_des23.buf1_size = total_hdr_len;
+	p->tdes23.tx_rd_des23.tcp_hdr_len = tcp_hdr_len / 4;
+	p->tdes23.tx_rd_des23.tx_pkt_len.tcp_payload_len  = tcp_payload_len;
+}
+
 /* Assign buffer lengths for descriptor */
 static void xgmac_prepare_tx_desc(struct xgmac_tx_norm_desc *p, u8 is_fd,
 				int buf1_len, int pkt_len)
@@ -99,36 +109,47 @@ static int xgmac_get_tx_timestamp_status(struct xgmac_tx_norm_desc *p)
 }
 
 /* TX Context Descripto Specific */
-static void xgmac_init_tx_ctxtdesc(struct xgmac_tx_ctxt_desc *p)
+static void xgmac_tx_ctxt_desc_set_ctxt(struct xgmac_tx_ctxt_desc *p)
 {
 	p->ctxt_bit = 1;
-	p->own_bit = 0;
 }
 
 /* Set the owner of TX context descriptor */
-static void xgmac_set_tx_ctxt_owner(struct xgmac_tx_ctxt_desc *p)
+static void xgmac_tx_ctxt_desc_set_owner(struct xgmac_tx_ctxt_desc *p)
 {
 	p->own_bit = 1;
 }
 
 /* Get the owner of TX context descriptor */
-static int xgmac_get_tx_ctxt_owner(struct xgmac_tx_ctxt_desc *p)
+static int xgmac_tx_ctxt_desc_get_owner(struct xgmac_tx_ctxt_desc *p)
 {
 	return p->own_bit;
 }
 
 /* Set TX mss in TX context Descriptor */
-static void xgmac_tx_ctxt_desc_setmss(struct xgmac_tx_ctxt_desc *p, int mss)
+static void xgmac_tx_ctxt_desc_set_mss(struct xgmac_tx_ctxt_desc *p, u16 mss)
 {
 	p->maxseg_size = mss;
 }
 
 /* Get TX mss from TX context Descriptor */
-static int xgmac_tx_ctxt_desc_getmss(struct xgmac_tx_ctxt_desc *p)
+static int xgmac_tx_ctxt_desc_get_mss(struct xgmac_tx_ctxt_desc *p)
 {
 	return p->maxseg_size;
 }
 
+/* Set TX tcmssv in TX context Descriptor */
+static void xgmac_tx_ctxt_desc_set_tcmssv(struct xgmac_tx_ctxt_desc *p)
+{
+	p->tcmssv = 1;
+}
+
+/* Reset TX ostc in TX context Descriptor */
+static void xgmac_tx_ctxt_desc_reset_ostc(struct xgmac_tx_ctxt_desc *p)
+{
+	p->ostc = 0;
+}
+
 /* Set IVLAN information */
 static void xgmac_tx_ctxt_desc_set_ivlantag(struct xgmac_tx_ctxt_desc *p,
 				     int is_ivlanvalid, int ivlan_tag,
@@ -175,13 +196,13 @@ static void xgmac_tx_ctxt_desc_set_tstamp(struct xgmac_tx_ctxt_desc *p,
 
 }
 /* Close TX context descriptor */
-static void xgmac_close_tx_ctxt_desc(struct xgmac_tx_ctxt_desc *p)
+static void xgmac_tx_ctxt_desc_close(struct xgmac_tx_ctxt_desc *p)
 {
 	p->own_bit = 1;
 }
 
 /* WB status of context descriptor */
-static int xgmac_get_tx_ctxt_cde(struct xgmac_tx_ctxt_desc *p)
+static int xgmac_tx_ctxt_desc_get_cde(struct xgmac_tx_ctxt_desc *p)
 {
 	return p->ctxt_desc_err;
 }
@@ -433,6 +454,7 @@ static u64 xgmac_get_rx_timestamp(struct xgmac_rx_ctxt_desc *p)
 
 static const struct xgmac_desc_ops desc_ops = {
 	.init_tx_desc = xgmac_init_tx_desc,
+	.tx_desc_enable_tse = xgmac_tx_desc_enable_tse,
 	.prepare_tx_desc = xgmac_prepare_tx_desc,
 	.tx_vlanctl_desc = xgmac_tx_vlanctl_desc,
 	.set_tx_owner = xgmac_set_tx_owner,
@@ -444,11 +466,20 @@ static const struct xgmac_desc_ops desc_ops = {
 	.get_tx_len = xgmac_get_tx_len,
 	.tx_enable_tstamp = xgmac_tx_enable_tstamp,
 	.get_tx_timestamp_status = xgmac_get_tx_timestamp_status,
+	.tx_ctxt_desc_set_ctxt = xgmac_tx_ctxt_desc_set_ctxt,
+	.tx_ctxt_desc_set_owner =  xgmac_tx_ctxt_desc_set_owner,
+	.get_tx_ctxt_owner = xgmac_tx_ctxt_desc_get_owner,
+	.tx_ctxt_desc_set_mss = xgmac_tx_ctxt_desc_set_mss,
+	.tx_ctxt_desc_get_mss = xgmac_tx_ctxt_desc_get_mss,
+	.tx_ctxt_desc_set_tcmssv = xgmac_tx_ctxt_desc_set_tcmssv,
+	.tx_ctxt_desc_reset_ostc = xgmac_tx_ctxt_desc_reset_ostc,
 	.tx_ctxt_desc_set_ivlantag = xgmac_tx_ctxt_desc_set_ivlantag,
 	.tx_ctxt_desc_get_ivlantag = xgmac_tx_ctxt_desc_get_ivlantag,
 	.tx_ctxt_desc_set_vlantag = xgmac_tx_ctxt_desc_set_vlantag,
 	.tx_ctxt_desc_get_vlantag = xgmac_tx_ctxt_desc_get_vlantag,
 	.tx_ctxt_set_tstamp = xgmac_tx_ctxt_desc_set_tstamp,
+	.close_tx_ctxt_desc = xgmac_tx_ctxt_desc_close,
+	.get_tx_ctxt_cde = xgmac_tx_ctxt_desc_get_cde,
 	.init_rx_desc = xgmac_init_rx_desc,
 	.get_rx_owner = xgmac_get_rx_owner,
 	.set_rx_owner = xgmac_set_rx_owner,
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.h b/drivers/net/ethernet/samsung/xgmac_desc.h
index 4f20283..d9b80fc 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.h
+++ b/drivers/net/ethernet/samsung/xgmac_desc.h
@@ -167,8 +167,9 @@ struct xgmac_desc_ops {
 	void (*init_tx_desc)(struct xgmac_tx_norm_desc *p);
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
-	void (*tx_enable_tse)(struct xgmac_tx_norm_desc *p, u8 is_tse,
-				u32 hdr_len, u32 payload_len);
+	void (*tx_desc_enable_tse)(struct xgmac_tx_norm_desc *p, u8 is_tse,
+				   u32 total_hdr_len, u32 tcp_hdr_len,
+				   u32 tcp_payload_len);
 
 	/* Assign buffer lengths for descriptor */
 	void (*prepare_tx_desc)(struct xgmac_tx_norm_desc *p, u8 is_fd,
@@ -207,20 +208,26 @@ struct xgmac_desc_ops {
 	int (*get_tx_timestamp_status)(struct xgmac_tx_norm_desc *p);
 
 	/* TX Context Descripto Specific */
-	void (*init_tx_ctxt_desc)(struct xgmac_tx_ctxt_desc *p);
+	void (*tx_ctxt_desc_set_ctxt)(struct xgmac_tx_ctxt_desc *p);
 
 	/* Set the owner of the TX context descriptor */
-	void (*set_tx_ctxt_owner)(struct xgmac_tx_ctxt_desc *p);
+	void (*tx_ctxt_desc_set_owner)(struct xgmac_tx_ctxt_desc *p);
 
 	/* Get the owner of the TX context descriptor */
 	int (*get_tx_ctxt_owner)(struct xgmac_tx_ctxt_desc *p);
 
 	/* Set TX mss */
-	void (*tx_ctxt_desc_setmss)(struct xgmac_tx_ctxt_desc *p, int mss);
+	void (*tx_ctxt_desc_set_mss)(struct xgmac_tx_ctxt_desc *p, u16 mss);
 
 	/* Set TX mss */
 	int (*tx_ctxt_desc_get_mss)(struct xgmac_tx_ctxt_desc *p);
 
+	/* Set TX tcmssv */
+	void (*tx_ctxt_desc_set_tcmssv)(struct xgmac_tx_ctxt_desc *p);
+
+	/* Reset TX ostc */
+	void (*tx_ctxt_desc_reset_ostc)(struct xgmac_tx_ctxt_desc *p);
+
 	/* Set IVLAN information */
 	void (*tx_ctxt_desc_set_ivlantag)(struct xgmac_tx_ctxt_desc *p,
 					int is_ivlanvalid, int ivlan_tag,
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.c b/drivers/net/ethernet/samsung/xgmac_dma.c
index c28d90c..47945a3 100644
--- a/drivers/net/ethernet/samsung/xgmac_dma.c
+++ b/drivers/net/ethernet/samsung/xgmac_dma.c
@@ -348,6 +348,15 @@ static void xgmac_dma_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 	}
 }
 
+static void xgmac_enable_tso(void __iomem *ioaddr, u8 chan_num)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(chan_num));
+	ctrl |= XGMAC_DMA_CHA_TXCTL_TSE_ENABLE;
+	writel(ctrl, ioaddr + XGMAC_DMA_CHA_TXCTL_REG(chan_num));
+}
+
 static const struct xgmac_dma_ops xgmac_dma_ops = {
 	.init = xgmac_dma_init,
 	.cha_init = xgmac_dma_channel_init,
@@ -363,6 +372,7 @@ static const struct xgmac_dma_ops xgmac_dma_ops = {
 	.tx_dma_int_status = xgmac_tx_dma_int_status,
 	.rx_dma_int_status = xgmac_rx_dma_int_status,
 	.rx_watchdog = xgmac_dma_rx_watchdog,
+	.enable_tso = xgmac_enable_tso,
 };
 
 const struct xgmac_dma_ops *xgmac_get_dma_ops(void)
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.h b/drivers/net/ethernet/samsung/xgmac_dma.h
index 002fd18..2e76ae0 100644
--- a/drivers/net/ethernet/samsung/xgmac_dma.h
+++ b/drivers/net/ethernet/samsung/xgmac_dma.h
@@ -42,6 +42,8 @@ struct xgmac_dma_ops {
 			      struct xgmac_extra_stats *x);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
+	/* Enable TSO for each DMA channel */
+	void (*enable_tso)(void __iomem *ioaddr, u8 chan_num);
 };
 
 const struct xgmac_dma_ops *xgmac_get_dma_ops(void);
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index f72a4c1..ef7f55b 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -1185,6 +1185,29 @@ static int xgmac_release(struct net_device *dev)
 
 }
 
+/* Prepare first Tx descriptor for doing TSO operation */
+void xgmac_tso_prepare(struct xgmac_priv_data *priv,
+		       struct xgmac_tx_norm_desc *first_desc,
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
+
+}
+
 /**
  *  xgmac_xmit: Tx entry point of the driver
  *  @skb : the socket buffer
@@ -1202,13 +1225,22 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int tx_rsize = priv->dma_tx_size;
 	struct xgmac_tx_queue *tqueue = priv->txq[txq_index];
 	struct xgmac_tx_norm_desc *tx_desc, *first_desc;
+	struct xgmac_tx_ctxt_desc *ctxt_desc = NULL;
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int no_pagedlen = skb_headlen(skb);
 	int is_jumbo = 0;
+	u16 mss;
+	u32 ctxt_desc_req = 0;
 
 	/* get the TX queue handle */
 	dev_txq = netdev_get_tx_queue(dev, txq_index);
 
+	if (likely(skb_is_gso(skb)
+	    || vlan_tx_tag_present(skb)
+	    || ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
+		 && tqueue->hwts_tx_en)))
+		ctxt_desc_req = 1;
+
 	/* get the spinlock */
 	spin_lock(&tqueue->tx_lock);
 
@@ -1227,18 +1259,36 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_desc = tqueue->dma_tx + entry;
 
 	first_desc = tx_desc;
+	if (ctxt_desc_req)
+		ctxt_desc = (struct xgmac_tx_ctxt_desc *)first_desc;
 
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
+			xgmac_tso_prepare(priv, first_desc, skb);
+		} else {
+			tx_desc->tdes01 = dma_map_single(priv->device,
+					skb->data, no_pagedlen, DMA_TO_DEVICE);
+			if (dma_mapping_error(priv->device, tx_desc->tdes01))
+				pr_err("%s: TX dma mapping failed!!\n"
+						, __func__);
+
+			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
+					no_pagedlen);
+		}
 	}
 
 	for (frag_num = 0; frag_num < nr_frags; frag_num++) {
@@ -1927,6 +1977,7 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 	int ret = 0;
 	struct net_device *ndev = NULL;
 	struct xgmac_priv_data *priv;
+	u8 queue_num;
 
 	ndev = alloc_etherdev_mqs(sizeof(struct xgmac_priv_data),
 				 XGMAC_TX_QUEUES, XGMAC_RX_QUEUES);
@@ -1971,7 +2022,9 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 
 	ndev->netdev_ops = &xgmac_netdev_ops;
 
-	ndev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM;
+	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			    NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_TSO6 |
+			    NETIF_F_GRO;
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 
@@ -1983,6 +2036,13 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 	if (flow_ctrl)
 		priv->flow_ctrl = XGMAC_FLOW_AUTO;	/* RX/TX pause on */
 
+	/* Enable TCP segmentation offload for all DMA channels */
+	if (priv->hw_cap.tcpseg_offload) {
+		XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+			priv->hw->dma->enable_tso(priv->ioaddr, queue_num);
+		}
+	}
+
 	/* Rx Watchdog is available, enable depend on platform data */
 	if (!priv->plat->riwt_off) {
 		priv->use_riwt = 1;
-- 
1.7.10.4
