From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v9 09/11] net/mlx4_en: add xdp forwarding and data write support
Date: Fri, 15 Jul 2016 16:28:56 -0700
Message-ID: <1468625338-32391-10-git-send-email-bblanco@plumgrid.com>
References: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35409 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbcGOX3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:29:38 -0400
Received: by mail-pf0-f180.google.com with SMTP id c2so45563649pfa.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:29:38 -0700 (PDT)
In-Reply-To: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user will now be able to loop packets back out of the same port using
a bpf program attached to xdp hook. Updates to the packet contents from
the bpf program is also supported.

For the packet write feature to work, the rx buffers are now mapped as
bidirectional when the page is allocated. This occurs only when the xdp
hook is active.

When the program returns a TX action, enqueue the packet directly to a
dedicated tx ring, so as to avoid completely any locking. This requires
the tx ring to be allocated 1:1 for each rx ring, as well as the tx
completion running in the same softirq.

Upon tx completion, this dedicated tx ring recycles pages without
unmapping directly back to the original rx ring. In steady state tx/drop
workload, effectively 0 page allocs/frees will occur.

In order to separate out the paths between free and recycle, a
free_tx_desc func pointer is introduced that is optionally updated
whenever recycle_ring is activated. By default the original free
function is always initialized.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   9 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  34 ++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  14 +++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 140 +++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  28 ++++-
 5 files changed, 217 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 51a2e82..f6c2625 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1722,6 +1722,12 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	    !channel->tx_count || !channel->rx_count)
 		return -EINVAL;
 
+	if (channel->tx_count * MLX4_EN_NUM_UP <= priv->rsv_tx_rings) {
+		en_err(priv, "Minimum %d tx channels required with XDP on\n",
+		       priv->rsv_tx_rings / MLX4_EN_NUM_UP + 1);
+		return -EINVAL;
+	}
+
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
@@ -1740,7 +1746,8 @@ static int mlx4_en_set_channels(struct net_device *dev,
 		goto out;
 	}
 
-	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
+	netif_set_real_num_tx_queues(dev, priv->tx_ring_num -
+							priv->rsv_tx_rings);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
 	if (dev->num_tc)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e54541e..a1542a1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1522,6 +1522,24 @@ static void mlx4_en_free_affinity_hint(struct mlx4_en_priv *priv, int ring_idx)
 	free_cpumask_var(priv->rx_ring[ring_idx]->affinity_mask);
 }
 
+static void mlx4_en_init_recycle_ring(struct mlx4_en_priv *priv,
+				      int tx_ring_idx)
+{
+	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[tx_ring_idx];
+	int rr_index;
+
+	rr_index = (priv->rsv_tx_rings - priv->tx_ring_num) + tx_ring_idx;
+	if (rr_index >= 0) {
+		tx_ring->free_tx_desc = mlx4_en_recycle_tx_desc;
+		tx_ring->recycle_ring = priv->rx_ring[rr_index];
+		en_dbg(DRV, priv,
+		       "Set tx_ring[%d]->recycle_ring = rx_ring[%d]\n",
+		       tx_ring_idx, rr_index);
+	} else {
+		tx_ring->recycle_ring = NULL;
+	}
+}
+
 int mlx4_en_start_port(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -1644,6 +1662,8 @@ int mlx4_en_start_port(struct net_device *dev)
 		}
 		tx_ring->tx_queue = netdev_get_tx_queue(dev, i);
 
+		mlx4_en_init_recycle_ring(priv, i);
+
 		/* Arm CQ for TX completions */
 		mlx4_en_arm_cq(priv, cq);
 
@@ -2534,9 +2554,12 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct bpf_prog *old_prog;
+	int rsv_tx_rings;
 	int port_up = 0;
 	int err;
 
+	rsv_tx_rings = prog ? ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP) : 0;
+
 	/* No need to reconfigure buffers when simply swapping the
 	 * program for a new one.
 	 */
