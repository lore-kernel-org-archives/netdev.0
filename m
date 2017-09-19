From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/13] mlxsw: spectrum: Change init order
Date: Tue, 19 Sep 2017 10:00:08 +0200
Message-ID: <20170919080020.5870-2-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34085 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbdISIAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:24 -0400
Received: by mail-wr0-f194.google.com with SMTP id k20so1712151wre.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:23 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The multicast router offloading code is going to require the counter_pools
initialization to occur before the router initialization, thus, change the
spectrum initialization order to fix it.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 696b99e..9728416 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3693,6 +3693,12 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_switchdev_init;
 	}
 
+	err = mlxsw_sp_counter_pool_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to init counter pool\n");
+		goto err_counter_pool_init;
+	}
+
 	err = mlxsw_sp_router_init(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to initialize router\n");
@@ -3711,12 +3717,6 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_acl_init;
 	}
 
-	err = mlxsw_sp_counter_pool_init(mlxsw_sp);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Failed to init counter pool\n");
-		goto err_counter_pool_init;
-	}
-
 	err = mlxsw_sp_dpipe_init(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to init pipeline debug\n");
@@ -3734,14 +3734,14 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 err_ports_create:
 	mlxsw_sp_dpipe_fini(mlxsw_sp);
 err_dpipe_init:
-	mlxsw_sp_counter_pool_fini(mlxsw_sp);
-err_counter_pool_init:
 	mlxsw_sp_acl_fini(mlxsw_sp);
 err_acl_init:
 	mlxsw_sp_span_fini(mlxsw_sp);
 err_span_init:
 	mlxsw_sp_router_fini(mlxsw_sp);
 err_router_init:
+	mlxsw_sp_counter_pool_fini(mlxsw_sp);
+err_counter_pool_init:
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 err_switchdev_init:
 	mlxsw_sp_lag_fini(mlxsw_sp);
@@ -3760,10 +3760,10 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
 	mlxsw_sp_dpipe_fini(mlxsw_sp);
-	mlxsw_sp_counter_pool_fini(mlxsw_sp);
 	mlxsw_sp_acl_fini(mlxsw_sp);
 	mlxsw_sp_span_fini(mlxsw_sp);
 	mlxsw_sp_router_fini(mlxsw_sp);
+	mlxsw_sp_counter_pool_fini(mlxsw_sp);
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 	mlxsw_sp_lag_fini(mlxsw_sp);
 	mlxsw_sp_buffers_fini(mlxsw_sp);
-- 
2.9.5
