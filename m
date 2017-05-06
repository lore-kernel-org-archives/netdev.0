From: David Ahern <dsahern@gmail.com>
Subject: [PATCH RFC net-next 1/6] net: Add accessor for kboject in a net_device
Date: Sat,  6 May 2017 10:07:29 -0600
Message-ID: <20170506160734.47084-2-dsahern@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36401 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdEFQHn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:07:43 -0400
Received: by mail-pg0-f68.google.com with SMTP id q4so1319069pga.3
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:07:42 -0700 (PDT)
In-Reply-To: <20170506160734.47084-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h |  5 +++++
 net/batman-adv/sysfs.c    | 13 +++++++++--
 net/bridge/br_if.c        | 12 ++++++----
 net/bridge/br_sysfs_br.c  | 17 +++++++++-----
 net/bridge/br_sysfs_if.c  |  8 +++++--
 net/core/dev.c            | 57 ++++++++++++++++++++++++++++++++++-------------
 net/core/net-sysfs.c      | 11 +++++----
 net/wireless/core.c       | 15 +++++++++----
 8 files changed, 100 insertions(+), 38 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9c23bd2efb56..305d2d42b349 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4272,6 +4272,11 @@ static inline const char *netdev_reg_state(const struct net_device *dev)
 	return " (unknown)";
 }
 
