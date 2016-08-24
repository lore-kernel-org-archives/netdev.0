From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 09/15] net/mlx5: LAG and SRIOV cannot be used together
Date: Wed, 24 Aug 2016 13:39:08 +0300
Message-ID: <1472035154-14517-10-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Until support will be added for RoCE LAG SRIOV.

Signed-off-by: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/lag.c       |  6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c     | 12 ++++++++++++
 3 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index 9523050..3cb570a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -201,6 +201,12 @@ static void mlx5_do_bond(struct mlx5_lag *ldev)
 	mutex_unlock(&lag_mutex);
 
 	if (tracker.is_bonded && !mlx5_lag_is_bonded(ldev)) {
+		if (mlx5_sriov_is_enabled(dev0) ||
+		    mlx5_sriov_is_enabled(dev1)) {
+			mlx5_core_warn(dev0, "LAG is not supported with SRIOV");
+			return;
+		}
+
 		for (i = 0; i < MLX5_MAX_PORTS; i++)
 			mlx5_remove_dev_by_protocol(ldev->pf[i].dev,
 						    MLX5_INTERFACE_PROTOCOL_IB);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index e716996..8557435 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -90,6 +90,7 @@ void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 void mlx5_enter_error_state(struct mlx5_core_dev *dev);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
 int mlx5_core_sriov_configure(struct pci_dev *dev, int num_vfs);
+bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev);
 int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
 int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id);
 int mlx5_wait_for_vf_pages(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index 0680dfb..78e7892 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -37,6 +37,13 @@
 #include "eswitch.h"
 #endif
 
+bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev)
+{
+	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
+
+	return !!sriov->num_vfs;
+}
+
 static void enable_vfs(struct mlx5_core_dev *dev, int num_vfs)
 {
 	struct mlx5_core_sriov *sriov = &dev->priv.sriov;
@@ -144,6 +151,11 @@ int mlx5_core_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	if (!mlx5_core_is_pf(dev))
 		return -EPERM;
 
+	if (num_vfs && mlx5_lag_is_active(dev)) {
+		mlx5_core_warn(dev, "can't turn sriov on while LAG is active");
+		return -EINVAL;
+	}
+
 	mlx5_core_cleanup_vfs(dev);
 
 	if (!num_vfs) {
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
