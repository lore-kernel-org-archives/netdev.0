From: sfeldma@gmail.com
Subject: [PATCH net-next v2 2/4] net: add IPv4 routing FIB support for switchdev
Date: Mon,  2 Mar 2015 02:06:15 -0800
Message-ID: <1425290777-22702-3-git-send-email-sfeldma@gmail.com>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:38944 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbbCBKFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 05:05:24 -0500
Received: by pdjy10 with SMTP id y10so38499937pdj.6
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 02:05:23 -0800 (PST)
In-Reply-To: <1425290777-22702-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add two new ndo ops (ndo_switch_fib_ipv4_add/del) for switchdev devices
capable of offloading IPv4 L3 routing function from the kernel.  The ops are
called by the core IPv4 FIB code when installing/removing/modifying FIB entries
in the kernel FIB.  On install/modify, the driver should return 0 if FIB entry
(route) can be installed/modified to device; -EOPNOTSUPP if route cannot be
installed/modified due to device limitations; and any other negative error code
on failure to install route to device.  On failure error code, the route is not
installed to device, and not installed in kernel FIB, and the return code is
propagated back to the user-space caller (via netlink).  An -EOPNOTSUPP error
code is skipped for the device but installed in the kernel FIB.

The FIB entry (route) nexthop list is used to find the switchdev netdev to
anchor the ndo op call.  The route's fib_dev (the first nexthop's dev) is used
find the switchdev netdev by recursively traversing the fib_dev's lower_dev
list until a switchdev netdev is found.  The ndo op is called on this switchdev
netdev.  This downward traversal is necessary for switchdev ports stacked under
bonds and/or bridges, where the bond or bridge has the L3 interface.

Thw switchdev driver can monitor netevent notifier NETEVENT_NEIGH_UPDATE to
know neighbor IP addresses which are resolved to a MAC address.  In the case
where the route's nexthops list contains unresolved neighbor IP addresses, the
driver can ask the kernel to resolve the neighbor.  As route nexthops are
resolved, the driver has enough information to program the device for
L3 forwarding offload.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |   22 +++++++++++
 include/net/switchdev.h   |   19 +++++++++
 net/ipv4/fib_trie.c       |   33 ++++++++++++++--
 net/switchdev/switchdev.c |   95 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 166 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5897b4e..73b2766 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -769,6 +769,8 @@ struct netdev_phys_item_id {
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
+struct fib_info;
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1032,6 +1034,14 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
  *	Called to notify switch device port of bridge port STP
  *	state change.
+ * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be32 dst,
+ *				     int dst_len, struct fib_info *fi,
+ *				     u8 tos, u8 type, u32 tb_id);
+ *	Called to add/modify IPv4 route to switch device.
+ * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be32 dst,
+ *				     int dst_len, struct fib_info *fi,
+ *				     u8 tos, u8 type, u32 tb_id);
+ *	Called to delete IPv4 route from switch device.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1193,6 +1203,18 @@ struct net_device_ops {
 							    struct netdev_phys_item_id *psid);
 	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
 							      u8 state);
+	int			(*ndo_switch_fib_ipv4_add)(struct net_device *dev,
+							   __be32 dst,
+							   int dst_len,
+							   struct fib_info *fi,
+							   u8 tos, u8 type,
+							   u32 tb_id);
+	int			(*ndo_switch_fib_ipv4_del)(struct net_device *dev,
+							   __be32 dst,
+							   int dst_len,
+							   struct fib_info *fi,
+							   u8 tos, u8 type,
+							   u32 tb_id);
 #endif
 };
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index cfcdac2..4b2fc3f2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -51,6 +51,11 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 					       struct nlmsghdr *nlh, u16 flags);
 int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
 					       struct nlmsghdr *nlh, u16 flags);
+int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id);
+int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id);
+
 #else
 
 static inline int netdev_switch_parent_id_get(struct net_device *dev,
@@ -109,6 +114,20 @@ static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *
 	return 0;
 }
 
+static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
+					     struct fib_info *fi,
+					     u8 tos, u8 type, u32 tb_id)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
+					     struct fib_info *fi,
+					     u8 tos, u8 type, u32 tb_id)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f485345..b834e9c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -79,6 +79,7 @@
 #include <net/tcp.h>
 #include <net/sock.h>
 #include <net/ip_fib.h>
+#include <net/switchdev.h>
 #include "fib_lookup.h"
 
 #define MAX_STAT_DEPTH 32
@@ -1161,7 +1162,17 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			new_fa->fa_slen = fa->fa_slen;
 
+			err = netdev_switch_fib_ipv4_add(key, plen, fi,
+							 new_fa->fa_tos,
+							 cfg->fc_type,
+							 tb->tb_id);
+			if (err && err != -EOPNOTSUPP) {
+				kmem_cache_free(fn_alias_kmem, new_fa);
+				goto out;
+			}
+
 			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
+
 			alias_free_mem_rcu(fa);
 
 			fib_release_info(fi_drop);
