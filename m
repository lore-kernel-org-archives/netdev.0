From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V3 2/3] net/mlx4_en: Refactor the XDP forwarding rings scheme
Date: Wed,  2 Nov 2016 17:12:24 +0200
Message-ID: <1478099545-24181-3-git-send-email-tariqt@mellanox.com>
References: <1478099545-24181-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44210 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752592AbcKBPMf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:12:35 -0400
In-Reply-To: <1478099545-24181-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separately manage the two types of TX rings: regular ones, and XDP.
Upon an XDP set, do not borrow regular TX rings and convert them
into XDP ones, but allocate new ones, unless we hit the max number
of rings.
Which means that in systems with smaller #cores we will not consume
the current TX rings for XDP, while we are still in the num TX limit.

XDP TX rings counters are not shown in ethtool statistics.
Instead, XDP counters will be added to the respective RX rings
in a downstream patch.

This has no performance implications.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c      |  10 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  76 +++--
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 378 ++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   8 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |   9 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  11 +-
 8 files changed, 293 insertions(+), 205 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 1427311a9640..03f05c4d1f98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -127,15 +127,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		/* For TX we use the same irq per
 		ring we assigned for the RX    */
 		struct mlx4_en_cq *rx_cq;
-		int xdp_index;
-
-		/* The xdp tx irq must align with the rx ring that forwards to
-		 * it, so reindex these from 0. This should only happen when
-		 * tx_ring_num is not a multiple of rx_ring_num.
-		 */
-		xdp_index = (priv->xdp_ring_num - priv->tx_ring_num) + cq_idx;
-		if (xdp_index >= 0)
-			cq_idx = xdp_index;
+
 		cq_idx = cq_idx % priv->rx_ring_num;
 		rx_cq = priv->rx_cq[cq_idx];
 		cq->vector = rx_cq->vector;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index bdda17d2ea0f..e8ccb95680bc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -49,16 +49,19 @@
 
 static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
 {
-	int i;
+	int i, t;
 	int err = 0;
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		priv->tx_cq[i]->moder_cnt = priv->tx_frames;
-		priv->tx_cq[i]->moder_time = priv->tx_usecs;
-		if (priv->port_up) {
-			err = mlx4_en_set_cq_moder(priv, priv->tx_cq[i]);
-			if (err)
-				return err;
+	for (t = 0 ; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		for (i = 0; i < priv->tx_ring_num[t]; i++) {
+			priv->tx_cq[t][i]->moder_cnt = priv->tx_frames;
+			priv->tx_cq[t][i]->moder_time = priv->tx_usecs;
+			if (priv->port_up) {
+				err = mlx4_en_set_cq_moder(priv,
+							   priv->tx_cq[t][i]);
+				if (err)
+					return err;
+			}
 		}
 	}
 
@@ -336,7 +339,7 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	switch (sset) {
 	case ETH_SS_STATS:
 		return bitmap_iterator_count(&it) +
-			(priv->tx_ring_num * 2) +
+			(priv->tx_ring_num[TX] * 2) +
 			(priv->rx_ring_num * 3);
 	case ETH_SS_TEST:
 		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.flags
@@ -397,9 +400,9 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 		if (bitmap_iterator_test(&it))
 			data[index++] = ((unsigned long *)&priv->pkstats)[i];
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		data[index++] = priv->tx_ring[i]->packets;
-		data[index++] = priv->tx_ring[i]->bytes;
+	for (i = 0; i < priv->tx_ring_num[TX]; i++) {
+		data[index++] = priv->tx_ring[TX][i]->packets;
+		data[index++] = priv->tx_ring[TX][i]->bytes;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		data[index++] = priv->rx_ring[i]->packets;
@@ -467,7 +470,7 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				strcpy(data + (index++) * ETH_GSTRING_LEN,
 				       main_strings[strings]);
 
-		for (i = 0; i < priv->tx_ring_num; i++) {
+		for (i = 0; i < priv->tx_ring_num[TX]; i++) {
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"tx%d_packets", i);
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
@@ -1060,7 +1063,7 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 
 	if (rx_size == (priv->port_up ? priv->rx_ring[0]->actual_size :
 					priv->rx_ring[0]->size) &&
-	    tx_size == priv->tx_ring[0]->size)
+	    tx_size == priv->tx_ring[TX][0]->size)
 		return 0;
 
 	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
@@ -1105,7 +1108,7 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 	param->tx_max_pending = MLX4_EN_MAX_TX_SIZE;
 	param->rx_pending = priv->port_up ?
 		priv->rx_ring[0]->actual_size : priv->rx_ring[0]->size;
-	param->tx_pending = priv->tx_ring[0]->size;
+	param->tx_pending = priv->tx_ring[TX][0]->size;
 }
 
 static u32 mlx4_en_get_rxfh_indir_size(struct net_device *dev)
@@ -1710,7 +1713,7 @@ static void mlx4_en_get_channels(struct net_device *dev,
 	channel->max_tx = MLX4_EN_MAX_TX_RING_P_UP;
 
 	channel->rx_count = priv->rx_ring_num;
-	channel->tx_count = priv->tx_ring_num / MLX4_EN_NUM_UP;
+	channel->tx_count = priv->tx_ring_num[TX] / MLX4_EN_NUM_UP;
 }
 
 static int mlx4_en_set_channels(struct net_device *dev,
@@ -1721,6 +1724,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	struct mlx4_en_port_profile new_prof;
 	struct mlx4_en_priv *tmp;
 	int port_up = 0;
+	int xdp_count;
 	int err = 0;
 
 	if (channel->other_count || channel->combined_count ||
@@ -1729,20 +1733,25 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	    !channel->tx_count || !channel->rx_count)
 		return -EINVAL;
 
-	if (channel->tx_count * MLX4_EN_NUM_UP <= priv->xdp_ring_num) {
-		en_err(priv, "Minimum %d tx channels required with XDP on\n",
-		       priv->xdp_ring_num / MLX4_EN_NUM_UP + 1);
-		return -EINVAL;
-	}
-
 	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
 	if (!tmp)
 		return -ENOMEM;
 
 	mutex_lock(&mdev->state_lock);
+	xdp_count = priv->tx_ring_num[TX_XDP] ? channel->rx_count : 0;
+	if (channel->tx_count * MLX4_EN_NUM_UP + xdp_count > MAX_TX_RINGS) {
+		err = -EINVAL;
+		en_err(priv,
+		       "Total number of TX and XDP rings (%d) exceeds the maximum supported (%d)\n",
+		       channel->tx_count * MLX4_EN_NUM_UP + xdp_count,
+		       MAX_TX_RINGS);
+		goto out;
+	}
+
 	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
 	new_prof.num_tx_rings_p_up = channel->tx_count;
-	new_prof.tx_ring_num = channel->tx_count * MLX4_EN_NUM_UP;
+	new_prof.tx_ring_num[TX] = channel->tx_count * MLX4_EN_NUM_UP;
+	new_prof.tx_ring_num[TX_XDP] = xdp_count;
 	new_prof.rx_ring_num = channel->rx_count;
 
 	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
@@ -1756,14 +1765,13 @@ static int mlx4_en_set_channels(struct net_device *dev,
 
 	mlx4_en_safe_replace_resources(priv, tmp);
 
-	netif_set_real_num_tx_queues(dev, priv->tx_ring_num -
-							priv->xdp_ring_num);
+	netif_set_real_num_tx_queues(dev, priv->tx_ring_num[TX]);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
 	if (dev->num_tc)
 		mlx4_en_setup_tc(dev, MLX4_EN_NUM_UP);
 
-	en_warn(priv, "Using %d TX rings\n", priv->tx_ring_num);
+	en_warn(priv, "Using %d TX rings\n", priv->tx_ring_num[TX]);
 	en_warn(priv, "Using %d RX rings\n", priv->rx_ring_num);
 
 	if (port_up) {
@@ -1774,8 +1782,8 @@ static int mlx4_en_set_channels(struct net_device *dev,
 
 	err = mlx4_en_moderation_update(priv);
 out:
-	kfree(tmp);
 	mutex_unlock(&mdev->state_lock);
+	kfree(tmp);
 	return err;
 }
 
@@ -1823,11 +1831,15 @@ static int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 	int ret = 0;
 
 	if (bf_enabled_new != bf_enabled_old) {
+		int t;
+
 		if (bf_enabled_new) {
 			bool bf_supported = true;
 
-			for (i = 0; i < priv->tx_ring_num; i++)
-				bf_supported &= priv->tx_ring[i]->bf_alloced;
+			for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++)
+				for (i = 0; i < priv->tx_ring_num[t]; i++)
+					bf_supported &=
+						priv->tx_ring[t][i]->bf_alloced;
 
 			if (!bf_supported) {
 				en_err(priv, "BlueFlame is not supported\n");
@@ -1839,8 +1851,10 @@ static int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 			priv->pflags &= ~MLX4_EN_PRIV_FLAGS_BLUEFLAME;
 		}
 
-		for (i = 0; i < priv->tx_ring_num; i++)
-			priv->tx_ring[i]->bf_enabled = bf_enabled_new;
+		for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++)
+			for (i = 0; i < priv->tx_ring_num[t]; i++)
+				priv->tx_ring[t][i]->bf_enabled =
+					bf_enabled_new;
 
 		en_info(priv, "BlueFlame %s\n",
 			bf_enabled_new ?  "Enabled" : "Disabled");
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index bf7628db098a..36a7a54bbb82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -169,7 +169,7 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ppp = pfctx;
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
-		params->prof[i].tx_ring_num = params->num_tx_rings_p_up *
+		params->prof[i].tx_ring_num[TX] = params->num_tx_rings_p_up *
 			MLX4_EN_NUM_UP;
 		params->prof[i].rss_rings = 0;
 		params->prof[i].inline_thold = inline_thold;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 58b749dd6125..edf0a99177e1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1214,8 +1214,8 @@ static void mlx4_en_netpoll(struct net_device *dev)
 	struct mlx4_en_cq *cq;
 	int i;
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		cq = priv->tx_cq[i];
+	for (i = 0; i < priv->tx_ring_num[TX]; i++) {
+		cq = priv->tx_cq[TX][i];
 		napi_schedule(&cq->napi);
 	}
 }
@@ -1299,12 +1299,14 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 	if (netif_msg_timer(priv))
 		en_warn(priv, "Tx timeout called on port:%d\n", priv->port);
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
+	for (i = 0; i < priv->tx_ring_num[TX]; i++) {
+		struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[TX][i];
+
 		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)))
 			continue;
 		en_warn(priv, "TX timeout on queue: %d, QP: 0x%x, CQ: 0x%x, Cons: 0x%x, Prod: 0x%x\n",
-			i, priv->tx_ring[i]->qpn, priv->tx_ring[i]->cqn,
-			priv->tx_ring[i]->cons, priv->tx_ring[i]->prod);
+			i, tx_ring->qpn, tx_ring->cqn,
+			tx_ring->cons, tx_ring->prod);
 	}
 
 	priv->port_stats.tx_timeout++;
@@ -1328,7 +1330,7 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_cq *cq;
-	int i;
+	int i, t;
 
 	/* If we haven't received a specific coalescing setting
 	 * (module param), we set the moderation parameters as follows:
@@ -1353,10 +1355,12 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 		priv->last_moder_bytes[i] = 0;
 	}
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		cq = priv->tx_cq[i];
-		cq->moder_cnt = priv->tx_frames;
-		cq->moder_time = priv->tx_usecs;
+	for (t = 0 ; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		for (i = 0; i < priv->tx_ring_num[t]; i++) {
+			cq = priv->tx_cq[t][i];
+			cq->moder_cnt = priv->tx_frames;
+			cq->moder_time = priv->tx_usecs;
+		}
 	}
 
 	/* Reset auto-moderation params */
@@ -1526,19 +1530,13 @@ static void mlx4_en_free_affinity_hint(struct mlx4_en_priv *priv, int ring_idx)
 static void mlx4_en_init_recycle_ring(struct mlx4_en_priv *priv,
 				      int tx_ring_idx)
 {
-	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[tx_ring_idx];
-	int rr_index;
+	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[TX_XDP][tx_ring_idx];
+	int rr_index = tx_ring_idx;
 
-	rr_index = (priv->xdp_ring_num - priv->tx_ring_num) + tx_ring_idx;
-	if (rr_index >= 0) {
-		tx_ring->free_tx_desc = mlx4_en_recycle_tx_desc;
-		tx_ring->recycle_ring = priv->rx_ring[rr_index];
-		en_dbg(DRV, priv,
-		       "Set tx_ring[%d]->recycle_ring = rx_ring[%d]\n",
-		       tx_ring_idx, rr_index);
-	} else {
-		tx_ring->recycle_ring = NULL;
-	}
+	tx_ring->free_tx_desc = mlx4_en_recycle_tx_desc;
+	tx_ring->recycle_ring = priv->rx_ring[rr_index];
+	en_dbg(DRV, priv, "Set tx_ring[%d][%d]->recycle_ring = rx_ring[%d]\n",
+	       TX_XDP, tx_ring_idx, rr_index);
 }
 
 int mlx4_en_start_port(struct net_device *dev)
@@ -1548,9 +1546,8 @@ int mlx4_en_start_port(struct net_device *dev)
 	struct mlx4_en_cq *cq;
 	struct mlx4_en_tx_ring *tx_ring;
 	int rx_index = 0;
-	int tx_index = 0;
 	int err = 0;
-	int i;
+	int i, t;
 	int j;
 	u8 mc_list[16] = {0};
 
@@ -1635,43 +1632,51 @@ int mlx4_en_start_port(struct net_device *dev)
 		goto rss_err;
 
 	/* Configure tx cq's and rings */
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		/* Configure cq */
-		cq = priv->tx_cq[i];
-		err = mlx4_en_activate_cq(priv, cq, i);
-		if (err) {
-			en_err(priv, "Failed allocating Tx CQ\n");
-			goto tx_err;
-		}
-		err = mlx4_en_set_cq_moder(priv, cq);
-		if (err) {
-			en_err(priv, "Failed setting cq moderation parameters\n");
-			mlx4_en_deactivate_cq(priv, cq);
-			goto tx_err;
-		}
-		en_dbg(DRV, priv, "Resetting index of collapsed CQ:%d to -1\n", i);
-		cq->buf->wqe_index = cpu_to_be16(0xffff);
+	for (t = 0 ; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		u8 num_tx_rings_p_up = t == TX ? priv->num_tx_rings_p_up : 1;
 
-		/* Configure ring */
-		tx_ring = priv->tx_ring[i];
-		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
-			i / priv->num_tx_rings_p_up);
-		if (err) {
-			en_err(priv, "Failed allocating Tx ring\n");
-			mlx4_en_deactivate_cq(priv, cq);
-			goto tx_err;
-		}
-		tx_ring->tx_queue = netdev_get_tx_queue(dev, i);
-
-		mlx4_en_init_recycle_ring(priv, i);
+		for (i = 0; i < priv->tx_ring_num[t]; i++) {
+			/* Configure cq */
+			cq = priv->tx_cq[t][i];
+			err = mlx4_en_activate_cq(priv, cq, i);
+			if (err) {
+				en_err(priv, "Failed allocating Tx CQ\n");
+				goto tx_err;
+			}
+			err = mlx4_en_set_cq_moder(priv, cq);
+			if (err) {
+				en_err(priv, "Failed setting cq moderation parameters\n");
+				mlx4_en_deactivate_cq(priv, cq);
+				goto tx_err;
+			}
+			en_dbg(DRV, priv,
+			       "Resetting index of collapsed CQ:%d to -1\n", i);
+			cq->buf->wqe_index = cpu_to_be16(0xffff);
+
+			/* Configure ring */
+			tx_ring = priv->tx_ring[t][i];
+			err = mlx4_en_activate_tx_ring(priv, tx_ring,
+						       cq->mcq.cqn,
+						       i / num_tx_rings_p_up);
+			if (err) {
+				en_err(priv, "Failed allocating Tx ring\n");
+				mlx4_en_deactivate_cq(priv, cq);
+				goto tx_err;
+			}
+			if (t != TX_XDP) {
+				tx_ring->tx_queue = netdev_get_tx_queue(dev, i);
+				tx_ring->recycle_ring = NULL;
+			} else {
+				mlx4_en_init_recycle_ring(priv, i);
+			}
 
-		/* Arm CQ for TX completions */
-		mlx4_en_arm_cq(priv, cq);
+			/* Arm CQ for TX completions */
+			mlx4_en_arm_cq(priv, cq);
 
-		/* Set initial ownership of all Tx TXBBs to SW (1) */
-		for (j = 0; j < tx_ring->buf_size; j += STAMP_STRIDE)
-			*((u32 *) (tx_ring->buf + j)) = 0xffffffff;
-		++tx_index;
+			/* Set initial ownership of all Tx TXBBs to SW (1) */
+			for (j = 0; j < tx_ring->buf_size; j += STAMP_STRIDE)
+				*((u32 *)(tx_ring->buf + j)) = 0xffffffff;
+		}
 	}
 
 	/* Configure port */
