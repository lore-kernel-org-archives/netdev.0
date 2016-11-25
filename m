From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/19] mlxsw: switchx2: Use generic listener struct for events
Date: Fri, 25 Nov 2016 10:33:36 +0100
Message-ID: <1480066427-3961-9-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33861 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752288AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so7223628wme.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:58 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change the events to use the generic listener struct.
Merge the event list into the trap list, so the same functions will
handle both.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 78 ++++----------------------
 1 file changed, 12 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index df6afdd..675ce12 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1396,52 +1396,6 @@ static void mlxsw_sx_pude_event_func(const struct mlxsw_reg_info *reg,
 		mlxsw_sx_pude_ib_event_func(mlxsw_sx_port, status);
 }
 
-static struct mlxsw_event_listener mlxsw_sx_pude_event = {
-	.func = mlxsw_sx_pude_event_func,
-	.trap_id = MLXSW_TRAP_ID_PUDE,
-};
-
-static int mlxsw_sx_event_register(struct mlxsw_sx *mlxsw_sx,
-				   enum mlxsw_event_trap_id trap_id)
-{
-	struct mlxsw_event_listener *el;
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
-	int err;
-
-	switch (trap_id) {
-	case MLXSW_TRAP_ID_PUDE:
-		el = &mlxsw_sx_pude_event;
-		break;
-	}
-	err = mlxsw_core_event_listener_register(mlxsw_sx->core, el, mlxsw_sx);
-	if (err)
-		return err;
-
-	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD, trap_id);
-	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(hpkt), hpkt_pl);
-	if (err)
-		goto err_event_trap_set;
-
-	return 0;
-
-err_event_trap_set:
-	mlxsw_core_event_listener_unregister(mlxsw_sx->core, el, mlxsw_sx);
-	return err;
-}
-
-static void mlxsw_sx_event_unregister(struct mlxsw_sx *mlxsw_sx,
-				      enum mlxsw_event_trap_id trap_id)
-{
-	struct mlxsw_event_listener *el;
-
-	switch (trap_id) {
-	case MLXSW_TRAP_ID_PUDE:
-		el = &mlxsw_sx_pude_event;
-		break;
-	}
-	mlxsw_core_event_listener_unregister(mlxsw_sx->core, el, mlxsw_sx);
-}
-
 static void mlxsw_sx_rx_listener_func(struct sk_buff *skb, u8 local_port,
 				      void *priv)
 {
@@ -1497,7 +1451,8 @@ static int mlxsw_sx_port_type_set(struct mlxsw_core *mlxsw_core, u8 local_port,
 #define MLXSW_SX_RXL(_trap_id) \
 	MLXSW_RXL(mlxsw_sx_rx_listener_func, _trap_id, TRAP_TO_CPU, FORWARD)
 
-static const struct mlxsw_listener mlxsw_sx_rx_listener[] = {
+static const struct mlxsw_listener mlxsw_sx_listener[] = {
+	MLXSW_EVENTL(mlxsw_sx_pude_event_func, PUDE),
 	MLXSW_SX_RXL(FDB_MC),
 	MLXSW_SX_RXL(STP),
 	MLXSW_SX_RXL(LACP),
@@ -1530,20 +1485,20 @@ static int mlxsw_sx_traps_init(struct mlxsw_sx *mlxsw_sx)
 	if (err)
 		return err;
 
-	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_listener); i++) {
 		err = mlxsw_core_trap_register(mlxsw_sx->core,
-					       &mlxsw_sx_rx_listener[i],
+					       &mlxsw_sx_listener[i],
 					       mlxsw_sx);
 		if (err)
-			goto err_rx_listener_register;
+			goto err_listener_register;
 
 	}
 	return 0;
 
-err_rx_listener_register:
+err_listener_register:
 	for (i--; i >= 0; i--) {
 		mlxsw_core_trap_unregister(mlxsw_sx->core,
-					   &mlxsw_sx_rx_listener[i],
+					   &mlxsw_sx_listener[i],
 					   mlxsw_sx);
 	}
 	return err;
@@ -1553,9 +1508,9 @@ static void mlxsw_sx_traps_fini(struct mlxsw_sx *mlxsw_sx)
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_rx_listener); i++) {
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sx_listener); i++) {
 		mlxsw_core_trap_unregister(mlxsw_sx->core,
-					   &mlxsw_sx_rx_listener[i],
+					   &mlxsw_sx_listener[i],
 					   mlxsw_sx);
 	}
 }
@@ -1649,16 +1604,10 @@ static int mlxsw_sx_init(struct mlxsw_core *mlxsw_core,
 		return err;
 	}
 
-	err = mlxsw_sx_event_register(mlxsw_sx, MLXSW_TRAP_ID_PUDE);
-	if (err) {
-		dev_err(mlxsw_sx->bus_info->dev, "Failed to register for PUDE events\n");
-		goto err_event_register;
-	}
-
 	err = mlxsw_sx_traps_init(mlxsw_sx);
 	if (err) {
-		dev_err(mlxsw_sx->bus_info->dev, "Failed to set traps for RX\n");
-		goto err_rx_listener_register;
+		dev_err(mlxsw_sx->bus_info->dev, "Failed to set traps\n");
+		goto err_listener_register;
 	}
 
 	err = mlxsw_sx_flood_init(mlxsw_sx);
@@ -1671,9 +1620,7 @@ static int mlxsw_sx_init(struct mlxsw_core *mlxsw_core,
 
 err_flood_init:
 	mlxsw_sx_traps_fini(mlxsw_sx);
-err_rx_listener_register:
-	mlxsw_sx_event_unregister(mlxsw_sx, MLXSW_TRAP_ID_PUDE);
-err_event_register:
+err_listener_register:
 	mlxsw_sx_ports_remove(mlxsw_sx);
 	return err;
 }
@@ -1683,7 +1630,6 @@ static void mlxsw_sx_fini(struct mlxsw_core *mlxsw_core)
 	struct mlxsw_sx *mlxsw_sx = mlxsw_core_driver_priv(mlxsw_core);
 
 	mlxsw_sx_traps_fini(mlxsw_sx);
-	mlxsw_sx_event_unregister(mlxsw_sx, MLXSW_TRAP_ID_PUDE);
 	mlxsw_sx_ports_remove(mlxsw_sx);
 }
 
-- 
2.7.4
