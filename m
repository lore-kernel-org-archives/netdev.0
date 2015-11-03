From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 4/7] net/mlx5e: Don't allow more than max supported channels
Date: Tue,  3 Nov 2015 08:07:21 +0200
Message-ID: <1446530844-14077-5-git-send-email-ogerlitz@mellanox.com>
References: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38568 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753099AbbKCGIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 01:08:06 -0500
In-Reply-To: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Consider MLX5E_MAX_NUM_CHANNELS @ethtool set/get_channels

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h         | 6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 5 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    | 3 +--
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0983a20..f2ae62d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -617,5 +617,11 @@ static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
 	mlx5_cq_arm(mcq, MLX5_CQ_DB_REQ_NOT, mcq->uar->map, NULL, cq->wq.cc);
 }
 
+static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
+{
+	return min_t(int, mdev->priv.eq_table.num_comp_vectors,
+		     MLX5E_MAX_NUM_CHANNELS);
+}
+
 extern const struct ethtool_ops mlx5e_ethtool_ops;
 u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index bce9126..2e022e9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -345,9 +345,8 @@ static void mlx5e_get_channels(struct net_device *dev,
 			       struct ethtool_channels *ch)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	int ncv = priv->mdev->priv.eq_table.num_comp_vectors;
 
-	ch->max_combined   = ncv;
+	ch->max_combined   = mlx5e_get_max_num_channels(priv->mdev);
 	ch->combined_count = priv->params.num_channels;
 }
 
@@ -355,7 +354,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 			      struct ethtool_channels *ch)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	int ncv = priv->mdev->priv.eq_table.num_comp_vectors;
+	int ncv = mlx5e_get_max_num_channels(priv->mdev);
 	unsigned int count = ch->combined_count;
 	bool was_opened;
 	int err = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0bab33c..febf711 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2047,8 +2047,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 {
 	struct net_device *netdev;
 	struct mlx5e_priv *priv;
-	int nch = min_t(int, mdev->priv.eq_table.num_comp_vectors,
-			MLX5E_MAX_NUM_CHANNELS);
+	int nch = mlx5e_get_max_num_channels(mdev);
 	int err;
 
 	if (mlx5e_check_required_hca_cap(mdev))
-- 
2.3.7
