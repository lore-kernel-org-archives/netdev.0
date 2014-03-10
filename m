From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 3/4] stmmac: fix chained mode
Date: Mon, 10 Mar 2014 13:40:33 +0100
Message-ID: <1394455234-32021-4-git-send-email-peppe.cavallaro@st.com>
References: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:55532 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753370AbaCJNOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 09:14:52 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 06929258
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:09 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D160E1652E
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:09 +0000 (GMT)
In-Reply-To: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix the chain mode that was broken
and generated a panic. This patch reviews the chain/ring
modes now shaing the same structure and taking care
about the pointers and callbacks.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |    2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h      |   20 ++-----
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    9 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   56 +++++++++------------
 4 files changed, 34 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 72d282b..c553f6b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -151,7 +151,7 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 					  sizeof(struct dma_desc)));
 }
 
-const struct stmmac_chain_mode_ops chain_mode_ops = {
+const struct stmmac_mode_ops chain_mode_ops = {
 	.init = stmmac_init_dma_chain,
 	.is_jumbo_frm = stmmac_is_jumbo_frm,
 	.jumbo_frm = stmmac_jumbo_frm,
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 7834a39..74610f3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -419,20 +419,13 @@ struct mii_regs {
 	unsigned int data;	/* MII Data */
 };
 
-struct stmmac_ring_mode_ops {
-	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
-	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
-	void (*refill_desc3) (void *priv, struct dma_desc *p);
-	void (*init_desc3) (struct dma_desc *p);
-	void (*clean_desc3) (void *priv, struct dma_desc *p);
-	int (*set_16kib_bfsize) (int mtu);
-};
-
-struct stmmac_chain_mode_ops {
+struct stmmac_mode_ops {
 	void (*init) (void *des, dma_addr_t phy_addr, unsigned int size,
 		      unsigned int extend_desc);
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum);
+	int (*set_16kib_bfsize)(int mtu);
+	void (*init_desc3)(struct dma_desc *p);
 	void (*refill_desc3) (void *priv, struct dma_desc *p);
 	void (*clean_desc3) (void *priv, struct dma_desc *p);
 };
@@ -441,8 +434,7 @@ struct mac_device_info {
 	const struct stmmac_ops *mac;
 	const struct stmmac_desc_ops *desc;
 	const struct stmmac_dma_ops *dma;
-	const struct stmmac_ring_mode_ops *ring;
-	const struct stmmac_chain_mode_ops *chain;
+	const struct stmmac_mode_ops *mode;
 	const struct stmmac_hwtimestamp *ptp;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
@@ -460,7 +452,7 @@ void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 void stmmac_set_mac(void __iomem *ioaddr, bool enable);
 
 void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
-extern const struct stmmac_ring_mode_ops ring_mode_ops;
-extern const struct stmmac_chain_mode_ops chain_mode_ops;
+extern const struct stmmac_mode_ops ring_mode_ops;
+extern const struct stmmac_mode_ops chain_mode_ops;
 
 #endif /* __COMMON_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index a96c7c2..650a4be 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -100,10 +100,9 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
 
-	if (unlikely(priv->plat->has_gmac))
-		/* Fill DES3 in case of RING mode */
-		if (priv->dma_buf_sz >= BUF_SIZE_8KiB)
-			p->des3 = p->des2 + BUF_SIZE_8KiB;
+	/* Fill DES3 in case of RING mode */
+	if (priv->dma_buf_sz >= BUF_SIZE_8KiB)
+		p->des3 = p->des2 + BUF_SIZE_8KiB;
 }
 
 /* In ring mode we need to fill the desc3 because it is used as buffer */
@@ -126,7 +125,7 @@ static int stmmac_set_16kib_bfsize(int mtu)
 	return ret;
 }
 
-const struct stmmac_ring_mode_ops ring_mode_ops = {
+const struct stmmac_mode_ops ring_mode_ops = {
 	.is_jumbo_frm = stmmac_is_jumbo_frm,
 	.jumbo_frm = stmmac_jumbo_frm,
 	.refill_desc3 = stmmac_refill_desc3,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5365836..8543e1c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -966,9 +966,9 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 
 	p->des2 = priv->rx_skbuff_dma[i];
 
-	if ((priv->mode == STMMAC_RING_MODE) &&
+	if ((priv->hw->mode->init_desc3) &&
 	    (priv->dma_buf_sz == BUF_SIZE_16KiB))
-		priv->hw->ring->init_desc3(p);
+		priv->hw->mode->init_desc3(p);
 
 	return 0;
 }
@@ -999,11 +999,8 @@ static int init_dma_desc_rings(struct net_device *dev)
 	unsigned int bfsize = 0;
 	int ret = -ENOMEM;
 
-	/* Set the max buffer size according to the DESC mode
-	 * and the MTU. Note that RING mode allows 16KiB bsize.
-	 */
-	if (priv->mode == STMMAC_RING_MODE)
-		bfsize = priv->hw->ring->set_16kib_bfsize(dev->mtu);
+	if (priv->hw->mode->set_16kib_bfsize)
+		bfsize = priv->hw->mode->set_16kib_bfsize(dev->mtu);
 
 	if (bfsize < BUF_SIZE_16KiB)
 		bfsize = stmmac_set_bfsize(dev->mtu, priv->dma_buf_sz);
@@ -1044,15 +1041,15 @@ static int init_dma_desc_rings(struct net_device *dev)
 	/* Setup the chained descriptor addresses */
 	if (priv->mode == STMMAC_CHAIN_MODE) {
 		if (priv->extend_desc) {
-			priv->hw->chain->init(priv->dma_erx, priv->dma_rx_phy,
-					      rxsize, 1);
-			priv->hw->chain->init(priv->dma_etx, priv->dma_tx_phy,
-					      txsize, 1);
+			priv->hw->mode->init(priv->dma_erx, priv->dma_rx_phy,
+					     rxsize, 1);
+			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
+					     txsize, 1);
 		} else {
-			priv->hw->chain->init(priv->dma_rx, priv->dma_rx_phy,
-					      rxsize, 0);
-			priv->hw->chain->init(priv->dma_tx, priv->dma_tx_phy,
-					      txsize, 0);
+			priv->hw->mode->init(priv->dma_rx, priv->dma_rx_phy,
+					     rxsize, 0);
+			priv->hw->mode->init(priv->dma_tx, priv->dma_tx_phy,
+					     txsize, 0);
 		}
 	}
 
@@ -1303,7 +1300,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 					 DMA_TO_DEVICE);
 			priv->tx_skbuff_dma[entry] = 0;
 		}
