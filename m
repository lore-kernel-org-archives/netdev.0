From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf programs support
Date: Wed,  7 Sep 2016 15:42:29 +0300
Message-ID: <1473252152-11379-9-git-send-email-saeedm@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: iovisor-dev <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45186 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756911AbcIGMmx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 08:42:53 -0400
In-Reply-To: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx5e driver.

When XDP is on we make sure to change channels RQs type to
MLX5_WQ_TYPE_LINKED_LIST rather than "striding RQ" type to
ensure "page per packet".

On XDP set, we fail if HW LRO is set and request from user to turn it
off.  Since on ConnectX4-LX HW LRO is always on by default, this will be
annoying, but we prefer not to enforce LRO off from XDP set function.

Full channels reset (close/open) is required only when setting XDP
on/off.

When XDP set is called just to exchange programs, we will update
each RQ xdp program on the fly and for synchronization with current
data path RX activity of that RQ, we temporally disable that RQ and
ensure RX path is not running, quickly update and re-enable that RQ,
for that we do:
	- rq.state = disabled
	- napi_synnchronize
	- xchg(rq->xdp_prg)
	- rq.state = enabled
	- napi_schedule // Just in case we've missed an IRQ

Packet rate performance testing was done with pktgen 64B packets and on
TX side and, TC drop action on RX side compared to XDP fast drop.

CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz

Comparison is done between:
	1. Baseline, Before this patch with TC drop action
	2. This patch with TC drop action
	3. This patch with XDP RX fast drop

Streams    Baseline(TC drop)    TC drop    XDP fast Drop
--------------------------------------------------------------
1           5.51Mpps            5.14Mpps     13.5Mpps
2           11.5Mpps            10.0Mpps     25.1Mpps
4           16.3Mpps            17.2Mpps     35.4Mpps
8           29.6Mpps            28.2Mpps     45.8Mpps*
16          34.0Mpps            30.1Mpps     45.8Mpps*

It seems that there is around ~5% degradation between Baseline
and this patch with single stream when comparing packet rate with TC drop,
it might be related to XDP code overhead or new cache misses added by
XDP code.

*My xmitter was limited to 45Mpps, so for 8/16 streams the xmitter is
the bottlenick and it seems that XDP drop can handle more.

Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 100 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  26 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   4 +
 4 files changed, 130 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 7dfb34e..729bae8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -334,6 +334,7 @@ struct mlx5e_rq {
 	int                    ix;
 
 	struct mlx5e_rx_am     am; /* Adaptive Moderation */
+	struct bpf_prog       *xdp_prog;
 
 	/* control */
 	struct mlx5_wq_ctrl    wq_ctrl;
@@ -627,6 +628,7 @@ struct mlx5e_priv {
 	/* priv data path fields - start */
 	struct mlx5e_sq            **txq_to_sq_map;
 	int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
+	struct bpf_prog *xdp_prog;
 	/* priv data path fields - end */
 
 	unsigned long              state;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a6a2e60..dab8486 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -34,6 +34,7 @@
 #include <net/pkt_cls.h>
 #include <linux/mlx5/fs.h>
 #include <net/vxlan.h>
+#include <linux/bpf.h>
 #include "en.h"
 #include "en_tc.h"
 #include "eswitch.h"
@@ -104,7 +105,8 @@ static void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type)
 
 static void mlx5e_set_rq_priv_params(struct mlx5e_priv *priv)
 {
-	u8 rq_type = mlx5e_check_fragmented_striding_rq_cap(priv->mdev) ?
+	u8 rq_type = mlx5e_check_fragmented_striding_rq_cap(priv->mdev) &&
+		    !priv->xdp_prog ?
 		    MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ :
 		    MLX5_WQ_TYPE_LINKED_LIST;
 	mlx5e_set_rq_type_params(priv, rq_type);
@@ -177,6 +179,7 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_csum_none	+= rq_stats->csum_none;
 		s->rx_csum_complete += rq_stats->csum_complete;
 		s->rx_csum_unnecessary_inner += rq_stats->csum_unnecessary_inner;
+		s->rx_xdp_drop += rq_stats->xdp_drop;
 		s->rx_wqe_err   += rq_stats->wqe_err;
 		s->rx_mpwqe_filler += rq_stats->mpwqe_filler;
 		s->rx_buff_alloc_err += rq_stats->buff_alloc_err;
@@ -476,6 +479,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->channel = c;
 	rq->ix      = c->ix;
 	rq->priv    = c->priv;
+	rq->xdp_prog = priv->xdp_prog;
 
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
@@ -539,6 +543,9 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->page_cache.head = 0;
 	rq->page_cache.tail = 0;
 
+	if (rq->xdp_prog)
+		bpf_prog_add(rq->xdp_prog, 1);
+
 	return 0;
 
 err_rq_wq_destroy:
@@ -551,6 +558,9 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 {
 	int i;
 
+	if (rq->xdp_prog)
+		bpf_prog_put(rq->xdp_prog);
+
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		mlx5e_rq_free_mpwqe_info(rq);
@@ -2953,6 +2963,92 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 		schedule_work(&priv->tx_timeout_work);
 }
 
+static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct bpf_prog *old_prog;
+	int err = 0;
+	bool reset, was_opened;
+	int i;
+
+	mutex_lock(&priv->state_lock);
+
+	if ((netdev->features & NETIF_F_LRO) && prog) {
+		netdev_warn(netdev, "can't set XDP while LRO is on, disable LRO first\n");
+		err = -EINVAL;
+		goto unlock;
+	}
+
+	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	/* no need for full reset when exchanging programs */
+	reset = (!priv->xdp_prog || !prog);
+
+	if (was_opened && reset)
+		mlx5e_close_locked(netdev);
+
+	/* exchange programs */
+	old_prog = xchg(&priv->xdp_prog, prog);
+	if (prog)
+		bpf_prog_add(prog, 1);
+	if (old_prog)
+		bpf_prog_put(old_prog);
+
+	if (reset) /* change RQ type according to priv->xdp_prog */
+		mlx5e_set_rq_priv_params(priv);
+
+	if (was_opened && reset)
+		mlx5e_open_locked(netdev);
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state) || reset)
+		goto unlock;
+
+	/* exchanging programs w/o reset, we update ref counts on behalf
+	 * of the channels RQs here.
+	 */
+	bpf_prog_add(prog, priv->params.num_channels);
+	for (i = 0; i < priv->params.num_channels; i++) {
+		struct mlx5e_channel *c = priv->channel[i];
+
+		set_bit(MLX5E_RQ_STATE_FLUSH, &c->rq.state);
+		napi_synchronize(&c->napi);
+		/* prevent mlx5e_poll_rx_cq from accessing rq->xdp_prog */
+
+		old_prog = xchg(&c->rq.xdp_prog, prog);
+
+		clear_bit(MLX5E_RQ_STATE_FLUSH, &c->rq.state);
+		/* napi_schedule in case we have missed anything */
+		set_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
+		napi_schedule(&c->napi);
+
+		if (old_prog)
+			bpf_prog_put(old_prog);
+	}
+
+unlock:
+	mutex_unlock(&priv->state_lock);
+	return err;
+}
+
+static bool mlx5e_xdp_attached(struct net_device *dev)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	return !!priv->xdp_prog;
+}
+
+static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return mlx5e_xdp_set(dev, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = mlx5e_xdp_attached(dev);
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
@@ -2972,6 +3068,7 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
 	.ndo_tx_timeout          = mlx5e_tx_timeout,
+	.ndo_xdp		 = mlx5e_xdp,
 };
 
 static const struct net_device_ops mlx5e_netdev_ops_sriov = {
@@ -3003,6 +3100,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
 	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
 	.ndo_tx_timeout          = mlx5e_tx_timeout,
+	.ndo_xdp		 = mlx5e_xdp,
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 95f9b1e..cde34c8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -624,8 +624,20 @@ static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 	napi_gro_receive(rq->cq.napi, skb);
 }
 
