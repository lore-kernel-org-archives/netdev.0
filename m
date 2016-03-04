From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/7] mlx5: use napi_consume_skb API to get bulk
 free operations
Date: Fri, 04 Mar 2016 14:01:23 +0100
Message-ID: <20160304130123.32651.50039.stgit@firesoul>
References: <20160304130054.32651.51776.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	gerlitz.or@gmail.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbcCDNB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 08:01:28 -0500
In-Reply-To: <20160304130054.32651.51776.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bulk free of SKBs happen transparently by the API call napi_consume_skb().
The napi budget parameter is needed by napi_consume_skb() to detect
if called from netpoll.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9c0e80e64b43..a0708782eb78 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -619,7 +619,7 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev);
 void mlx5e_completion_event(struct mlx5_core_cq *mcq);
 void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
-bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq);
+bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index c34f4f3e9537..996b13a5042f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -336,7 +336,7 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 	return mlx5e_sq_xmit(sq, skb);
 }
 
-bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
+bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 {
 	struct mlx5e_sq *sq;
 	u32 dma_fifo_cc;
@@ -412,7 +412,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 			npkts++;
 			nbytes += wi->num_bytes;
 			sqcc += wi->num_wqebbs;
-			dev_kfree_skb(skb);
+			napi_consume_skb(skb, napi_budget);
 		} while (!last_wqe);
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 4ac8d716dbdd..d244acee63a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -60,7 +60,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	clear_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
 
 	for (i = 0; i < c->num_tc; i++)
-		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq);
+		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq, budget);
 
 	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
 	busy |= work_done == budget;
