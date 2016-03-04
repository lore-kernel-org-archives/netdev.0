From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 4/7] mlx5: use napi_alloc_skb API to get SKB bulk
 allocations
Date: Fri, 04 Mar 2016 14:01:53 +0100
Message-ID: <20160304130153.32651.26827.stgit@firesoul>
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
Received: from mx1.redhat.com ([209.132.183.28]:37617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbcCDNCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 08:02:00 -0500
In-Reply-To: <20160304130054.32651.51776.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Activate the bulk alloc API, simply by changing mlx5 from using
netdev_alloc_skb() to using napi_alloc_skb().

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |    9 +++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a0708782eb78..38ed89b7145d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -621,7 +621,7 @@ void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
-bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
+bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi);
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
 void mlx5e_update_stats(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 519a07f253f9..5ef9772ff708 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -42,12 +42,13 @@ static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 }
 
 static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
-				     struct mlx5e_rx_wqe *wqe, u16 ix)
+				     struct mlx5e_rx_wqe *wqe, u16 ix,
+				     struct napi_struct *napi)
 {
 	struct sk_buff *skb;
 	dma_addr_t dma_addr;
 
-	skb = netdev_alloc_skb(rq->netdev, rq->wqe_sz);
+	skb = napi_alloc_skb(napi, rq->wqe_sz);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
@@ -76,7 +77,7 @@ err_free_skb:
 	return -ENOMEM;
 }
 
-bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
+bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi)
 {
 	struct mlx5_wq_ll *wq = &rq->wq;
 
@@ -86,7 +87,7 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 	while (!mlx5_wq_ll_is_full(wq)) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
 
-		if (unlikely(mlx5e_alloc_rx_wqe(rq, wqe, wq->head)))
+		if (unlikely(mlx5e_alloc_rx_wqe(rq, wqe, wq->head, napi)))
 			break;
 
 		mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index d244acee63a5..8fd07c8087e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -64,7 +64,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 
 	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
 	busy |= work_done == budget;
-	busy |= mlx5e_post_rx_wqes(&c->rq);
+	busy |= mlx5e_post_rx_wqes(&c->rq, napi);
 
 	if (busy)
 		return budget;
