From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 4/4] mlxsw: spectrum: Implement SW stats ndo and expose HW stats by default
Date: Tue, 21 Jun 2016 17:15:56 +0200
Message-ID: <1466522156-4795-5-git-send-email-jiri@resnulli.us>
References: <1466522156-4795-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:33909 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbcFUPQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:16:06 -0400
Received: by mail-lb0-f194.google.com with SMTP id w10so2252902lbo.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 08:16:05 -0700 (PDT)
In-Reply-To: <1466522156-4795-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a function to get the SW statistics with an ndo.
Change the default statistics ndo to return HW statistics
(like the one returned by ethtool_ops)
The HW stats are collected to a cache by delayed work every 1 sec.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 110 +++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   5 ++
 2 files changed, 107 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d23948b..855b1c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -534,8 +534,8 @@ err_port_mtu_set:
 }
 
 static struct rtnl_link_stats64 *
-mlxsw_sp_port_get_stats64(struct net_device *dev,
-			  struct rtnl_link_stats64 *stats)
+mlxsw_sp_port_get_sw_stats64(struct net_device *dev,
+			     struct rtnl_link_stats64 *stats)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port_pcpu_stats *p;
@@ -565,6 +565,89 @@ mlxsw_sp_port_get_stats64(struct net_device *dev,
 	return stats;
 }
 
+static int mlxsw_sp_port_get_stats_raw(struct net_device *dev,
+				       char *ppcnt_pl)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port,
+			     MLXSW_REG_PPCNT_IEEE_8023_CNT, 0)
+;
+	return mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
+}
+
+static int mlxsw_sp_port_get_hw_stats(struct net_device *dev,
+				      struct rtnl_link_stats64 *stats)
+{
+	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
+	int err;
+
+	err =  mlxsw_sp_port_get_stats_raw(dev, ppcnt_pl);
+	if (err)
+		goto out;
+
+	stats->tx_packets =
+		mlxsw_reg_ppcnt_a_frames_transmitted_ok_get(ppcnt_pl);
+	stats->rx_packets =
+		mlxsw_reg_ppcnt_a_frames_received_ok_get(ppcnt_pl);
+	stats->tx_bytes =
+		mlxsw_reg_ppcnt_a_octets_transmitted_ok_get(ppcnt_pl);
+	stats->rx_bytes =
+		mlxsw_reg_ppcnt_a_octets_received_ok_get(ppcnt_pl);
+	stats->multicast =
+		mlxsw_reg_ppcnt_a_multicast_frames_received_ok_get(ppcnt_pl);
+
+	stats->rx_crc_errors =
+		mlxsw_reg_ppcnt_a_frame_check_sequence_errors_get(ppcnt_pl);
+	stats->rx_frame_errors =
+		mlxsw_reg_ppcnt_a_alignment_errors_get(ppcnt_pl);
+
+	stats->rx_length_errors = (
+		mlxsw_reg_ppcnt_a_in_range_length_errors_get(ppcnt_pl) +
+		mlxsw_reg_ppcnt_a_out_of_range_length_field_get(ppcnt_pl) +
+		mlxsw_reg_ppcnt_a_frame_too_long_errors_get(ppcnt_pl));
+
+	stats->rx_errors = (stats->rx_crc_errors +
+		stats->rx_frame_errors + stats->rx_length_errors);
+
+out:
+	return err;
+}
+
+static void update_stats_cache(struct work_struct *work)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port =
+		container_of(work, struct mlxsw_sp_port,
+			     hw_stats.update_dw.work);
+
+	if (!netif_carrier_ok(mlxsw_sp_port->dev))
+		goto out;
+
+	mlxsw_sp_port_get_hw_stats(mlxsw_sp_port->dev,
+				   mlxsw_sp_port->hw_stats.cache);
+
+out:
+	mlxsw_core_schedule_dw(&mlxsw_sp_port->hw_stats.update_dw,
+			       MLXSW_HW_STATS_UPDATE_TIME);
+}
+
+/* HW stats are being read by a delayed work to a cache
+ * and this function return it. The use for cache is because
+ * reading HW stats require EMAD and thatfor sleep and we might
+ * be asked to return stats in sleepless mode
+ */
+static struct rtnl_link_stats64 *
+mlxsw_sp_port_get_stats64(struct net_device *dev,
+			  struct rtnl_link_stats64 *stats)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+
+	memcpy(stats, mlxsw_sp_port->hw_stats.cache, sizeof(*stats));
+
+	return stats;
+}
+
 int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
 			   u16 vid_end, bool is_member, bool untagged)
 {
@@ -978,6 +1061,7 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_set_mac_address	= mlxsw_sp_port_set_mac_address,
 	.ndo_change_mtu		= mlxsw_sp_port_change_mtu,
 	.ndo_get_stats64	= mlxsw_sp_port_get_stats64,
+	.ndo_get_sw_stats64     = mlxsw_sp_port_get_sw_stats64,
 	.ndo_vlan_rx_add_vid	= mlxsw_sp_port_add_vid,
 	.ndo_vlan_rx_kill_vid	= mlxsw_sp_port_kill_vid,
 	.ndo_fdb_add		= switchdev_port_fdb_add,
@@ -1198,15 +1282,10 @@ static int mlxsw_sp_port_set_phys_id(struct net_device *dev,
 static void mlxsw_sp_port_get_stats(struct net_device *dev,
 				    struct ethtool_stats *stats, u64 *data)
 {
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
 	int i;
 	int err;
-
-	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port,
-			     MLXSW_REG_PPCNT_IEEE_8023_CNT, 0);
-	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
+	err = mlxsw_sp_port_get_stats_raw(dev, ppcnt_pl);
 	for (i = 0; i < MLXSW_SP_PORT_HW_STATS_LEN; i++)
 		data[i] = !err ? mlxsw_sp_port_hw_stats[i].getter(ppcnt_pl) : 0;
 }
@@ -1718,6 +1797,16 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_alloc_stats;
 	}
 
