From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 15/17] net/mlx5e: Use kernel's mechanism to avoid missing NAPIs
Date: Sun,  3 Sep 2017 07:21:15 +0300
Message-ID: <20170903042117.28923-16-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60146 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751528AbdICEWQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:16 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

We used a channel state bit MLX5E_CHANNEL_NAPI_SCHED to make
sure no NAPI is missed when a channel's napi_schedule() is called
for completion events of the different channel's resources/rings
while NAPI is currently running.
Now, as similar mechanism is implemented in kernel,
("39e6c8208d7b net: solve a NAPI race"),
we obsolete our own implementation and rely on the return value
of napi_complete_done().

This patch removes a redundant overhead of atomic bit operations.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  5 -----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 10 +---------
 3 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9c0c07ffe557..7c046ae8b18e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -570,10 +570,6 @@ struct mlx5e_rq {
 	struct mlx5_core_mkey  umr_mkey;
 } ____cacheline_aligned_in_smp;
 
-enum channel_flags {
-	MLX5E_CHANNEL_NAPI_SCHED = 1,
-};
-
 struct mlx5e_channel {
 	/* data path */
 	struct mlx5e_rq            rq;
@@ -585,7 +581,6 @@ struct mlx5e_channel {
 	struct net_device         *netdev;
 	__be32                     mkey_be;
 	u8                         num_tc;
-	unsigned long              flags;
 
 	/* control */
 	struct mlx5e_priv         *priv;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2da2ea222aaa..b2f689ec0d72 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3697,7 +3697,6 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 
 		set_bit(MLX5E_RQ_STATE_ENABLED, &c->rq.state);
 		/* napi_schedule in case we have missed anything */
-		set_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
 		napi_schedule(&c->napi);
 
 		if (old_prog)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 439ba1f2ffbc..92d9aa1cddd6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -40,8 +40,6 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	int work_done;
 	int i;
 
-	clear_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
-
 	for (i = 0; i < c->num_tc; i++)
 		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq, budget);
 
@@ -56,13 +54,8 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	if (busy)
 		return budget;
 
-	napi_complete_done(napi, work_done);
-
-	/* avoid losing completion event during/after polling cqs */
-	if (test_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags)) {
-		napi_schedule(napi);
+	if (unlikely(!napi_complete_done(napi, work_done)))
 		return work_done;
-	}
 
 	for (i = 0; i < c->num_tc; i++)
 		mlx5e_cq_arm(&c->sq[i].cq);
@@ -81,7 +74,6 @@ void mlx5e_completion_event(struct mlx5_core_cq *mcq)
 	struct mlx5e_cq *cq = container_of(mcq, struct mlx5e_cq, mcq);
 
 	cq->event_ctr++;
-	set_bit(MLX5E_CHANNEL_NAPI_SCHED, &cq->channel->flags);
 	napi_schedule(cq->napi);
 }
 
-- 
2.13.0
