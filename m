From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 1/4] netns: move net->ipv4.rt_genid to net->rt_genid
Date: Mon, 10 Sep 2012 15:22:15 +0200
Message-ID: <1347283338-4249-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20120907.144828.97793990734588625.davem@davemloft.net>
 <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: vyasevich@gmail.com, davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38168 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805Ab2IJNWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 09:22:07 -0400
In-Reply-To: <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit prepares the use of rt_genid by both IPv4 and IPv6.
Initialization is left in IPv4 part.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/net_namespace.h | 10 ++++++++++
 include/net/netns/ipv4.h    |  1 -
 net/ipv4/route.c            |  9 ++-------
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 5ae57f1..037190a 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -107,6 +107,7 @@ struct net {
 #endif
 	struct netns_ipvs	*ipvs;
 	struct sock		*diag_nlsk;
+	atomic_t		rt_genid;
 };
 
 /*
@@ -312,5 +313,14 @@ static inline void unregister_net_sysctl_table(struct ctl_table_header *header)
 }
 #endif
 
+static inline int rt_genid(struct net *net)
+{
+	return atomic_read(&net->rt_genid);
+}
+
+static inline void rt_genid_bump(struct net *net)
+{
+	atomic_inc(&net->rt_genid);
+}
 
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 7d00583..2ae2b83 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -64,7 +64,6 @@ struct netns_ipv4 {
 	kgid_t sysctl_ping_group_range[2];
 	long sysctl_tcp_mem[3];
 
-	atomic_t rt_genid;
 	atomic_t dev_addr_genid;
 
 #ifdef CONFIG_IP_MROUTE
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d39edf1..8ff984b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -202,11 +202,6 @@ EXPORT_SYMBOL(ip_tos2prio);
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 #define RT_CACHE_STAT_INC(field) __this_cpu_inc(rt_cache_stat.field)
 
-static inline int rt_genid(struct net *net)
-{
-	return atomic_read(&net->ipv4.rt_genid);
-}
-
 #ifdef CONFIG_PROC_FS
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
@@ -449,7 +444,7 @@ static inline bool rt_is_expired(const struct rtable *rth)
 
 void rt_cache_flush(struct net *net)
 {
-	atomic_inc(&net->ipv4.rt_genid);
+	rt_genid_bump(net);
 }
 
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
@@ -2506,7 +2501,7 @@ static __net_initdata struct pernet_operations sysctl_route_ops = {
 
 static __net_init int rt_genid_init(struct net *net)
 {
-	atomic_set(&net->ipv4.rt_genid, 0);
+	atomic_set(&net->rt_genid, 0);
 	get_random_bytes(&net->ipv4.dev_addr_genid,
 			 sizeof(net->ipv4.dev_addr_genid));
 	return 0;
-- 
1.7.12
