From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/19] mlxsw: spectrum: Use generic listener struct for rx traps
Date: Fri, 25 Nov 2016 10:33:32 +0100
Message-ID: <1480066427-3961-5-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34565 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751724AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wj0-f193.google.com with SMTP id xy5so4928093wjc.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:54 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Replace the old rx listener struct definitions by the generic ones.
Use the new generic registering / unregistering functions for them.
Add some macros to organize the trap list.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 95 +++++++++++---------------
 1 file changed, 38 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 2f06de3..efa99af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2744,8 +2744,8 @@ static void mlxsw_sp_event_unregister(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_core_event_listener_unregister(mlxsw_sp->core, el, mlxsw_sp);
 }
 
-static void mlxsw_sp_rx_listener_func(struct sk_buff *skb, u8 local_port,
-				      void *priv)
+static void mlxsw_sp_rx_listener_no_mark_func(struct sk_buff *skb,
+					      u8 local_port, void *priv)
 {
 	struct mlxsw_sp *mlxsw_sp = priv;
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
@@ -2773,44 +2773,43 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 					   void *priv)
 {
 	skb->offload_fwd_mark = 1;
-	return mlxsw_sp_rx_listener_func(skb, local_port, priv);
+	return mlxsw_sp_rx_listener_no_mark_func(skb, local_port, priv);
 }
 
-#define MLXSW_SP_RXL(_func, _trap_id, _action)			\
-	{							\
-		.func = _func,					\
-		.local_port = MLXSW_PORT_DONT_CARE,		\
-		.trap_id = MLXSW_TRAP_ID_##_trap_id,		\
-		.action = MLXSW_REG_HPKT_ACTION_##_action,	\
-	}
+#define MLXSW_SP_RXL_NO_MARK(_trap_id, _action)				\
+	MLXSW_RXL(mlxsw_sp_rx_listener_no_mark_func, _trap_id, _action,	\
+		  DISCARD)
+
+#define MLXSW_SP_RXL_MARK(_trap_id, _action)				\
+	MLXSW_RXL(mlxsw_sp_rx_listener_mark_func, _trap_id, _action,	\
+		  DISCARD)
 
-static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
+static const struct mlxsw_listener mlxsw_sp_rx_listener[] = {
 	/* L2 traps */
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, STP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LACP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LLDP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, DHCP, MIRROR_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, IGMP_QUERY, MIRROR_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V1_REPORT, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_REPORT, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_LEAVE, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V3_REPORT, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, ARPBC, MIRROR_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, ARPUC, MIRROR_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(STP, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(LACP, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(LLDP, TRAP_TO_CPU),
+	MLXSW_SP_RXL_MARK(DHCP, MIRROR_TO_CPU),
+	MLXSW_SP_RXL_MARK(IGMP_QUERY, MIRROR_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V1_REPORT, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V2_REPORT, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V2_LEAVE, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(IGMP_V3_REPORT, TRAP_TO_CPU),
+	MLXSW_SP_RXL_MARK(ARPBC, MIRROR_TO_CPU),
+	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU),
 	/* L3 traps */
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MTUERROR, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, TTLERROR, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LBERROR, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, OSPF, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IP2ME, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RTR_INGRESS0, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, HOST_MISS_IPV4, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(MTUERROR, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(TTLERROR, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(LBERROR, TRAP_TO_CPU),
+	MLXSW_SP_RXL_MARK(OSPF, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(IP2ME, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU),
+	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU),
 };
 
 static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
 	int i;
 	int err;
 
@@ -2825,50 +2824,32 @@ static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
 		return err;
 
 	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_rx_listener); i++) {
-		err = mlxsw_core_rx_listener_register(mlxsw_sp->core,
-						      &mlxsw_sp_rx_listener[i],
-						      mlxsw_sp);
+		err = mlxsw_core_trap_register(mlxsw_sp->core,
+					       &mlxsw_sp_rx_listener[i],
+					       mlxsw_sp);
 		if (err)
 			goto err_rx_listener_register;
 
-		mlxsw_reg_hpkt_pack(hpkt_pl, mlxsw_sp_rx_listener[i].action,
-				    mlxsw_sp_rx_listener[i].trap_id);
-		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
-		if (err)
-			goto err_rx_trap_set;
 	}
 	return 0;
 
-err_rx_trap_set:
-	mlxsw_core_rx_listener_unregister(mlxsw_sp->core,
-					  &mlxsw_sp_rx_listener[i],
-					  mlxsw_sp);
 err_rx_listener_register:
 	for (i--; i >= 0; i--) {
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
-				    mlxsw_sp_rx_listener[i].trap_id);
-		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
-
-		mlxsw_core_rx_listener_unregister(mlxsw_sp->core,
-						  &mlxsw_sp_rx_listener[i],
-						  mlxsw_sp);
+		mlxsw_core_trap_unregister(mlxsw_sp->core,
+					   &mlxsw_sp_rx_listener[i],
+					   mlxsw_sp);
 	}
 	return err;
 }
 
 static void mlxsw_sp_traps_fini(struct mlxsw_sp *mlxsw_sp)
 {
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_rx_listener); i++) {
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
-				    mlxsw_sp_rx_listener[i].trap_id);
-		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
-
-		mlxsw_core_rx_listener_unregister(mlxsw_sp->core,
-						  &mlxsw_sp_rx_listener[i],
-						  mlxsw_sp);
+		mlxsw_core_trap_unregister(mlxsw_sp->core,
+					   &mlxsw_sp_rx_listener[i],
+					   mlxsw_sp);
 	}
 }
 
-- 
2.7.4
