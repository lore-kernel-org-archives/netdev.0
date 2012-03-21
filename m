From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V1 1/6] net/mlx4_en: Force user priority by QP attribute
Date: Wed, 21 Mar 2012 11:24:58 +0200
Message-ID: <1332321903-11704-2-git-send-email-amirv@mellanox.com>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:54827 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755552Ab2CUJZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 05:25:35 -0400
In-Reply-To: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Instead of relying on HW to change schedule queue by UP, schedule
queue is fixed for a tx_ring, and UP in WQE is ignored in this aspect.  This
resolves two issues with untagged traffic:
1. untagged traffic has no UP in packet which is needed for QoS. The change
   above allows setting the schedule queue (and by that the UP) of such a stream.
2. BlueFlame uses the same field used by vlan tag. So forcing UP from QPC
   allows using BF for untagged but prioritized traffic.

In old firmware that force UP is not supported, untagged traffic will not subject to
QoS.

Because UP is set by QP, need to always have a tx ring per UP, even if pfcrx
module paramter is false.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    6 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |    9 ++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |    6 +++---
 include/linux/mlx4/qp.h                           |    3 ++-
 7 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 2097a7d..346fdb2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -114,7 +114,7 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
 		params->prof[i].tx_ring_num = MLX4_EN_NUM_TX_RINGS +
-			(!!pfcrx) * MLX4_EN_NUM_PPP_RINGS;
+			MLX4_EN_NUM_PPP_RINGS;
 		params->prof[i].rss_rings = 0;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 31b455a..2322622 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -650,7 +650,8 @@ int mlx4_en_start_port(struct net_device *dev)
 
 		/* Configure ring */
 		tx_ring = &priv->tx_ring[i];
-		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn);
+		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
+				max(0, i - MLX4_EN_NUM_TX_RINGS));
 		if (err) {
 			en_err(priv, "Failed allocating Tx ring\n");
 			mlx4_en_deactivate_cq(priv, cq);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index bcbc54c..10c24c7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -39,7 +39,7 @@
 
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 			     int is_tx, int rss, int qpn, int cqn,
-			     struct mlx4_qp_context *context)
+			     int user_prio, struct mlx4_qp_context *context)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 
@@ -57,6 +57,10 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	context->local_qpn = cpu_to_be32(qpn);
 	context->pri_path.ackto = 1 & 0x07;
 	context->pri_path.sched_queue = 0x83 | (priv->port - 1) << 6;
+	if (user_prio >= 0) {
+		context->pri_path.sched_queue |= user_prio << 3;
+		context->pri_path.feup = 1 << 6;
+	}
 	context->pri_path.counter_index = 0xff;
 	context->cqn_send = cpu_to_be32(cqn);
 	context->cqn_recv = cpu_to_be32(cqn);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 9adbd53..d49a7ac 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -823,7 +823,7 @@ static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
 
 	memset(context, 0, sizeof *context);
 	mlx4_en_fill_qp_context(priv, ring->actual_size, ring->stride, 0, 0,
-				qpn, ring->cqn, context);
+				qpn, ring->cqn, -1, context);
 	context->db_rec_addr = cpu_to_be64(ring->wqres.db.dma);
 
 	/* Cancel FCS removal if FW allows */
@@ -890,7 +890,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 	rss_map->indir_qp.event = mlx4_en_sqp_event;
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
-				priv->rx_ring[0].cqn, &context);
+				priv->rx_ring[0].cqn, -1, &context);
 
 	if (!priv->prof->rss_rings || priv->prof->rss_rings > priv->rx_ring_num)
 		rss_rings = priv->rx_ring_num;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 1796824..445a771 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -156,7 +156,7 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring,
-			     int cq)
+			     int cq, int user_prio)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;
@@ -174,7 +174,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->doorbell_qpn = ring->qp.qpn << 8;
 
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
-				ring->cqn, &ring->context);
+				ring->cqn, user_prio, &ring->context);
 	if (ring->bf_enabled)
 		ring->context.usr_page = cpu_to_be32(ring->bf.uar->index);
 
@@ -570,18 +570,17 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	struct mlx4_en_priv *priv = netdev_priv(dev);
 	u16 vlan_tag = 0;
 
 	/* If we support per priority flow control and the packet contains
 	 * a vlan tag, send the packet to the TX ring assigned to that priority
 	 */
-	if (priv->prof->rx_ppp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
 		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
 	}
 
-	return skb_tx_hash(dev, skb);
+	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS);
 }
 
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9e2b911..5bd7c2a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -521,7 +521,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ri
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring);
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring,
-			     int cq);
+			     int cq, int user_prio);
 void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring);
 
@@ -539,8 +539,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
 			  int budget);
 int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
-			     int is_tx, int rss, int qpn, int cqn,
-			     struct mlx4_qp_context *context);
+		int is_tx, int rss, int qpn, int cqn, int user_prio,
+		struct mlx4_qp_context *context);
 void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event);
 int mlx4_en_map_buffer(struct mlx4_buf *buf);
 void mlx4_en_unmap_buffer(struct mlx4_buf *buf);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 091f9e7..96005d7 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -139,7 +139,8 @@ struct mlx4_qp_path {
 	u8			rgid[16];
 	u8			sched_queue;
 	u8			vlan_index;
-	u8			reserved3[2];
+	u8			feup;
+	u8			reserved3;
 	u8			reserved4[2];
 	u8			dmac[6];
 };
-- 
1.7.8.2
