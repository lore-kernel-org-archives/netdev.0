From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] net: replace br_fdb_external_learn_* calls with switchdev notifier events
Date: Thu, 15 Jan 2015 23:49:37 +0100
Message-ID: <1421362177-10719-2-git-send-email-jiri@resnulli.us>
References: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, sfeldma@gmail.co,
	stephen@networkplumber.org, linus.luessing@web.de, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:63927 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338AbbAOWtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 17:49:41 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so514958wiw.3
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 14:49:40 -0800 (PST)
In-Reply-To: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch benefits from newly introduced switchdev notifier and uses it
to propagate fdb learn events from rocker driver to bridge. That avoids
direct function calls and possible use by other listeners (ovs).

Suggested-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 10 +++++--
 include/linux/if_bridge.h            | 18 -------------
 include/net/switchdev.h              | 11 ++++++++
 net/bridge/br.c                      | 52 +++++++++++++++++++++++++++++++++++-
 net/bridge/br_fdb.c                  | 38 +++-----------------------
 net/bridge/br_private.h              |  4 +++
 6 files changed, 78 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index cad8cf9..964d719 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3026,11 +3026,17 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		container_of(work, struct rocker_fdb_learn_work, work);
 	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
 	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
+	struct netdev_switch_notifier_fdb_info info;
+
+	info.addr = lw->addr;
+	info.vid = lw->vid;
 
 	if (learned && removing)
-		br_fdb_external_learn_del(lw->dev, lw->addr, lw->vid);
+		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL,
+					     lw->dev, &info.info);
 	else if (learned && !removing)
-		br_fdb_external_learn_add(lw->dev, lw->addr, lw->vid);
+		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_ADD,
+					     lw->dev, &info.info);
 
 	kfree(work);
 }
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 0a8ce76..a57bca2 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -50,24 +50,6 @@ extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __use
 typedef int br_should_route_hook_t(struct sk_buff *skb);
 extern br_should_route_hook_t __rcu *br_should_route_hook;
 
-#if IS_ENABLED(CONFIG_BRIDGE)
-int br_fdb_external_learn_add(struct net_device *dev,
-			      const unsigned char *addr, u16 vid);
-int br_fdb_external_learn_del(struct net_device *dev,
-			      const unsigned char *addr, u16 vid);
-#else
-static inline int br_fdb_external_learn_add(struct net_device *dev,
-					    const unsigned char *addr, u16 vid)
-{
-	return 0;
-}
-static inline int br_fdb_external_learn_del(struct net_device *dev,
-					    const unsigned char *addr, u16 vid)
-{
-	return 0;
-}
-#endif
-
 #if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_IGMP_SNOOPING)
 int br_multicast_list_adjacent(struct net_device *dev,
 			       struct list_head *br_ip_list);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 7f8d743..201120e 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -13,10 +13,21 @@
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 
+enum netdev_switch_notifier_type {
+	NETDEV_SWITCH_FDB_ADD = 1,
+	NETDEV_SWITCH_FDB_DEL,
+};
+
 struct netdev_switch_notifier_info {
 	struct net_device *dev;
 };
 
