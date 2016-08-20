From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 22/30] net/mlx5: Get RoCE netdev
Date: Sat, 20 Aug 2016 23:12:05 +0300
Message-ID: <1471723933-5894-23-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Aviv Heller <avivh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34322 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752487AbcHTUMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:54 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

Used by IB driver for determining the IB bond
device's netdev, when LAG is active.

Returns PF0's netdev if mode is not active-backup,
or the PF netdev of the active slave when mode is
active-backup.

Signed-off-by: Aviv Heller <avivh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
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
