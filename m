From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 04/17] batman-adv: Create batman soft interfaces within correct netns.
Date: Wed, 11 May 2016 03:29:52 +0800
Message-ID: <1462908605-27412-5-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:27304 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917AbcEJTbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:31:04 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

When creating a soft interface, create it in the same netns as the
hard interface. Replace all references to init_net with the correct
name space for the interface being manipulated.

Suggested-by: Daniel Ehlers <danielehlers@mindeye.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/hard-interface.c    | 10 +++++-----
 net/batman-adv/hard-interface.h    |  3 ++-
 net/batman-adv/soft-interface.c    |  7 +++++--
 net/batman-adv/soft-interface.h    |  3 ++-
 net/batman-adv/sysfs.c             |  3 ++-
 net/batman-adv/translation-table.c |  4 ++--
 6 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 0a7deaf2670a..f0e1899e5b6b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -36,7 +36,6 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
-#include <net/net_namespace.h>
 
 #include "bridge_loop_avoidance.h"
 #include "debugfs.h"
@@ -121,6 +120,7 @@ static bool batadv_mutual_parents(const struct net_device *dev1,
 static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 {
 	struct net_device *parent_dev;
+	struct net *net = dev_net(net_dev);
 	bool ret;
 
 	/* check if this is a batman-adv mesh interface */
@@ -133,7 +133,7 @@ static bool batadv_is_on_batman_iface(const struct net_device *net_dev)
 		return false;
 
 	/* recurse over the parent device */
-	parent_dev = __dev_get_by_index(&init_net, dev_get_iflink(net_dev));
+	parent_dev = __dev_get_by_index(net, dev_get_iflink(net_dev));
 	/* if we got a NULL parent_dev there is something broken.. */
 	if (WARN(!parent_dev, "Cannot find parent device"))
 		return false;
@@ -456,7 +456,7 @@ static int batadv_master_del_slave(struct batadv_hard_iface *slave,
 }
 
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
-				   const char *iface_name)
+				   struct net *net, const char *iface_name)
 {
 	struct batadv_priv *bat_priv;
 	struct net_device *soft_iface, *master;
@@ -470,10 +470,10 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	if (!kref_get_unless_zero(&hard_iface->refcount))
 		goto out;
 
-	soft_iface = dev_get_by_name(&init_net, iface_name);
+	soft_iface = dev_get_by_name(net, iface_name);
 
 	if (!soft_iface) {
-		soft_iface = batadv_softif_create(iface_name);
+		soft_iface = batadv_softif_create(net, iface_name);
 
 		if (!soft_iface) {
 			ret = -ENOMEM;
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index d74f1983f33e..a76724d369bf 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -28,6 +28,7 @@
 #include <linux/types.h>
 
 struct net_device;
+struct net;
 
 enum batadv_hard_if_state {
 	BATADV_IF_NOT_IN_USE,
@@ -55,7 +56,7 @@ bool batadv_is_wifi_iface(int ifindex);
 struct batadv_hard_iface*
 batadv_hardif_get_by_netdev(const struct net_device *net_dev);
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
-				   const char *iface_name);
+				   struct net *net, const char *iface_name);
 void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 				     enum batadv_hard_if_cleanup autodel);
 void batadv_hardif_remove_interfaces(void);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 66dd0aac480a..04866c9b860a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -885,13 +885,14 @@ static int batadv_softif_slave_add(struct net_device *dev,
 				   struct net_device *slave_dev)
 {
 	struct batadv_hard_iface *hard_iface;
+	struct net *net = dev_net(dev);
 	int ret = -EINVAL;
 
 	hard_iface = batadv_hardif_get_by_netdev(slave_dev);
 	if (!hard_iface || hard_iface->soft_iface)
 		goto out;
 
-	ret = batadv_hardif_enable_interface(hard_iface, dev->name);
+	ret = batadv_hardif_enable_interface(hard_iface, net, dev->name);
 
 out:
 	if (hard_iface)
@@ -988,7 +989,7 @@ static void batadv_softif_init_early(struct net_device *dev)
 	memset(priv, 0, sizeof(*priv));
 }
 
-struct net_device *batadv_softif_create(const char *name)
+struct net_device *batadv_softif_create(struct net *net, const char *name)
 {
 	struct net_device *soft_iface;
 	int ret;
@@ -998,6 +999,8 @@ struct net_device *batadv_softif_create(const char *name)
 	if (!soft_iface)
 		return NULL;
 
+	dev_net_set(soft_iface, net);
+
 	soft_iface->rtnl_link_ops = &batadv_link_ops;
 
 	ret = register_netdevice(soft_iface);
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 5942da3d03d5..b0966342a986 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -23,13 +23,14 @@
 #include <net/rtnetlink.h>
 
 struct net_device;
+struct net;
 struct sk_buff;
 
 int batadv_skb_head_push(struct sk_buff *skb, unsigned int len);
 void batadv_interface_rx(struct net_device *soft_iface,
 			 struct sk_buff *skb, int hdr_size,
 			 struct batadv_orig_node *orig_node);
-struct net_device *batadv_softif_create(const char *name);
+struct net_device *batadv_softif_create(struct net *net, const char *name);
 void batadv_softif_destroy_sysfs(struct net_device *soft_iface);
 int batadv_softif_is_valid(const struct net_device *net_dev);
 extern struct rtnl_link_ops batadv_link_ops;
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index e7cf51333a36..6b1e54f3250a 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -830,6 +830,7 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 				       size_t count)
 {
 	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
+	struct net *net = dev_net(net_dev);
 	struct batadv_hard_iface *hard_iface;
 	int status_tmp = -1;
 	int ret = count;
@@ -873,7 +874,7 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 		batadv_hardif_disable_interface(hard_iface,
 						BATADV_IF_CLEANUP_AUTO);
 
-	ret = batadv_hardif_enable_interface(hard_iface, buff);
+	ret = batadv_hardif_enable_interface(hard_iface, net, buff);
 
 unlock:
 	rtnl_unlock();
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 942b3aa00bed..6ea6e9bf9a8c 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -43,7 +43,6 @@
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/workqueue.h>
-#include <net/net_namespace.h>
 
 #include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
@@ -585,6 +584,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	struct batadv_tt_local_entry *tt_local;
 	struct batadv_tt_global_entry *tt_global = NULL;
+	struct net *net = dev_net(soft_iface);
 	struct batadv_softif_vlan *vlan;
 	struct net_device *in_dev = NULL;
 	struct hlist_head *head;
@@ -596,7 +596,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	u32 match_mark;
 
 	if (ifindex != BATADV_NULL_IFINDEX)
-		in_dev = dev_get_by_index(&init_net, ifindex);
+		in_dev = dev_get_by_index(net, ifindex);
 
 	tt_local = batadv_tt_local_hash_find(bat_priv, addr, vid);
 
-- 
2.8.2
