From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/4] net/mlx5: Unmap only the relevant IO memory mapping
Date: Sun,  1 May 2016 22:59:54 +0300
Message-ID: <1462132797-22853-2-git-send-email-saeedm@mellanox.com>
References: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:55758 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751942AbcEAUCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 16:02:07 -0400
In-Reply-To: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

When freeing UAR the driver tries to unmap uar->map and uar->bf_map
which are mutually exclusive thus always unmapping a NULL pointer.
Make sure we only call iounmap() once, for the actual mapping.

Fixes: 0ba422410bbf ('net/mlx5: Fix global UAR mapping')
Signed-off-by: Gal Pressman <galp@mellanox.com>
Reported-by: Doron Tsur <doront@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/uar.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index 8ba080e..5ff8af4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -269,8 +269,10 @@ EXPORT_SYMBOL(mlx5_alloc_map_uar);
 
 void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
 {
-	iounmap(uar->map);
-	iounmap(uar->bf_map);
+	if (uar->map)
+		iounmap(uar->map);
+	else
+		iounmap(uar->bf_map);
 	mlx5_cmd_free_uar(mdev, uar->index);
 }
 EXPORT_SYMBOL(mlx5_unmap_free_uar);
-- 
2.8.0
