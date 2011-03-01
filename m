From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/8] xfrm: Handle blackhole route creation via afinfo.
Date: Tue, 01 Mar 2011 15:11:38 -0800 (PST)
Message-ID: <20110301.151138.15246864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48525
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757154Ab1CAXLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:11:01 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B85C324C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


That way we don't have to potentially do this in every xfrm_lookup()
caller.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h       |    8 --------
 include/net/ipv6.h      |    4 ++--
 include/net/route.h     |    1 +
 include/net/xfrm.h      |    1 +
 net/ipv4/route.c        |   20 +++++++-------------
 net/ipv4/xfrm4_policy.c |    1 +
 net/ipv6/ip6_output.c   |   32 ++++++++++----------------------
 net/ipv6/route.c        |    3 +--
 net/ipv6/xfrm6_policy.c |    1 +
 net/xfrm/xfrm_policy.c  |   46 ++++++++++++++++++++++++++--------------------
 10 files changed, 50 insertions(+), 67 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 15d67c8..8948452 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -432,17 +432,9 @@ static inline int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
 {
 	return 0;
 } 
-static inline int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-				const struct flowi *fl, struct sock *sk,
-				int flags)
-{
-	return 0;
-}
 #else
 extern int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
 		       const struct flowi *fl, struct sock *sk, int flags);
-extern int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-			 const struct flowi *fl, struct sock *sk, int flags);
 #endif
 #endif
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5d125c1..d6d077d 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -520,8 +520,8 @@ extern struct dst_entry *	ip6_sk_dst_lookup_flow(struct sock *sk,
 						       struct flowi *fl,
 						       const struct in6_addr *final_dst,
 						       bool can_sleep);