@@ -1746,9 +1751,18 @@ int mlx4_en_start_port(struct net_device *dev)
 	return 0;
 
 tx_err:
-	while (tx_index--) {
-		mlx4_en_deactivate_tx_ring(priv, priv->tx_ring[tx_index]);
-		mlx4_en_deactivate_cq(priv, priv->tx_cq[tx_index]);
+	if (t == MLX4_EN_NUM_TX_TYPES) {
+		t--;
+		i = priv->tx_ring_num[t];
+	}
+	while (t >= 0) {
+		while (i--) {
+			mlx4_en_deactivate_tx_ring(priv, priv->tx_ring[t][i]);
+			mlx4_en_deactivate_cq(priv, priv->tx_cq[t][i]);
+		}
+		if (!t--)
+			break;
+		i = priv->tx_ring_num[t];
 	}
 	mlx4_en_destroy_drop_qp(priv);
 rss_err:
@@ -1773,7 +1787,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_mc_list *mclist, *tmp;
 	struct ethtool_flow_id *flow, *tmp_flow;
-	int i;
+	int i, t;
 	u8 mc_list[16] = {0};
 
 	if (!priv->port_up) {
@@ -1859,14 +1873,17 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	mlx4_en_destroy_drop_qp(priv);
 
 	/* Free TX Rings */
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		mlx4_en_deactivate_tx_ring(priv, priv->tx_ring[i]);
-		mlx4_en_deactivate_cq(priv, priv->tx_cq[i]);
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		for (i = 0; i < priv->tx_ring_num[t]; i++) {
+			mlx4_en_deactivate_tx_ring(priv, priv->tx_ring[t][i]);
+			mlx4_en_deactivate_cq(priv, priv->tx_cq[t][i]);
+		}
 	}
 	msleep(10);
 
-	for (i = 0; i < priv->tx_ring_num; i++)
-		mlx4_en_free_tx_buf(dev, priv->tx_ring[i]);
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++)
+		for (i = 0; i < priv->tx_ring_num[t]; i++)
+			mlx4_en_free_tx_buf(dev, priv->tx_ring[t][i]);
 
 	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
 		mlx4_en_delete_rss_steer_rules(priv);
