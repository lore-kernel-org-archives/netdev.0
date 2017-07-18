From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next 04/11] net: dsa: Add support for learning FDB through notification
Date: Tue, 18 Jul 2017 17:20:17 +0300
Message-ID: <1500387624-4361-5-git-send-email-arkadis@mellanox.com>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36058 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751493AbdGROQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 10:16:52 -0400
In-Reply-To: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for learning FDB through notification. The driver defers
the hardware update via ordered work queue. In case of a successful
FDB add a notification is sent back to bridge.

In case of hw FDB del failure the static FDB will be deleted from
the bridge, thus, the interface is moved to down state in order to
indicate inconsistent situation.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 include/net/dsa.h |   1 +
 net/dsa/dsa.c     |  13 ++++++
 net/dsa/slave.c   | 127 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 139 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index f054d41..4835b0e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -451,6 +451,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 struct net_device *dsa_dev_to_net_device(struct device *dev);
+bool dsa_schedule_work(struct work_struct *work);
 
 /* Keep inline for faster access in hot path */
 static inline bool netdev_uses_dsa(struct net_device *dev)
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 416ac4e..9abe6dc 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -271,10 +271,22 @@ static struct packet_type dsa_pack_type __read_mostly = {
 	.func	= dsa_switch_rcv,
 };
 
+static struct workqueue_struct *dsa_owq;
+
+bool dsa_schedule_work(struct work_struct *work)
+{
+	return queue_work(dsa_owq, work);
+}
+
 static int __init dsa_init_module(void)
 {
 	int rc;
 
+	dsa_owq = alloc_ordered_workqueue("dsa_ordered",
+					  WQ_MEM_RECLAIM);
+	if (!dsa_owq)
+		return -ENOMEM;
+
 	rc = dsa_slave_register_notifier();
 	if (rc)
 		return rc;
@@ -294,6 +306,7 @@ static void __exit dsa_cleanup_module(void)
 	dsa_slave_unregister_notifier();
 	dev_remove_pack(&dsa_pack_type);
 	dsa_legacy_unregister();
+	destroy_workqueue(dsa_owq);
 }
 module_exit(dsa_cleanup_module);
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 19395cc..8278d08 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1263,19 +1263,142 @@ static int dsa_slave_netdevice_event(struct notifier_block *nb,
 	return NOTIFY_DONE;
 }
 
+struct dsa_switchdev_event_work {
+	struct work_struct work;
+	struct switchdev_notifier_fdb_info fdb_info;
+	struct net_device *dev;
+	unsigned long event;
+};
+
+static void dsa_slave_switchdev_event_work(struct work_struct *work)
+{
+	struct dsa_switchdev_event_work *switchdev_work =
+		container_of(work, struct dsa_switchdev_event_work, work);
+	struct net_device *dev = switchdev_work->dev;
+	struct switchdev_notifier_fdb_info *fdb_info;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	int err;
+
+	rtnl_lock();
+	switch (switchdev_work->event) {
+	case SWITCHDEV_FDB_ADD_TO_DEVICE:
+		fdb_info = &switchdev_work->fdb_info;
+		err = dsa_port_fdb_add(p->dp, fdb_info->addr, fdb_info->vid);
+		if (err) {
+			netdev_dbg(dev, "fdb add failed err=%d\n", err);
+			break;
+		}
+		call_switchdev_notifiers(SWITCHDEV_FDB_OFFLOADED, dev,
+					 &fdb_info->info);
+		break;
+
+	case SWITCHDEV_FDB_DEL_TO_DEVICE:
+		fdb_info = &switchdev_work->fdb_info;
+		err = dsa_port_fdb_del(p->dp, fdb_info->addr, fdb_info->vid);
+		if (err) {
+			netdev_dbg(dev, "fdb del failed err=%d\n", err);
+			dev_close(dev);
+		}
+		break;
+	}
+	rtnl_unlock();
+
+	kfree(switchdev_work->fdb_info.addr);
+	kfree(switchdev_work);
+	dev_put(dev);
+}
+
+static int
+dsa_slave_switchdev_fdb_work_init(struct dsa_switchdev_event_work *
+				  switchdev_work,
+				  const struct switchdev_notifier_fdb_info *
+				  fdb_info)
+{
+	memcpy(&switchdev_work->fdb_info, fdb_info,
+	       sizeof(switchdev_work->fdb_info));
+	switchdev_work->fdb_info.addr = kzalloc(ETH_ALEN, GFP_ATOMIC);
+	if (!switchdev_work->fdb_info.addr)
+		return -ENOMEM;
+	ether_addr_copy((u8 *)switchdev_work->fdb_info.addr,
+			fdb_info->addr);
+	return 0;
+}
+
+/* Called under rcu_read_lock() */
+static int dsa_slave_switchdev_event(struct notifier_block *unused,
+				     unsigned long event, void *ptr)
+{
+	struct net_device *dev = switchdev_notifier_info_to_dev(ptr);
+	struct dsa_switchdev_event_work *switchdev_work;
+
+	if (!dsa_slave_dev_check(dev))
+		return NOTIFY_DONE;
+
+	switchdev_work = kzalloc(sizeof(*switchdev_work), GFP_ATOMIC);
+	if (!switchdev_work)
+		return NOTIFY_BAD;
+
+	INIT_WORK(&switchdev_work->work,
+		  dsa_slave_switchdev_event_work);
+	switchdev_work->dev = dev;
+	switchdev_work->event = event;
+
+	switch (event) {
+	case SWITCHDEV_FDB_ADD_TO_DEVICE: /* fall through */
+	case SWITCHDEV_FDB_DEL_TO_DEVICE:
+		if (dsa_slave_switchdev_fdb_work_init(switchdev_work,
+						      ptr))
+			goto err_fdb_work_init;
+		dev_hold(dev);
+		break;
+	default:
+		kfree(switchdev_work);
+		return NOTIFY_DONE;
+	}
+
+	dsa_schedule_work(&switchdev_work->work);
+	return NOTIFY_OK;
+
+err_fdb_work_init:
+	kfree(switchdev_work);
+	return NOTIFY_BAD;
+}
+
 static struct notifier_block dsa_slave_nb __read_mostly = {
-	.notifier_call	= dsa_slave_netdevice_event,
+	.notifier_call  = dsa_slave_netdevice_event,
+};
+
+static struct notifier_block dsa_slave_switchdev_notifier = {
+	.notifier_call = dsa_slave_switchdev_event,
 };
 
 int dsa_slave_register_notifier(void)
 {
-	return register_netdevice_notifier(&dsa_slave_nb);
+	int err;
+
+	err = register_netdevice_notifier(&dsa_slave_nb);
+	if (err)
+		return err;
+
+	err = register_switchdev_notifier(&dsa_slave_switchdev_notifier);
+	if (err)
+		goto err_switchdev_nb;
+
+	return 0;
+
+err_switchdev_nb:
+	unregister_netdevice_notifier(&dsa_slave_nb);
+	return err;
 }
 
 void dsa_slave_unregister_notifier(void)
 {
 	int err;
 
+	err = unregister_netdevice_notifier(&dsa_slave_switchdev_notifier);
+	if (err)
+		pr_err("DSA: failed to unregister switchdev notifier (%d)\n", err);
+
 	err = unregister_netdevice_notifier(&dsa_slave_nb);
 	if (err)
 		pr_err("DSA: failed to unregister slave notifier (%d)\n", err);
-- 
2.4.11
