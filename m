From: Bruce Liu <damuzi000@gmail.com>
Subject: [PATCH] [PATCH net-next v2] net: stmmac: fix NULL pointer dereference in stmmac_get_tx_hwtstamp
Date: Fri, 17 Jan 2014 23:47:59 +0800
Message-ID: <1389973679-2755-1-git-send-email-damuzi000@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruce Liu <damuzi000@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When timestamping is enabled, stmmac_tx_clean will call
stmmac_get_tx_hwtstamp to get tx TS.
But the skb can be NULL because the last of its tx_skbuff is NULL
if this packet frame is filled in more than one descriptors.

To fix the issue, change the code:
- Store TX skb to the tx_skbuff[] of frame's last segment.
- Check skb is not NULL in stmmac_get_tx_hwtstamp.

Signed-off-by: Bruce Liu <damuzi000@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |    3 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   35 +++++++++++----------
 3 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index d234ab5..72d282b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -51,6 +51,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
 
 	while (len != 0) {
+		priv->tx_skbuff[entry] = NULL;
 		entry = (++priv->cur_tx) % txsize;
 		desc = priv->dma_tx + entry;
 
@@ -62,7 +63,6 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
-			priv->tx_skbuff[entry] = NULL;
 			len -= bmax;
 			i++;
 		} else {
@@ -73,7 +73,6 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
-			priv->tx_skbuff[entry] = NULL;
 			len = 0;
 		}
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 1ef9d8a..a96c7c2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -58,6 +58,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
 						STMMAC_RING_MODE);
 		wmb();
+		priv->tx_skbuff[entry] = NULL;
 		entry = (++priv->cur_tx) % txsize;
 
 		if (priv->extend_desc)
@@ -73,7 +74,6 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 						STMMAC_RING_MODE);
 		wmb();
 		priv->hw->desc->set_tx_owner(desc);
-		priv->tx_skbuff[entry] = NULL;
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 797b56a..5cf52ad 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -332,7 +332,7 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 		return;
 
 	/* exit if skb doesn't support hw tstamp */
-	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
+	if (likely(!skb || !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
 		return;
 
 	if (priv->adv_ts)
@@ -1161,21 +1161,24 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 	int i;
 
 	for (i = 0; i < priv->dma_tx_size; i++) {
-		if (priv->tx_skbuff[i] != NULL) {
-			struct dma_desc *p;
-			if (priv->extend_desc)
-				p = &((priv->dma_etx + i)->basic);
-			else
-				p = priv->dma_tx + i;
+		struct dma_desc *p;
 
-			if (priv->tx_skbuff_dma[i])
-				dma_unmap_single(priv->device,
-						 priv->tx_skbuff_dma[i],
-						 priv->hw->desc->get_tx_len(p),
-						 DMA_TO_DEVICE);
+		if (priv->extend_desc)
+			p = &((priv->dma_etx + i)->basic);
+		else
+			p = priv->dma_tx + i;
+
+		if (priv->tx_skbuff_dma[i]) {
+			dma_unmap_single(priv->device,
+					 priv->tx_skbuff_dma[i],
+					 priv->hw->desc->get_tx_len(p),
+					 DMA_TO_DEVICE);
+			priv->tx_skbuff_dma[i] = 0;
+		}
+
+		if (priv->tx_skbuff[i] != NULL) {
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
-			priv->tx_skbuff_dma[i] = 0;
 		}
 	}
 }
@@ -1844,8 +1847,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	first = desc;
 
-	priv->tx_skbuff[entry] = skb;
-
 	/* To program the descriptors according to the size of the frame */
 	if (priv->mode == STMMAC_RING_MODE) {
 		is_jumbo = priv->hw->ring->is_jumbo_frm(skb->len,
@@ -1873,6 +1874,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 		int len = skb_frag_size(frag);
 
+		priv->tx_skbuff[entry] = NULL;
 		entry = (++priv->cur_tx) % txsize;
 		if (priv->extend_desc)
 			desc = (struct dma_desc *)(priv->dma_etx + entry);
@@ -1882,7 +1884,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
 					      DMA_TO_DEVICE);
 		priv->tx_skbuff_dma[entry] = desc->des2;
-		priv->tx_skbuff[entry] = NULL;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
 						priv->mode);
 		wmb();
@@ -1890,6 +1891,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		wmb();
 	}
 
+	priv->tx_skbuff[entry] = skb;
+
 	/* Finalize the latest segment. */
 	priv->hw->desc->close_tx_desc(desc);
 
-- 
1.7.9.5