@@ -1915,6 +1932,7 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_tx_ring **tx_ring;
 	int i;
 
 	if (!mlx4_is_slave(mdev->dev))
@@ -1932,15 +1950,16 @@ static void mlx4_en_clear_stats(struct net_device *dev)
 	       sizeof(priv->tx_priority_flowstats));
 	memset(&priv->pf_stats, 0, sizeof(priv->pf_stats));
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		priv->tx_ring[i]->bytes = 0;
-		priv->tx_ring[i]->packets = 0;
-		priv->tx_ring[i]->tx_csum = 0;
-		priv->tx_ring[i]->tx_dropped = 0;
-		priv->tx_ring[i]->queue_stopped = 0;
-		priv->tx_ring[i]->wake_queue = 0;
-		priv->tx_ring[i]->tso_packets = 0;
-		priv->tx_ring[i]->xmit_more = 0;
+	tx_ring = priv->tx_ring[TX];
+	for (i = 0; i < priv->tx_ring_num[TX]; i++) {
+		tx_ring[i]->bytes = 0;
+		tx_ring[i]->packets = 0;
+		tx_ring[i]->tx_csum = 0;
+		tx_ring[i]->tx_dropped = 0;
+		tx_ring[i]->queue_stopped = 0;
+		tx_ring[i]->wake_queue = 0;
+		tx_ring[i]->tso_packets = 0;
+		tx_ring[i]->xmit_more = 0;
 	}
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		priv->rx_ring[i]->bytes = 0;
@@ -1996,17 +2015,20 @@ static int mlx4_en_close(struct net_device *dev)
 
 static void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 {
-	int i;
+	int i, t;
 
 #ifdef CONFIG_RFS_ACCEL
 	priv->dev->rx_cpu_rmap = NULL;
 #endif
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		if (priv->tx_ring && priv->tx_ring[i])
-			mlx4_en_destroy_tx_ring(priv, &priv->tx_ring[i]);
-		if (priv->tx_cq && priv->tx_cq[i])
-			mlx4_en_destroy_cq(priv, &priv->tx_cq[i]);
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		for (i = 0; i < priv->tx_ring_num[t]; i++) {
+			if (priv->tx_ring[t] && priv->tx_ring[t][i])
+				mlx4_en_destroy_tx_ring(priv,
+							&priv->tx_ring[t][i]);
+			if (priv->tx_cq[t] && priv->tx_cq[t][i])
+				mlx4_en_destroy_cq(priv, &priv->tx_cq[t][i]);
+		}
 	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
@@ -2022,20 +2044,22 @@ static void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 static int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_port_profile *prof = priv->prof;
-	int i;
+	int i, t;
 	int node;
 
 	/* Create tx Rings */
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		node = cpu_to_node(i % num_online_cpus());
-		if (mlx4_en_create_cq(priv, &priv->tx_cq[i],
-				      prof->tx_ring_size, i, TX, node))
-			goto err;
-
-		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i],
-					   prof->tx_ring_size, TXBB_SIZE,
-					   node, i))
-			goto err;
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		for (i = 0; i < priv->tx_ring_num[t]; i++) {
+			node = cpu_to_node(i % num_online_cpus());
+			if (mlx4_en_create_cq(priv, &priv->tx_cq[t][i],
+					      prof->tx_ring_size, i, t, node))
+				goto err;
+
+			if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[t][i],
+						   prof->tx_ring_size,
+						   TXBB_SIZE, node, i))
+				goto err;
+		}
 	}
 
 	/* Create rx Rings */
