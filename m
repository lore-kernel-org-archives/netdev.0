From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 07/10] net/mlx4_en: Poll XDP TX completion queue in RX NAPI
Date: Thu, 15 Jun 2017 14:35:37 +0300
Message-ID: <1497526540-30028-8-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36078 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752311AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having their own NAPIs, XDP TX completion queues get
polled within the corresponding RX NAPI.
This prevents any possible race on TX ring prod/cons indices,
between the context that issues the transmits (RX NAPI) and the
context that handles the completions (was previously done in
a separate NAPI).

This also improves performance, as it decreases the number
of NAPIs running on a CPU, saving the overhead of syncing
and switching between the contexts.

Performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
Single queue no-RSS optimization ON.

XDP_TX packet rate:
-------------------------------------
     | Before    | After     | Gain |
IPv4 | 12.0 Mpps | 13.8 Mpps |  15% |
IPv6 | 12.0 Mpps | 13.8 Mpps |  15% |
-------------------------------------

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     | 25 ++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  8 +++++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 22 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |  5 +++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  7 ++++++-
 5 files changed, 51 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 09dd3776db76..85fe17e4dcfb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -146,16 +146,25 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	if (err)
 		goto free_eq;
 
-	cq->mcq.comp  = cq->type != RX ? mlx4_en_tx_irq : mlx4_en_rx_irq;
 	cq->mcq.event = mlx4_en_cq_event;
 
-	if (cq->type != RX)
+	switch (cq->type) {
+	case TX:
+		cq->mcq.comp = mlx4_en_tx_irq;
 		netif_tx_napi_add(cq->dev, &cq->napi, mlx4_en_poll_tx_cq,
 				  NAPI_POLL_WEIGHT);
-	else
+		napi_enable(&cq->napi);
+		break;
+	case RX:
+		cq->mcq.comp = mlx4_en_rx_irq;
 		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_rx_cq, 64);
-
-	napi_enable(&cq->napi);
+		napi_enable(&cq->napi);
+		break;
+	case TX_XDP:
+		/* nothing regarding napi, it's shared with rx ring */
+		cq->xdp_busy = false;
+		break;
+	}
 
 	return 0;
 
@@ -184,8 +193,10 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
-	napi_disable(&cq->napi);
-	netif_napi_del(&cq->napi);
+	if (cq->type != TX_XDP) {
+		napi_disable(&cq->napi);
+		netif_napi_del(&cq->napi);
+	}
 
 	mlx4_cq_free(priv->mdev->dev, &cq->mcq);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 51ce111b719e..99c02bb4f302 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1679,13 +1679,15 @@ int mlx4_en_start_port(struct net_device *dev)
 			if (t != TX_XDP) {
 				tx_ring->tx_queue = netdev_get_tx_queue(dev, i);
 				tx_ring->recycle_ring = NULL;
+
+				/* Arm CQ for TX completions */
+				mlx4_en_arm_cq(priv, cq);
+
 			} else {
 				mlx4_en_init_recycle_ring(priv, i);
+				/* XDP TX CQ should never be armed */
 			}
 
-			/* Arm CQ for TX completions */
-			mlx4_en_arm_cq(priv, cq);
-
 			/* Set initial ownership of all Tx TXBBs to SW (1) */
 			for (j = 0; j < tx_ring->buf_size; j += STAMP_STRIDE)
 				*((u32 *)(tx_ring->buf + j)) = 0xffffffff;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 747e4d7d7693..e5fb89505a13 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -880,8 +880,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	rcu_read_unlock();
 
 	if (likely(polled)) {
-		if (doorbell_pending)
-			mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
+		if (doorbell_pending) {
+			priv->tx_cq[TX_XDP][cq_ring]->xdp_busy = true;
+			mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq_ring]);
+		}
 
 		mlx4_cq_set_ci(&cq->mcq);
 		wmb(); /* ensure HW sees CQ consumer before we post new buffers */
@@ -912,16 +914,30 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	struct mlx4_en_cq *cq = container_of(napi, struct mlx4_en_cq, napi);
 	struct net_device *dev = cq->dev;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_cq *xdp_tx_cq = NULL;
+	bool clean_complete = true;
 	int done;
 
+	if (priv->tx_ring_num[TX_XDP]) {
+		xdp_tx_cq = priv->tx_cq[TX_XDP][cq->ring];
+		if (xdp_tx_cq->xdp_busy) {
+			clean_complete = mlx4_en_process_tx_cq(dev, xdp_tx_cq,
+							       budget);
+			xdp_tx_cq->xdp_busy = !clean_complete;
+		}
+	}
+
 	done = mlx4_en_process_rx_cq(dev, cq, budget);
 
 	/* If we used up all the quota - we're probably not done yet... */
-	if (done == budget) {
+	if (done == budget || !clean_complete) {
 		const struct cpumask *aff;
 		struct irq_data *idata;
 		int cpu_curr;
 
+		/* in case we got here because of !clean_complete */
+		done = budget;
+
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
 
 		cpu_curr = smp_processor_id();
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 01bb43879221..500442c60342 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -395,8 +395,8 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	return cnt;
 }
 
-static bool mlx4_en_process_tx_cq(struct net_device *dev,
-				  struct mlx4_en_cq *cq, int napi_budget)
+bool mlx4_en_process_tx_cq(struct net_device *dev,
+			   struct mlx4_en_cq *cq, int napi_budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
@@ -1176,6 +1176,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 
 tx_drop_count:
 	rx_ring->xdp_tx_full++;
+	*doorbell_pending = true;
 tx_drop:
 	return NETDEV_TX_BUSY;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index c52edb717add..bde3bc869b70 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -358,7 +358,10 @@ struct mlx4_en_cq {
 	struct mlx4_hwq_resources wqres;
 	int                     ring;
 	struct net_device      *dev;
-	struct napi_struct	napi;
+	union {
+		struct napi_struct napi;
+		bool               xdp_busy;
+	};
 	int size;
 	int buf_size;
 	int vector;
@@ -720,6 +723,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
 			  int budget);
 int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
 int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget);
+bool mlx4_en_process_tx_cq(struct net_device *dev,
+			   struct mlx4_en_cq *cq, int napi_budget);
 u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			 struct mlx4_en_tx_ring *ring,
 			 int index, u64 timestamp,
-- 
1.8.3.1
