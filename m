From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/19] mlxsw: spectrum: Use generic listener struct for events
Date: Fri, 25 Nov 2016 10:33:35 +0100
Message-ID: <1480066427-3961-8-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35795 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752870AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so7222215wme.2
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:57 -0800 (PST)
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
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 77 ++++----------------------
 1 file changed, 12 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index efa99af..d758ce6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2698,52 +2698,6 @@ static void mlxsw_sp_pude_event_func(const struct mlxsw_reg_info *reg,
 	}
 }
 
-static struct mlxsw_event_listener mlxsw_sp_pude_event = {
-	.func = mlxsw_sp_pude_event_func,
-	.trap_id = MLXSW_TRAP_ID_PUDE,
-};
-
-static int mlxsw_sp_event_register(struct mlxsw_sp *mlxsw_sp,
-				   enum mlxsw_event_trap_id trap_id)
-{
-	struct mlxsw_event_listener *el;
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
-	int err;
-
-	switch (trap_id) {
-	case MLXSW_TRAP_ID_PUDE:
-		el = &mlxsw_sp_pude_event;
-		break;
-	}
-	err = mlxsw_core_event_listener_register(mlxsw_sp->core, el, mlxsw_sp);
-	if (err)
-		return err;
-
-	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD, trap_id);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
-	if (err)
-		goto err_event_trap_set;
-
-	return 0;
-
-err_event_trap_set:
-	mlxsw_core_event_listener_unregister(mlxsw_sp->core, el, mlxsw_sp);
-	return err;
-}
-
-static void mlxsw_sp_event_unregister(struct mlxsw_sp *mlxsw_sp,
-				      enum mlxsw_event_trap_id trap_id)
-{
-	struct mlxsw_event_listener *el;
-
-	switch (trap_id) {
-	case MLXSW_TRAP_ID_PUDE:
-		el = &mlxsw_sp_pude_event;
-		break;
-	}
-	mlxsw_core_event_listener_unregister(mlxsw_sp->core, el, mlxsw_sp);
-}
-
 static void mlxsw_sp_rx_listener_no_mark_func(struct sk_buff *skb,
 					      u8 local_port, void *priv)
 {
@@ -2784,7 +2738,9 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 	MLXSW_RXL(mlxsw_sp_rx_listener_mark_func, _trap_id, _action,	\
 		  DISCARD)
 
-static const struct mlxsw_listener mlxsw_sp_rx_listener[] = {
+static const struct mlxsw_listener mlxsw_sp_listener[] = {
+	/* Events */
+	MLXSW_EVENTL(mlxsw_sp_pude_event_func, PUDE),
 	/* L2 traps */
 	MLXSW_SP_RXL_NO_MARK(STP, TRAP_TO_CPU),
 	MLXSW_SP_RXL_NO_MARK(LACP, TRAP_TO_CPU),
@@ -2823,20 +2779,20 @@ static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
-	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_rx_listener); i++) {
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_listener); i++) {
 		err = mlxsw_core_trap_register(mlxsw_sp->core,
-					       &mlxsw_sp_rx_listener[i],
+					       &mlxsw_sp_listener[i],
 					       mlxsw_sp);
 		if (err)
-			goto err_rx_listener_register;
+			goto err_listener_register;
 
 	}
 	return 0;
 
-err_rx_listener_register:
+err_listener_register:
 	for (i--; i >= 0; i--) {
 		mlxsw_core_trap_unregister(mlxsw_sp->core,
-					   &mlxsw_sp_rx_listener[i],
+					   &mlxsw_sp_listener[i],
 					   mlxsw_sp);
 	}
 	return err;
@@ -2846,9 +2802,9 @@ static void mlxsw_sp_traps_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_rx_listener); i++) {
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sp_listener); i++) {
 		mlxsw_core_trap_unregister(mlxsw_sp->core,
-					   &mlxsw_sp_rx_listener[i],
+					   &mlxsw_sp_listener[i],
 					   mlxsw_sp);
 	}
 }
@@ -2952,16 +2908,10 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		return err;
 	}
 
-	err = mlxsw_sp_event_register(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Failed to register for PUDE events\n");
-		return err;
-	}
-
 	err = mlxsw_sp_traps_init(mlxsw_sp);
 	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Failed to set traps for RX\n");
-		goto err_rx_listener_register;
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to set traps\n");
+		return err;
 	}
 
 	err = mlxsw_sp_flood_init(mlxsw_sp);
@@ -3021,8 +2971,6 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 err_buffers_init:
 err_flood_init:
 	mlxsw_sp_traps_fini(mlxsw_sp);
-err_rx_listener_register:
-	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	return err;
 }
 
@@ -3037,7 +2985,6 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_lag_fini(mlxsw_sp);
 	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
-	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	WARN_ON(!list_empty(&mlxsw_sp->vfids.list));
 	WARN_ON(!list_empty(&mlxsw_sp->fids));
 }
-- 
2.7.4