@@ -2067,11 +2091,14 @@ static int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 		if (priv->rx_cq[i])
 			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
 	}
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		if (priv->tx_ring[i])
-			mlx4_en_destroy_tx_ring(priv, &priv->tx_ring[i]);
-		if (priv->tx_cq[i])
-			mlx4_en_destroy_cq(priv, &priv->tx_cq[i]);
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		for (i = 0; i < priv->tx_ring_num[t]; i++) {
+			if (priv->tx_ring[t][i])
+				mlx4_en_destroy_tx_ring(priv,
+							&priv->tx_ring[t][i]);
+			if (priv->tx_cq[t][i])
+				mlx4_en_destroy_cq(priv, &priv->tx_cq[t][i]);
+		}
 	}
 	return -ENOMEM;
 }
@@ -2088,10 +2115,11 @@ static int mlx4_en_copy_priv(struct mlx4_en_priv *dst,
 			     struct mlx4_en_priv *src,
 			     struct mlx4_en_port_profile *prof)
 {
+	int t;
+
 	memcpy(&dst->hwtstamp_config, &prof->hwtstamp_config,
 	       sizeof(dst->hwtstamp_config));
 	dst->num_tx_rings_p_up = src->mdev->profile.num_tx_rings_p_up;
-	dst->tx_ring_num = prof->tx_ring_num;
 	dst->rx_ring_num = prof->rx_ring_num;
 	dst->flags = prof->flags;
 	dst->mdev = src->mdev;
@@ -2101,33 +2129,50 @@ static int mlx4_en_copy_priv(struct mlx4_en_priv *dst,
 	dst->stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
 					 DS_SIZE * MLX4_EN_MAX_RX_FRAGS);
 
-	dst->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring *) * MAX_TX_RINGS,
-				GFP_KERNEL);
-	if (!dst->tx_ring)
-		return -ENOMEM;
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		dst->tx_ring_num[t] = prof->tx_ring_num[t];
+		if (!dst->tx_ring_num[t])
+			continue;
 
