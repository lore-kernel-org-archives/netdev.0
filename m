From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx5e: CQE compression
Date: Wed, 11 May 2016 00:29:14 +0300
Message-ID: <1462915756-18180-2-git-send-email-saeedm@mellanox.com>
References: <1462915756-18180-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52797 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752735AbcEJVcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:32:04 -0400
In-Reply-To: <1462915756-18180-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

CQE compression feature is meant to save PCIe bandwidth by
compressing few CQEs into smaller amount of bytes on PCIe.
CQE compression can be selectively enabled per CQ.  By default
is disabled for now and will be enabled later on.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  10 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 151 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   8 ++
 include/linux/mlx5/device.h                        |  34 +++++
 6 files changed, 211 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index bfa5daa..19f0d8d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -157,6 +157,8 @@ struct mlx5e_params {
 	u8  log_rq_size;
 	u16 num_channels;
 	u8  num_tc;
+	bool rx_cqe_compress_admin;
+	bool rx_cqe_compress;
 	u16 rx_cq_moderation_usec;
 	u16 rx_cq_moderation_pkts;
 	u16 tx_cq_moderation_usec;
@@ -202,6 +204,13 @@ struct mlx5e_cq {
 	struct mlx5e_channel      *channel;
 	struct mlx5e_priv         *priv;
 
+	/* cqe decompression */
+	struct mlx5_cqe64          title;
+	struct mlx5_mini_cqe8      mini_arr[MLX5_MINI_CQE_ARRAY_SIZE];
+	u8                         mini_arr_idx;
+	u16                        decmprs_left;
+	u16                        decmprs_wqe_counter;
+
 	/* control */
 	struct mlx5_wq_ctrl        wq_ctrl;
 } ____cacheline_aligned_in_smp;
@@ -616,6 +625,7 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv);
 void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv);
 int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr);
 int mlx5e_hwstamp_get(struct net_device *dev, struct ifreq *ifr);
+void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val);
 
 int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 			  u16 vid);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 2018eeb..847a8f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -93,6 +93,8 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	/* RX HW timestamp */
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
+		/* Reset CQE compression to Admin default */
+		mlx5e_modify_rx_cqe_compression(priv, priv->params.rx_cqe_compress_admin);
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_SOME:
@@ -108,6 +110,8 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		/* Disable CQE compression */
+		mlx5e_modify_rx_cqe_compression(priv, false);
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	default:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1c70e51..0ea4c03 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -114,6 +114,8 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_mpwqe_filler += rq_stats->mpwqe_filler;
 		s->rx_mpwqe_frag   += rq_stats->mpwqe_frag;
 		s->rx_buff_alloc_err += rq_stats->buff_alloc_err;
+		s->rx_cqe_compress_blks += rq_stats->cqe_compress_blks;
+		s->rx_cqe_compress_pkts += rq_stats->cqe_compress_pkts;
 
 		for (j = 0; j < priv->params.num_tc; j++) {
 			sq_stats = &priv->channel[i]->sq[j].stats;
@@ -1204,6 +1206,10 @@ static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
 	}
 
 	MLX5_SET(cqc, cqc, log_cq_size, log_cq_size);
+	if (priv->params.rx_cqe_compress) {
+		MLX5_SET(cqc, cqc, mini_cqe_res_format, MLX5_CQE_FORMAT_CSUM);
+		MLX5_SET(cqc, cqc, cqe_comp_en, 1);
+	}
 
 	mlx5e_build_common_cq_param(priv, param);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 23adfe2..c8b8d45 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -42,6 +42,143 @@ static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 	return tstamp->hwtstamp_config.rx_filter == HWTSTAMP_FILTER_ALL;
 }
 
