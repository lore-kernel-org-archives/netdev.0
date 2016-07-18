From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Move filters cleanup to a proper location
Date: Mon, 18 Jul 2016 18:35:11 +0300
Message-ID: <1468856112-17858-2-git-send-email-tariqt@mellanox.com>
References: <1468856112-17858-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44253 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751722AbcGRPgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 11:36:43 -0400
In-Reply-To: <1468856112-17858-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Filters cleanup should be done once before destroying net device,
since filters list is contained in the private data.

Fixes: 1eb8c695bda9 ('net/mlx4_en: Add accelerated RFS support')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 4 ++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 3 ---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0c0dfd6..5d809c8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2080,6 +2080,10 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	mdev->upper[priv->port] = NULL;
 	mutex_unlock(&mdev->state_lock);
 
+#ifdef CONFIG_RFS_ACCEL
+	mlx4_en_cleanup_filters(priv);
+#endif
+
 	mlx4_en_free_resources(priv);
 
 	kfree(priv->tx_ring);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c1b3a9c..99b5407 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -514,9 +514,6 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 	ring->rx_info = NULL;
 	kfree(ring);
 	*pring = NULL;
-#ifdef CONFIG_RFS_ACCEL
-	mlx4_en_cleanup_filters(priv);
-#endif
 }
 
 void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
-- 
1.8.3.1
