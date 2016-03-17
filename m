From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: bcmgenet: fix dma api length mismatch
Date: Thu, 17 Mar 2016 11:57:06 -0700
Message-ID: <1458241026.7353.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458137881.7353.9.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56EAE2A8.5000206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35833 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031188AbcCQS5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 14:57:09 -0400
Received: by mail-pf0-f176.google.com with SMTP id n5so132302512pfn.2
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 11:57:09 -0700 (PDT)
In-Reply-To: <56EAE2A8.5000206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When un-mapping skb->data in __bcmgenet_tx_reclaim(),
we must use the length that was used in original dma_map_single(),
instead of skb->len that might be bigger (includes the frags)

We simply can store skb_len into tx_cb_ptr->dma_len and use it
at unmap time.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d7e01a7..6746fd0 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1197,7 +1197,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
 			dma_unmap_single(&dev->dev,
 					 dma_unmap_addr(tx_cb_ptr, dma_addr),
-					 tx_cb_ptr->skb->len,
+					 dma_unmap_len(tx_cb_ptr, dma_len),
 					 DMA_TO_DEVICE);
 			bcmgenet_free_cb(tx_cb_ptr);
 		} else if (dma_unmap_addr(tx_cb_ptr, dma_addr)) {
@@ -1308,7 +1308,7 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 	}
 
 	dma_unmap_addr_set(tx_cb_ptr, dma_addr, mapping);
-	dma_unmap_len_set(tx_cb_ptr, dma_len, skb->len);
+	dma_unmap_len_set(tx_cb_ptr, dma_len, skb_len);
 	length_status = (skb_len << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
 			(priv->hw_params->qtag_mask << DMA_TX_QTAG_SHIFT) |
 			DMA_TX_APPEND_CRC;
