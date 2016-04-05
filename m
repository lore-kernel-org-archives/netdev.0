From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2 1/3] net: bcmgenet: cleanup for bcmgenet_xmit()
Date: Tue,  5 Apr 2016 13:05:09 -0700
Message-ID: <1459886711-72949-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35051 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbcDEUFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:05:24 -0400
Received: by mail-pa0-f51.google.com with SMTP id td3so17041293pab.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 13:05:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Readability: Move nr_frags assignment a few lines down in order
   to bundle index -> ring -> txq calculations together.
2. Readability: Add parentheses around nr_frags + 1.
3. Minor fix: Stop the Tx queue and throw the error message only if
   the Tx queue hasn't already been stopped.

Signed-off-by: Petri Gynther <pgynther@google.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index cf6445d..7f85a84 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1447,15 +1447,19 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	else
 		index -= 1;
 
-	nr_frags = skb_shinfo(skb)->nr_frags;
 	ring = &priv->tx_rings[index];
 	txq = netdev_get_tx_queue(dev, ring->queue);
 
+	nr_frags = skb_shinfo(skb)->nr_frags;
+
 	spin_lock_irqsave(&ring->lock, flags);
-	if (ring->free_bds <= nr_frags + 1) {
-		netif_tx_stop_queue(txq);
-		netdev_err(dev, "%s: tx ring %d full when queue %d awake\n",
-			   __func__, index, ring->queue);
+	if (ring->free_bds <= (nr_frags + 1)) {
+		if (!netif_tx_queue_stopped(txq)) {
+			netif_tx_stop_queue(txq);
+			netdev_err(dev,
+				   "%s: tx ring %d full when queue %d awake\n",
+				   __func__, index, ring->queue);
+		}
 		ret = NETDEV_TX_BUSY;
 		goto out;
 	}
-- 
2.8.0.rc3.226.g39d4020
