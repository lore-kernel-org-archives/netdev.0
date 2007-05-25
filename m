From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Packet drops during larval state resolution
Date: Thu, 24 May 2007 18:13:55 -0700 (PDT)
Message-ID: <20070524.181355.74748116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34025
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbXEYBNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 21:13:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 841BA510001
	for <netdev@vger.kernel.org>; Thu, 24 May 2007 18:13:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The current IPSEC rule resolution behavior we have does not work for a
lot of people, even though technically it's an improvement from the
-EAGAIN buisness we had before.

Right now we'll block until the key manager resolves the route.  That
works for simple cases, but many folks would rather packets get
silently dropped until the key manager resolves the IPSEC rules.

We can't tell these folks to "set the socket non-blocking" because
they don't have control over the non-block setting of things like the
sockets used to resolve DNS deep inside of the resolver libraries in
libc.

With that in mind I coded up the patch below with some help from
Herbert Xu which provides packet-drop behavior during larval
state resolution, controllable via sysctl and off by default.

This lays the framework to either:

1) Make this default at some point or...

2) Move this logic into xfrm{4,6}_policy.c and implement the
   ARP-like resolution queue we've all been dreaming of.
   The idea would be to queue packets to the policy, then
   once the larval state is resolved by the key manager we
   re-resolve the route and push the packets out.  The
   packets would timeout if the rule didn't get resolved
   in a certain amount of time.

In any event I'm going to push the following into 2.6.22 and
possibly -stable because it's zero risk since none of the
new code runs by default, and for folks who can't use the
current behavior it gives them an option.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/dst.h b/include/net/dst.h
index e12a8ce..82270f9 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -265,9 +265,16 @@ static inline int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
 {
 	return 0;
 } 
+static inline int __xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
+				struct sock *sk, int flags)
+{
+	return 0;
+}
 #else
 extern int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
 		       struct sock *sk, int flags);
+extern int __xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
+			 struct sock *sk, int flags);
 #endif
 #endif
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4fa5dfe..78a0d06 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -469,6 +469,9 @@ extern void			ip6_flush_pending_frames(struct sock *sk);
 extern int			ip6_dst_lookup(struct sock *sk,
 					       struct dst_entry **dst,
 					       struct flowi *fl);
+extern int			ip6_dst_blackhole(struct sock *sk,
+						  struct dst_entry **dst,
+						  struct flowi *fl);
 extern int			ip6_sk_dst_lookup(struct sock *sk,
 						  struct dst_entry **dst,
 						  struct flowi *fl);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index b297120..f34aca0 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -24,6 +24,7 @@ extern int sysctl_core_destroy_delay;
 #ifdef CONFIG_XFRM
 extern u32 sysctl_xfrm_aevent_etime;
 extern u32 sysctl_xfrm_aevent_rseqth;
