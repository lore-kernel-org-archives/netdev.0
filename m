From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 13/30] net/mlx5: Enable setting minimum inline header mode for VFs
Date: Sat, 20 Aug 2016 23:11:56 +0300
Message-ID: <1471723933-5894-14-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34179 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751919AbcHTUMp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:45 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Implement the low-level part of the PF side in setting minimum
inline header mode for VFs.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/vport.c | 20 ++++++++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                   |  2 +-
 include/linux/mlx5/vport.h                      |  2 ++
 3 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 3593bf7..525f17a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -125,6 +125,26 @@ void mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
 }
 EXPORT_SYMBOL_GPL(mlx5_query_nic_vport_min_inline);
 
+int mlx5_modify_nic_vport_min_inline(struct mlx5_core_dev *mdev,
+				     u16 vport, u8 min_inline)
+{
+	u32 in[MLX5_ST_SZ_DW(modify_nic_vport_context_in)] = {0};
+	int inlen = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in);
+	void *nic_vport_ctx;
+
+	MLX5_SET(modify_nic_vport_context_in, in,
+		 field_select.min_inline, 1);
+	MLX5_SET(modify_nic_vport_context_in, in, vport_number, vport);
+	MLX5_SET(modify_nic_vport_context_in, in, other_vport, 1);
+
+	nic_vport_ctx = MLX5_ADDR_OF(modify_nic_vport_context_in,
+				     in, nic_vport_context);
+	MLX5_SET(nic_vport_context, nic_vport_ctx,
+		 min_wqe_inline_mode, min_inline);
+
+	return mlx5_modify_nic_vport_context(mdev, in, inlen);
+}
+
 int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr)
 {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index cb94ac5..7a8ef0a 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -4724,7 +4724,7 @@ struct mlx5_ifc_modify_nic_vport_field_select_bits {
 	u8         reserved_at_0[0x16];
 	u8         node_guid[0x1];
 	u8         port_guid[0x1];
-	u8         reserved_at_18[0x1];
+	u8         min_inline[0x1];
 	u8         mtu[0x1];
 	u8         change_event[0x1];
 	u8         promisc[0x1];
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index e087b7d..451b0bd 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -45,6 +45,8 @@ int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr);
 void mlx5_query_nic_vport_min_inline(struct mlx5_core_dev *mdev,
 				     u8 *min_inline);
+int mlx5_modify_nic_vport_min_inline(struct mlx5_core_dev *mdev,
+				     u16 vport, u8 min_inline);
 int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *dev,
 				      u16 vport, u8 *addr);
 int mlx5_query_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 *mtu);
-- 
2.7.4
