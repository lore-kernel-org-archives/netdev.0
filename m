From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [net-next-2.6 PATCH 3/3] mlx4_en: Not using Shared Receive Queues
Date: Sun, 19 Jul 2009 16:07:13 +0300
Message-ID: <4A631A81.5070606@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39287 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754290AbZGSNIq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 09:08:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use 1:1 mapping between QPs and SRQs on receive side,
so additional indirection level not required. Allocated the receive
buffers for the RSS QPs.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c    |    3 +-
 drivers/net/mlx4/en_resources.c |    9 ++---
 drivers/net/mlx4/en_rx.c        |   77 +++++++++------------------------------
 drivers/net/mlx4/en_tx.c        |    4 +-
 drivers/net/mlx4/mlx4_en.h      |    6 +--
 5 files changed, 26 insertions(+), 73 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index f8bbc5a..c48b0f4 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -622,8 +622,7 @@ int mlx4_en_start_port(struct net_device *dev)
 
 		/* Configure ring */
 		tx_ring = &priv->tx_ring[i];
-		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
-					       priv->rx_ring[0].srq.srqn);
+		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn);
 		if (err) {
 			en_err(priv, "Failed allocating Tx ring\n");
 			mlx4_en_deactivate_cq(priv, cq);
diff --git a/drivers/net/mlx4/en_resources.c b/drivers/net/mlx4/en_resources.c
index 65ca706..1625678 100644
--- a/drivers/net/mlx4/en_resources.c
+++ b/drivers/net/mlx4/en_resources.c
@@ -37,7 +37,7 @@
 #include "mlx4_en.h"
 
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
-			     int is_tx, int rss, int qpn, int cqn, int srqn,
+			     int is_tx, int rss, int qpn, int cqn,
 			     struct mlx4_qp_context *context)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -46,11 +46,12 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	context->flags = cpu_to_be32(7 << 16 | rss << 13);
 	context->pd = cpu_to_be32(mdev->priv_pdn);
 	context->mtu_msgmax = 0xff;
-	context->rq_size_stride = 0;
+	if (!is_tx && !rss)
+		context->rq_size_stride = ilog2(size) << 3 | (ilog2(stride) - 4);
 	if (is_tx)
 		context->sq_size_stride = ilog2(size) << 3 | (ilog2(stride) - 4);
 	else
-		context->sq_size_stride = 1;
+		context->sq_size_stride = ilog2(TXBB_SIZE) - 4;
 	context->usr_page = cpu_to_be32(mdev->priv_uar.index);
 	context->local_qpn = cpu_to_be32(qpn);
 	context->pri_path.ackto = 1 & 0x07;
@@ -59,8 +60,6 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	context->cqn_send = cpu_to_be32(cqn);
 	context->cqn_recv = cpu_to_be32(cqn);
 	context->db_rec_addr = cpu_to_be64(priv->res.db.dma << 2);
-	if (!rss)
-		context->srqn = cpu_to_be32(MLX4_EN_USE_SRQ | srqn);
 }
 
 
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 47b178e..cd084de 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -40,16 +40,6 @@
 
 #include "mlx4_en.h"
 
-static void *get_wqe(struct mlx4_en_rx_ring *ring, int n)
-{
-	int offset = n << ring->srq.wqe_shift;
-	return ring->buf + offset;
-}
-
-static void mlx4_en_srq_event(struct mlx4_srq *srq, enum mlx4_event type)
-{
-	return;
-}
 
 static int mlx4_en_get_frag_header(struct skb_frag_struct *frags, void **mac_hdr,
 				   void **ip_hdr, void **tcpudp_hdr,
@@ -154,9 +144,6 @@ static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
 	int possible_frags;
 	int i;
 
-	/* Pre-link descriptor */
-	rx_desc->next.next_wqe_index = cpu_to_be16((index + 1) & ring->size_mask);
-
 	/* Set size and memtype fields */
 	for (i = 0; i < priv->num_frags; i++) {
 		skb_frags[i].size = priv->frag_info[i].frag_size;
@@ -294,9 +281,6 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	int err;
 	int tmp;
 
-	/* Sanity check SRQ size before proceeding */
-	if (size >= mdev->dev->caps.max_srq_wqes)
-		return -EINVAL;
 
 	ring->prod = 0;
 	ring->cons = 0;
@@ -304,7 +288,7 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	ring->size_mask = size - 1;
 	ring->stride = stride;
 	ring->log_stride = ffs(ring->stride) - 1;
-	ring->buf_size = ring->size * ring->stride;
+	ring->buf_size = ring->size * ring->stride + TXBB_SIZE;
 
 	tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
 					sizeof(struct skb_frag_struct));
@@ -360,15 +344,12 @@ err_ring:
 
 int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 {
-	struct mlx4_en_dev *mdev = priv->mdev;
-	struct mlx4_wqe_srq_next_seg *next;
 	struct mlx4_en_rx_ring *ring;
 	int i;
 	int ring_ind;
 	int err;
 	int stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
 					DS_SIZE * priv->num_frags);
-	int max_gs = (stride - sizeof(struct mlx4_wqe_srq_next_seg)) / DS_SIZE;
 
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
 		ring = &priv->rx_ring[ring_ind];
@@ -379,6 +360,9 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		ring->cqn = priv->rx_cq[ring_ind].mcq.cqn;
 
 		ring->stride = stride;
+		if (ring->stride <= TXBB_SIZE)
+			ring->buf += TXBB_SIZE;
+
 		ring->log_stride = ffs(ring->stride) - 1;
 		ring->buf_size = ring->size * ring->stride;
 
@@ -405,37 +389,10 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		ring = &priv->rx_ring[ring_ind];
 
 		mlx4_en_update_rx_prod_db(ring);
-
-		/* Configure SRQ representing the ring */
-		ring->srq.max    = ring->actual_size;
-		ring->srq.max_gs = max_gs;
-		ring->srq.wqe_shift = ilog2(ring->stride);
-
-		for (i = 0; i < ring->srq.max; ++i) {
-			next = get_wqe(ring, i);
-			next->next_wqe_index =
-			cpu_to_be16((i + 1) & (ring->srq.max - 1));
-		}
-
-		err = mlx4_srq_alloc(mdev->dev, mdev->priv_pdn, &ring->wqres.mtt,
-				     ring->wqres.db.dma, &ring->srq);
-		if (err){
-			en_err(priv, "Failed to allocate srq\n");
-			ring_ind--;
-			goto err_srq;
-		}
-		ring->srq.event = mlx4_en_srq_event;
 	}
 
 	return 0;
 
