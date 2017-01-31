From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 4/8] net/mlx5: TX WQE update
Date: Tue, 31 Jan 2017 22:58:39 +0200
Message-ID: <20170131205843.23235-5-saeedm@mellanox.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60063 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751241AbdAaVFo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:05:44 -0500
In-Reply-To: <20170131205843.23235-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new TX WQE fields for Connect-X5 vlan insertion support,
type and vlan_tci, when type = MLX5_ETH_WQE_INSERT_VLAN the
HW will insert the vlan and prio fields (vlan_tci) to the packet.

Those bits and the inline header fields are mutually exclusive, and
valid only when:
MLX5_CAP_ETH(mdev, wqe_inline_mode) == MLX5_CAP_INLINE_MODE_NOT_REQUIRED
and MLX5_CAP_ETH(mdev, wqe_vlan_insert),
who will be set in ConnectX-5 and later HW generations.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c                 |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c |  8 ++++----
 include/linux/mlx5/mlx5_ifc.h                   |  3 ++-
 include/linux/mlx5/qp.h                         | 16 ++++++++++++++--
 5 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 6a83fb32599d..e31bf11ae64f 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -2984,20 +2984,20 @@ static void *set_eth_seg(struct mlx5_wqe_eth_seg *eseg,
 
 	if (wr->opcode == IB_WR_LSO) {
 		struct ib_ud_wr *ud_wr = container_of(wr, struct ib_ud_wr, wr);
-		int size_of_inl_hdr_start = sizeof(eseg->inline_hdr_start);
+		int size_of_inl_hdr_start = sizeof(eseg->inline_hdr.start);
 		u64 left, leftlen, copysz;
 		void *pdata = ud_wr->header;
 
 		left = ud_wr->hlen;
 		eseg->mss = cpu_to_be16(ud_wr->mss);
-		eseg->inline_hdr_sz = cpu_to_be16(left);
+		eseg->inline_hdr.sz = cpu_to_be16(left);
 
 		/*
 		 * check if there is space till the end of queue, if yes,
 		 * copy all in one shot, otherwise copy till the end of queue,
 		 * rollback and than the copy the left
 		 */
-		leftlen = qend - (void *)eseg->inline_hdr_start;
+		leftlen = qend - (void *)eseg->inline_hdr.start;
 		copysz = min_t(u64, leftlen, left);
 
 		memcpy(seg - size_of_inl_hdr_start, pdata, copysz);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index fd8dff6acc12..965e69e9ff1e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -687,8 +687,8 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	memset(wqe, 0, sizeof(*wqe));
 
 	/* copy the inline part */
-	memcpy(eseg->inline_hdr_start, xdp->data, MLX5E_XDP_MIN_INLINE);
-	eseg->inline_hdr_sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
+	memcpy(eseg->inline_hdr.start, xdp->data, MLX5E_XDP_MIN_INLINE);
+	eseg->inline_hdr.sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
 
 	dseg = (struct mlx5_wqe_data_seg *)cseg + (MLX5E_XDP_TX_DS_COUNT - 1);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index cfb68371c397..678c07c8fbb0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -284,18 +284,18 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	wi->num_bytes = num_bytes;
 
 	if (skb_vlan_tag_present(skb)) {
-		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, ihs, &skb_data,
+		mlx5e_insert_vlan(eseg->inline_hdr.start, skb, ihs, &skb_data,
 				  &skb_len);
 		ihs += VLAN_HLEN;
 	} else {
-		memcpy(eseg->inline_hdr_start, skb_data, ihs);
+		memcpy(eseg->inline_hdr.start, skb_data, ihs);
 		mlx5e_tx_skb_pull_inline(&skb_data, &skb_len, ihs);
 	}
 
-	eseg->inline_hdr_sz = cpu_to_be16(ihs);
+	eseg->inline_hdr.sz = cpu_to_be16(ihs);
 
 	ds_cnt  = sizeof(*wqe) / MLX5_SEND_WQE_DS;
-	ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr_start),
+	ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr.start),
 			       MLX5_SEND_WQE_DS);
 	dseg    = (struct mlx5_wqe_data_seg *)cseg + ds_cnt;
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index cc8ae860cd45..afcd4736d8df 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -577,7 +577,8 @@ struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         lro_cap[0x1];
 	u8         lro_psh_flag[0x1];
 	u8         lro_time_stamp[0x1];
-	u8         reserved_at_5[0x3];
+	u8         reserved_at_5[0x2];
+	u8         wqe_vlan_insert[0x1];
 	u8         self_lb_en_modifiable[0x1];
 	u8         reserved_at_9[0x2];
 	u8         max_lso_cap[0x5];
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 219c699c17b7..3096370fe831 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -221,14 +221,26 @@ enum {
 	MLX5_ETH_WQE_L4_CSUM            = 1 << 7,
 };
 
+enum {
+	MLX5_ETH_WQE_INSERT_VLAN        = 1 << 15,
+};
+
 struct mlx5_wqe_eth_seg {
 	u8              rsvd0[4];
 	u8              cs_flags;
 	u8              rsvd1;
 	__be16          mss;
 	__be32          rsvd2;
-	__be16          inline_hdr_sz;
-	u8              inline_hdr_start[2];
+	union {
+		struct {
+			__be16 sz;
+			u8     start[2];
+		} inline_hdr;
+		struct {
+			__be16 type;
+			__be16 vlan_tci;
+		} insert;
+	};
 };
 
 struct mlx5_wqe_xrc_seg {
-- 
2.11.0
