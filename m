From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 05/11] mlx5: use napi_*_skb APIs to get bulk alloc
 and free
Date: Tue, 02 Feb 2016 22:12:23 +0100
Message-ID: <20160202211206.16315.47208.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934339AbcBBVMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:12:25 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bulk alloc and free of SKBs happen transparently by the API calls
napi_alloc_skb() and napi_consume_skb().

The mlx5 driver have an extra high benefit of these changes,
because it already have a loop refilling its RX ring queue.  I
considered if the alloc API should be allowed to request larger
allocation, knowing the size of objects it need to refill.  For
now, just use the default bulk size hidden inside napi_alloc_skb().

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |    9 +++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    4 ++--
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9ea49a893323..3e531fae9ed3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -591,9 +591,9 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev);
 void mlx5e_completion_event(struct mlx5_core_cq *mcq);
 void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
-bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq);
+bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
-bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
+bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi);
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
 void mlx5e_update_stats(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index dd959d929aad..e923f4adc0f8 100644
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
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 2c3fba0fff54..06a29c8f5712 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -326,7 +326,7 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 	return mlx5e_sq_xmit(sq, skb);
 }
 
-bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
+bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 {
 	struct mlx5e_sq *sq;
 	u32 dma_fifo_cc;
@@ -402,7 +402,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 			npkts++;
 			nbytes += wi->num_bytes;
 			sqcc += wi->num_wqebbs;
-			dev_kfree_skb(skb);
+			napi_consume_skb(skb, napi_budget);
 		} while (!last_wqe);
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 4ac8d716dbdd..8fd07c8087e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -60,11 +60,11 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	clear_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
 
 	for (i = 0; i < c->num_tc; i++)
-		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq);
+		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq, budget);
 
 	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
 	busy |= work_done == budget;
-	busy |= mlx5e_post_rx_wqes(&c->rq);
+	busy |= mlx5e_post_rx_wqes(&c->rq, napi);
 
 	if (busy)
 		return budget;
