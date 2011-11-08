From: David Miller <davem@davemloft.net>
Subject: Re: dst->obsolete has become pointless
Date: Tue, 08 Nov 2011 13:59:01 -0500 (EST)
Message-ID: <20111108.135901.1506278599930259562.davem@davemloft.net>
References: <20111104.230910.520924516201406800.davem@davemloft.net>
	<20111108093424.GG22141@secunet.com>
	<20111108.122020.1080743546477280623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755586Ab1KHTAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:00:21 -0500
In-Reply-To: <20111108.122020.1080743546477280623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 08 Nov 2011 12:20:20 -0500 (EST)

> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 8 Nov 2011 10:34:24 +0100
> 
>> I don't know what to do with DecNET, but we probaply need to decide
>> about the future of dst->obsolete before we can fix the ipv4 PMTU
>> problems. Possible fixes might depend on whether ->dst_check() is
>> always invoked or not.
> 
> Simplest thing to do is to move dst->obsolete check into DecNET's
> ->dst_check() handler, then call ->dst_check() unconditionally.
> 
> Then we can just set dst->obsolete to zero for all route types,
> and kill the "initial_obsolete" argument to dst_alloc() and
> associated logic.

What I meant is something like the following patch.  It needs more
work because it turns out some cases in ipv6 and xfrm_policy really
want dst_check to be avoided for special routes.

--------------------
net: Kill pointless and misleading checks on dst->obsolete.

dst->obsolete is set to -1 for all ipv4 and ipv6 routes.  Therefore
the check guarding the invocation dst_ops->dst_check() is completely
pointless and misleads the reader into thinking we elide the call
in the common case.

What this value really means these days is that dst_free() has been
called on the route.

Therefore rename it to dst->freed, and make it take on only the values
"0" and "1".

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/dst.h b/include/net/dst.h
index 4fb6c43..7bd2fdb 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -22,7 +22,7 @@
 
 /* Each dst_entry has reference count and sits in some parent list(s).
  * When it is removed from parent list, it is "freed" (dst_free).
- * After this it enters dead state (dst->obsolete > 0) and if its refcnt
+ * After this it enters dead state (dst->freed == 1) and if its refcnt
  * is zero, it can be destroyed immediately, otherwise it is added
  * to gc list and garbage collector periodically checks the refcnt.
  */
@@ -55,7 +55,7 @@ struct dst_entry {
 #define DST_NOCOUNT		0x0020
 
 	short			error;
-	short			obsolete;
+	unsigned short		freed;
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -369,13 +369,13 @@ static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 
 extern int dst_discard(struct sk_buff *skb);
 extern void *dst_alloc(struct dst_ops * ops, struct net_device *dev,
-		       int initial_ref, int initial_obsolete, int flags);
+		       int initial_ref, int flags);
 extern void __dst_free(struct dst_entry * dst);
 extern struct dst_entry *dst_destroy(struct dst_entry * dst);
 
 static inline void dst_free(struct dst_entry * dst)
 {
-	if (dst->obsolete > 1)
+	if (dst->freed)
 		return;
 	if (!atomic_read(&dst->__refcnt)) {
 		dst = dst_destroy(dst);
@@ -440,9 +440,7 @@ static inline int dst_input(struct sk_buff *skb)
 
 static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 {
-	if (dst->obsolete)
-		dst = dst->ops->check(dst, cookie);
-	return dst;
+	return dst->ops->check(dst, cookie);
 }
 
 extern void		dst_init(void);
diff --git a/net/core/dst.c b/net/core/dst.c
index d5e2c4c..6cb504a 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -90,11 +90,11 @@ loop:
 			 * on gc list, invalidate it and add to gc list.
 			 *
 			 * Note: this is temporary. Actually, NOHASH dst's
-			 * must be obsoleted when parent is obsoleted.
-			 * But we do not have state "obsoleted, but
+			 * must be freed when parent is freed.
+			 * But we do not have state "freed, but
 			 * referenced by parent", so it is right.
 			 */
-			if (dst->obsolete > 1)
+			if (dst->freed)
 				continue;
 
 			___dst_free(dst);
@@ -152,7 +152,7 @@ EXPORT_SYMBOL(dst_discard);
 const u32 dst_default_metrics[RTAX_MAX];
 
 void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
-		int initial_ref, int initial_obsolete, int flags)
+		int initial_ref, int flags)
 {
 	struct dst_entry *dst;
 
@@ -178,7 +178,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->input = dst_discard;
 	dst->output = dst_discard;
 	dst->error = 0;
-	dst->obsolete = initial_obsolete;
+	dst->freed = 0;
 	dst->header_len = 0;
 	dst->trailer_len = 0;
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -202,7 +202,7 @@ static void ___dst_free(struct dst_entry *dst)
 	 */
 	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP))
 		dst->input = dst->output = dst_discard;