-extern struct dst_entry *	ip6_dst_blackhole(struct net *net,
-						  struct dst_entry *orig_dst);
+extern struct dst_entry *	ip6_blackhole_route(struct net *net,
+						    struct dst_entry *orig_dst);
 
 /*
  *	skb processing functions
diff --git a/include/net/route.h b/include/net/route.h
index 923e670..707cfc8 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -121,6 +121,7 @@ extern void		rt_cache_flush_batch(struct net *net);
 extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk);
+extern struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig);
 
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
 				 u8 tos, struct net_device *devin, bool noref);
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index efded23..d5dcf39 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -280,6 +280,7 @@ struct xfrm_policy_afinfo {
 	int			(*fill_dst)(struct xfrm_dst *xdst,
 					    struct net_device *dev,
 					    const struct flowi *fl);
+	struct dst_entry	*(*blackhole_route)(struct net *net, struct dst_entry *orig);
 };
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 23d2050..e24e4cf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2675,12 +2675,10 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 };
 
-
-static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi *flp)
+struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
-	struct rtable *ort = *rp;
-	struct rtable *rt = (struct rtable *)
-		dst_alloc(&ipv4_dst_blackhole_ops, 1);
+	struct rtable *rt = dst_alloc(&ipv4_dst_blackhole_ops, 1);
+	struct rtable *ort = (struct rtable *) dst_orig;
 
 	if (rt) {
 		struct dst_entry *new = &rt->dst;
@@ -2714,9 +2712,9 @@ static int ipv4_dst_blackhole(struct net *net, struct rtable **rp, struct flowi
 		dst_free(new);
 	}
 
-	dst_release(&(*rp)->dst);
-	*rp = rt;
-	return rt ? 0 : -ENOMEM;
+	dst_release(dst_orig);
+
+	return rt ? &rt->dst : ERR_PTR(-ENOMEM);
 }
 
 int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
@@ -2732,11 +2730,7 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 			flp->fl4_src = (*rp)->rt_src;
 		if (!flp->fl4_dst)
 			flp->fl4_dst = (*rp)->rt_dst;
-		err = __xfrm_lookup(net, (struct dst_entry **)rp, flp, sk, 0);
-		if (err == -EREMOTE)
-			err = ipv4_dst_blackhole(net, rp, flp);
-
-		return err;
+		return xfrm_lookup(net, (struct dst_entry **)rp, flp, sk, 0);
 	}
 
 	return 0;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 63aa88e..5f0f058 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -234,6 +234,7 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.get_tos =		xfrm4_get_tos,
 	.init_path =		xfrm4_init_path,
 	.fill_dst =		xfrm4_fill_dst,
+	.blackhole_route =	ipv4_blackhole_route,
 };
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ac16f3b..35a4ad9 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1025,18 +1025,12 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		return ERR_PTR(err);
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
-	if (can_sleep) {
+	if (can_sleep)
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
-		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
-		if (err == -EREMOTE)
-			return ip6_dst_blackhole(sock_net(sk), dst);
-		if (err)
-			return ERR_PTR(err);
-	} else {
-		err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
-		if (err)
-			return ERR_PTR(err);
-	}
+
+	err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
+	if (err)
+		return ERR_PTR(err);
 	return dst;
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
@@ -1070,18 +1064,12 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		return ERR_PTR(err);
 	if (final_dst)
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
-	if (can_sleep) {
+	if (can_sleep)
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
-		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
-		if (err == -EREMOTE)
-			return ip6_dst_blackhole(sock_net(sk), dst);
-		if (err)
-			return ERR_PTR(err);
-	} else {
-		err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
-		if (err)
-			return ERR_PTR(err);
-	}
+
+	err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
+	if (err)
+		return ERR_PTR(err);
 	return dst;
 }
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cf6fdea..053a92e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -870,7 +870,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 
 EXPORT_SYMBOL(ip6_route_output);
 
-struct dst_entry *ip6_dst_blackhole(struct net *net, struct dst_entry *dst_orig)
+struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
 	struct rt6_info *rt = dst_alloc(&ip6_dst_blackhole_ops, 1);
 	struct rt6_info *ort = (struct rt6_info *) dst_orig;
@@ -907,7 +907,6 @@ struct dst_entry *ip6_dst_blackhole(struct net *net, struct dst_entry *dst_orig)
 	dst_release(dst_orig);
 	return new ? new : ERR_PTR(-ENOMEM);
 }
-EXPORT_SYMBOL_GPL(ip6_dst_blackhole);
 
 /*
  *	Destination cache support functions
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c128ca1..48ce496 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -274,6 +274,7 @@ static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.get_tos =		xfrm6_get_tos,
 	.init_path =		xfrm6_init_path,
 	.fill_dst =		xfrm6_fill_dst,
+	.blackhole_route =	ip6_blackhole_route,
 };
 
 static int __init xfrm6_policy_init(void)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f4c7467..0248afa 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1735,14 +1735,31 @@ error:
 	return ERR_PTR(err);
 }
 
+static struct dst_entry *make_blackhole(struct net *net, u16 family,
+					struct dst_entry *dst_orig)
+{
+	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	struct dst_entry *ret;
+
+	if (!afinfo) {
+		dst_release(dst_orig);
+		ret = ERR_PTR(-EINVAL);
+	} else {
+		ret = afinfo->blackhole_route(net, dst_orig);
+	}
+	xfrm_policy_put_afinfo(afinfo);
+
+	return ret;
+}
+
 /* Main function: finds/creates a bundle for given flow.
  *
  * At the moment we eat a raw IP route. Mostly to speed up lookups
  * on interfaces with disabled IPsec.
  */
-int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-		  const struct flowi *fl,
-		  struct sock *sk, int flags)
+int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
+		const struct flowi *fl,
+		struct sock *sk, int flags)
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	struct flow_cache_object *flo;
@@ -1829,7 +1846,12 @@ restart:
 			dst_release(dst);
 			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
-			return -EREMOTE;
+
+			dst = make_blackhole(net, family, dst_orig);
+			if (IS_ERR(dst))
+				return PTR_ERR(dst);
+			*dst_p = dst;
+			return 0;
 		}
 		if (fl->flags & FLOWI_FLAG_CAN_SLEEP) {
 			DECLARE_WAITQUEUE(wait, current);
@@ -1895,22 +1917,6 @@ dropdst:
 	xfrm_pols_put(pols, drop_pols);
 	return err;
 }
-EXPORT_SYMBOL(__xfrm_lookup);
-
-int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-		const struct flowi *fl,
-		struct sock *sk, int flags)
-{
-	int err = __xfrm_lookup(net, dst_p, fl, sk, flags);
-
-	if (err == -EREMOTE) {
-		dst_release(*dst_p);
-		*dst_p = NULL;
-		err = -EAGAIN;
-	}
-
-	return err;
-}
 EXPORT_SYMBOL(xfrm_lookup);
 
 static inline int
-- 
1.7.4.1