+static inline struct kobject *netdev_kobject(struct net_device *dev)
+{
+	return &dev->dev.kobj;
+}
+
 __printf(3, 4)
 void netdev_printk(const char *level, const struct net_device *dev,
 		   const char *format, ...);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 0ae8b30e4eaa..a8a7294fc054 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -735,11 +735,14 @@ static struct batadv_attribute *batadv_vlan_attrs[] = {
 
 int batadv_sysfs_add_meshif(struct net_device *dev)
 {
-	struct kobject *batif_kobject = &dev->dev.kobj;
+	struct kobject *batif_kobject = netdev_kobject(dev);
 	struct batadv_priv *bat_priv = netdev_priv(dev);
 	struct batadv_attribute **bat_attr;
 	int err;
 
+	if (!batif_kobject)
+		return 0;
+
 	bat_priv->mesh_obj = kobject_create_and_add(BATADV_SYSFS_IF_MESH_SUBDIR,
 						    batif_kobject);
 	if (!bat_priv->mesh_obj) {
@@ -778,6 +781,9 @@ void batadv_sysfs_del_meshif(struct net_device *dev)
 	struct batadv_priv *bat_priv = netdev_priv(dev);
 	struct batadv_attribute **bat_attr;
 
+	if (!bat_priv->mesh_obj)
+		return;
+
 	for (bat_attr = batadv_mesh_attrs; *bat_attr; ++bat_attr)
 		sysfs_remove_file(bat_priv->mesh_obj, &((*bat_attr)->attr));
 
@@ -1132,10 +1138,13 @@ static struct batadv_attribute *batadv_batman_attrs[] = {
 
 int batadv_sysfs_add_hardif(struct kobject **hardif_obj, struct net_device *dev)
 {
-	struct kobject *hardif_kobject = &dev->dev.kobj;
+	struct kobject *hardif_kobject = netdev_kobject(dev);
 	struct batadv_attribute **bat_attr;
 	int err;
 
+	if (!hardif_kobject)
+		return 0;
+
 	*hardif_obj = kobject_create_and_add(BATADV_SYSFS_IF_BAT_SUBDIR,
 					     hardif_kobject);
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 7f8d05cf9065..a5354436ada8 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -485,6 +485,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	struct net_bridge_port *p;
 	int err = 0;
 	unsigned br_hr, dev_hr;
+	struct kobject *kobj;
 	bool changed_addr;
 
 	/* Don't allow bridging non-ethernet like devices, or DSA-enabled
@@ -521,10 +522,13 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto put_back;
 
-	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
-				   SYSFS_BRIDGE_PORT_ATTR);
-	if (err)
-		goto err1;
+	kobj = netdev_kobject(dev);
+	if (kobj) {
+		err = kobject_init_and_add(&p->kobj, &brport_ktype, kobj,
+					   SYSFS_BRIDGE_PORT_ATTR);
+		if (err)
+			goto err1;
+	}
 
 	err = br_sysfs_addif(p);
 	if (err)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 0b5dd607444c..f6439664ffea 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -917,10 +917,13 @@ static struct bin_attribute bridge_forward = {
  */
 int br_sysfs_addbr(struct net_device *dev)
 {
-	struct kobject *brobj = &dev->dev.kobj;
+	struct kobject *brobj = netdev_kobject(dev);
 	struct net_bridge *br = netdev_priv(dev);
 	int err;
 
+	if (!brobj)
+		return 0;
+
 	err = sysfs_create_group(brobj, &bridge_group);
 	if (err) {
 		pr_info("%s: can't create group %s/%s\n",
@@ -944,9 +947,9 @@ int br_sysfs_addbr(struct net_device *dev)
 	}
 	return 0;
  out3:
-	sysfs_remove_bin_file(&dev->dev.kobj, &bridge_forward);
+	sysfs_remove_bin_file(brobj, &bridge_forward);
  out2:
-	sysfs_remove_group(&dev->dev.kobj, &bridge_group);
+	sysfs_remove_group(brobj, &bridge_group);
  out1:
 	return err;
 
@@ -954,10 +957,12 @@ int br_sysfs_addbr(struct net_device *dev)
 
 void br_sysfs_delbr(struct net_device *dev)
 {
-	struct kobject *kobj = &dev->dev.kobj;
+	struct kobject *kobj = netdev_kobject(dev);
 	struct net_bridge *br = netdev_priv(dev);
 
 	kobject_put(br->ifobj);
-	sysfs_remove_bin_file(kobj, &bridge_forward);
-	sysfs_remove_group(kobj, &bridge_group);
+	if (kobj) {
+		sysfs_remove_bin_file(kobj, &bridge_forward);
+		sysfs_remove_group(kobj, &bridge_group);
+	}
 }
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 5d5d413a6cf8..4256e78f6c9f 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -283,10 +283,14 @@ int br_sysfs_addif(struct net_bridge_port *p)
 {
 	struct net_bridge *br = p->br;
 	const struct brport_attribute **a;
+	struct kobject *br_kobj;
 	int err;
 
-	err = sysfs_create_link(&p->kobj, &br->dev->dev.kobj,
-				SYSFS_BRIDGE_PORT_LINK);
+	br_kobj = netdev_kobject(br->dev);
+	if (!br_kobj)
+		return 0;
+
+	err = sysfs_create_link(&p->kobj, br_kobj, SYSFS_BRIDGE_PORT_LINK);
 	if (err)
 		return err;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index d07aa5ffb511..f166b3bf1895 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5910,22 +5910,33 @@ static int netdev_adjacent_sysfs_add(struct net_device *dev,
 			      struct net_device *adj_dev,
 			      struct list_head *dev_list)
 {
+	struct kobject *dev_kobj, *adj_kobj;
 	char linkname[IFNAMSIZ+7];
+	int rc = 0;
 
-	sprintf(linkname, dev_list == &dev->adj_list.upper ?
-		"upper_%s" : "lower_%s", adj_dev->name);
-	return sysfs_create_link(&(dev->dev.kobj), &(adj_dev->dev.kobj),
-				 linkname);
+	dev_kobj = netdev_kobject(dev);
+	adj_kobj = netdev_kobject(adj_dev);
+
+	if (dev_kobj && adj_kobj) {
+		sprintf(linkname, dev_list == &dev->adj_list.upper ?
+			"upper_%s" : "lower_%s", adj_dev->name);
+		rc = sysfs_create_link(dev_kobj, adj_kobj, linkname);
+	}
+	return rc;
 }
+
 static void netdev_adjacent_sysfs_del(struct net_device *dev,
 			       char *name,
 			       struct list_head *dev_list)
 {
+	struct kobject *kobj = netdev_kobject(dev);
 	char linkname[IFNAMSIZ+7];
 
-	sprintf(linkname, dev_list == &dev->adj_list.upper ?
-		"upper_%s" : "lower_%s", name);
-	sysfs_remove_link(&(dev->dev.kobj), linkname);
+	if (kobj) {
+		sprintf(linkname, dev_list == &dev->adj_list.upper ?
+			"upper_%s" : "lower_%s", name);
+		sysfs_remove_link(kobj, linkname);
+	}
 }
 
 static inline bool netdev_adjacent_is_neigh_list(struct net_device *dev,
@@ -5976,11 +5987,14 @@ static int __netdev_adjacent_dev_insert(struct net_device *dev,
 
 	/* Ensure that master link is always the first item in list. */
 	if (master) {
-		ret = sysfs_create_link(&(dev->dev.kobj),
-					&(adj_dev->dev.kobj), "master");
-		if (ret)
-			goto remove_symlinks;
+		struct kobject *dev_kobj = netdev_kobject(dev);
+		struct kobject *adj_kobj = netdev_kobject(adj_dev);
 
+		if (dev_kobj && adj_kobj) {
+			ret = sysfs_create_link(dev_kobj, adj_kobj, "master");
+			if (ret)
+				goto remove_symlinks;
+		}
 		list_add_rcu(&adj->list, dev_list);
 	} else {
 		list_add_tail_rcu(&adj->list, dev_list);
@@ -6025,8 +6039,12 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 		return;
 	}
 
-	if (adj->master)
-		sysfs_remove_link(&(dev->dev.kobj), "master");
+	if (adj->master) {
+		struct kobject *kobj = netdev_kobject(dev);
+
+		if (kobj)
+			sysfs_remove_link(kobj, "master");
+	}
 
 	if (netdev_adjacent_is_neigh_list(dev, adj_dev, dev_list))
 		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
@@ -7665,6 +7683,7 @@ void netdev_run_todo(void)
 		rcu_barrier();
 
 	while (!list_empty(&list)) {
+		struct kobject *kobj;
 		struct net_device *dev
 			= list_first_entry(&list, struct net_device, todo_list);
 		list_del(&dev->todo_list);
@@ -7702,7 +7721,9 @@ void netdev_run_todo(void)
 		wake_up(&netdev_unregistering_wq);
 
 		/* Free network device */
-		kobject_put(&dev->dev.kobj);
+		kobj = netdev_kobject(dev);
+		if (kobj)
+			kobject_put(kobj);
 	}
 }
 
@@ -8071,6 +8092,7 @@ EXPORT_SYMBOL(unregister_netdev);
 
 int dev_change_net_namespace(struct net_device *dev, struct net *net, const char *pat)
 {
+	struct kobject *kobj;
 	int err;
 
 	ASSERT_RTNL();
@@ -8136,7 +8158,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_mc_flush(dev);
 
 	/* Send a netdev-removed uevent to the old namespace */
-	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
+	kobj = netdev_kobject(dev);
+	if (kobj)
+		kobject_uevent(kobj, KOBJ_REMOVE);
 	netdev_adjacent_del_links(dev);
 
 	/* Actually switch the network namespace */
@@ -8147,7 +8171,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 		dev->ifindex = dev_new_index(net);
 
 	/* Send a netdev-add uevent to the new namespace */
-	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
+	if (kobj)
+		kobject_uevent(kobj, KOBJ_ADD);
 	netdev_adjacent_add_links(dev);
 
 	/* Fixup kobjects */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 65ea0ff4017c..9df53b688f5b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1390,10 +1390,13 @@ static int register_queue_kobjects(struct net_device *dev)
 	int error = 0, txq = 0, rxq = 0, real_rx = 0, real_tx = 0;
 
 #ifdef CONFIG_SYSFS
-	dev->queues_kset = kset_create_and_add("queues",
-	    NULL, &dev->dev.kobj);
-	if (!dev->queues_kset)
-		return -ENOMEM;
+	struct kobject *kobj = netdev_kobject(dev);
+
+	if (kobj) {
+		dev->queues_kset = kset_create_and_add("queues", NULL, kobj);
+		if (!dev->queues_kset)
+			return -ENOMEM;
+	}
 	real_rx = dev->real_num_rx_queues;
 #endif
 	real_tx = dev->real_num_tx_queues;
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 83ea164f16b3..a73b3efc17b2 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -1122,6 +1122,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 	struct cfg80211_registered_device *rdev;
 	struct cfg80211_sched_scan_request *pos, *tmp;
+	struct kobject *kobj;
 
 	if (!wdev)
 		return NOTIFY_DONE;
@@ -1160,9 +1161,12 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 		/* can only change netns with wiphy */
 		dev->features |= NETIF_F_NETNS_LOCAL;
 
-		if (sysfs_create_link(&dev->dev.kobj, &rdev->wiphy.dev.kobj,
-				      "phy80211")) {
-			pr_err("failed to add phy80211 symlink to netdev!\n");
+		kobj = netdev_kobject(dev);
+		if (kobj) {
+			if (sysfs_create_link(kobj, &rdev->wiphy.dev.kobj,
+					      "phy80211")) {
+				pr_err("failed to add phy80211 symlink to netdev!\n");
+			}
 		}
 		wdev->netdev = dev;
 #ifdef CONFIG_CFG80211_WEXT
@@ -1264,9 +1268,12 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 		 * remove and clean it up.
 		 */
 		if (!list_empty(&wdev->list)) {
+			struct kobject *kobj = netdev_kobject(dev);
+
 			nl80211_notify_iface(rdev, wdev,
 					     NL80211_CMD_DEL_INTERFACE);
-			sysfs_remove_link(&dev->dev.kobj, "phy80211");
+			if (kobj)
+				sysfs_remove_link(kobj, "phy80211");
 			list_del_rcu(&wdev->list);
 			rdev->devlist_generation++;
 			cfg80211_mlme_purge_registrations(wdev);
-- 
2.11.0 (Apple Git-81)
