From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 11/12] net/mlx5e: Fix checksum handling for non-stripped vlan packets
Date: Fri, 22 Apr 2016 22:00:46 +0300
Message-ID: <1461351647-27412-12-git-send-email-saeedm@mellanox.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36912 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751690AbcDVTCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:06 -0400
In-Reply-To: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now as rx-vlan offload can be disabled, packets can be received
with vlan tag not stripped, which means is_first_ethertype_ip will
return false, for that we need to check if the hardware reported
csum OK so we will report CHECKSUM_UNNECESSARY for those packets.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   20 ++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |    8 +++++-
 include/linux/mlx5/device.h                        |   21 +++++++++++++++----
 4 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 6c9c10c..5bad17d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -109,6 +109,7 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->lro_bytes	+= rq_stats->lro_bytes;
 		s->rx_csum_none	+= rq_stats->csum_none;
 		s->rx_csum_sw	+= rq_stats->csum_sw;
+		s->rx_csum_inner += rq_stats->csum_inner;
 		s->rx_wqe_err   += rq_stats->wqe_err;
 		s->rx_mpwqe_filler += rq_stats->mpwqe_filler;
 		s->rx_mpwqe_frag   += rq_stats->mpwqe_frag;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 918b7c7..23adfe2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -543,16 +543,26 @@ static inline void mlx5e_handle_csum(struct net_device *netdev,
 
 	if (lro) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (likely(is_first_ethertype_ip(skb))) {
+		return;
+	}
+
+	if (is_first_ethertype_ip(skb)) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
 		skb->csum = csum_unfold((__force __sum16)cqe->check_sum);
 		rq->stats.csum_sw++;
-	} else {
-		goto csum_none;
+		return;
 	}
 
-	return;
-
+	if (likely((cqe->hds_ip_ext & CQE_L3_OK) &&
+		   (cqe->hds_ip_ext & CQE_L4_OK))) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		if (cqe_is_tunneled(cqe)) {
+			skb->csum_level = 1;
+			skb->encapsulation = 1;
+			rq->stats.csum_inner++;
+		}
+		return;
+	}
 csum_none:
 	skb->ip_summed = CHECKSUM_NONE;
 	rq->stats.csum_none++;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 7cd8cb4..115752b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -62,6 +62,7 @@ struct mlx5e_sw_stats {
 	u64 rx_csum_good;
 	u64 rx_csum_none;
 	u64 rx_csum_sw;
+	u64 rx_csum_inner;
 	u64 tx_csum_offload;
 	u64 tx_csum_inner;
 	u64 tx_queue_stopped;
@@ -90,6 +91,7 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_good) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_none) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_sw) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_inner) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_offload) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_inner) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_stopped) },
@@ -272,8 +274,9 @@ static const struct counter_desc pport_per_prio_pfc_stats_desc[] = {
 struct mlx5e_rq_stats {
 	u64 packets;
 	u64 bytes;
-	u64 csum_none;
 	u64 csum_sw;
+	u64 csum_inner;
+	u64 csum_none;
 	u64 lro_packets;
 	u64 lro_bytes;
 	u64 wqe_err;
@@ -285,8 +288,9 @@ struct mlx5e_rq_stats {
 static const struct counter_desc rq_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, packets) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, bytes) },
-	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, csum_none) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, csum_sw) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, csum_inner) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, csum_none) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, lro_packets) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, lro_bytes) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_rq_stats, wqe_err) },
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 942bcca..6bd429b 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -645,8 +645,9 @@ struct mlx5_err_cqe {
 };
 
 struct mlx5_cqe64 {
-	u8              rsvd0[2];
-	__be16          wqe_id;
+	u8		outer_l3_tunneled;
+	u8		rsvd0;
+	__be16		wqe_id;
 	u8		lro_tcppsh_abort_dupack;
 	u8		lro_min_ttl;
 	__be16		lro_tcp_win;
@@ -659,7 +660,7 @@ struct mlx5_cqe64 {
 	__be16		slid;
 	__be32		flags_rqpn;
 	u8		hds_ip_ext;
-	u8		l4_hdr_type_etc;
+	u8		l4_l3_hdr_type;
 	__be16		vlan_info;
 	__be32		srqn; /* [31:24]: lro_num_seg, [23:0]: srqn */
 	__be32		imm_inval_pkey;
@@ -680,12 +681,22 @@ static inline int get_cqe_lro_tcppsh(struct mlx5_cqe64 *cqe)
 
 static inline u8 get_cqe_l4_hdr_type(struct mlx5_cqe64 *cqe)
 {
-	return (cqe->l4_hdr_type_etc >> 4) & 0x7;
+	return (cqe->l4_l3_hdr_type >> 4) & 0x7;
+}
+
+static inline u8 get_cqe_l3_hdr_type(struct mlx5_cqe64 *cqe)
+{
+	return (cqe->l4_l3_hdr_type >> 2) & 0x3;
+}
+
+static inline u8 cqe_is_tunneled(struct mlx5_cqe64 *cqe)
+{
+	return cqe->outer_l3_tunneled & 0x1;
 }
 
 static inline int cqe_has_vlan(struct mlx5_cqe64 *cqe)
 {
-	return !!(cqe->l4_hdr_type_etc & 0x1);
+	return !!(cqe->l4_l3_hdr_type & 0x1);
 }
 
 static inline u64 get_cqe_ts(struct mlx5_cqe64 *cqe)
-- 
1.7.1
