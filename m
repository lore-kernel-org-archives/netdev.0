From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 1/2] net: bcmgenet: fix dev->stats.tx_bytes accounting
Date: Wed, 23 Mar 2016 15:09:32 -0700
Message-ID: <3ED195EB-4396-4C56-895F-FA070BBE58B0@gmail.com>
References: <1458763289-95167-1-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, edumazet@google.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35963 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756621AbcCWWJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:09:42 -0400
Received: by mail-pf0-f170.google.com with SMTP id u190so40707325pfb.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:09:42 -0700 (PDT)
In-Reply-To: <1458763289-95167-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 23, 2016 1:01:28 PM PDT, Petri Gynther <pgynther@google.com> wrote:
>1. Add bytes_compl local variable to collect transmitted bytes
>   - dev->stats updates can then be moved outside the while-loop
>   - bytes_compl is also needed for future BQL support
>2. When bcmgenet device uses Tx checksum offload, each transmitted
>   skb has an extra 64-byte header prepended to it. This needs to
>   be deducted when counting transmitted bytes.
>3. skb->len covers the entire length of skb, whether it is linear or
>   fragmented. Thus, when we clean the fragments, do not increase
>   transmitted bytes.
>
>Signed-off-by: Petri Gynther <pgynther@google.com>

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

>---
> drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 ++++++----
> 1 file changed, 6 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>index 6746fd0..9990582 100644
>--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>@@ -1171,6 +1171,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct
>net_device *dev,
> 	struct enet_cb *tx_cb_ptr;
> 	struct netdev_queue *txq;
> 	unsigned int pkts_compl = 0;
>+	unsigned int bytes_compl = 0;
> 	unsigned int c_index;
> 	unsigned int txbds_ready;
> 	unsigned int txbds_processed = 0;
>@@ -1193,16 +1194,14 @@ static unsigned int
>__bcmgenet_tx_reclaim(struct net_device *dev,
> 		tx_cb_ptr = &priv->tx_cbs[ring->clean_ptr];
> 		if (tx_cb_ptr->skb) {
> 			pkts_compl++;
>-			dev->stats.tx_packets++;
>-			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
>+			bytes_compl += tx_cb_ptr->skb->len -
>+				       (priv->desc_64b_en ? 64 : 0);
> 			dma_unmap_single(&dev->dev,
> 					 dma_unmap_addr(tx_cb_ptr, dma_addr),
> 					 dma_unmap_len(tx_cb_ptr, dma_len),
> 					 DMA_TO_DEVICE);
> 			bcmgenet_free_cb(tx_cb_ptr);
> 		} else if (dma_unmap_addr(tx_cb_ptr, dma_addr)) {
>-			dev->stats.tx_bytes +=
>-				dma_unmap_len(tx_cb_ptr, dma_len);
> 			dma_unmap_page(&dev->dev,
> 				       dma_unmap_addr(tx_cb_ptr, dma_addr),
> 				       dma_unmap_len(tx_cb_ptr, dma_len),
>@@ -1220,6 +1219,9 @@ static unsigned int __bcmgenet_tx_reclaim(struct
>net_device *dev,
> 	ring->free_bds += txbds_processed;
> 	ring->c_index = (ring->c_index + txbds_processed) & DMA_C_INDEX_MASK;
> 
>+	dev->stats.tx_packets += pkts_compl;
>+	dev->stats.tx_bytes += bytes_compl;
>+
> 	if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
> 		txq = netdev_get_tx_queue(dev, ring->queue);
> 		if (netif_tx_queue_stopped(txq))


-- 
Florian
