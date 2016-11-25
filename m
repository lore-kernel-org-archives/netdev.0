From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/19] mlxsw: Create a different trap group list for each device
Date: Fri, 25 Nov 2016 10:33:44 +0100
Message-ID: <1480066427-3961-17-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33732 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752913AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id u144so7192604wmu.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:08 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Trap groups can be used to control traps priority, both in terms of
which trap "wins" if a packet matches two traps (priority) and in terms
of packets from which trap group will be scheduled to the cpu first (tc).
They can also be used to set rate limiters (policers) on them (will be
added in the next patches).

Currently, we support two trap groups. In Spectrum we want a better
resolution, so every protocol / flow will have a different trap group,
so we can control its parameters separately. Once the policers will be
implemented, it will also allow us limit the rate of each protocol by
itself.

This patch change the trap group list to include:
* the emad trap group, which is shared for all the devices.
* Switchx2's trap groups, which are a copy of the current trap groups.
* Spectrum's new trap groups, in order to match the above guidelines.
(Switchib is using only the emad trap group, so it require no changes).

This patch also includes new configuration for Spectrum's trap groups,
with primary priority order within them.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 17 ++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 86 +++++++++++++++++---------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  8 +--
 3 files changed, 77 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 2116f8f..2d92e41 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3034,8 +3034,21 @@ MLXSW_ITEM32(reg, htgt, type, 0x00, 8, 4);
 
 enum mlxsw_reg_htgt_trap_group {
 	MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
-	MLXSW_REG_HTGT_TRAP_GROUP_RX,
-	MLXSW_REG_HTGT_TRAP_GROUP_CTRL,
+	MLXSW_REG_HTGT_TRAP_GROUP_SX2_RX,
+	MLXSW_REG_HTGT_TRAP_GROUP_SX2_CTRL,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_STP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_LACP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_LLDP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_IGMP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP_IPV4,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_OSPF,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP_MISS,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_IP2ME,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_EVENT,
 };
 
 /* reg_htgt_trap_group
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 42ac968..2207001 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2730,46 +2730,50 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 	return mlxsw_sp_rx_listener_no_mark_func(skb, local_port, priv);
 }
 
-#define MLXSW_SP_RXL_NO_MARK(_trap_id, _action, _is_ctrl)		\
+#define MLXSW_SP_RXL_NO_MARK(_trap_id, _action, _trap_group, _is_ctrl)	\
 	MLXSW_RXL(mlxsw_sp_rx_listener_no_mark_func, _trap_id, _action,	\
-		  _is_ctrl, RX, DISCARD)
+		  _is_ctrl, SP_##_trap_group, DISCARD)
 
-#define MLXSW_SP_RXL_MARK(_trap_id, _action, _is_ctrl)			\
+#define MLXSW_SP_RXL_MARK(_trap_id, _action, _trap_group, _is_ctrl)	\
 	MLXSW_RXL(mlxsw_sp_rx_listener_mark_func, _trap_id, _action,	\
-		  _is_ctrl, RX, DISCARD)
+		_is_ctrl, SP_##_trap_group, DISCARD)
+
+#define MLXSW_SP_EVENTL(_func, _trap_id)		\
+	MLXSW_EVENTL(_func, _trap_id, SP_EVENT)
 
 static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	/* Events */
-	MLXSW_EVENTL(mlxsw_sp_pude_event_func, PUDE, EMAD),
+	MLXSW_SP_EVENTL(mlxsw_sp_pude_event_func, PUDE),
 	/* L2 traps */
-	MLXSW_SP_RXL_NO_MARK(STP, TRAP_TO_CPU, true),
-	MLXSW_SP_RXL_NO_MARK(LACP, TRAP_TO_CPU, true),
-	MLXSW_SP_RXL_NO_MARK(LLDP, TRAP_TO_CPU, true),
-	MLXSW_SP_RXL_MARK(DHCP, MIRROR_TO_CPU, false),
-	MLXSW_SP_RXL_MARK(IGMP_QUERY, MIRROR_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V1_REPORT, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V2_REPORT, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V2_LEAVE, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(IGMP_V3_REPORT, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_MARK(ARPBC, MIRROR_TO_CPU, false),
-	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(STP, TRAP_TO_CPU, STP, true),
+	MLXSW_SP_RXL_NO_MARK(LACP, TRAP_TO_CPU, LACP, true),
+	MLXSW_SP_RXL_NO_MARK(LLDP, TRAP_TO_CPU, LLDP, true),
+	MLXSW_SP_RXL_MARK(DHCP, MIRROR_TO_CPU, DHCP, false),
+	MLXSW_SP_RXL_MARK(IGMP_QUERY, MIRROR_TO_CPU, IGMP, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V1_REPORT, TRAP_TO_CPU, IGMP, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V2_REPORT, TRAP_TO_CPU, IGMP, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V2_LEAVE, TRAP_TO_CPU, IGMP, false),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V3_REPORT, TRAP_TO_CPU, IGMP, false),
+	MLXSW_SP_RXL_MARK(ARPBC, MIRROR_TO_CPU, ARP, false),
+	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU, ARP, false),
 	/* L3 traps */
