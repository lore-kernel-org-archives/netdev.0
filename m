From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/10] net/mlx5e: IPoIB, Change parameters default values
Date: Tue, 20 Jun 2017 17:13:09 +0300
Message-ID: <20170620141314.25620-6-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42045 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751116AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Add function that sets the default values for ipoib, setting/clearing
abilities that IPoIB doesn't support, like RQ size in this case.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index cc9ff4014e5c..45ca869118c0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -36,6 +36,7 @@
 #include "ipoib.h"
 
 #define IB_DEFAULT_Q_KEY   0xb1b
+#define MLX5I_PARAMS_DEFAULT_LOG_RQ_SIZE 9
 
 static int mlx5i_open(struct net_device *netdev);
 static int mlx5i_close(struct net_device *netdev);
@@ -50,6 +51,19 @@ static const struct net_device_ops mlx5i_netdev_ops = {
 };
 
 /* IPoIB mlx5 netdev profile */
+static void mlx5i_build_nic_params(struct mlx5_core_dev *mdev,
+				   struct mlx5e_params *params)
+{
+	/* Override RQ params as IPoIB supports only LINKED LIST RQ for now */
+	mlx5e_set_rq_type_params(mdev, params, MLX5_WQ_TYPE_LINKED_LIST);
+
+	/* RQ size in ipoib by default is 512 */
+	params->log_rq_size = is_kdump_kernel() ?
+		MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE :
+		MLX5I_PARAMS_DEFAULT_LOG_RQ_SIZE;
+
+	params->lro_en = false;
+}
 
 /* Called directly after IPoIB netdevice was created to initialize SW structs */
 static void mlx5i_init(struct mlx5_core_dev *mdev,
@@ -65,10 +79,7 @@ static void mlx5i_init(struct mlx5_core_dev *mdev,
 	priv->ppriv       = ppriv;
 
 	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
-
-	/* Override RQ params as IPoIB supports only LINKED LIST RQ for now */
-	mlx5e_set_rq_type_params(mdev, &priv->channels.params, MLX5_WQ_TYPE_LINKED_LIST);
-	priv->channels.params.lro_en = false;
+	mlx5i_build_nic_params(mdev, &priv->channels.params);
 
 	mutex_init(&priv->state_lock);
 
-- 
2.11.0