-	dst->tx_cq = kzalloc(sizeof(struct mlx4_en_cq *) * MAX_TX_RINGS,
-			      GFP_KERNEL);
-	if (!dst->tx_cq) {
-		kfree(dst->tx_ring);
-		return -ENOMEM;
+		dst->tx_ring[t] = kzalloc(sizeof(struct mlx4_en_tx_ring *) *
+					  MAX_TX_RINGS, GFP_KERNEL);
+		if (!dst->tx_ring[t])
+			goto err_free_tx;
+
+		dst->tx_cq[t] = kzalloc(sizeof(struct mlx4_en_cq *) *
+					MAX_TX_RINGS, GFP_KERNEL);
+		if (!dst->tx_cq[t]) {
+			kfree(dst->tx_ring[t]);
+			goto err_free_tx;
+		}
 	}
+
 	return 0;
+
+err_free_tx:
+	while (t--) {
+		kfree(dst->tx_ring[t]);
+		kfree(dst->tx_cq[t]);
+	}
+	return -ENOMEM;
 }
 
 static void mlx4_en_update_priv(struct mlx4_en_priv *dst,
 				struct mlx4_en_priv *src)
 {
+	int t;
 	memcpy(dst->rx_ring, src->rx_ring,
 	       sizeof(struct mlx4_en_rx_ring *) * src->rx_ring_num);
 	memcpy(dst->rx_cq, src->rx_cq,
 	       sizeof(struct mlx4_en_cq *) * src->rx_ring_num);
 	memcpy(&dst->hwtstamp_config, &src->hwtstamp_config,
 	       sizeof(dst->hwtstamp_config));
-	dst->tx_ring_num = src->tx_ring_num;
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		dst->tx_ring_num[t] = src->tx_ring_num[t];
+		dst->tx_ring[t] = src->tx_ring[t];
+		dst->tx_cq[t] = src->tx_cq[t];
+	}
 	dst->rx_ring_num = src->rx_ring_num;
