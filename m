From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 1/2] net/mlx4_en: Add TX_XDP for CQ types
Date: Thu, 27 Oct 2016 17:52:03 +0300
Message-ID: <1477579924-32737-2-git-send-email-tariqt@mellanox.com>
References: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38553 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1033994AbcJ0OwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:52:20 -0400
In-Reply-To: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support XDP CQ type, and refactor the CQ type enum.
Rename the is_tx field to match the change.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c   | 18 +++++++++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  7 ++++---
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 132cea655920..03f05c4d1f98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -65,7 +65,7 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	cq->buf_size = cq->size * mdev->dev->caps.cqe_size;
 
 	cq->ring = ring;
-	cq->is_tx = mode;
+	cq->type = mode;
 	cq->vector = mdev->dev->caps.num_comp_vectors;
 
 	/* Allocate HW buffers on provided NUMA node.
@@ -104,7 +104,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	*cq->mcq.arm_db    = 0;
 	memset(cq->buf, 0, cq->buf_size);
 
-	if (cq->is_tx == RX) {
+	if (cq->type == RX) {
 		if (!mlx4_is_eq_vector_valid(mdev->dev, priv->port,
 					     cq->vector)) {
 			cq->vector = cpumask_first(priv->rx_ring[cq->ring]->affinity_mask);
@@ -133,11 +133,11 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		cq->vector = rx_cq->vector;
 	}
 
-	if (!cq->is_tx)
+	if (cq->type == RX)
 		cq->size = priv->rx_ring[cq->ring]->actual_size;
 
-	if ((cq->is_tx && priv->hwtstamp_config.tx_type) ||
-	    (!cq->is_tx && priv->hwtstamp_config.rx_filter))
+	if ((cq->type != RX && priv->hwtstamp_config.tx_type) ||
+	    (cq->type == RX && priv->hwtstamp_config.rx_filter))
 		timestamp_en = 1;
 
 	err = mlx4_cq_alloc(mdev->dev, cq->size, &cq->wqres.mtt,
@@ -146,10 +146,10 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	if (err)
 		goto free_eq;
 
-	cq->mcq.comp  = cq->is_tx ? mlx4_en_tx_irq : mlx4_en_rx_irq;
+	cq->mcq.comp  = cq->type != RX ? mlx4_en_tx_irq : mlx4_en_rx_irq;
 	cq->mcq.event = mlx4_en_cq_event;
 
-	if (cq->is_tx)
+	if (cq->type != RX)
 		netif_tx_napi_add(cq->dev, &cq->napi, mlx4_en_poll_tx_cq,
 				  NAPI_POLL_WEIGHT);
 	else
@@ -173,7 +173,7 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
 	if (mlx4_is_eq_vector_valid(mdev->dev, priv->port, cq->vector) &&
-	    cq->is_tx == RX)
+	    cq->type == RX)
 		mlx4_release_eq(priv->mdev->dev, cq->vector);
 	cq->vector = 0;
 	cq->buf_size = 0;
@@ -185,7 +185,7 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
 	napi_disable(&cq->napi);
-	if (!cq->is_tx) {
+	if (cq->type == RX) {
 		napi_hash_del(&cq->napi);
 		synchronize_rcu();
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a3528dd1e72e..83c914a79f14 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -207,8 +207,9 @@ enum {
  */
 
 enum cq_type {
-	RX = 0,
-	TX = 1,
+	TX,
+	TX_XDP,
+	RX,
 };
 
 
@@ -361,7 +362,7 @@ struct mlx4_en_cq {
 	int size;
 	int buf_size;
 	int vector;
-	enum cq_type is_tx;
+	enum cq_type type;
 	u16 moder_time;
 	u16 moder_cnt;
 	struct mlx4_cqe *buf;
-- 
1.8.3.1
