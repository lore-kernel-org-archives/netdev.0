From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 01/11] net/mlx5e: IPoIB, Fix access to invalid memory address
Date: Thu, 28 Sep 2017 07:41:22 +0300
Message-ID: <20170928044132.30940-2-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54366 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751082AbdI1EmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:05 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

When cleaning rdma netdevice we need to save the mdev pointer
because priv is released when we release netdev.

This bug was found using the kernel address sanitizer (KASAN).
use-after-free in mlx5_rdma_netdev_free+0xe3/0x100 [mlx5_core]

Fixes: 48935bbb7ae8 ("net/mlx5e: IPoIB, Add netdevice profile skeleton")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 85298051a3e4..145e392ab849 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -572,12 +572,13 @@ void mlx5_rdma_netdev_free(struct net_device *netdev)
 {
 	struct mlx5e_priv          *priv    = mlx5i_epriv(netdev);
 	const struct mlx5e_profile *profile = priv->profile;
+	struct mlx5_core_dev       *mdev    = priv->mdev;
 
 	mlx5e_detach_netdev(priv);
 	profile->cleanup(priv);
 	destroy_workqueue(priv->wq);
 	free_netdev(netdev);
 
-	mlx5e_destroy_mdev_resources(priv->mdev);
+	mlx5e_destroy_mdev_resources(mdev);
 }
 EXPORT_SYMBOL(mlx5_rdma_netdev_free);
-- 
2.13.0
