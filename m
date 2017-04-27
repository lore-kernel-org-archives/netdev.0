From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] mlx5: work around unused function warning
Date: Thu, 27 Apr 2017 13:04:02 +0200
Message-ID: <20170427110421.2431598-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Erez Shitrit <erezsh@mellanox.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous patch addressed a sparse warning but replaced it with a
compiler warning when CONFIG_MODULES is disabled:

drivers/net/ethernet/mellanox/mlx5/core/ipoib.c:485:13: error: 'mlx5_rdma_netdev_free' defined but not used [-Werror=unused-function]
drivers/net/ethernet/mellanox/mlx5/core/ipoib.c:423:27: error: 'mlx5_rdma_netdev_alloc' defined but not used [-Werror=unused-function]

We should never export 'static' functions, so this makes them global
again but hides them in another #ifdef like the change before.

Fixes: a7082ef066f0 ("mlx5: hide unused functions")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index 3c84e36af018..eb48f112dff4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -405,7 +405,6 @@ static int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
 
 	return mlx5i_sq_xmit(sq, skb, &mah->av, dqpn, dqkey);
 }
-#endif
 
 static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
@@ -420,10 +419,10 @@ static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 	return 0;
 }
 
-static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
-						 struct ib_device *ibdev,
-						 const char *name,
-						 void (*setup)(struct net_device *))
+struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
+					  struct ib_device *ibdev,
+					  const char *name,
+					  void (*setup)(struct net_device *))
 {
 	const struct mlx5e_profile *profile = &mlx5i_nic_profile;
 	int nch = profile->max_nch(mdev);
@@ -482,7 +481,7 @@ static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 }
 EXPORT_SYMBOL(mlx5_rdma_netdev_alloc);
 
-static void mlx5_rdma_netdev_free(struct net_device *netdev)
+void mlx5_rdma_netdev_free(struct net_device *netdev)
 {
 	struct mlx5e_priv          *priv    = mlx5i_epriv(netdev);
 	const struct mlx5e_profile *profile = priv->profile;
@@ -495,4 +494,4 @@ static void mlx5_rdma_netdev_free(struct net_device *netdev)
 	mlx5e_destroy_mdev_resources(priv->mdev);
 }
 EXPORT_SYMBOL(mlx5_rdma_netdev_free);
-
+#endif
-- 
2.9.0
