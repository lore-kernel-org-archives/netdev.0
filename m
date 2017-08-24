From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: Be drop monitor friendly
Date: Thu, 24 Aug 2017 15:56:29 -0700
Message-ID: <20170824225629.27850-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, edumazet@gmail.com,
        pgynther@google.com, jaedon.shin@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38685 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753456AbdHXW4g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:56:36 -0400
Received: by mail-wm0-f66.google.com with SMTP id z132so850947wmg.5
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 15:56:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 3 spots where we call dev_kfree_skb() but we are actually
just doing a normal SKB consumption: __bcmgenet_tx_reclaim() for normal
TX reclamation, bcmgenet_alloc_rx_buffers() during the initial RX ring
setup and bcmgenet_free_rx_buffers() during RX ring cleanup.

Fixes: d6707bec5986 ("net: bcmgenet: rewrite bcmgenet_rx_refill()")
Fixes: f48bed16a756 ("net: bcmgenet: Free skb after last Tx frag")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David, I tagged these two commits, but this can actually go back
to when the driver was first merged. Let me know if you would want
me to provide -stable backports against other trees.

Thanks!

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index a981c4ee9d72..fea3f9a5fb2d 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1360,7 +1360,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 		if (skb) {
 			pkts_compl++;
 			bytes_compl += GENET_CB(skb)->bytes_sent;
-			dev_kfree_skb_any(skb);
+			dev_consume_skb_any(skb);
 		}
 
 		txbds_processed++;
@@ -1875,7 +1875,7 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv,
 		cb = ring->cbs + i;
 		skb = bcmgenet_rx_refill(priv, cb);
 		if (skb)
-			dev_kfree_skb_any(skb);
+			dev_consume_skb_any(skb);
 		if (!cb->skb)
 			return -ENOMEM;
 	}
@@ -1894,7 +1894,7 @@ static void bcmgenet_free_rx_buffers(struct bcmgenet_priv *priv)
 
 		skb = bcmgenet_free_rx_cb(&priv->pdev->dev, cb);
 		if (skb)
-			dev_kfree_skb_any(skb);
+			dev_consume_skb_any(skb);
 	}
 }
 
-- 
2.9.3
