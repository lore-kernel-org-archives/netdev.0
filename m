From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 07:14:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.071451.108794109.davem@redhat.com>
References: <20030609065211.GB20613@netnation.com>
	<20030608.235622.38700262.davem@redhat.com>
	<20030609081803.GF20613@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
   hadi@shell.cyberus.ca, Robert.Olsson@data.slu.se, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030609081803.GF20613@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok Simon/Robert/Mr.Foo :), give this a try, it's my final installment
for the evening :-)

If this shows improvement, we can make even larger strides
by moving the struct flowi up into struct dst_entry.

--- net/core/dst.c.~1~	Mon Jun  9 01:47:26 2003
+++ net/core/dst.c	Mon Jun  9 03:13:56 2003
@@ -122,13 +122,34 @@ void * dst_alloc(struct dst_ops * ops)
 	dst = kmem_cache_alloc(ops->kmem_cachep, SLAB_ATOMIC);
 	if (!dst)
 		return NULL;
-	memset(dst, 0, ops->entry_size);
+	dst->next = NULL;
 	atomic_set(&dst->__refcnt, 0);
-	dst->ops = ops;
+	dst->__use = 0;
+	dst->child = NULL;
+	dst->dev = NULL;
+	dst->obsolete = 0;
+	dst->flags = 0;
 	dst->lastuse = jiffies;
+	dst->expires = 0;
+	dst->header_len = 0;
+	dst->trailer_len = 0;
+	memset(dst->metrics, 0, sizeof(dst->metrics));
 	dst->path = dst;
+	dst->rate_last = 0;
+	dst->rate_tokens = 0;
+	dst->error = 0;
+	dst->neighbour = NULL;
+	dst->hh = NULL;
+	dst->xfrm = NULL;
 	dst->input = dst_discard;
 	dst->output = dst_blackhole;
+#ifdef CONFIG_NET_CLS_ROUTE
+	dst->tclassid = 0;
+#endif
+	dst->ops = ops;
+	INIT_RCU_HEAD(&dst->rcu_head);
+	memset(dst->info, 0,
+	       ops->entry_size - offsetof(struct dst_entry, info));
 #if RT_CACHE_DEBUG >= 2 
 	atomic_inc(&dst_total);
 #endif
--- net/ipv4/route.c.~1~	Sun Jun  8 23:28:00 2003
+++ net/ipv4/route.c	Mon Jun  9 06:49:15 2003
@@ -88,6 +88,7 @@
 #include <linux/random.h>
 #include <linux/jhash.h>
 #include <linux/rcupdate.h>
+#include <linux/prefetch.h>
 #include <net/protocol.h>
 #include <net/ip.h>
 #include <net/route.h>
@@ -882,6 +883,60 @@ static void rt_del(unsigned hash, struct
 	spin_unlock_bh(&rt_hash_table[hash].lock);
 }
 
