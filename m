From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 05/11] net: calxedaxgmac: update ring buffer tx_head after barriers
Date: Fri, 30 Aug 2013 16:49:23 -0500
Message-ID: <1377899369-23252-5-git-send-email-robherring2@gmail.com>
References: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:60064 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756786Ab3H3VuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:50:03 -0400
Received: by mail-ob0-f175.google.com with SMTP id xn12so2430392obc.6
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 14:50:01 -0700 (PDT)
In-Reply-To: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

Ensure that the descriptor writes are visible before the ring buffer head
is updated. Since writel is a barrier, we can simply update the head after
the writel.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 64854ad..f630855 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1121,9 +1121,10 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	wmb();
 	desc_set_tx_owner(first, desc_flags | TXDESC_FIRST_SEG);
 
+	writel(1, priv->base + XGMAC_DMA_TX_POLL);
+
 	priv->tx_head = dma_ring_incr(entry, DMA_TX_RING_SZ);
 
-	writel(1, priv->base + XGMAC_DMA_TX_POLL);
 	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
 	    MAX_SKB_FRAGS)
 		netif_stop_queue(dev);
-- 
1.8.1.2