+struct netdev_switch_notifier_fdb_info {
+	struct netdev_switch_notifier_info info; /* must be first */
+	const unsigned char *addr;
+	u16 vid;
+};
+
 static inline struct net_device *
 netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *info)
 {
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 44425af..fb57ab6 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -19,6 +19,7 @@
 #include <linux/llc.h>
 #include <net/llc.h>
 #include <net/stp.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 
@@ -120,6 +121,48 @@ static struct notifier_block br_device_notifier = {
 	.notifier_call = br_device_event
 };
 
+static int br_netdev_switch_event(struct notifier_block *unused,
+				  unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_switch_notifier_info_to_dev(ptr);
+	struct net_bridge_port *p;
+	struct net_bridge *br;
+	struct netdev_switch_notifier_fdb_info *fdb_info;
+	int err = NOTIFY_DONE;
+
+	rtnl_lock();
+	p = br_port_get_rtnl(dev);
+	if (!p)
+		goto out;
+
+	br = p->br;
+
+	switch (event) {
+	case NETDEV_SWITCH_FDB_ADD:
+		fdb_info = ptr;
+		err = br_fdb_external_learn_add(br, p, fdb_info->addr,
+						fdb_info->vid);
+		if (err)
+			err = notifier_from_errno(err);
+		break;
+	case NETDEV_SWITCH_FDB_DEL:
+		fdb_info = ptr;
+		err = br_fdb_external_learn_del(br, p, fdb_info->addr,
+						fdb_info->vid);
+		if (err)
+			err = notifier_from_errno(err);
+		break;
+	}
+
+out:
+	rtnl_unlock();
+	return err;
+}
+
+static struct notifier_block br_netdev_switch_notifier = {
+	.notifier_call = br_netdev_switch_event,
+};
+
 static void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
@@ -169,10 +212,14 @@ static int __init br_init(void)
 	if (err)
 		goto err_out3;
 
-	err = br_netlink_init();
+	err = register_netdev_switch_notifier(&br_netdev_switch_notifier);
 	if (err)
 		goto err_out4;
 
+	err = br_netlink_init();
+	if (err)
+		goto err_out5;
+
 	brioctl_set(br_ioctl_deviceless_stub);
 
 #if IS_ENABLED(CONFIG_ATM_LANE)
@@ -185,6 +232,8 @@ static int __init br_init(void)
 
 	return 0;
 
+err_out5:
+	unregister_netdev_switch_notifier(&br_netdev_switch_notifier);
 err_out4:
 	unregister_netdevice_notifier(&br_device_notifier);
 err_out3:
@@ -202,6 +251,7 @@ static void __exit br_deinit(void)
 {
 	stp_proto_unregister(&br_stp_proto);
 	br_netlink_fini();
+	unregister_netdev_switch_notifier(&br_netdev_switch_notifier);
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
 	unregister_pernet_subsys(&br_net_ops);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e6e0372..03667e6 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -990,26 +990,14 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
 	}
 }
 
-int br_fdb_external_learn_add(struct net_device *dev,
+int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid)
 {
-	struct net_bridge_port *p;
-	struct net_bridge *br;
 	struct hlist_head *head;
 	struct net_bridge_fdb_entry *fdb;
 	int err = 0;
 
-	rtnl_lock();
-
-	p = br_port_get_rtnl(dev);
-	if (!p) {
-		pr_info("bridge: %s not a bridge port\n", dev->name);
-		err = -EINVAL;
-		goto err_rtnl_unlock;
-	}
-
-	br = p->br;
-
+	ASSERT_RTNL();
 	spin_lock_bh(&br->hash_lock);
 
 	head = &br->hash[br_mac_hash(addr, vid)];
@@ -1034,33 +1022,18 @@ int br_fdb_external_learn_add(struct net_device *dev,
 
 err_unlock:
 	spin_unlock_bh(&br->hash_lock);
-err_rtnl_unlock:
-	rtnl_unlock();
 
 	return err;
 }
-EXPORT_SYMBOL(br_fdb_external_learn_add);
 
-int br_fdb_external_learn_del(struct net_device *dev,
+int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid)
 {
-	struct net_bridge_port *p;
-	struct net_bridge *br;
 	struct hlist_head *head;
 	struct net_bridge_fdb_entry *fdb;
 	int err = 0;
 
-	rtnl_lock();
-
-	p = br_port_get_rtnl(dev);
-	if (!p) {
-		pr_info("bridge: %s not a bridge port\n", dev->name);
-		err = -EINVAL;
-		goto err_rtnl_unlock;
-	}
-
-	br = p->br;
-
+	ASSERT_RTNL();
 	spin_lock_bh(&br->hash_lock);
 
 	head = &br->hash[br_mac_hash(addr, vid)];
@@ -1071,9 +1044,6 @@ int br_fdb_external_learn_del(struct net_device *dev,
 		err = -ENOENT;
 
 	spin_unlock_bh(&br->hash_lock);
-err_rtnl_unlock:
-	rtnl_unlock();
 
 	return err;
 }
-EXPORT_SYMBOL(br_fdb_external_learn_del);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d808d76..e8e3f36 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -402,6 +402,10 @@ int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		struct net_device *dev, struct net_device *fdev, int idx);
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
+int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
+			      const unsigned char *addr, u16 vid);
+int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
+			      const unsigned char *addr, u16 vid);
 
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
-- 
1.9.3
