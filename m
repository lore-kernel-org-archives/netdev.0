From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: implement rt_genid_bump_ipv6 with
 fn_sernum and remove rt6i_genid
Date: Thu, 11 Sep 2014 14:05:46 +0200
Message-ID: <1410437146.18873.2.camel@localhost>
References: <1410267519.27979.31.camel@localhost>
	 <130f98f49b1b90a30908bfda8f01109c91edfe1c.1410341451.git.hannes@stressinduktion.org>
	 <20140910.130929.247064282043941043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36513 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754302AbaIKMFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 08:05:50 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 4DFC520C01
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 08:05:49 -0400 (EDT)
In-Reply-To: <20140910.130929.247064282043941043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-09-10 at 13:09 -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 10 Sep 2014 11:31:28 +0200
> 
> > In case we need to force the sockets to relookup the routes we now
> > increase the fn_sernum on all fibnodes in the routing tree. This is a
> > costly operation but should only happen if we have major routing/policy
> > changes in the kernel (e.g. manual route adding/removal, xfrm policy
> > changes).
> 
> Core routers can update thousands of route updates per second, and they
> do this via what you refer to as "manual route adding/removal".
> 
> I don't think we want to put such a scalability problem into the tree.
> 
> There has to be a lightweight way to address this.

An alternative approach without traversing the routing table, but each
newly inserted route (even only cached ones) might bump all other routes
out of the per-socket caches:

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9bcb220..a7e45b9 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -119,8 +119,6 @@ struct rt6_info {
 	struct inet6_dev		*rt6i_idev;
 	unsigned long			_rt6i_peer;
 
-	u32				rt6i_genid;
-
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 361d260..428fdcb 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -358,18 +358,28 @@ static inline int rt_genid_ipv6(struct net *net)
 	return atomic_read(&net->ipv6.rt_genid);
 }
 
-static inline void rt_genid_bump_ipv6(struct net *net)
+static inline int rt_genid_bump_ipv6(struct net *net)
 {
-	atomic_inc(&net->ipv6.rt_genid);
+	int new, old;
+
+	do {
+		old = atomic_read(&net->ipv6.rt_genid);
+		new = old + 1;
+		if (new <= 0)
+			new = 1;
+	} while (atomic_cmpxchg(&net->ipv6.rt_genid, old, new) != old);
+	return new;
+
 }
 #else
 static inline int rt_genid_ipv6(struct net *net)
 {
-	return 0;
+	return 1;
 }
 
-static inline void rt_genid_bump_ipv6(struct net *net)
+static inline int rt_genid_bump_ipv6(struct net *net)
 {
+	return 1;
 }
 #endif
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 76b7f5e..4a2f130 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -84,7 +84,10 @@ static int fib6_walk_continue(struct fib6_walker_t *w);
  *	result of redirects, path MTU changes, etc.
  */
 
-static __u32 rt_sernum;
+static int fib6_new_sernum(struct net *net)
+{
+	return rt_genid_bump_ipv6(net);
+}
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
@@ -104,13 +107,6 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 	list_del(&w->lh);
 	write_unlock_bh(&fib6_walker_lock);
 }
-static __inline__ u32 fib6_new_sernum(void)
-{
-	u32 n = ++rt_sernum;
-	if ((__s32)n <= 0)
-		rt_sernum = n = 1;
-	return n;
-}
 
 /*
  *	Auxiliary address test functions for the radix tree.
@@ -421,16 +417,15 @@ out:
  */
 
 static struct fib6_node *fib6_add_1(struct fib6_node *root,
-				     struct in6_addr *addr, int plen,
-				     int offset, int allow_create,
-				     int replace_required)
+				    struct in6_addr *addr, int plen,
+				    int offset, int allow_create,
+				    int replace_required, int sernum)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
 	struct rt6key *key;
 	int	bit;
 	__be32	dir = 0;
-	__u32	sernum = fib6_new_sernum();
 
 	RT6_TRACE("fib6_add_1\n");
 
@@ -844,6 +839,7 @@ void fib6_force_start_gc(struct net *net)
 int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	     struct nlattr *mx, int mx_len)
 {
+	struct net *net = dev_net(rt->dst.dev);
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
 	int allow_create = 1;
@@ -860,7 +856,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			offsetof(struct rt6_info, rt6i_dst), allow_create,
-			replace_required);
+			replace_required, fib6_new_sernum(net));
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
 		fn = NULL;
@@ -894,14 +890,15 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 			sfn->leaf = info->nl_net->ipv6.ip6_null_entry;
 			atomic_inc(&info->nl_net->ipv6.ip6_null_entry->rt6i_ref);
 			sfn->fn_flags = RTN_ROOT;
-			sfn->fn_sernum = fib6_new_sernum();
+			sfn->fn_sernum = fib6_new_sernum(net);
 
 			/* Now add the first leaf node to new subtree */
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required);
+					allow_create, replace_required,
+					fib6_new_sernum(net));
 
 			if (IS_ERR(sn)) {
 				/* If it is failed, discard just allocated
@@ -920,7 +917,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required);
+					allow_create, replace_required,
+					fib6_new_sernum(net));
 
 			if (IS_ERR(sn)) {
 				err = PTR_ERR(sn);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f74b041..54b7d81 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -314,7 +314,6 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
-		rt->rt6i_genid = rt_genid_ipv6(net);
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
 	}
 	return rt;
@@ -1096,10 +1095,7 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 */
-	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
-		return NULL;
-
-	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
+	if (!rt->rt6i_node || rt_genid_ipv6(dev_net(rt->dst.dev)) != cookie)
 		return NULL;
 
 	if (rt6_check_expired(rt))
