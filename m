From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/6] net/mlx4_en: Datapath resources allocated dynamically
Date: Thu,  7 Nov 2013 12:19:52 +0200
Message-ID: <1383819594-24070-5-git-send-email-amirv@mellanox.com>
References: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44690 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754201Ab3KGKUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:20:19 -0500
In-Reply-To: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Currently all TX/RX rings and completion queues are part of the
netdev priv structure and are allocated statically. This patch
will change the priv to hold only arrays of pointers and therefore
all TX/RX rings and completetion queues will be allocated
dynamically. This is in preparation for NUMA aware allocations.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c       | 34 ++++++---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  | 36 +++++-----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   | 87 ++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/en_port.c     | 14 ++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       | 57 ++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c       | 32 ++++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     | 27 ++++----
 8 files changed, 178 insertions(+), 111 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 3e2d504..d203f11 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -44,12 +44,19 @@ static void mlx4_en_cq_event(struct mlx4_cq *cq, enum mlx4_event event)
 
 
 int mlx4_en_create_cq(struct mlx4_en_priv *priv,
-		      struct mlx4_en_cq *cq,
+		      struct mlx4_en_cq **pcq,
 		      int entries, int ring, enum cq_type mode)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_cq *cq;
 	int err;
 
+	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
+	if (!cq) {
+		en_err(priv, "Failed to allocate CQ structure\n");
+		return -ENOMEM;
+	}
+
 	cq->size = entries;
 	cq->buf_size = cq->size * mdev->dev->caps.cqe_size;
 
@@ -60,14 +67,22 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	err = mlx4_alloc_hwq_res(mdev->dev, &cq->wqres,
 				cq->buf_size, 2 * PAGE_SIZE);
 	if (err)
-		return err;
+		goto err_cq;
 
 	err = mlx4_en_map_buffer(&cq->wqres.buf);
 	if (err)
-		mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
-	else
-		cq->buf = (struct mlx4_cqe *) cq->wqres.buf.direct.buf;
+		goto err_res;
+
+	cq->buf = (struct mlx4_cqe *)cq->wqres.buf.direct.buf;
+	*pcq = cq;
 
+	return 0;
+
+err_res:
+	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
+err_cq:
+	kfree(cq);
+	*pcq = NULL;
 	return err;
 }
 
@@ -117,12 +132,12 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		struct mlx4_en_cq *rx_cq;
 
 		cq_idx = cq_idx % priv->rx_ring_num;
-		rx_cq = &priv->rx_cq[cq_idx];
+		rx_cq = priv->rx_cq[cq_idx];
 		cq->vector = rx_cq->vector;
 	}
 
 	if (!cq->is_tx)
-		cq->size = priv->rx_ring[cq->ring].actual_size;
+		cq->size = priv->rx_ring[cq->ring]->actual_size;
 
 	if ((cq->is_tx && priv->hwtstamp_config.tx_type) ||
 	    (!cq->is_tx && priv->hwtstamp_config.rx_filter))
@@ -146,9 +161,10 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	return 0;
 }
 
-void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
+void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_cq *cq = *pcq;
 
 	mlx4_en_unmap_buffer(&cq->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
@@ -157,6 +173,8 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	cq->vector = 0;
 	cq->buf_size = 0;
 	cq->buf = NULL;
+	kfree(cq);
+	*pcq = NULL;
 }
 
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 0c75098..0596f9f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -51,10 +51,10 @@ static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
 	int err = 0;
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		priv->tx_cq[i].moder_cnt = priv->tx_frames;
-		priv->tx_cq[i].moder_time = priv->tx_usecs;
+		priv->tx_cq[i]->moder_cnt = priv->tx_frames;
+		priv->tx_cq[i]->moder_time = priv->tx_usecs;
 		if (priv->port_up) {
-			err = mlx4_en_set_cq_moder(priv, &priv->tx_cq[i]);
+			err = mlx4_en_set_cq_moder(priv, priv->tx_cq[i]);
 			if (err)
 				return err;
 		}
@@ -64,11 +64,11 @@ static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
 		return 0;
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		priv->rx_cq[i].moder_cnt = priv->rx_frames;
-		priv->rx_cq[i].moder_time = priv->rx_usecs;
+		priv->rx_cq[i]->moder_cnt = priv->rx_frames;
+		priv->rx_cq[i]->moder_time = priv->rx_usecs;
 		priv->last_moder_time[i] = MLX4_EN_AUTO_CONF;
 		if (priv->port_up) {
-			err = mlx4_en_set_cq_moder(priv, &priv->rx_cq[i]);
+			err = mlx4_en_set_cq_moder(priv, priv->rx_cq[i]);
 			if (err)
 				return err;
 		}
