From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/mlx5e: make VXLAN support conditional
Date: Fri, 26 Feb 2016 22:13:31 +0100
Message-ID: <1456521217-2174580-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	"David S . Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:63452 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcBZVON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 16:14:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VXLAN can be disabled at compile-time or it can be a loadable
module while mlx5 is built-in, which leads to a link error:

drivers/net/built-in.o: In function `mlx5e_create_netdev':
ntb_netdev.c:(.text+0x106de4): undefined reference to `vxlan_get_rx_port'

This avoids the link error and makes the vxlan code optional,
like the other ethernet drivers do as well.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  7 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h   | 11 +++++++++--
 5 files changed, 24 insertions(+), 3 deletions(-)

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
index 11b592dbf16a..3ecef5f74ccf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -6,6 +6,8 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
-		en_txrx.o en_clock.o vxlan.o
+		en_txrx.o en_clock.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN_VXLAN) += vxlan.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1dca3dcf90f5..18040da1c3a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -552,7 +552,9 @@ struct mlx5e_priv {
 	struct mlx5e_flow_tables   fts;
 	struct mlx5e_eth_addr_db   eth_addr;
 	struct mlx5e_vlan_db       vlan;
+#ifdef CONFIG_MLX5_CORE_EN_VXLAN
 	struct mlx5e_vxlan_db      vxlan;
+#endif
 
 	struct mlx5e_params        params;
 	spinlock_t                 async_events_spinlock; /* sync hw events */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0d45f35aee72..44fc4bc35ffd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2116,6 +2116,9 @@ static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
 	u16 proto;
 	u16 port = 0;
 
+	if (!IS_ENABLED(CONFIG_MLX5_CORE_EN_VXLAN))
+		goto out;
+
 	switch (vlan_get_protocol(skb)) {
 	case htons(ETH_P_IP):
 		proto = ip_hdr(skb)->protocol;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
index a01685056ab1..8c57861e0f8a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
@@ -41,14 +41,21 @@ struct mlx5e_vxlan {
 
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
 int  mlx5e_vxlan_add_port(struct mlx5e_priv *priv, u16 port);
 void mlx5e_vxlan_del_port(struct mlx5e_priv *priv, u16 port);
 struct mlx5e_vxlan *mlx5e_vxlan_lookup_port(struct mlx5e_priv *priv, u16 port);
-void mlx5e_vxlan_cleanup(struct mlx5e_priv *priv);
 
 #endif /* __MLX5_VXLAN_H__ */
-- 
2.7.0
