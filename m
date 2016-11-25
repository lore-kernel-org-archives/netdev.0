From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/19] mlxsw: spectrum: Add policers for trap groups
Date: Fri, 25 Nov 2016 10:33:47 +0100
Message-ID: <1480066427-3961-20-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34861 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752921AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id a20so7222669wme.2
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:12 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Configure policers and connect them to trap groups.

While many trap groups share policer's configuration they don't share
the actual policer because each trap group represents a different
flow / protocol and we don't want one of them to be able to exceed its
rate on behalf of another.
For example, if STP and LLDP gets to send 128 packets/sec each, if we
put them in one 256 packets/sec policer, one can send 200 packets while
the other only 50.

Note that IP2ME covers lots of flows, so it's limit is set to match the
cpu ability to handle data.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 74 +++++++++++++++++++++++++-
 1 file changed, 72 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 2207001..fece974 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2767,20 +2767,82 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_NO_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
 };
 
+static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
+{
+	char qpcr_pl[MLXSW_REG_QPCR_LEN];
+	enum mlxsw_reg_qpcr_ir_units ir_units;
+	int max_cpu_policers;
+	bool is_bytes;
+	u8 burst_size;
+	u32 rate;
+	int i, err;
+
+	if (!MLXSW_CORE_RES_VALID(mlxsw_core, MAX_CPU_POLICERS))
+		return -EIO;
+
+	max_cpu_policers = MLXSW_CORE_RES_GET(mlxsw_core, MAX_CPU_POLICERS);
+
+	ir_units = MLXSW_REG_QPCR_IR_UNITS_M;
+	for (i = 0; i < max_cpu_policers; i++) {
+		is_bytes = false;
+		switch (i) {
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_STP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LACP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LLDP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_OSPF:
+			rate = 128;
+			burst_size = 7;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IGMP:
+			rate = 16 * 1024;
+			burst_size = 10;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP_IPV4:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP_MISS:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE:
+			rate = 1024;
+			burst_size = 7;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IP2ME:
+			is_bytes = true;
+			rate = 4 * 1024;
+			burst_size = 4;
+			break;
+		default:
+			continue;
+		}
+
+		mlxsw_reg_qpcr_pack(qpcr_pl, i, ir_units, is_bytes, rate,
+				    burst_size);
+		err = mlxsw_reg_write(mlxsw_core, MLXSW_REG(qpcr), qpcr_pl);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
 	enum mlxsw_reg_htgt_trap_group i;
+	int max_cpu_policers;
 	int max_trap_groups;
 	u8 priority, tc;
+	u16 policer_id;
 	int err;
 
 	if (!MLXSW_CORE_RES_VALID(mlxsw_core, MAX_TRAP_GROUPS))
 		return -EIO;
 
 	max_trap_groups = MLXSW_CORE_RES_GET(mlxsw_core, MAX_TRAP_GROUPS);
+	max_cpu_policers = MLXSW_CORE_RES_GET(mlxsw_core, MAX_CPU_POLICERS);
 
 	for (i = 0; i < max_trap_groups; i++) {
+		policer_id = i;
 		switch (i) {
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_STP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LACP:
@@ -2812,13 +2874,17 @@ static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_EVENT:
 			priority = MLXSW_REG_HTGT_DEFAULT_PRIORITY;
 			tc = MLXSW_REG_HTGT_DEFAULT_TC;
+			policer_id = MLXSW_REG_HTGT_INVALID_POLICER;
 			break;
 		default:
 			continue;
 		}
 
-		mlxsw_reg_htgt_pack(htgt_pl, i, MLXSW_REG_HTGT_INVALID_POLICER,
-				    priority, tc);
+		if (max_cpu_policers <= policer_id &&
+		    policer_id != MLXSW_REG_HTGT_INVALID_POLICER)
+			return -EIO;
+
+		mlxsw_reg_htgt_pack(htgt_pl, i, policer_id, priority, tc);
 		err = mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
 		if (err)
 			return err;
@@ -2832,6 +2898,10 @@ static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
 	int i;
 	int err;
 
+	err = mlxsw_sp_cpu_policers_set(mlxsw_sp->core);
+	if (err)
+		return err;
+
 	err = mlxsw_sp_trap_groups_set(mlxsw_sp->core);
 	if (err)
 		return err;
-- 
2.7.4
