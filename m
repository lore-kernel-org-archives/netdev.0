From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V2 RE-SEND 4/7] net: sxgbe: add Checksum offload support for
 Samsung sxgbe
Date: Thu, 13 Mar 2014 15:56:02 +0900
Message-ID: <007d01cf3e89$4be479e0$e3ad6da0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ilho215.lee@samsung.com,
	vipul.pandya@samsung.com, 'Joe Perches' <joe@perches.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vipul Pandya <vipul.pandya@samsung.com>

This patch adds TX and RX checksum offload support.

Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Neatening-by: Joe Perches <joe@perches.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe_common.h |    6 +++-
 drivers/net/ethernet/samsung/sxgbe_core.c   |   20 ++++++++++++
 drivers/net/ethernet/samsung/sxgbe_desc.c   |   27 ++++++++++++----
 drivers/net/ethernet/samsung/sxgbe_desc.h   |    6 ++--
 drivers/net/ethernet/samsung/sxgbe_main.c   |   46 ++++++++++++++++++++-------
 5 files changed, 84 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe_common.h
index 21d8ee6..68e8ad4 100644
--- a/drivers/net/ethernet/samsung/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe_common.h
@@ -347,6 +347,10 @@ struct sxgbe_core_ops {
 	void (*set_eee_timer)(void __iomem *ioaddr, const int ls,
 			      const int tw);
 	void (*set_eee_pls)(void __iomem *ioaddr, const int link);
+
+	/* Enable disable checksum offload operations */
+	void (*enable_rx_csum)(void __iomem *ioaddr);
+	void (*disable_rx_csum)(void __iomem *ioaddr);
 };
 
 const struct sxgbe_core_ops *sxgbe_get_core_ops(void);