+static inline void mlx5e_read_cqe_slot(struct mlx5e_cq *cq, u32 cqcc,
+				       void *data)
+{
+	u32 ci = cqcc & cq->wq.sz_m1;
+
+	memcpy(data, mlx5_cqwq_get_wqe(&cq->wq, ci), sizeof(struct mlx5_cqe64));
+}
+
+static inline void mlx5e_read_title_slot(struct mlx5e_rq *rq,
+					 struct mlx5e_cq *cq, u32 cqcc)
+{
+	mlx5e_read_cqe_slot(cq, cqcc, &cq->title);
+	cq->decmprs_left        = be32_to_cpu(cq->title.byte_cnt);
+	cq->decmprs_wqe_counter = be16_to_cpu(cq->title.wqe_counter);
+	rq->stats.cqe_compress_blks++;
+}
+
+static inline void mlx5e_read_mini_arr_slot(struct mlx5e_cq *cq, u32 cqcc)
+{
+	mlx5e_read_cqe_slot(cq, cqcc, cq->mini_arr);
+	cq->mini_arr_idx = 0;
+}
+
+static inline void mlx5e_cqes_update_owner(struct mlx5e_cq *cq, u32 cqcc, int n)
+{
+	u8 op_own = (cqcc >> cq->wq.log_sz) & 1;
+	u32 wq_sz = 1 << cq->wq.log_sz;
+	u32 ci = cqcc & cq->wq.sz_m1;
+	u32 ci_top = min_t(u32, wq_sz, ci + n);
+
+	for (; ci < ci_top; ci++, n--) {
+		struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(&cq->wq, ci);
+
+		cqe->op_own = op_own;
+	}
+
+	if (unlikely(ci == wq_sz)) {
+		op_own = !op_own;
+		for (ci = 0; ci < n; ci++) {
+			struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(&cq->wq, ci);
+
+			cqe->op_own = op_own;
+		}
+	}
+}
+
+static inline void mlx5e_decompress_cqe(struct mlx5e_rq *rq,
+					struct mlx5e_cq *cq, u32 cqcc)
+{
+	u16 wqe_cnt_step;
+
+	cq->title.byte_cnt     = cq->mini_arr[cq->mini_arr_idx].byte_cnt;
+	cq->title.check_sum    = cq->mini_arr[cq->mini_arr_idx].checksum;
+	cq->title.op_own      &= 0xf0;
+	cq->title.op_own      |= 0x01 & (cqcc >> cq->wq.log_sz);
+	cq->title.wqe_counter  = cpu_to_be16(cq->decmprs_wqe_counter);
+
+	wqe_cnt_step =
+		rq->wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ ?
+		mpwrq_get_cqe_consumed_strides(&cq->title) : 1;
+	cq->decmprs_wqe_counter =
+		(cq->decmprs_wqe_counter + wqe_cnt_step) & rq->wq.sz_m1;
+}
+
+static inline void mlx5e_decompress_cqe_no_hash(struct mlx5e_rq *rq,
+						struct mlx5e_cq *cq, u32 cqcc)
+{
+	mlx5e_decompress_cqe(rq, cq, cqcc);
+	cq->title.rss_hash_type   = 0;
+	cq->title.rss_hash_result = 0;
+}
+
+static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
+					     struct mlx5e_cq *cq,
+					     int update_owner_only,
+					     int budget_rem)
+{
+	u32 cqcc = cq->wq.cc + update_owner_only;
+	u32 cqe_count;
+	u32 i;
+
+	cqe_count = min_t(u32, cq->decmprs_left, budget_rem);
+
+	for (i = update_owner_only; i < cqe_count;
+	     i++, cq->mini_arr_idx++, cqcc++) {
+		if (unlikely(cq->mini_arr_idx == MLX5_MINI_CQE_ARRAY_SIZE))
+			mlx5e_read_mini_arr_slot(cq, cqcc);
+
+		mlx5e_decompress_cqe_no_hash(rq, cq, cqcc);
+		rq->handle_rx_cqe(rq, &cq->title);
+	}
+	mlx5e_cqes_update_owner(cq, cq->wq.cc, cqcc - cq->wq.cc);
+	cq->wq.cc = cqcc;
+	cq->decmprs_left -= cqe_count;
+	rq->stats.cqe_compress_pkts += cqe_count;
+
+	return cqe_count;
+}
+
+static inline u32 mlx5e_decompress_cqes_start(struct mlx5e_rq *rq,
+					      struct mlx5e_cq *cq,
+					      int budget_rem)
+{
+	mlx5e_read_title_slot(rq, cq, cq->wq.cc);
+	mlx5e_read_mini_arr_slot(cq, cq->wq.cc + 1);
+	mlx5e_decompress_cqe(rq, cq, cq->wq.cc);
+	rq->handle_rx_cqe(rq, &cq->title);
+	cq->mini_arr_idx++;
+
+	return mlx5e_decompress_cqes_cont(rq, cq, 1, budget_rem) - 1;
+}
+
+void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
+{
+	bool was_opened;
+
+	if (!MLX5_CAP_GEN(priv->mdev, cqe_compression))
+		return;
+
+	mutex_lock(&priv->state_lock);
+
+	if (priv->params.rx_cqe_compress == val)
+		goto unlock;
+
+	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	if (was_opened)
+		mlx5e_close_locked(priv->netdev);
+
+	priv->params.rx_cqe_compress = val;
+
+	if (was_opened)
+		mlx5e_open_locked(priv->netdev);
+
+unlock:
+	mutex_unlock(&priv->state_lock);
+}
+
 int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 {
 	struct sk_buff *skb;
@@ -738,14 +875,24 @@ mpwrq_cqe_out:
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
-	int work_done;
+	int work_done = 0;
 
-	for (work_done = 0; work_done < budget; work_done++) {
+	if (cq->decmprs_left)
+		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget);
+
+	for (; work_done < budget; work_done++) {
 		struct mlx5_cqe64 *cqe = mlx5e_get_cqe(cq);
 
 		if (!cqe)
 			break;
 
+		if (mlx5_get_cqe_format(cqe) == MLX5_COMPRESSED) {
+			work_done +=
+				mlx5e_decompress_cqes_start(rq, cq,
+							    budget - work_done);
+			continue;
+		}
+
 		mlx5_cqwq_pop(&cq->wq);
 
 		rq->handle_rx_cqe(rq, cqe);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 115752b..83bc32b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -72,6 +72,8 @@ struct mlx5e_sw_stats {
 	u64 rx_mpwqe_filler;
 	u64 rx_mpwqe_frag;
 	u64 rx_buff_alloc_err;
+	u64 rx_cqe_compress_blks;
+	u64 rx_cqe_compress_pkts;
 
 	/* Special handling counters */
 	u64 link_down_events;
@@ -101,6 +103,8 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_filler) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_mpwqe_frag) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_buff_alloc_err) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_blks) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_pkts) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, link_down_events) },
 };
 