-	dst->tx_ring = src->tx_ring;
-	dst->tx_cq = src->tx_cq;
 	memcpy(dst->prof, src->prof, sizeof(struct mlx4_en_port_profile));
 }
 
@@ -2135,14 +2180,18 @@ int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
 				struct mlx4_en_priv *tmp,
 				struct mlx4_en_port_profile *prof)
 {
+	int t;
+
 	mlx4_en_copy_priv(tmp, priv, prof);
 
 	if (mlx4_en_alloc_resources(tmp)) {
 		en_warn(priv,
 			"%s: Resource allocation failed, using previous configuration\n",
 			__func__);
-		kfree(tmp->tx_ring);
-		kfree(tmp->tx_cq);
+		for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+			kfree(tmp->tx_ring[t]);
+			kfree(tmp->tx_cq[t]);
+		}
 		return -ENOMEM;
 	}
 	return 0;
@@ -2161,6 +2210,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	bool shutdown = mdev->dev->persist->interface_state &
 					    MLX4_INTERFACE_STATE_SHUTDOWN;
+	int t;
 
 	en_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);
 
@@ -2197,8 +2247,10 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 
 	mlx4_en_free_resources(priv);
 
-	kfree(priv->tx_ring);
-	kfree(priv->tx_cq);
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		kfree(priv->tx_ring[t]);
+		kfree(priv->tx_cq[t]);
+	}
 
 	if (!shutdown)
 		free_netdev(dev);
@@ -2214,7 +2266,7 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 	en_dbg(DRV, priv, "Change MTU called - current:%d new:%d\n",
 		 dev->mtu, new_mtu);
 
-	if (priv->xdp_ring_num && MLX4_EN_EFF_MTU(new_mtu) > FRAG_SZ0) {
+	if (priv->tx_ring_num[TX_XDP] && MLX4_EN_EFF_MTU(new_mtu) > FRAG_SZ0) {
 		en_err(priv, "MTU size:%d requires frags but XDP running\n",
 		       new_mtu);
 		return -EOPNOTSUPP;
@@ -2605,7 +2657,7 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
 static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 maxrate)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[queue_index];
+	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[TX][queue_index];
 	struct mlx4_update_qp_params params;
 	int err;
 
@@ -2633,18 +2685,21 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_port_profile new_prof;
 	struct bpf_prog *old_prog;
+	struct mlx4_en_priv *tmp;
+	int tx_changed = 0;
 	int xdp_ring_num;
 	int port_up = 0;
 	int err;
 	int i;
 
-	xdp_ring_num = prog ? ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP) : 0;
+	xdp_ring_num = prog ? priv->rx_ring_num : 0;
 
 	/* No need to reconfigure buffers when simply swapping the
 	 * program for a new one.
 	 */
