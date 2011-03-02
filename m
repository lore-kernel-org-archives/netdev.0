From: David Miller <davem@davemloft.net>
Subject: [PATCH] xfrm: Return dst directly from xfrm_lookup()
Date: Wed, 02 Mar 2011 13:55:24 -0800 (PST)
Message-ID: <20110302.135524.28830612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56784
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757902Ab1CBVyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 16:54:47 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 39EBD24C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 13:55:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of on the stack.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Ok, this is what I was setting up for with the changes I wrote
and posted yesterday.

Next is getting the ipv4 route lookup interfaces to do this as
well.

 include/net/dst.h                |   14 ++++++++------
 net/decnet/dn_route.c            |   12 ++++++++++--
 net/ipv4/icmp.c                  |   36 ++++++++++++++----------------------
 net/ipv4/netfilter.c             |    6 ++++--
 net/ipv4/route.c                 |    7 ++++++-
 net/ipv6/icmp.c                  |   37 ++++++++++++++++++-------------------
 net/ipv6/ip6_output.c            |   10 ++--------
 net/ipv6/ip6_tunnel.c            |    8 +++++++-
 net/ipv6/mcast.c                 |   13 ++++++++++---
 net/ipv6/ndisc.c                 |    8 ++++----
 net/ipv6/netfilter.c             |    3 ++-
 net/ipv6/netfilter/ip6t_REJECT.c |    3 ++-
 net/netfilter/ipvs/ip_vs_xmit.c  |    9 +++++++--
 net/xfrm/xfrm_policy.c           |   34 +++++++++++++++++-----------------
 14 files changed, 111 insertions(+), 89 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 8948452..2a46cba 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -426,15 +426,17 @@ enum {
 
 struct flowi;
 #ifndef CONFIG_XFRM
-static inline int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-			      const struct flowi *fl, struct sock *sk,
-			      int flags)
+static inline struct dst_entry *xfrm_lookup(struct net *net,
+					    struct dst_entry *dst_orig,
+					    const struct flowi *fl, struct sock *sk,
+					    int flags)
 {
-	return 0;
+	return dst_orig;
 } 
 #else
-extern int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-		       const struct flowi *fl, struct sock *sk, int flags);
+extern struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
+				     const struct flowi *fl, struct sock *sk,
+				     int flags);
 #endif
 #endif
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 0877147..484fdbf 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1222,7 +1222,11 @@ static int dn_route_output_key(struct dst_entry **pprt, struct flowi *flp, int f
 
 	err = __dn_route_output_key(pprt, flp, flags);
 	if (err == 0 && flp->proto) {
-		err = xfrm_lookup(&init_net, pprt, flp, NULL, 0);
+		*pprt = xfrm_lookup(&init_net, *pprt, flp, NULL, 0);
+		if (IS_ERR(*pprt)) {
+			err = PTR_ERR(*pprt);
+			*pprt = NULL;
+		}
 	}
 	return err;
 }
@@ -1235,7 +1239,11 @@ int dn_route_output_sock(struct dst_entry **pprt, struct flowi *fl, struct sock
 	if (err == 0 && fl->proto) {
 		if (!(flags & MSG_DONTWAIT))
 			fl->flags |= FLOWI_FLAG_CAN_SLEEP;
-		err = xfrm_lookup(&init_net, pprt, fl, sk, 0);
+		*pprt = xfrm_lookup(&init_net, *pprt, fl, sk, 0);
+		if (IS_ERR(*pprt)) {
+			err = PTR_ERR(*pprt);
+			*pprt = NULL;
+		}
 	}
 	return err;
 }
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 2a86c89..c23bd8c 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -398,18 +398,14 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 	if (!fl.fl4_src)
 		fl.fl4_src = rt->rt_src;
 