@@ -283,6 +287,8 @@ struct mlx5e_rq_stats {
 	u64 mpwqe_filler;
 	u64 mpwqe_frag;
 	u64 buff_alloc_err;
+	u64 cqe_compress_blks;
+	u64 cqe_compress_pkts;
 };
 
 static const struct counter_desc rq_stats_desc[] = {
@@ -297,6 +303,8 @@ static const struct counter_desc rq_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, mpwqe_filler) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, mpwqe_frag) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, buff_alloc_err) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, cqe_compress_blks) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, cqe_compress_pkts) },
 };
 
 struct mlx5e_sq_stats {
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index ee0d5a9..035abdf 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -685,6 +685,40 @@ struct mlx5_cqe64 {
 	u8		op_own;
 };
 
+struct mlx5_mini_cqe8 {
+	union {
+		__be32 rx_hash_result;
+		struct {
+			__be16 checksum;
+			__be16 rsvd;
+		};
+		struct {
+			__be16 wqe_counter;
+			u8  s_wqe_opcode;
+			u8  reserved;
+		} s_wqe_info;
+	};
+	__be32 byte_cnt;
+};
+
+enum {
+	MLX5_NO_INLINE_DATA,
+	MLX5_INLINE_DATA32_SEG,
+	MLX5_INLINE_DATA64_SEG,
+	MLX5_COMPRESSED,
+};
+
+enum {
+	MLX5_CQE_FORMAT_CSUM = 0x1,
+};
+
+#define MLX5_MINI_CQE_ARRAY_SIZE 8
+
+static inline int mlx5_get_cqe_format(struct mlx5_cqe64 *cqe)
+{
+	return (cqe->op_own >> 2) & 0x3;
+}
+
 static inline int get_cqe_lro_tcppsh(struct mlx5_cqe64 *cqe)
 {
 	return (cqe->lro_tcppsh_abort_dupack >> 6) & 1;
-- 
2.8.0
