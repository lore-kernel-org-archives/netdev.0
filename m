From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 04/13] net/mlx4_core: Remove counters table allocation from VF flow
Date: Wed, 10 Jun 2015 17:59:29 +0300
Message-ID: <1433948378-17570-5-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37807 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933140AbbFJPAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:00:25 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Since virtual functions get their counters indices allocation from the PF,
allocate counters indices bitmap only in case the function isn't virtual.

Also, check that the device has counters to allocate before creating the
indices bitmap table.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 9c1b8b0..c3fe49e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2198,6 +2198,9 @@ static int mlx4_init_counters_table(struct mlx4_dev *dev)
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS))
 		return -ENOENT;
 
+	if (!dev->caps.max_counters)
+		return -ENOSPC;
+
 	nent_pow2 = roundup_pow_of_two(dev->caps.max_counters);
 	/* reserve last counter index for sink counter */
 	return mlx4_bitmap_init(&priv->counters_bitmap, nent_pow2,
@@ -2210,6 +2213,9 @@ static void mlx4_cleanup_counters_table(struct mlx4_dev *dev)
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS))
 		return;
 
+	if (!dev->caps.max_counters)
+		return;
+
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->counters_bitmap);
 }
 
@@ -2425,10 +2431,12 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 		goto err_srq_table_free;
 	}
 
-	err = mlx4_init_counters_table(dev);
-	if (err && err != -ENOENT) {
-		mlx4_err(dev, "Failed to initialize counters table, aborting\n");
-		goto err_qp_table_free;
+	if (!mlx4_is_slave(dev)) {
+		err = mlx4_init_counters_table(dev);
+		if (err && err != -ENOENT) {
+			mlx4_err(dev, "Failed to initialize counters table, aborting\n");
+			goto err_qp_table_free;
+		}
 	}
 
 	if (!mlx4_is_slave(dev)) {
@@ -2470,7 +2478,8 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)
 	return 0;
 
 err_counters_table_free:
-	mlx4_cleanup_counters_table(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_cleanup_counters_table(dev);
 
 err_qp_table_free:
 	mlx4_cleanup_qp_table(dev);
@@ -3201,7 +3210,8 @@ err_port:
 	for (--port; port >= 1; --port)
 		mlx4_cleanup_port_info(&priv->port[port]);
 
-	mlx4_cleanup_counters_table(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_cleanup_counters_table(dev);
 	mlx4_cleanup_qp_table(dev);
 	mlx4_cleanup_srq_table(dev);
 	mlx4_cleanup_cq_table(dev);
@@ -3499,7 +3509,8 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 		mlx4_free_resource_tracker(dev,
 					   RES_TR_FREE_SLAVES_ONLY);
 
-	mlx4_cleanup_counters_table(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_cleanup_counters_table(dev);
 	mlx4_cleanup_qp_table(dev);
 	mlx4_cleanup_srq_table(dev);
 	mlx4_cleanup_cq_table(dev);
-- 
1.7.1
