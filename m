From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 07/15] net/mlx5: Get RoCE netdev
Date: Wed, 24 Aug 2016 13:39:06 +0300
Message-ID: <1472035154-14517-8-git-send-email-saeedm@mellanox.com>
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

Used by IB driver for determining the IB bond
device's netdev, when LAG is active.

Returns PF0's netdev if mode is not active-backup,
or the PF netdev of the active slave when mode is
active-backup.

Signed-off-by: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/lag.c | 27 +++++++++++++++++++++++++++
 include/linux/mlx5/driver.h                   |  1 +
 2 files changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index 3bf0a7f..9523050 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -528,3 +528,30 @@ bool mlx5_lag_is_active(struct mlx5_core_dev *dev)
 }
 EXPORT_SYMBOL(mlx5_lag_is_active);
 
+struct net_device *mlx5_lag_get_roce_netdev(struct mlx5_core_dev *dev)
+{
+	struct net_device *ndev = NULL;
+	struct mlx5_lag *ldev;
+
+	mutex_lock(&lag_mutex);
+	ldev = mlx5_lag_dev_get(dev);
+
+	if (!(ldev && mlx5_lag_is_bonded(ldev)))
+		goto unlock;
+
+	if (ldev->tracker.tx_type == NETDEV_LAG_TX_TYPE_ACTIVEBACKUP) {
+		ndev = ldev->tracker.netdev_state[0].tx_enabled ?
+		       ldev->pf[0].netdev : ldev->pf[1].netdev;
+	} else {
+		ndev = ldev->pf[0].netdev;
+	}
+	if (ndev)
+		dev_hold(ndev);
+
+unlock:
+	mutex_unlock(&lag_mutex);
+
+	return ndev;
+}
+EXPORT_SYMBOL(mlx5_lag_get_roce_netdev);
+
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index ed983b8..c568dd9 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -945,6 +945,7 @@ void mlx5_unregister_interface(struct mlx5_interface *intf);
 int mlx5_core_query_vendor_id(struct mlx5_core_dev *mdev, u32 *vendor_id);
 
 bool mlx5_lag_is_active(struct mlx5_core_dev *dev);
+struct net_device *mlx5_lag_get_roce_netdev(struct mlx5_core_dev *dev);
 
 struct mlx5_profile {
 	u64	mask;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
