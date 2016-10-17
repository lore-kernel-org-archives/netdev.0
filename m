From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 05/15] ethernet/mellanox: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:07 -0400
Message-ID: <20161017195417.48259-6-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mlx4: min_mtu 46, max_mtu depends on hardware

mlx5: min_mtu 68, max_mtu depends on hardware

CC: netdev@vger.kernel.org
CC: Tariq Toukan <tariqt@mellanox.com>
CC: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 24 ++++++-----------------
 2 files changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7e703be..bf35ac4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2205,10 +2205,6 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 	en_dbg(DRV, priv, "Change MTU called - current:%d new:%d\n",
 		 dev->mtu, new_mtu);
 
-	if ((new_mtu < MLX4_EN_MIN_MTU) || (new_mtu > priv->max_mtu)) {
-		en_err(priv, "Bad MTU size:%d.\n", new_mtu);
-		return -EPERM;
-	}
 	if (priv->xdp_ring_num && MLX4_EN_EFF_MTU(new_mtu) > FRAG_SZ0) {
 		en_err(priv, "MTU size:%d requires frags but XDP running\n",
 		       new_mtu);
@@ -3288,6 +3284,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		dev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
 	}
 
+	/* MTU range: 46 - hw-specific max */
+	dev->min_mtu = MLX4_EN_MIN_MTU;
+	dev->max_mtu = priv->max_mtu;
+
 	mdev->pndev[port] = dev;
 	mdev->upper[port] = NULL;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7eaf380..03183eb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2851,31 +2851,13 @@ static int mlx5e_set_features(struct net_device *netdev,
 	return err ? -EINVAL : 0;
 }
 
-#define MXL5_HW_MIN_MTU 64
-#define MXL5E_MIN_MTU (MXL5_HW_MIN_MTU + ETH_FCS_LEN)
-
 static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	struct mlx5_core_dev *mdev = priv->mdev;
 	bool was_opened;
-	u16 max_mtu;
-	u16 min_mtu;
 	int err = 0;
 	bool reset;
 
-	mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
-
-	max_mtu = MLX5E_HW2SW_MTU(max_mtu);
-	min_mtu = MLX5E_HW2SW_MTU(MXL5E_MIN_MTU);
-
-	if (new_mtu > max_mtu || new_mtu < min_mtu) {
-		netdev_err(netdev,
-			   "%s: Bad MTU (%d), valid range is: [%d..%d]\n",
-			   __func__, new_mtu, min_mtu, max_mtu);
-		return -EINVAL;
-	}
-
 	mutex_lock(&priv->state_lock);
 
 	reset = !priv->params.lro_en &&
@@ -3835,6 +3817,7 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 {
 	const struct mlx5e_profile *profile;
 	struct mlx5e_priv *priv;
+	u16 max_mtu;
 	int err;
 
 	priv = netdev_priv(netdev);
@@ -3865,6 +3848,11 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 
 	mlx5e_init_l2_addr(priv);
 
+	/* MTU range: 68 - hw-specific max */
+	netdev->min_mtu = ETH_MIN_MTU;
+	mlx5_query_port_max_mtu(priv->mdev, &max_mtu, 1);
+	netdev->max_mtu = MLX5E_HW2SW_MTU(max_mtu);
+
 	mlx5e_set_dev_port_mtu(netdev);
 
 	if (profile->enable)
-- 
2.10.0
