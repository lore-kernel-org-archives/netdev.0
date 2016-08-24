From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 13/15] net/mlx5: Configure IB devices according to LAG state
Date: Wed, 24 Aug 2016 13:39:12 +0300
Message-ID: <1472035154-14517-14-git-send-email-saeedm@mellanox.com>
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

When mlx5_ib is loaded, we would like each card's IB devices
to be added according to its LAG state (one IB device, instead of
two, is to be added if LAG is active).

Signed-off-by: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/lag.c       | 17 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c      |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h |  2 ++
 3 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index 5fe320c..92c3e0d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -583,3 +583,20 @@ unlock:
 }
 EXPORT_SYMBOL(mlx5_lag_get_roce_netdev);
 
+bool mlx5_lag_intf_add(struct mlx5_interface *intf, struct mlx5_priv *priv)
+{
+	struct mlx5_core_dev *dev = container_of(priv, struct mlx5_core_dev,
+						 priv);
+	struct mlx5_lag *ldev;
+
+	if (intf->protocol != MLX5_INTERFACE_PROTOCOL_IB)
+		return true;
+
+	ldev = mlx5_lag_dev_get(dev);
+	if (!ldev || !mlx5_lag_is_bonded(ldev) || ldev->pf[0].dev == dev)
+		return true;
+
+	/* If bonded, we do not add an IB device for PF1. */
+	return false;
+}
+
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index db7bcfc..28e3ce6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -783,6 +783,9 @@ static void mlx5_add_device(struct mlx5_interface *intf, struct mlx5_priv *priv)
 	struct mlx5_device_context *dev_ctx;
 	struct mlx5_core_dev *dev = container_of(priv, struct mlx5_core_dev, priv);
 
+	if (!mlx5_lag_intf_add(intf, priv))
+		return;
+
 	dev_ctx = kmalloc(sizeof(*dev_ctx), GFP_KERNEL);
 	if (!dev_ctx)
 		return;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 8557435..714b71b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -105,6 +105,8 @@ void mlx5_lag_remove(struct mlx5_core_dev *dev);
 void mlx5_add_dev_by_protocol(struct mlx5_core_dev *dev, int protocol);
 void mlx5_remove_dev_by_protocol(struct mlx5_core_dev *dev, int protocol);
 
+bool mlx5_lag_intf_add(struct mlx5_interface *intf, struct mlx5_priv *priv);
+
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
