From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 04/11] net: calxedaxgmac: fix possible skb free before tx complete
Date: Fri, 30 Aug 2013 16:49:22 -0500
Message-ID: <1377899369-23252-4-git-send-email-robherring2@gmail.com>
References: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:48334 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778Ab3H3VuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:50:01 -0400
Received: by mail-ob0-f171.google.com with SMTP id tb18so2416360obb.2
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 14:50:00 -0700 (PDT)
In-Reply-To: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

The TX completion code may have freed an skb before the entire sg list
was transmitted. The DMA unmap calls for the fragments could also get
skipped. Now set the skb pointer on every entry in the ring, not just
the head of the sg list. We then use the FS (first segment) bit in the
descriptors to determine skb head vs. fragment.

This also fixes similar bug in xgmac_free_tx_skbufs where clean-up of
a sg list that wraps at the end of the ring buffer would not get
unmapped.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 55 ++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index df7e3e2..64854ad 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -470,6 +470,11 @@ static inline int desc_get_tx_ls(struct xgmac_dma_desc *p)
 	return le32_to_cpu(p->flags) & TXDESC_LAST_SEG;
 }
 
+static inline int desc_get_tx_fs(struct xgmac_dma_desc *p)
+{
+	return le32_to_cpu(p->flags) & TXDESC_FIRST_SEG;
+}
+
 static inline u32 desc_get_buf_addr(struct xgmac_dma_desc *p)
 {
 	return le32_to_cpu(p->buf1_addr);
@@ -796,7 +801,7 @@ static void xgmac_free_rx_skbufs(struct xgmac_priv *priv)
 
 static void xgmac_free_tx_skbufs(struct xgmac_priv *priv)
 {
-	int i, f;
+	int i;
 	struct xgmac_dma_desc *p;
 
 	if (!priv->tx_skbuff)
@@ -807,16 +812,15 @@ static void xgmac_free_tx_skbufs(struct xgmac_priv *priv)
 			continue;
 
 		p = priv->dma_tx + i;
-		dma_unmap_single(priv->device, desc_get_buf_addr(p),
-				 desc_get_buf_len(p), DMA_TO_DEVICE);
-
-		for (f = 0; f < skb_shinfo(priv->tx_skbuff[i])->nr_frags; f++) {
-			p = priv->dma_tx + i++;
+		if (desc_get_tx_fs(p))
+			dma_unmap_single(priv->device, desc_get_buf_addr(p),
+					 desc_get_buf_len(p), DMA_TO_DEVICE);
+		else
 			dma_unmap_page(priv->device, desc_get_buf_addr(p),
 				       desc_get_buf_len(p), DMA_TO_DEVICE);
-		}
 
-		dev_kfree_skb_any(priv->tx_skbuff[i]);
+		if (desc_get_tx_ls(p))
+			dev_kfree_skb_any(priv->tx_skbuff[i]);
 		priv->tx_skbuff[i] = NULL;
 	}
 }
@@ -853,8 +857,6 @@ static void xgmac_free_dma_desc_rings(struct xgmac_priv *priv)
  */
 static void xgmac_tx_complete(struct xgmac_priv *priv)
 {
-	int i;
-
 	while (dma_ring_cnt(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ)) {
 		unsigned int entry = priv->tx_tail;
 		struct sk_buff *skb = priv->tx_skbuff[entry];
@@ -864,33 +866,24 @@ static void xgmac_tx_complete(struct xgmac_priv *priv)
 		if (desc_get_owner(p))
 			break;
 
-		/* Verify tx error by looking at the last segment */
-		if (desc_get_tx_ls(p))
-			desc_get_tx_status(priv, p);
-
 		netdev_dbg(priv->dev, "tx ring: curr %d, dirty %d\n",
 			priv->tx_head, priv->tx_tail);
 
-		dma_unmap_single(priv->device, desc_get_buf_addr(p),
-				 desc_get_buf_len(p), DMA_TO_DEVICE);
-
-		priv->tx_skbuff[entry] = NULL;
-		priv->tx_tail = dma_ring_incr(entry, DMA_TX_RING_SZ);
-
-		if (!skb) {
-			continue;
-		}
-
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			entry = priv->tx_tail = dma_ring_incr(priv->tx_tail,
-							      DMA_TX_RING_SZ);
-			p = priv->dma_tx + priv->tx_tail;
-
+		if (desc_get_tx_fs(p))
+			dma_unmap_single(priv->device, desc_get_buf_addr(p),
+					 desc_get_buf_len(p), DMA_TO_DEVICE);
+		else
 			dma_unmap_page(priv->device, desc_get_buf_addr(p),
 				       desc_get_buf_len(p), DMA_TO_DEVICE);
+
+		/* Check tx error on the last segment */
+		if (desc_get_tx_ls(p)) {
+			desc_get_tx_status(priv, p);
+			dev_kfree_skb(skb);
 		}
 
-		dev_kfree_skb(skb);
+		priv->tx_skbuff[entry] = NULL;
+		priv->tx_tail = dma_ring_incr(entry, DMA_TX_RING_SZ);
 	}
 
 	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) >
@@ -1110,7 +1103,7 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		entry = dma_ring_incr(entry, DMA_TX_RING_SZ);
 		desc = priv->dma_tx + entry;
-		priv->tx_skbuff[entry] = NULL;
+		priv->tx_skbuff[entry] = skb;
 
 		desc_set_buf_addr_and_size(desc, paddr, len);
 		if (i < (nfrags - 1))
-- 
1.8.1.2
