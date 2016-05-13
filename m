From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 4/4] mlxsw: spectrum: Implement SW stats ndo and expose HW stats by default
Date: Fri, 13 May 2016 16:54:17 +0200
Message-ID: <1463151257-3972-5-git-send-email-jiri@resnulli.us>
References: <1463151257-3972-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35986 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058AbcEMOy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 10:54:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id w143so4196075wmw.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 07:54:25 -0700 (PDT)
In-Reply-To: <1463151257-3972-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a function to get the SW statistics with an ndo.
Change the default statistics ndo to return HW statistics
(like the one returned by ethtool_ops)

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v2->v3:
- no change
v1->v2:
- no change
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 65 ++++++++++++++++++++++----
 1 file changed, 57 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4a72737..956e724 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -535,8 +535,8 @@ err_port_mtu_set:
 }
 
 static struct rtnl_link_stats64 *
-mlxsw_sp_port_get_stats64(struct net_device *dev,
-			  struct rtnl_link_stats64 *stats)
+mlxsw_sp_port_get_sw_stats64(struct net_device *dev,
+			     struct rtnl_link_stats64 *stats)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port_pcpu_stats *p;
@@ -566,6 +566,59 @@ mlxsw_sp_port_get_stats64(struct net_device *dev,
 	return stats;
 }
 
+static int mlxsw_sp_port_get_stats_raw(struct net_device *dev,
+				       char *ppcnt_pl)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	int err;
+
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port,
+			     MLXSW_REG_PPCNT_IEEE_8023_CNT, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
+	return err;
+}
+
+static struct rtnl_link_stats64 *
+mlxsw_sp_port_get_stats64(struct net_device *dev,
+			  struct rtnl_link_stats64 *stats)
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
+	stats->multicast +=
+		mlxsw_reg_ppcnt_a_broadcast_frames_received_ok_get(ppcnt_pl);
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
+out:
+	return stats;
+}
+
 int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
 			   u16 vid_end, bool is_member, bool untagged)
 {
@@ -980,6 +1033,7 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_set_mac_address	= mlxsw_sp_port_set_mac_address,
 	.ndo_change_mtu		= mlxsw_sp_port_change_mtu,
 	.ndo_get_stats64	= mlxsw_sp_port_get_stats64,
+	.ndo_get_sw_stats64     = mlxsw_sp_port_get_sw_stats64,
 	.ndo_vlan_rx_add_vid	= mlxsw_sp_port_add_vid,
 	.ndo_vlan_rx_kill_vid	= mlxsw_sp_port_kill_vid,
 	.ndo_fdb_add		= switchdev_port_fdb_add,
@@ -1200,15 +1254,10 @@ static int mlxsw_sp_port_set_phys_id(struct net_device *dev,
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
-- 
2.5.5
