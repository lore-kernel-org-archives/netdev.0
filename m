From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V8 5/7] net: sxgbe: add Checksum offload support for Samsung
 sxgbe
Date: Thu, 20 Mar 2014 10:26:11 -0700
Message-ID: <013201cf4461$82a8a2c0$87f9e840$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vipul Pandya <vipul.pandya@samsung.com>

This patch adds TX and RX checksum offload support.

Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Neatening-by: Joe Perches <joe@perches.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h |    5 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c   |   20 +++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h   |    6 +--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c   |   46 ++++++++++++++++-----
 4 files changed, 63 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
index 5f1d02c..f06d439 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
@@ -337,6 +337,10 @@ struct sxgbe_core_ops {
 	void (*set_eee_timer)(void __iomem *ioaddr, const int ls,
 			      const int tw);
 	void (*set_eee_pls)(void __iomem *ioaddr, const int link);
+
+	/* Enable disable checksum offload operations */
+	void (*enable_rx_csum)(void __iomem *ioaddr);
+	void (*disable_rx_csum)(void __iomem *ioaddr);
 };
 
 const struct sxgbe_core_ops *sxgbe_get_core_ops(void);
@@ -449,6 +453,7 @@ struct sxgbe_priv_data {
 	struct sxgbe_ops *hw;	/* sxgbe specific ops */
 	int no_csum_insertion;
 	int irq;
+	int rxcsum_insertion;
 	spinlock_t stats_lock;	/* lock for tx/rx statatics */
 
 	struct phy_device *phydev;
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
index bf93b16..5885fd6 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
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
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
index 547edf3..3c0b5a8 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
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
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index d105b2c..b845322 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1255,6 +1255,7 @@ void sxgbe_tso_prepare(struct sxgbe_priv_data *priv,
 static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int entry, frag_num;
+	int cksum_flag = 0;
 	struct netdev_queue *dev_txq;
 	unsigned txq_index = skb_get_queue_mapping(skb);
 	struct sxgbe_priv_data *priv = netdev_priv(dev);
@@ -1335,7 +1336,7 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 					   __func__);
 
 			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
-							no_pagedlen);
+							no_pagedlen, cksum_flag);
 		}
 	}
 
@@ -1353,7 +1354,7 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* prepare the descriptor */
 		priv->hw->desc->prepare_tx_desc(tx_desc, 0, len,
-						len);
+						len, cksum_flag);
 		/* memory barrier to flush descriptor */
 		wmb();
 
@@ -1474,6 +1475,8 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
 	unsigned int entry = priv->rxq[qnum]->cur_rx;
 	unsigned int next_entry = 0;
 	unsigned int count = 0;
+	int checksum;
+	int status;
 
 	while (count < limit) {
 		struct sxgbe_rx_norm_desc *p;
@@ -1490,7 +1493,18 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
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
 
@@ -1504,7 +1518,11 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
 
 		skb_put(skb, frame_len);
 
-		netif_receive_skb(skb);
+		skb->ip_summed = checksum;
+		if (checksum == CHECKSUM_NONE)
+			netif_receive_skb(skb);
+		else
+			napi_gro_receive(&priv->napi, skb);
 
 		entry = next_entry;
 	}
@@ -1750,15 +1768,15 @@ static int sxgbe_set_features(struct net_device *dev,
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
@@ -2121,6 +2139,12 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
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
