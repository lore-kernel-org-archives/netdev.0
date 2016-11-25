From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/19] mlxsw: switchx2: Use generic listener struct for rx traps
Date: Fri, 25 Nov 2016 10:33:33 +0100
Message-ID: <1480066427-3961-6-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36811 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f67.google.com with SMTP id m203so7188250wma.3
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:55 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Reorganize the traps to use the new generic listener struct and
functions. Use macros to shorten the traps list.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 127 ++++++-------------------
 1 file changed, 27 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 60f19fb..df6afdd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1494,84 +1494,29 @@ static int mlxsw_sx_port_type_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 	return err;
 }
 
-static const struct mlxsw_rx_listener mlxsw_sx_rx_listener[] = {
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_FDB_MC,
-	},
-	/* Traps for specific L2 packet types, not trapped as FDB MC */
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_STP,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_LACP,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_EAPOL,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_LLDP,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_MMRP,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_MVRP,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_RPVST,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_DHCP,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_QUERY,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V1_REPORT,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V2_REPORT,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V2_LEAVE,
-	},
-	{
-		.func = mlxsw_sx_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V3_REPORT,
-	},
+#define MLXSW_SX_RXL(_trap_id) \
+	MLXSW_RXL(mlxsw_sx_rx_listener_func, _trap_id, TRAP_TO_CPU, FORWARD)
+
+static const struct mlxsw_listener mlxsw_sx_rx_listener[] = {
+	MLXSW_SX_RXL(FDB_MC),
+	MLXSW_SX_RXL(STP),
+	MLXSW_SX_RXL(LACP),
+	MLXSW_SX_RXL(EAPOL),
+	MLXSW_SX_RXL(LLDP),
+	MLXSW_SX_RXL(MMRP),
+	MLXSW_SX_RXL(MVRP),
+	MLXSW_SX_RXL(RPVST),
+	MLXSW_SX_RXL(DHCP),
+	MLXSW_SX_RXL(IGMP_QUERY),
+	MLXSW_SX_RXL(IGMP_V1_REPORT),
+	MLXSW_SX_RXL(IGMP_V2_REPORT),
+	MLXSW_SX_RXL(IGMP_V2_LEAVE),
+	MLXSW_SX_RXL(IGMP_V3_REPORT),
 };
 
 static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 {
 	char htgt_pl[MLXSW_REG_HTGT_LEN];
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
 	int i;
 	int err;
 
@@ -1586,50 +1531,32 @@ static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 		return err;
 
 	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
-		err = mlxsw_core_rx_listener_register(mlxsw_sx->core,
-						      &mlxsw_sx_rx_listener[i],
-						      mlxsw_sx);
+		err = mlxsw_core_trap_register(mlxsw_sx->core,
+					       &mlxsw_sx_rx_listener[i],
+					       mlxsw_sx);
 		if (err)
 			goto err_rx_listener_register;
 
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
-				    mlxsw_sx_rx_listener[i].trap_id);
-		err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
-		if (err)
-			goto err_rx_trap_set;
 	}
 	return 0;
 
-err_rx_trap_set:
-	mlxsw_core_rx_listener_unregister(mlxsw_sx->core,
-					  &mlxsw_sx_rx_listener[i],
-					  mlxsw_sx);
 err_rx_listener_register:
 	for (i--; i >= 0; i--) {
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
-				    mlxsw_sx_rx_listener[i].trap_id);
-		mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
-
-		mlxsw_core_rx_listener_unregister(mlxsw_sx->core,
-						  &mlxsw_sx_rx_listener[i],
-						  mlxsw_sx);
+		mlxsw_core_trap_unregister(mlxsw_sx->core,
+					   &mlxsw_sx_rx_listener[i],
+					   mlxsw_sx);
 	}
 	return err;
 }
 
 static void mlxsw_sx_traps_fini(struct mlxsw_sx *mlxsw_sx)
 {
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD,
-				    mlxsw_sx_rx_listener[i].trap_id);
-		mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
-
-		mlxsw_core_rx_listener_unregister(mlxsw_sx->core,
-						  &mlxsw_sx_rx_listener[i],
-						  mlxsw_sx);
+		mlxsw_core_trap_unregister(mlxsw_sx->core,
+					   &mlxsw_sx_rx_listener[i],
+					   mlxsw_sx);
 	}
 }
 
-- 
2.7.4