+extern int sysctl_xfrm_larval_drop;
 #endif
 
 ctl_table core_table[] = {
@@ -118,6 +119,14 @@ ctl_table core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "xfrm_larval_drop",
+		.data		= &sysctl_xfrm_larval_drop,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 #endif /* CONFIG_XFRM */
 #endif /* CONFIG_NET */
 	{
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 64eac25..31737cd 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1043,9 +1043,13 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	err = xfrm_lookup(&dst, &fl, sk, 1);
-	if (err < 0)
-		goto failure;
+	err = __xfrm_lookup(&dst, &fl, sk, 1);
+	if (err < 0) {
+		if (err == -EREMOTE)
+			err = ip6_dst_blackhole(sk, &dst, &fl);
+		if (err < 0)
+			goto failure;
+	}
 
 	if (saddr == NULL) {
 		saddr = &fl.fl6_src;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index df9fe4f..8603cfb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2598,6 +2598,69 @@ int __ip_route_output_key(struct rtable **rp, const struct flowi *flp)
 
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
+static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
+{
+}
+
+static struct dst_ops ipv4_dst_blackhole_ops = {
+	.family			=	AF_INET,
+	.protocol		=	__constant_htons(ETH_P_IP),
+	.destroy		=	ipv4_dst_destroy,
+	.check			=	ipv4_dst_check,
+	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
+	.entry_size		=	sizeof(struct rtable),
+};
+
+
+static int ipv4_blackhole_output(struct sk_buff *skb)
+{
+	kfree_skb(skb);
+	return 0;
+}
+
+static int ipv4_dst_blackhole(struct rtable **rp, struct flowi *flp, struct sock *sk)
+{
+	struct rtable *ort = *rp;
+	struct rtable *rt = (struct rtable *)
+		dst_alloc(&ipv4_dst_blackhole_ops);
+
+	if (rt) {
+		struct dst_entry *new = &rt->u.dst;
+
+		atomic_set(&new->__refcnt, 1);
+		new->__use = 1;
+		new->input = ipv4_blackhole_output;
+		new->output = ipv4_blackhole_output;
+		memcpy(new->metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
+
+		new->dev = ort->u.dst.dev;
+		if (new->dev)
+			dev_hold(new->dev);
+
+		rt->fl = ort->fl;
+
+		rt->idev = ort->idev;
+		if (rt->idev)
+			in_dev_hold(rt->idev);
+		rt->rt_flags = ort->rt_flags;
+		rt->rt_type = ort->rt_type;
+		rt->rt_dst = ort->rt_dst;
+		rt->rt_src = ort->rt_src;
+		rt->rt_iif = ort->rt_iif;
+		rt->rt_gateway = ort->rt_gateway;
+		rt->rt_spec_dst = ort->rt_spec_dst;
+		rt->peer = ort->peer;
+		if (rt->peer)
+			atomic_inc(&rt->peer->refcnt);
+
+		dst_free(new);
+	}
+
+	dst_release(&(*rp)->u.dst);
+	*rp = rt;
+	return (rt ? 0 : -ENOMEM);
+}
+
 int ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk, int flags)
 {
 	int err;
@@ -2610,7 +2673,11 @@ int ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk,
 			flp->fl4_src = (*rp)->rt_src;
 		if (!flp->fl4_dst)
 			flp->fl4_dst = (*rp)->rt_dst;
-		return xfrm_lookup((struct dst_entry **)rp, flp, sk, flags);
+		err = __xfrm_lookup((struct dst_entry **)rp, flp, sk, flags);
+		if (err == -EREMOTE)
+			err = ipv4_dst_blackhole(rp, flp, sk);
+
+		return err;
 	}
 
 	return 0;
@@ -3139,6 +3206,8 @@ int __init ip_rt_init(void)
 		kmem_cache_create("ip_dst_cache", sizeof(struct rtable), 0,
 				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
+	ipv4_dst_blackhole_ops.kmem_cachep = ipv4_dst_ops.kmem_cachep;
+
 	rt_hash_table = (struct rt_hash_bucket *)
 		alloc_large_system_hash("IP route cache",
 					sizeof(struct rt_hash_bucket),
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 403eee6..b1fe7ac 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -177,8 +177,12 @@ ipv4_connected:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
-		goto out;
+	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+		if (err == -EREMOTE)
+			err = ip6_dst_blackhole(sk, &dst, &fl);
+		if (err < 0)
+			goto out;
+	}
 
 	/* source address lookup done in ip6_dst_lookup */
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 009a104..a58459a 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -818,8 +818,12 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
-		goto out;
+	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+		if (err == -EREMOTE)
+			err = ip6_dst_blackhole(sk, &dst, &fl);
+		if (err < 0)
+			goto out;
+	}
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b46ad53..1324b06 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -119,6 +119,19 @@ static struct dst_ops ip6_dst_ops = {
 	.entry_size		=	sizeof(struct rt6_info),
 };
 
+static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
+{
+}
+
+static struct dst_ops ip6_dst_blackhole_ops = {
+	.family			=	AF_INET6,
+	.protocol		=	__constant_htons(ETH_P_IPV6),
+	.destroy		=	ip6_dst_destroy,
+	.check			=	ip6_dst_check,
+	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
+	.entry_size		=	sizeof(struct rt6_info),
+};
+
 struct rt6_info ip6_null_entry = {
 	.u = {
 		.dst = {
@@ -833,6 +846,54 @@ struct dst_entry * ip6_route_output(struct sock *sk, struct flowi *fl)
 
 EXPORT_SYMBOL(ip6_route_output);
 
+static int ip6_blackhole_output(struct sk_buff *skb)
+{
+	kfree_skb(skb);
+	return 0;
+}
+
+int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl)
+{
+	struct rt6_info *ort = (struct rt6_info *) *dstp;
+	struct rt6_info *rt = (struct rt6_info *)
+		dst_alloc(&ip6_dst_blackhole_ops);
+	struct dst_entry *new = NULL;
+
+	if (rt) {
+		new = &rt->u.dst;
+
+		atomic_set(&new->__refcnt, 1);
+		new->__use = 1;
+		new->input = ip6_blackhole_output;
+		new->output = ip6_blackhole_output;
+
+		memcpy(new->metrics, ort->u.dst.metrics, RTAX_MAX*sizeof(u32));
+		new->dev = ort->u.dst.dev;
+		if (new->dev)
+			dev_hold(new->dev);
+		rt->rt6i_idev = ort->rt6i_idev;
+		if (rt->rt6i_idev)
+			in6_dev_hold(rt->rt6i_idev);
+		rt->rt6i_expires = 0;
+
+		ipv6_addr_copy(&rt->rt6i_gateway, &ort->rt6i_gateway);
+		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
+		rt->rt6i_metric = 0;
+
+		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
+#ifdef CONFIG_IPV6_SUBTREES
+		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
+#endif
+
+		dst_free(new);
+	}
+
+	dst_release(*dstp);
+	*dstp = new;
+	return (new ? 0 : -ENOMEM);
+}
+EXPORT_SYMBOL_GPL(ip6_dst_blackhole);
+
 /*
  *	Destination cache support functions
  */
@@ -2495,6 +2556,8 @@ void __init ip6_route_init(void)
 	ip6_dst_ops.kmem_cachep =
 		kmem_cache_create("ip6_dst_cache", sizeof(struct rt6_info), 0,
 				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
+
 	fib6_init();
 #ifdef 	CONFIG_PROC_FS
 	p = proc_net_create("ipv6_route", 0, rt6_proc_info);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e2f25ea..4f06a51 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -265,8 +265,12 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
-		goto failure;
+	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+		if (err == -EREMOTE)
+			err = ip6_dst_blackhole(sk, &dst, &fl);
+		if (err < 0)
+			goto failure;
+	}
 
 	if (saddr == NULL) {
 		saddr = &fl.fl6_src;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a7ae59c..d1fbddd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -767,8 +767,12 @@ do_udp_sendmsg:
 	if (final_p)
 		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-	if ((err = xfrm_lookup(&dst, &fl, sk, 1)) < 0)
-		goto out;
+	if ((err = __xfrm_lookup(&dst, &fl, sk, 1)) < 0) {
+		if (err == -EREMOTE)
+			err = ip6_dst_blackhole(sk, &dst, &fl);
+		if (err < 0)
+			goto out;
+	}
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d0882e5..b8bab89 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -29,6 +29,8 @@
 
 #include "xfrm_hash.h"
 
+int sysctl_xfrm_larval_drop;
+
 DEFINE_MUTEX(xfrm_cfg_mutex);
 EXPORT_SYMBOL(xfrm_cfg_mutex);
 
@@ -1390,8 +1392,8 @@ static int stale_bundle(struct dst_entry *dst);
  * At the moment we eat a raw IP route. Mostly to speed up lookups
  * on interfaces with disabled IPsec.
  */
-int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
-		struct sock *sk, int flags)
+int __xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
+		  struct sock *sk, int flags)
 {
 	struct xfrm_policy *policy;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
@@ -1509,6 +1511,13 @@ restart:
 
 		if (unlikely(nx<0)) {
 			err = nx;
+			if (err == -EAGAIN && sysctl_xfrm_larval_drop) {
+				/* EREMOTE tells the caller to generate
+				 * a one-shot blackhole route.
+				 */
+				xfrm_pol_put(policy);
+				return -EREMOTE;
+			}
 			if (err == -EAGAIN && flags) {
 				DECLARE_WAITQUEUE(wait, current);
 
@@ -1598,6 +1607,21 @@ error:
 	*dst_p = NULL;
 	return err;
 }
+EXPORT_SYMBOL(__xfrm_lookup);
+
+int xfrm_lookup(struct dst_entry **dst_p, struct flowi *fl,
+		struct sock *sk, int flags)
+{
+	int err = __xfrm_lookup(dst_p, fl, sk, flags);
+
+	if (err == -EREMOTE) {
+		dst_release(*dst_p);
+		*dst_p = NULL;
+		err = -EAGAIN;
+	}
+
+	return err;
+}
 EXPORT_SYMBOL(xfrm_lookup);
 
 static inline int
