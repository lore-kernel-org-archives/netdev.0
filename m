From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 2/3] net: bcmgenet: cleanup for bcmgenet_xmit_frag()
Date: Mon,  4 Apr 2016 17:10:00 -0700
Message-ID: <1459815001-91703-2-git-send-email-pgynther@google.com>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com,
	Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36443 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbcDEAKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 20:10:22 -0400
Received: by mail-pf0-f177.google.com with SMTP id e128so132996827pfe.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 17:10:21 -0700 (PDT)
In-Reply-To: <1459815001-91703-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add frag_size = skb_frag_size(frag) and use it when needed.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 7f85a84..d77cd6d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1331,6 +1331,7 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct device *kdev = &priv->pdev->dev;
 	struct enet_cb *tx_cb_ptr;
+	unsigned int frag_size;
 	dma_addr_t mapping;
 	int ret;
 
@@ -1338,10 +1339,12 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
 
 	if (unlikely(!tx_cb_ptr))
 		BUG();
+
 	tx_cb_ptr->skb = NULL;
 
-	mapping = skb_frag_dma_map(kdev, frag, 0,
-				   skb_frag_size(frag), DMA_TO_DEVICE);
+	frag_size = skb_frag_size(frag);
+
+	mapping = skb_frag_dma_map(kdev, frag, 0, frag_size, DMA_TO_DEVICE);
 	ret = dma_mapping_error(kdev, mapping);
 	if (ret) {
 		priv->mib.tx_dma_failed++;
@@ -1351,10 +1354,10 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
 	}
 
 	dma_unmap_addr_set(tx_cb_ptr, dma_addr, mapping);
-	dma_unmap_len_set(tx_cb_ptr, dma_len, frag->size);
+	dma_unmap_len_set(tx_cb_ptr, dma_len, frag_size);
 
 	dmadesc_set(priv, tx_cb_ptr->bd_addr, mapping,
-		    (frag->size << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
+		    (frag_size << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
 		    (priv->hw_params->qtag_mask << DMA_TX_QTAG_SHIFT));
 
 	return 0;
-- 
2.8.0.rc3.226.g39d4020