+static void __rt_hash_shrink(unsigned int hash)
+{
+	struct rtable *rth, **rthp;
+	struct rtable *cand, **candp;
+	unsigned int min_use = ~(unsigned int) 0;
+
+	spin_lock_bh(&rt_hash_table[hash].lock);
+	cand = NULL;
+	candp = NULL;
+	rthp = &rt_hash_table[hash].chain;
+	while ((rth = *rthp) != NULL) {
+		if (!atomic_read(&rth->u.dst.__refcnt) &&
+		    ((unsigned int) rth->u.dst.__use) < min_use) {
+			cand = rth;
+			candp = rthp;
+			min_use = rth->u.dst.__use;
+		}
+		rthp = &rth->u.rt_next;
+	}
+	if (cand) {
+		*candp = cand->u.rt_next;
+		rt_free(cand);
+	}
+
+	spin_unlock_bh(&rt_hash_table[hash].lock);
+}
+
+static inline struct rtable *ip_rt_dst_alloc(unsigned int hash)
+{
+	if (atomic_read(&ipv4_dst_ops.entries) >
+	    ipv4_dst_ops.gc_thresh)
+		__rt_hash_shrink(hash);
+
+	return dst_alloc(&ipv4_dst_ops);
+}
+
+static void ip_rt_copy(struct rtable *rt, struct rtable *old)
+{
+	memcpy(rt, old, sizeof(*rt));
+
+	INIT_RCU_HEAD(&rt->u.dst.rcu_head);
+	rt->u.dst.__use		= 1;
+	atomic_set(&rt->u.dst.__refcnt, 1);
+	rt->u.dst.child		= NULL;
+	if (rt->u.dst.dev)
+		dev_hold(rt->u.dst.dev);
+	rt->u.dst.obsolete	= 0;
+	rt->u.dst.lastuse	= jiffies;
+	rt->u.dst.path		= &rt->u.dst;
+	rt->u.dst.neighbour	= NULL;
+	rt->u.dst.hh		= NULL;
+	rt->u.dst.xfrm		= NULL;
+}
+
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
 		    u32 saddr, u8 tos, struct net_device *dev)
 {
@@ -912,9 +967,10 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 
 	for (i = 0; i < 2; i++) {
 		for (k = 0; k < 2; k++) {
-			unsigned hash = rt_hash_code(daddr,
-						     skeys[i] ^ (ikeys[k] << 5),
-						     tos);
+			unsigned int hash = rt_hash_code(daddr,
+							 skeys[i] ^
+							 (ikeys[k] << 5),
+							 tos);
 
 			rthp=&rt_hash_table[hash].chain;
 
@@ -942,7 +998,7 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 				dst_hold(&rth->u.dst);
 				rcu_read_unlock();
 
-				rt = dst_alloc(&ipv4_dst_ops);
+				rt = ip_rt_dst_alloc(hash);
 				if (rt == NULL) {
 					ip_rt_put(rth);
 					in_dev_put(in_dev);
@@ -950,19 +1006,7 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 				}
 
 				/* Copy all the information. */
-				*rt = *rth;
- 				INIT_RCU_HEAD(&rt->u.dst.rcu_head);
-				rt->u.dst.__use		= 1;
-				atomic_set(&rt->u.dst.__refcnt, 1);
-				rt->u.dst.child		= NULL;
-				if (rt->u.dst.dev)
-					dev_hold(rt->u.dst.dev);
-				rt->u.dst.obsolete	= 0;
-				rt->u.dst.lastuse	= jiffies;
-				rt->u.dst.path		= &rt->u.dst;
-				rt->u.dst.neighbour	= NULL;
-				rt->u.dst.hh		= NULL;
-				rt->u.dst.xfrm		= NULL;
+				ip_rt_copy(rt, rth);
 
 				rt->rt_flags		|= RTCF_REDIRECTED;
 
@@ -1352,7 +1396,7 @@ static void rt_set_nexthop(struct rtable
 static int ip_route_input_mc(struct sk_buff *skb, u32 daddr, u32 saddr,
 				u8 tos, struct net_device *dev, int our)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct rtable *rth;
 	u32 spec_dst;
 	struct in_device *in_dev = in_dev_get(dev);
@@ -1375,7 +1419,9 @@ static int ip_route_input_mc(struct sk_b
 					dev, &spec_dst, &itag) < 0)
 		goto e_inval;
 
-	rth = dst_alloc(&ipv4_dst_ops);
+	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5), tos);
+
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1421,7 +1467,6 @@ static int ip_route_input_mc(struct sk_b
 	RT_CACHE_STAT_INC(in_slow_mc);
 
 	in_dev_put(in_dev);
-	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5), tos);
 	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
 
 e_nobufs:
@@ -1584,45 +1629,42 @@ int ip_route_input_slow(struct sk_buff *
 			goto e_inval;
 	}
 
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
 	atomic_set(&rth->u.dst.__refcnt, 1);
-	rth->u.dst.flags= DST_HOST;
-	if (in_dev->cnf.no_policy)
-		rth->u.dst.flags |= DST_NOPOLICY;
-	if (in_dev->cnf.no_xfrm)
-		rth->u.dst.flags |= DST_NOXFRM;
-	rth->fl.fl4_dst	= daddr;
+	rth->u.dst.dev	= out_dev->dev;
+	dev_hold(out_dev->dev);
+	rth->u.dst.flags= (DST_HOST |
+			   (in_dev->cnf.no_policy ? DST_NOPOLICY : 0) |
+			   (in_dev->cnf.no_xfrm ? DST_NOXFRM : 0));
+	rth->u.dst.input = ip_forward;
+	rth->u.dst.output = ip_output;
+
+	rth->rt_flags	= flags;
+	rth->rt_src	= saddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
+	rth->rt_iif 	= dev->ifindex;
+	rth->rt_gateway	= daddr;
+
+	rth->fl.iif	= dev->ifindex;
+	rth->fl.fl4_dst	= daddr;
+	rth->fl.fl4_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	rth->fl.fl4_fwmark= skb->nfmark;
 #endif
-	rth->fl.fl4_src	= saddr;
-	rth->rt_src	= saddr;
-	rth->rt_gateway	= daddr;
+	rth->fl.fl4_tos	= tos;
+	rth->rt_spec_dst= spec_dst;
 #ifdef CONFIG_IP_ROUTE_NAT
 	rth->rt_src_map	= fl.fl4_src;
 	rth->rt_dst_map	= fl.fl4_dst;
