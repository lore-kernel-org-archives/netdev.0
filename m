From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Remove flowi from struct rtable.
Date: Fri, 04 Mar 2011 22:12:14 -0800 (PST)
Message-ID: <20110304.221214.189707201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59609
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750720Ab1CEGLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 01:11:37 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AC76824C087
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2011 22:12:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The only necessary parts are the src/dst addresses, the
interface indexes, the TOS, and the mark.

The rest is unnecessary bloat, which amounts to nearly
50 bytes on 64-bit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |   22 ++++---
 net/ipv4/icmp.c         |    2 +-
 net/ipv4/ipmr.c         |   52 +++++++++++++----
 net/ipv4/route.c        |  153 +++++++++++++++++++++++++---------------------
 net/ipv4/xfrm4_policy.c |    7 ++-
 net/sched/cls_route.c   |    2 +-
 net/sched/em_meta.c     |    2 +-
 7 files changed, 146 insertions(+), 94 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 8905d90..9257f5f 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -53,16 +53,20 @@ struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
 
-	/* Cache lookup keys */
-	struct flowi		fl;
+	/* Lookup key. */
+	__be32			rt_key_dst;
+	__be32			rt_key_src;
 
 	int			rt_genid;
 	unsigned		rt_flags;
 	__u16			rt_type;
+	__u8			rt_tos;
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
 	int			rt_iif;
+	int			rt_oif;
+	__u32			rt_mark;
 
 	/* Info on neighbour */
 	__be32			rt_gateway;
