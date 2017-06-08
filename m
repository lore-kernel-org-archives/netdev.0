From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 11/19] mlxsw: spectrum_switchdev: Add support for learning FDB through notification
Date: Thu,  8 Jun 2017 08:44:20 +0200
Message-ID: <20170608064428.4785-12-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33999 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdFHGow (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:44:52 -0400
Received: by mail-wr0-f195.google.com with SMTP id u101so2902899wrc.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:51 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for learning FDB through notification. The driver defers
the hardware update via ordered work queue. Support for stacked devices
is also provided. In case of a successful FDB add a notification is
sent back to bridge.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 137 +++++++++++++++++++++
 3 files changed, 139 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e6e0ab9..93530ab 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3702,7 +3702,7 @@ struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
 	return mlxsw_sp_port ? mlxsw_sp_port->mlxsw_sp : NULL;
 }
 
-static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find_rcu(struct net_device *dev)
+struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find_rcu(struct net_device *dev)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 4a7a39a..5ef98d4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -361,6 +361,7 @@ struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev);
 struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find(struct net_device *dev);
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
 void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port);
+struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find_rcu(struct net_device *dev);
 
 /* spectrum_dcb.c */
 #ifdef CONFIG_MLXSW_SPECTRUM_DCB
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0b50d1d..0297c13 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1181,6 +1181,43 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 						   true, false);
 }
 
+static int
+mlxsw_sp_port_fdb_set(struct mlxsw_sp_port *mlxsw_sp_port,
+		      struct switchdev_notifier_fdb_info *fdb_info, bool adding)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct net_device *orig_dev = fdb_info->info.dev;
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
+	struct mlxsw_sp_bridge_device *bridge_device;
+	struct mlxsw_sp_bridge_port *bridge_port;
+	u16 fid_index, vid;
+
+	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
+	if (!bridge_port)
+		return -EINVAL;
+
+	bridge_device = bridge_port->bridge_device;
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_bridge(mlxsw_sp_port,
+							       bridge_device,
+							       fdb_info->vid);
+	if (!mlxsw_sp_port_vlan)
+		return 0;
+
+	fid_index = mlxsw_sp_fid_index(mlxsw_sp_port_vlan->fid);
+	vid = mlxsw_sp_port_vlan->vid;
+
+	if (!bridge_port->lagged)
+		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp,
+					       bridge_port->system_port,
+					       fdb_info->addr, fid_index,
+					       adding, false);
+	else
+		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp,
+						   bridge_port->lag_id,
+						   fdb_info->addr, fid_index,
+						   vid, adding, false);
+}
+
 static int mlxsw_sp_port_mdb_op(struct mlxsw_sp *mlxsw_sp, const char *addr,
 				u16 fid, u16 mid, bool adding)
 {
@@ -2013,6 +2050,97 @@ static void mlxsw_sp_fdb_notify_work(struct work_struct *work)
 	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
 }
 
