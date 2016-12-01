From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: Utilize correct struct device for all DMA operations
Date: Wed, 30 Nov 2016 21:15:50 -0800
Message-ID: <1480569350-43535-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
        opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34940 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbcLAFSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 00:18:42 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so1873214pfk.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 21:18:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__bcmgenet_tx_reclaim() is not using the struct device reference when
doing its unmap operation, which made the DMA-API debugging warn about
it. Fix this by always using &priv->pdev->dev throughout the driver,
using an identical device reference for all map/unmap calls.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 4464bc5db934..d7b553020d66 100644
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
-- 
1.9.1
