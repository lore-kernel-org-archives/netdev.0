From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 4/5] net/mlx4_core: Fixing error flow in case of QUERY_FW failure
Date: Thu,  6 Sep 2012 11:50:51 +0300
Message-ID: <1346921452-2035-5-git-send-email-yevgenyp@mellanox.com>
References: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, Aviad Yehezkel <aviadye@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:56566 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754466Ab2IFIvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:51:33 -0400
In-Reply-To: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviad Yehezkel <aviadye@mellanox.com>

The order of operations was wrong on the teardown flow.

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 827b72d..0fadac5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1234,13 +1234,13 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 				mlx4_info(dev, "non-primary physical function, skipping.\n");
 			else
 				mlx4_err(dev, "QUERY_FW command failed, aborting.\n");
-			goto unmap_bf;
+			return err;
 		}
 
 		err = mlx4_load_fw(dev);
 		if (err) {
 			mlx4_err(dev, "Failed to start FW, aborting.\n");
-			goto unmap_bf;
+			return err;
 		}
 
 		mlx4_cfg.log_pg_sz_m = 1;
@@ -1304,7 +1304,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		err = mlx4_init_slave(dev);
 		if (err) {
 			mlx4_err(dev, "Failed to initialize slave\n");
-			goto unmap_bf;
+			return err;
 		}
 
 		err = mlx4_slave_cap(dev);
@@ -1324,7 +1324,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 	err = mlx4_QUERY_ADAPTER(dev, &adapter);
 	if (err) {
 		mlx4_err(dev, "QUERY_ADAPTER command failed, aborting.\n");
-		goto err_close;
+		goto unmap_bf;
 	}
 
 	priv->eq_table.inta_pin = adapter.inta_pin;
@@ -1332,6 +1332,9 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 	return 0;
 
+unmap_bf:
+	unmap_bf_area(dev);
+
 err_close:
 	mlx4_close_hca(dev);
 
@@ -1344,8 +1347,6 @@ err_stop_fw:
 		mlx4_UNMAP_FA(dev);
 		mlx4_free_icm(dev, priv->fw.fw_icm, 0);
 	}
-unmap_bf:
-	unmap_bf_area(dev);
 	return err;
 }
 
-- 
1.7.7