+	mlxsw_sp_port->hw_stats.cache =
+		kzalloc(sizeof(*mlxsw_sp_port->hw_stats.cache), GFP_KERNEL);
+
+	if (!mlxsw_sp_port->hw_stats.cache) {
+		err = -ENOMEM;
+		goto err_alloc_hw_stats;
+	}
+	INIT_DELAYED_WORK(&mlxsw_sp_port->hw_stats.update_dw,
+			  &update_stats_cache);
+
 	dev->netdev_ops = &mlxsw_sp_port_netdev_ops;
 	dev->ethtool_ops = &mlxsw_sp_port_ethtool_ops;
 
@@ -1814,6 +1903,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_port_vlan_init;
 
 	mlxsw_sp->ports[local_port] = mlxsw_sp_port;
+	mlxsw_core_schedule_dw(&mlxsw_sp_port->hw_stats.update_dw, 0);
 	return 0;
 
 err_port_vlan_init:
@@ -1830,6 +1920,8 @@ err_port_speed_by_width_set:
 err_port_swid_set:
 err_port_system_port_mapping_set:
 err_dev_addr_init:
+	kfree(mlxsw_sp_port->hw_stats.cache);
+err_alloc_hw_stats:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
 	kfree(mlxsw_sp_port->untagged_vlans);
@@ -1863,6 +1955,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 
 	if (!mlxsw_sp_port)
 		return;
+	cancel_delayed_work_sync(&mlxsw_sp_port->hw_stats.update_dw);
 	mlxsw_sp->ports[local_port] = NULL;
 	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
@@ -1872,6 +1965,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
+	kfree(mlxsw_sp_port->hw_stats.cache);
 	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
 	free_netdev(mlxsw_sp_port->dev);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 36c9835..e393c2c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -240,6 +240,11 @@ struct mlxsw_sp_port {
 	unsigned long *untagged_vlans;
 	/* VLAN interfaces */
 	struct list_head vports_list;
+	struct {
+		#define MLXSW_HW_STATS_UPDATE_TIME HZ
+		struct rtnl_link_stats64 *cache;
+		struct delayed_work update_dw;
+	} hw_stats;
 };
 
 static inline bool
-- 
2.5.5