-	err = xfrm_lookup(net, (struct dst_entry **)&rt, &fl, NULL, 0);
-	switch (err) {
-	case 0:
+	rt = (struct rtable *) xfrm_lookup(net, &rt->dst, &fl, NULL, 0);
+	if (!IS_ERR(rt)) {
 		if (rt != rt2)
 			return rt;
-		break;
-	case -EPERM:
+	} else if (PTR_ERR(rt) == -EPERM) {
 		rt = NULL;
-		break;
-	default:
-		return ERR_PTR(err);
-	}
+	} else
+		return rt;
 
 	err = xfrm_decode_session_reverse(skb_in, &fl, AF_INET);
 	if (err)
@@ -438,22 +434,18 @@ static struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,
 	if (err)
 		goto relookup_failed;
 
-	err = xfrm_lookup(net, (struct dst_entry **)&rt2, &fl, NULL,
-			  XFRM_LOOKUP_ICMP);
-	switch (err) {
-	case 0:
+	rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst, &fl, NULL, XFRM_LOOKUP_ICMP);
+	if (!IS_ERR(rt2)) {
 		dst_release(&rt->dst);
 		rt = rt2;
-		break;
-	case -EPERM:
-		return ERR_PTR(err);
-	default:
-		if (!rt)
-			return ERR_PTR(err);
-		break;
+	} else if (PTR_ERR(rt2) == -EPERM) {
+		if (rt)
+			dst_release(&rt->dst);
+		return rt2;
+	} else {
+		err = PTR_ERR(rt2);
+		goto relookup_failed;
 	}
-
-
 	return rt;
 
 relookup_failed:
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 994a1f2..9770bb4 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -69,7 +69,8 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	    xfrm_decode_session(skb, &fl, AF_INET) == 0) {
 		struct dst_entry *dst = skb_dst(skb);
 		skb_dst_set(skb, NULL);
-		if (xfrm_lookup(net, &dst, &fl, skb->sk, 0))
+		dst = xfrm_lookup(net, dst, &fl, skb->sk, 0);
+		if (IS_ERR(dst))
 			return -1;
 		skb_dst_set(skb, dst);
 	}
@@ -102,7 +103,8 @@ int ip_xfrm_me_harder(struct sk_buff *skb)
 		dst = ((struct xfrm_dst *)dst)->route;
 	dst_hold(dst);
 
-	if (xfrm_lookup(dev_net(dst->dev), &dst, &fl, skb->sk, 0) < 0)
+	dst = xfrm_lookup(dev_net(dst->dev), dst, &fl, skb->sk, 0);
+	if (IS_ERR(dst))
 		return -1;
 
 	skb_dst_drop(skb);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e24e4cf..63d3700 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2730,7 +2730,12 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 			flp->fl4_src = (*rp)->rt_src;
 		if (!flp->fl4_dst)
 			flp->fl4_dst = (*rp)->rt_dst;
-		return xfrm_lookup(net, (struct dst_entry **)rp, flp, sk, 0);
+		*rp = (struct rtable *) xfrm_lookup(net, &(*rp)->dst, flp, sk, 0);
+		if (IS_ERR(*rp)) {
+			err = PTR_ERR(*rp);
+			*rp = NULL;
+			return err;
+		}
 	}
 
 	return 0;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index e332bae..5566595 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -324,17 +324,15 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *sk
 	/* No need to clone since we're just using its address. */
 	dst2 = dst;
 
