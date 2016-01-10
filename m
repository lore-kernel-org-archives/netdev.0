From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum: Add FDB lock to prevent session interleaving
Date: Sun, 10 Jan 2016 09:32:16 +0100
Message-ID: <1452414736-3571-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35873 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbcAJIcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 03:32:19 -0500
Received: by mail-wm0-f52.google.com with SMTP id l65so178297852wmf.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 00:32:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Dumping the FDB (invoked with a process context) or handling FDB
notifications (polled periodicly in delayed work) might each entail
multiple EMAD transcations due to the number of entries.

While we only allow one EMAD transaction at a time, there is nothing
stopping the dump and notification processing sessions from
interleaving. However, this is forbidden by the hardware, so we need to
make sure only one of these sessions can run at a time.

Solve this by adding a mutex ('fdb_lock'), as both kernel threads can
sleep while waiting for the response EMAD.

Fixes: 56ade8fe3f ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           | 1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 4365c8b..69281ca 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -63,6 +63,7 @@ struct mlxsw_sp {
 	} fdb_notify;
 #define MLXSW_SP_DEFAULT_AGEING_TIME 300
 	u32 ageing_time;
+	struct mutex fdb_lock;	/* Make sure FDB sessions are atomic. */
 	struct {
 		struct net_device *dev;
 		unsigned int ref_count;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 617fb22..80e2660 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -650,6 +650,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sfd_pl)
 		return -ENOMEM;
 
+	mutex_lock(&mlxsw_sp_port->mlxsw_sp->fdb_lock);
 	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
 	do {
 		mlxsw_reg_sfd_num_rec_set(sfd_pl, MLXSW_REG_SFD_REC_MAX_COUNT);
@@ -684,6 +685,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	} while (num_rec == MLXSW_REG_SFD_REC_MAX_COUNT);
 
 out:
+	mutex_unlock(&mlxsw_sp_port->mlxsw_sp->fdb_lock);
 	kfree(sfd_pl);
 	return stored_err ? stored_err : err;
 }
@@ -812,6 +814,7 @@ static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
 
 	mlxsw_sp = container_of(work, struct mlxsw_sp, fdb_notify.dw.work);
 
+	mutex_lock(&mlxsw_sp->fdb_lock);
 	do {
 		mlxsw_reg_sfn_pack(sfn_pl);
 		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(sfn), sfn_pl);
@@ -824,6 +827,7 @@ static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
 			mlxsw_sp_fdb_notify_rec_process(mlxsw_sp, sfn_pl, i);
 
 	} while (num_rec);
+	mutex_unlock(&mlxsw_sp->fdb_lock);
 
 	kfree(sfn_pl);
 	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
@@ -838,6 +842,7 @@ static int mlxsw_sp_fdb_init(struct mlxsw_sp *mlxsw_sp)
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to set default ageing time\n");
 		return err;
 	}
+	mutex_init(&mlxsw_sp->fdb_lock);
 	INIT_DELAYED_WORK(&mlxsw_sp->fdb_notify.dw, mlxsw_sp_fdb_notify_work);
 	mlxsw_sp->fdb_notify.interval = MLXSW_SP_DEFAULT_LEARNING_INTERVAL;
 	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
-- 
2.4.3
