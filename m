From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 05/19] batman-adv: Modify mesh_iface outside sysfs context
Date: Fri, 12 Aug 2016 10:56:41 +0200
Message-ID: <1470992215-11009-6-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:34976 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbcHLI5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:15 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The legacy sysfs interface to modify interfaces belonging to batman-adv
is run inside a region holding s_lock. And to add a net_device, it has
to also get the rtnl_lock. This is exactly the other way around than in
other virtual net_devices and conflicts with netdevice notifier which
executes inside rtnl_lock.

The inverted lock situation is currently solved by executing the removal
of netdevices via workqueue. The workqueue isn't executed inside
rtnl_lock and thus can independently get the s_lock and the rtnl_lock.

But this workaround fails when the netdevice notifier creates events in
quick succession and the earlier triggered removal of a net_device isn't
processed in the workqueue before the adding of the new netdevice (with
same name) event is issued.

Instead the legacy sysfs interface store events have to be enqueued in
a workqueue to loose the s_lock. The worker is then free to get the
required locks and the deadlock is avoided.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/sysfs.c | 107 +++++++++++++++++++++++++++++++++++++------------
 net/batman-adv/types.h |  13 ++++++
 2 files changed, 94 insertions(+), 26 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index fe9ca94..8528959 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -37,6 +37,7 @@
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/stringify.h>
+#include <linux/workqueue.h>
 
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
@@ -828,31 +829,31 @@ static ssize_t batadv_show_mesh_iface(struct kobject *kobj,
 	return length;
 }
 
-static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
-				       struct attribute *attr, char *buff,
-				       size_t count)
+/**
+ * batadv_store_mesh_iface_finish - store new hardif mesh_iface state
+ * @net_dev: netdevice to add/remove to/from batman-adv soft-interface
+ * @ifname: name of soft-interface to modify
+ *
+ * Changes the parts of the hard+soft interface which can not be modified under
+ * sysfs lock (to prevent deadlock situations).
+ *
+ * Return: 0 on success, 0 < on failure
+ */
+static int batadv_store_mesh_iface_finish(struct net_device *net_dev,
+					  char ifname[IFNAMSIZ])
 {
-	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
 	struct net *net = dev_net(net_dev);
 	struct batadv_hard_iface *hard_iface;
-	int status_tmp = -1;
-	int ret = count;
+	int status_tmp;
+	int ret = 0;
+
+	ASSERT_RTNL();
 
 	hard_iface = batadv_hardif_get_by_netdev(net_dev);
 	if (!hard_iface)
-		return count;
-
-	if (buff[count - 1] == '\n')
-		buff[count - 1] = '\0';
-
-	if (strlen(buff) >= IFNAMSIZ) {
-		pr_err("Invalid parameter for 'mesh_iface' setting received: interface name too long '%s'\n",
-		       buff);
-		batadv_hardif_put(hard_iface);
-		return -EINVAL;
-	}
+		return 0;
 
-	if (strncmp(buff, "none", 4) == 0)
+	if (strncmp(ifname, "none", 4) == 0)
 		status_tmp = BATADV_IF_NOT_IN_USE;
 	else
 		status_tmp = BATADV_IF_I_WANT_YOU;
@@ -861,15 +862,13 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 		goto out;
 
 	if ((hard_iface->soft_iface) &&
-	    (strncmp(hard_iface->soft_iface->name, buff, IFNAMSIZ) == 0))
+	    (strncmp(hard_iface->soft_iface->name, ifname, IFNAMSIZ) == 0))
 		goto out;
 
-	rtnl_lock();
-
 	if (status_tmp == BATADV_IF_NOT_IN_USE) {
 		batadv_hardif_disable_interface(hard_iface,
 						BATADV_IF_CLEANUP_AUTO);
-		goto unlock;
+		goto out;
 	}
 
 	/* if the interface already is in use */
@@ -877,15 +876,71 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 		batadv_hardif_disable_interface(hard_iface,
 						BATADV_IF_CLEANUP_AUTO);
 
-	ret = batadv_hardif_enable_interface(hard_iface, net, buff);
-
-unlock:
-	rtnl_unlock();
+	ret = batadv_hardif_enable_interface(hard_iface, net, ifname);
 out:
 	batadv_hardif_put(hard_iface);
 	return ret;
 }
 
+/**
+ * batadv_store_mesh_iface_work - store new hardif mesh_iface state
+ * @work: work queue item
+ *
+ * Changes the parts of the hard+soft interface which can not be modified under
+ * sysfs lock (to prevent deadlock situations).
+ */
+static void batadv_store_mesh_iface_work(struct work_struct *work)
+{
+	struct batadv_store_mesh_work *store_work;
+	int ret;
+
+	store_work = container_of(work, struct batadv_store_mesh_work, work);
+
+	rtnl_lock();
+	ret = batadv_store_mesh_iface_finish(store_work->net_dev,
+					     store_work->soft_iface_name);
+	rtnl_unlock();
+
+	if (ret < 0)
+		pr_err("Failed to store new mesh_iface state %s for %s: %d\n",
+		       store_work->soft_iface_name, store_work->net_dev->name,
+		       ret);
+
+	dev_put(store_work->net_dev);
+	kfree(store_work);
+}
+
+static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
+				       struct attribute *attr, char *buff,
+				       size_t count)
+{
+	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
+	struct batadv_store_mesh_work *store_work;
+
+	if (buff[count - 1] == '\n')
+		buff[count - 1] = '\0';
+
+	if (strlen(buff) >= IFNAMSIZ) {
+		pr_err("Invalid parameter for 'mesh_iface' setting received: interface name too long '%s'\n",
+		       buff);
+		return -EINVAL;
+	}
+
+	store_work = kmalloc(sizeof(*store_work), GFP_KERNEL);
+	if (!store_work)
+		return -ENOMEM;
+
+	dev_hold(net_dev);
+	INIT_WORK(&store_work->work, batadv_store_mesh_iface_work);
+	store_work->net_dev = net_dev;
+	strlcpy(store_work->soft_iface_name, buff,
+		sizeof(store_work->soft_iface_name));
+
+	queue_work(batadv_event_workqueue, &store_work->work);
+
+	return count;
+}
+
 static ssize_t batadv_show_iface_status(struct kobject *kobj,
 					struct attribute *attr, char *buff)
 {
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 0ede27a..23c9577 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1566,4 +1566,17 @@ enum batadv_tvlv_handler_flags {
 	BATADV_TVLV_HANDLER_OGM_CALLED = BIT(2),
 };
 
+/**
+ * struct batadv_store_mesh_work - Work queue item to detach add/del interface
+ *  from sysfs locks
+ * @net_dev: netdevice to add/remove to/from batman-adv soft-interface
+ * @soft_iface_name: name of soft-interface to modify
+ * @work: work queue item
+ */
+struct batadv_store_mesh_work {
+	struct net_device *net_dev;
+	char soft_iface_name[IFNAMSIZ];
+	struct work_struct work;
+};
+
 #endif /* _NET_BATMAN_ADV_TYPES_H_ */
-- 
2.8.1
