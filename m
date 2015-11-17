From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 7/9] mlx5: support napi_complete_done()
Date: Tue, 17 Nov 2015 05:57:02 -0800
Message-ID: <1447768624-14962-8-git-send-email-edumazet@google.com>
References: <1447768624-14962-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34255 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbbKQN5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:57:50 -0500
Received: by padhx2 with SMTP id hx2so10028017pad.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 05:57:50 -0800 (PST)
In-Reply-To: <1447768624-14962-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A NAPI poll handler should return number of RX packets processed,
instead of 0 / budget.

This allows proper busy poll accounting through LINUX_MIB_BUSYPOLLRXPACKETS
SNMP counter.

napi_complete_done() allows /sys/class/net/ethX/gro_flush_timeout
to be used for finer GRO aggregation control.

Tested:

Enabled busy polling, and checked TcpExtBusyPollRxPackets counter is increasing.

echo 70 >/proc/sys/net/core/busy_read
nstat >/dev/null
netperf -H target -t TCP_RR >/dev/null
nstat | grep TcpExtBusyPollRxPackets
TcpExtBusyPollRxPackets         490958             0.0

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 14 ++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 11 ++++++-----
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f2ae62dd8c09..633b22a17b77 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -558,7 +558,7 @@ void mlx5e_completion_event(struct mlx5_core_cq *mcq);
 void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq);
-bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
+int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 54800c61a563..fe752f8e24b9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -216,16 +216,16 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 				       be16_to_cpu(cqe->vlan_info));
 }
 
-bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
+int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
-	int i;
+	int work_done;
 
 	/* avoid accessing cq (dma coherent memory) if not needed */
 	if (!test_and_clear_bit(MLX5E_CQ_HAS_CQES, &cq->flags))
-		return false;
+		return 0;
 
-	for (i = 0; i < budget; i++) {
+	for (work_done = 0; work_done < budget; work_done++) {
 		struct mlx5e_rx_wqe *wqe;
 		struct mlx5_cqe64 *cqe;
 		struct sk_buff *skb;
@@ -271,10 +271,8 @@ wq_ll_pop:
 	/* ensure cq space is freed before enabling more cqes */
 	wmb();
 
-	if (i == budget) {
+	if (work_done == budget)
 		set_bit(MLX5E_CQ_HAS_CQES, &cq->flags);
-		return true;
-	}
 
-	return false;
+	return work_done;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 2c7cb6755d1d..4ac8d716dbdd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -54,6 +54,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	struct mlx5e_channel *c = container_of(napi, struct mlx5e_channel,
 					       napi);
 	bool busy = false;
+	int work_done;
 	int i;
 
 	clear_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
@@ -61,26 +62,26 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	for (i = 0; i < c->num_tc; i++)
 		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq);
 
-	busy |= mlx5e_poll_rx_cq(&c->rq.cq, budget);
-
+	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
+	busy |= work_done == budget;
 	busy |= mlx5e_post_rx_wqes(&c->rq);
 
 	if (busy)
 		return budget;
 
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 
 	/* avoid losing completion event during/after polling cqs */
 	if (test_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags)) {
 		napi_schedule(napi);
-		return 0;
+		return work_done;
 	}
 
 	for (i = 0; i < c->num_tc; i++)
 		mlx5e_cq_arm(&c->sq[i].cq);
 	mlx5e_cq_arm(&c->rq.cq);
 
-	return 0;
+	return work_done;
 }
 
 void mlx5e_completion_event(struct mlx5_core_cq *mcq)
-- 
2.6.0.rc2.230.g3dd15c0
