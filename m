From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 5/6] ipv6: keep rt_sernum per namespace to reduce number of flushes
Date: Fri, 12 Sep 2014 01:21:52 +0200
Message-ID: <8ce7a0db97a79a958b589e2f6f1ea9a57d68206f.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:55833 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752660AbaIKXWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:22:04 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 73D2020E2E
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:22:04 -0400 (EDT)
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves rt_sernum into per-namespace storage. This reduces number
of flushes needed when a xfrm policy gets modified in one namespace.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/netns/ipv6.h |  1 +
 net/ipv6/af_inet6.c      |  1 +
 net/ipv6/ip6_fib.c       | 21 +++++++++++----------
 3 files changed, 13 insertions(+), 10 deletions(-)

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
index cffee60..0ffabe2 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -86,8 +86,6 @@ static int fib6_walk_continue(struct fib6_walker_t *w);
  *	result of redirects, path MTU changes, etc.
  */
 
-static u32 rt_sernum;
-
 static void fib6_gc_timer_cb(unsigned long arg);
 
 static LIST_HEAD(fib6_walkers);
@@ -106,12 +104,15 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
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
+	(*n)++;
+	if ((s32)*n <= 0)
+		*n = 1;
+	return *n;
 }
 
 /*
@@ -850,7 +851,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
-	u32 sernum = fib6_new_sernum();
+	u32 sernum = fib6_new_sernum(dev_net(rt->dst.dev));
 
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
@@ -1355,7 +1356,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	struct net *net = info->nl_net;
 	struct fib6_node *fn = rt->rt6i_node;
 	struct rt6_info **rtp;
-	u32 sernum = fib6_new_sernum();
+	u32 sernum = fib6_new_sernum(dev_net(rt->dst.dev));
 
 #if RT6_DEBUG >= 2
 	if (rt->dst.obsolete > 0) {
@@ -1601,7 +1602,7 @@ static void __fib6_clean_all(struct net *net,
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			sernum = update_sernum && !sernum ?
-				 fib6_new_sernum() : 0;
+				 fib6_new_sernum(net) : 0;
 			fib6_clean_tree(net, &table->tb6_root,
 					func, 0, sernum, arg);
 			write_unlock_bh(&table->tb6_lock);
-- 
1.9.3
