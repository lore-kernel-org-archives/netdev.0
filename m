From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/15] net/mlx5: Query and cache PCAM, MCAM registers on initialization
Date: Fri, 20 Jan 2017 00:39:02 +0200
Message-ID: <20170119223908.15924-10-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59326 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751583AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

On load_one, we now cache our capabilities registers internally, similar
to QUERY_HCA_CAP. Capabilities can later be queried using macros
introduced in this patch.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c | 20 ++++++++++++++++++++
 include/linux/mlx5/device.h                  |  6 ++++++
 include/linux/mlx5/driver.h                  |  4 ++++
 3 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 5718aada6605..d0bbefa08af7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -91,6 +91,20 @@ int mlx5_core_query_vendor_id(struct mlx5_core_dev *mdev, u32 *vendor_id)
 }
 EXPORT_SYMBOL(mlx5_core_query_vendor_id);
 
+static int mlx5_get_pcam_reg(struct mlx5_core_dev *dev)
+{
+	return mlx5_query_pcam_reg(dev, dev->caps.pcam,
+				   MLX5_PCAM_FEATURE_ENHANCED_FEATURES,
+				   MLX5_PCAM_REGS_5000_TO_507F);
+}
+
+static int mlx5_get_mcam_reg(struct mlx5_core_dev *dev)
+{
+	return mlx5_query_mcam_reg(dev, dev->caps.mcam,
+				   MLX5_MCAM_FEATURE_ENHANCED_FEATURES,
+				   MLX5_MCAM_REGS_FIRST_128);
+}
+
 int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 {
 	int err;
@@ -154,6 +168,12 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 			return err;
 	}
 
+	if (MLX5_CAP_GEN(dev, pcam_reg))
+		mlx5_get_pcam_reg(dev);
+
+	if (MLX5_CAP_GEN(dev, mcam_reg))
+		mlx5_get_mcam_reg(dev);
+
 	return 0;
 }
 
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 79f38e67fe2f..f21528abfb74 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1081,6 +1081,12 @@ enum mlx5_mcam_feature_groups {
 #define MLX5_CAP_QOS(mdev, cap)\
 	MLX5_GET(qos_cap, mdev->hca_caps_cur[MLX5_CAP_QOS], cap)
 
+#define MLX5_CAP_PCAM_FEATURE(mdev, fld) \
+	MLX5_GET(pcam_reg, (mdev)->caps.pcam, feature_cap_mask.enhanced_features.fld)
+
+#define MLX5_CAP_MCAM_FEATURE(mdev, fld) \
+	MLX5_GET(mcam_reg, (mdev)->caps.mcam, mng_feature_cap_mask.enhanced_features.fld)
+
 enum {
 	MLX5_CMD_STAT_OK			= 0x0,
 	MLX5_CMD_STAT_INT_ERR			= 0x1,
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 60c2b156da8c..69c4661d391e 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -739,6 +739,10 @@ struct mlx5_core_dev {
 	struct mlx5_port_caps	port_caps[MLX5_MAX_PORTS];
 	u32 hca_caps_cur[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
 	u32 hca_caps_max[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
+	struct {
+		u32 pcam[MLX5_ST_SZ_DW(pcam_reg)];
+		u32 mcam[MLX5_ST_SZ_DW(mcam_reg)];
+	} caps;
 	phys_addr_t		iseg_base;
 	struct mlx5_init_seg __iomem *iseg;
 	enum mlx5_device_state	state;
-- 
2.11.0