@@ -2555,12 +2578,23 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		return -EOPNOTSUPP;
 	}
 
+	if (priv->tx_ring_num < rsv_tx_rings + MLX4_EN_NUM_UP) {
+		en_err(priv,
+		       "Minimum %d tx channels required to run XDP\n",
+		       (rsv_tx_rings + MLX4_EN_NUM_UP) / MLX4_EN_NUM_UP);
+		return -EINVAL;
+	}
+
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
 		mlx4_en_stop_port(dev, 1);
 	}
 
+	priv->rsv_tx_rings = rsv_tx_rings;
+	netif_set_real_num_tx_queues(dev, priv->tx_ring_num -
+							priv->rsv_tx_rings);
+
 	old_prog = xchg(&priv->prog, prog);
 	if (old_prog)
 		bpf_prog_put(old_prog);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6020c37..64b5bc7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -780,7 +780,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
 	struct bpf_prog *prog;
+	int doorbell_pending;
 	struct sk_buff *skb;
+	int tx_index;
 	int index;
 	int nr;
 	unsigned int length;
@@ -797,6 +799,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		return polled;
 
 	prog = READ_ONCE(priv->prog);
+	doorbell_pending = 0;
+	tx_index = (priv->tx_ring_num - priv->rsv_tx_rings) + cq->ring;
 
 	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
 	 * descriptor offset can be deduced from the CQE index instead of
@@ -895,6 +899,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			switch (act) {
 			case XDP_PASS:
 				break;
+			case XDP_TX:
+				if (!mlx4_en_xmit_frame(frags, dev,
+							length, tx_index,
+							&doorbell_pending))
+					goto consumed;
+				break;
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
@@ -1065,6 +1075,9 @@ consumed:
 	}
 
 out:
+	if (doorbell_pending)
+		mlx4_en_xmit_doorbell(priv->tx_ring[tx_index]);
+
 	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
 	mlx4_cq_set_ci(&cq->mcq);
 	wmb(); /* ensure HW sees CQ consumer before we post new buffers */
@@ -1144,6 +1157,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 	 * This only works when num_frags == 1.
 	 */
 	if (priv->prog) {
+		dma_dir = PCI_DMA_BIDIRECTIONAL;
 		/* This will gain efficient xdp frame recycling at the expense
 		 * of more costly truesize accounting
 		 */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c29191e..5d8452d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -196,6 +196,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->last_nr_txbb = 1;
 	memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
 	memset(ring->buf, 0, ring->buf_size);
+	ring->free_tx_desc = mlx4_en_free_tx_desc;
 
 	ring->qp_state = MLX4_QP_STATE_RST;
 	ring->doorbell_qpn = cpu_to_be32(ring->qp.qpn << 8);
@@ -265,10 +266,10 @@ static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
 }
 
 
-static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
-				struct mlx4_en_tx_ring *ring,
-				int index, u8 owner, u64 timestamp,
-				int napi_mode)
+u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
+			 struct mlx4_en_tx_ring *ring,
+			 int index, u8 owner, u64 timestamp,
+			 int napi_mode)
 {
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
 	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
@@ -344,6 +345,27 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 	return tx_info->nr_txbb;
 }
 
