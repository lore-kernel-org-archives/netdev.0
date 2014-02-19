From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 2/3] net/mlx4: Set number of RX rings in a utility function
Date: Wed, 19 Feb 2014 14:58:03 +0200
Message-ID: <1392814684-2129-3-git-send-email-amirv@mellanox.com>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32814 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753471AbaBSM62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 07:58:28 -0500
In-Reply-To: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

mlx4_en_add() is too long.
Moving set number of RX rings to a utiltity function to improve
readability and modulization of the code.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c | 15 ++-------------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 22 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  2 +-
 3 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index d357bf5..fa2f6e7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -274,19 +274,8 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
 		mlx4_en_init_timestamp(mdev);
 
-	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
-		if (!dev->caps.comp_pool) {
-			mdev->profile.prof[i].rx_ring_num =
-				rounddown_pow_of_two(max_t(int, MIN_RX_RINGS,
-							   min_t(int,
-								 dev->caps.num_comp_vectors,
-								 DEF_RX_RINGS)));
-		} else {
-			mdev->profile.prof[i].rx_ring_num = rounddown_pow_of_two(
-				min_t(int, dev->caps.comp_pool/
-				      dev->caps.num_ports - 1 , MAX_MSIX_P_PORT - 1));
-		}
-	}
+	/* Set default number of RX rings*/
+	mlx4_en_set_num_rx_rings(mdev);
 
 	/* Create our own workqueue for reset/multicast tasks
 	 * Note: we cannot use the shared workqueue because of deadlocks caused
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b0eba6d..61e44ae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -318,6 +318,28 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 	}
 }
 
+void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
+{
+	int i;
+	int num_of_eqs;
+	struct mlx4_dev *dev = mdev->dev;
+
+	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
+		if (!dev->caps.comp_pool)
+			num_of_eqs = max_t(int, MIN_RX_RINGS,
+					   min_t(int,
+						 dev->caps.num_comp_vectors,
+						 DEF_RX_RINGS));
+		else
+			num_of_eqs = min_t(int, MAX_MSIX_P_PORT,
+					   dev->caps.comp_pool/
+					   dev->caps.num_ports) - 1;
+
+		mdev->profile.prof[i].rx_ring_num =
+			rounddown_pow_of_two(num_of_eqs);
+	}
+}
+
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring **pring,
 			   u32 size, u16 stride, int node)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 101d636..f97a0d3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -738,7 +738,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     int cq, int user_prio);
 void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring);
-
+void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev);
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring **pring,
 			   u32 size, u16 stride, int node);
-- 
1.8.3.4
