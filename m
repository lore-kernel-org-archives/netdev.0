From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] bcmgenet tx path
Date: Wed, 16 Mar 2016 07:18:01 -0700
Message-ID: <1458137881.7353.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:33299 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934415AbcCPOSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:18:06 -0400
Received: by mail-qk0-f171.google.com with SMTP id s5so21325372qkd.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:18:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

I was looking at drivers/net/ethernet/broadcom/genet/bcmgenet.c
and found TX completion (__bcmgenet_tx_reclaim()) was freeing skb before
frags were actually dma unmapped.


Are you sure this is OK ? bnx2 and bnx2x actually do the reverse (unmap
all frags before freeing skb)

A second problem is the dma_unmap_single() uses tx_cb_ptr->skb->len for
the length, while it really should be the same thing that was used in
bcmgenet_xmit_single()

skb_len = skb_headlen(skb) < ETH_ZLEN ? ETH_ZLEN : skb_headlen(skb);

So maybe something like :

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d7e01a7..9211b9c7 100644
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
