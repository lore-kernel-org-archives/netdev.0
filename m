From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 2/2] bridge: add support of adding and deleting mdb entries
Date: Wed, 12 Dec 2012 16:23:08 +0800
Message-ID: <1355300590-2390-2-git-send-email-amwang@redhat.com>
References: <1355300590-2390-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776Ab2LLIX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 03:23:56 -0500
In-Reply-To: <1355300590-2390-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This patch implents adding/deleting mdb entries via netlink.
Currently all entries are temp, we probably need a flag to distinguish
permanent entries too.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 include/uapi/linux/if_bridge.h |    8 ++
 net/bridge/br_mdb.c            |  240 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_multicast.c      |   55 +++++-----
 net/bridge/br_private.h        |   23 ++++
 4 files changed, 297 insertions(+), 29 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 9a0f6ff..afbb18a 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -157,6 +157,7 @@ enum {
 #define MDBA_ROUTER_MAX (__MDBA_ROUTER_MAX - 1)
 
 struct br_port_msg {
+	__u8  family;
 	__u32 ifindex;
 };
 
@@ -171,4 +172,11 @@ struct br_mdb_entry {
 	} addr;
 };
 
+enum {
+	MDBA_SET_ENTRY_UNSPEC,
+	MDBA_SET_ENTRY,
+	__MDBA_SET_ENTRY_MAX,
+};
+#define MDBA_SET_ENTRY_MAX (__MDBA_SET_ENTRY_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_BRIDGE_H */
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index a8cfbf5..6f0a2ee 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -4,6 +4,7 @@
 #include <linux/netdevice.h>
 #include <linux/rculist.h>
 #include <linux/skbuff.h>
+#include <linux/if_ether.h>
 #include <net/ip.h>
 #include <net/netlink.h>
 #if IS_ENABLED(CONFIG_IPV6)
@@ -235,7 +236,246 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 	__br_mdb_notify(dev, &entry, type);
 }
 
