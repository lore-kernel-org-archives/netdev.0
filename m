From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum: Change stats cache to be local
Date: Thu, 26 Oct 2017 10:55:32 +0200
Message-ID: <20171026085533.4448-2-jiri@resnulli.us>
References: <20171026085533.4448-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:54609 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdJZIzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:55:37 -0400
Received: by mail-wr0-f194.google.com with SMTP id o44so2407853wrf.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 01:55:36 -0700 (PDT)
In-Reply-To: <20171026085533.4448-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change the HW stats cache to be local. Rename it for better clarity.
It holds the results of the last result of HW stats that are being read
periodically, in order to have answer for stats request immediately.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 24 +++++++-----------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  4 ++--
 2 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 12b6ac4..0219269 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1328,16 +1328,16 @@ static void update_stats_cache(struct work_struct *work)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port =
 		container_of(work, struct mlxsw_sp_port,
-			     hw_stats.update_dw.work);
+			     periodic_hw_stats.update_dw.work);
 
 	if (!netif_carrier_ok(mlxsw_sp_port->dev))
 		goto out;
 
 	mlxsw_sp_port_get_hw_stats(mlxsw_sp_port->dev,
-				   mlxsw_sp_port->hw_stats.cache);
+				   &mlxsw_sp_port->periodic_hw_stats.stats);
 
 out:
-	mlxsw_core_schedule_dw(&mlxsw_sp_port->hw_stats.update_dw,
+	mlxsw_core_schedule_dw(&mlxsw_sp_port->periodic_hw_stats.update_dw,
 			       MLXSW_HW_STATS_UPDATE_TIME);
 }
 
@@ -1350,7 +1350,7 @@ mlxsw_sp_port_get_stats64(struct net_device *dev,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 
-	memcpy(stats, mlxsw_sp_port->hw_stats.cache, sizeof(*stats));
+	memcpy(stats, &mlxsw_sp_port->periodic_hw_stats.stats, sizeof(*stats));
 }
 
 static int __mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -2905,14 +2905,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_alloc_sample;
 	}
 
-	mlxsw_sp_port->hw_stats.cache =
-		kzalloc(sizeof(*mlxsw_sp_port->hw_stats.cache), GFP_KERNEL);
-
-	if (!mlxsw_sp_port->hw_stats.cache) {
-		err = -ENOMEM;
-		goto err_alloc_hw_stats;
-	}
-	INIT_DELAYED_WORK(&mlxsw_sp_port->hw_stats.update_dw,
+	INIT_DELAYED_WORK(&mlxsw_sp_port->periodic_hw_stats.update_dw,
 			  &update_stats_cache);
 
 	dev->netdev_ops = &mlxsw_sp_port_netdev_ops;
@@ -3026,7 +3019,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	mlxsw_core_port_eth_set(mlxsw_sp->core, mlxsw_sp_port->local_port,
 				mlxsw_sp_port, dev, mlxsw_sp_port->split,
 				module);
-	mlxsw_core_schedule_dw(&mlxsw_sp_port->hw_stats.update_dw, 0);
+	mlxsw_core_schedule_dw(&mlxsw_sp_port->periodic_hw_stats.update_dw, 0);
 	return 0;
 
 err_register_netdev:
@@ -3049,8 +3042,6 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 err_port_swid_set:
 	mlxsw_sp_port_module_unmap(mlxsw_sp_port);
 err_port_module_map:
-	kfree(mlxsw_sp_port->hw_stats.cache);
-err_alloc_hw_stats:
 	kfree(mlxsw_sp_port->sample);
 err_alloc_sample:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
@@ -3065,7 +3056,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
 
-	cancel_delayed_work_sync(&mlxsw_sp_port->hw_stats.update_dw);
+	cancel_delayed_work_sync(&mlxsw_sp_port->periodic_hw_stats.update_dw);
 	mlxsw_core_port_clear(mlxsw_sp->core, local_port, mlxsw_sp);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
 	mlxsw_sp->ports[local_port] = NULL;
@@ -3075,7 +3066,6 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp_port);
-	kfree(mlxsw_sp_port->hw_stats.cache);
 	kfree(mlxsw_sp_port->sample);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 	WARN_ON_ONCE(!list_empty(&mlxsw_sp_port->vlans_list));
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index dc1b739..aa0cefb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -231,9 +231,9 @@ struct mlxsw_sp_port {
 	struct list_head mall_tc_list;
 	struct {
 		#define MLXSW_HW_STATS_UPDATE_TIME HZ
-		struct rtnl_link_stats64 *cache;
+		struct rtnl_link_stats64 stats;
 		struct delayed_work update_dw;
-	} hw_stats;
+	} periodic_hw_stats;
 	struct mlxsw_sp_port_sample *sample;
 	struct list_head vlans_list;
 };
-- 
2.9.5
