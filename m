From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 8/9] ipv6: switch rt_sernum to atomic_t and clean up types
Date: Sun, 21 Sep 2014 16:11:52 +0200
Message-ID: <8288dd74edeacd1f9260842a1fda805ff8d5ae64.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:54791 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401AbaIUOMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:12:13 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 4DEF4207ED
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 10:12:13 -0400 (EDT)
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch rt_sernum to atomic_t, make it concurrency safe (the old scheme
looked broken to me) and switch from u32 to int types for the fn_sernum.
(fib6_new_sernum only gets used with table locks, but different tables
can get mutated at the same time.)

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h    |  2 +-
 include/net/netns/ipv6.h |  2 +-
 net/ipv6/af_inet6.c      |  2 +-
 net/ipv6/ip6_fib.c       | 29 +++++++++++++++--------------
 4 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a09e554..5440f99 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -64,7 +64,7 @@ struct fib6_node {
 
 	__u16			fn_bit;		/* bit key */
 	__u16			fn_flags;
-	u32			fn_sernum;
+	int			fn_sernum;
 	struct rt6_info		*rr_ptr;
 };
 
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 2319949..7dee21b 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -76,7 +76,7 @@ struct netns_ipv6 {
 #endif
 #endif
 	atomic_t		dev_addr_genid;
-	u32			rt_sernum;
+	atomic_t		rt_sernum;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7ff8996..6cde9b4 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,7 +766,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
 	net->ipv6.sysctl.auto_flowlabels = 0;
-	net->ipv6.rt_sernum = 1;
+	atomic_set(&net->ipv6.rt_sernum, 1);
 
 	err = ipv6_init_mibs(net);
 	if (err)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 9f973e4..ae87d0c 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -50,7 +50,7 @@ struct fib6_cleaner_t {
 	struct fib6_walker_t w;
 	struct net *net;
 	int (*func)(struct rt6_info *, void *arg);
-	u32 sernum;
+	int sernum;
 	void *arg;
 };
 
@@ -63,7 +63,7 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 #endif
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
-			      u32 sernum);
+			      int sernum);
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
 static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
 static int fib6_walk(struct fib6_walker_t *w);
@@ -97,15 +97,16 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 
 static u32 fib6_new_sernum(struct net *net)
 {
-	int *n = &net->ipv6.rt_sernum;
+	int old, new;
 
-	++*n;
-	if ((s32)*n <= 0)
-		*n = 1;
-	return *n;
+	do {
+		old = atomic_read(&net->ipv6.rt_sernum);
+		new = old < INT_MAX ? old + 1 : 1;
+	} while (atomic_cmpxchg(&net->ipv6.rt_sernum, old, new) != old);
+	return new;
 }
 
-#define FIB6_NO_SERNUM_CHANGE (0U)
+#define FIB6_NO_SERNUM_CHANGE (0)
 
 /*
  *	Auxiliary address test functions for the radix tree.
@@ -418,7 +419,7 @@ out:
 static struct fib6_node *fib6_add_1(struct fib6_node *root,
 				    struct in6_addr *addr, int plen,
 				    int offset, int allow_create,
-				    int replace_required, u32 sernum)
+				    int replace_required, int sernum)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
@@ -842,7 +843,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
-	u32 sernum = fib6_new_sernum(dev_net(rt->dst.dev));
+	int sernum = fib6_new_sernum(dev_net(rt->dst.dev));
 
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
@@ -1558,7 +1559,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
-			    bool prune, u32 sernum, void *arg)
+			    bool prune, int sernum, void *arg)
 {
 	struct fib6_cleaner_t c;
 
@@ -1577,7 +1578,7 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 
 void __fib6_clean_all(struct net *net,
 		      int (*func)(struct rt6_info *, void *arg),
-		      u32 sernum, void *arg)
+		      int sernum, void *arg)
 {
 	struct fib6_table *table;
 	struct hlist_head *head;
@@ -1617,7 +1618,7 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 	return 0;
 }
 
-static void fib6_prune_clones(struct net *net, struct fib6_node *fn, u32 sernum)
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn, int sernum)
 {
 	fib6_clean_tree(net, fn, fib6_prune_clone, true, sernum, NULL);
 }
@@ -1830,7 +1831,7 @@ struct ipv6_route_iter {
 	struct fib6_walker_t w;
 	loff_t skip;
 	struct fib6_table *tbl;
-	u32 sernum;
+	int sernum;
 };
 
 static int ipv6_route_seq_show(struct seq_file *seq, void *v)
-- 
1.9.3