-	if (priv->xdp_ring_num == xdp_ring_num) {
+	if (priv->tx_ring_num[TX_XDP] == xdp_ring_num) {
 		if (prog) {
 			prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
 			if (IS_ERR(prog))
@@ -2668,28 +2723,41 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -EOPNOTSUPP;
 	}
 
-	if (priv->tx_ring_num < xdp_ring_num + MLX4_EN_NUM_UP) {
-		en_err(priv,
-		       "Minimum %d tx channels required to run XDP\n",
-		       (xdp_ring_num + MLX4_EN_NUM_UP) / MLX4_EN_NUM_UP);
-		return -EINVAL;
-	}
+	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
 
 	if (prog) {
 		prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
-		if (IS_ERR(prog))
-			return PTR_ERR(prog);
+		if (IS_ERR(prog)) {
+			err = PTR_ERR(prog);
+			goto out;
+		}
 	}
 
 	mutex_lock(&mdev->state_lock);
+	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
+	new_prof.tx_ring_num[TX_XDP] = xdp_ring_num;
+
+	if (priv->tx_ring_num[TX] + xdp_ring_num > MAX_TX_RINGS) {
+		tx_changed = 1;
+		new_prof.tx_ring_num[TX] =
+			MAX_TX_RINGS - ALIGN(xdp_ring_num, MLX4_EN_NUM_UP);
+		en_warn(priv, "Reducing the number of TX rings, to not exceed the max total rings number.\n");
+	}
+
+	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
+	if (err)
+		goto unlock_out;
+
 	if (priv->port_up) {
 		port_up = 1;
 		mlx4_en_stop_port(dev, 1);
 	}
 
-	priv->xdp_ring_num = xdp_ring_num;
-	netif_set_real_num_tx_queues(dev, priv->tx_ring_num -
-							priv->xdp_ring_num);
+	mlx4_en_safe_replace_resources(priv, tmp);
+	if (tx_changed)
+		netif_set_real_num_tx_queues(dev, priv->tx_ring_num[TX]);
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		old_prog = rcu_dereference_protected(
@@ -2709,15 +2777,18 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		}
 	}
 
+unlock_out:
 	mutex_unlock(&mdev->state_lock);
-	return 0;
+out:
+	kfree(tmp);
+	return err;
 }
 
 static bool mlx4_xdp_attached(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
-	return !!priv->xdp_ring_num;
+	return !!priv->tx_ring_num[TX_XDP];
 }
 
 static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
@@ -3061,7 +3132,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 {
 	struct net_device *dev;
 	struct mlx4_en_priv *priv;
-	int i;
+	int i, t;
 	int err;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
@@ -3069,7 +3140,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (dev == NULL)
 		return -ENOMEM;
 
-	netif_set_real_num_tx_queues(dev, prof->tx_ring_num);
+	netif_set_real_num_tx_queues(dev, prof->tx_ring_num[TX]);
 	netif_set_real_num_rx_queues(dev, prof->rx_ring_num);
 
 	SET_NETDEV_DEV(dev, &mdev->dev->persist->pdev->dev);
@@ -3106,21 +3177,27 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->ctrl_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 			MLX4_WQE_CTRL_SOLICITED);
 	priv->num_tx_rings_p_up = mdev->profile.num_tx_rings_p_up;
-	priv->tx_ring_num = prof->tx_ring_num;
 	priv->tx_work_limit = MLX4_EN_DEFAULT_TX_WORK;
 	netdev_rss_key_fill(priv->rss_key, sizeof(priv->rss_key));
 
-	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring *) * MAX_TX_RINGS,
-				GFP_KERNEL);
-	if (!priv->tx_ring) {
-		err = -ENOMEM;
-		goto out;
-	}
-	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq *) * MAX_TX_RINGS,
-			      GFP_KERNEL);
-	if (!priv->tx_cq) {
-		err = -ENOMEM;
-		goto out;
+	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+		priv->tx_ring_num[t] = prof->tx_ring_num[t];
+		if (!priv->tx_ring_num[t])
+			continue;
+
+		priv->tx_ring[t] = kzalloc(sizeof(struct mlx4_en_tx_ring *) *
+					   MAX_TX_RINGS, GFP_KERNEL);
+		if (!priv->tx_ring[t]) {
+			err = -ENOMEM;
+			goto err_free_tx;
+		}
+		priv->tx_cq[t] = kzalloc(sizeof(struct mlx4_en_cq *) *
+					 MAX_TX_RINGS, GFP_KERNEL);
+		if (!priv->tx_cq[t]) {
+			kfree(priv->tx_ring[t]);
+			err = -ENOMEM;
+			goto out;
+		}
 	}
 	priv->rx_ring_num = prof->rx_ring_num;
 	priv->cqe_factor = (mdev->dev->caps.cqe_size == 64) ? 1 : 0;
@@ -3203,7 +3280,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	else
 		dev->netdev_ops = &mlx4_netdev_ops;
 	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
-	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
+	netif_set_real_num_tx_queues(dev, priv->tx_ring_num[TX]);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
 	dev->ethtool_ops = &mlx4_en_ethtool_ops;
@@ -3303,7 +3380,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_carrier_off(dev);
 	mlx4_en_set_default_moderation(priv);
 
-	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num);
+	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num[TX]);
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
 
 	mlx4_en_update_loopback_state(priv->dev, priv->dev->features);
@@ -3363,6 +3440,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	return 0;
 
+err_free_tx:
+	while (t--) {
+		kfree(priv->tx_ring[t]);
+		kfree(priv->tx_cq[t]);
+	}
 out:
 	mlx4_en_destroy_netdev(dev);
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 59473a0ebcdf..2e1ab4642569 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -196,8 +196,8 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->port_stats.tso_packets = 0;
 	priv->port_stats.xmit_more = 0;
 
