From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 5/8 (v2)] stmmac: add tx_skbuff_dma to save descriptors used by PTP
Date: Tue, 26 Mar 2013 15:43:09 +0100
Message-ID: <1364308992-27929-6-git-send-email-peppe.cavallaro@st.com>
References: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Cc: rayagond@vayavyalabs.com, richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:49326 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934493Ab3CZOo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:44:57 -0400
In-Reply-To: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
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
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |    3 +++
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    3 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   19 +++++++++++++++----
 4 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 688c3f4..63b6031 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -47,6 +47,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 	desc->des2 = dma_map_single(priv->device, skb->data,
 				    bmax, DMA_TO_DEVICE);
+	priv->tx_skbuff_dma[entry] = desc->des2;
 	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE);
 
 	while (len != 0) {
@@ -57,6 +58,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = dma_map_single(priv->device,
 						    (skb->data + bmax * i),
 						    bmax, DMA_TO_DEVICE);
+			priv->tx_skbuff_dma[entry] = desc->des2;
 			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
@@ -67,6 +69,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = dma_map_single(priv->device,
 						    (skb->data + bmax * i), len,
 						    DMA_TO_DEVICE);
+			priv->tx_skbuff_dma[entry] = desc->des2;
 			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 							STMMAC_CHAIN_MODE);
 			priv->hw->desc->set_tx_owner(desc);
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 8a5e661..43fc699 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -48,6 +48,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    bmax, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
 						STMMAC_RING_MODE);
@@ -57,6 +58,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 
 		desc->des2 = dma_map_single(priv->device, skb->data + bmax,
 					    len, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 						STMMAC_RING_MODE);
@@ -66,6 +68,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    nopaged_len, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
 						STMMAC_RING_MODE);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 182a838..5176cae 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -38,6 +38,7 @@ struct stmmac_priv {
 	struct dma_extended_desc *dma_etx;	/* Extended TX descriptor */
 	dma_addr_t dma_tx_phy;
 	struct sk_buff **tx_skbuff;
+	dma_addr_t *tx_skbuff_dma;
 	unsigned int cur_tx;
 	unsigned int dirty_tx;
 	unsigned int dma_tx_size;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ac166be..180eed7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -661,6 +661,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 					    GFP_KERNEL);
 	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
+	priv->tx_skbuff_dma = kmalloc_array(txsize, sizeof(dma_addr_t),
+					GFP_KERNEL);
 	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
 	if (netif_msg_drv(priv))
@@ -710,6 +712,7 @@ static void init_dma_desc_rings(struct net_device *dev)
 		else
 			p = priv->dma_tx + i;
 		p->des2 = 0;
+		priv->tx_skbuff_dma[i] = 0;
 		priv->tx_skbuff[i] = NULL;
 	}
 
@@ -748,12 +751,14 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 			else
 				p = priv->dma_tx + i;
 
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
@@ -783,6 +788,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 	}
 	kfree(priv->rx_skbuff_dma);
 	kfree(priv->rx_skbuff);
+	kfree(priv->tx_skbuff_dma);
 	kfree(priv->tx_skbuff);
 }
 
@@ -854,10 +860,13 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
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
 		if (priv->mode == STMMAC_RING_MODE)
 			priv->hw->ring->clean_desc3(p);
 
@@ -1423,6 +1432,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (likely(!is_jumbo)) {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					nopaged_len, DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion, priv->mode);
 	} else
@@ -1441,6 +1451,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		TX_DBG("\t[entry %d] segment len: %d\n", entry, len);
 		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
 					      DMA_TO_DEVICE);
+		priv->tx_skbuff_dma[entry] = desc->des2;
 		priv->tx_skbuff[entry] = NULL;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
 						priv->mode);
-- 
1.7.4.4