@@ -1197,12 +1208,18 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_state = 0;
 	new_fa->fa_slen = slen;
 
+	/* (Optionally) offload fib entry to switch hardware. */
+	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
+					 cfg->fc_type, tb->tb_id);
+	if (err && err != -EOPNOTSUPP)
+		goto out_free_new_fa;
+
 	/* Insert new entry to the list. */
 	if (!l) {
 		l = fib_insert_node(t, key, plen);
 		if (unlikely(!l)) {
 			err = -ENOMEM;
-			goto out_free_new_fa;
+			goto out_sw_fib_del;
 		}
 	}
 
@@ -1217,6 +1234,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 succeeded:
 	return 0;
 
+out_sw_fib_del:
+	netdev_switch_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
 out_free_new_fa:
 	kmem_cache_free(fn_alias_kmem, new_fa);
 out:
@@ -1475,6 +1494,10 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 		return -ESRCH;
 
 	fa = fa_to_delete;
+
+	netdev_switch_fib_ipv4_del(key, plen, fa->fa_info, tos,
+				   cfg->fc_type, tb->tb_id);
+
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1494,7 +1517,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
-static int trie_flush_leaf(struct tnode *l)
+static int trie_flush_leaf(struct fib_table *tb, struct tnode *l)
 {
 	struct hlist_node *tmp;
 	unsigned char slen = 0;
@@ -1505,6 +1528,10 @@ static int trie_flush_leaf(struct tnode *l)
 		struct fib_info *fi = fa->fa_info;
 
 		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+			netdev_switch_fib_ipv4_del(l->key,
+						   KEYLENGTH - fa->fa_slen,
+						   fi, fa->fa_tos,
+						   fa->fa_type, tb->tb_id);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
@@ -1593,7 +1620,7 @@ int fib_table_flush(struct fib_table *tb)
 	int found = 0;
 
 	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
-		found += trie_flush_leaf(l);
+		found += trie_flush_leaf(tb, l);
 
 		if (ll) {
 			if (hlist_empty(&ll->leaf))
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8c1e558..a84bdb4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -14,6 +14,7 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <net/ip_fib.h>
 #include <net/switchdev.h>
 
 /**
@@ -225,3 +226,97 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 	return ret;
 }
 EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
+
+static struct net_device *netdev_switch_get_by_fib_dev(struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct net_device *lower_dev;
+	struct net_device *port_dev;
+	struct list_head *iter;
+
+	/* Recusively search from fib_dev down until we find
+	 * a sw port dev.  (A sw port dev supports
+	 * ndo_switch_parent_id_get).
+	 */
+
+	if (ops->ndo_switch_parent_id_get)
+		return dev;
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		port_dev = netdev_switch_get_by_fib_dev(lower_dev);
+		if (port_dev)
+			return port_dev;
+	}
+
+	return NULL;
+}
+
+/**
+ *	netdev_switch_fib_ipv4_add - Add IPv4 route entry to switch
+ *
+ *	@dst: route's IPv4 destination address
+ *	@dst_len: destination address length (prefix length)
+ *	@fi: route FIB info structure
+ *	@tos: route TOS
+ *	@type: route type
+ *	@tb_id: route table ID
+ *
+ *	Add IPv4 route entry to switch device.
+ */
+int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id)
+{
+	struct net_device *dev;
+	const struct net_device_ops *ops;
+	int err = -EOPNOTSUPP;
+
+	dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
+	if (!dev)
+		return -EOPNOTSUPP;
+	ops = dev->netdev_ops;
+
+	if (ops->ndo_switch_fib_ipv4_add)
+		err = ops->ndo_switch_fib_ipv4_add(dev, htonl(dst), dst_len,
+						   fi, tos, type, tb_id);
+
+	if (!err)
+		fi->fib_flags |= RTNH_F_EXTERNAL;
+
+	return err;
+}
+EXPORT_SYMBOL(netdev_switch_fib_ipv4_add);
+
+/**
+ *	netdev_switch_fib_ipv4_del - Delete IPv4 route entry from switch
+ *
+ *	@dst: route's IPv4 destination address
+ *	@dst_len: destination address length (prefix length)
+ *	@fi: route FIB info structure
+ *	@tos: route TOS
+ *	@type: route type
+ *	@tb_id: route table ID
+ *
+ *	Delete IPv4 route entry from switch device.
+ */
+int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id)
+{
+	struct net_device *dev;
+	const struct net_device_ops *ops;
+	int err = -EOPNOTSUPP;
+
+	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
+		return -EOPNOTSUPP;
+
+	dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
+	if (!dev)
+		return -EOPNOTSUPP;
+	ops = dev->netdev_ops;
+
+	if (ops->ndo_switch_fib_ipv4_del)
+		err = ops->ndo_switch_fib_ipv4_del(dev, htonl(dst), dst_len,
+						   fi, tos, type, tb_id);
+
+	return err;
+}
+EXPORT_SYMBOL(netdev_switch_fib_ipv4_del);
-- 
1.7.10.4
