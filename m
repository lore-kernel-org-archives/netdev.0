From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 05/11] net: calxedaxgmac: update ring buffer tx_head after barriers
Date: Thu, 29 Aug 2013 22:13:42 -0500
Message-ID: <1377832428-18117-5-git-send-email-robherring2@gmail.com>
References: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	bhutchings@solarflare.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:41127 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042Ab3H3DOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:14:04 -0400
Received: by mail-ob0-f171.google.com with SMTP id tb18so1360646obb.2
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 20:14:03 -0700 (PDT)
In-Reply-To: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

Ensure that the descriptor writes are visible before the ring buffer head
is updated. Since writel is a barrier, we can simply update the head after
the writel.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
v2: No change

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
