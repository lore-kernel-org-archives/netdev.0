From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/2] net/mlx5e: make VXLAN support conditional
Date: Sun,  8 May 2016 14:55:25 +0300
Message-ID: <1462708525-23545-3-git-send-email-saeedm@mellanox.com>
References: <1462708525-23545-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38948 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750735AbcEHLz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2016 07:55:57 -0400
In-Reply-To: <1462708525-23545-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

VXLAN can be disabled at compile-time or it can be a loadable
module while mlx5 is built-in, which leads to a link error:

drivers/net/built-in.o: In function `mlx5e_create_netdev':
ntb_netdev.c:(.text+0x106de4): undefined reference to `vxlan_get_rx_port'

This avoids the link error and makes the vxlan code optional,
like the other ethernet drivers do as well.

Link: https://patchwork.ozlabs.org/patch/589296/
Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  7 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   | 11 +++++++++--
 5 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 1cf722e..f5c3b94 100644
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
index 4fc45ee..bf65b71 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -6,6 +6,7 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
-		en_txrx.o en_clock.o vxlan.o en_tc.o
+		en_txrx.o en_clock.o en_tc.o
 
+mlx5_core-$(CONFIG_MLX5_CORE_EN_VXLAN) += vxlan.o
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 3881dce..24344aaf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -564,7 +564,9 @@ struct mlx5e_priv {
 	struct mlx5e_flow_tables   fts;
 	struct mlx5e_eth_addr_db   eth_addr;
 	struct mlx5e_vlan_db       vlan;
+#ifdef CONFIG_MLX5_CORE_EN_VXLAN
 	struct mlx5e_vxlan_db      vxlan;
+#endif
 
 	struct mlx5e_params        params;
 	struct workqueue_struct    *wq;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d4dfc5c..94fef70 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2149,6 +2149,7 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 					    vf_stats);
 }
 
+#if IS_ENABLED(CONFIG_MLX5_CORE_EN_VXLAN)
 static void mlx5e_add_vxlan_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
@@ -2220,6 +2221,7 @@ static netdev_features_t mlx5e_features_check(struct sk_buff *skb,
 
 	return features;
 }
+#endif
 
 static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
@@ -2251,9 +2253,11 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_features        = mlx5e_set_features,
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
+#ifdef CONFIG_MLX5_CORE_EN_VXLAN
 	.ndo_add_vxlan_port      = mlx5e_add_vxlan_port,
 	.ndo_del_vxlan_port      = mlx5e_del_vxlan_port,
 	.ndo_features_check      = mlx5e_features_check,
+#endif
 	.ndo_set_vf_mac          = mlx5e_set_vf_mac,
 	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
 	.ndo_get_vf_config       = mlx5e_get_vf_config,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
index 129f352..217ac53 100644
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
2.8.0