@@ -76,12 +80,12 @@ struct rtable {
 
 static inline bool rt_is_input_route(struct rtable *rt)
 {
-	return rt->fl.iif != 0;
+	return rt->rt_iif != 0;
 }
 
 static inline bool rt_is_output_route(struct rtable *rt)
 {
-	return rt->fl.iif == 0;
+	return rt->rt_iif == 0;
 }
 
 struct ip_rt_acct {
@@ -212,11 +216,11 @@ static inline struct rtable *ip_route_newports(struct rtable *rt,
 					       __be16 dport, struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi fl = { .oif = rt->fl.oif,
-				    .mark = rt->fl.mark,
-				    .fl4_dst = rt->fl.fl4_dst,
-				    .fl4_src = rt->fl.fl4_src,
-				    .fl4_tos = rt->fl.fl4_tos,
+		struct flowi fl = { .oif = rt->rt_oif,
+				    .mark = rt->rt_mark,
+				    .fl4_dst = rt->rt_key_dst,
+				    .fl4_src = rt->rt_key_src,
+				    .fl4_tos = rt->rt_tos,
 				    .proto = protocol,
 				    .fl_ip_sport = sport,
 				    .fl_ip_dport = dport };
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 994a785..1771ce6 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -563,7 +563,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		rcu_read_lock();
 		if (rt_is_input_route(rt) &&
 		    net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
-			dev = dev_get_by_index_rcu(net, rt->fl.iif);
+			dev = dev_get_by_index_rcu(net, rt->rt_iif);
 
 		if (dev)
 			saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 26ca2f2..9d5f634 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1813,12 +1813,22 @@ int ip_mr_input(struct sk_buff *skb)
 	if (IPCB(skb)->flags & IPSKB_FORWARDED)
 		goto dont_forward;
 
-	err = ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt);
-	if (err < 0) {
-		kfree_skb(skb);
-		return err;
+	{
+		struct rtable *rt = skb_rtable(skb);
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+		err = ipmr_fib_lookup(net, &fl, &mrt);
+		if (err < 0) {
+			kfree_skb(skb);
+			return err;
+		}
 	}
-
 	if (!local) {
 		if (IPCB(skb)->opt.router_alert) {
 			if (ip_call_ra_chain(skb))
@@ -1946,9 +1956,19 @@ int pim_rcv_v1(struct sk_buff *skb)
 
 	pim = igmp_hdr(skb);
 
-	if (ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt) < 0)
-		goto drop;
-
+	{
+		struct rtable *rt = skb_rtable(skb);
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
+			goto drop;
+	}
 	if (!mrt->mroute_do_pim ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
@@ -1978,9 +1998,19 @@ static int pim_rcv(struct sk_buff *skb)
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
 
-	if (ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt) < 0)
-		goto drop;
-
+	{
+		struct rtable *rt = skb_rtable(skb);
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
+			goto drop;
+	}
 	if (__pim_rcv(mrt, skb, sizeof(*pim))) {
 drop:
 		kfree_skb(skb);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 602473c..92a24ea 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -424,7 +424,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			dst_metric(&r->dst, RTAX_WINDOW),
 			(int)((dst_metric(&r->dst, RTAX_RTT) >> 3) +
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
-			r->fl.fl4_tos,
+			r->rt_tos,
 			r->dst.hh ? atomic_read(&r->dst.hh->hh_refcnt) : -1,
 			r->dst.hh ? (r->dst.hh->hh_output ==
 				       dev_queue_xmit) : 0,
@@ -711,22 +711,22 @@ static inline bool rt_caching(const struct net *net)
 		net->ipv4.sysctl_rt_cache_rebuild_count;
 }
 
-static inline bool compare_hash_inputs(const struct flowi *fl1,
-					const struct flowi *fl2)
+static inline bool compare_hash_inputs(const struct rtable *rt1,
+				       const struct rtable *rt2)
 {
-	return ((((__force u32)fl1->fl4_dst ^ (__force u32)fl2->fl4_dst) |
-		((__force u32)fl1->fl4_src ^ (__force u32)fl2->fl4_src) |
-		(fl1->iif ^ fl2->iif)) == 0);
+	return ((((__force u32)rt1->rt_key_dst ^ (__force u32)rt2->rt_key_dst) |
+		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
+		(rt1->rt_iif ^ rt2->rt_iif)) == 0);
 }
 
-static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
+static inline int compare_keys(struct rtable *rt1, struct rtable *rt2)
 {
-	return (((__force u32)fl1->fl4_dst ^ (__force u32)fl2->fl4_dst) |
-		((__force u32)fl1->fl4_src ^ (__force u32)fl2->fl4_src) |
-		(fl1->mark ^ fl2->mark) |
-		(*(u16 *)&fl1->fl4_tos ^ *(u16 *)&fl2->fl4_tos) |
-		(fl1->oif ^ fl2->oif) |
-		(fl1->iif ^ fl2->iif)) == 0;
+	return (((__force u32)rt1->rt_key_dst ^ (__force u32)rt2->rt_key_dst) |
+		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
+		(rt1->rt_mark ^ rt2->rt_mark) |
+		(rt1->rt_tos ^ rt2->rt_tos) |
+		(rt1->rt_oif ^ rt2->rt_oif) |
+		(rt1->rt_iif ^ rt2->rt_iif)) == 0;
 }
 
 static inline int compare_netns(struct rtable *rt1, struct rtable *rt2)
@@ -813,7 +813,7 @@ static int has_noalias(const struct rtable *head, const struct rtable *rth)
 	const struct rtable *aux = head;
 
 	while (aux != rth) {
-		if (compare_hash_inputs(&aux->fl, &rth->fl))
+		if (compare_hash_inputs(aux, rth))
 			return 0;
 		aux = rcu_dereference_protected(aux->dst.rt_next, 1);
 	}
@@ -1073,7 +1073,7 @@ restart:
 			rt_free(rth);
 			continue;
 		}
-		if (compare_keys(&rth->fl, &rt->fl) && compare_netns(rth, rt)) {
+		if (compare_keys(rth, rt) && compare_netns(rth, rt)) {
 			/* Put it first */
 			*rthp = rth->dst.rt_next;
 			/*
@@ -1136,7 +1136,7 @@ restart:
 			rt_emergency_hash_rebuild(net);
 			spin_unlock_bh(rt_hash_lock_addr(hash));
 
-			hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
+			hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
 					ifindex, rt_genid(net));
 			goto restart;
 		}
@@ -1344,12 +1344,12 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			ip_rt_put(rt);
 			ret = NULL;
 		} else if (rt->rt_flags & RTCF_REDIRECTED) {
-			unsigned hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
-						rt->fl.oif,
+			unsigned hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
+						rt->rt_oif,
 						rt_genid(dev_net(dst->dev)));
 #if RT_CACHE_DEBUG >= 1
 			printk(KERN_DEBUG "ipv4_negative_advice: redirect to %pI4/%02x dropped\n",
-				&rt->rt_dst, rt->fl.fl4_tos);
+				&rt->rt_dst, rt->rt_tos);
 #endif
 			rt_del(hash, rt);
 			ret = NULL;
@@ -1697,8 +1697,17 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 	if (rt_is_output_route(rt))
 		src = rt->rt_src;
 	else {
+		struct flowi fl = {
+			.fl4_dst = rt->rt_key_dst,
+			.fl4_src = rt->rt_key_src,
+			.fl4_tos = rt->rt_tos,
+			.oif = rt->rt_oif,
+			.iif = rt->rt_iif,
+			.mark = rt->rt_mark,
+		};
+
 		rcu_read_lock();
-		if (fib_lookup(dev_net(rt->dst.dev), &rt->fl, &res) == 0)
+		if (fib_lookup(dev_net(rt->dst.dev), &fl, &res) == 0)
 			src = FIB_RES_PREFSRC(res);
 		else
 			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
@@ -1748,7 +1757,8 @@ static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
+static void rt_init_metrics(struct rtable *rt, const struct flowi *oldflp,
+			    struct fib_info *fi)
 {
 	struct inet_peer *peer;
 	int create = 0;
@@ -1756,7 +1766,7 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 	/* If a peer entry exists for this destination, we must hook
 	 * it up in order to get at cached metrics.
 	 */
-	if (rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)
+	if (oldflp && (oldflp->flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
@@ -1783,7 +1793,8 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 	}
 }
 
-static void rt_set_nexthop(struct rtable *rt, const struct fib_result *res,
+static void rt_set_nexthop(struct rtable *rt, const struct flowi *oldflp,
+			   const struct fib_result *res,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
 	struct dst_entry *dst = &rt->dst;
@@ -1792,7 +1803,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct fib_result *res,
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		rt_init_metrics(rt, fi);
+		rt_init_metrics(rt, oldflp, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
@@ -1861,20 +1872,19 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	rth->dst.output = ip_rt_bug;
 
-	rth->fl.fl4_dst	= daddr;
+	rth->rt_key_dst	= daddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.mark    = skb->mark;
-	rth->fl.fl4_src	= saddr;
+	rth->rt_tos	= tos;
+	rth->rt_mark    = skb->mark;
+	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
-	rth->rt_iif	=
-	rth->fl.iif	= dev->ifindex;
+	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= init_net.loopback_dev;
 	dev_hold(rth->dst.dev);
-	rth->fl.oif	= 0;
+	rth->rt_oif	= 0;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_genid	= rt_genid(dev_net(dev));
@@ -1999,25 +2009,24 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->fl.fl4_dst	= daddr;
+	rth->rt_key_dst	= daddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.mark    = skb->mark;
-	rth->fl.fl4_src	= saddr;
+	rth->rt_tos	= tos;
+	rth->rt_mark    = skb->mark;
+	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 	rth->rt_gateway	= daddr;
-	rth->rt_iif 	=
-		rth->fl.iif	= in_dev->dev->ifindex;
+	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->dst.dev	= (out_dev)->dev;
 	dev_hold(rth->dst.dev);
-	rth->fl.oif 	= 0;
+	rth->rt_oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 
-	rt_set_nexthop(rth, res, res->fi, res->type, itag);
+	rt_set_nexthop(rth, NULL, res, res->fi, res->type, itag);
 
 	rth->rt_flags = flags;
 
@@ -2172,17 +2181,16 @@ local_input:
 	rth->dst.output= ip_rt_bug;
 	rth->rt_genid = rt_genid(net);
 
-	rth->fl.fl4_dst	= daddr;
+	rth->rt_key_dst	= daddr;
 	rth->rt_dst	= daddr;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.mark    = skb->mark;
-	rth->fl.fl4_src	= saddr;
+	rth->rt_tos	= tos;
+	rth->rt_mark    = skb->mark;
+	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
-	rth->rt_iif	=
-	rth->fl.iif	= dev->ifindex;
+	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= net->loopback_dev;
 	dev_hold(rth->dst.dev);
 	rth->rt_gateway	= daddr;
@@ -2261,12 +2269,12 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 	     rth = rcu_dereference(rth->dst.rt_next)) {
-		if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr) |
-		     ((__force u32)rth->fl.fl4_src ^ (__force u32)saddr) |
-		     (rth->fl.iif ^ iif) |
-		     rth->fl.oif |
-		     (rth->fl.fl4_tos ^ tos)) == 0 &&
-		    rth->fl.mark == skb->mark &&
+		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
+		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
+		     (rth->rt_iif ^ iif) |
+		     rth->rt_oif |
+		     (rth->rt_tos ^ tos)) == 0 &&
+		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
 			if (noref) {
@@ -2374,11 +2382,11 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-	rth->fl.fl4_dst	= oldflp->fl4_dst;
-	rth->fl.fl4_tos	= tos;
-	rth->fl.fl4_src	= oldflp->fl4_src;
-	rth->fl.oif	= oldflp->oif;
-	rth->fl.mark    = oldflp->mark;
+	rth->rt_key_dst	= oldflp->fl4_dst;
+	rth->rt_tos	= tos;
+	rth->rt_key_src	= oldflp->fl4_src;
+	rth->rt_oif	= oldflp->oif;
+	rth->rt_mark    = oldflp->mark;
 	rth->rt_dst	= fl->fl4_dst;
 	rth->rt_src	= fl->fl4_src;
 	rth->rt_iif	= 0;
@@ -2416,7 +2424,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, res, fi, type, 0);
+	rt_set_nexthop(rth, oldflp, res, fi, type, 0);
 
 	rth->rt_flags = flags;
 	return rth;
@@ -2629,12 +2637,12 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
 	rcu_read_lock_bh();
 	for (rth = rcu_dereference_bh(rt_hash_table[hash].chain); rth;
 		rth = rcu_dereference_bh(rth->dst.rt_next)) {
-		if (rth->fl.fl4_dst == flp->fl4_dst &&
-		    rth->fl.fl4_src == flp->fl4_src &&
+		if (rth->rt_key_dst == flp->fl4_dst &&
+		    rth->rt_key_src == flp->fl4_src &&
 		    rt_is_output_route(rth) &&
-		    rth->fl.oif == flp->oif &&
-		    rth->fl.mark == flp->mark &&
-		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
+		    rth->rt_oif == flp->oif &&
+		    rth->rt_mark == flp->mark &&
+		    !((rth->rt_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
@@ -2693,7 +2701,12 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->fl = ort->fl;
+		rt->rt_key_dst = ort->rt_key_dst;
+		rt->rt_key_src = ort->rt_key_src;
+		rt->rt_tos = ort->rt_tos;
+		rt->rt_iif = ort->rt_iif;
+		rt->rt_oif = ort->rt_oif;
+		rt->rt_mark = ort->rt_mark;
 
 		rt->rt_genid = rt_genid(net);
 		rt->rt_flags = ort->rt_flags;
@@ -2756,7 +2769,7 @@ static int rt_fill_info(struct net *net,
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
-	r->rtm_tos	= rt->fl.fl4_tos;
+	r->rtm_tos	= rt->rt_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
 	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
@@ -2768,9 +2781,9 @@ static int rt_fill_info(struct net *net,
 
 	NLA_PUT_BE32(skb, RTA_DST, rt->rt_dst);
 
-	if (rt->fl.fl4_src) {
+	if (rt->rt_key_src) {
 		r->rtm_src_len = 32;
-		NLA_PUT_BE32(skb, RTA_SRC, rt->fl.fl4_src);
+		NLA_PUT_BE32(skb, RTA_SRC, rt->rt_key_src);
 	}
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
@@ -2780,7 +2793,7 @@ static int rt_fill_info(struct net *net,
 #endif
 	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != rt->fl.fl4_src)
+	else if (rt->rt_src != rt->rt_key_src)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
 
 	if (rt->rt_dst != rt->rt_gateway)
@@ -2789,8 +2802,8 @@ static int rt_fill_info(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	if (rt->fl.mark)
-		NLA_PUT_BE32(skb, RTA_MARK, rt->fl.mark);
+	if (rt->rt_mark)
+		NLA_PUT_BE32(skb, RTA_MARK, rt->rt_mark);
 
 	error = rt->dst.error;
 	expires = (rt->peer && rt->peer->pmtu_expires) ?
@@ -2824,7 +2837,7 @@ static int rt_fill_info(struct net *net,
 			}
 		} else
 #endif
-			NLA_PUT_U32(skb, RTA_IIF, rt->fl.iif);
+			NLA_PUT_U32(skb, RTA_IIF, rt->rt_iif);
 	}
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, id, ts, tsage,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 45b8214..c70c42e 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -70,7 +70,12 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 {
 	struct rtable *rt = (struct rtable *)xdst->route;
 
-	xdst->u.rt.fl = *fl;
+	rt->rt_key_dst = fl->fl4_dst;
+	rt->rt_key_src = fl->fl4_src;
+	rt->rt_tos = fl->fl4_tos;
+	rt->rt_iif = fl->iif;
+	rt->rt_oif = fl->oif;
+	rt->rt_mark = fl->mark;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index d580cdf..a9079053 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -143,7 +143,7 @@ static int route4_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	if (head == NULL)
 		goto old_method;
 
-	iif = ((struct rtable *)dst)->fl.iif;
+	iif = ((struct rtable *)dst)->rt_iif;
 
 	h = route4_fastmap_hash(id, iif);
 	if (id == head->fastmap[h].id &&
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index e5e1747..a4de67e 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -264,7 +264,7 @@ META_COLLECTOR(int_rtiif)
 	if (unlikely(skb_rtable(skb) == NULL))
 		*err = -1;
 	else
-		dst->value = skb_rtable(skb)->fl.iif;
+		dst->value = skb_rtable(skb)->rt_iif;
 }
 
 /**************************************************************************
-- 
1.7.4.1