-	for (i = 0; i < priv->tx_ring_num; i++) {
-		const struct mlx4_en_tx_ring *ring = priv->tx_ring[i];
+	for (i = 0; i < priv->tx_ring_num[TX]; i++) {
+		const struct mlx4_en_tx_ring *ring = priv->tx_ring[TX][i];
 
 		stats->tx_packets += ring->packets;
 		stats->tx_bytes += ring->bytes;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index f2e8beddcf44..71196f68b55d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -788,7 +788,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct bpf_prog *xdp_prog;
 	int doorbell_pending;
 	struct sk_buff *skb;
-	int tx_index;
 	int index;
 	int nr;
 	unsigned int length;
@@ -808,7 +807,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	rcu_read_lock();
 	xdp_prog = rcu_dereference(ring->xdp_prog);
 	doorbell_pending = 0;
-	tx_index = (priv->tx_ring_num - priv->xdp_ring_num) + cq->ring;
 
 	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
 	 * descriptor offset can be deduced from the CQE index instead of
@@ -905,7 +903,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				break;
 			case XDP_TX:
 				if (likely(!mlx4_en_xmit_frame(frags, dev,
-							length, tx_index,
+							length, cq->ring,
 							&doorbell_pending)))
 					goto consumed;
 				goto xdp_drop; /* Drop on xmit failure */
@@ -1082,7 +1080,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 out:
 	rcu_read_unlock();
 	if (doorbell_pending)
-		mlx4_en_xmit_doorbell(priv->tx_ring[tx_index]);
+		mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
 
 	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
 	mlx4_cq_set_ci(&cq->mcq);
@@ -1162,7 +1160,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	/* bpf requires buffers to be set up as 1 packet per page.
 	 * This only works when num_frags == 1.
 	 */
-	if (priv->xdp_ring_num) {
+	if (priv->tx_ring_num[TX_XDP]) {
 		dma_dir = PCI_DMA_BIDIRECTIONAL;
 		/* This will gain efficient xdp frame recycling at the expense
 		 * of more costly truesize accounting
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e2509bba3e7c..95dc864bb2f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -392,7 +392,8 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 		cnt++;
 	}
 
-	netdev_tx_reset_queue(ring->tx_queue);
+	if (ring->tx_queue)
+		netdev_tx_reset_queue(ring->tx_queue);
 
 	if (cnt)
 		en_dbg(DRV, priv, "Freed %d uncompleted tx descriptors\n", cnt);
@@ -405,7 +406,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
-	struct mlx4_en_tx_ring *ring = priv->tx_ring[cq->ring];
+	struct mlx4_en_tx_ring *ring = priv->tx_ring[cq->type][cq->ring];
 	struct mlx4_cqe *cqe;
 	u16 index;
 	u16 new_index, ring_index, stamp_index;
@@ -807,7 +808,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool bf_ok;
 
 	tx_ind = skb_get_queue_mapping(skb);
-	ring = priv->tx_ring[tx_ind];
+	ring = priv->tx_ring[TX][tx_ind];
 
 	if (!priv->port_up)
 		goto tx_drop;
@@ -1101,7 +1102,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
 	BUILD_BUG_ON_MSG(ALIGN(CTRL_SIZE + DS_SIZE, TXBB_SIZE) != TXBB_SIZE,
 			 "mlx4_en_xmit_frame requires minimum size tx desc");
 
-	ring = priv->tx_ring[tx_ind];
+	ring = priv->tx_ring[TX_XDP][tx_ind];
 
 	if (!priv->port_up)
 		goto tx_drop;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 83c914a79f14..6e0693659f85 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -207,8 +207,10 @@ enum {
  */
 
 enum cq_type {
+	/* keep tx types first */
 	TX,
 	TX_XDP,
+#define MLX4_EN_NUM_TX_TYPES (TX_XDP + 1)
 	RX,
 };
 
@@ -373,7 +375,7 @@ struct mlx4_en_cq {
 
 struct mlx4_en_port_profile {
 	u32 flags;
-	u32 tx_ring_num;
+	u32 tx_ring_num[MLX4_EN_NUM_TX_TYPES];
 	u32 rx_ring_num;
 	u32 tx_ring_size;
 	u32 rx_ring_size;
@@ -570,17 +572,16 @@ struct mlx4_en_priv {
 	u32 flags;
 	u8 num_tx_rings_p_up;
 	u32 tx_work_limit;
-	u32 tx_ring_num;
+	u32 tx_ring_num[MLX4_EN_NUM_TX_TYPES];
 	u32 rx_ring_num;
 	u32 rx_skb_size;
 	struct mlx4_en_frag_info frag_info[MLX4_EN_MAX_RX_FRAGS];
 	u16 num_frags;
 	u16 log_rx_info;
-	int xdp_ring_num;
 
-	struct mlx4_en_tx_ring **tx_ring;
+	struct mlx4_en_tx_ring **tx_ring[MLX4_EN_NUM_TX_TYPES];
 	struct mlx4_en_rx_ring *rx_ring[MAX_RX_RINGS];
-	struct mlx4_en_cq **tx_cq;
+	struct mlx4_en_cq **tx_cq[MLX4_EN_NUM_TX_TYPES];
 	struct mlx4_en_cq *rx_cq[MAX_RX_RINGS];
 	struct mlx4_qp drop_qp;
 	struct work_struct rx_mode_task;
-- 
1.8.3.1
