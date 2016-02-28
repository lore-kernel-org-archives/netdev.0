From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 06/10] net/mlx5e: Don't try to modify CQ moderation if it is not supported
Date: Sun, 28 Feb 2016 17:09:07 +0200
Message-ID: <1456672151-11749-7-git-send-email-saeedm@mellanox.com>
References: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59846 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758022AbcB1PKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 10:10:53 -0500
In-Reply-To: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

If CQ moderation is not supported by the device, print a warning on
netdevice load, and return error when trying to modify/query cq
moderation via ethtool.

Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4
Ethernet functionality')
Signed-off-by: Gal Pressman <galp@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |    6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   12 ++++++------
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 577b4b1..a1b3bb4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -400,6 +400,9 @@ static int mlx5e_get_coalesce(struct net_device *netdev,
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
+	if (!MLX5_CAP_GEN(priv->mdev, cq_moderation))
+		return -ENOTSUPP;
+
 	coal->rx_coalesce_usecs       = priv->params.rx_cq_moderation_usec;
 	coal->rx_max_coalesced_frames = priv->params.rx_cq_moderation_pkts;
 	coal->tx_coalesce_usecs       = priv->params.tx_cq_moderation_usec;
@@ -417,6 +420,9 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 	int tc;
 	int i;
 
+	if (!MLX5_CAP_GEN(mdev, cq_moderation))
+		return -ENOTSUPP;
+
 	priv->params.tx_cq_moderation_usec = coal->tx_coalesce_usecs;
 	priv->params.tx_cq_moderation_pkts = coal->tx_max_coalesced_frames;
 	priv->params.rx_cq_moderation_usec = coal->rx_coalesce_usecs;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 30fd971..b20a35b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -870,12 +870,10 @@ static int mlx5e_open_cq(struct mlx5e_channel *c,
 	if (err)
 		goto err_destroy_cq;
 
-	err = mlx5_core_modify_cq_moderation(mdev, &cq->mcq,
-					     moderation_usecs,
-					     moderation_frames);
-	if (err)
-		goto err_destroy_cq;
-
+	if (MLX5_CAP_GEN(mdev, cq_moderation))
+		mlx5_core_modify_cq_moderation(mdev, &cq->mcq,
+					       moderation_usecs,
+					       moderation_frames);
 	return 0;
 
 err_destroy_cq:
@@ -2218,6 +2216,8 @@ static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 	}
 	if (!MLX5_CAP_ETH(mdev, self_lb_en_modifiable))
 		mlx5_core_warn(mdev, "Self loop back prevention is not supported\n");
+	if (!MLX5_CAP_GEN(mdev, cq_moderation))
+		mlx5_core_warn(mdev, "CQ modiration is not supported\n");
 
 	return 0;
 }
-- 
1.7.1
