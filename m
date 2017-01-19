From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/15] net/mlx5: Implement PCAM, MCAM access register commands
Date: Fri, 20 Jan 2017 00:39:01 +0200
Message-ID: <20170119223908.15924-9-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59324 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751719AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Introduced registers will expose capabilities of new registers and
features related to port/management.
Driver will query MCAM and PCAM in order to avoid failing on old
firmwares with lack of support.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 24 ++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 090e3a1dedc2..b3dabe6e8836 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -113,6 +113,11 @@ u32 mlx5_get_msix_vec(struct mlx5_core_dev *dev, int vecidx);
 struct mlx5_eq *mlx5_eqn2eq(struct mlx5_core_dev *dev, int eqn);
 void mlx5_cq_tasklet_cb(unsigned long data);
 
+int mlx5_query_pcam_reg(struct mlx5_core_dev *dev, u32 *pcam, u8 feature_group,
+			u8 access_reg_group);
+int mlx5_query_mcam_reg(struct mlx5_core_dev *dev, u32 *mcap, u8 feature_group,
+			u8 access_reg_group);
+
 void mlx5_lag_add(struct mlx5_core_dev *dev, struct net_device *netdev);
 void mlx5_lag_remove(struct mlx5_core_dev *dev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 5ea85336b2e4..969e352435ee 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -74,6 +74,30 @@ int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 }
 EXPORT_SYMBOL_GPL(mlx5_core_access_reg);
 
+int mlx5_query_pcam_reg(struct mlx5_core_dev *dev, u32 *pcam, u8 feature_group,
+			u8 access_reg_group)
+{
+	u32 in[MLX5_ST_SZ_DW(pcam_reg)] = {0};
+	int sz = MLX5_ST_SZ_BYTES(pcam_reg);
+
+	MLX5_SET(pcam_reg, in, feature_group, feature_group);
+	MLX5_SET(pcam_reg, in, access_reg_group, access_reg_group);
+
+	return mlx5_core_access_reg(dev, in, sz, pcam, sz, MLX5_REG_PCAM, 0, 0);
+}
+
+int mlx5_query_mcam_reg(struct mlx5_core_dev *dev, u32 *mcam, u8 feature_group,
+			u8 access_reg_group)
+{
+	u32 in[MLX5_ST_SZ_DW(mcam_reg)] = {0};
+	int sz = MLX5_ST_SZ_BYTES(mcam_reg);
+
+	MLX5_SET(mcam_reg, in, feature_group, feature_group);
+	MLX5_SET(mcam_reg, in, access_reg_group, access_reg_group);
+
+	return mlx5_core_access_reg(dev, in, sz, mcam, sz, MLX5_REG_MCAM, 0, 0);
+}
+
 struct mlx5_reg_pcap {
 	u8			rsvd0;
 	u8			port_num;
-- 
2.11.0
