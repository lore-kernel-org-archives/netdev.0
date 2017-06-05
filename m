From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/19] rocker: Add support for learning FDB through notification
Date: Mon,  5 Jun 2017 11:20:41 +0200
Message-ID: <20170605092043.3523-18-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36039 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdFEJVK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:21:10 -0400
Received: by mail-wr0-f194.google.com with SMTP id e23so5692316wre.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:21:09 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for learning FDB through notification. The driver defers
the hardware update via ordered work queue.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 140 ++++++++++++++++++++++++++++--
 1 file changed, 135 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 9f0154d..72dab7c 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1691,6 +1691,29 @@ rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
 }
 
 static int
+rocker_world_port_fdb_add(struct rocker_port *rocker_port,
+			  struct switchdev_notifier_fdb_info *info)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_fdb_add)
+		return -EOPNOTSUPP;
+
+	return wops->port_obj_fdb_add(rocker_port, info->vid, info->addr);
+}
+
+static int
+rocker_world_port_fdb_del(struct rocker_port *rocker_port,
+			  struct switchdev_notifier_fdb_info *info)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_fdb_del)
+		return -EOPNOTSUPP;
+	return wops->port_obj_fdb_del(rocker_port, info->vid, info->addr);
+}
+
+static int
 rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
 			       struct switchdev_obj_port_fdb *fdb,
 			       switchdev_obj_dump_cb_t *cb)
@@ -2767,6 +2790,109 @@ static void rocker_msix_fini(const struct rocker *rocker)
 	kfree(rocker->msix_entries);
 }
 
+static bool rocker_port_dev_check(const struct net_device *dev)
+{
+	return dev->netdev_ops == &rocker_port_netdev_ops;
+}
+
+struct rocker_switchdev_event_work {
+	struct work_struct work;
+	struct switchdev_notifier_fdb_info fdb_info;
+	struct rocker_port *rocker_port;
+	unsigned long event;
+};
+
+static void
+rocker_fdb_offload_notify(struct rocker_port *rocker_port,
+			  struct switchdev_notifier_fdb_info *recv_info)
+{
+	struct switchdev_notifier_fdb_info info;
+
+	info.addr = recv_info->addr;
+	info.vid = recv_info->vid;
+	call_switchdev_notifiers(SWITCHDEV_FDB_OFFLOADED,
+				 rocker_port->dev, &info.info);
+}
+
+static void rocker_switchdev_event_work(struct work_struct *work)
+{
+	struct rocker_switchdev_event_work *switchdev_work =
+		container_of(work, struct rocker_switchdev_event_work, work);
+	struct rocker_port *rocker_port = switchdev_work->rocker_port;
+	struct switchdev_notifier_fdb_info *fdb_info;
+	int err;
+
+	rtnl_lock();
+	switch (switchdev_work->event) {
+	case SWITCHDEV_FDB_ADD_TO_DEVICE:
+		fdb_info = &switchdev_work->fdb_info;
+		err = rocker_world_port_fdb_add(rocker_port, fdb_info);
+		if (err) {
+			netdev_dbg(rocker_port->dev, "fdb add failed err=%d\n", err);
+			break;
+		}
+		rocker_fdb_offload_notify(rocker_port, fdb_info);
+		break;
+	case SWITCHDEV_FDB_DEL_TO_DEVICE:
+		fdb_info = &switchdev_work->fdb_info;
+		err = rocker_world_port_fdb_del(rocker_port, fdb_info);
+		if (err)
+			netdev_dbg(rocker_port->dev, "fdb add failed err=%d\n", err);
+		break;
+	}
+	rtnl_unlock();
+
+	kfree(switchdev_work->fdb_info.addr);
+	kfree(switchdev_work);
+	dev_put(rocker_port->dev);
+}
+
+/* called under rcu_read_lock() */
+static int rocker_switchdev_event(struct notifier_block *unused,
+				  unsigned long event, void *ptr)
+{
+	struct net_device *dev = switchdev_notifier_info_to_dev(ptr);
+	struct rocker_switchdev_event_work *switchdev_work;
+	struct switchdev_notifier_fdb_info *fdb_info = ptr;
+	struct rocker_port *rocker_port;
+
+	if (!rocker_port_dev_check(dev))
+		return NOTIFY_DONE;
+
+	rocker_port = netdev_priv(dev);
+	switchdev_work = kzalloc(sizeof(*switchdev_work), GFP_ATOMIC);
+	if (WARN_ON(!switchdev_work))
+		return NOTIFY_BAD;
+
+	INIT_WORK(&switchdev_work->work, rocker_switchdev_event_work);
+	switchdev_work->rocker_port = rocker_port;
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
+		/* Take a reference on the rocker device */
+		dev_hold(dev);
+		break;
+	default:
+		kfree(switchdev_work);
+		return NOTIFY_DONE;
+	}
+
+	queue_work(rocker_port->rocker->rocker_owq,
+		   &switchdev_work->work);
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rocker_switchdev_notifier = {
+	.notifier_call = rocker_switchdev_event,
+};
+
 static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct rocker *rocker;
@@ -2872,6 +2998,12 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	if (err)
 		goto err_register_fib_notifier;
 
+	err = register_switchdev_notifier(&rocker_switchdev_notifier);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to register switchdev notifier\n");
+		goto err_register_switchdev_notifier;
+	}
+
 	rocker->hw.id = rocker_read64(rocker, SWITCH_ID);
 
 	err = rocker_probe_ports(rocker);
@@ -2886,6 +3018,8 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	return 0;
 
 err_probe_ports:
+	unregister_switchdev_notifier(&rocker_switchdev_notifier);
+err_register_switchdev_notifier:
 	unregister_fib_notifier(&rocker->fib_nb);
 err_register_fib_notifier:
 	destroy_workqueue(rocker->rocker_owq);
@@ -2916,6 +3050,7 @@ static void rocker_remove(struct pci_dev *pdev)
 	struct rocker *rocker = pci_get_drvdata(pdev);
 
 	rocker_remove_ports(rocker);
+	unregister_switchdev_notifier(&rocker_switchdev_notifier);
 	unregister_fib_notifier(&rocker->fib_nb);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
 	destroy_workqueue(rocker->rocker_owq);
@@ -2940,11 +3075,6 @@ static struct pci_driver rocker_pci_driver = {
  * Net device notifier event handler
  ************************************/
 
-static bool rocker_port_dev_check(const struct net_device *dev)
-{
-	return dev->netdev_ops == &rocker_port_netdev_ops;
-}
-
 static bool rocker_port_dev_check_under(const struct net_device *dev,
 					struct rocker *rocker)
 {
-- 
2.9.3