-	err = xfrm_lookup(net, &dst, fl, sk, 0);
-	switch (err) {
-	case 0:
+	dst = xfrm_lookup(net, dst, fl, sk, 0);
+	if (!IS_ERR(dst)) {
 		if (dst != dst2)
 			return dst;
-		break;
-	case -EPERM:
-		dst = NULL;
-		break;
-	default:
-		return ERR_PTR(err);
+	} else {
+		if (PTR_ERR(dst) == -EPERM)
+			dst = NULL;
+		else
+			return dst;
 	}
 
 	err = xfrm_decode_session_reverse(skb, &fl2, AF_INET6);
@@ -345,17 +343,17 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *sk
 	if (err)
 		goto relookup_failed;
 
-	err = xfrm_lookup(net, &dst2, &fl2, sk, XFRM_LOOKUP_ICMP);
-	switch (err) {
-	case 0:
+	dst2 = xfrm_lookup(net, dst2, &fl2, sk, XFRM_LOOKUP_ICMP);
+	if (!IS_ERR(dst2)) {
 		dst_release(dst);
 		dst = dst2;
-		break;
-	case -EPERM:
-		dst_release(dst);
-		return ERR_PTR(err);
-	default:
-		goto relookup_failed;
+	} else {
+		err = PTR_ERR(dst2);
+		if (err == -EPERM) {
+			dst_release(dst);
+			return dst2;
+		} else
+			goto relookup_failed;
 	}
 
 relookup_failed:
@@ -560,7 +558,8 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
-	if ((err = xfrm_lookup(net, &dst, &fl, sk, 0)) < 0)
+	dst = xfrm_lookup(net, dst, &fl, sk, 0);
+	if (IS_ERR(dst))
 		goto out;
 
 	if (ipv6_addr_is_multicast(&fl.fl6_dst))
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 35a4ad9..adaffaf 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1028,10 +1028,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 	if (can_sleep)
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 
-	err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
-	if (err)
-		return ERR_PTR(err);
-	return dst;
+	return xfrm_lookup(sock_net(sk), dst, fl, sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
 
@@ -1067,10 +1064,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 	if (can_sleep)
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 
-	err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
-	if (err)
-		return ERR_PTR(err);
-	return dst;
+	return xfrm_lookup(sock_net(sk), dst, fl, sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 4f4483e..da43038 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -903,8 +903,14 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	else {
 		dst = ip6_route_output(net, NULL, fl);
 
-		if (dst->error || xfrm_lookup(net, &dst, fl, NULL, 0) < 0)
+		if (dst->error)
 			goto tx_err_link_failure;
+		dst = xfrm_lookup(net, dst, fl, NULL, 0);
+		if (IS_ERR(dst)) {
+			err = PTR_ERR(dst);
+			dst = NULL;
+			goto tx_err_link_failure;
+		}
 	}
 
 	tdev = dst->dev;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 49f986d..7b27d08 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1429,7 +1429,12 @@ static void mld_sendpack(struct sk_buff *skb)
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
+	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	err = 0;
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
+		dst = NULL;
+	}
 	skb_dst_set(skb, dst);
 	if (err)
 		goto err_out;
@@ -1796,9 +1801,11 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
-	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
-	if (err)
+	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
 		goto err_out;
+	}
 
 	skb_dst_set(skb, dst);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7254ce3..9360d3b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -529,8 +529,8 @@ void ndisc_send_skb(struct sk_buff *skb,
 		return;
 	}
 
-	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
-	if (err < 0) {
+	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	if (IS_ERR(dst)) {
 		kfree_skb(skb);
 		return;
 	}
@@ -1542,8 +1542,8 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	if (dst == NULL)
 		return;
 
-	err = xfrm_lookup(net, &dst, &fl, NULL, 0);
-	if (err)
+	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	if (IS_ERR(dst))
 		return;
 
 	rt = (struct rt6_info *) dst;
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 35915e8..8d74116 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -39,7 +39,8 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
 	    xfrm_decode_session(skb, &fl, AF_INET6) == 0) {
 		skb_dst_set(skb, NULL);
-		if (xfrm_lookup(net, &dst, &fl, skb->sk, 0))
+		dst = xfrm_lookup(net, dst, &fl, skb->sk, 0);
+		if (IS_ERR(dst))
 			return -1;
 		skb_dst_set(skb, dst);
 	}
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index bf998fe..91f6a61 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -101,7 +101,8 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 		dst_release(dst);
 		return;
 	}
-	if (xfrm_lookup(net, &dst, &fl, NULL, 0))
+	dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+	if (IS_ERR(dst))
 		return;
 
 	hh_len = (dst->dev->hard_header_len + 15)&~15;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index a48239a..6264219 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -218,8 +218,13 @@ __ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
 	    ipv6_dev_get_saddr(net, ip6_dst_idev(dst)->dev,
 			       &fl.fl6_dst, 0, &fl.fl6_src) < 0)
 		goto out_err;
