From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 4/7] net: xgmac: add Checksum offload support for Samsung xgmac
Date: Wed, 05 Mar 2014 20:28:25 +0900
Message-ID: <007e01cf3866$05db1fe0$11915fa0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vipul.pandya@samsung.com,
	ilho215.lee@samsung.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58294 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbaCEL22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 06:28:28 -0500
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul.pandya@samsung.com>

This patch adds TX and RX checksum offload support.

Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/xgmac_common.h |    6 +++-
 drivers/net/ethernet/samsung/xgmac_core.c   |   20 ++++++++++++
 drivers/net/ethernet/samsung/xgmac_desc.c   |   29 +++++++++++++----
 drivers/net/ethernet/samsung/xgmac_desc.h   |    8 ++---
 drivers/net/ethernet/samsung/xgmac_main.c   |   46 ++++++++++++++++++++-------
 5 files changed, 86 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_common.h b/drivers/net/ethernet/samsung/xgmac_common.h
index 6b7f1de..349cddc 100644
--- a/drivers/net/ethernet/samsung/xgmac_common.h
+++ b/drivers/net/ethernet/samsung/xgmac_common.h
@@ -351,6 +351,10 @@ struct xgmac_core_ops {
 	void (*set_eee_timer)(void __iomem *ioaddr, const int ls,
 			const int tw);
 	void (*set_eee_pls)(void __iomem *ioaddr, const int link);
+
+	/* Enable disable checksum offload operations */
+	void (*enable_rx_csum)(void __iomem *ioaddr);
+	void (*disable_rx_csum)(void __iomem *ioaddr);
 };
 
 const struct xgmac_core_ops *xgmac_get_core_ops(void);
@@ -466,7 +470,7 @@ struct xgmac_priv_data {
 	struct net_device *dev;
 	struct device *device;
 	struct xgmac_ops *hw;/* xgmac specific ops */
-	int no_csum_insertion;
+	int rxcsum_insertion;
 	spinlock_t lock;
 	spinlock_t stats_lock;
 
diff --git a/drivers/net/ethernet/samsung/xgmac_core.c b/drivers/net/ethernet/samsung/xgmac_core.c
index ed475fa..43d093c 100644
--- a/drivers/net/ethernet/samsung/xgmac_core.c
+++ b/drivers/net/ethernet/samsung/xgmac_core.c
@@ -217,6 +217,24 @@ static void  xgmac_set_eee_timer(void __iomem *ioaddr,
 	writel(value, ioaddr + XGMAC_CORE_LPI_TIMER_CTRL);
 }
 
+static void xgmac_enable_rx_csum(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+	ctrl |= XGMAC_RX_CSUMOFFLOAD_ENABLE;
+	writel(ctrl, ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+}
+
+static void xgmac_disable_rx_csum(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+	ctrl &= ~XGMAC_RX_CSUMOFFLOAD_ENABLE;
+	writel(ctrl, ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+}
+
 const struct xgmac_core_ops core_ops = {
 	.core_init = xgmac_core_init,
 	.dump_regs = xgmac_core_dump_regs,
@@ -233,6 +251,8 @@ const struct xgmac_core_ops core_ops = {
 	.reset_eee_mode = xgmac_reset_eee_mode,
 	.set_eee_timer = xgmac_set_eee_timer,
 	.set_eee_pls = xgmac_set_eee_pls,
+	.enable_rx_csum = xgmac_enable_rx_csum,
+	.disable_rx_csum = xgmac_disable_rx_csum,
 };
 
 const struct xgmac_core_ops *xgmac_get_core_ops(void)
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.c b/drivers/net/ethernet/samsung/xgmac_desc.c
index 51b7e71..c5417de 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.c
+++ b/drivers/net/ethernet/samsung/xgmac_desc.c
@@ -37,13 +37,16 @@ static void xgmac_tx_desc_enable_tse(struct xgmac_tx_norm_desc *p, u8 is_tse,
 
 /* Assign buffer lengths for descriptor */
 static void xgmac_prepare_tx_desc(struct xgmac_tx_norm_desc *p, u8 is_fd,
-				int buf1_len, int pkt_len)
+			int buf1_len, int pkt_len, int cksum)
 {
 	p->tdes23.tx_rd_des23.first_desc = is_fd;
 	p->tdes23.tx_rd_des23.buf1_size = buf1_len;
 
 	p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.total_pkt_len = pkt_len;
 
+	if (cksum)
+		p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.cksum_ctl =
+								cic_full;
 }
 
 /* Set VLAN control information */
@@ -249,31 +252,40 @@ static int xgmac_get_rx_ld_status(struct xgmac_rx_norm_desc *p)
 
 
 /* Return the RX status looking at the WB fields */
-static void xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
-			struct xgmac_extra_stats *x)
+static int xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
+			     struct xgmac_extra_stats *x, int *checksum)
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
@@ -366,12 +378,14 @@ static void xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
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
 
@@ -381,6 +395,7 @@ static void xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
 	if (p->rdes23.rx_wb_des23.l4_filter_match)
 		x->l4_filter_match++;
 
+	return status;
 }
 
 /* Get own bit of context descriptor */
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.h b/drivers/net/ethernet/samsung/xgmac_desc.h
index d9b80fc..028b505 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.h
+++ b/drivers/net/ethernet/samsung/xgmac_desc.h
@@ -113,7 +113,7 @@ struct xgmac_rx_norm_desc {
 			/* WB RDES3 */
 			u32 pkt_len:14;
 			u32 rdes3_reserved:1;
-			u32 err_summary:15;
+			u32 err_summary:1;
 			u32 err_l2_type:4;
 			u32 layer34_pkt_type:4;
 			u32 no_coagulation_pkt:1;
@@ -173,7 +173,7 @@ struct xgmac_desc_ops {
 
 	/* Assign buffer lengths for descriptor */
 	void (*prepare_tx_desc)(struct xgmac_tx_norm_desc *p, u8 is_fd,
-				 int buf1_len, int pkt_len);
+				 int buf1_len, int pkt_len, int cksum);
 
 	/* Set VLAN control information */
 	void (*tx_vlanctl_desc)(struct xgmac_tx_norm_desc *p, int vlan_ctl);
@@ -273,8 +273,8 @@ struct xgmac_desc_ops {
 	int (*get_rx_ld_status)(struct xgmac_rx_norm_desc *p);
 
 	/* Return the reception status looking at the RDES1 */
-	void (*rx_wbstatus)(struct xgmac_rx_norm_desc *p,
-				struct xgmac_extra_stats *x);
+	int (*rx_wbstatus)(struct xgmac_rx_norm_desc *p,
+			   struct xgmac_extra_stats *x, int *checksum);
 
 	/* Get own bit */
 	int (*get_rx_ctxt_owner)(struct xgmac_rx_ctxt_desc *p);
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index 6d14c81..d1f746a 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -1332,6 +1332,7 @@ void xgmac_tso_prepare(struct xgmac_priv_data *priv,
 static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int entry, frag_num;
+	int cksum_flag = 0;
 	struct netdev_queue *dev_txq;
 	unsigned txq_index = skb_get_queue_mapping(skb);
 	struct xgmac_priv_data *priv = netdev_priv(dev);
@@ -1403,7 +1404,7 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 						, __func__);
 
 			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
-					no_pagedlen);
+					no_pagedlen, cksum_flag);
 		}
 	}
 
