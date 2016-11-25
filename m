From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/19] mlxsw: Change trap set function
Date: Fri, 25 Nov 2016 10:33:38 +0100
Message-ID: <1480066427-3961-11-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33429 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wj0-f193.google.com with SMTP id kp2so4928357wjc.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:01 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change trap setting function so instead of determining the trap group by
trap id, it gets it as a parameter (so later we can have different trap
groups for Spectrum and Switchx2).
Add "is_ctrl" parameter to the trap setting function. It control whether
the trapped packets wait in a designated control buffer or in their
default one. This parameter is ignored by Switchx2 and Switchib.
Add these parameters to the traps array in Spectrum, Switchx2 and
Switchib.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 14 +++++---
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  8 ++++-
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 20 ++++-------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 46 +++++++++++++-------------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  5 +--
 5 files changed, 49 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index a8cff78..d3b82d6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -590,7 +590,8 @@ static int mlxsw_emad_traps_set(struct mlxsw_core *mlxsw_core)
 		return err;
 
 	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
-			    MLXSW_TRAP_ID_ETHEMAD);
+			    MLXSW_TRAP_ID_ETHEMAD,
+			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD, false);
 	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
 }
 
@@ -643,7 +644,8 @@ static void mlxsw_emad_fini(struct mlxsw_core *mlxsw_core)
 
 	mlxsw_core->emad.use_emad = false;
 	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
