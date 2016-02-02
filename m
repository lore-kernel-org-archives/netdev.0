From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 08/11] mlx5: hint the NAPI alloc skb API about the
 expected bulk size
Date: Tue, 02 Feb 2016 22:14:09 +0100
Message-ID: <20160202211402.16315.52592.stgit@firesoul>
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
Received: from mx1.redhat.com ([209.132.183.28]:38187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbcBBVOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:14:11 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the newly introduced napi_alloc_skb_hint() API, to get the underlying
slab bulk allocation sizes to align with what mlx5 driver need for refilling
its RX ring queue.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   10 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    2 +-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 3e531fae9ed3..b2aba498e8d4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -593,7 +593,8 @@ void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
-bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi);
+bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi,
+			unsigned int bulk_hint);
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
 void mlx5e_update_stats(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 5d96d6682db0..88f88d354abc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -43,12 +43,13 @@ static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 
 static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
 				     struct mlx5e_rx_wqe *wqe, u16 ix,
-				     struct napi_struct *napi)
+				     struct napi_struct *napi,
+				     unsigned int bulk_hint)
 {
 	struct sk_buff *skb;
 	dma_addr_t dma_addr;
 
-	skb = napi_alloc_skb(napi, rq->wqe_sz);
+	skb = napi_alloc_skb_hint(napi, rq->wqe_sz, bulk_hint);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
@@ -77,7 +78,8 @@ err_free_skb:
 	return -ENOMEM;
 }
 
-bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi)
+bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi,
+			unsigned int hint)
 {
 	struct mlx5_wq_ll *wq = &rq->wq;
 
@@ -87,7 +89,7 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq, struct napi_struct *napi)
 	while (!mlx5_wq_ll_is_full(wq)) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
 
-		if (unlikely(mlx5e_alloc_rx_wqe(rq, wqe, wq->head, napi)))
+		if (unlikely(mlx5e_alloc_rx_wqe(rq, wqe, wq->head, napi, hint)))
 			break;
 
 		mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 8fd07c8087e3..6488404edff6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -64,7 +64,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 
 	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
 	busy |= work_done == budget;
-	busy |= mlx5e_post_rx_wqes(&c->rq, napi);
+	busy |= mlx5e_post_rx_wqes(&c->rq, napi, work_done);
 
 	if (busy)
 		return budget;
