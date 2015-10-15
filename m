From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/15] mlxsw: Simplify traps creation
Date: Thu, 15 Oct 2015 17:43:27 +0200
Message-ID: <1444923809-20785-14-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:34220 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbbJOPnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:47 -0400
Received: by qkfm62 with SMTP id m62so38790691qkf.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:46 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The Host Trap Group Table (HTGT) register configures trap groups, which
are populated with trap IDs using the Host PacKet Trap (HPKT) register.
However, a trap ID can only be present inside one trap group (the last
configured).

Instead of passing both the trap group and ID for the function that
packs HPKT, pass only the trap ID and derive from it the trap group.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     |  2 --
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 14 ++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  6 +-----
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index cf7c9d2..bd80ac7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -511,7 +511,6 @@ static int mlxsw_emad_traps_set(struct mlxsw_core *mlxsw_core)
 		return err;
 
 	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
-			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
 			    MLXSW_TRAP_ID_ETHEMAD);
 	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
 }
@@ -558,7 +557,6 @@ static void mlxsw_emad_fini(struct mlxsw_core *mlxsw_core)
 
 	mlxsw_core->emad.use_emad = false;
 	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
-			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
 			    MLXSW_TRAP_ID_ETHEMAD);
 	mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 7595cf1..fc6f520 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1209,12 +1209,22 @@ enum {
  */
 MLXSW_ITEM32(reg, hpkt, ctrl, 0x04, 16, 2);
 
-static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action,
-				       u8 trap_group, u16 trap_id)
+static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 {
+	u8 trap_group;
+
 	MLXSW_REG_ZERO(hpkt, payload);
 	mlxsw_reg_hpkt_ack_set(payload, MLXSW_REG_HPKT_ACK_NOT_REQUIRED);
 	mlxsw_reg_hpkt_action_set(payload, action);
+	switch (trap_id) {
+	case MLXSW_TRAP_ID_ETHEMAD:
+	case MLXSW_TRAP_ID_PUDE:
+		trap_group = MLXSW_REG_HTGT_TRAP_GROUP_EMAD;
+		break;
+	default:
+		trap_group = MLXSW_REG_HTGT_TRAP_GROUP_RX;
+		break;
+	}
 	mlxsw_reg_hpkt_trap_group_set(payload, trap_group);
 	mlxsw_reg_hpkt_trap_id_set(payload, trap_id);
 	mlxsw_reg_hpkt_ctrl_set(payload, MLXSW_REG_HPKT_CTRL_PACKET_DEFAULT);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 0c0205c..ef3c4af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1177,8 +1177,7 @@ static int mlxsw_sx_event_register(struct mlxsw_sx *mlxsw_sx,
 	if (err)
 		return err;
 
-	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
-			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD, trap_id);
+	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD, trap_id);
 	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
 	if (err)
 		goto err_event_trap_set;
@@ -1322,7 +1321,6 @@ static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 			goto err_rx_listener_register;
 
 		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
-				    MLXSW_REG_HTGT_TRAP_GROUP_RX,
 				    mlxsw_sx_rx_listener[i].trap_id);
 		err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
 		if (err)
@@ -1337,7 +1335,6 @@ err_rx_trap_set:
 err_rx_listener_register:
 	for (i--; i >= 0; i--) {
 		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
-				    MLXSW_REG_HTGT_TRAP_GROUP_RX,
 				    mlxsw_sx_rx_listener[i].trap_id);
 		mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
 
@@ -1355,7 +1352,6 @@ static void mlxsw_sx_traps_fini(struct mlxsw_sx *mlxsw_sx)
 
 	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
 		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
-				    MLXSW_REG_HTGT_TRAP_GROUP_RX,
 				    mlxsw_sx_rx_listener[i].trap_id);
 		mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
 
-- 
1.9.3