-	MLXSW_SP_RXL_NO_MARK(MTUERROR, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(TTLERROR, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(LBERROR, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_MARK(OSPF, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(IP2ME, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, false),
-	MLXSW_SP_RXL_MARK(BGP_IPV4, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_NO_MARK(MTUERROR, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_NO_MARK(TTLERROR, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_NO_MARK(LBERROR, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(OSPF, TRAP_TO_CPU, OSPF, false),
+	MLXSW_SP_RXL_NO_MARK(IP2ME, TRAP_TO_CPU, IP2ME, false),
+	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU, REMOTE_ROUTE, false),
+	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, ARP_MISS, false),
+	MLXSW_SP_RXL_NO_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
 };
 
 static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
+	enum mlxsw_reg_htgt_trap_group i;
 	int max_trap_groups;
 	u8 priority, tc;
-	int i, err;
+	int err;
 
 	if (!MLXSW_CORE_RES_VALID(mlxsw_core, MAX_TRAP_GROUPS))
 		return -EIO;
@@ -2778,15 +2782,41 @@ static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 
 	for (i = 0; i < max_trap_groups; i++) {
 		switch (i) {
-		case MLXSW_REG_HTGT_TRAP_GROUP_EMAD:
-		case MLXSW_REG_HTGT_TRAP_GROUP_RX:
-		case MLXSW_REG_HTGT_TRAP_GROUP_CTRL:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_STP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LACP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LLDP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_OSPF:
+			priority = 5;
+			tc = 5;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP_IPV4:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP:
+			priority = 4;
+			tc = 4;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IGMP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IP2ME:
+			priority = 3;
+			tc = 3;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP:
+			priority = 2;
+			tc = 2;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP_MISS:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE:
+			priority = 1;
+			tc = 1;
+			break;
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_EVENT:
 			priority = MLXSW_REG_HTGT_DEFAULT_PRIORITY;
 			tc = MLXSW_REG_HTGT_DEFAULT_TC;
 			break;
 		default:
 			continue;
 		}
+
 		mlxsw_reg_htgt_pack(htgt_pl, i, MLXSW_REG_HTGT_INVALID_POLICER,
 				    priority, tc);
 		err = mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 4cdc02c..150ccf5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1448,9 +1448,9 @@ static int mlxsw_sx_port_type_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 	return err;
 }
 
-#define MLXSW_SX_RXL(_trap_id)						\
+#define MLXSW_SX_RXL(_trap_id) \
 	MLXSW_RXL(mlxsw_sx_rx_listener_func, _trap_id, TRAP_TO_CPU,	\
-		  false, RX, FORWARD)
+		  false, SX2_RX, FORWARD)
 
 static const struct mlxsw_listener mlxsw_sx_listener[] = {
 	MLXSW_EVENTL(mlxsw_sx_pude_event_func, PUDE, EMAD),
@@ -1476,7 +1476,7 @@ static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 	int i;
 	int err;
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_RX,
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_SX2_RX,
 			    MLXSW_REG_HTGT_INVALID_POLICER,
 			    MLXSW_REG_HTGT_DEFAULT_PRIORITY,
 			    MLXSW_REG_HTGT_DEFAULT_TC);
@@ -1487,7 +1487,7 @@ static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 	if (err)
 		return err;
 
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_CTRL,
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_SX2_CTRL,
 			    MLXSW_REG_HTGT_INVALID_POLICER,
 			    MLXSW_REG_HTGT_DEFAULT_PRIORITY,
 			    MLXSW_REG_HTGT_DEFAULT_TC);
-- 
2.7.4
