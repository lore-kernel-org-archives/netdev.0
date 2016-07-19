From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum: Expose per-priority counters via ethtool
Date: Tue, 19 Jul 2016 15:35:53 +0200
Message-ID: <1468935354-7008-2-git-send-email-jiri@resnulli.us>
References: <1468935354-7008-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34167 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693AbcGSNf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 09:35:58 -0400
Received: by mail-wm0-f67.google.com with SMTP id q128so2870092wma.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 06:35:57 -0700 (PDT)
In-Reply-To: <1468935354-7008-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Expose per-priority bytes / packets / PFC packets counters via ethtool.

These counters are very useful when debugging QoS functionality and
provide a better insight into the device's forwarding plane.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 116 +++++++++++++++++++++++--
 1 file changed, 107 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c812513..784a2cd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -899,7 +899,7 @@ struct mlxsw_sp_port_hw_stats {
 	u64 (*getter)(char *payload);
 };
 
-static const struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_stats[] = {
+static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_stats[] = {
 	{
 		.str = "a_frames_transmitted_ok",
 		.getter = mlxsw_reg_ppcnt_a_frames_transmitted_ok_get,
@@ -980,6 +980,58 @@ static const struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_stats[] = {
 
 #define MLXSW_SP_PORT_HW_STATS_LEN ARRAY_SIZE(mlxsw_sp_port_hw_stats)
 
+static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_prio_stats[] = {
+	{
+		.str = "rx_octets_prio",
+		.getter = mlxsw_reg_ppcnt_rx_octets_get,
+	},
+	{
+		.str = "rx_frames_prio",
+		.getter = mlxsw_reg_ppcnt_rx_frames_get,
+	},
+	{
+		.str = "tx_octets_prio",
+		.getter = mlxsw_reg_ppcnt_tx_octets_get,
+	},
+	{
+		.str = "tx_frames_prio",
+		.getter = mlxsw_reg_ppcnt_tx_frames_get,
+	},
+	{
+		.str = "rx_pause_prio",
+		.getter = mlxsw_reg_ppcnt_rx_pause_get,
+	},
+	{
+		.str = "rx_pause_duration_prio",
+		.getter = mlxsw_reg_ppcnt_rx_pause_duration_get,
+	},
+	{
+		.str = "tx_pause_prio",
+		.getter = mlxsw_reg_ppcnt_tx_pause_get,
+	},
+	{
+		.str = "tx_pause_duration_prio",
+		.getter = mlxsw_reg_ppcnt_tx_pause_duration_get,
+	},
+};
+
+#define MLXSW_SP_PORT_HW_PRIO_STATS_LEN ARRAY_SIZE(mlxsw_sp_port_hw_prio_stats)
+
+#define MLXSW_SP_PORT_ETHTOOL_STATS_LEN (MLXSW_SP_PORT_HW_STATS_LEN + \
+					 MLXSW_SP_PORT_HW_PRIO_STATS_LEN * \
+					 IEEE_8021QAZ_MAX_TCS)
+
+static void mlxsw_sp_port_get_prio_strings(u8 **p, int prio)
+{
+	int i;
+
+	for (i = 0; i < MLXSW_SP_PORT_HW_PRIO_STATS_LEN; i++) {
+		snprintf(*p, ETH_GSTRING_LEN, "%s_%d",
+			 mlxsw_sp_port_hw_prio_stats[i].str, prio);
+		*p += ETH_GSTRING_LEN;
+	}
+}
+
 static void mlxsw_sp_port_get_strings(struct net_device *dev,
 				      u32 stringset, u8 *data)
 {
@@ -993,6 +1045,10 @@ static void mlxsw_sp_port_get_strings(struct net_device *dev,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
+
+		for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+			mlxsw_sp_port_get_prio_strings(&p, i);
+
 		break;
 	}
 }
@@ -1020,27 +1076,69 @@ static int mlxsw_sp_port_set_phys_id(struct net_device *dev,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mlcr), mlcr_pl);
 }
 
-static void mlxsw_sp_port_get_stats(struct net_device *dev,
-				    struct ethtool_stats *stats, u64 *data)
+static int
+mlxsw_sp_get_hw_stats_by_group(struct mlxsw_sp_port_hw_stats **p_hw_stats,
+			       int *p_len, enum mlxsw_reg_ppcnt_grp grp)
+{
+	switch (grp) {
+	case  MLXSW_REG_PPCNT_IEEE_8023_CNT:
+		*p_hw_stats = mlxsw_sp_port_hw_stats;
+		*p_len = MLXSW_SP_PORT_HW_STATS_LEN;
+		break;
+	case MLXSW_REG_PPCNT_PRIO_CNT:
+		*p_hw_stats = mlxsw_sp_port_hw_prio_stats;
+		*p_len = MLXSW_SP_PORT_HW_PRIO_STATS_LEN;
+		break;
+	default:
+		WARN_ON(1);
+		return -ENOTSUPP;
+	}
+	return 0;
+}
+
+static void __mlxsw_sp_port_get_stats(struct net_device *dev,
+				      enum mlxsw_reg_ppcnt_grp grp, int prio,
+				      u64 *data, int data_index)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_port_hw_stats *hw_stats;
 	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
-	int i;
+	int i, len;
 	int err;
 
-	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port,
-			     MLXSW_REG_PPCNT_IEEE_8023_CNT, 0);
+	err = mlxsw_sp_get_hw_stats_by_group(&hw_stats, &len, grp);
+	if (err)
+		return;
+	mlxsw_reg_ppcnt_pack(ppcnt_pl, mlxsw_sp_port->local_port, grp, prio);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ppcnt), ppcnt_pl);
-	for (i = 0; i < MLXSW_SP_PORT_HW_STATS_LEN; i++)
-		data[i] = !err ? mlxsw_sp_port_hw_stats[i].getter(ppcnt_pl) : 0;
+	for (i = 0; i < len; i++)
+		data[data_index + i] = !err ? hw_stats[i].getter(ppcnt_pl) : 0;
+}
+
+static void mlxsw_sp_port_get_stats(struct net_device *dev,
+				    struct ethtool_stats *stats, u64 *data)
+{
+	int i, data_index = 0;
+
+	/* IEEE 802.3 Counters */
+	__mlxsw_sp_port_get_stats(dev, MLXSW_REG_PPCNT_IEEE_8023_CNT, 0,
+				  data, data_index);
+	data_index = MLXSW_SP_PORT_HW_STATS_LEN;
+
+	/* Per-Priority Counters */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		__mlxsw_sp_port_get_stats(dev, MLXSW_REG_PPCNT_PRIO_CNT, i,
+					  data, data_index);
+		data_index += MLXSW_SP_PORT_HW_PRIO_STATS_LEN;
+	}
 }
 
 static int mlxsw_sp_port_get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return MLXSW_SP_PORT_HW_STATS_LEN;
+		return MLXSW_SP_PORT_ETHTOOL_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.5.5
