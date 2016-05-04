From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 2/3] net/mlx5e: make VXLAN support conditional
Date: Wed,  4 May 2016 14:31:14 +0200
Message-ID: <1462365116-3856622-1-git-send-email-arnd@arndb.de>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Matthew Finlay <matt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Abramonvsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Gal Pressman <galp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462364774-3792510-1-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

VXLAN can be disabled at compile-time or it can be a loadable
module while mlx5 is built-in, which leads to a link error:

drivers/net/built-in.o: In function `mlx5e_create_netdev':
ntb_netdev.c:(.text+0x106de4): undefined reference to `vxlan_get_rx_port'

This avoids the link error and makes the vxlan code optional,
like the other ethernet drivers do as well.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Link: https://patchwork.ozlabs.org/patch/589296/
Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
---
I sent it originally on Feb 26 2016, but misread Saeed Mahameed's
reply as saying that he'd fix it up himself. The new version
should address the original comment.
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  7 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   | 11 +++++++++--
 5 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 1cf722eba607..f5c3b9465d8d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -31,3 +31,10 @@ config MLX5_CORE_EN_DCB
 	  This flag is depended on the kernel's DCB support.
 
 	  If unsure, set to Y
+
+config MLX5_CORE_EN_VXLAN
+	bool "VXLAN offloads Support"
+	default y
+	depends on MLX5_CORE_EN && VXLAN && !(MLX5_CORE=y && VXLAN=m)
+	---help---
+	  Say Y here if you want to use VXLAN offloads in the driver.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 679e18ffb3a6..6b8da0b36acd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -6,7 +6,9 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
-		en_txrx.o en_clock.o vxlan.o en_tc.o
+		en_txrx.o en_clock.o en_tc.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN_VXLAN) += vxlan.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 mlx5_core-$(CONFIG_RFS_ACCEL) +=  en_arfs.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index bfa5daaaf5aa..19b1b021af2d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -522,7 +522,9 @@ struct mlx5e_priv {
 	struct mlx5e_direct_tir    direct_tir[MLX5E_MAX_NUM_CHANNELS];
 
 	struct mlx5e_flow_steering fs;
+#ifdef CONFIG_MLX5_CORE_EN_VXLAN
 	struct mlx5e_vxlan_db      vxlan;
+#endif
 
 	struct mlx5e_params        params;
 	struct workqueue_struct    *wq;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7dfb73aa8e41..5e710315c5a9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2494,6 +2494,7 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 					    vf_stats);
 }
 
+#if IS_ENABLED(CONFIG_MLX5_CORE_EN_VXLAN)
 static void mlx5e_add_vxlan_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
@@ -2565,6 +2566,7 @@ static netdev_features_t mlx5e_features_check(struct sk_buff *skb,
 
 	return features;
 }
+#endif
 
 static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
@@ -2599,9 +2601,11 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_features        = mlx5e_set_features,
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
+#ifdef CONFIG_MLX5_CORE_EN_VXLAN
 	.ndo_add_vxlan_port      = mlx5e_add_vxlan_port,
 	.ndo_del_vxlan_port      = mlx5e_del_vxlan_port,
 	.ndo_features_check      = mlx5e_features_check,
+#endif
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
index 129f3527aa14..217ac530a514 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
@@ -48,14 +48,21 @@ struct mlx5e_vxlan_work {
 
 static inline bool mlx5e_vxlan_allowed(struct mlx5_core_dev *mdev)
 {
-	return (MLX5_CAP_ETH(mdev, tunnel_stateless_vxlan) &&
+	return IS_ENABLED(CONFIG_MLX5_CORE_EN_VXLAN) &&
+		(MLX5_CAP_ETH(mdev, tunnel_stateless_vxlan) &&
 		mlx5_core_is_pf(mdev));
 }
 
+#ifdef CONFIG_MLX5_CORE_EN_VXLAN
 void mlx5e_vxlan_init(struct mlx5e_priv *priv);
+void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv);
+#else
+static inline void mlx5e_vxlan_init(struct mlx5e_priv *priv) {}
+static inline void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv) {}
+#endif
+
 void mlx5e_vxlan_queue_work(struct mlx5e_priv *priv, sa_family_t sa_family,
 			    u16 port, int add);
 struct mlx5e_vxlan *mlx5e_vxlan_lookup_port(struct mlx5e_priv *priv, u16 port);
-void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv);
 
 #endif /* __MLX5_VXLAN_H__ */
-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