-			    MLXSW_TRAP_ID_ETHEMAD);
+			    MLXSW_TRAP_ID_ETHEMAD,
+			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD, false);
 	mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
 
 	mlxsw_core_rx_listener_unregister(mlxsw_core,
@@ -1430,8 +1432,9 @@ int mlxsw_core_trap_register(struct mlxsw_core *mlxsw_core,
 	if (err)
 		return err;
 
-	mlxsw_reg_hpkt_pack(hpkt_pl, listener->action, listener->trap_id);
-	err = mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
+	mlxsw_reg_hpkt_pack(hpkt_pl, listener->action, listener->trap_id,
+			    listener->trap_group, listener->is_ctrl);
+	err = mlxsw_reg_write(mlxsw_core,  MLXSW_REG(hpkt), hpkt_pl);
 	if (err)
 		goto err_trap_set;
 
@@ -1451,7 +1454,8 @@ void mlxsw_core_trap_unregister(struct mlxsw_core *mlxsw_core,
 
 	if (!listener->is_event) {
 		mlxsw_reg_hpkt_pack(hpkt_pl, listener->unreg_action,
-				    listener->trap_id);
+				    listener->trap_id, listener->trap_group,
+				    listener->is_ctrl);
 		mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 852218e..b5b5b36 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -98,10 +98,12 @@ struct mlxsw_listener {
 	} u;
 	enum mlxsw_reg_hpkt_action action;
 	enum mlxsw_reg_hpkt_action unreg_action;
+	u8 trap_group;
+	bool is_ctrl; /* should go via control buffer or not */
 	bool is_event;
 };
 
-#define MLXSW_RXL(_func, _trap_id, _action, _unreg_action)		\
+#define MLXSW_RXL(_func, _trap_id, _action, _is_ctrl, _unreg_action)	\
 	{								\
 		.trap_id = MLXSW_TRAP_ID_##_trap_id,			\
 		.u.rx_listener =					\
@@ -112,6 +114,8 @@ struct mlxsw_listener {
 		},							\
 		.action = MLXSW_REG_HPKT_ACTION_##_action,		\
 		.unreg_action = MLXSW_REG_HPKT_ACTION_##_unreg_action,	\
+		.trap_group = MLXSW_REG_HTGT_TRAP_GROUP_RX,		\
+		.is_ctrl = _is_ctrl,					\
 		.is_event = false,					\
 	}
 
@@ -124,6 +128,8 @@ struct mlxsw_listener {
 			.trap_id = MLXSW_TRAP_ID_##_trap_id,	\
 		},						\
 		.action = MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,	\
+		.trap_group = MLXSW_REG_HTGT_TRAP_GROUP_EMAD,	\
+		.is_ctrl = false,				\
 		.is_event = true,				\
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 2618e9c..68a0e63 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3214,6 +3214,7 @@ enum {
 
 /* reg_hpkt_ctrl
  * Configure dedicated buffer resources for control packets.
+ * Ignored by SwitchX-2.
  * 0 - Keep factory defaults.
  * 1 - Do not use control buffer for this trap ID.
  * 2 - Use control buffer for this trap ID.
@@ -3221,25 +3222,18 @@ enum {
  */
 MLXSW_ITEM32(reg, hpkt, ctrl, 0x04, 16, 2);
 
-static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
+static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id,
+				       enum mlxsw_reg_htgt_trap_group trap_group,
+				       bool is_ctrl)
 {
-	enum mlxsw_reg_htgt_trap_group trap_group;
-
 	MLXSW_REG_ZERO(hpkt, payload);
 	mlxsw_reg_hpkt_ack_set(payload, MLXSW_REG_HPKT_ACK_NOT_REQUIRED);
 	mlxsw_reg_hpkt_action_set(payload, action);
-	switch (trap_id) {
-	case MLXSW_TRAP_ID_ETHEMAD:
-	case MLXSW_TRAP_ID_PUDE:
-		trap_group = MLXSW_REG_HTGT_TRAP_GROUP_EMAD;
-		break;
-	default:
-		trap_group = MLXSW_REG_HTGT_TRAP_GROUP_RX;
-		break;
-	}
 	mlxsw_reg_hpkt_trap_group_set(payload, trap_group);
 	mlxsw_reg_hpkt_trap_id_set(payload, trap_id);
-	mlxsw_reg_hpkt_ctrl_set(payload, MLXSW_REG_HPKT_CTRL_PACKET_DEFAULT);
+	mlxsw_reg_hpkt_ctrl_set(payload, is_ctrl ?
+				MLXSW_REG_HPKT_CTRL_PACKET_USE_BUFFER :
+				MLXSW_REG_HPKT_CTRL_PACKET_NO_BUFFER);
 }
 
 /* RGCR - Router General Configuration Register
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d758ce6..3582e3f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2730,37 +2730,37 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 	return mlxsw_sp_rx_listener_no_mark_func(skb, local_port, priv);
 }
 
-#define MLXSW_SP_RXL_NO_MARK(_trap_id, _action)				\
-	MLXSW_RXL(mlxsw_sp_rx_listener_no_mark_func, _trap_id, _action,	\
-		  DISCARD)
+#define MLXSW_SP_RXL_NO_MARK(_trap_id, _action, _is_ctrl)		\
+	MLXSW_RXL(mlxsw_sp_rx_listener_no_mark_func, _trap_id, _action, \
+		  _is_ctrl, DISCARD)
 
-#define MLXSW_SP_RXL_MARK(_trap_id, _action)				\
+#define MLXSW_SP_RXL_MARK(_trap_id, _action, _is_ctrl)			\
 	MLXSW_RXL(mlxsw_sp_rx_listener_mark_func, _trap_id, _action,	\
-		  DISCARD)
+		  _is_ctrl, DISCARD)
 
 static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	/* Events */
 	MLXSW_EVENTL(mlxsw_sp_pude_event_func, PUDE),
 	/* L2 traps */
-	MLXSW_SP_RXL_NO_MARK(STP, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(LACP, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(LLDP, TRAP_TO_CPU),
-	MLXSW_SP_RXL_MARK(DHCP, MIRROR_TO_CPU),
-	MLXSW_SP_RXL_MARK(IGMP_QUERY, MIRROR_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V1_REPORT, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V2_REPORT, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V2_LEAVE, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V3_REPORT, TRAP_TO_CPU),
-	MLXSW_SP_RXL_MARK(ARPBC, MIRROR_TO_CPU),
-	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(STP, TRAP_TO_CPU, true),
+	MLXSW_SP_RXL_NO_MARK(LACP, TRAP_TO_CPU, true),
+	MLXSW_SP_RXL_NO_MARK(LLDP, TRAP_TO_CPU, true),
+	MLXSW_SP_RXL_MARK(DHCP, MIRROR_TO_CPU, false),
+	MLXSW_SP_RXL_MARK(IGMP_QUERY, MIRROR_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V1_REPORT, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V2_REPORT, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V2_LEAVE, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V3_REPORT, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_MARK(ARPBC, MIRROR_TO_CPU, false),
+	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU, false),
 	/* L3 traps */
-	MLXSW_SP_RXL_NO_MARK(MTUERROR, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(TTLERROR, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(LBERROR, TRAP_TO_CPU),
-	MLXSW_SP_RXL_MARK(OSPF, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(IP2ME, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU),
-	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(MTUERROR, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(TTLERROR, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(LBERROR, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_MARK(OSPF, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(IP2ME, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, false),
 };
 
 static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 675ce12..a158756 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1448,8 +1448,9 @@ static int mlxsw_sx_port_type_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 	return err;
 }
 
-#define MLXSW_SX_RXL(_trap_id) \
-	MLXSW_RXL(mlxsw_sx_rx_listener_func, _trap_id, TRAP_TO_CPU, FORWARD)
+#define MLXSW_SX_RXL(_trap_id)						\
+	MLXSW_RXL(mlxsw_sx_rx_listener_func, _trap_id, TRAP_TO_CPU,	\
+		  false, FORWARD)
 
 static const struct mlxsw_listener mlxsw_sx_listener[] = {
 	MLXSW_EVENTL(mlxsw_sx_pude_event_func, PUDE),
-- 
2.7.4
