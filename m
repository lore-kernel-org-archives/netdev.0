From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/19] mlxsw: switchib: Use generic listener struct for events
Date: Fri, 25 Nov 2016 10:33:37 +0100
Message-ID: <1480066427-3961-10-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33868 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so7223661wme.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:00 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change the event handling in Switchib to be comptible with Spectrum and
Switchx2.
Use the generic listener struct for the events. Init and fini them by loop
(and not by calling each event by its name).

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchib.c | 62 +++++++++++---------------
 1 file changed, 27 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
index 1552594..847cbbf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
@@ -408,51 +408,43 @@ static void mlxsw_sib_pude_event_func(const struct mlxsw_reg_info *reg,
 	mlxsw_sib_pude_ib_event_func(mlxsw_sib_port, status);
 }
 
-static struct mlxsw_event_listener mlxsw_sib_pude_event = {
-	.func = mlxsw_sib_pude_event_func,
-	.trap_id = MLXSW_TRAP_ID_PUDE,
+static const struct mlxsw_listener mlxsw_sib_listener[] = {
+	MLXSW_EVENTL(mlxsw_sib_pude_event_func, PUDE),
 };
 
-static int mlxsw_sib_event_register(struct mlxsw_sib *mlxsw_sib,
-				    enum mlxsw_event_trap_id trap_id)
+static int mlxsw_sib_taps_init(struct mlxsw_sib *mlxsw_sib)
 {
-	struct mlxsw_event_listener *el;
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int i;
 	int err;
 
-	switch (trap_id) {
-	case MLXSW_TRAP_ID_PUDE:
-		el = &mlxsw_sib_pude_event;
-		break;
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sib_listener); i++) {
+		err = mlxsw_core_trap_register(mlxsw_sib->core,
+					       &mlxsw_sib_listener[i],
+					       mlxsw_sib);
+		if (err)
+			goto err_rx_listener_register;
 	}
-	err = mlxsw_core_event_listener_register(mlxsw_sib->core, el,
-						 mlxsw_sib);
-	if (err)
-		return err;
-
-	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_FORWARD, trap_id);
-	err = mlxsw_reg_write(mlxsw_sib->core, MLXSW_REG(hpkt), hpkt_pl);
-	if (err)
-		goto err_event_trap_set;
 
 	return 0;
 
-err_event_trap_set:
-	mlxsw_core_event_listener_unregister(mlxsw_sib->core, el, mlxsw_sib);
+err_rx_listener_register:
+	for (i--; i >= 0; i--) {
+		mlxsw_core_trap_unregister(mlxsw_sib->core,
+					   &mlxsw_sib_listener[i],
+					   mlxsw_sib);
+	}
+
 	return err;
 }
 
-static void mlxsw_sib_event_unregister(struct mlxsw_sib *mlxsw_sib,
-				       enum mlxsw_event_trap_id trap_id)
+static void mlxsw_sib_traps_fini(struct mlxsw_sib *mlxsw_sib)
 {
-	struct mlxsw_event_listener *el;
+	int i;
 
-	switch (trap_id) {
-	case MLXSW_TRAP_ID_PUDE:
-		el = &mlxsw_sib_pude_event;
-		break;
+	for (i = 0; i < ARRAY_SIZE(mlxsw_sib_listener); i++) {
+		mlxsw_core_trap_unregister(mlxsw_sib->core,
+					   &mlxsw_sib_listener[i], mlxsw_sib);
 	}
-	mlxsw_core_event_listener_unregister(mlxsw_sib->core, el, mlxsw_sib);
 }
 
 static int mlxsw_sib_init(struct mlxsw_core *mlxsw_core,
@@ -470,15 +462,15 @@ static int mlxsw_sib_init(struct mlxsw_core *mlxsw_core,
 		return err;
 	}
 
-	err = mlxsw_sib_event_register(mlxsw_sib, MLXSW_TRAP_ID_PUDE);
+	err = mlxsw_sib_taps_init(mlxsw_sib);
 	if (err) {
-		dev_err(mlxsw_sib->bus_info->dev, "Failed to register for PUDE events\n");
-		goto err_event_register;
+		dev_err(mlxsw_sib->bus_info->dev, "Failed to set traps\n");
+		goto err_traps_init_err;
 	}
 
 	return 0;
 
-err_event_register:
+err_traps_init_err:
 	mlxsw_sib_ports_remove(mlxsw_sib);
 	return err;
 }
@@ -487,7 +479,7 @@ static void mlxsw_sib_fini(struct mlxsw_core *mlxsw_core)
 {
 	struct mlxsw_sib *mlxsw_sib = mlxsw_core_driver_priv(mlxsw_core);
 
-	mlxsw_sib_event_unregister(mlxsw_sib, MLXSW_TRAP_ID_PUDE);
+	mlxsw_sib_traps_fini(mlxsw_sib);
 	mlxsw_sib_ports_remove(mlxsw_sib);
 }
 
-- 
2.7.4
