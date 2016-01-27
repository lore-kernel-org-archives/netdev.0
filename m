From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] switchdev: Require RTNL mutex to be held when sending FDB notifications
Date: Wed, 27 Jan 2016 15:16:43 +0100
Message-ID: <1453904203-4908-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35784 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602AbcA0OQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:16:47 -0500
Received: by mail-wm0-f67.google.com with SMTP id l66so562096wml.2
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:16:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When switchdev drivers process FDB notifications from the underlying
device they resolve the netdev to which the entry points to and notify
the bridge using the switchdev notifier.

However, since the RTNL mutex is not held there is nothing preventing
the netdev from disappearing in the middle, which will cause
br_switchdev_event() to dereference a non-existing netdev.

Make switchdev drivers hold the lock at the beginning of the
notification processing session and release it once it ends, after
notifying the bridge.

Also, remove switchdev_mutex and fdb_lock, as they are no longer needed
when RTNL mutex is held.

Fixes: 03bf0c281234 ("switchdev: introduce switchdev notifier")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |  1 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  8 +++-----
 drivers/net/ethernet/rocker/rocker.c                     |  2 ++
 net/bridge/br.c                                          |  3 +--
 net/switchdev/switchdev.c                                | 15 ++++++++-------
 5 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index a23dc61..199f91a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -120,7 +120,6 @@ struct mlxsw_sp {
 	} fdb_notify;
 #define MLXSW_SP_DEFAULT_AGEING_TIME 300
 	u32 ageing_time;
-	struct mutex fdb_lock;	/* Make sure FDB sessions are atomic. */
 	struct mlxsw_sp_upper master_bridge;
 	struct mlxsw_sp_upper lags[MLXSW_SP_LAG_MAX];
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 45479ef..54d25af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -45,6 +45,7 @@
 #include <linux/if_bridge.h>
 #include <linux/workqueue.h>
 #include <linux/jiffies.h>
+#include <linux/rtnetlink.h>
 #include <net/switchdev.h>
 
 #include "spectrum.h"
@@ -1058,7 +1059,6 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sfd_pl)
 		return -ENOMEM;
 
-	mutex_lock(&mlxsw_sp_port->mlxsw_sp->fdb_lock);
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
 		u16 tmp;
 
@@ -1124,7 +1124,6 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	} while (num_rec == MLXSW_REG_SFD_REC_MAX_COUNT);
 
 out:
-	mutex_unlock(&mlxsw_sp_port->mlxsw_sp->fdb_lock);
 	kfree(sfd_pl);
 	return stored_err ? stored_err : err;
 }
@@ -1374,7 +1373,7 @@ static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
 
 	mlxsw_sp = container_of(work, struct mlxsw_sp, fdb_notify.dw.work);
 
-	mutex_lock(&mlxsw_sp->fdb_lock);
+	rtnl_lock();
 	do {
 		mlxsw_reg_sfn_pack(sfn_pl);
 		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(sfn), sfn_pl);
@@ -1387,7 +1386,7 @@ static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
 			mlxsw_sp_fdb_notify_rec_process(mlxsw_sp, sfn_pl, i);
 
 	} while (num_rec);
-	mutex_unlock(&mlxsw_sp->fdb_lock);
+	rtnl_unlock();
 
 	kfree(sfn_pl);
 	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
@@ -1402,7 +1401,6 @@ static int mlxsw_sp_fdb_init(struct mlxsw_sp *mlxsw_sp)
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to set default ageing time\n");
 		return err;
 	}
-	mutex_init(&mlxsw_sp->fdb_lock);
 	INIT_DELAYED_WORK(&mlxsw_sp->fdb_notify.dw, mlxsw_sp_fdb_notify_work);
 	mlxsw_sp->fdb_notify.interval = MLXSW_SP_DEFAULT_LEARNING_INTERVAL;
 	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a4ab71d..166a7fc 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3531,12 +3531,14 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 	info.addr = lw->addr;
 	info.vid = lw->vid;
 
+	rtnl_lock();
 	if (learned && removing)
 		call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
 					 lw->rocker_port->dev, &info.info);
 	else if (learned && !removing)
 		call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
 					 lw->rocker_port->dev, &info.info);
+	rtnl_unlock();
 
 	rocker_port_kfree(lw->trans, work);
 }
diff --git a/net/bridge/br.c b/net/bridge/br.c
index a1abe49..3addc05 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -121,6 +121,7 @@ static struct notifier_block br_device_notifier = {
 	.notifier_call = br_device_event
 };
 
+/* called with RTNL */
 static int br_switchdev_event(struct notifier_block *unused,
 			      unsigned long event, void *ptr)
 {
@@ -130,7 +131,6 @@ static int br_switchdev_event(struct notifier_block *unused,
 	struct switchdev_notifier_fdb_info *fdb_info;
 	int err = NOTIFY_DONE;
 
-	rtnl_lock();
 	p = br_port_get_rtnl(dev);
 	if (!p)
 		goto out;
@@ -155,7 +155,6 @@ static int br_switchdev_event(struct notifier_block *unused,
 	}
 
 out:
-	rtnl_unlock();
 	return err;
 }
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index ebc661d..47f7da5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -20,6 +20,7 @@
 #include <linux/list.h>
 #include <linux/workqueue.h>
 #include <linux/if_vlan.h>
+#include <linux/rtnetlink.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
@@ -567,7 +568,6 @@ int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_obj_dump);
 
-static DEFINE_MUTEX(switchdev_mutex);
 static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
 
 /**
@@ -582,9 +582,9 @@ int register_switchdev_notifier(struct notifier_block *nb)
 {
 	int err;
 
-	mutex_lock(&switchdev_mutex);
+	rtnl_lock();
 	err = raw_notifier_chain_register(&switchdev_notif_chain, nb);
-	mutex_unlock(&switchdev_mutex);
+	rtnl_unlock();
 	return err;
 }
 EXPORT_SYMBOL_GPL(register_switchdev_notifier);
@@ -600,9 +600,9 @@ int unregister_switchdev_notifier(struct notifier_block *nb)
 {
 	int err;
 
-	mutex_lock(&switchdev_mutex);
+	rtnl_lock();
 	err = raw_notifier_chain_unregister(&switchdev_notif_chain, nb);
-	mutex_unlock(&switchdev_mutex);
+	rtnl_unlock();
 	return err;
 }
 EXPORT_SYMBOL_GPL(unregister_switchdev_notifier);
@@ -616,16 +616,17 @@ EXPORT_SYMBOL_GPL(unregister_switchdev_notifier);
  *	Call all network notifier blocks. This should be called by driver
  *	when it needs to propagate hardware event.
  *	Return values are same as for atomic_notifier_call_chain().
+ *	rtnl_lock must be held.
  */
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 			     struct switchdev_notifier_info *info)
 {
 	int err;
 
+	ASSERT_RTNL();
+
 	info->dev = dev;
-	mutex_lock(&switchdev_mutex);
 	err = raw_notifier_call_chain(&switchdev_notif_chain, val, info);
-	mutex_unlock(&switchdev_mutex);
 	return err;
 }
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
-- 
1.9.3
