From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 7/8] ipv6: keep rt_sernum per namespace to reduce number of flushes
Date: Sun, 21 Sep 2014 00:05:24 +0200
Message-ID: <6b158cda3d0f288ec8146138a96dbb8014419fdf.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53115 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbaITWFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 18:05:40 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 1D8D920780
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:05:40 -0400 (EDT)
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/netns/ipv6.h |  1 +
 net/ipv6/af_inet6.c      |  1 +
 net/ipv6/ip6_fib.c       | 19 ++++++++++---------
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 3291ba6..2319949 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -76,6 +76,7 @@ struct netns_ipv6 {
 #endif
 #endif
 	atomic_t		dev_addr_genid;
+	u32			rt_sernum;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2189d2d..7ff8996 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,6 +766,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
 	net->ipv6.sysctl.auto_flowlabels = 0;
+	net->ipv6.rt_sernum = 1;
 
 	err = ipv6_init_mibs(net);
 	if (err)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0fe9241..9f973e4 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -76,8 +76,6 @@ static int fib6_walk_continue(struct fib6_walker_t *w);
  *	result of redirects, path MTU changes, etc.
  */
 
-static u32 rt_sernum;
-
 static void fib6_gc_timer_cb(unsigned long arg);
 
 static LIST_HEAD(fib6_walkers);
@@ -96,12 +94,15 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 	list_del(&w->lh);
 	write_unlock_bh(&fib6_walker_lock);
 }
-static __inline__ u32 fib6_new_sernum(void)
+
+static u32 fib6_new_sernum(struct net *net)
 {
-	u32 n = ++rt_sernum;
-	if ((__s32)n <= 0)
-		rt_sernum = n = 1;
-	return n;
+	int *n = &net->ipv6.rt_sernum;
+
+	++*n;
+	if ((s32)*n <= 0)
+		*n = 1;
+	return *n;
 }
 
 #define FIB6_NO_SERNUM_CHANGE (0U)
@@ -841,7 +842,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
-	u32 sernum = fib6_new_sernum();
+	u32 sernum = fib6_new_sernum(dev_net(rt->dst.dev));
 
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
@@ -1603,7 +1604,7 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 
 static void fib6_flush_trees(struct net *net)
 {
-	__fib6_clean_all(net, NULL, fib6_new_sernum(), NULL);
+	__fib6_clean_all(net, NULL, fib6_new_sernum(net), NULL);
 }
 
 static int fib6_prune_clone(struct rt6_info *rt, void *arg)
-- 
1.9.3