+static inline enum xdp_action mlx5e_xdp_handle(struct mlx5e_rq *rq,
+					       const struct bpf_prog *prog,
+					       void *data, u32 len)
+{
+	struct xdp_buff xdp;
+
+	xdp.data = data;
+	xdp.data_end = xdp.data + len;
+	return bpf_prog_run_xdp(prog, &xdp);
+}
+
 void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 {
+	struct bpf_prog *xdp_prog = READ_ONCE(rq->xdp_prog);
 	struct mlx5e_dma_info *di;
 	struct mlx5e_rx_wqe *wqe;
 	__be16 wqe_counter_be;
@@ -646,6 +658,7 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 				      rq->buff.wqe_sz,
 				      DMA_FROM_DEVICE);
 	prefetch(va + MLX5_RX_HEADROOM);
+	cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
 
 	if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
 		rq->stats.wqe_err++;
@@ -653,6 +666,18 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto wq_ll_pop;
 	}
 
+	if (xdp_prog) {
+		enum xdp_action act =
+			mlx5e_xdp_handle(rq, xdp_prog, va + MLX5_RX_HEADROOM,
+					 cqe_bcnt);
+
+		if (act != XDP_PASS) {
+			rq->stats.xdp_drop++;
+			mlx5e_page_release(rq, di, true);
+			goto wq_ll_pop;
+		}
+	}
+
 	skb = build_skb(va, RQ_PAGE_SIZE(rq));
 	if (unlikely(!skb)) {
 		rq->stats.buff_alloc_err++;
@@ -664,7 +689,6 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	page_ref_inc(di->page);
 	mlx5e_page_release(rq, di, true);
 
-	cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
 	skb_reserve(skb, MLX5_RX_HEADROOM);
 	skb_put(skb, cqe_bcnt);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 6af8d79..084d6c8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -65,6 +65,7 @@ struct mlx5e_sw_stats {
 	u64 rx_csum_none;
 	u64 rx_csum_complete;
 	u64 rx_csum_unnecessary_inner;
+	u64 rx_xdp_drop;
 	u64 tx_csum_partial;
 	u64 tx_csum_partial_inner;
 	u64 tx_queue_stopped;
@@ -100,6 +101,7 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_none) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_complete) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_unnecessary_inner) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_drop) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial_inner) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_stopped) },
@@ -278,6 +280,7 @@ struct mlx5e_rq_stats {
 	u64 csum_none;
 	u64 lro_packets;
 	u64 lro_bytes;
+	u64 xdp_drop;
 	u64 wqe_err;
 	u64 mpwqe_filler;
 	u64 buff_alloc_err;
@@ -295,6 +298,7 @@ static const struct counter_desc rq_stats_desc[] = {
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_complete) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_unnecessary_inner) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_none) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_drop) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_packets) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_bytes) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, wqe_err) },
-- 
2.7.4