@@ -274,16 +274,16 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 		}
 	}
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		data[index++] = priv->tx_ring[i].packets;
-		data[index++] = priv->tx_ring[i].bytes;
+		data[index++] = priv->tx_ring[i]->packets;
+		data[index++] = priv->tx_ring[i]->bytes;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		data[index++] = priv->rx_ring[i].packets;
-		data[index++] = priv->rx_ring[i].bytes;
+		data[index++] = priv->rx_ring[i]->packets;
+		data[index++] = priv->rx_ring[i]->bytes;
 #ifdef CONFIG_NET_RX_BUSY_POLL
-		data[index++] = priv->rx_ring[i].yields;
-		data[index++] = priv->rx_ring[i].misses;
-		data[index++] = priv->rx_ring[i].cleaned;
+		data[index++] = priv->rx_ring[i]->yields;
+		data[index++] = priv->rx_ring[i]->misses;
+		data[index++] = priv->rx_ring[i]->cleaned;
 #endif
 	}
 	spin_unlock_bh(&priv->stats_lock);
@@ -510,9 +510,9 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 	tx_size = max_t(u32, tx_size, MLX4_EN_MIN_TX_SIZE);
 	tx_size = min_t(u32, tx_size, MLX4_EN_MAX_TX_SIZE);
 
-	if (rx_size == (priv->port_up ? priv->rx_ring[0].actual_size :
-					priv->rx_ring[0].size) &&
-	    tx_size == priv->tx_ring[0].size)
+	if (rx_size == (priv->port_up ? priv->rx_ring[0]->actual_size :
+					priv->rx_ring[0]->size) &&
+	    tx_size == priv->tx_ring[0]->size)
 		return 0;
 
 	mutex_lock(&mdev->state_lock);
@@ -553,8 +553,8 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 	param->rx_max_pending = MLX4_EN_MAX_RX_SIZE;
 	param->tx_max_pending = MLX4_EN_MAX_TX_SIZE;
 	param->rx_pending = priv->port_up ?
-		priv->rx_ring[0].actual_size : priv->rx_ring[0].size;
-	param->tx_pending = priv->tx_ring[0].size;
+		priv->rx_ring[0]->actual_size : priv->rx_ring[0]->size;
+	param->tx_pending = priv->tx_ring[0]->size;
 }
 
 static u32 mlx4_en_get_rxfh_indir_size(struct net_device *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index cd61e26..f430788 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -75,7 +75,7 @@ static int mlx4_en_low_latency_recv(struct napi_struct *napi)
 	struct mlx4_en_cq *cq = container_of(napi, struct mlx4_en_cq, napi);
 	struct net_device *dev = cq->dev;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_rx_ring *rx_ring = &priv->rx_ring[cq->ring];
+	struct mlx4_en_rx_ring *rx_ring = priv->rx_ring[cq->ring];
 	int done;
 
 	if (!priv->port_up)
@@ -355,8 +355,7 @@ err:
 	return ret;
 }
 
-void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv,
-			     struct mlx4_en_rx_ring *rx_ring)
+void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_filter *filter, *tmp;
 	LIST_HEAD(del_list);
@@ -1242,7 +1241,7 @@ static void mlx4_en_netpoll(struct net_device *dev)
 	int i;
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		cq = &priv->rx_cq[i];
+		cq = priv->rx_cq[i];
 		spin_lock_irqsave(&cq->lock, flags);
 		napi_synchronize(&cq->napi);
 		mlx4_en_process_rx_cq(dev, cq, 0);
@@ -1264,8 +1263,8 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)))
 			continue;
 		en_warn(priv, "TX timeout on queue: %d, QP: 0x%x, CQ: 0x%x, Cons: 0x%x, Prod: 0x%x\n",
-			i, priv->tx_ring[i].qpn, priv->tx_ring[i].cqn,
-			priv->tx_ring[i].cons, priv->tx_ring[i].prod);
+			i, priv->tx_ring[i]->qpn, priv->tx_ring[i]->cqn,
+			priv->tx_ring[i]->cons, priv->tx_ring[i]->prod);
 	}
 
 	priv->port_stats.tx_timeout++;
