From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 4/6] netns: move net->ipv4.rt_genid to net->rt_genid
Date: Fri, 19 Oct 2012 15:21:59 -0400
Message-ID: <20121019192159.GD8315@kvack.org>
References: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43180 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312Ab2JSTWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:22:00 -0400
Content-Disposition: inline
In-Reply-To: <20121019191347.GD13515@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b42664f898c976247f7f609b8bb9c94d7475ca10
Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date:   Mon Sep 10 22:09:44 2012 +0000

    netns: move net->ipv4.rt_genid to net->rt_genid

    This commit prepares the use of rt_genid by both IPv4 and IPv6.
    Initialization is left in IPv4 part.

    Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Since 2.6.32 still has the routing cache, this patch has been modified to
retain the IPv4 method for updating rt_genid in rt_cache_invalidate() to
perturb the route cache's hash function.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 include/net/net_namespace.h |   12 ++++++++++++
 include/net/netns/ipv4.h    |    1 -
 net/ipv4/route.c            |   11 +++--------
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index a120284..b810fa1 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -84,6 +84,7 @@ struct net {
 	struct sk_buff_head	wext_nlevents;
 #endif
 	struct net_generic	*gen;
+	atomic_t		rt_genid;
 };
 
 
@@ -272,4 +273,15 @@ extern struct ctl_table_header *register_net_sysctl_rotable(
 	const struct ctl_path *path, struct ctl_table *table);
 extern void unregister_net_sysctl_table(struct ctl_table_header *header);
 
+static inline int rt_genid(struct net *net)
+{
+	return atomic_read(&net->rt_genid);
+}
+
+extern void rt_cache_invalidate(struct net *net);
+static inline void rt_genid_bump(struct net *net)
+{
+	rt_cache_invalidate(net);
+}
+
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 9a4b8b7..5f0d561 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -54,7 +54,6 @@ struct netns_ipv4 {
 	int current_rt_cache_rebuild_count;
 
 	struct timer_list rt_secret_timer;
-	atomic_t rt_genid;
 
 #ifdef CONFIG_IP_MROUTE
 	struct sock		*mroute_sk;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f79a9a8..83f16e3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -267,11 +267,6 @@ static inline unsigned int rt_hash(__be32 daddr, __be32 saddr, int idx,
 		& rt_hash_mask;
 }
 
-static inline int rt_genid(struct net *net)
-{
-	return atomic_read(&net->ipv4.rt_genid);
-}
-
 #ifdef CONFIG_PROC_FS
 struct rt_cache_iter_state {
 	struct seq_net_private p;
@@ -884,12 +879,12 @@ static void rt_worker_func(struct work_struct *work)
  * many times (2^24) without giving recent rt_genid.
  * Jenkins hash is strong enough that litle changes of rt_genid are OK.
  */
-static void rt_cache_invalidate(struct net *net)
+void rt_cache_invalidate(struct net *net)
 {
 	unsigned char shuffle;
 
 	get_random_bytes(&shuffle, sizeof(shuffle));
-	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
+	atomic_add(shuffle + 1U, &net->rt_genid);
 }
 
 /*
@@ -3364,7 +3359,7 @@ static __net_initdata struct pernet_operations sysctl_route_ops = {
 
 static __net_init int rt_secret_timer_init(struct net *net)
 {
-	atomic_set(&net->ipv4.rt_genid,
+	atomic_set(&net->rt_genid,
 			(int) ((num_physpages ^ (num_physpages>>8)) ^
 			(jiffies ^ (jiffies >> 7))));
 
-- 
1.7.1


-- 
"Thought is the essence of where you are now."
