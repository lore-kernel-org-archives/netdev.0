From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum: Expose per-tc counters via ethtool
Date: Tue, 19 Jul 2016 15:35:54 +0200
Message-ID: <1468935354-7008-3-git-send-email-jiri@resnulli.us>
References: <1468935354-7008-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36452 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbcGSNf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 09:35:59 -0400
Received: by mail-wm0-f68.google.com with SMTP id x83so2838856wma.3
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 06:35:59 -0700 (PDT)
In-Reply-To: <1468935354-7008-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Expose the transmit queue length of each traffic class and the amount of
unicast packets discarded due to insufficient room in the shared buffer.

The first counter allows us to debug user priority to traffic class
mapping, whereas the drop counter is useful when determining shared buffer
configuration.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 18 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 48 +++++++++++++++++++++++++-
 2 files changed, 65 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0cc1485..b669b04 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2503,6 +2503,7 @@ MLXSW_ITEM32(reg, ppcnt, pnat, 0x00, 14, 2);
 enum mlxsw_reg_ppcnt_grp {
 	MLXSW_REG_PPCNT_IEEE_8023_CNT = 0x0,
 	MLXSW_REG_PPCNT_PRIO_CNT = 0x10,
+	MLXSW_REG_PPCNT_TC_CNT = 0x11,
 };
 
 /* reg_ppcnt_grp
@@ -2703,6 +2704,23 @@ MLXSW_ITEM64(reg, ppcnt, tx_pause_duration, 0x08 + 0x68, 0, 64);
  */
 MLXSW_ITEM64(reg, ppcnt, tx_pause_transition, 0x08 + 0x70, 0, 64);
 
+/* Ethernet Per Traffic Group Counters */
+
+/* reg_ppcnt_tc_transmit_queue
+ * Contains the transmit queue depth in cells of traffic class
+ * selected by prio_tc and the port selected by local_port.
+ * The field cannot be cleared.
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, tc_transmit_queue, 0x08 + 0x00, 0, 64);
+
+/* reg_ppcnt_tc_no_buffer_discard_uc
+ * The number of unicast packets dropped due to lack of shared
+ * buffer resources.
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, tc_no_buffer_discard_uc, 0x08 + 0x08, 0, 64);
+
 static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port,
 					enum mlxsw_reg_ppcnt_grp grp,
 					u8 prio_tc)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 784a2cd..3e7920b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1017,8 +1017,29 @@ static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_prio_stats[] = {
 
 #define MLXSW_SP_PORT_HW_PRIO_STATS_LEN ARRAY_SIZE(mlxsw_sp_port_hw_prio_stats)
 
+static u64 mlxsw_reg_ppcnt_tc_transmit_queue_bytes_get(char *ppcnt_pl)
+{
+	u64 transmit_queue = mlxsw_reg_ppcnt_tc_transmit_queue_get(ppcnt_pl);
+
+	return MLXSW_SP_CELLS_TO_BYTES(transmit_queue);
+}
+
+static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_tc_stats[] = {
+	{
+		.str = "tc_transmit_queue_tc",
+		.getter = mlxsw_reg_ppcnt_tc_transmit_queue_bytes_get,
+	},
+	{
+		.str = "tc_no_buffer_discard_uc_tc",
+		.getter = mlxsw_reg_ppcnt_tc_no_buffer_discard_uc_get,
+	},
+};
+
+#define MLXSW_SP_PORT_HW_TC_STATS_LEN ARRAY_SIZE(mlxsw_sp_port_hw_tc_stats)
+
 #define MLXSW_SP_PORT_ETHTOOL_STATS_LEN (MLXSW_SP_PORT_HW_STATS_LEN + \
-					 MLXSW_SP_PORT_HW_PRIO_STATS_LEN * \
+					 (MLXSW_SP_PORT_HW_PRIO_STATS_LEN + \
+					  MLXSW_SP_PORT_HW_TC_STATS_LEN) * \
 					 IEEE_8021QAZ_MAX_TCS)
 
 static void mlxsw_sp_port_get_prio_strings(u8 **p, int prio)
@@ -1032,6 +1053,17 @@ static void mlxsw_sp_port_get_prio_strings(u8 **p, int prio)
 	}
 }
 
+static void mlxsw_sp_port_get_tc_strings(u8 **p, int tc)
+{
+	int i;
+
+	for (i = 0; i < MLXSW_SP_PORT_HW_TC_STATS_LEN; i++) {
+		snprintf(*p, ETH_GSTRING_LEN, "%s_%d",
+			 mlxsw_sp_port_hw_tc_stats[i].str, tc);
+		*p += ETH_GSTRING_LEN;
+	}
+}
+
 static void mlxsw_sp_port_get_strings(struct net_device *dev,
 				      u32 stringset, u8 *data)
 {
@@ -1049,6 +1081,9 @@ static void mlxsw_sp_port_get_strings(struct net_device *dev,
 		for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
 			mlxsw_sp_port_get_prio_strings(&p, i);
 
+		for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+			mlxsw_sp_port_get_tc_strings(&p, i);
+
 		break;
 	}
 }
@@ -1089,6 +1124,10 @@ mlxsw_sp_get_hw_stats_by_group(struct mlxsw_sp_port_hw_stats **p_hw_stats,
 		*p_hw_stats = mlxsw_sp_port_hw_prio_stats;
 		*p_len = MLXSW_SP_PORT_HW_PRIO_STATS_LEN;
 		break;
+	case MLXSW_REG_PPCNT_TC_CNT:
+		*p_hw_stats = mlxsw_sp_port_hw_tc_stats;
+		*p_len = MLXSW_SP_PORT_HW_TC_STATS_LEN;
+		break;
 	default:
 		WARN_ON(1);
 		return -ENOTSUPP;
@@ -1132,6 +1171,13 @@ static void mlxsw_sp_port_get_stats(struct net_device *dev,
 					  data, data_index);
 		data_index += MLXSW_SP_PORT_HW_PRIO_STATS_LEN;
 	}
+
+	/* Per-TC Counters */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		__mlxsw_sp_port_get_stats(dev, MLXSW_REG_PPCNT_TC_CNT, i,
+					  data, data_index);
+		data_index += MLXSW_SP_PORT_HW_TC_STATS_LEN;
+	}
 }
 
 static int mlxsw_sp_port_get_sset_count(struct net_device *dev, int sset)
-- 
2.5.5
