From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 2/5] NET : Convert ipv4 route to use the new dst_entry 'next'
 pointer
Date: Thu, 08 Feb 2007 22:35:33 +0100
Message-ID: <45CB97A5.3070000@cosmosbay.com>
References: <20070202120528.GA10392@de.ibm.com> <20070206.144106.39659974.davem@davemloft.net> <45C9093D.1030605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080009000803000200070008"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54119 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423438AbXBHVfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:35:46 -0500
In-Reply-To: <45C9093D.1030605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080009000803000200070008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes the rt_next pointer from 'struct rtable.u' union, and 
renames u.rt_next to u.dst_rt_next.

It also moves 'struct flowi' right after 'struct dst_entry' to prepare the 
gain on lookups.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------080009000803000200070008
Content-Type: text/plain;
 name="route.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="route.patch"

--- linux-2.6.20/include/net/route.h	2007-02-08 21:12:52.000000000 +0100
+++ linux-2.6.20-ed/include/net/route.h	2007-02-08 21:12:52.000000000 +0100
@@ -53,9 +53,11 @@ struct rtable
 	union
 	{
 		struct dst_entry	dst;
-		struct rtable		*rt_next;
 	} u;
 
+	/* Cache lookup keys */
+	struct flowi		fl;
+
 	struct in_device	*idev;
 	
 	unsigned		rt_flags;
@@ -69,9 +71,6 @@ struct rtable
 	/* Info on neighbour */
 	__be32			rt_gateway;
 
-	/* Cache lookup keys */
-	struct flowi		fl;
-
 	/* Miscellaneous cached information */
 	__be32			rt_spec_dst; /* RFC1122 specific destination */
 	struct inet_peer	*peer; /* long-living peer info */