-	if (do_xfrm && xfrm_lookup(net, &dst, &fl, NULL, 0) < 0)
-		goto out_err;
+	if (do_xfrm) {
+		dst = xfrm_lookup(net, dst, &fl, NULL, 0);
+		if (IS_ERR(dst)) {
+			dst = NULL;
+			goto out_err;
+		}
+	}
 	ipv6_addr_copy(ret_saddr, &fl.fl6_src);
 	return dst;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0248afa..b1932a6 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1757,14 +1757,14 @@ static struct dst_entry *make_blackhole(struct net *net, u16 family,
  * At the moment we eat a raw IP route. Mostly to speed up lookups
  * on interfaces with disabled IPsec.
  */
-int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-		const struct flowi *fl,
-		struct sock *sk, int flags)
+struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
+			      const struct flowi *fl,
+			      struct sock *sk, int flags)
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	struct flow_cache_object *flo;
 	struct xfrm_dst *xdst;
-	struct dst_entry *dst, *dst_orig = *dst_p, *route;
+	struct dst_entry *dst, *route;
 	u16 family = dst_orig->ops->family;
 	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
 	int i, err, num_pols, num_xfrms = 0, drop_pols = 0;
@@ -1847,11 +1847,7 @@ restart:
 			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 
-			dst = make_blackhole(net, family, dst_orig);
-			if (IS_ERR(dst))
-				return PTR_ERR(dst);
-			*dst_p = dst;
-			return 0;
+			return make_blackhole(net, family, dst_orig);
 		}
 		if (fl->flags & FLOWI_FLAG_CAN_SLEEP) {
 			DECLARE_WAITQUEUE(wait, current);
@@ -1895,27 +1891,28 @@ no_transform:
 		goto error;
 	} else if (num_xfrms > 0) {
 		/* Flow transformed */
-		*dst_p = dst;
 		dst_release(dst_orig);
 	} else {
 		/* Flow passes untransformed */
 		dst_release(dst);
+		dst = dst_orig;
 	}
 ok:
 	xfrm_pols_put(pols, drop_pols);
-	return 0;
+	return dst;
 
 nopol:
-	if (!(flags & XFRM_LOOKUP_ICMP))
+	if (!(flags & XFRM_LOOKUP_ICMP)) {
+		dst = dst_orig;
 		goto ok;
+	}
 	err = -ENOENT;
 error:
 	dst_release(dst);
 dropdst:
 	dst_release(dst_orig);
-	*dst_p = NULL;
 	xfrm_pols_put(pols, drop_pols);
-	return err;
+	return ERR_PTR(err);
 }
 EXPORT_SYMBOL(xfrm_lookup);
 
@@ -2175,7 +2172,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 	struct net *net = dev_net(skb->dev);
 	struct flowi fl;
 	struct dst_entry *dst;
-	int res;
+	int res = 0;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMFWDHDRERROR);
@@ -2183,9 +2180,12 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 	}
 
 	skb_dst_force(skb);
-	dst = skb_dst(skb);
 
-	res = xfrm_lookup(net, &dst, &fl, NULL, 0) == 0;
+	dst = xfrm_lookup(net, skb_dst(skb), &fl, NULL, 0);
+	if (IS_ERR(dst)) {
+		res = 1;
+		dst = NULL;
+	}
 	skb_dst_set(skb, dst);
 	return res;
 }
-- 
1.7.4.1

