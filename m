From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/2] net: bcmgenet: add support for xmit_more
Date: Fri, 13 Mar 2015 12:11:07 -0700
Message-ID: <1426273867-10874-3-git-send-email-f.fainelli@gmail.com>
References: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:46313 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbbCMTLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:11:52 -0400
Received: by pdev10 with SMTP id v10so30858356pde.13
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 12:11:52 -0700 (PDT)
In-Reply-To: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delay the update of the TDMA producer index unless this is the last SKB
in a batch, or the queue is already stopped. Move the check for whether
the queue should be stopped before the xmit_more check to avoid locking
the transmit queue in case there was a SKB submitted which has xmit_more
set.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f59427072a9b..c9212e147fe9 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1316,12 +1316,13 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	ring->prod_index += nr_frags + 1;
 	ring->prod_index &= DMA_P_INDEX_MASK;
 
-	bcmgenet_tdma_ring_writel(priv, ring->index,
-				  ring->prod_index, TDMA_PROD_INDEX);
-
 	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
 		netif_tx_stop_queue(txq);
 
+	if (!skb->xmit_more || netif_xmit_stopped(txq))
+		/* Packets are ready, update producer index */
+		bcmgenet_tdma_ring_writel(priv, ring->index,
+					  ring->prod_index, TDMA_PROD_INDEX);
 out:
 	spin_unlock_irqrestore(&ring->lock, flags);
 
-- 
2.1.0
