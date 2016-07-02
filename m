From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/18] mlxsw: spectrum: Initialize ports at the end of init sequence
Date: Sat,  2 Jul 2016 09:26:28 +0200
Message-ID: <1467444400-9480-7-git-send-email-jiri@resnulli.us>
References: <1467444400-9480-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33938 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbcGBH1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 03:27:23 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so9911726wmz.1
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 00:26:51 -0700 (PDT)
In-Reply-To: <1467444400-9480-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

During ports initialization a net device is registered for each
available port, which implies the port is usable. However, a port is
only usable after the different parts of the device (e.g. flooding,
buffers) are initialized. This is especially important now, when we must
initialize the router before the ports, as otherwise the device can't be
initialized.

Solve that by initializing the switch ports at the end of init sequence.

Also, remove an unnecessary warning about port up/down events, which
would otherwise be invoked whenever removing the driver, as ports are
removed before unregistering the listener for these events.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 30fe0d2..b6f4dfb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2099,11 +2099,8 @@ static void mlxsw_sp_pude_event_func(const struct mlxsw_reg_info *reg,
 
 	local_port = mlxsw_reg_pude_local_port_get(pude_pl);
 	mlxsw_sp_port = mlxsw_sp->ports[local_port];
-	if (!mlxsw_sp_port) {
-		dev_warn(mlxsw_sp->bus_info->dev, "Port %d: Link event received for non-existent port\n",
-			 local_port);
+	if (!mlxsw_sp_port)
 		return;
-	}
 
 	status = mlxsw_reg_pude_oper_status_get(pude_pl);
 	if (status == MLXSW_PORT_OPER_STATUS_UP) {
@@ -2405,16 +2402,10 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		return err;
 	}
 
-	err = mlxsw_sp_ports_create(mlxsw_sp);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
-		return err;
-	}
-
 	err = mlxsw_sp_event_register(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to register for PUDE events\n");
-		goto err_event_register;
+		return err;
 	}
 
 	err = mlxsw_sp_traps_init(mlxsw_sp);
@@ -2447,8 +2438,16 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_switchdev_init;
 	}
 
+	err = mlxsw_sp_ports_create(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
+		goto err_ports_create;
+	}
+
 	return 0;
 
+err_ports_create:
+	mlxsw_sp_switchdev_fini(mlxsw_sp);
 err_switchdev_init:
 err_lag_init:
 	mlxsw_sp_buffers_fini(mlxsw_sp);
@@ -2457,8 +2456,6 @@ err_flood_init:
 	mlxsw_sp_traps_fini(mlxsw_sp);
 err_rx_listener_register:
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
-err_event_register:
-	mlxsw_sp_ports_remove(mlxsw_sp);
 	return err;
 }
 
@@ -2466,11 +2463,11 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
+	mlxsw_sp_ports_remove(mlxsw_sp);
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
-	mlxsw_sp_ports_remove(mlxsw_sp);
 	WARN_ON(!list_empty(&mlxsw_sp->fids));
 }
 
-- 
2.5.5