@@ -1305,7 +1304,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 
 	/* Setup cq moderation params */
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		cq = &priv->rx_cq[i];
+		cq = priv->rx_cq[i];
 		cq->moder_cnt = priv->rx_frames;
 		cq->moder_time = priv->rx_usecs;
 		priv->last_moder_time[i] = MLX4_EN_AUTO_CONF;
@@ -1314,7 +1313,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	}
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		cq = &priv->tx_cq[i];
+		cq = priv->tx_cq[i];
 		cq->moder_cnt = priv->tx_frames;
 		cq->moder_time = priv->tx_usecs;
 	}
@@ -1348,8 +1347,8 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 
 	for (ring = 0; ring < priv->rx_ring_num; ring++) {
 		spin_lock_bh(&priv->stats_lock);
-		rx_packets = priv->rx_ring[ring].packets;
-		rx_bytes = priv->rx_ring[ring].bytes;
+		rx_packets = priv->rx_ring[ring]->packets;
+		rx_bytes = priv->rx_ring[ring]->bytes;
 		spin_unlock_bh(&priv->stats_lock);
 
 		rx_pkt_diff = ((unsigned long) (rx_packets -
@@ -1378,7 +1377,7 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 
 		if (moder_time != priv->last_moder_time[ring]) {
 			priv->last_moder_time[ring] = moder_time;
-			cq = &priv->rx_cq[ring];
+			cq = priv->rx_cq[ring];
 			cq->moder_time = moder_time;
 			cq->moder_cnt = priv->rx_frames;
 			err = mlx4_en_set_cq_moder(priv, cq);
@@ -1501,7 +1500,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		return err;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		cq = &priv->rx_cq[i];
+		cq = priv->rx_cq[i];
 
 		mlx4_en_cq_init_lock(cq);
 
@@ -1519,7 +1518,7 @@ int mlx4_en_start_port(struct net_device *dev)
 			goto cq_err;
 		}
 		mlx4_en_arm_cq(priv, cq);
-		priv->rx_ring[i].cqn = cq->mcq.cqn;
+		priv->rx_ring[i]->cqn = cq->mcq.cqn;
 		++rx_index;
 	}
 
@@ -1545,7 +1544,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	/* Configure tx cq's and rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		/* Configure cq */
-		cq = &priv->tx_cq[i];
+		cq = priv->tx_cq[i];
 		err = mlx4_en_activate_cq(priv, cq, i);
 		if (err) {
 			en_err(priv, "Failed allocating Tx CQ\n");
@@ -1561,7 +1560,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		cq->buf->wqe_index = cpu_to_be16(0xffff);
 
 		/* Configure ring */
-		tx_ring = &priv->tx_ring[i];
+		tx_ring = priv->tx_ring[i];
 		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
 			i / priv->num_tx_rings_p_up);
 		if (err) {
@@ -1631,8 +1630,8 @@ int mlx4_en_start_port(struct net_device *dev)
 
 tx_err:
 	while (tx_index--) {
-		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[tx_index]);
-		mlx4_en_deactivate_cq(priv, &priv->tx_cq[tx_index]);
+		mlx4_en_deactivate_tx_ring(priv, priv->tx_ring[tx_index]);
+		mlx4_en_deactivate_cq(priv, priv->tx_cq[tx_index]);
 	}
 	mlx4_en_destroy_drop_qp(priv);
 rss_err:
@@ -1641,9 +1640,9 @@ mac_err:
 	mlx4_en_put_qp(priv);
 cq_err:
 	while (rx_index--)
-		mlx4_en_deactivate_cq(priv, &priv->rx_cq[rx_index]);
+		mlx4_en_deactivate_cq(priv, priv->rx_cq[rx_index]);
 	for (i = 0; i < priv->rx_ring_num; i++)
-		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
+		mlx4_en_deactivate_rx_ring(priv, priv->rx_ring[i]);
 
 	return err; /* need to close devices */
 }
@@ -1739,13 +1738,13 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 
 	/* Free TX Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[i]);
-		mlx4_en_deactivate_cq(priv, &priv->tx_cq[i]);
+		mlx4_en_deactivate_tx_ring(priv, priv->tx_ring[i]);
+		mlx4_en_deactivate_cq(priv, priv->tx_cq[i]);
 	}
 	msleep(10);
 
 	for (i = 0; i < priv->tx_ring_num; i++)
-		mlx4_en_free_tx_buf(dev, &priv->tx_ring[i]);
+		mlx4_en_free_tx_buf(dev, priv->tx_ring[i]);
 
 	/* Free RSS qps */
 	mlx4_en_release_rss_steer(priv);
@@ -1757,7 +1756,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 
 	/* Free RX Rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		struct mlx4_en_cq *cq = &priv->rx_cq[i];
+		struct mlx4_en_cq *cq = priv->rx_cq[i];
 
 		local_bh_disable();
 		while (!mlx4_en_cq_lock_napi(cq)) {
@@ -1768,7 +1767,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 
 		while (test_bit(NAPI_STATE_SCHED, &cq->napi.state))
 			msleep(1);
-		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
+		mlx4_en_deactivate_rx_ring(priv, priv->rx_ring[i]);
 		mlx4_en_deactivate_cq(priv, cq);
 	}
 }
@@ -1806,15 +1805,15 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 	memset(&priv->port_stats, 0, sizeof(priv->port_stats));
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		priv->tx_ring[i].bytes = 0;
-		priv->tx_ring[i].packets = 0;
-		priv->tx_ring[i].tx_csum = 0;
+		priv->tx_ring[i]->bytes = 0;
+		priv->tx_ring[i]->packets = 0;
+		priv->tx_ring[i]->tx_csum = 0;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		priv->rx_ring[i].bytes = 0;
-		priv->rx_ring[i].packets = 0;
-		priv->rx_ring[i].csum_ok = 0;
-		priv->rx_ring[i].csum_none = 0;
+		priv->rx_ring[i]->bytes = 0;
+		priv->rx_ring[i]->packets = 0;
+		priv->rx_ring[i]->csum_ok = 0;
+		priv->rx_ring[i]->csum_none = 0;
 	}
 }
 
@@ -1871,17 +1870,17 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 #endif
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		if (priv->tx_ring[i].tx_info)
+		if (priv->tx_ring && priv->tx_ring[i])
 			mlx4_en_destroy_tx_ring(priv, &priv->tx_ring[i]);
-		if (priv->tx_cq[i].buf)
+		if (priv->tx_cq && priv->tx_cq[i])
 			mlx4_en_destroy_cq(priv, &priv->tx_cq[i]);
 	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		if (priv->rx_ring[i].rx_info)
+		if (priv->rx_ring[i])
 			mlx4_en_destroy_rx_ring(priv, &priv->rx_ring[i],
 				priv->prof->rx_ring_size, priv->stride);
-		if (priv->rx_cq[i].buf)
+		if (priv->rx_cq[i])
 			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
 	}
 
@@ -1937,6 +1936,20 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 
 err:
 	en_err(priv, "Failed to allocate NIC resources\n");
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		if (priv->rx_ring[i])
+			mlx4_en_destroy_rx_ring(priv, &priv->rx_ring[i],
+						prof->rx_ring_size,
+						priv->stride);
+		if (priv->rx_cq[i])
+			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
+	}
+	for (i = 0; i < priv->tx_ring_num; i++) {
+		if (priv->tx_ring[i])
+			mlx4_en_destroy_tx_ring(priv, &priv->tx_ring[i]);
+		if (priv->tx_cq[i])
+			mlx4_en_destroy_cq(priv, &priv->tx_cq[i]);
+	}
 	return -ENOMEM;
 }
 
@@ -2230,13 +2243,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->num_tx_rings_p_up = mdev->profile.num_tx_rings_p_up;
 	priv->tx_ring_num = prof->tx_ring_num;
 
-	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring) * MAX_TX_RINGS,
+	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring *) * MAX_TX_RINGS,
 				GFP_KERNEL);
 	if (!priv->tx_ring) {
 		err = -ENOMEM;
 		goto out;
 	}
-	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * MAX_TX_RINGS,
+	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq *) * MAX_TX_RINGS,
 			      GFP_KERNEL);
 	if (!priv->tx_cq) {
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 5f8535e..dae1a1f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -140,18 +140,18 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->port_stats.rx_chksum_good = 0;
 	priv->port_stats.rx_chksum_none = 0;
 	for (i = 0; i < priv->rx_ring_num; i++) {
-		stats->rx_packets += priv->rx_ring[i].packets;
-		stats->rx_bytes += priv->rx_ring[i].bytes;
-		priv->port_stats.rx_chksum_good += priv->rx_ring[i].csum_ok;
-		priv->port_stats.rx_chksum_none += priv->rx_ring[i].csum_none;
+		stats->rx_packets += priv->rx_ring[i]->packets;
+		stats->rx_bytes += priv->rx_ring[i]->bytes;
+		priv->port_stats.rx_chksum_good += priv->rx_ring[i]->csum_ok;
+		priv->port_stats.rx_chksum_none += priv->rx_ring[i]->csum_none;
 	}
 	stats->tx_packets = 0;
 	stats->tx_bytes = 0;
 	priv->port_stats.tx_chksum_offload = 0;
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		stats->tx_packets += priv->tx_ring[i].packets;
-		stats->tx_bytes += priv->tx_ring[i].bytes;
-		priv->port_stats.tx_chksum_offload += priv->tx_ring[i].tx_csum;
+		stats->tx_packets += priv->tx_ring[i]->packets;
+		stats->tx_bytes += priv->tx_ring[i]->bytes;
+		priv->port_stats.tx_chksum_offload += priv->tx_ring[i]->tx_csum;
 	}
 
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index afe2efa..1c45f88 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -264,7 +264,7 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 
 	for (buf_ind = 0; buf_ind < priv->prof->rx_ring_size; buf_ind++) {
 		for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
-			ring = &priv->rx_ring[ring_ind];
+			ring = priv->rx_ring[ring_ind];
 
 			if (mlx4_en_prepare_rx_desc(priv, ring,
 						    ring->actual_size,
@@ -289,7 +289,7 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 
 reduce_rings:
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
-		ring = &priv->rx_ring[ring_ind];
+		ring = priv->rx_ring[ring_ind];
 		while (ring->actual_size > new_size) {
 			ring->actual_size--;
 			ring->prod--;
@@ -319,12 +319,20 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 }
 
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_rx_ring *ring, u32 size, u16 stride)
+			   struct mlx4_en_rx_ring **pring,
+			   u32 size, u16 stride)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_rx_ring *ring;
 	int err = -ENOMEM;
 	int tmp;
 
+	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+	if (!ring) {
+		en_err(priv, "Failed to allocate RX ring structure\n");
+		return -ENOMEM;
+	}
+
 	ring->prod = 0;
 	ring->cons = 0;
 	ring->size = size;
@@ -336,8 +344,10 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
 					sizeof(struct mlx4_en_rx_alloc));
 	ring->rx_info = vmalloc(tmp);
-	if (!ring->rx_info)
-		return -ENOMEM;
+	if (!ring->rx_info) {
+		err = -ENOMEM;
+		goto err_ring;
+	}
 
 	en_dbg(DRV, priv, "Allocated rx_info ring at addr:%p size:%d\n",
 		 ring->rx_info, tmp);
@@ -345,7 +355,7 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres,
 				 ring->buf_size, 2 * PAGE_SIZE);
 	if (err)
-		goto err_ring;
+		goto err_info;
 
 	err = mlx4_en_map_buffer(&ring->wqres.buf);
 	if (err) {
@@ -356,13 +366,18 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 
 	ring->hwtstamp_rx_filter = priv->hwtstamp_config.rx_filter;
 
+	*pring = ring;
 	return 0;
 
 err_hwq:
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
-err_ring:
+err_info:
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
+err_ring:
+	kfree(ring);
+	*pring = NULL;
+
 	return err;
 }
 
@@ -376,12 +391,12 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 					DS_SIZE * priv->num_frags);
 
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
-		ring = &priv->rx_ring[ring_ind];
+		ring = priv->rx_ring[ring_ind];
 
 		ring->prod = 0;
 		ring->cons = 0;
 		ring->actual_size = 0;
-		ring->cqn = priv->rx_cq[ring_ind].mcq.cqn;
+		ring->cqn = priv->rx_cq[ring_ind]->mcq.cqn;
 
 		ring->stride = stride;
 		if (ring->stride <= TXBB_SIZE)
@@ -412,7 +427,7 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		goto err_buffers;
 
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
-		ring = &priv->rx_ring[ring_ind];
+		ring = priv->rx_ring[ring_ind];
 
 		ring->size_mask = ring->actual_size - 1;
 		mlx4_en_update_rx_prod_db(ring);
@@ -422,30 +437,34 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 
 err_buffers:
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++)
-		mlx4_en_free_rx_buf(priv, &priv->rx_ring[ring_ind]);
+		mlx4_en_free_rx_buf(priv, priv->rx_ring[ring_ind]);
 
 	ring_ind = priv->rx_ring_num - 1;
 err_allocator:
 	while (ring_ind >= 0) {
-		if (priv->rx_ring[ring_ind].stride <= TXBB_SIZE)
-			priv->rx_ring[ring_ind].buf -= TXBB_SIZE;
-		mlx4_en_destroy_allocator(priv, &priv->rx_ring[ring_ind]);
+		if (priv->rx_ring[ring_ind]->stride <= TXBB_SIZE)
+			priv->rx_ring[ring_ind]->buf -= TXBB_SIZE;
+		mlx4_en_destroy_allocator(priv, priv->rx_ring[ring_ind]);
 		ring_ind--;
 	}
 	return err;
 }
 
 void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
-			     struct mlx4_en_rx_ring *ring, u32 size, u16 stride)
+			     struct mlx4_en_rx_ring **pring,
+			     u32 size, u16 stride)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_rx_ring *ring = *pring;
 
 	mlx4_en_unmap_buffer(&ring->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
+	kfree(ring);
+	*pring = NULL;
 #ifdef CONFIG_RFS_ACCEL
-	mlx4_en_cleanup_filters(priv, ring);
+	mlx4_en_cleanup_filters(priv);
 #endif
 }
 
@@ -592,7 +611,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_cqe *cqe;
-	struct mlx4_en_rx_ring *ring = &priv->rx_ring[cq->ring];
+	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
 	struct sk_buff *skb;
@@ -991,7 +1010,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		qpn = rss_map->base_qpn + i;
-		err = mlx4_en_config_rss_qp(priv, qpn, &priv->rx_ring[i],
+		err = mlx4_en_config_rss_qp(priv, qpn, priv->rx_ring[i],
 					    &rss_map->state[i],
 					    &rss_map->qps[i]);
 		if (err)
@@ -1008,7 +1027,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 	rss_map->indir_qp.event = mlx4_en_sqp_event;
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
-				priv->rx_ring[0].cqn, -1, &context);
+				priv->rx_ring[0]->cqn, -1, &context);
 
 	if (!priv->prof->rss_rings || priv->prof->rss_rings > priv->rx_ring_num)
 		rss_rings = priv->rx_ring_num;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 2448f0d..4062669 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -156,7 +156,7 @@ retry_tx:
 		 * since we turned the carrier off */
 		msleep(200);
 		for (i = 0; i < priv->tx_ring_num && carrier_ok; i++) {
-			tx_ring = &priv->tx_ring[i];
+			tx_ring = priv->tx_ring[i];
 			if (tx_ring->prod != (tx_ring->cons + tx_ring->last_nr_txbb))
 				goto retry_tx;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 0698c82..d4e4cf3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -54,13 +54,20 @@ module_param_named(inline_thold, inline_thold, int, 0444);
 MODULE_PARM_DESC(inline_thold, "threshold for using inline data");
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_tx_ring *ring, int qpn, u32 size,
+			   struct mlx4_en_tx_ring **pring, int qpn, u32 size,
 			   u16 stride)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_tx_ring *ring;
 	int tmp;
 	int err;
 
+	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+	if (!ring) {
+		en_err(priv, "Failed allocating TX ring\n");
+		return -ENOMEM;
+	}
+
 	ring->size = size;
 	ring->size_mask = size - 1;
 	ring->stride = stride;
@@ -69,8 +76,10 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
 	ring->tx_info = vmalloc(tmp);
-	if (!ring->tx_info)
-		return -ENOMEM;
+	if (!ring->tx_info) {
+		err = -ENOMEM;
+		goto err_ring;
+	}
 
 	en_dbg(DRV, priv, "Allocated tx_info ring at addr:%p size:%d\n",
 		 ring->tx_info, tmp);
@@ -78,7 +87,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	ring->bounce_buf = kmalloc(MAX_DESC_SIZE, GFP_KERNEL);
 	if (!ring->bounce_buf) {
 		err = -ENOMEM;
-		goto err_tx;
+		goto err_info;
 	}
 	ring->buf_size = ALIGN(size * ring->stride, MLX4_EN_PAGE_SIZE);
 
@@ -120,6 +129,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 
 	ring->hwtstamp_tx_type = priv->hwtstamp_config.tx_type;
 
+	*pring = ring;
 	return 0;
 
 err_map:
@@ -129,16 +139,20 @@ err_hwq_res:
 err_bounce:
 	kfree(ring->bounce_buf);
 	ring->bounce_buf = NULL;
-err_tx:
+err_info:
 	vfree(ring->tx_info);
 	ring->tx_info = NULL;
+err_ring:
+	kfree(ring);
+	*pring = NULL;
 	return err;
 }
 
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
-			     struct mlx4_en_tx_ring *ring)
+			     struct mlx4_en_tx_ring **pring)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_tx_ring *ring = *pring;
 	en_dbg(DRV, priv, "Destroying tx ring, qpn: %d\n", ring->qpn);
 
 	if (ring->bf_enabled)
