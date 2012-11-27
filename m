From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 1/1] Introduce notification events for routing changes
Date: Tue, 27 Nov 2012 21:27:25 +0100
Message-ID: <1354048045-17846-2-git-send-email-kadlec@blackhole.kfki.hu>
References: <1354048045-17846-1-git-send-email-kadlec@blackhole.kfki.hu>
Cc: netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1354048045-17846-1-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netfilter MASQUERADE target does not handle the case when the routing
changes and the source address of existing connections become invalid.
The problem can be solved if routing modifications create events to which
the MASQUERADE target can subscribe and then delete the affected
connections.

The patch adds the required event support for IPv4/IPv6.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/inetdevice.h |    2 ++
 include/linux/netdevice.h  |    1 +
 include/net/ip6_route.h    |    3 ++-
 net/ipv4/fib_trie.c        |   17 +++++++++++++++++
 net/ipv6/route.c           |   21 +++++++++++++++++++++
 5 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index d032780..cf16dab 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -170,6 +170,8 @@ struct in_ifaddr {
 
 extern int register_inetaddr_notifier(struct notifier_block *nb);
 extern int unregister_inetaddr_notifier(struct notifier_block *nb);
+extern int register_iproute_notifier(struct notifier_block *nb);
+extern int unregister_iproute_notifier(struct notifier_block *nb);
 
 extern struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
 static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e9929ab..cd53253 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1559,6 +1559,7 @@ struct packet_offload {
 #define NETDEV_RELEASE		0x0012
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
+#define NETDEV_ROUTE_CHANGED	0x0015
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 27d8318..e3c079d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -149,7 +149,8 @@ extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net *net, struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
-
+extern int register_ip6route_notifier(struct notifier_block *nb);
+extern int unregister_ip6route_notifier(struct notifier_block *nb);
 
 /*
  *	Store a destination cache entry in a socket
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 31d771c..ee6f968 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -178,6 +178,8 @@ static const int sync_pages = 128;
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
+static BLOCKING_NOTIFIER_HEAD(iproute_chain);
+
 /*
  * caller must hold RTNL
  */
@@ -1337,6 +1339,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 succeeded:
+	blocking_notifier_call_chain(&iproute_chain,
+				     NETDEV_ROUTE_CHANGED, fi);
 	return 0;
 
 out_free_new_fa:
@@ -1713,6 +1717,8 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (fa->fa_state & FA_S_ACCESSED)
 		rt_cache_flush(cfg->fc_nlinfo.nl_net);
 
+	blocking_notifier_call_chain(&iproute_chain,
+				     NETDEV_ROUTE_CHANGED, fa->fa_info);
 	fib_release_info(fa->fa_info);
 	alias_free_mem_rcu(fa);
 	return 0;
@@ -1979,6 +1985,17 @@ void __init fib_trie_init(void)
 					   0, SLAB_PANIC, NULL);
 }
 
+int register_iproute_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&iproute_chain, nb);
+}
+EXPORT_SYMBOL(register_iproute_notifier);
+
+int unregister_iproute_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&iproute_chain, nb);
+}
+EXPORT_SYMBOL(unregister_iproute_notifier);
 
 struct fib_table *fib_trie_table(u32 id)
 {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8f124f5..5d086d2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -94,6 +94,8 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *gwaddr, int ifindex);
 #endif
 
+static ATOMIC_NOTIFIER_HEAD(ip6route_chain);
+
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
@@ -818,6 +820,10 @@ static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info)
 	err = fib6_add(&table->tb6_root, rt, info);
 	write_unlock_bh(&table->tb6_lock);
 
+	if (!err)
+		atomic_notifier_call_chain(&ip6route_chain,
+					   NETDEV_ROUTE_CHANGED, rt);
+
 	return err;
 }
 
@@ -1652,6 +1658,9 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	err = fib6_del(rt, info);
 	write_unlock_bh(&table->tb6_lock);
 
+	if (!err)
+		atomic_notifier_call_chain(&ip6route_chain,
+					   NETDEV_ROUTE_CHANGED, rt);
 out:
 	ip6_rt_put(rt);
 	return err;
@@ -2788,6 +2797,18 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 	return NOTIFY_OK;
 }
 
+int register_ip6route_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&ip6route_chain, nb);
+}
+EXPORT_SYMBOL(register_ip6route_notifier);
+
+int unregister_ip6route_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&ip6route_chain, nb);
+}
+EXPORT_SYMBOL(unregister_ip6route_notifier);
+
 /*
  *	/proc
  */
-- 
1.7.0.4