+struct mlxsw_sp_switchdev_event_work {
+	struct work_struct work;
+	struct switchdev_notifier_fdb_info fdb_info;
+	struct net_device *dev;
+	unsigned long event;
+};
+
+static void mlxsw_sp_switchdev_event_work(struct work_struct *work)
+{
+	struct mlxsw_sp_switchdev_event_work *switchdev_work =
+		container_of(work, struct mlxsw_sp_switchdev_event_work, work);
+	struct net_device *dev = switchdev_work->dev;
+	struct switchdev_notifier_fdb_info *fdb_info;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	int err;
+
+	rtnl_lock();
+	mlxsw_sp_port = mlxsw_sp_port_dev_lower_find(dev);
+	if (!mlxsw_sp_port)
+		goto out;
+
+	switch (switchdev_work->event) {
+	case SWITCHDEV_FDB_ADD_TO_DEVICE:
+		fdb_info = &switchdev_work->fdb_info;
+		err = mlxsw_sp_port_fdb_set(mlxsw_sp_port, fdb_info, true);
+		if (err)
+			break;
+		mlxsw_sp_fdb_call_notifiers(SWITCHDEV_FDB_OFFLOADED,
+					    fdb_info->addr,
+					    fdb_info->vid, dev);
+		break;
+	case SWITCHDEV_FDB_DEL_TO_DEVICE:
+		fdb_info = &switchdev_work->fdb_info;
+		mlxsw_sp_port_fdb_set(mlxsw_sp_port, fdb_info, false);
+		break;
+	}
+
+out:
+	rtnl_unlock();
+	kfree(switchdev_work->fdb_info.addr);
+	kfree(switchdev_work);
+	dev_put(dev);
+}
+
+/* Called under rcu_read_lock() */
+static int mlxsw_sp_switchdev_event(struct notifier_block *unused,
+				    unsigned long event, void *ptr)
+{
+	struct net_device *dev = switchdev_notifier_info_to_dev(ptr);
+	struct mlxsw_sp_switchdev_event_work *switchdev_work;
+	struct switchdev_notifier_fdb_info *fdb_info = ptr;
+
+	if (!mlxsw_sp_port_dev_lower_find_rcu(dev))
+		return NOTIFY_DONE;
+
+	switchdev_work = kzalloc(sizeof(*switchdev_work), GFP_ATOMIC);
+	if (!switchdev_work)
+		return NOTIFY_BAD;
+
+	INIT_WORK(&switchdev_work->work, mlxsw_sp_switchdev_event_work);
+	switchdev_work->dev = dev;
+	switchdev_work->event = event;
+
+	switch (event) {
+	case SWITCHDEV_FDB_ADD_TO_DEVICE: /* fall through */
+	case SWITCHDEV_FDB_DEL_TO_DEVICE:
+		memcpy(&switchdev_work->fdb_info, ptr,
+		       sizeof(switchdev_work->fdb_info));
+		switchdev_work->fdb_info.addr = kzalloc(ETH_ALEN, GFP_ATOMIC);
+		ether_addr_copy((u8 *)switchdev_work->fdb_info.addr,
+				fdb_info->addr);
+		/* Take a reference on the device. This can be either
+		 * upper device containig mlxsw_sp_port or just a
+		 * mlxsw_sp_port
+		 */
+		dev_hold(dev);
+		break;
+	default:
+		kfree(switchdev_work);
+		return NOTIFY_DONE;
+	}
+
+	mlxsw_core_schedule_work(&switchdev_work->work);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block mlxsw_sp_switchdev_notifier = {
+	.notifier_call = mlxsw_sp_switchdev_event,
+};
+
 static int mlxsw_sp_fdb_init(struct mlxsw_sp *mlxsw_sp)
 {
 	struct mlxsw_sp_bridge *bridge = mlxsw_sp->bridge;
@@ -2023,6 +2151,13 @@ static int mlxsw_sp_fdb_init(struct mlxsw_sp *mlxsw_sp)
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to set default ageing time\n");
 		return err;
 	}
+
+	err = register_switchdev_notifier(&mlxsw_sp_switchdev_notifier);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to register switchdev notifier\n");
+		return err;
+	}
+
 	INIT_DELAYED_WORK(&bridge->fdb_notify.dw, mlxsw_sp_fdb_notify_work);
 	bridge->fdb_notify.interval = MLXSW_SP_DEFAULT_LEARNING_INTERVAL;
 	mlxsw_sp_fdb_notify_work_schedule(mlxsw_sp);
@@ -2032,6 +2167,8 @@ static int mlxsw_sp_fdb_init(struct mlxsw_sp *mlxsw_sp)
 static void mlxsw_sp_fdb_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	cancel_delayed_work_sync(&mlxsw_sp->bridge->fdb_notify.dw);
+	unregister_switchdev_notifier(&mlxsw_sp_switchdev_notifier);
+
 }
 
 int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
-- 
2.9.3