@@ -151,6 +165,8 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 	ring->bounce_buf = NULL;
 	vfree(ring->tx_info);
 	ring->tx_info = NULL;
+	kfree(ring);
+	*pring = NULL;
 }
 
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
@@ -330,7 +346,7 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
-	struct mlx4_en_tx_ring *ring = &priv->tx_ring[cq->ring];
+	struct mlx4_en_tx_ring *ring = priv->tx_ring[cq->ring];
 	struct mlx4_cqe *cqe;
 	u16 index;
 	u16 new_index, ring_index, stamp_index;
@@ -622,7 +638,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	tx_ind = skb->queue_mapping;
-	ring = &priv->tx_ring[tx_ind];
+	ring = priv->tx_ring[tx_ind];
 	if (vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index bf06e36..b2547ae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -530,10 +530,10 @@ struct mlx4_en_priv {
 	u16 num_frags;
 	u16 log_rx_info;
 
-	struct mlx4_en_tx_ring *tx_ring;
-	struct mlx4_en_rx_ring rx_ring[MAX_RX_RINGS];
-	struct mlx4_en_cq *tx_cq;
-	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
+	struct mlx4_en_tx_ring **tx_ring;
+	struct mlx4_en_rx_ring *rx_ring[MAX_RX_RINGS];
+	struct mlx4_en_cq **tx_cq;
+	struct mlx4_en_cq *rx_cq[MAX_RX_RINGS];
 	struct mlx4_qp drop_qp;
 	struct work_struct rx_mode_task;
 	struct work_struct watchdog_task;
@@ -626,7 +626,7 @@ static inline bool mlx4_en_cq_lock_poll(struct mlx4_en_cq *cq)
 	if ((cq->state & MLX4_CQ_LOCKED)) {
 		struct net_device *dev = cq->dev;
 		struct mlx4_en_priv *priv = netdev_priv(dev);
-		struct mlx4_en_rx_ring *rx_ring = &priv->rx_ring[cq->ring];
+		struct mlx4_en_rx_ring *rx_ring = priv->rx_ring[cq->ring];
 
 		cq->state |= MLX4_EN_CQ_STATE_POLL_YIELD;
 		rc = false;
@@ -704,9 +704,9 @@ void mlx4_en_stop_port(struct net_device *dev, int detach);
 void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
 
-int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
+int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq,
 		      int entries, int ring, enum cq_type mode);
-void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
+void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq);
 int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 			int cq_idx);
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
@@ -717,9 +717,11 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq);
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
-int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring,
+int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
+			   struct mlx4_en_tx_ring **pring,
 			   int qpn, u32 size, u16 stride);
-void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv, struct mlx4_en_tx_ring *ring);
+void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
+			     struct mlx4_en_tx_ring **pring);
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring,
 			     int cq, int user_prio);
@@ -727,10 +729,10 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring);
 
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_rx_ring *ring,
+			   struct mlx4_en_rx_ring **pring,
 			   u32 size, u16 stride);
 void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
-			     struct mlx4_en_rx_ring *ring,
+			     struct mlx4_en_rx_ring **pring,
 			     u32 size, u16 stride);
 int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv);
 void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
@@ -768,8 +770,7 @@ extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_pfc_ops;
 int mlx4_en_setup_tc(struct net_device *dev, u8 up);
 
 #ifdef CONFIG_RFS_ACCEL
-void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv,
-			     struct mlx4_en_rx_ring *rx_ring);
+void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv);
 #endif
 
 #define MLX4_EN_NUM_SELF_TEST	5
-- 
1.8.3.4