-	dst->obsolete = 2;
+	dst->freed = 1;
 }
 
 void __dst_free(struct dst_entry *dst)
diff --git a/net/core/sock.c b/net/core/sock.c
index 4ed7b1d..7b84f24 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -385,7 +385,7 @@ struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
 
-	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+	if (dst && dst->ops->check(dst, cookie) == NULL) {
 		sk_tx_queue_clear(sk);
 		RCU_INIT_POINTER(sk->sk_dst_cache, NULL);
 		dst_release(dst);
@@ -400,7 +400,7 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = sk_dst_get(sk);
 
-	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+	if (dst && dst->ops->check(dst, cookie) == NULL) {
 		sk_dst_reset(sk);
 		dst_release(dst);
 		return NULL;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index a77d161..fc91774 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -269,11 +269,10 @@ static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
-/*
- * When a route has been marked obsolete. (e.g. routing cache flush)
- */
 static struct dst_entry *dn_dst_check(struct dst_entry *dst, __u32 cookie)
 {
+	if (!dst->freed)
+		return dst;
 	return NULL;
 }
 
@@ -1142,7 +1141,7 @@ make_route:
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rt = dst_alloc(&dn_dst_ops, dev_out, 1, 0, DST_HOST);
+	rt = dst_alloc(&dn_dst_ops, dev_out, 1, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
@@ -1412,7 +1411,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	}
 
 make_route:
-	rt = dst_alloc(&dn_dst_ops, out_dev, 0, 0, DST_HOST);
+	rt = dst_alloc(&dn_dst_ops, out_dev, 0, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 155138d..6fe264f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1401,7 +1401,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 	struct dst_entry *ret = dst;
 
 	if (rt) {
-		if (dst->obsolete > 0) {
+		if (dst->freed) {
 			ip_rt_put(rt);
 			ret = NULL;
 		} else if (rt->rt_flags & RTCF_REDIRECTED) {
@@ -1890,7 +1890,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 static struct rtable *rt_dst_alloc(struct net_device *dev,
 				   bool nopolicy, bool noxfrm)
 {
-	return dst_alloc(&ipv4_dst_ops, dev, 1, -1,
+	return dst_alloc(&ipv4_dst_ops, dev, 1,
 			 DST_HOST |
 			 (nopolicy ? DST_NOPOLICY : 0) |
 			 (noxfrm ? DST_NOXFRM : 0));
@@ -2776,7 +2776,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 
 struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
-	struct rtable *rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, 0, 0);
+	struct rtable *rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, 0);
 	struct rtable *ort = (struct rtable *) dst_orig;
 
 	if (rt) {
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 93718f3..35bab4e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1166,7 +1166,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	struct rt6_info **rtp;
 
 #if RT6_DEBUG >= 2
-	if (rt->dst.obsolete>0) {
+	if (rt->dst.freed) {
 		WARN_ON(fn != NULL);
 		return -ENOENT;
 	}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index bdc15c9..b38ff32 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -123,8 +123,7 @@ static inline struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 {
 	struct dst_entry *dst = t->dst_cache;
 
-	if (dst && dst->obsolete &&
-	    dst->ops->check(dst, t->dst_cookie) == NULL) {
+	if (dst && dst->ops->check(dst, t->dst_cookie) == NULL) {
 		t->dst_cache = NULL;
 		dst_release(dst);
 		return NULL;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8473016..dfad749 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -190,7 +190,6 @@ static struct rt6_info ip6_null_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
 		.__use		= 1,
-		.obsolete	= -1,
 		.error		= -ENETUNREACH,
 		.input		= ip6_pkt_discard,
 		.output		= ip6_pkt_discard_out,
@@ -210,7 +209,6 @@ static struct rt6_info ip6_prohibit_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
 		.__use		= 1,
-		.obsolete	= -1,
 		.error		= -EACCES,
 		.input		= ip6_pkt_prohibit,
 		.output		= ip6_pkt_prohibit_out,
@@ -225,7 +223,6 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
 		.__use		= 1,
-		.obsolete	= -1,
 		.error		= -EINVAL,
 		.input		= dst_discard,
 		.output		= dst_discard,
@@ -243,7 +240,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
 					     struct net_device *dev,
 					     int flags)
 {
-	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, flags);
+	struct rt6_info *rt = dst_alloc(ops, dev, 0, flags);
 
 	if (rt != NULL)
 		memset(&rt->rt6i_table, 0,
@@ -913,7 +910,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 	struct rt6_info *rt, *ort = (struct rt6_info *) dst_orig;
 	struct dst_entry *new = NULL;
 
-	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, 0, 0);
+	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, 0);
 	if (rt) {
 		memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
 
@@ -1243,7 +1240,6 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt->dst.obsolete = -1;
 	rt->rt6i_expires = (cfg->fc_flags & RTF_EXPIRES) ?
 				jiffies + clock_t_to_jiffies(cfg->fc_expires) :
 				0;
@@ -2058,7 +2054,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->dst.input = ip6_input;
 	rt->dst.output = ip6_output;
 	rt->rt6i_idev = idev;
-	rt->dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
 	if (anycast)
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index aa2d720..9934629 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -74,8 +74,7 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 
 	if (!dst)
 		return NULL;
-	if ((dst->obsolete || rtos != dest->dst_rtos) &&
-	    dst->ops->check(dst, dest->dst_cookie) == NULL) {
+	if (dst->ops->check(dst, dest->dst_cookie) == NULL) {
 		dest->dst_cache = NULL;
 		dst_release(dst);
 		return NULL;
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 08b3cea..23bff5b 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -377,8 +377,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 */
 	skb_set_owner_w(nskb, sk);
 
-	/* The 'obsolete' field of dst is set to 2 when a dst is freed. */
-	if (!dst || (dst->obsolete > 1)) {
+	if (!dst || dst->freed) {
 		dst_release(dst);
 		sctp_transport_route(tp, NULL, sctp_sk(sk));
 		if (asoc && (asoc->param_flags & SPP_PMTUD_ENABLE)) {
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 394c57c..90a1a60 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -214,7 +214,7 @@ void sctp_transport_set_owner(struct sctp_transport *transport,
 void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 {
 	/* If we don't have a fresh route, look one up */
-	if (!transport->dst || transport->dst->obsolete > 1) {
+	if (!transport->dst || transport->dst->freed) {
 		dst_release(transport->dst);
 		transport->af_specific->get_dst(transport, &transport->saddr,
 						&transport->fl, sk);
@@ -234,7 +234,7 @@ static struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
 {
 	struct dst_entry *dst = t->dst;
 
-	if (dst && dst->obsolete && dst->ops->check(dst, 0) == NULL) {
+	if (dst && dst->ops->check(dst, 0) == NULL) {
 		dst_release(t->dst);
 		t->dst = NULL;
 		return NULL;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 552df27..3ae2903 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1348,7 +1348,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops, NULL, 0, 0, 0);
+	xdst = dst_alloc(dst_ops, NULL, 0, 0);
 
 	if (likely(xdst)) {
 		memset(&xdst->u.rt6.rt6i_table, 0,
@@ -1474,7 +1474,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		dst1->xfrm = xfrm[i];
 		xdst->xfrm_genid = xfrm[i]->genid;
 
-		dst1->obsolete = -1;
 		dst1->flags |= DST_HOST;
 		dst1->lastuse = now;
 
@@ -2215,30 +2214,12 @@ EXPORT_SYMBOL(__xfrm_route_forward);
 
 static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 {
-	/* Code (such as __xfrm4_bundle_create()) sets dst->obsolete
-	 * to "-1" to force all XFRM destinations to get validated by
-	 * dst_ops->check on every use.  We do this because when a
-	 * normal route referenced by an XFRM dst is obsoleted we do
-	 * not go looking around for all parent referencing XFRM dsts
-	 * so that we can invalidate them.  It is just too much work.
-	 * Instead we make the checks here on every use.  For example:
-	 *
-	 *	XFRM dst A --> IPv4 dst X
-	 *
-	 * X is the "xdst->route" of A (X is also the "dst->path" of A
-	 * in this example).  If X is marked obsolete, "A" will not
-	 * notice.  That's what we are validating here via the
-	 * stale_bundle() check.
-	 *
-	 * When a policy's bundle is pruned, we dst_free() the XFRM
-	 * dst which causes it's ->obsolete field to be set to a
-	 * positive non-zero integer.  If an XFRM dst has been pruned
-	 * like this, we want to force a new route lookup.
+	/* All destinations in the kernel are validated unconditionally
+	 * by calling dst_ops->dst_check() on every use.
 	 */
-	if (dst->obsolete < 0 && !stale_bundle(dst))
-		return dst;
-
-	return NULL;
+	if (dst->freed || stale_bundle(dst))
+		return NULL;
+	return dst;
 }
 
 static int stale_bundle(struct dst_entry *dst)
@@ -2263,11 +2244,9 @@ static void xfrm_link_failure(struct sk_buff *skb)
 
 static struct dst_entry *xfrm_negative_advice(struct dst_entry *dst)
 {
-	if (dst) {
-		if (dst->obsolete) {
-			dst_release(dst);
-			dst = NULL;
-		}
+	if (dst && dst->freed) {
+		dst_release(dst);
+		dst = NULL;
 	}
 	return dst;
 }
