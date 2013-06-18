From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 1/2] net/mlx4_en: Add Low Latency Socket (LLS) support
Date: Tue, 18 Jun 2013 16:18:27 +0300
Message-ID: <1371561508-11960-2-git-send-email-amirv@mellanox.com>
References: <1371561508-11960-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39404 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932189Ab3FRNSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 09:18:45 -0400
In-Reply-To: <1371561508-11960-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add basic support for LLS.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |   3 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  43 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  15 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 121 +++++++++++++++++++++++++
 4 files changed, 178 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 1e6c594..3e2d504 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -139,6 +139,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 
 	if (!cq->is_tx) {
 		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_rx_cq, 64);
+		napi_hash_add(&cq->napi);
 		napi_enable(&cq->napi);
 	}
 
@@ -162,6 +163,8 @@ void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
 	if (!cq->is_tx) {
 		napi_disable(&cq->napi);
+		napi_hash_del(&cq->napi);
+		synchronize_rcu();
 		netif_napi_del(&cq->napi);
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 89c47ea..bb9847a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -38,6 +38,7 @@
 #include <linux/slab.h>
 #include <linux/hash.h>
 #include <net/ip.h>
+#include <net/ll_poll.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
@@ -67,6 +68,30 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	return 0;
 }
 
+#ifdef CONFIG_NET_LL_RX_POLL
+/* must be called with local_bh_disable()d */
+static int mlx4_en_low_latency_recv(struct napi_struct *napi)
+{
+	struct mlx4_en_cq *cq = container_of(napi, struct mlx4_en_cq, napi);
+	struct net_device *dev = cq->dev;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_rx_ring *rx_ring = &priv->rx_ring[cq->ring];
+	int done;
+
+	if (!priv->port_up)
+		return LL_FLUSH_FAILED;
+
+	if (!mlx4_en_cq_lock_poll(cq))
+		return LL_FLUSH_BUSY;
+
+	done = mlx4_en_process_rx_cq(dev, cq, 4);
+
+	mlx4_en_cq_unlock_poll(cq);
+
+	return done;
+}
+#endif	/* CONFIG_NET_LL_RX_POLL */
+
 #ifdef CONFIG_RFS_ACCEL
 
 struct mlx4_en_filter {
@@ -1445,6 +1470,8 @@ int mlx4_en_start_port(struct net_device *dev)
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		cq = &priv->rx_cq[i];
 
+		mlx4_en_cq_init_lock(cq);
+
 		err = mlx4_en_activate_cq(priv, cq, i);
 		if (err) {
 			en_err(priv, "Failed activating Rx CQ\n");
@@ -1694,10 +1721,19 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 
 	/* Free RX Rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
+		struct mlx4_en_cq *cq = &priv->rx_cq[i];
+
+		local_bh_disable();
+		while (!mlx4_en_cq_lock_napi(cq)) {
+			pr_info("CQ %d locked\n", i);
+			mdelay(1);
+		}
+		local_bh_enable();
+
 		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
-		while (test_bit(NAPI_STATE_SCHED, &priv->rx_cq[i].napi.state))
+		while (test_bit(NAPI_STATE_SCHED, &cq->napi.state))
 			msleep(1);
-		mlx4_en_deactivate_cq(priv, &priv->rx_cq[i]);
+		mlx4_en_deactivate_cq(priv, cq);
 	}
 
 	/* close port*/
@@ -2083,6 +2119,9 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
+#ifdef CONFIG_NET_LL_RX_POLL
+	.ndo_ll_poll		= mlx4_en_low_latency_recv,
+#endif
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 02aee1e..9c57581 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -31,6 +31,7 @@
  *
  */
 
+#include <net/ll_poll.h>
 #include <linux/mlx4/cq.h>
 #include <linux/slab.h>
 #include <linux/mlx4/qp.h>
@@ -656,8 +657,11 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				 * - DIX Ethernet (type interpretation)
 				 * - TCP/IP (v4)
 				 * - without IP options
-				 * - not an IP fragment */
-				if (dev->features & NETIF_F_GRO) {
+				 * - not an IP fragment
+				 * - no LLS polling in progress
+				 */
+				if (!mlx4_en_cq_ll_polling(cq) &&
+				    (dev->features & NETIF_F_GRO)) {
 					struct sk_buff *gro_skb = napi_get_frags(&cq->napi);
 					if (!gro_skb)
 						goto next;
@@ -737,6 +741,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					       timestamp);
 		}
 
+		skb_mark_ll(skb, &cq->napi);
+
 		/* Push it up the stack */
 		netif_receive_skb(skb);
 
@@ -781,8 +787,13 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int done;
 
+	if (!mlx4_en_cq_lock_napi(cq))
+		return budget;
+
 	done = mlx4_en_process_rx_cq(dev, cq, budget);
 
+	mlx4_en_cq_unlock_napi(cq);
+
 	/* If we used up all the quota - we're probably not done yet... */
 	if (done == budget)
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index b1f51c1..11c862e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -310,6 +310,19 @@ struct mlx4_en_cq {
 	u16 moder_cnt;
 	struct mlx4_cqe *buf;
 #define MLX4_EN_OPCODE_ERROR	0x1e
+
+#ifdef CONFIG_NET_LL_RX_POLL
+	unsigned int state;
+#define MLX4_EN_CQ_STATE_IDLE        0
+#define MLX4_EN_CQ_STATE_NAPI     1    /* NAPI owns this CQ */
+#define MLX4_EN_CQ_STATE_POLL     2    /* poll owns this CQ */
+#define MLX4_CQ_LOCKED (MLX4_EN_CQ_STATE_NAPI | MLX4_EN_CQ_STATE_POLL)
+#define MLX4_EN_CQ_STATE_NAPI_YIELD  4    /* NAPI yielded this CQ */
+#define MLX4_EN_CQ_STATE_POLL_YIELD  8    /* poll yielded this CQ */
+#define CQ_YIELD (MLX4_EN_CQ_STATE_NAPI_YIELD | MLX4_EN_CQ_STATE_POLL_YIELD)
+#define CQ_USER_PEND (MLX4_EN_CQ_STATE_POLL | MLX4_EN_CQ_STATE_POLL_YIELD)
+	spinlock_t poll_lock; /* protects from LLS/napi conflicts */
+#endif  /* CONFIG_NET_LL_RX_POLL */
 };
 
 struct mlx4_en_port_profile {
@@ -562,6 +575,114 @@ struct mlx4_mac_entry {
 	struct rcu_head rcu;
 };
 
+#ifdef CONFIG_NET_LL_RX_POLL
+static inline void mlx4_en_cq_init_lock(struct mlx4_en_cq *cq)
+{
+	spin_lock_init(&cq->poll_lock);
+	cq->state = MLX4_EN_CQ_STATE_IDLE;
+}
+
+/* called from the device poll rutine to get ownership of a cq */
+static inline bool mlx4_en_cq_lock_napi(struct mlx4_en_cq *cq)
+{
+	int rc = true;
+	spin_lock(&cq->poll_lock);
+	if (cq->state & MLX4_CQ_LOCKED) {
+		WARN_ON(cq->state & MLX4_EN_CQ_STATE_NAPI);
+		cq->state |= MLX4_EN_CQ_STATE_NAPI_YIELD;
+		rc = false;
+	} else
+		/* we don't care if someone yielded */
+		cq->state = MLX4_EN_CQ_STATE_NAPI;
+	spin_unlock(&cq->poll_lock);
+	return rc;
+}
+
+/* returns true is someone tried to get the cq while napi had it */
+static inline bool mlx4_en_cq_unlock_napi(struct mlx4_en_cq *cq)
+{
+	int rc = false;
+	spin_lock(&cq->poll_lock);
+	WARN_ON(cq->state & (MLX4_EN_CQ_STATE_POLL |
+			       MLX4_EN_CQ_STATE_NAPI_YIELD));
+
+	if (cq->state & MLX4_EN_CQ_STATE_POLL_YIELD)
+		rc = true;
+	cq->state = MLX4_EN_CQ_STATE_IDLE;
+	spin_unlock(&cq->poll_lock);
+	return rc;
+}
+
+/* called from mlx4_en_low_latency_poll() */
+static inline bool mlx4_en_cq_lock_poll(struct mlx4_en_cq *cq)
+{
+	int rc = true;
+	spin_lock_bh(&cq->poll_lock);
+	if ((cq->state & MLX4_CQ_LOCKED)) {
+		struct net_device *dev = cq->dev;
+		struct mlx4_en_priv *priv = netdev_priv(dev);
+		struct mlx4_en_rx_ring *rx_ring = &priv->rx_ring[cq->ring];
+
+		cq->state |= MLX4_EN_CQ_STATE_POLL_YIELD;
+		rc = false;
+	} else
+		/* preserve yield marks */
+		cq->state |= MLX4_EN_CQ_STATE_POLL;
+	spin_unlock_bh(&cq->poll_lock);
+	return rc;
+}
+
+/* returns true if someone tried to get the cq while it was locked */
+static inline bool mlx4_en_cq_unlock_poll(struct mlx4_en_cq *cq)
+{
+	int rc = false;
+	spin_lock_bh(&cq->poll_lock);
+	WARN_ON(cq->state & (MLX4_EN_CQ_STATE_NAPI));
+
+	if (cq->state & MLX4_EN_CQ_STATE_POLL_YIELD)
+		rc = true;
+	cq->state = MLX4_EN_CQ_STATE_IDLE;
+	spin_unlock_bh(&cq->poll_lock);
+	return rc;
+}
+
+/* true if a socket is polling, even if it did not get the lock */
+static inline bool mlx4_en_cq_ll_polling(struct mlx4_en_cq *cq)
+{
+	WARN_ON(!(cq->state & MLX4_CQ_LOCKED));
+	return cq->state & CQ_USER_PEND;
+}
+#else
+static inline void mlx4_en_cq_init_lock(struct mlx4_en_cq *cq)
+{
+}
+
+static inline bool mlx4_en_cq_lock_napi(struct mlx4_en_cq *cq)
+{
+	return true;
+}
+
+static inline bool mlx4_en_cq_unlock_napi(struct mlx4_en_cq *cq)
+{
+	return false;
+}
+
+static inline bool mlx4_en_cq_lock_poll(struct mlx4_en_cq *cq)
+{
+	return false;
+}
+
+static inline bool mlx4_en_cq_unlock_poll(struct mlx4_en_cq *cq)
+{
+	return false;
+}
+
+static inline bool mlx4_en_cq_ll_polling(struct mlx4_en_cq *cq)
+{
+	return false;
+}
+#endif /* CONFIG_NET_LL_RX_POLL */
+
 #define MLX4_EN_WOL_DO_MODIFY (1ULL << 63)
 
 void mlx4_en_update_loopback_state(struct net_device *dev,
-- 
1.8.3.251.g1462b67
