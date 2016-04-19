From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 6/9] net/mlx5e: Use vport MTU rather than physical port MTU
Date: Tue, 19 Apr 2016 15:33:39 +0300
Message-ID: <1461069222-27076-7-git-send-email-saeedm@mellanox.com>
References: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48440 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752718AbcDSMfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 08:35:03 -0400
In-Reply-To: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set and report vport MTU rather than physical MTU,
Driver will set both vport and physical port mtu and will
rely on the query of vport mtu.

SRIOV VFs have to report their MTU to their vport manager (PF),
and this will allow them to work with any MTU they need
without failing the request.

Also for some cases where the PF is not a port owner, PF can
work with MTU less than the physical port mtu if set physical
port mtu didn't take effect.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   44 ++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   |   40 +++++++++++++++++++
 include/linux/mlx5/vport.h                        |    2 +
 3 files changed, 77 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 93e4ef4..85773f8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1404,24 +1404,50 @@ static int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5e_priv *priv)
 	return 0;
 }
 
-static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
+static int mlx5e_set_mtu(struct mlx5e_priv *priv, u16 mtu)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	u16 hw_mtu;
+	u16 hw_mtu = MLX5E_SW2HW_MTU(mtu);
 	int err;
 
-	err = mlx5_set_port_mtu(mdev, MLX5E_SW2HW_MTU(netdev->mtu), 1);
+	err = mlx5_set_port_mtu(mdev, hw_mtu, 1);
 	if (err)
 		return err;
 
-	mlx5_query_port_oper_mtu(mdev, &hw_mtu, 1);
+	/* Update vport context MTU */
+	mlx5_modify_nic_vport_mtu(mdev, hw_mtu);
+	return 0;
+}
+
+static void mlx5e_query_mtu(struct mlx5e_priv *priv, u16 *mtu)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u16 hw_mtu = 0;
+	int err;
+
+	err = mlx5_query_nic_vport_mtu(mdev, &hw_mtu);
+	if (err || !hw_mtu) /* fallback to port oper mtu */
+		mlx5_query_port_oper_mtu(mdev, &hw_mtu, 1);
+
+	*mtu = MLX5E_HW2SW_MTU(hw_mtu);
+}
+
+static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	u16 mtu;
+	int err;
+
+	err = mlx5e_set_mtu(priv, netdev->mtu);
+	if (err)
+		return err;
 
-	if (MLX5E_HW2SW_MTU(hw_mtu) != netdev->mtu)
-		netdev_warn(netdev, "%s: Port MTU %d is different than netdev mtu %d\n",
-			    __func__, MLX5E_HW2SW_MTU(hw_mtu), netdev->mtu);
+	mlx5e_query_mtu(priv, &mtu);
+	if (mtu != netdev->mtu)
+		netdev_warn(netdev, "%s: VPort MTU %d is different than netdev mtu %d\n",
+			    __func__, mtu, netdev->mtu);
 
-	netdev->mtu = MLX5E_HW2SW_MTU(hw_mtu);
+	netdev->mtu = mtu;
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index bd51840..b69dadc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -196,6 +196,46 @@ int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 }
 EXPORT_SYMBOL_GPL(mlx5_modify_nic_vport_mac_address);
 
+int mlx5_query_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 *mtu)
+{
+	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
+	u32 *out;
+	int err;
+
+	out = mlx5_vzalloc(outlen);
+	if (!out)
+		return -ENOMEM;
+
+	err = mlx5_query_nic_vport_context(mdev, 0, out, outlen);
+	if (!err)
+		*mtu = MLX5_GET(query_nic_vport_context_out, out,
+				nic_vport_context.mtu);
+
+	kvfree(out);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_nic_vport_mtu);
+
+int mlx5_modify_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 mtu)
+{
+	int inlen = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in);
+	void *in;
+	int err;
+
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	MLX5_SET(modify_nic_vport_context_in, in, field_select.mtu, 1);
+	MLX5_SET(modify_nic_vport_context_in, in, nic_vport_context.mtu, mtu);
+
+	err = mlx5_modify_nic_vport_context(mdev, in, inlen);
+
+	kvfree(in);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_modify_nic_vport_mtu);
+
 int mlx5_query_nic_vport_mac_list(struct mlx5_core_dev *dev,
 				  u32 vport,
 				  enum mlx5_list_type list_type,
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index bd93e63..301da4a 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -45,6 +45,8 @@ int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr);
 int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *dev,
 				      u16 vport, u8 *addr);
+int mlx5_query_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 *mtu);
+int mlx5_modify_nic_vport_mtu(struct mlx5_core_dev *mdev, u16 mtu);
 int mlx5_query_nic_vport_system_image_guid(struct mlx5_core_dev *mdev,
 					   u64 *system_image_guid);
 int mlx5_query_nic_vport_node_guid(struct mlx5_core_dev *mdev, u64 *node_guid);
-- 
1.7.1
