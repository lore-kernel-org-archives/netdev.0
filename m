From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v10 3/3] mlxsw: spectrum: Implement offload stats ndo and expose HW stats by default
Date: Fri, 16 Sep 2016 15:05:38 +0200
Message-ID: <1474031138-2065-4-git-send-email-jiri@resnulli.us>
References: <1474031138-2065-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34362 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932173AbcIPNFq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 09:05:46 -0400
Received: by mail-wm0-f67.google.com with SMTP id l132so2508808wmf.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 06:05:46 -0700 (PDT)
In-Reply-To: <1474031138-2065-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change the default statistics ndo to return HW statistics
(like the one returned by ethtool_ops).
The HW stats are collected to a cache by delayed work every 1 sec.
Implement the offload stat ndo.
Add a function to get SW statistics, to be called from this function.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 129 +++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   5 +
 2 files changed, 127 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 27bbcaf..171f8dd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -819,9 +819,9 @@ err_span_port_mtu_update:
 	return err;
 }
 
-static struct rtnl_link_stats64 *
-mlxsw_sp_port_get_stats64(struct net_device *dev,
-			  struct rtnl_link_stats64 *stats)
+int
+mlxsw_sp_port_get_sw_stats64(const struct net_device *dev,
+			     struct rtnl_link_stats64 *stats)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port_pcpu_stats *p;
@@ -848,6 +848,107 @@ mlxsw_sp_port_get_stats64(struct net_device *dev,
 		tx_dropped	+= p->tx_dropped;
 	}
 	stats->tx_dropped	= tx_dropped;
+	return 0;
+}
+
+bool mlxsw_sp_port_has_offload_stats(int attr_id)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return true;
+	}
+
+	return false;
+}
+
+int mlxsw_sp_port_get_offload_stats(int attr_id, const struct net_device *dev,
+				    void *sp)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return mlxsw_sp_port_get_sw_stats64(dev, sp);
+	}
+
+	return -EINVAL;
+}
+
+static int mlxsw_sp_port_get_stats_raw(struct net_device *dev, int grp,
+				       int prio, char *ppcnt_pl)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port, grp, prio);
+	return mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
+}
+
+static int mlxsw_sp_port_get_hw_stats(struct net_device *dev,
+				      struct rtnl_link_stats64 *stats)
+{
+	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
+	int err;
+
+	err = mlxsw_sp_port_get_stats_raw(dev, MLXSW_REG_PPCNT_IEEE_8023_CNT,
+					  0, ppcnt_pl);
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
+/* Return the stats from a cache that is updated periodically,
+ * as this function might get called in an atomic context.
+ */
+static struct rtnl_link_stats64 *
+mlxsw_sp_port_get_stats64(struct net_device *dev,
+			  struct rtnl_link_stats64 *stats)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+
+	memcpy(stats, mlxsw_sp_port->hw_stats.cache, sizeof(*stats));
+
 	return stats;
 }
 
@@ -1209,6 +1310,8 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_set_mac_address	= mlxsw_sp_port_set_mac_address,
 	.ndo_change_mtu		= mlxsw_sp_port_change_mtu,
 	.ndo_get_stats64	= mlxsw_sp_port_get_stats64,
+	.ndo_has_offload_stats	= mlxsw_sp_port_has_offload_stats,
+	.ndo_get_offload_stats	= mlxsw_sp_port_get_offload_stats,
 	.ndo_vlan_rx_add_vid	= mlxsw_sp_port_add_vid,
 	.ndo_vlan_rx_kill_vid	= mlxsw_sp_port_kill_vid,
 	.ndo_neigh_construct	= mlxsw_sp_router_neigh_construct,
@@ -1547,8 +1650,6 @@ static void __mlxsw_sp_port_get_stats(struct net_device *dev,
 				      enum mlxsw_reg_ppcnt_grp grp, int prio,
 				      u64 *data, int data_index)
 {
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port_hw_stats *hw_stats;
 	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
 	int i, len;
@@ -1557,8 +1658,7 @@ static void __mlxsw_sp_port_get_stats(struct net_device *dev,
 	err = mlxsw_sp_get_hw_stats_by_group(&hw_stats, &len, grp);
 	if (err)
 		return;
-	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port, grp, prio);
-	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
+	mlxsw_sp_port_get_stats_raw(dev, grp, prio, ppcnt_pl);
 	for (i = 0; i < len; i++)
 		data[data_index + i] = !err ? hw_stats[i].getter(ppcnt_pl) : 0;
 }
@@ -2145,6 +2245,16 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
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
 
@@ -2245,6 +2355,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_core_port_init;
 	}
 
+	mlxsw_core_schedule_dw(&mlxsw_sp_port->hw_stats.update_dw, 0);
 	return 0;
 
 err_core_port_init:
@@ -2265,6 +2376,8 @@ err_port_system_port_mapping_set:
 err_dev_addr_init:
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 err_port_swid_set:
+	kfree(mlxsw_sp_port->hw_stats.cache);
+err_alloc_hw_stats:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
 	kfree(mlxsw_sp_port->untagged_vlans);
@@ -2281,6 +2394,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 
 	if (!mlxsw_sp_port)
 		return;
+	cancel_delayed_work_sync(&mlxsw_sp_port->hw_stats.update_dw);
 	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
 	mlxsw_sp->ports[local_port] = NULL;
@@ -2290,6 +2404,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
+	kfree(mlxsw_sp_port->hw_stats.cache);
 	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
 	WARN_ON_ONCE(!list_empty(&mlxsw_sp_port->vports_list));
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 969c250..49f4caf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -361,6 +361,11 @@ struct mlxsw_sp_port {
 	struct list_head vports_list;
 	/* TC handles */
 	struct list_head mall_tc_list;
+	struct {
+		#define MLXSW_HW_STATS_UPDATE_TIME HZ
+		struct rtnl_link_stats64 *cache;
+		struct delayed_work update_dw;
+	} hw_stats;
 };
 
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
-- 
2.5.5