@@ -462,7 +466,7 @@ struct sxgbe_priv_data {
 	struct net_device *dev;
 	struct device *device;
 	struct sxgbe_ops *hw;/* sxgbe specific ops */
-	int no_csum_insertion;
+	int rxcsum_insertion;
 	spinlock_t lock;
 	spinlock_t stats_lock;
 
diff --git a/drivers/net/ethernet/samsung/sxgbe_core.c b/drivers/net/ethernet/samsung/sxgbe_core.c
index bf93b16..5885fd6 100644
--- a/drivers/net/ethernet/samsung/sxgbe_core.c
+++ b/drivers/net/ethernet/samsung/sxgbe_core.c
@@ -217,6 +217,24 @@ static void  sxgbe_set_eee_timer(void __iomem *ioaddr,
 	writel(value, ioaddr + SXGBE_CORE_LPI_TIMER_CTRL);
 }
 
+static void sxgbe_enable_rx_csum(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+	ctrl |= SXGBE_RX_CSUMOFFLOAD_ENABLE;
+	writel(ctrl, ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+}
+
+static void sxgbe_disable_rx_csum(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+	ctrl &= ~SXGBE_RX_CSUMOFFLOAD_ENABLE;
+	writel(ctrl, ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+}
+
 const struct sxgbe_core_ops core_ops = {
 	.core_init = sxgbe_core_init,
 	.dump_regs = sxgbe_core_dump_regs,
@@ -233,6 +251,8 @@ const struct sxgbe_core_ops core_ops = {
 	.reset_eee_mode = sxgbe_reset_eee_mode,
 	.set_eee_timer = sxgbe_set_eee_timer,
 	.set_eee_pls = sxgbe_set_eee_pls,
+	.enable_rx_csum = sxgbe_enable_rx_csum,
+	.disable_rx_csum = sxgbe_disable_rx_csum,
 };
 
 const struct sxgbe_core_ops *sxgbe_get_core_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe_desc.c b/drivers/net/ethernet/samsung/sxgbe_desc.c
index fa21236..8d9ee61 100644
--- a/drivers/net/ethernet/samsung/sxgbe_desc.c
+++ b/drivers/net/ethernet/samsung/sxgbe_desc.c
@@ -47,6 +47,9 @@ static void sxgbe_prepare_tx_desc(struct sxgbe_tx_norm_desc *p, u8 is_fd,
 
 	p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.total_pkt_len = pkt_len;
 
+	if (cksum)
+		p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.cksum_ctl =
+			cic_full;
 }
 
 /* Set VLAN control information */
@@ -250,31 +253,40 @@ static int sxgbe_get_rx_ld_status(struct sxgbe_rx_norm_desc *p)
 
 
 /* Return the RX status looking at the WB fields */
-static void sxgbe_rx_wbstatus(struct sxgbe_rx_norm_desc *p,
-			struct sxgbe_extra_stats *x)
+static int sxgbe_rx_wbstatus(struct sxgbe_rx_norm_desc *p,
+			     struct sxgbe_extra_stats *x, int *checksum)
 {
+	int status = 0;
 
+	*checksum = CHECKSUM_UNNECESSARY;
 	if (p->rdes23.rx_wb_des23.err_summary) {
 		switch (p->rdes23.rx_wb_des23.err_l2_type) {
 		case RX_GMII_ERR:
+			status = -EINVAL;
 			x->rx_code_gmii_err++;
 			break;
 		case RX_WATCHDOG_ERR:
+			status = -EINVAL;
 			x->rx_watchdog_err++;
 			break;
 		case RX_CRC_ERR:
+			status = -EINVAL;
 			x->rx_crc_err++;
 			break;
 		case RX_GAINT_ERR:
+			status = -EINVAL;
 			x->rx_gaint_pkt_err++;
 			break;
 		case RX_IP_HDR_ERR:
+			*checksum = CHECKSUM_NONE;
 			x->ip_hdr_err++;
 			break;
 		case RX_PAYLOAD_ERR:
+			*checksum = CHECKSUM_NONE;
 			x->ip_payload_err++;
 			break;
 		case RX_OVERFLOW_ERR:
+			status = -EINVAL;
 			x->overflow_error++;
 			break;
 		default:
@@ -366,12 +378,14 @@ static void sxgbe_rx_wbstatus(struct sxgbe_rx_norm_desc *p,
 	if (p->rdes23.rx_wb_des23.vlan_filter_match)
 		x->vlan_filter_match++;
 
-	if (p->rdes23.rx_wb_des23.sa_filter_fail)
+	if (p->rdes23.rx_wb_des23.sa_filter_fail) {
+		status = -EINVAL;
 		x->sa_filter_fail++;
-
-	if (p->rdes23.rx_wb_des23.da_filter_fail)
+	}
+	if (p->rdes23.rx_wb_des23.da_filter_fail) {
+		status = -EINVAL;
 		x->da_filter_fail++;
-
+	}
 	if (p->rdes23.rx_wb_des23.hash_filter_pass)
 		x->hash_filter_pass++;
 
@@ -381,6 +395,7 @@ static void sxgbe_rx_wbstatus(struct sxgbe_rx_norm_desc *p,
 	if (p->rdes23.rx_wb_des23.l4_filter_match)
 		x->l4_filter_match++;
 
+	return status;
 }
 
 /* Get own bit of context descriptor */
diff --git a/drivers/net/ethernet/samsung/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe_desc.h
index 976d5ac..032789c 100644
--- a/drivers/net/ethernet/samsung/sxgbe_desc.h
+++ b/drivers/net/ethernet/samsung/sxgbe_desc.h
@@ -113,7 +113,7 @@ struct sxgbe_rx_norm_desc {
 			/* WB RDES3 */
 			u32 pkt_len:14;
 			u32 rdes3_reserved:1;
-			u32 err_summary:15;
+			u32 err_summary:1;
 			u32 err_l2_type:4;
 			u32 layer34_pkt_type:4;
 			u32 no_coagulation_pkt:1;
@@ -273,8 +273,8 @@ struct sxgbe_desc_ops {
 	int (*get_rx_ld_status)(struct sxgbe_rx_norm_desc *p);
 
 	/* Return the reception status looking at the RDES1 */
-	void (*rx_wbstatus)(struct sxgbe_rx_norm_desc *p,
-				struct sxgbe_extra_stats *x);
+	int (*rx_wbstatus)(struct sxgbe_rx_norm_desc *p,
+			   struct sxgbe_extra_stats *x, int *checksum);
 
 	/* Get own bit */
 	int (*get_rx_ctxt_owner)(struct sxgbe_rx_ctxt_desc *p);
diff --git a/drivers/net/ethernet/samsung/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe_main.c
index cd09cdd..e6b4406 100644
--- a/drivers/net/ethernet/samsung/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe_main.c
@@ -1314,6 +1314,7 @@ void sxgbe_tso_prepare(struct sxgbe_priv_data *priv,
 static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int entry, frag_num;
+	int cksum_flag = 0;
 	struct netdev_queue *dev_txq;
 	unsigned txq_index = skb_get_queue_mapping(skb);
 	struct sxgbe_priv_data *priv = netdev_priv(dev);
@@ -1385,7 +1386,7 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 					   __func__);
 
 			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
-							no_pagedlen);
+							no_pagedlen, cksum_flag);
 		}
 	}
 
@@ -1402,7 +1403,7 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* prepare the descriptor */
 		priv->hw->desc->prepare_tx_desc(tx_desc, 0, len,
-						len);
+						len, cksum_flag);
 		/* memory barrier to flush descriptor */
 		wmb();
 
@@ -1528,6 +1529,8 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
 	unsigned int entry = priv->rxq[qnum]->cur_rx;
 	unsigned int next_entry = 0;
 	unsigned int count = 0;
+	int checksum;
+	int status;
 
 	while (count < limit) {
 		struct sxgbe_rx_norm_desc *p;
@@ -1544,7 +1547,18 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
 		next_entry = (++priv->rxq[qnum]->cur_rx) % rxsize;
 		prefetch(priv->rxq[qnum]->dma_rx + next_entry);
 
-		/*TO DO read the status of the incoming frame */
+		/* Read the status of the incoming frame and also get checksum
+		 * value based on whether it is enabled in SXGBE hardware or
+		 * not.
+		 */
+		status = priv->hw->desc->rx_wbstatus(p, &priv->xstats,
+						     &checksum);
+		if (unlikely(status < 0)) {
+			entry = next_entry;
+			continue;
+		}
+		if (unlikely(!priv->rxcsum_insertion))
+			checksum = CHECKSUM_NONE;
 
 		skb = priv->rxq[qnum]->rx_skbuff[entry];
 
@@ -1558,7 +1572,11 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
 
 		skb_put(skb, frame_len);
 
-		netif_receive_skb(skb);
+		skb->ip_summed = checksum;
+		if (checksum == CHECKSUM_NONE)
+			netif_receive_skb(skb);
+		else
+			napi_gro_receive(&priv->napi, skb);
 
 		entry = next_entry;
 	}
@@ -1789,15 +1807,15 @@ static int sxgbe_set_features(struct net_device *dev,
 {
 	struct sxgbe_priv_data *priv = netdev_priv(dev);
 	netdev_features_t changed = dev->features ^ features;
-	u32 ctrl;
 
 	if (changed & NETIF_F_RXCSUM) {
-		ctrl = readl(priv->ioaddr + SXGBE_CORE_RX_CONFIG_REG);
-		if (features & NETIF_F_RXCSUM)
-			ctrl |= SXGBE_RX_CSUMOFFLOAD_ENABLE;
-		else
-			ctrl &= ~SXGBE_RX_CSUMOFFLOAD_ENABLE;
-		writel(ctrl, priv->ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+		if (features & NETIF_F_RXCSUM) {
+			priv->hw->mac->enable_rx_csum(priv->ioaddr);
+			priv->rxcsum_insertion = true;
+		} else {
+			priv->hw->mac->disable_rx_csum(priv->ioaddr);
+			priv->rxcsum_insertion = false;
+		}
 	}
 
 	return 0;
@@ -2163,6 +2181,12 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
 		}
 	}
 
+	/* Enable Rx checksum offload */
+	if (priv->hw_cap.rx_csum_offload) {
+		priv->hw->mac->enable_rx_csum(priv->ioaddr);
+		priv->rxcsum_insertion = true;
+	}
+
 	/* Rx Watchdog is available, enable depend on platform data */
 	if (!priv->plat->riwt_off) {
 		priv->use_riwt = 1;
-- 
1.7.10.4
