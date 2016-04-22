From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/12] net/mlx5e: Disable link up on INIT HCA command
Date: Fri, 22 Apr 2016 22:00:47 +0300
Message-ID: <1461351647-27412-13-git-send-email-saeedm@mellanox.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36946 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752478AbcDVTCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:25 -0400
In-Reply-To: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Disable link up when initializing the HCA. Link up/down will be changed
using (Ports Administrative and Operational Status Register) PAOS
commands.

If link layer is Ethernet, up/down the link in ndo_open/stop.  If link
layer is IB, up/down the link as part of the mlx5 IB add/remove flow.

Before this patch the link was up when the HCA was initialized, now the
driver will manage the link.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                  |   11 +++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |    5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |    4 ++--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |    4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |    5 +++--
 include/linux/mlx5/port.h                          |    3 ++-
 8 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 5acf346..6fd365f 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -2261,6 +2261,9 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	if (err)
 		goto err_dealloc;
 
+	mlx5_foreach_port(dev, i, IB_LINK_LAYER_INFINIBAND)
+		mlx5_set_port_admin_status(dev->mdev, MLX5_PORT_UP, i + 1);
+
 	if (mlx5_use_mad_ifc(dev))
 		get_ext_port_caps(dev);
 
@@ -2443,6 +2446,9 @@ err_disable_roce:
 	if (ll == IB_LINK_LAYER_ETHERNET)
 		mlx5_disable_roce(dev);
 
+	mlx5_foreach_port(dev, i, IB_LINK_LAYER_INFINIBAND)
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN, i + 1);
+
 err_dealloc:
 	ib_dealloc_device((struct ib_device *)dev);
 
@@ -2453,6 +2459,7 @@ static void mlx5_ib_remove(struct mlx5_core_dev *mdev, void *context)
 {
 	struct mlx5_ib_dev *dev = context;
 	enum rdma_link_layer ll = mlx5_ib_port_link_layer(&dev->ib_dev, 1);
+	int i;
 
 	ib_unregister_device(&dev->ib_dev);
 	destroy_umrc_res(dev);
@@ -2460,6 +2467,10 @@ static void mlx5_ib_remove(struct mlx5_core_dev *mdev, void *context)
 	destroy_dev_resources(&dev->devr);
 	if (ll == IB_LINK_LAYER_ETHERNET)
 		mlx5_disable_roce(dev);
+
+	mlx5_foreach_port(dev, i, IB_LINK_LAYER_INFINIBAND)
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN, i + 1);
+
 	ib_dealloc_device(&dev->ib_dev);
 }
 
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index b46c255..4585fca 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -62,6 +62,11 @@ pr_warn("%s:%s:%d:(pid %d): " format, (dev)->ib_dev.name, __func__,	\
 #define MLX5_IB_DEFAULT_UIDX 0xffffff
 #define MLX5_USER_ASSIGNED_UIDX_MASK __mlx5_mask(qpc, user_index)
 
+#define mlx5_foreach_port(dev, p, type)					\
+	for ((p) = 0; (p) < MLX5_CAP_GEN(dev->mdev, num_ports); (p)++)	\
+		if (mlx5_ib_port_link_layer(&dev->ib_dev, (p) + 1) ==	\
+		    (type))
+
 enum {
 	MLX5_IB_MMAP_CMD_SHIFT	= 8,
 	MLX5_IB_MMAP_CMD_MASK	= 0xff,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
index b2db180..f083797 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
@@ -202,12 +202,12 @@ static int mlx5e_dcbnl_ieee_setpfc(struct net_device *dev,
 
 	mlx5_query_port_admin_status(mdev, &ps);
 	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN, 1);
 
 	ret = mlx5_set_port_pfc(mdev, pfc->pfc_en, pfc->pfc_en);
 
 	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP);
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP, 1);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 0518c86..2fed67f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -777,10 +777,10 @@ static int mlx5e_set_settings(struct net_device *netdev,
 
 	mlx5_query_port_admin_status(mdev, &ps);
 	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN);
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_DOWN, 1);
 	mlx5_set_port_proto(mdev, link_modes, MLX5_PTYS_EN);
 	if (ps == MLX5_PORT_UP)
-		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP);
+		mlx5_set_port_admin_status(mdev, MLX5_PORT_UP, 1);
 
 out:
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5bad17d..6c9fa9f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1632,9 +1632,12 @@ static int mlx5e_open(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int err;
+	u8 state;
 
 	mutex_lock(&priv->state_lock);
 	err = mlx5e_open_locked(netdev);
+	state = err ? MLX5_PORT_DOWN : MLX5_PORT_UP;
+	mlx5_set_port_admin_status(priv->mdev, state, 1);
 	mutex_unlock(&priv->state_lock);
 
 	return err;
@@ -1666,6 +1669,7 @@ static int mlx5e_close(struct net_device *netdev)
 	int err;
 
 	mutex_lock(&priv->state_lock);
+	mlx5_set_port_admin_status(priv->mdev, MLX5_PORT_DOWN, 1);
 	err = mlx5e_close_locked(netdev);
 	mutex_unlock(&priv->state_lock);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 3f3b2fa..6211cc3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -497,6 +497,10 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 
 	MLX5_SET(cmd_hca_cap, set_hca_cap, log_uar_page_sz, PAGE_SHIFT - 12);
 
+	/* disable link up by INIT_HCA */
+	if (MLX5_CAP_GEN_MAX(dev, disable_link_up))
+		MLX5_SET(cmd_hca_cap, set_hca_cap, disable_link_up, 1);
+
 	err = set_caps(dev, set_ctx, set_sz,
 		       MLX5_SET_HCA_CAP_OP_MOD_GENERAL_DEVICE);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 4cb2a44..5036e14 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -223,14 +223,15 @@ int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 EXPORT_SYMBOL_GPL(mlx5_set_port_proto);
 
 int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
-			       enum mlx5_port_status status)
+			       enum mlx5_port_status status,
+			       u8 port)
 {
 	u32 in[MLX5_ST_SZ_DW(paos_reg)];
 	u32 out[MLX5_ST_SZ_DW(paos_reg)];
 
 	memset(in, 0, sizeof(in));
 
-	MLX5_SET(paos_reg, in, local_port, 1);
+	MLX5_SET(paos_reg, in, local_port, port);
 	MLX5_SET(paos_reg, in, admin_status, status);
 	MLX5_SET(paos_reg, in, ase, 1);
 
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index 7391eb8..0656118 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -68,7 +68,8 @@ int mlx5_query_port_proto_oper(struct mlx5_core_dev *dev,
 int mlx5_set_port_proto(struct mlx5_core_dev *dev, u32 proto_admin,
 			int proto_mask);
 int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
-			       enum mlx5_port_status status);
+			       enum mlx5_port_status status,
+			       u8 port);
 int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
 				 enum mlx5_port_status *status);
 int mlx5_set_port_beacon(struct mlx5_core_dev *dev, u16 beacon_duration);
-- 
1.7.1