-		priv->hw->ring->clean_desc3(priv, p);
+		priv->hw->mode->clean_desc3(priv, p);
 
 		if (likely(skb != NULL)) {
 			dev_kfree_skb(skb);
@@ -1859,6 +1856,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	struct dma_desc *desc, *first;
 	unsigned int nopaged_len = skb_headlen(skb);
+	unsigned int enh_desc = priv->plat->enh_desc;
 
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
 		if (!netif_queue_stopped(dev)) {
@@ -1886,27 +1884,19 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	first = desc;
 
 	/* To program the descriptors according to the size of the frame */
-	if (priv->mode == STMMAC_RING_MODE) {
-		is_jumbo = priv->hw->ring->is_jumbo_frm(skb->len,
-							priv->plat->enh_desc);
-		if (unlikely(is_jumbo))
-			entry = priv->hw->ring->jumbo_frm(priv, skb,
-							  csum_insertion);
-	} else {
-		is_jumbo = priv->hw->chain->is_jumbo_frm(skb->len,
-							 priv->plat->enh_desc);
-		if (unlikely(is_jumbo))
-			entry = priv->hw->chain->jumbo_frm(priv, skb,
-							   csum_insertion);
-	}
+	if (enh_desc)
+		is_jumbo = priv->hw->mode->is_jumbo_frm(skb->len, enh_desc);
+
 	if (likely(!is_jumbo)) {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
 		priv->tx_skbuff_dma[entry] = desc->des2;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion, priv->mode);
-	} else
+	} else {
 		desc = first;
+		entry = priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
+	}
 
 	for (i = 0; i < nfrags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -2044,7 +2034,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 			p->des2 = priv->rx_skbuff_dma[entry];
 
-			priv->hw->ring->refill_desc3(priv, p);
+			priv->hw->mode->refill_desc3(priv, p);
 
 			if (netif_msg_rx_status(priv))
 				pr_debug("\trefill entry #%d\n", entry);
@@ -2648,11 +2638,11 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 
 	/* To use the chained or ring mode */
 	if (chain_mode) {
-		priv->hw->chain = &chain_mode_ops;
+		priv->hw->mode = &chain_mode_ops;
 		pr_info(" Chain mode enabled\n");
 		priv->mode = STMMAC_CHAIN_MODE;
 	} else {
-		priv->hw->ring = &ring_mode_ops;
+		priv->hw->mode = &ring_mode_ops;
 		pr_info(" Ring mode enabled\n");
 		priv->mode = STMMAC_RING_MODE;
 	}
-- 
1.7.4.4