--- linux-2.6.20/net/ipv4/route.c	2007-02-08 21:13:44.000000000 +0100
+++ linux-2.6.20-ed/net/ipv4/route.c	2007-02-08 21:13:44.000000000 +0100
@@ -289,7 +289,7 @@ static struct rtable *rt_cache_get_next(
 {
 	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
 
-	r = r->u.rt_next;
+	r = r->u.dst.rt_next;
 	while (!r) {
 		rcu_read_unlock_bh();
 		if (--st->bucket < 0)
@@ -512,7 +512,7 @@ static __inline__ int rt_fast_clean(stru
 	/* Kill broadcast/multicast entries very aggresively, if they
 	   collide in hash table with more useful entries */
 	return (rth->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) &&
-		rth->fl.iif && rth->u.rt_next;
+		rth->fl.iif && rth->u.dst.rt_next;
 }
 
 static __inline__ int rt_valuable(struct rtable *rth)
@@ -595,10 +595,10 @@ static struct rtable **rt_remove_balance
 		if (((*rthp)->u.dst.flags & DST_BALANCED) != 0  &&
 		    compare_keys(&(*rthp)->fl, &expentry->fl)) {
 			if (*rthp == expentry) {
-				*rthp = rth->u.rt_next;
+				*rthp = rth->u.dst.rt_next;
 				continue;
 			} else {
-				*rthp = rth->u.rt_next;
+				*rthp = rth->u.dst.rt_next;
 				rt_free(rth);
 				if (removed_count)
 					++(*removed_count);
@@ -606,9 +606,9 @@ static struct rtable **rt_remove_balance
 		} else {
 			if (!((*rthp)->u.dst.flags & DST_BALANCED) &&
 			    passedexpired && !nextstep)
-				nextstep = &rth->u.rt_next;
+				nextstep = &rth->u.dst.rt_next;
 
-			rthp = &rth->u.rt_next;
+			rthp = &rth->u.dst.rt_next;
 		}
 	}
 
@@ -649,12 +649,12 @@ static void rt_check_expire(unsigned lon
 				/* Entry is expired even if it is in use */
 				if (time_before_eq(now, rth->u.dst.expires)) {
 					tmo >>= 1;
-					rthp = &rth->u.rt_next;
+					rthp = &rth->u.dst.rt_next;
 					continue;
 				}
 			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
 				tmo >>= 1;
-				rthp = &rth->u.rt_next;
+				rthp = &rth->u.dst.rt_next;
 				continue;
 			}
 
@@ -668,11 +668,11 @@ static void rt_check_expire(unsigned lon
 				if (!rthp)
 					break;
 			} else {
-				*rthp = rth->u.rt_next;
+				*rthp = rth->u.dst.rt_next;
 				rt_free(rth);
 			}
 #else /* CONFIG_IP_ROUTE_MULTIPATH_CACHED */
- 			*rthp = rth->u.rt_next;
+ 			*rthp = rth->u.dst.rt_next;
  			rt_free(rth);
 #endif /* CONFIG_IP_ROUTE_MULTIPATH_CACHED */
 		}
@@ -706,7 +706,7 @@ static void rt_run_flush(unsigned long d
 		spin_unlock_bh(rt_hash_lock_addr(i));
 
 		for (; rth; rth = next) {
-			next = rth->u.rt_next;
+			next = rth->u.dst.rt_next;
 			rt_free(rth);
 		}
 	}
@@ -840,7 +840,7 @@ static int rt_garbage_collect(void)
 			while ((rth = *rthp) != NULL) {
 				if (!rt_may_expire(rth, tmo, expire)) {
 					tmo >>= 1;
-					rthp = &rth->u.rt_next;
+					rthp = &rth->u.dst.rt_next;
 					continue;
 				}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
@@ -858,12 +858,12 @@ static int rt_garbage_collect(void)
 					if (!rthp)
 						break;
 				} else {
-					*rthp = rth->u.rt_next;
+					*rthp = rth->u.dst.rt_next;
 					rt_free(rth);
 					goal--;
 				}
 #else /* CONFIG_IP_ROUTE_MULTIPATH_CACHED */
-				*rthp = rth->u.rt_next;
+				*rthp = rth->u.dst.rt_next;
 				rt_free(rth);
 				goal--;
 #endif /* CONFIG_IP_ROUTE_MULTIPATH_CACHED */
@@ -947,13 +947,13 @@ restart:
 		if (compare_keys(&rth->fl, &rt->fl)) {
 #endif
 			/* Put it first */
-			*rthp = rth->u.rt_next;
+			*rthp = rth->u.dst.rt_next;
 			/*
 			 * Since lookup is lockfree, the deletion
 			 * must be visible to another weakly ordered CPU before
 			 * the insertion at the start of the hash chain.
 			 */
-			rcu_assign_pointer(rth->u.rt_next,
+			rcu_assign_pointer(rth->u.dst.rt_next,
 					   rt_hash_table[hash].chain);
 			/*
 			 * Since lookup is lockfree, the update writes
@@ -983,7 +983,7 @@ restart:
 
 		chain_length++;
 
-		rthp = &rth->u.rt_next;
+		rthp = &rth->u.dst.rt_next;
 	}
 
 	if (cand) {
@@ -994,7 +994,7 @@ restart:
 		 * only 2 entries per bucket. We will see.
 		 */
 		if (chain_length > ip_rt_gc_elasticity) {
-			*candp = cand->u.rt_next;
+			*candp = cand->u.dst.rt_next;
 			rt_free(cand);
 		}
 	}
@@ -1034,13 +1034,13 @@ restart:
 		}
 	}
 
-	rt->u.rt_next = rt_hash_table[hash].chain;
+	rt->u.dst.rt_next = rt_hash_table[hash].chain;
 #if RT_CACHE_DEBUG >= 2
-	if (rt->u.rt_next) {
+	if (rt->u.dst.rt_next) {
 		struct rtable *trt;
 		printk(KERN_DEBUG "rt_cache @%02x: %u.%u.%u.%u", hash,
 		       NIPQUAD(rt->rt_dst));
-		for (trt = rt->u.rt_next; trt; trt = trt->u.rt_next)
+		for (trt = rt->u.dst.rt_next; trt; trt = trt->u.dst.rt_next)
 			printk(" . %u.%u.%u.%u", NIPQUAD(trt->rt_dst));
 		printk("\n");
 	}
@@ -1117,9 +1117,9 @@ static void rt_del(unsigned hash, struct
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	ip_rt_put(rt);
 	for (rthp = &rt_hash_table[hash].chain; *rthp;
-	     rthp = &(*rthp)->u.rt_next)
+	     rthp = &(*rthp)->u.dst.rt_next)
 		if (*rthp == rt) {
-			*rthp = rt->u.rt_next;
+			*rthp = rt->u.dst.rt_next;
 			rt_free(rt);
 			break;
 		}
@@ -1167,7 +1167,7 @@ void ip_rt_redirect(__be32 old_gw, __be3
 				    rth->fl.fl4_src != skeys[i] ||
 				    rth->fl.oif != ikeys[k] ||
 				    rth->fl.iif != 0) {
-					rthp = &rth->u.rt_next;
+					rthp = &rth->u.dst.rt_next;
 					continue;
 				}
 
@@ -1416,7 +1416,7 @@ unsigned short ip_rt_frag_needed(struct 
 
 		rcu_read_lock();
 		for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-		     rth = rcu_dereference(rth->u.rt_next)) {
+		     rth = rcu_dereference(rth->u.dst.rt_next)) {
 			if (rth->fl.fl4_dst == daddr &&
 			    rth->fl.fl4_src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
@@ -2099,7 +2099,7 @@ int ip_route_input(struct sk_buff *skb, 
 
 	rcu_read_lock();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-	     rth = rcu_dereference(rth->u.rt_next)) {
+	     rth = rcu_dereference(rth->u.dst.rt_next)) {
 		if (rth->fl.fl4_dst == daddr &&
 		    rth->fl.fl4_src == saddr &&
 		    rth->fl.iif == iif &&
@@ -2563,7 +2563,7 @@ int __ip_route_output_key(struct rtable 
 
 	rcu_read_lock_bh();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-		rth = rcu_dereference(rth->u.rt_next)) {
+		rth = rcu_dereference(rth->u.dst.rt_next)) {
 		if (rth->fl.fl4_dst == flp->fl4_dst &&
 		    rth->fl.fl4_src == flp->fl4_src &&
 		    rth->fl.iif == 0 &&
@@ -2824,7 +2824,7 @@ int ip_rt_dump(struct sk_buff *skb,  str
 			s_idx = 0;
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference(rt_hash_table[h].chain), idx = 0; rt;
-		     rt = rcu_dereference(rt->u.rt_next), idx++) {
+		     rt = rcu_dereference(rt->u.dst.rt_next), idx++) {
 			if (idx < s_idx)
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);

--------------080009000803000200070008--