-	if (flags&RTCF_DNAT)
+	if (flags & RTCF_DNAT)
 		rth->rt_gateway	= fl.fl4_dst;
 #endif
-	rth->rt_iif 	=
-	rth->fl.iif	= dev->ifindex;
-	rth->u.dst.dev	= out_dev->dev;
-	dev_hold(rth->u.dst.dev);
-	rth->fl.oif 	= 0;
-	rth->rt_spec_dst= spec_dst;
-
-	rth->u.dst.input = ip_forward;
-	rth->u.dst.output = ip_output;
 
 	rt_set_nexthop(rth, &res, itag);
 
-	rth->rt_flags = flags;
-
 #ifdef CONFIG_NET_FASTROUTE
 	if (netdev_fastroute && !(flags&(RTCF_NAT|RTCF_MASQ|RTCF_DOREDIRECT))) {
 		struct net_device *odev = rth->u.dst.dev;
@@ -1663,45 +1705,45 @@ brd_input:
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
+	atomic_set(&rth->u.dst.__refcnt, 1);
+	rth->u.dst.dev	= &loopback_dev;
+	dev_hold(&loopback_dev);
+	rth->u.dst.flags= (DST_HOST |
+			   (in_dev->cnf.no_policy ? DST_NOPOLICY : 0));
+	rth->u.dst.input= ip_local_deliver;
 	rth->u.dst.output= ip_rt_bug;
+#ifdef CONFIG_NET_CLS_ROUTE
+	rth->u.dst.tclassid = itag;
+#endif
 
-	atomic_set(&rth->u.dst.__refcnt, 1);
-	rth->u.dst.flags= DST_HOST;
-	if (in_dev->cnf.no_policy)
-		rth->u.dst.flags |= DST_NOPOLICY;
-	rth->fl.fl4_dst	= daddr;
+	rth->rt_flags 	= flags|RTCF_LOCAL;
+	rth->rt_type	= res.type;
+	rth->rt_src	= saddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
+	rth->rt_iif	= dev->ifindex;
+	rth->rt_gateway	= daddr;
+
+	rth->fl.iif	= dev->ifindex;
+	rth->fl.fl4_dst	= daddr;
+	rth->fl.fl4_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	rth->fl.fl4_fwmark= skb->nfmark;
 #endif
-	rth->fl.fl4_src	= saddr;
-	rth->rt_src	= saddr;
+	rth->fl.fl4_tos	= tos;
+	rth->rt_spec_dst= spec_dst;
 #ifdef CONFIG_IP_ROUTE_NAT
 	rth->rt_dst_map	= fl.fl4_dst;
 	rth->rt_src_map	= fl.fl4_src;
 #endif
-#ifdef CONFIG_NET_CLS_ROUTE
-	rth->u.dst.tclassid = itag;
-#endif
-	rth->rt_iif	=
-	rth->fl.iif	= dev->ifindex;
-	rth->u.dst.dev	= &loopback_dev;
-	dev_hold(rth->u.dst.dev);
-	rth->rt_gateway	= daddr;
-	rth->rt_spec_dst= spec_dst;
-	rth->u.dst.input= ip_local_deliver;
-	rth->rt_flags 	= flags|RTCF_LOCAL;
 	if (res.type == RTN_UNREACHABLE) {
 		rth->u.dst.input= ip_error;
 		rth->u.dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
-	rth->rt_type	= res.type;
 	goto intern;
 
 no_route:
@@ -1767,6 +1809,8 @@ int ip_route_input(struct sk_buff *skb, 
 	tos &= IPTOS_RT_MASK;
 	hash = rt_hash_code(daddr, saddr ^ (iif << 5), tos);
 
+	prefetch(&rt_hash_table[hash].chain->fl);
+
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
 		smp_read_barrier_depends();
@@ -2048,7 +2092,10 @@ make_route:
 		}
 	}
 
-	rth = dst_alloc(&ipv4_dst_ops);
+	hash = rt_hash_code(oldflp->fl4_dst,
+			    oldflp->fl4_src ^ (oldflp->oif << 5), tos);
+
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
@@ -2104,10 +2151,6 @@ make_route:
 
 	rt_set_nexthop(rth, &res, 0);
 	
-
-	rth->rt_flags = flags;
-
-	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src ^ (oldflp->oif << 5), tos);
 	err = rt_intern_hash(hash, rth, rp);
 done:
 	if (free_res)
@@ -2132,6 +2175,8 @@ int __ip_route_output_key(struct rtable 
 	struct rtable *rth;
 
 	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5), flp->fl4_tos);
+
+	prefetch(&rt_hash_table[hash].chain->fl);
 
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
