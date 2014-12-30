From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_core: Fix error flow in mlx4_init_hca()
Date: Tue, 30 Dec 2014 11:59:50 +0200
Message-ID: <1419933590-9718-3-git-send-email-ogerlitz@mellanox.com>
References: <1419933590-9718-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	talal@labmailer.mlnx, Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36395 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751756AbaL3KAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2014 05:00:15 -0500
In-Reply-To: <1419933590-9718-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

We shouldn't call UNMAP_FA here, this is done in mlx4_load_one.

If mlx4_query_func fails, we need to invoke CLOSE_HCA for both
native and master.

Fixes: a0eacca948d2 ('net/mlx4_core: Refactor mlx4_load_one')
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 943cbd4..03e9eb0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1829,7 +1829,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		err = mlx4_dev_cap(dev, &dev_cap);
 		if (err) {
 			mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting\n");
-			goto err_stop_fw;
+			return err;
 		}
 
 		choose_steering_mode(dev, &dev_cap);
@@ -1860,7 +1860,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 					     &init_hca);
 		if ((long long) icm_size < 0) {
 			err = icm_size;
-			goto err_stop_fw;
+			return err;
 		}
 
 		dev->caps.max_fmr_maps = (1 << (32 - ilog2(dev->caps.num_mpts))) - 1;
@@ -1874,7 +1874,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 		err = mlx4_init_icm(dev, &dev_cap, &init_hca, icm_size);
 		if (err)
-			goto err_stop_fw;
+			return err;
 
 		err = mlx4_INIT_HCA(dev, &init_hca);
 		if (err) {
@@ -1886,7 +1886,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 			err = mlx4_query_func(dev, &dev_cap);
 			if (err < 0) {
 				mlx4_err(dev, "QUERY_FUNC command failed, aborting.\n");
-				goto err_stop_fw;
+				goto err_close;
 			} else if (err & MLX4_QUERY_FUNC_NUM_SYS_EQS) {
 				dev->caps.num_eqs = dev_cap.max_eqs;
 				dev->caps.reserved_eqs = dev_cap.reserved_eqs;
@@ -2006,11 +2006,6 @@ err_free_icm:
 	if (!mlx4_is_slave(dev))
 		mlx4_free_icms(dev);
 
-err_stop_fw:
-	if (!mlx4_is_slave(dev)) {
-		mlx4_UNMAP_FA(dev);
-		mlx4_free_icm(dev, priv->fw.fw_icm, 0);
-	}
 	return err;
 }
 
-- 
1.7.1
