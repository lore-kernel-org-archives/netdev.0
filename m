From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bridge: add __rcu annotations
Date: Sat, 13 Nov 2010 09:15:28 +0100
Message-ID: <1289636128.2743.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33498 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453Ab0KMIPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 03:15:36 -0500
Received: by wwb29 with SMTP id 29so86668wwb.1
        for <netdev@vger.kernel.org>; Sat, 13 Nov 2010 00:15:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add modern __rcu annotations to bridge code, to reduce sparse errors,
and self document code.
(CONFIG_SPARSE_RCU_POINTER=y)

Use of an anonymous union in net_device to get proper type for
net_dev->br_port_rcu, to get cleaner br_port_get_rcu() definition.

br_port_get() renamed to br_port_get_rtnl() to make clear RTNL is held.

Note: Add br_should_route_hook_t typedef, this is the only way we can
get a clean RCU implementation for function pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
---
 include/linux/if_bridge.h             |    3 
 include/linux/netdevice.h             |    5 +
 net/bridge/br.c                       |    5 -
 net/bridge/br_if.c                    |    2 
 net/bridge/br_input.c                 |    4 -
 net/bridge/br_multicast.c             |   78 +++++++++++++++---------
 net/bridge/br_netlink.c               |    4 -
 net/bridge/br_notify.c                |    4 -
 net/bridge/br_private.h               |   11 +--
 net/bridge/netfilter/ebtable_broute.c |    2 
 10 files changed, 72 insertions(+), 46 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 0d241a5..dc813e9 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -102,7 +102,8 @@ struct __fdb_entry {
 #include <linux/netdevice.h>
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
-extern int (*br_should_route_hook)(struct sk_buff *skb);
+typedef int (*br_should_route_hook_t)(struct sk_buff *skb);
+extern br_should_route_hook_t __rcu *br_should_route_hook;
 
 #endif
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 578debb..ffbd177 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -996,7 +996,10 @@ struct net_device {
 #endif
 
 	rx_handler_func_t	*rx_handler;
-	void			*rx_handler_data;
+	union {
+		void				*rx_handler_data;
+		struct net_bridge_port __rcu	*br_port_rcu;
+	};
 
 	struct netdev_queue __rcu *ingress_queue;
 
diff --git a/net/bridge/br.c b/net/bridge/br.c
index c8436fa..9fad125 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -22,7 +22,8 @@
 
 #include "br_private.h"
 
-int (*br_should_route_hook)(struct sk_buff *skb);
+br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
+EXPORT_SYMBOL(br_should_route_hook);
 
 static const struct stp_proto br_stp_proto = {
 	.rcv	= br_stp_rcv,
@@ -102,8 +103,6 @@ static void __exit br_deinit(void)
 	br_fdb_fini();
 }
 
-EXPORT_SYMBOL(br_should_route_hook);
-
 module_init(br_init)
 module_exit(br_deinit)
 MODULE_LICENSE("GPL");
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 89ad25a..3a611d2 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -478,7 +478,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	if (!br_port_exists(dev))
 		return -EINVAL;
 
-	p = br_port_get(dev);
+	p = br_port_get_rtnl(dev);
 	if (p->br != br)
 		return -EINVAL;
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 25207a1..948c921 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -139,7 +139,7 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
 {
 	struct net_bridge_port *p;
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
-	int (*rhook)(struct sk_buff *skb);
+	br_should_route_hook_t *rhook;
 
 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
 		return skb;
@@ -174,7 +174,7 @@ forward:
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
 		if (rhook != NULL) {
-			if (rhook(skb))
+			if ((*rhook)(skb))
 				return skb;
 			dest = eth_hdr(skb)->h_dest;
 		}
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index eb5b256..326e599 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -33,6 +33,9 @@
 
 #include "br_private.h"
 
+#define mlock_dereference(X, br) \
+	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline int ipv6_is_local_multicast(const struct in6_addr *addr)
 {
@@ -135,7 +138,7 @@ static struct net_bridge_mdb_entry *br_mdb_ip6_get(
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb = rcu_dereference(br->mdb);
 	struct br_ip ip;
 
 	if (br->multicast_disabled)
@@ -235,7 +238,8 @@ static void br_multicast_group_expired(unsigned long data)
 	if (mp->ports)
 		goto out;
 
-	mdb = br->mdb;
+	mdb = mlock_dereference(br->mdb, br);
+
 	hlist_del_rcu(&mp->hlist[mdb->ver]);
 	mdb->size--;
 
@@ -249,16 +253,20 @@ out:
 static void br_multicast_del_pg(struct net_bridge *br,
 				struct net_bridge_port_group *pg)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
-	struct net_bridge_port_group **pp;
+	struct net_bridge_port_group __rcu **pp;
+
+	mdb = mlock_dereference(br->mdb, br);
 
 	mp = br_mdb_ip_get(mdb, &pg->addr);
 	if (WARN_ON(!mp))
 		return;
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (p != pg)
 			continue;
 
@@ -294,10 +302,10 @@ out:
 	spin_unlock(&br->multicast_lock);
 }
 
-static int br_mdb_rehash(struct net_bridge_mdb_htable **mdbp, int max,
+static int br_mdb_rehash(struct net_bridge_mdb_htable __rcu **mdbp, int max,
 			 int elasticity)
 {
-	struct net_bridge_mdb_htable *old = *mdbp;
+	struct net_bridge_mdb_htable *old = rcu_dereference_protected(*mdbp, 1);
 	struct net_bridge_mdb_htable *mdb;
 	int err;
 
@@ -569,7 +577,7 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 	struct net_bridge *br, struct net_bridge_port *port,
 	struct br_ip *group, int hash)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
 	struct hlist_node *p;
 	unsigned count = 0;
@@ -577,6 +585,7 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 	int elasticity;
 	int err;
 
+	mdb = rcu_dereference_protected(br->mdb, 1);
 	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
 		count++;
 		if (unlikely(br_ip_equal(group, &mp->addr)))
@@ -642,10 +651,11 @@ static struct net_bridge_mdb_entry *br_multicast_new_group(
 	struct net_bridge *br, struct net_bridge_port *port,
 	struct br_ip *group)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
 	int hash;
 
+	mdb = rcu_dereference_protected(br->mdb, 1);
 	if (!mdb) {
 		if (br_mdb_rehash(&br->mdb, BR_HASH_SIZE, 0))
 			return NULL;
@@ -660,7 +670,7 @@ static struct net_bridge_mdb_entry *br_multicast_new_group(
 
 	case -EAGAIN:
 rehash:
-		mdb = br->mdb;
+		mdb = rcu_dereference_protected(br->mdb, 1);
 		hash = br_ip_hash(mdb, group);
 		break;
 
@@ -692,7 +702,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
-	struct net_bridge_port_group **pp;
+	struct net_bridge_port_group __rcu **pp;
 	unsigned long now = jiffies;
 	int err;
 
@@ -712,7 +722,9 @@ static int br_multicast_add_group(struct net_bridge *br,
 		goto out;
 	}
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (p->port == port)
 			goto found;
 		if ((unsigned long)p->port < (unsigned long)port)
@@ -1106,7 +1118,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	struct net_bridge_mdb_entry *mp;
 	struct igmpv3_query *ih3;
 	struct net_bridge_port_group *p;
-	struct net_bridge_port_group **pp;
+	struct net_bridge_port_group __rcu **pp;
 	unsigned long max_delay;
 	unsigned long now = jiffies;
 	__be32 group;
@@ -1145,7 +1157,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip4_get(br->mdb, group);
+	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group);
 	if (!mp)
 		goto out;
 
@@ -1157,7 +1169,9 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	     try_to_del_timer_sync(&mp->timer) >= 0))
 		mod_timer(&mp->timer, now + max_delay);
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (timer_pending(&p->timer) ?
 		    time_after(p->timer.expires, now + max_delay) :
 		    try_to_del_timer_sync(&p->timer) >= 0)
@@ -1178,7 +1192,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	struct mld_msg *mld = (struct mld_msg *) icmp6_hdr(skb);
 	struct net_bridge_mdb_entry *mp;
 	struct mld2_query *mld2q;
-	struct net_bridge_port_group *p, **pp;
+	struct net_bridge_port_group *p;
+	struct net_bridge_port_group __rcu **pp;
 	unsigned long max_delay;
 	unsigned long now = jiffies;
 	struct in6_addr *group = NULL;
@@ -1214,7 +1229,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip6_get(br->mdb, group);
+	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group);
 	if (!mp)
 		goto out;
 
@@ -1225,7 +1240,9 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	     try_to_del_timer_sync(&mp->timer) >= 0))
 		mod_timer(&mp->timer, now + max_delay);
 
-	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
 		if (timer_pending(&p->timer) ?
 		    time_after(p->timer.expires, now + max_delay) :
 		    try_to_del_timer_sync(&p->timer) >= 0)
@@ -1254,7 +1271,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	    timer_pending(&br->multicast_querier_timer))
 		goto out;
 
