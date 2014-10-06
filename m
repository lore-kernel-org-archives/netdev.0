From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 07/14] net/mlx4_en: Avoid false sharing in mlx4_en_en_process_tx_cq()
Date: Mon,  6 Oct 2014 09:15:56 +0300
Message-ID: <1412576163-7224-8-git-send-email-amirv@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:57150 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751252AbaJFGQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 02:16:35 -0400
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mlx4_en_process_tx_cq() carefully fetches and writes ring->last_nr_txbb
and ring->cons only one time to avoid false sharing

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 9328e6e..63e1f24 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -387,6 +387,8 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	u64 timestamp = 0;
 	int done = 0;
 	int budget = priv->tx_work_limit;
+	u32 last_nr_txbb;
+	u32 ring_cons;
 
 	if (!priv->port_up)
 		return true;
@@ -394,7 +396,9 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	prefetchw(&ring->tx_queue->dql.limit);
 	index = cons_index & size_mask;
 	cqe = mlx4_en_get_cqe(buf, index, priv->cqe_size) + factor;
-	ring_index = ring->cons & size_mask;
+	last_nr_txbb = ACCESS_ONCE(ring->last_nr_txbb);
+	ring_cons = ACCESS_ONCE(ring->cons);
+	ring_index = ring_cons & size_mask;
 	stamp_index = ring_index;
 
 	/* Process all completed CQEs */
@@ -419,19 +423,19 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 		new_index = be16_to_cpu(cqe->wqe_index) & size_mask;
 
 		do {
-			txbbs_skipped += ring->last_nr_txbb;
-			ring_index = (ring_index + ring->last_nr_txbb) & size_mask;
+			txbbs_skipped += last_nr_txbb;
+			ring_index = (ring_index + last_nr_txbb) & size_mask;
 			if (ring->tx_info[ring_index].ts_requested)
 				timestamp = mlx4_en_get_cqe_ts(cqe);
 
 			/* free next descriptor */
-			ring->last_nr_txbb = mlx4_en_free_tx_desc(
+			last_nr_txbb = mlx4_en_free_tx_desc(
 					priv, ring, ring_index,
-					!!((ring->cons + txbbs_skipped) &
+					!!((ring_cons + txbbs_skipped) &
 					ring->size), timestamp);
 
 			mlx4_en_stamp_wqe(priv, ring, stamp_index,
-					  !!((ring->cons + txbbs_stamp) &
+					  !!((ring_cons + txbbs_stamp) &
 						ring->size));
 			stamp_index = ring_index;
 			txbbs_stamp = txbbs_skipped;
@@ -452,7 +456,11 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	mcq->cons_index = cons_index;
 	mlx4_cq_set_ci(mcq);
 	wmb();
-	ring->cons += txbbs_skipped;
+
+	/* we want to dirty this cache line once */
+	ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
+	ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
+
 	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
 
 	/*
-- 
1.8.3.1
