From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 1/9] stmmac: add tx_skbuff_dma to save descriptors used by PTP
Date: Thu,  7 Mar 2013 11:50:11 +0100
Message-ID: <1362653419-1047-2-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-us.st.com ([167.4.1.35]:56663 "EHLO beta.dmz-us.st.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932455Ab3CGLrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:47:08 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rayagond Kokatanur <rayagond@vayavyalabs.com>

This patch adds a new pointer variable called "tx_skbuff_dma" to private
data structure. This variable will holds the physical address of packet
to be transmitted & same will be used to free/unmap the memory once the
corresponding packet is transmitted by device.

Prior to this patch the descriptor buffer pointer(ie des2) itself was
being used for freeing/unmapping the buffer memory. But in case PTP v1
with normal descriptor the field(des2) will be overwritten by device
with timestamp value, hence driver will loose the buffer pointer to be
freed/unmapped.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |    3 +++
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    3 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   21 ++++++++++++++++-----
 4 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 0668659..ad3d75f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -47,6 +47,7 @@ unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 	desc->des2 = dma_map_single(priv->device, skb->data,
 				    bmax, DMA_TO_DEVICE);
+	priv->tx_skbuff_dma[entry] = desc->des2;
 	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum);
 
 	while (len != 0) {
@@ -57,6 +58,7 @@ unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = dma_map_single(priv->device,
 						    (skb->data + bmax * i),
 						    bmax, DMA_TO_DEVICE);
+			priv->tx_skbuff_dma[entry] = desc->des2;
 			priv->hw->desc->prepare_tx_desc(desc, 0, bmax,
 							csum);
 			priv->hw->desc->set_tx_owner(desc);
@@ -67,6 +69,7 @@ unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = dma_map_single(priv->device,
 						    (skb->data + bmax * i), len,
 						    DMA_TO_DEVICE);
+			priv->tx_skbuff_dma[entry] = desc->des2;
 			priv->hw->desc->prepare_tx_desc(desc, 0, len,
 							csum);
 			priv->hw->desc->set_tx_owner(desc);
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 4b785e1..839e349 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -48,6 +48,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    bmax, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax,
 						csum);
@@ -57,6 +58,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des2 = dma_map_single(priv->device, skb->data + bmax,
 					    len, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum);
 		wmb();
@@ -65,6 +67,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum);
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index b05df89..013a7d5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -37,6 +37,7 @@ struct stmmac_priv {
 	struct dma_desc *dma_tx ____cacheline_aligned;
 	dma_addr_t dma_tx_phy;
 	struct sk_buff **tx_skbuff;
+	dma_addr_t *tx_skbuff_dma;
 	unsigned int cur_tx;
 	unsigned int dirty_tx;
 	unsigned int dma_tx_size;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 39c6c55..260af93 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -540,6 +540,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 						  sizeof(struct dma_desc),
 						  &priv->dma_rx_phy,
 						  GFP_KERNEL);
+	priv->tx_skbuff_dma = kmalloc_array(txsize, sizeof(dma_addr_t),
+					    GFP_KERNEL);
 	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
 	priv->dma_tx =
@@ -591,6 +593,7 @@ static void init_dma_desc_rings(struct net_device *dev)
 
 	/* TX INITIALIZATION */
 	for (i = 0; i < txsize; i++) {
+		priv->tx_skbuff_dma[i] = 0;
 		priv->tx_skbuff[i] = NULL;
 		priv->dma_tx[i].des2 = 0;
 	}
@@ -638,12 +641,14 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 	for (i = 0; i < priv->dma_tx_size; i++) {
 		if (priv->tx_skbuff[i] != NULL) {
 			struct dma_desc *p = priv->dma_tx + i;
-			if (p->des2)
-				dma_unmap_single(priv->device, p->des2,
+			if (priv->tx_skbuff_dma[i])
+				dma_unmap_single(priv->device,
+						 priv->tx_skbuff_dma[i],
 						 priv->hw->desc->get_tx_len(p),
 						 DMA_TO_DEVICE);
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
+			priv->tx_skbuff_dma[i] = 0;
 		}
 	}
 }
@@ -664,6 +669,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 			  priv->dma_rx, priv->dma_rx_phy);
 	kfree(priv->rx_skbuff_dma);
 	kfree(priv->rx_skbuff);
+	kfree(priv->tx_skbuff_dma);
 	kfree(priv->tx_skbuff);
 }
 
@@ -730,10 +736,13 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		TX_DBG("%s: curr %d, dirty %d\n", __func__,
 			priv->cur_tx, priv->dirty_tx);
 
-		if (likely(p->des2))
-			dma_unmap_single(priv->device, p->des2,
+		if (likely(priv->tx_skbuff_dma[entry])) {
+			dma_unmap_single(priv->device,
+					 priv->tx_skbuff_dma[entry],
 					 priv->hw->desc->get_tx_len(p),
 					 DMA_TO_DEVICE);
+			priv->tx_skbuff_dma[entry] = 0;
+		}
 		priv->hw->ring->clean_desc3(p);
 
 		if (likely(skb != NULL)) {
@@ -1249,7 +1258,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		desc = priv->dma_tx + entry;
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
-					nopaged_len, DMA_TO_DEVICE);
+					    nopaged_len, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion);
 	}
@@ -1264,6 +1274,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		TX_DBG("\t[entry %d] segment len: %d\n", entry, len);
 		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
 					      DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		priv->tx_skbuff[entry] = NULL;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
 		wmb();
-- 
1.7.4.4