-	mdb = br->mdb;
+	mdb = mlock_dereference(br->mdb, br);
 	mp = br_mdb_ip_get(mdb, group);
 	if (!mp)
 		goto out;
@@ -1277,7 +1294,9 @@ static void br_multicast_leave_group(struct net_bridge *br,
 		goto out;
 	}
 
-	for (p = mp->ports; p; p = p->next) {
+	for (p = mlock_dereference(mp->ports, br);
+	     p != NULL;
+	     p = mlock_dereference(p->next, br)) {
 		if (p->port != port)
 			continue;
 
@@ -1625,7 +1644,7 @@ void br_multicast_stop(struct net_bridge *br)
 	del_timer_sync(&br->multicast_query_timer);
 
 	spin_lock_bh(&br->multicast_lock);
-	mdb = br->mdb;
+	mdb = mlock_dereference(br->mdb, br);
 	if (!mdb)
 		goto out;
 
@@ -1729,6 +1748,7 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 {
 	struct net_bridge_port *port;
 	int err = 0;
+	struct net_bridge_mdb_htable *mdb;
 
 	spin_lock(&br->multicast_lock);
 	if (br->multicast_disabled == !val)
@@ -1741,15 +1761,16 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 	if (!netif_running(br->dev))
 		goto unlock;
 
-	if (br->mdb) {
-		if (br->mdb->old) {
+	mdb = mlock_dereference(br->mdb, br);
+	if (mdb) {
+		if (mdb->old) {
 			err = -EEXIST;
 rollback:
 			br->multicast_disabled = !!val;
 			goto unlock;
 		}
 
-		err = br_mdb_rehash(&br->mdb, br->mdb->max,
+		err = br_mdb_rehash(&br->mdb, mdb->max,
 				    br->hash_elasticity);
 		if (err)
 			goto rollback;
@@ -1774,6 +1795,7 @@ int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val)
 {
 	int err = -ENOENT;
 	u32 old;
+	struct net_bridge_mdb_htable *mdb;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev))
@@ -1782,7 +1804,9 @@ int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val)
 	err = -EINVAL;
 	if (!is_power_of_2(val))
 		goto unlock;
-	if (br->mdb && val < br->mdb->size)
+
+	mdb = mlock_dereference(br->mdb, br);
+	if (mdb && val < mdb->size)
 		goto unlock;
 
 	err = 0;
@@ -1790,8 +1814,8 @@ int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val)
 	old = br->hash_max;
 	br->hash_max = val;
 
-	if (br->mdb) {
-		if (br->mdb->old) {
+	if (mdb) {
+		if (mdb->old) {
 			err = -EEXIST;
 rollback:
 			br->hash_max = old;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 4a6a378..b301dfc 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -123,7 +123,7 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 		if (!br_port_exists(dev) || idx < cb->args[0])
 			goto skip;
 
-		if (br_fill_ifinfo(skb, br_port_get(dev),
+		if (br_fill_ifinfo(skb, br_port_get_rtnl(dev),
 				   NETLINK_CB(cb->skb).pid,
 				   cb->nlh->nlmsg_seq, RTM_NEWLINK,
 				   NLM_F_MULTI) < 0)
@@ -171,7 +171,7 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 
 	if (!br_port_exists(dev))
 		return -EINVAL;
-	p = br_port_get(dev);
+	p = br_port_get_rtnl(dev);
 
 	/* if kernel STP is running, don't allow changes */
 	if (p->br->stp_enabled == BR_KERNEL_STP)
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 404d4e1..e72e49e 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -32,7 +32,7 @@ struct notifier_block br_device_notifier = {
 static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct net_bridge_port *p = br_port_get(dev);
+	struct net_bridge_port *p;
 	struct net_bridge *br;
 	int err;
 
@@ -40,7 +40,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	if (!br_port_exists(dev))
 		return NOTIFY_DONE;
 
-	p = br_port_get(dev);
+	p = br_port_get_rtnl(dev);
 	br = p->br;
 
 	switch (event) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 75c90ed..32235d4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -72,7 +72,7 @@ struct net_bridge_fdb_entry
 
 struct net_bridge_port_group {
 	struct net_bridge_port		*port;
-	struct net_bridge_port_group	*next;
+	struct net_bridge_port_group __rcu	*next;
 	struct hlist_node		mglist;
 	struct rcu_head			rcu;
 	struct timer_list		timer;
@@ -86,7 +86,7 @@ struct net_bridge_mdb_entry
 	struct hlist_node		hlist[2];
 	struct hlist_node		mglist;
 	struct net_bridge		*br;
-	struct net_bridge_port_group	*ports;
+	struct net_bridge_port_group __rcu	*ports;
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
@@ -151,9 +151,8 @@ struct net_bridge_port
 #endif
 };
 
-#define br_port_get_rcu(dev) \
-	((struct net_bridge_port *) rcu_dereference(dev->rx_handler_data))
-#define br_port_get(dev) ((struct net_bridge_port *) dev->rx_handler_data)
+#define br_port_get_rcu(dev) rcu_dereference(dev->br_port_rcu)
+#define br_port_get_rtnl(dev) rtnl_dereference(dev->br_port_rcu)
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
 
 struct br_cpu_netstats {
@@ -227,7 +226,7 @@ struct net_bridge
 	unsigned long			multicast_startup_query_interval;
 
 	spinlock_t			multicast_lock;
-	struct net_bridge_mdb_htable	*mdb;
+	struct net_bridge_mdb_htable __rcu	*mdb;
 	struct hlist_head		router_list;
 	struct hlist_head		mglist;
 
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index ae3f106..4ce9d8a 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -87,7 +87,7 @@ static int __init ebtable_broute_init(void)
 	if (ret < 0)
 		return ret;
 	/* see br_input.c */
-	rcu_assign_pointer(br_should_route_hook, ebt_broute);
+	rcu_assign_pointer(br_should_route_hook, (br_should_route_hook_t *)ebt_broute);
 	return 0;
 }
 


