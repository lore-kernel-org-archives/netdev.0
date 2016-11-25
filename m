From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/19] mlxsw: Change trap groups setting
Date: Fri, 25 Nov 2016 10:33:42 +0100
Message-ID: <1480066427-3961-15-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33449 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wj0-f195.google.com with SMTP id kp2so4928506wjc.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:06 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Trap groups have many options which we currently set to default values.
In the next patches we will use many of them with non-default values.

Some of these options have no default value, so this patch sets them as
params for the trap group set function. Others almost always use the same
values, so the set function will use this default values. In the rare cases
when they will need to be with other values, these values can be set
directly (using the macros for fields in registers).

Parameters without default value:
TC - the traffic class for packets that hit this trap group.
    (old default is the max tc)
priority - if one packet hits multiple trap groups, the group with the
	   higher priority will "catch" it. (old default is 0)
policer - limit rate policer (old default is disabled)

Default parameters:
swid - switch id, relevant for the emad trap only, ignored on Spectrum.
       (new default is 0)
rdq - CPU receive descriptor queue (new default is identical to trap
      group id)

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 53 +++++++++++++-------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 47 ++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlxsw/switchib.c |  8 +++-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 24 ++++++++++--
 4 files changed, 92 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 68a0e63..2116f8f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3057,6 +3057,8 @@ enum {
  */
 MLXSW_ITEM32(reg, htgt, pide, 0x04, 15, 1);
 
+#define MLXSW_REG_HTGT_INVALID_POLICER 0xff
+
 /* reg_htgt_pid
  * Policer ID for the trap group.
  * Access: RW
@@ -3082,6 +3084,8 @@ MLXSW_ITEM32(reg, htgt, mirror_action, 0x08, 8, 2);
  */
 MLXSW_ITEM32(reg, htgt, mirroring_agent, 0x08, 0, 3);
 
+#define MLXSW_REG_HTGT_DEFAULT_PRIORITY 0
+
 /* reg_htgt_priority
  * Trap group priority.
  * In case a packet matches multiple classification rules, the packet will
@@ -3095,52 +3099,47 @@ MLXSW_ITEM32(reg, htgt, mirroring_agent, 0x08, 0, 3);
  */
 MLXSW_ITEM32(reg, htgt, priority, 0x0C, 0, 4);
 
+#define MLXSW_REG_HTGT_DEFAULT_TC 7
+
 /* reg_htgt_local_path_cpu_tclass
  * CPU ingress traffic class for the trap group.
  * Access: RW
  */
 MLXSW_ITEM32(reg, htgt, local_path_cpu_tclass, 0x10, 16, 6);
 
-#define MLXSW_REG_HTGT_LOCAL_PATH_RDQ_EMAD	0x15
-#define MLXSW_REG_HTGT_LOCAL_PATH_RDQ_RX	0x14
-#define MLXSW_REG_HTGT_LOCAL_PATH_RDQ_CTRL	0x13
-
+enum mlxsw_reg_htgt_local_path_rdq {
+	MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SX2_CTRL = 0x13,
+	MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SX2_RX = 0x14,
+	MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SX2_EMAD = 0x15,
+	MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SIB_EMAD = 0x15,
+};
 /* reg_htgt_local_path_rdq
  * Receive descriptor queue (RDQ) to use for the trap group.
  * Access: RW
  */
 MLXSW_ITEM32(reg, htgt, local_path_rdq, 0x10, 0, 6);
 
-static inline void mlxsw_reg_htgt_pack(char *payload,
-				       enum mlxsw_reg_htgt_trap_group group)
+static inline void mlxsw_reg_htgt_pack(char *payload, u8 group, u8 policer_id,
+				       u8 priority, u8 tc)
 {
-	u8 swid, rdq;
-
 	MLXSW_REG_ZERO(htgt, payload);
-	switch (group) {
-	case MLXSW_REG_HTGT_TRAP_GROUP_EMAD:
-		swid = MLXSW_PORT_SWID_ALL_SWIDS;
-		rdq = MLXSW_REG_HTGT_LOCAL_PATH_RDQ_EMAD;
-		break;
-	case MLXSW_REG_HTGT_TRAP_GROUP_RX:
-		swid = 0;
-		rdq = MLXSW_REG_HTGT_LOCAL_PATH_RDQ_RX;
-		break;
-	case MLXSW_REG_HTGT_TRAP_GROUP_CTRL:
-		swid = 0;
-		rdq = MLXSW_REG_HTGT_LOCAL_PATH_RDQ_CTRL;
-		break;
+
+	if (policer_id == MLXSW_REG_HTGT_INVALID_POLICER) {
+		mlxsw_reg_htgt_pide_set(payload,
+					MLXSW_REG_HTGT_POLICER_DISABLE);
+	} else {
+		mlxsw_reg_htgt_pide_set(payload,
+					MLXSW_REG_HTGT_POLICER_ENABLE);
+		mlxsw_reg_htgt_pid_set(payload, policer_id);
 	}
-	mlxsw_reg_htgt_swid_set(payload, swid);
+
 	mlxsw_reg_htgt_type_set(payload, MLXSW_REG_HTGT_PATH_TYPE_LOCAL);
 	mlxsw_reg_htgt_trap_group_set(payload, group);
-	mlxsw_reg_htgt_pide_set(payload, MLXSW_REG_HTGT_POLICER_DISABLE);
-	mlxsw_reg_htgt_pid_set(payload, 0);
 	mlxsw_reg_htgt_mirror_action_set(payload, MLXSW_REG_HTGT_TRAP_TO_CPU);
 	mlxsw_reg_htgt_mirroring_agent_set(payload, 0);
-	mlxsw_reg_htgt_priority_set(payload, 0);
-	mlxsw_reg_htgt_local_path_cpu_tclass_set(payload, 7);
-	mlxsw_reg_htgt_local_path_rdq_set(payload, rdq);
+	mlxsw_reg_htgt_priority_set(payload, priority);
+	mlxsw_reg_htgt_local_path_cpu_tclass_set(payload, tc);
+	mlxsw_reg_htgt_local_path_rdq_set(payload, group);
 }
 
 /* HPKT - Host Packet Trap
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 79c0a01..75ba22a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2763,19 +2763,45 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, false),
 };
 
-static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
+static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
+	int max_trap_groups;
+	u8 priority, tc;
+	int i, err;
+
+	if (!MLXSW_CORE_RES_VALID(mlxsw_core, MAX_TRAP_GROUPS))
+		return -EIO;
+
+	max_trap_groups = MLXSW_CORE_RES_GET(mlxsw_core, MAX_TRAP_GROUPS);
+
+	for (i = 0; i < max_trap_groups; i++) {
+		switch (i) {
+		case MLXSW_REG_HTGT_TRAP_GROUP_EMAD:
+		case MLXSW_REG_HTGT_TRAP_GROUP_RX:
+		case MLXSW_REG_HTGT_TRAP_GROUP_CTRL:
+			priority = MLXSW_REG_HTGT_DEFAULT_PRIORITY;
+			tc = MLXSW_REG_HTGT_DEFAULT_TC;
+			break;
+		default:
+			continue;
+		}
+		mlxsw_reg_htgt_pack(htgt_pl, i, MLXSW_REG_HTGT_INVALID_POLICER,
+				    priority, tc);
+		err = mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
+{
 	int i;
 	int err;
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_RX);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(htgt), htgt_pl);
-	if (err)
-		return err;
-
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_CTRL);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(htgt), htgt_pl);
+	err = mlxsw_sp_trap_groups_set(mlxsw_sp->core);
 	if (err)
 		return err;
 
@@ -2894,7 +2920,10 @@ static int mlxsw_sp_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD);
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
+			    MLXSW_REG_HTGT_INVALID_POLICER,
+			    MLXSW_REG_HTGT_DEFAULT_PRIORITY,
+			    MLXSW_REG_HTGT_DEFAULT_TC);
 	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
index 9a5f829..74341fe 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
@@ -451,7 +451,13 @@ static int mlxsw_sib_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD);
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
+			    MLXSW_REG_HTGT_INVALID_POLICER,
+			    MLXSW_REG_HTGT_DEFAULT_PRIORITY,
+			    MLXSW_REG_HTGT_DEFAULT_TC);
+	mlxsw_reg_htgt_swid_set(htgt_pl, MLXSW_PORT_SWID_ALL_SWIDS);
+	mlxsw_reg_htgt_local_path_rdq_set(htgt_pl,
+					MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SIB_EMAD);
 	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 8caa962..4cdc02c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1476,12 +1476,24 @@ static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 	int i;
 	int err;
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_RX);
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_RX,
+			    MLXSW_REG_HTGT_INVALID_POLICER,
+			    MLXSW_REG_HTGT_DEFAULT_PRIORITY,
+			    MLXSW_REG_HTGT_DEFAULT_TC);
+	mlxsw_reg_htgt_local_path_rdq_set(htgt_pl,
+					  MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SX2_RX);
+
 	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(htgt), htgt_pl);
 	if (err)
 		return err;
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_CTRL);
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_CTRL,
+			    MLXSW_REG_HTGT_INVALID_POLICER,
+			    MLXSW_REG_HTGT_DEFAULT_PRIORITY,
+			    MLXSW_REG_HTGT_DEFAULT_TC);
+	mlxsw_reg_htgt_local_path_rdq_set(htgt_pl,
+					MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SX2_CTRL);
+
 	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(htgt), htgt_pl);
 	if (err)
 		return err;
@@ -1588,7 +1600,13 @@ static int mlxsw_sx_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD);
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
+			    MLXSW_REG_HTGT_INVALID_POLICER,
+			    MLXSW_REG_HTGT_DEFAULT_PRIORITY,
+			    MLXSW_REG_HTGT_DEFAULT_TC);
+	mlxsw_reg_htgt_swid_set(htgt_pl, MLXSW_PORT_SWID_ALL_SWIDS);
+	mlxsw_reg_htgt_local_path_rdq_set(htgt_pl,
+					MLXSW_REG_HTGT_LOCAL_PATH_RDQ_SX2_EMAD);
 	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
 }
 
-- 
2.7.4
