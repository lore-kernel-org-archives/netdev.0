From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/2] net: bcmgenet: update ring producer index and buffer count in xmit
Date: Fri, 13 Mar 2015 12:11:06 -0700
Message-ID: <1426273867-10874-2-git-send-email-f.fainelli@gmail.com>
References: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42061 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbCMTLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:11:50 -0400
Received: by padfa1 with SMTP id fa1so31615215pad.9
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 12:11:50 -0700 (PDT)
In-Reply-To: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to have both bcmgenet_xmit_single() and
bcmgenet_xmit_frag() perform a free_bds decrement and a prod_index
increment by one. In case one of these functions fails to map a SKB or
fragment for transmit, we will return and exit bcmgenet_xmit() with an
error.

We can therefore safely use our local copy of nr_frags to know by how
much we should decrement the number of free buffers available, and by
how much the producer count must be incremented and do this in the tail
of bcmgenet_xmit().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Acked-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index d3be1aeb7f47..f59427072a9b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1130,11 +1130,6 @@ static int bcmgenet_xmit_single(struct net_device *dev,
 
 	dmadesc_set(priv, tx_cb_ptr->bd_addr, mapping, length_status);
 
-	/* Decrement total BD count and advance our write pointer */
-	ring->free_bds -= 1;
-	ring->prod_index += 1;
-	ring->prod_index &= DMA_P_INDEX_MASK;
-
 	return 0;
 }
 
@@ -1173,11 +1168,6 @@ static int bcmgenet_xmit_frag(struct net_device *dev,
 		    (frag->size << DMA_BUFLENGTH_SHIFT) | dma_desc_flags |
 		    (priv->hw_params->qtag_mask << DMA_TX_QTAG_SHIFT));
 
-
-	ring->free_bds -= 1;
-	ring->prod_index += 1;
-	ring->prod_index &= DMA_P_INDEX_MASK;
-
 	return 0;
 }
 
@@ -1321,9 +1311,11 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_tx_timestamp(skb);
 
-	/* we kept a software copy of how much we should advance the TDMA
-	 * producer index, now write it down to the hardware
-	 */
+	/* Decrement total BD count and advance our write pointer */
+	ring->free_bds -= nr_frags + 1;
+	ring->prod_index += nr_frags + 1;
+	ring->prod_index &= DMA_P_INDEX_MASK;
+
 	bcmgenet_tdma_ring_writel(priv, ring->index,
 				  ring->prod_index, TDMA_PROD_INDEX);
 
-- 
2.1.0