+u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
+			    struct mlx4_en_tx_ring *ring,
+			    int index, u8 owner, u64 timestamp,
+			    int napi_mode)
+{
+	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
+	struct mlx4_en_rx_alloc frame = {
+		.page = tx_info->page,
+		.dma = tx_info->map0_dma,
+		.page_offset = 0,
+		.page_size = PAGE_SIZE,
+	};
+
+	if (!mlx4_en_rx_recycle(ring->recycle_ring, &frame)) {
+		dma_unmap_page(priv->ddev, tx_info->map0_dma,
+			       PAGE_SIZE, priv->frag_info[0].dma_dir);
+		put_page(tx_info->page);
+	}
+
+	return tx_info->nr_txbb;
+}
 
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 {
@@ -362,7 +384,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	}
 
 	while (ring->cons != ring->prod) {
-		ring->last_nr_txbb = mlx4_en_free_tx_desc(priv, ring,
+		ring->last_nr_txbb = ring->free_tx_desc(priv, ring,
 						ring->cons & ring->size_mask,
 						!!(ring->cons & ring->size), 0,
 						0 /* Non-NAPI caller */);
@@ -444,7 +466,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 				timestamp = mlx4_en_get_cqe_ts(cqe);
 
 			/* free next descriptor */
-			last_nr_txbb = mlx4_en_free_tx_desc(
+			last_nr_txbb = ring->free_tx_desc(
 					priv, ring, ring_index,
 					!!((ring_cons + txbbs_skipped) &
 					ring->size), timestamp, napi_budget);
@@ -476,6 +498,9 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
 	ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
 
+	if (ring->free_tx_desc == mlx4_en_recycle_tx_desc)
+		return done < budget;
+
 	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
 
 	/* Wakeup Tx queue if this stopped, and ring is not full.
@@ -1055,3 +1080,106 @@ tx_drop:
 	return NETDEV_TX_OK;
 }
 
+netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
+			       struct net_device *dev, unsigned int length,
+			       int tx_ind, int *doorbell_pending)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	union mlx4_wqe_qpn_vlan	qpn_vlan = {};
+	struct mlx4_en_tx_ring *ring;
+	struct mlx4_en_tx_desc *tx_desc;
+	struct mlx4_wqe_data_seg *data;
+	struct mlx4_en_tx_info *tx_info;
+	int index, bf_index;
+	bool send_doorbell;
+	int nr_txbb = 1;
+	bool stop_queue;
+	dma_addr_t dma;
+	int real_size;
+	__be32 op_own;
+	u32 ring_cons;
+	bool bf_ok;
+
+	BUILD_BUG_ON_MSG(ALIGN(CTRL_SIZE + DS_SIZE, TXBB_SIZE) != TXBB_SIZE,
+			 "mlx4_en_xmit_frame requires minimum size tx desc");
+
+	ring = priv->tx_ring[tx_ind];
+
+	if (!priv->port_up)
+		goto tx_drop;
+
+	if (mlx4_en_is_tx_ring_full(ring))
+		goto tx_drop;
+
+	/* fetch ring->cons far ahead before needing it to avoid stall */
+	ring_cons = READ_ONCE(ring->cons);
+
+	index = ring->prod & ring->size_mask;
+	tx_info = &ring->tx_info[index];
+
+	bf_ok = ring->bf_enabled;
+
+	/* Track current inflight packets for performance analysis */
+	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
+			 (u32)(ring->prod - ring_cons - 1));
+
+	bf_index = ring->prod;
+	tx_desc = ring->buf + index * TXBB_SIZE;
+	data = &tx_desc->data;
+
+	dma = frame->dma;
+
+	tx_info->page = frame->page;
+	frame->page = NULL;
+	tx_info->map0_dma = dma;
+	tx_info->map0_byte_count = length;
+	tx_info->nr_txbb = nr_txbb;
+	tx_info->nr_bytes = max_t(unsigned int, length, ETH_ZLEN);
+	tx_info->data_offset = (void *)data - (void *)tx_desc;
+	tx_info->ts_requested = 0;
+	tx_info->nr_maps = 1;
+	tx_info->linear = 1;
+	tx_info->inl = 0;
+
+	dma_sync_single_for_device(priv->ddev, dma, length, PCI_DMA_TODEVICE);
+
+	data->addr = cpu_to_be64(dma);
+	data->lkey = ring->mr_key;
+	dma_wmb();
+	data->byte_count = cpu_to_be32(length);
+
+	/* tx completion can avoid cache line miss for common cases */
+	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
+
+	op_own = cpu_to_be32(MLX4_OPCODE_SEND) |
+		((ring->prod & ring->size) ?
+		 cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
+
+	ring->packets++;
+	ring->bytes += tx_info->nr_bytes;
+	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, length);
+
+	ring->prod += nr_txbb;
+
+	stop_queue = mlx4_en_is_tx_ring_full(ring);
+	send_doorbell = stop_queue ||
+				*doorbell_pending > MLX4_EN_DOORBELL_BUDGET;
+	bf_ok &= send_doorbell;
+
+	real_size = ((CTRL_SIZE + nr_txbb * DS_SIZE) / 16) & 0x3f;
+
+	if (bf_ok)
+		qpn_vlan.bf_qpn = ring->doorbell_qpn | cpu_to_be32(real_size);
+	else
+		qpn_vlan.fence_size = real_size;
+
+	mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, bf_index,
+			      op_own, bf_ok, send_doorbell);
+	*doorbell_pending = send_doorbell ? 0 : *doorbell_pending + 1;
+
+	return NETDEV_TX_OK;
+
+tx_drop:
+	ring->tx_dropped++;
+	return NETDEV_TX_BUSY;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 948d7a1..31c6e7d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -132,6 +132,7 @@ enum {
 					 MLX4_EN_NUM_UP)
 
 #define MLX4_EN_DEFAULT_TX_WORK		256
+#define MLX4_EN_DOORBELL_BUDGET		8
 
 /* Target number of packets to coalesce with interrupt moderation */
 #define MLX4_EN_RX_COAL_TARGET	44
@@ -219,7 +220,10 @@ enum cq_type {
 
 
 struct mlx4_en_tx_info {
-	struct sk_buff *skb;
+	union {
+		struct sk_buff *skb;
+		struct page *page;
+	};
 	dma_addr_t	map0_dma;
 	u32		map0_byte_count;
 	u32		nr_txbb;
@@ -265,6 +269,8 @@ struct mlx4_en_page_cache {
 	struct mlx4_en_rx_alloc buf[MLX4_EN_CACHE_SIZE];
 };
 
+struct mlx4_en_priv;
+
 struct mlx4_en_tx_ring {
 	/* cache line used and dirtied in tx completion
 	 * (mlx4_en_free_tx_buf())
@@ -298,6 +304,11 @@ struct mlx4_en_tx_ring {
 	__be32			mr_key;
 	void			*buf;
 	struct mlx4_en_tx_info	*tx_info;
+	struct mlx4_en_rx_ring	*recycle_ring;
+	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
+						struct mlx4_en_tx_ring *ring,
+						int index, u8 owner,
+						u64 timestamp, int napi_mode);
 	u8			*bounce_buf;
 	struct mlx4_qp_context	context;
 	int			qpn;
@@ -604,6 +615,7 @@ struct mlx4_en_priv {
 	struct hwtstamp_config hwtstamp_config;
 	u32 counter_index;
 	struct bpf_prog *prog;
+	int rsv_tx_rings;
 
 #ifdef CONFIG_MLX4_EN_DCB
 #define MLX4_EN_DCB_ENABLED	0x3
@@ -677,6 +689,12 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq);
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 			 void *accel_priv, select_queue_fallback_t fallback);
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
+			       struct net_device *dev, unsigned int length,
+			       int tx_ind, int *doorbell_pending);
+void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
+bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
+			struct mlx4_en_rx_alloc *frame);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_tx_ring **pring,
@@ -705,6 +723,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
 			  int budget);
 int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
 int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget);
+u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
+			 struct mlx4_en_tx_ring *ring,
+			 int index, u8 owner, u64 timestamp,
+			 int napi_mode);
+u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
+			    struct mlx4_en_tx_ring *ring,
+			    int index, u8 owner, u64 timestamp,
+			    int napi_mode);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 		int is_tx, int rss, int qpn, int cqn, int user_prio,
 		struct mlx4_qp_context *context);
-- 
2.8.2
