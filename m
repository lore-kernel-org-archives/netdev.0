From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 3/5] NET :  Convert ipv6 route to use the new dst_entry 'next'
 pointer
Date: Thu, 08 Feb 2007 22:36:59 +0100
Message-ID: <45CB97FB.4060202@cosmosbay.com>
References: <20070202120528.GA10392@de.ibm.com> <20070206.144106.39659974.davem@davemloft.net> <45C9093D.1030605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010708060509050000030702"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57996 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423440AbXBHVhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:37:11 -0500
In-Reply-To: <45C9093D.1030605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010708060509050000030702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes the next pointer from 'struct rt6_info.u' union, and 
renames u.next to u.dst.rt6_next.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010708060509050000030702
Content-Type: text/plain;
 name="ipv6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6.patch"

--- linux-2.6.20/include/net/ip6_fib.h	2007-02-08 21:20:31.000000000 +0100
+++ linux-2.6.20-ed/include/net/ip6_fib.h	2007-02-08 21:20:31.000000000 +0100
@@ -83,7 +83,6 @@ struct rt6_info
 {
 	union {
 		struct dst_entry	dst;
-		struct rt6_info		*next;
 	} u;
 
 	struct inet6_dev		*rt6i_idev;
--- linux-2.6.20/net/ipv6/route.c	2007-02-08 21:22:58.000000000 +0100
+++ linux-2.6.20-ed/net/ipv6/route.c	2007-02-08 21:22:58.000000000 +0100
@@ -243,7 +243,7 @@ static __inline__ struct rt6_info *rt6_d
 	struct rt6_info *sprt;
 
 	if (oif) {
-		for (sprt = rt; sprt; sprt = sprt->u.next) {
+		for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
 			struct net_device *dev = sprt->rt6i_dev;
 			if (dev->ifindex == oif)
 				return sprt;
@@ -367,7 +367,7 @@ static struct rt6_info *rt6_select(struc
 
 	for (rt = rt0, metric = rt0->rt6i_metric;
 	     rt && rt->rt6i_metric == metric && (!last || rt != rt0);
-	     rt = rt->u.next) {
+	     rt = rt->u.dst.rt6_next) {
 		int m;
 
 		if (rt6_check_expired(rt))
@@ -395,9 +395,9 @@ static struct rt6_info *rt6_select(struc
 		/* no entries matched; do round-robin */
 		static DEFINE_SPINLOCK(lock);
 		spin_lock(&lock);
-		*head = rt0->u.next;
-		rt0->u.next = last->u.next;
-		last->u.next = rt0;
+		*head = rt0->u.dst.rt6_next;
+		rt0->u.dst.rt6_next = last->u.dst.rt6_next;
+		last->u.dst.rt6_next = rt0;
 		spin_unlock(&lock);
 	}
 
@@ -1269,7 +1269,7 @@ static int ip6_route_del(struct fib6_con
 			 &cfg->fc_src, cfg->fc_src_len);
 	
 	if (fn) {
-		for (rt = fn->leaf; rt; rt = rt->u.next) {
+		for (rt = fn->leaf; rt; rt = rt->u.dst.rt6_next) {
 			if (cfg->fc_ifindex &&
 			    (rt->rt6i_dev == NULL ||
 			     rt->rt6i_dev->ifindex != cfg->fc_ifindex))
@@ -1320,7 +1320,7 @@ static struct rt6_info *__ip6_route_redi
 	read_lock_bh(&table->tb6_lock);
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
-	for (rt = fn->leaf; rt; rt = rt->u.next) {
+	for (rt = fn->leaf; rt; rt = rt->u.dst.rt6_next) {
 		/*
 		 * Current route is on-link; redirect is always invalid.
 		 *
@@ -1581,7 +1581,7 @@ static struct rt6_info *rt6_get_route_in
 	if (!fn)
 		goto out;
 
-	for (rt = fn->leaf; rt; rt = rt->u.next) {
+	for (rt = fn->leaf; rt; rt = rt->u.dst.rt6_next) {
 		if (rt->rt6i_dev->ifindex != ifindex)
 			continue;
 		if ((rt->rt6i_flags & (RTF_ROUTEINFO|RTF_GATEWAY)) != (RTF_ROUTEINFO|RTF_GATEWAY))
@@ -1632,7 +1632,7 @@ struct rt6_info *rt6_get_dflt_router(str
 		return NULL;
 
 	write_lock_bh(&table->tb6_lock);
-	for (rt = table->tb6_root.leaf; rt; rt=rt->u.next) {
+	for (rt = table->tb6_root.leaf; rt; rt=rt->u.dst.rt6_next) {
 		if (dev == rt->rt6i_dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
 		    ipv6_addr_equal(&rt->rt6i_gateway, addr))
@@ -1675,7 +1675,7 @@ void rt6_purge_dflt_routers(void)
 
 restart:
 	read_lock_bh(&table->tb6_lock);
-	for (rt = table->tb6_root.leaf; rt; rt = rt->u.next) {
+	for (rt = table->tb6_root.leaf; rt; rt = rt->u.dst.rt6_next) {
 		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
 			dst_hold(&rt->u.dst);
 			read_unlock_bh(&table->tb6_lock);
--- linux-2.6.20/net/ipv6/ip6_fib.c	2007-02-08 21:26:36.000000000 +0100
+++ linux-2.6.20-ed/net/ipv6/ip6_fib.c	2007-02-08 21:26:36.000000000 +0100
@@ -298,7 +298,7 @@ static int fib6_dump_node(struct fib6_wa
 	int res;
 	struct rt6_info *rt;
 
-	for (rt = w->leaf; rt; rt = rt->u.next) {
+	for (rt = w->leaf; rt; rt = rt->u.dst.rt6_next) {
 		res = rt6_dump_route(rt, w->args);
 		if (res < 0) {
 			/* Frame is full, suspend walking */
@@ -624,11 +624,11 @@ static int fib6_add_rt2node(struct fib6_
 	    fn->leaf == &ip6_null_entry &&
 	    !(rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ){
 		fn->leaf = rt;
-		rt->u.next = NULL;
+		rt->u.dst.rt6_next = NULL;
 		goto out;
 	}
 
-	for (iter = fn->leaf; iter; iter=iter->u.next) {
+	for (iter = fn->leaf; iter; iter=iter->u.dst.rt6_next) {
 		/*
 		 *	Search for duplicates
 		 */
@@ -656,7 +656,7 @@ static int fib6_add_rt2node(struct fib6_
 		if (iter->rt6i_metric > rt->rt6i_metric)
 			break;
 
-		ins = &iter->u.next;
+		ins = &iter->u.dst.rt6_next;
 	}
 
 	/*
@@ -664,7 +664,7 @@ static int fib6_add_rt2node(struct fib6_
 	 */
 
 out:
-	rt->u.next = iter;
+	rt->u.dst.rt6_next = iter;
 	*ins = rt;
 	rt->rt6i_node = fn;
 	atomic_inc(&rt->rt6i_ref);
@@ -1105,7 +1105,7 @@ static void fib6_del_route(struct fib6_n
 	RT6_TRACE("fib6_del_route\n");
 
 	/* Unlink it */
-	*rtp = rt->u.next;
+	*rtp = rt->u.dst.rt6_next;
 	rt->rt6i_node = NULL;
 	rt6_stats.fib_rt_entries--;
 	rt6_stats.fib_discarded_routes++;
@@ -1115,14 +1115,14 @@ static void fib6_del_route(struct fib6_n
 	FOR_WALKERS(w) {
 		if (w->state == FWS_C && w->leaf == rt) {
 			RT6_TRACE("walker %p adjusted by delroute\n", w);
-			w->leaf = rt->u.next;
+			w->leaf = rt->u.dst.rt6_next;
 			if (w->leaf == NULL)
 				w->state = FWS_U;
 		}
 	}
 	read_unlock(&fib6_walker_lock);
 
-	rt->u.next = NULL;
+	rt->u.dst.rt6_next = NULL;
 
 	if (fn->leaf == NULL && fn->fn_flags&RTN_TL_ROOT)
 		fn->leaf = &ip6_null_entry;
@@ -1190,7 +1190,7 @@ int fib6_del(struct rt6_info *rt, struct
 	 *	Walk the leaf entries looking for ourself
 	 */
 
-	for (rtp = &fn->leaf; *rtp; rtp = &(*rtp)->u.next) {
+	for (rtp = &fn->leaf; *rtp; rtp = &(*rtp)->u.dst.rt6_next) {
 		if (*rtp == rt) {
 			fib6_del_route(fn, rtp, info);
 			return 0;
@@ -1317,7 +1317,7 @@ static int fib6_clean_node(struct fib6_w
 	struct rt6_info *rt;
 	struct fib6_cleaner_t *c = (struct fib6_cleaner_t*)w;
 
-	for (rt = w->leaf; rt; rt = rt->u.next) {
+	for (rt = w->leaf; rt; rt = rt->u.dst.rt6_next) {
 		res = c->func(rt, c->arg);
 		if (res < 0) {
 			w->leaf = rt;

--------------010708060509050000030702--