+static bool is_valid_mdb_entry(struct br_mdb_entry *entry)
+{
+	if (entry->ifindex == 0)
+		return false;
+
+	if (entry->addr.proto == htons(ETH_P_IP)) {
+		if (!ipv4_is_multicast(entry->addr.u.ip4))
+			return false;
+		if (ipv4_is_local_multicast(entry->addr.u.ip4))
+			return false;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if (entry->addr.proto == htons(ETH_P_IPV6)) {
+		if (!ipv6_is_transient_multicast(&entry->addr.u.ip6))
+			return false;
+#endif
+	} else
+		return false;
+
+	return true;
+}
+
+static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct net_device **pdev, struct br_mdb_entry **pentry)
+{
+	struct net *net = sock_net(skb->sk);
+	struct br_mdb_entry *entry;
+	struct br_port_msg *bpm;
+	struct nlattr *tb[MDBA_SET_ENTRY_MAX+1];
+	struct net_device *dev;
+	int err;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	err = nlmsg_parse(nlh, sizeof(*bpm), tb, MDBA_SET_ENTRY, NULL);
+	if (err < 0)
+		return err;
+
+	bpm = nlmsg_data(nlh);
+	if (bpm->ifindex == 0) {
+		pr_info("PF_BRIDGE: br_mdb_parse() with invalid ifindex\n");
+		return -EINVAL;
+	}
+
+	dev = __dev_get_by_index(net, bpm->ifindex);
+	if (dev == NULL) {
+		pr_info("PF_BRIDGE: br_mdb_parse() with unknown ifindex\n");
+		return -ENODEV;
+	}
+
+	if (!(dev->priv_flags & IFF_EBRIDGE)) {
+		pr_info("PF_BRIDGE: br_mdb_parse() with non-bridge\n");
+		return -EOPNOTSUPP;
+	}
+
+	*pdev = dev;
+
+	if (!tb[MDBA_SET_ENTRY] ||
+	    nla_len(tb[MDBA_SET_ENTRY]) != sizeof(struct br_mdb_entry)) {
+		pr_info("PF_BRIDGE: br_mdb_parse() with invalid attr\n");
+		return -EINVAL;
+	}
+
+	entry = nla_data(tb[MDBA_SET_ENTRY]);
+	if (!is_valid_mdb_entry(entry)) {
+		pr_info("PF_BRIDGE: br_mdb_parse() with invalid entry\n");
+		return -EINVAL;
+	}
+
+	*pentry = entry;
+	return 0;
+}
+
+static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
+			    struct br_ip *group)
+{
+	struct net_bridge_mdb_entry *mp;
+	struct net_bridge_port_group *p;
+	struct net_bridge_port_group __rcu **pp;
+	struct net_bridge_mdb_htable *mdb;
+	int err;
+
+	mdb = mlock_dereference(br->mdb, br);
+	mp = br_mdb_ip_get(mdb, group);
+	if (!mp) {
+		mp = br_multicast_new_group(br, port, group);
+		err = PTR_ERR(mp);
+		if (IS_ERR(mp))
+			return err;
+	}
+
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
+		if (p->port == port)
+			return -EEXIST;
+		if ((unsigned long)p->port < (unsigned long)port)
+			break;
+	}
+
+	p = br_multicast_new_port_group(port, group, *pp);
+	if (unlikely(!p))
+		return -ENOMEM;
+	rcu_assign_pointer(*pp, p);
+
+	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
+	return 0;
+}
+
+static int __br_mdb_add(struct net *net, struct net_bridge *br,
+			struct br_mdb_entry *entry)
+{
+	struct br_ip ip;
+	struct net_device *dev;
+	struct net_bridge_port *p;
+	int ret;
+
+	if (!netif_running(br->dev) || br->multicast_disabled)
+		return -EINVAL;
+
+	dev = __dev_get_by_index(net, entry->ifindex);
+	if (!dev)
+		return -ENODEV;
+
+	p = br_port_get_rtnl(dev);
+	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
+		return -EINVAL;
+
+	ip.proto = entry->addr.proto;
+	if (ip.proto == htons(ETH_P_IP))
+		ip.u.ip4 = entry->addr.u.ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		ip.u.ip6 = entry->addr.u.ip6;
+#endif
+
+	spin_lock_bh(&br->multicast_lock);
+	ret = br_mdb_add_group(br, p, &ip);
+	spin_unlock_bh(&br->multicast_lock);
+	return ret;
+}
+
+static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct br_mdb_entry *entry;
+	struct net_device *dev;
+	struct net_bridge *br;
+	int err;
+
+	err = br_mdb_parse(skb, nlh, &dev, &entry);
+	if (err < 0)
+		return err;
+
+	br = netdev_priv(dev);
+
+	err = __br_mdb_add(net, br, entry);
+	if (!err)
+		__br_mdb_notify(dev, entry, RTM_NEWMDB);
+	return err;
+}
+
+static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
+{
+	struct net_bridge_mdb_htable *mdb;
+	struct net_bridge_mdb_entry *mp;
+	struct net_bridge_port_group *p;
+	struct net_bridge_port_group __rcu **pp;
+	struct br_ip ip;
+	int err = -EINVAL;
+
+	if (!netif_running(br->dev) || br->multicast_disabled)
+		return -EINVAL;
+
+	if (timer_pending(&br->multicast_querier_timer))
+		return -EBUSY;
+
+	ip.proto = entry->addr.proto;
+	if (ip.proto == htons(ETH_P_IP))
+		ip.u.ip4 = entry->addr.u.ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		ip.u.ip6 = entry->addr.u.ip6;
+#endif
+
+	spin_lock_bh(&br->multicast_lock);
+	mdb = mlock_dereference(br->mdb, br);
+
+	mp = br_mdb_ip_get(mdb, &ip);
+	if (!mp)
+		goto unlock;
+
+	for (pp = &mp->ports;
+	     (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
+		if (!p->port || p->port->dev->ifindex != entry->ifindex)
+			continue;
+
+		if (p->port->state == BR_STATE_DISABLED)
+			goto unlock;
+
+		rcu_assign_pointer(*pp, p->next);
+		hlist_del_init(&p->mglist);
+		del_timer(&p->timer);
+		call_rcu_bh(&p->rcu, br_multicast_free_pg);
+		err = 0;
+
+		if (!mp->ports && !mp->mglist &&
+		    netif_running(br->dev))
+			mod_timer(&mp->timer, jiffies);
+		break;
+	}
+
+unlock:
+	spin_unlock_bh(&br->multicast_lock);
+	return err;
+}
+
+static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net_device *dev;
+	struct br_mdb_entry *entry;
+	struct net_bridge *br;
+	int err;
+
+	err = br_mdb_parse(skb, nlh, &dev, &entry);
+	if (err < 0)
+		return err;
+
+	br = netdev_priv(dev);
+
+	err = __br_mdb_del(br, entry);
+	if (!err)
+		__br_mdb_notify(dev, entry, RTM_DELMDB);
+	return err;
+}
+
 void br_mdb_init(void)
 {
 	rtnl_register(PF_BRIDGE, RTM_GETMDB, NULL, br_mdb_dump, NULL);
+	rtnl_register(PF_BRIDGE, RTM_NEWMDB, br_mdb_add, NULL, NULL);
+	rtnl_register(PF_BRIDGE, RTM_DELMDB, br_mdb_del, NULL, NULL);
 }
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d929586..977c3ee 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -27,27 +27,14 @@
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/mld.h>
-#include <net/addrconf.h>
 #include <net/ip6_checksum.h>
 #endif
 
 #include "br_private.h"
 
