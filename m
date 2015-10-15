From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/15] mlxsw: Add trap group for control packets
Date: Thu, 15 Oct 2015 17:43:28 +0200
Message-ID: <1444923809-20785-15-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34242 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840AbbJOPns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:48 -0400
Received: by qkfm62 with SMTP id m62so38791275qkf.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:47 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Previously, we trapped flooded and control packets using the same trap
group. This can cause flooded packets to overflow the PCI bus and
prevent control packets (e.g. STP, LACP) from getting to the CPU.

Solve this by splitting the RX trap group to RX and control, which allows
us to configure a policer on the first, thereby preventing it from
overflowing the PCI bus.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 26 +++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  5 +++++
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index fc6f520..7b245af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1029,8 +1029,11 @@ MLXSW_ITEM32(reg, htgt, swid, 0x00, 24, 8);
  */
 MLXSW_ITEM32(reg, htgt, type, 0x00, 8, 4);
 
-#define MLXSW_REG_HTGT_TRAP_GROUP_EMAD	0x0
-#define MLXSW_REG_HTGT_TRAP_GROUP_RX	0x1
+enum mlxsw_reg_htgt_trap_group {
+	MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
+	MLXSW_REG_HTGT_TRAP_GROUP_RX,
+	MLXSW_REG_HTGT_TRAP_GROUP_CTRL,
+};
 
 /* reg_htgt_trap_group
  * Trap group number. User defined number specifying which trap groups
@@ -1097,6 +1100,7 @@ MLXSW_ITEM32(reg, htgt, local_path_cpu_tclass, 0x10, 16, 6);
 
 #define MLXSW_REG_HTGT_LOCAL_PATH_RDQ_EMAD	0x15
 #define MLXSW_REG_HTGT_LOCAL_PATH_RDQ_RX	0x14
+#define MLXSW_REG_HTGT_LOCAL_PATH_RDQ_CTRL	0x13
 
 /* reg_htgt_local_path_rdq
  * Receive descriptor queue (RDQ) to use for the trap group.
@@ -1104,21 +1108,29 @@ MLXSW_ITEM32(reg, htgt, local_path_cpu_tclass, 0x10, 16, 6);
  */
 MLXSW_ITEM32(reg, htgt, local_path_rdq, 0x10, 0, 6);
 
-static inline void mlxsw_reg_htgt_pack(char *payload, u8 trap_group)
+static inline void mlxsw_reg_htgt_pack(char *payload,
+				       enum mlxsw_reg_htgt_trap_group group)
 {
 	u8 swid, rdq;
 
 	MLXSW_REG_ZERO(htgt, payload);
-	if (MLXSW_REG_HTGT_TRAP_GROUP_EMAD == trap_group) {
+	switch (group) {
+	case MLXSW_REG_HTGT_TRAP_GROUP_EMAD:
 		swid = MLXSW_PORT_SWID_ALL_SWIDS;
 		rdq = MLXSW_REG_HTGT_LOCAL_PATH_RDQ_EMAD;
-	} else {
+		break;
+	case MLXSW_REG_HTGT_TRAP_GROUP_RX:
 		swid = 0;
 		rdq = MLXSW_REG_HTGT_LOCAL_PATH_RDQ_RX;
+		break;
+	case MLXSW_REG_HTGT_TRAP_GROUP_CTRL:
+		swid = 0;
+		rdq = MLXSW_REG_HTGT_LOCAL_PATH_RDQ_CTRL;
+		break;
 	}
 	mlxsw_reg_htgt_swid_set(payload, swid);
 	mlxsw_reg_htgt_type_set(payload, MLXSW_REG_HTGT_PATH_TYPE_LOCAL);
-	mlxsw_reg_htgt_trap_group_set(payload, trap_group);
+	mlxsw_reg_htgt_trap_group_set(payload, group);
 	mlxsw_reg_htgt_pide_set(payload, MLXSW_REG_HTGT_POLICER_DISABLE);
 	mlxsw_reg_htgt_pid_set(payload, 0);
 	mlxsw_reg_htgt_mirror_action_set(payload, MLXSW_REG_HTGT_TRAP_TO_CPU);
@@ -1211,7 +1223,7 @@ MLXSW_ITEM32(reg, hpkt, ctrl, 0x04, 16, 2);
 
 static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 {
-	u8 trap_group;
+	enum mlxsw_reg_htgt_trap_group trap_group;
 
 	MLXSW_REG_ZERO(hpkt, payload);
 	mlxsw_reg_hpkt_ack_set(payload, MLXSW_REG_HPKT_ACK_NOT_REQUIRED);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index ef3c4af..176c159 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1313,6 +1313,11 @@ static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 	if (err)
 		return err;
 
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_CTRL);
+	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(htgt), htgt_pl);
+	if (err)
+		return err;
+
 	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
 		err = mlxsw_core_rx_listener_register(mlxsw_sx->core,
 						      &mlxsw_sx_rx_listener[i],
-- 
1.9.3
