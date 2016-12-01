From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: bcmgenet: Utilize correct struct device for all DMA operations
Date: Thu,  1 Dec 2016 09:45:45 -0800
Message-ID: <1480614345-5827-1-git-send-email-florian.fainelli@broadcom.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
        opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33981 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758762AbcLARsv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:48:51 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so12245888pfb.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 09:48:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

__bcmgenet_tx_reclaim() and bcmgenet_free_rx_buffers() are not using the
same struct device during unmap that was used for the map operation,
which makes DMA-API debugging warn about it. Fix this by always using
&priv->pdev->dev throughout the driver, using an identical device
reference for all map/unmap calls.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 4464bc5db934..a4e60e56c14f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1172,6 +1172,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 					  struct bcmgenet_tx_ring *ring)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct device *kdev = &priv->pdev->dev;
 	struct enet_cb *tx_cb_ptr;
 	struct netdev_queue *txq;
 	unsigned int pkts_compl = 0;
@@ -1199,13 +1200,13 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 		if (tx_cb_ptr->skb) {
 			pkts_compl++;
 			bytes_compl += GENET_CB(tx_cb_ptr->skb)->bytes_sent;
-			dma_unmap_single(&dev->dev,
+			dma_unmap_single(kdev,
 					 dma_unmap_addr(tx_cb_ptr, dma_addr),
 					 dma_unmap_len(tx_cb_ptr, dma_len),
 					 DMA_TO_DEVICE);
 			bcmgenet_free_cb(tx_cb_ptr);
 		} else if (dma_unmap_addr(tx_cb_ptr, dma_addr)) {
-			dma_unmap_page(&dev->dev,
+			dma_unmap_page(kdev,
 				       dma_unmap_addr(tx_cb_ptr, dma_addr),
 				       dma_unmap_len(tx_cb_ptr, dma_len),
 				       DMA_TO_DEVICE);
@@ -1775,6 +1776,7 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv,
 
 static void bcmgenet_free_rx_buffers(struct bcmgenet_priv *priv)
 {
+	struct device *kdev = &priv->pdev->dev;
 	struct enet_cb *cb;
 	int i;
 
@@ -1782,7 +1784,7 @@ static void bcmgenet_free_rx_buffers(struct bcmgenet_priv *priv)
 		cb = &priv->rx_cbs[i];
 
 		if (dma_unmap_addr(cb, dma_addr)) {
-			dma_unmap_single(&priv->dev->dev,
+			dma_unmap_single(kdev,
 					 dma_unmap_addr(cb, dma_addr),
 					 priv->rx_buf_len, DMA_FROM_DEVICE);
 			dma_unmap_addr_set(cb, dma_addr, 0);
-- 
1.9.1
