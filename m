From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/19] mlxsw: Add option to choose trap group
Date: Fri, 25 Nov 2016 10:33:39 +0100
Message-ID: <1480066427-3961-12-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33700 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so7192393wmu.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:02 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Currently, we set the trap group to pre-determined option, based on whether
it is an rx or event trap.
This commit adds a possibility to chose the trap group, so it can be set
to different values in the following patches.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 29 +++++++++++++-------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  8 +++----
 drivers/net/ethernet/mellanox/mlxsw/switchib.c |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  4 ++--
 4 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index b5b5b36..d663b8e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -103,7 +103,8 @@ struct mlxsw_listener {
 	bool is_event;
 };
 
-#define MLXSW_RXL(_func, _trap_id, _action, _is_ctrl, _unreg_action)	\
+#define MLXSW_RXL(_func, _trap_id, _action, _is_ctrl, _trap_group,	\
+		  _unreg_action)					\
 	{								\
 		.trap_id = MLXSW_TRAP_ID_##_trap_id,			\
 		.u.rx_listener =					\
@@ -114,23 +115,23 @@ struct mlxsw_listener {
 		},							\
 		.action = MLXSW_REG_HPKT_ACTION_##_action,		\
 		.unreg_action = MLXSW_REG_HPKT_ACTION_##_unreg_action,	\
-		.trap_group = MLXSW_REG_HTGT_TRAP_GROUP_RX,		\
+		.trap_group = MLXSW_REG_HTGT_TRAP_GROUP_##_trap_group,	\
 		.is_ctrl = _is_ctrl,					\
 		.is_event = false,					\
 	}
 
-#define MLXSW_EVENTL(_func, _trap_id)				\
-	{							\
-		.trap_id = MLXSW_TRAP_ID_##_trap_id,		\
-		.u.event_listener =				\
-		{						\
-			.func = _func,				\
-			.trap_id = MLXSW_TRAP_ID_##_trap_id,	\
-		},						\
-		.action = MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,	\
-		.trap_group = MLXSW_REG_HTGT_TRAP_GROUP_EMAD,	\
-		.is_ctrl = false,				\
-		.is_event = true,				\
+#define MLXSW_EVENTL(_func, _trap_id, _trap_group)			\
+	{								\
+		.trap_id = MLXSW_TRAP_ID_##_trap_id,			\
+		.u.event_listener =					\
+		{							\
+			.func = _func,					\
+			.trap_id = MLXSW_TRAP_ID_##_trap_id,		\
+		},							\
+		.action = MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,		\
+		.trap_group = MLXSW_REG_HTGT_TRAP_GROUP_##_trap_group,	\
+		.is_ctrl = false,					\
+		.is_event = true,					\
 	}
 
 int mlxsw_core_rx_listener_register(struct mlxsw_core *mlxsw_core,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3582e3f..44243a4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2731,16 +2731,16 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 }
 
 #define MLXSW_SP_RXL_NO_MARK(_trap_id, _action, _is_ctrl)		\
-	MLXSW_RXL(mlxsw_sp_rx_listener_no_mark_func, _trap_id, _action, \
-		  _is_ctrl, DISCARD)
+	MLXSW_RXL(mlxsw_sp_rx_listener_no_mark_func, _trap_id, _action,	\
+		  _is_ctrl, RX, DISCARD)
 
 #define MLXSW_SP_RXL_MARK(_trap_id, _action, _is_ctrl)			\
 	MLXSW_RXL(mlxsw_sp_rx_listener_mark_func, _trap_id, _action,	\
-		  _is_ctrl, DISCARD)
+		  _is_ctrl, RX, DISCARD)
 
 static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	/* Events */
-	MLXSW_EVENTL(mlxsw_sp_pude_event_func, PUDE),
+	MLXSW_EVENTL(mlxsw_sp_pude_event_func, PUDE, EMAD),
 	/* L2 traps */
 	MLXSW_SP_RXL_NO_MARK(STP, TRAP_TO_CPU, true),
 	MLXSW_SP_RXL_NO_MARK(LACP, TRAP_TO_CPU, true),
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
index 847cbbf..b798711 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
@@ -409,7 +409,7 @@ static void mlxsw_sib_pude_event_func(const struct mlxsw_reg_info *reg,
 }
 
 static const struct mlxsw_listener mlxsw_sib_listener[] = {
-	MLXSW_EVENTL(mlxsw_sib_pude_event_func, PUDE),
+	MLXSW_EVENTL(mlxsw_sib_pude_event_func, PUDE, EMAD),
 };
 
 static int mlxsw_sib_taps_init(struct mlxsw_sib *mlxsw_sib)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index a158756..1bcb391 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1450,10 +1450,10 @@ static int mlxsw_sx_port_type_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 
 #define MLXSW_SX_RXL(_trap_id)						\
 	MLXSW_RXL(mlxsw_sx_rx_listener_func, _trap_id, TRAP_TO_CPU,	\
-		  false, FORWARD)
+		  false, RX, FORWARD)
 
 static const struct mlxsw_listener mlxsw_sx_listener[] = {
-	MLXSW_EVENTL(mlxsw_sx_pude_event_func, PUDE),
+	MLXSW_EVENTL(mlxsw_sx_pude_event_func, PUDE, EMAD),
 	MLXSW_SX_RXL(FDB_MC),
 	MLXSW_SX_RXL(STP),
 	MLXSW_SX_RXL(LACP),
-- 
2.7.4