@@ -1420,7 +1421,7 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* prepare the descriptor */
 		priv->hw->desc->prepare_tx_desc(tx_desc, 0, len,
-						len);
+						len, cksum_flag);
 		/* memory barrier to flush descriptor */
 		wmb();
 
@@ -1545,6 +1546,8 @@ static int xgmac_rx(struct xgmac_priv_data *priv, int limit)
 	unsigned int entry = priv->rxq[qnum]->cur_rx;
 	unsigned int next_entry = 0;
 	unsigned int count = 0;
+	int checksum;
+	int status;
 
 	while (count < limit) {
 		struct xgmac_rx_norm_desc *p;
@@ -1561,7 +1564,18 @@ static int xgmac_rx(struct xgmac_priv_data *priv, int limit)
 		next_entry = (++priv->rxq[qnum]->cur_rx) % rxsize;
 		prefetch(priv->rxq[qnum]->dma_rx + next_entry);
 
-		/*TO DO read the status of the incoming frame */
+		/* Read the status of the incoming frame and also get checksum
+		 * value based on whether it is enabled in XGMAC hardware or
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
 
@@ -1577,7 +1591,11 @@ static int xgmac_rx(struct xgmac_priv_data *priv, int limit)
 
 		skb_put(skb, frame_len);
 
-		netif_receive_skb(skb);
+		skb->ip_summed = checksum;
+		if (checksum == CHECKSUM_NONE)
+			netif_receive_skb(skb);
+		else
+			napi_gro_receive(&priv->napi, skb);
 
 		entry = next_entry;
 	}
@@ -1808,15 +1826,15 @@ static int xgmac_set_features(struct net_device *dev,
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 	netdev_features_t changed = dev->features ^ features;
-	u32 ctrl;
 
 	if (changed & NETIF_F_RXCSUM) {
-		ctrl = readl(priv->ioaddr + XGMAC_CORE_RX_CONFIG_REG);
-		if (features & NETIF_F_RXCSUM)
-			ctrl |= XGMAC_RX_CSUMOFFLOAD_ENABLE;
-		else
-			ctrl &= ~XGMAC_RX_CSUMOFFLOAD_ENABLE;
-		writel(ctrl, priv->ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+		if (features & NETIF_F_RXCSUM) {
+			priv->hw->mac->enable_rx_csum(priv->ioaddr);
+			priv->rxcsum_insertion = true;
+		} else {
+			priv->hw->mac->disable_rx_csum(priv->ioaddr);
+			priv->rxcsum_insertion = false;
+		}
 	}
 
 	return 0;
@@ -2178,6 +2196,12 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
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
