From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 2/3] net: mvneta: Clean mvneta_tx() sk_buff handling
Date: Thu, 10 Apr 2014 19:58:01 -0300
Message-ID: <1397170682-19138-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42473 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759191AbaDJW6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 18:58:46 -0400
In-Reply-To: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework mvneta_tx() so that the code that performs the final handling
before a sk_buff is transmitted is done only if the numbers of fragments
processed if positive.

This is preparation work to introduce a software TSO routine.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b0db2c4..e5bd3ca 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1584,7 +1584,6 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 	u16 txq_id = skb_get_queue_mapping(skb);
 	struct mvneta_tx_queue *txq = &pp->txqs[txq_id];
 	struct mvneta_tx_desc *tx_desc;
-	struct netdev_queue *nq;
 	int frags = 0;
 	u32 tx_cmd;
 
@@ -1592,7 +1591,6 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 
 	frags = skb_shinfo(skb)->nr_frags + 1;
-	nq    = netdev_get_tx_queue(dev, txq_id);
 
 	/* Get a descriptor for the first part of the packet */
 	tx_desc = mvneta_txq_next_desc_get(txq);
@@ -1635,15 +1633,16 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	txq->count += frags;
-	mvneta_txq_pend_desc_add(pp, txq, frags);
-
-	if (txq->size - txq->count < MAX_SKB_FRAGS + 1)
-		netif_tx_stop_queue(nq);
-
 out:
 	if (frags > 0) {
 		struct mvneta_pcpu_stats *stats = this_cpu_ptr(pp->stats);
+		struct netdev_queue *nq = netdev_get_tx_queue(dev, txq_id);
+
+		txq->count += frags;
+		mvneta_txq_pend_desc_add(pp, txq, frags);
+
+		if (txq->size - txq->count < MAX_SKB_FRAGS + 1)
+			netif_tx_stop_queue(nq);
 
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
-- 
1.9.1