-err_srq:
-	while (ring_ind >= 0) {
-		ring = &priv->rx_ring[ring_ind];
-		mlx4_srq_free(mdev->dev, &ring->srq);
-		ring_ind--;
-	}
-
 err_buffers:
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++)
 		mlx4_en_free_rx_buf(priv, &priv->rx_ring[ring_ind]);
@@ -456,7 +413,7 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 
 	kfree(ring->lro.lro_arr);
 	mlx4_en_unmap_buffer(&ring->wqres.buf);
-	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
+	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
 }
@@ -464,10 +421,9 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_rx_ring *ring)
 {
-	struct mlx4_en_dev *mdev = priv->mdev;
-
-	mlx4_srq_free(mdev->dev, &ring->srq);
 	mlx4_en_free_rx_buf(priv, ring);
+	if (ring->stride <= TXBB_SIZE)
+		ring->buf -= TXBB_SIZE;
 	mlx4_en_destroy_allocator(priv, ring);
 }
 
@@ -835,8 +791,8 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 
 /* RSS related functions */
 
-static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv,
-				 int qpn, int srqn, int cqn,
+static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
+				 struct mlx4_en_rx_ring *ring,
 				 enum mlx4_qp_state *state,
 				 struct mlx4_qp *qp)
 {
@@ -858,13 +814,16 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv,
 	qp->event = mlx4_en_sqp_event;
 
 	memset(context, 0, sizeof *context);
-	mlx4_en_fill_qp_context(priv, 0, 0, 0, 0, qpn, cqn, srqn, context);
+	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 0, 0,
+				qpn, ring->cqn, context);
+	context->db_rec_addr = cpu_to_be64(ring->wqres.db.dma);
 
-	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, context, qp, state);
+	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, context, qp, state);
 	if (err) {
 		mlx4_qp_remove(mdev->dev, qp);
 		mlx4_qp_free(mdev->dev, qp);
 	}
+	mlx4_en_update_rx_prod_db(ring);
 out:
 	kfree(context);
 	return err;
@@ -880,7 +839,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	void *ptr;
 	int rss_xor = mdev->profile.rss_xor;
 	u8 rss_mask = mdev->profile.rss_mask;
-	int i, srqn, qpn, cqn;
+	int i, qpn;
 	int err = 0;
 	int good_qps = 0;
 
@@ -894,10 +853,8 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		cqn = priv->rx_ring[i].cqn;
-		srqn = priv->rx_ring[i].srq.srqn;
 		qpn = rss_map->base_qpn + i;
-		err = mlx4_en_config_rss_qp(priv, qpn, srqn, cqn,
+		err = mlx4_en_config_rss_qp(priv, qpn, &priv->rx_ring[i],
 					    &rss_map->state[i],
 					    &rss_map->qps[i]);
 		if (err)
@@ -920,7 +877,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 	rss_map->indir_qp.event = mlx4_en_sqp_event;
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
-				priv->rx_ring[0].cqn, 0, &context);
+				priv->rx_ring[0].cqn, &context);
 
 	ptr = ((void *) &context) + 0x3c;
 	rss_context = (struct mlx4_en_rss_context *) ptr;
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 3e8a404..0ecc1e1 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -150,7 +150,7 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring,
-			     int cq, int srqn)
+			     int cq)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;
@@ -168,7 +168,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->doorbell_qpn = swab32(ring->qp.qpn << 8);
 
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
-				ring->cqn, srqn, &ring->context);
+				ring->cqn, &ring->context);
 
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
 			       &ring->qp, &ring->qp_state);
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 2d76ff4..4513fb4 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -274,13 +274,11 @@ struct mlx4_en_tx_ring {
 };
 
 struct mlx4_en_rx_desc {
-	struct mlx4_wqe_srq_next_seg next;
 	/* actual number of entries depends on rx ring stride */
 	struct mlx4_wqe_data_seg data[0];
 };
 
 struct mlx4_en_rx_ring {
-	struct mlx4_srq srq;
 	struct mlx4_hwq_resources wqres;
 	struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
 	struct net_lro_mgr lro;
@@ -527,7 +525,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ri
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring);
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring,
-			     int cq, int srqn);
+			     int cq);
 void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring);
 
@@ -544,7 +542,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
 			  int budget);
 int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
-			     int is_tx, int rss, int qpn, int cqn, int srqn,
+			     int is_tx, int rss, int qpn, int cqn,
 			     struct mlx4_qp_context *context);
 void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event);
 int mlx4_en_map_buffer(struct mlx4_buf *buf);
-- 
1.6.0

