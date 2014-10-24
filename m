From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: bcmgenet: return number of packets completed in TX reclaim
Date: Fri, 24 Oct 2014 13:02:20 -0700
Message-ID: <1414180942-2132-3-git-send-email-f.fainelli@gmail.com>
References: <1414180942-2132-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64116 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbaJXUCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 16:02:52 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so2008427pdj.24
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 13:02:52 -0700 (PDT)
In-Reply-To: <1414180942-2132-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for reclaiming transmitted buffers in NAPI context,
update __bcmgenet_tx_reclaim() and bcmgenet_tx_reclaim() to return the
number of packets completed per call.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index ee4d5baf09b6..70f2fb366375 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -876,14 +876,14 @@ static inline void bcmgenet_tx_ring_int_disable(struct bcmgenet_priv *priv,
 }
 
 /* Unlocked version of the reclaim routine */
-static void __bcmgenet_tx_reclaim(struct net_device *dev,
-				  struct bcmgenet_tx_ring *ring)
+static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
+					  struct bcmgenet_tx_ring *ring)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	int last_tx_cn, last_c_index, num_tx_bds;
 	struct enet_cb *tx_cb_ptr;
 	struct netdev_queue *txq;
-	unsigned int bds_compl;
+	unsigned int bds_compl, pkts_compl = 0;
 	unsigned int c_index;
 
 	/* Compute how many buffers are transmitted since last xmit call */
@@ -928,6 +928,7 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 		}
 		dev->stats.tx_packets++;
 		ring->free_bds += bds_compl;
+		pkts_compl += bds_compl;
 
 		last_c_index++;
 		last_c_index &= (num_tx_bds - 1);
@@ -936,20 +937,25 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 	if (ring->free_bds > (MAX_SKB_FRAGS + 1))
 		ring->int_disable(priv, ring);
 
-	if (netif_tx_queue_stopped(txq))
+	if (netif_tx_queue_stopped(txq) && pkts_compl)
 		netif_tx_wake_queue(txq);
 
 	ring->c_index = c_index;
+
+	return pkts_compl;
 }
 
-static void bcmgenet_tx_reclaim(struct net_device *dev,
-				struct bcmgenet_tx_ring *ring)
+static unsigned int bcmgenet_tx_reclaim(struct net_device *dev,
+					struct bcmgenet_tx_ring *ring)
 {
 	unsigned long flags;
+	unsigned int pkts_compl;
 
 	spin_lock_irqsave(&ring->lock, flags);
-	__bcmgenet_tx_reclaim(dev, ring);
+	pkts_compl = __bcmgenet_tx_reclaim(dev, ring);
 	spin_unlock_irqrestore(&ring->lock, flags);
+
+	return pkts_compl;
 }
 
 static void bcmgenet_tx_reclaim_all(struct net_device *dev)
-- 
1.9.1