-#define mlock_dereference(X, br) \
-	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
-
 static void br_multicast_start_querier(struct net_bridge *br);
 unsigned int br_mdb_rehash_seq;
 
-#if IS_ENABLED(CONFIG_IPV6)
-static inline int ipv6_is_transient_multicast(const struct in6_addr *addr)
-{
-	if (ipv6_addr_is_multicast(addr) && IPV6_ADDR_MC_FLAG_TRANSIENT(addr))
-		return 1;
-	return 0;
-}
-#endif
-
 static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 {
 	if (a->proto != b->proto)
@@ -104,8 +91,8 @@ static struct net_bridge_mdb_entry *__br_mdb_ip_get(
 	return NULL;
 }
 
-static struct net_bridge_mdb_entry *br_mdb_ip_get(
-	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
+struct net_bridge_mdb_entry *br_mdb_ip_get(struct net_bridge_mdb_htable *mdb,
+					   struct br_ip *dst)
 {
 	if (!mdb)
 		return NULL;
@@ -208,7 +195,7 @@ static int br_mdb_copy(struct net_bridge_mdb_htable *new,
 	return maxlen > elasticity ? -EINVAL : 0;
 }
 
-static void br_multicast_free_pg(struct rcu_head *head)
+void br_multicast_free_pg(struct rcu_head *head)
 {
 	struct net_bridge_port_group *p =
 		container_of(head, struct net_bridge_port_group, rcu);
@@ -584,9 +571,8 @@ err:
 	return mp;
 }
 
-static struct net_bridge_mdb_entry *br_multicast_new_group(
-	struct net_bridge *br, struct net_bridge_port *port,
-	struct br_ip *group)
+struct net_bridge_mdb_entry *br_multicast_new_group(struct net_bridge *br,
+	struct net_bridge_port *port, struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -633,6 +619,26 @@ out:
 	return mp;
 }
 
+struct net_bridge_port_group *br_multicast_new_port_group(
+			struct net_bridge_port *port,
+			struct br_ip *group,
+			struct net_bridge_port_group *next)
+{
+	struct net_bridge_port_group *p;
+
+	p = kzalloc(sizeof(*p), GFP_ATOMIC);
+	if (unlikely(!p))
+		return NULL;
+
+	p->addr = *group;
+	p->port = port;
+	p->next = next;
+	hlist_add_head(&p->mglist, &port->mglist);
+	setup_timer(&p->timer, br_multicast_port_group_expired,
+		    (unsigned long)p);
+	return p;
+}
+
 static int br_multicast_add_group(struct net_bridge *br,
 				  struct net_bridge_port *port,
 				  struct br_ip *group)
@@ -668,18 +674,9 @@ static int br_multicast_add_group(struct net_bridge *br,
 			break;
 	}
 
-	p = kzalloc(sizeof(*p), GFP_ATOMIC);
-	err = -ENOMEM;
+	p = br_multicast_new_port_group(port, group, *pp);
 	if (unlikely(!p))
 		goto err;
-
-	p->addr = *group;
-	p->port = port;
-	p->next = *pp;
-	hlist_add_head(&p->mglist, &port->mglist);
-	setup_timer(&p->timer, br_multicast_port_group_expired,
-		    (unsigned long)p);
-
 	rcu_assign_pointer(*pp, p);
 	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2807c76..f21a739 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -434,10 +434,33 @@ extern int br_multicast_set_port_router(struct net_bridge_port *p,
 extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
+extern struct net_bridge_mdb_entry *br_mdb_ip_get(
+				struct net_bridge_mdb_htable *mdb,
+				struct br_ip *dst);
+extern struct net_bridge_mdb_entry *br_multicast_new_group(struct net_bridge *br,
+				struct net_bridge_port *port, struct br_ip *group);
+extern void br_multicast_free_pg(struct rcu_head *head);
+extern struct net_bridge_port_group *br_multicast_new_port_group(
+				struct net_bridge_port *port,
+				struct br_ip *group,
+				struct net_bridge_port_group *next);
 extern void br_mdb_init(void);
 extern void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 			  struct br_ip *group, int type);
 
+#define mlock_dereference(X, br) \
+	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
+
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/addrconf.h>
+static inline int ipv6_is_transient_multicast(const struct in6_addr *addr)
+{
+	if (ipv6_addr_is_multicast(addr) && IPV6_ADDR_MC_FLAG_TRANSIENT(addr))
+		return 1;
+	return 0;
+}
+#endif
+
 static inline bool br_multicast_is_router(struct net_bridge *br)
 {
 	return br->multicast_router == 2 ||
-- 
1.7.7.6
