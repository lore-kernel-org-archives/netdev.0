From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 11/11] net: calxedaxgmac: fix xgmac_xmit DMA mapping error handling
Date: Fri, 30 Aug 2013 16:49:29 -0500
Message-ID: <1377899369-23252-11-git-send-email-robherring2@gmail.com>
References: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:52273 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126Ab3H3VuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:50:09 -0400
Received: by mail-ob0-f172.google.com with SMTP id er7so2465175obc.3
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 14:50:09 -0700 (PDT)
In-Reply-To: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

On a DMA mapping error in xgmac_xmit, we should simply free the skb and
return NETDEV_TX_OK rather than -EIO. In the case of errors in mapping
frags, we need to undo everything that has been setup.

Reported-by: Andreas Herrmann <andreas.herrmann@calxeda.com>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index cd5010b..78d6d6b 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -466,6 +466,13 @@ static inline void desc_set_tx_owner(struct xgmac_dma_desc *p, u32 flags)
 	p->flags = cpu_to_le32(tmpflags);
 }
 
+static inline void desc_clear_tx_owner(struct xgmac_dma_desc *p)
+{
+	u32 tmpflags = le32_to_cpu(p->flags);
+	tmpflags &= TXDESC_END_RING;
+	p->flags = cpu_to_le32(tmpflags);
+}
+
 static inline int desc_get_tx_ls(struct xgmac_dma_desc *p)
 {
 	return le32_to_cpu(p->flags) & TXDESC_LAST_SEG;
@@ -1100,7 +1107,7 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	paddr = dma_map_single(priv->device, skb->data, len, DMA_TO_DEVICE);
 	if (dma_mapping_error(priv->device, paddr)) {
 		dev_kfree_skb(skb);
-		return -EIO;
+		return NETDEV_TX_OK;
 	}
 	priv->tx_skbuff[entry] = skb;
 	desc_set_buf_addr_and_size(desc, paddr, len);
@@ -1112,10 +1119,8 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		paddr = skb_frag_dma_map(priv->device, frag, 0, len,
 					 DMA_TO_DEVICE);
-		if (dma_mapping_error(priv->device, paddr)) {
-			dev_kfree_skb(skb);
-			return -EIO;
-		}
+		if (dma_mapping_error(priv->device, paddr))
+			goto dma_err;
 
 		entry = dma_ring_incr(entry, DMA_TX_RING_SZ);
 		desc = priv->dma_tx + entry;
@@ -1151,6 +1156,22 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_start_queue(dev);
 	}
 	return NETDEV_TX_OK;
+
+dma_err:
+	entry = priv->tx_head;
+	for ( ; i > 0; i--) {
+		entry = dma_ring_incr(entry, DMA_TX_RING_SZ);
+		desc = priv->dma_tx + entry;
+		priv->tx_skbuff[entry] = NULL;
+		dma_unmap_page(priv->device, desc_get_buf_addr(desc),
+			       desc_get_buf_len(desc), DMA_TO_DEVICE);
+		desc_clear_tx_owner(desc);
+	}
+	desc = first;
+	dma_unmap_single(priv->device, desc_get_buf_addr(desc),
+			 desc_get_buf_len(desc), DMA_TO_DEVICE);
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 static int xgmac_rx(struct xgmac_priv *priv, int limit)
-- 
1.8.1.2
