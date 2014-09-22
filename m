From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: Generate blackhole routes only from route lookup functions
Date: Mon, 22 Sep 2014 07:38:39 +0200
Message-ID: <1411364320-5309-2-git-send-email-steffen.klassert@secunet.com>
References: <1411364320-5309-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51323 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbaIVFjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 01:39:06 -0400
In-Reply-To: <1411364320-5309-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we genarate a blackhole route route whenever we have
matching policies but can not resolve the states. Here we assume
that dst_output() is called to kill the balckholed packets.
Unfortunately this assumption is not true in all cases, so
it is possible that these packets leave the system unwanted.

We fix this by generating blackhole routes only from the
route lookup functions, here we can guarantee a call to
dst_output() afterwards.

Fixes: 2774c131b1d ("xfrm: Handle blackhole route creation via afinfo.")
Reported-by: Konstantinos Kolelis <k.kolelis@sirrix.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      | 15 ++++++++++++++-
 net/ipv4/route.c       |  6 +++---
 net/ipv6/ip6_output.c  |  4 ++--
 net/xfrm/xfrm_policy.c | 18 +++++++++++++++++-
 4 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 71c60f4..fa11c90 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -490,7 +490,16 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
 					    int flags)
 {
 	return dst_orig;
-} 
+}
+
+static inline struct dst_entry *xfrm_lookup_route(struct net *net,
+						  struct dst_entry *dst_orig,
+						  const struct flowi *fl,
+						  struct sock *sk,
+						  int flags)
+{
+	return dst_orig;
+}
 
 static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
 {
@@ -502,6 +511,10 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			      const struct flowi *fl, struct sock *sk,
 			      int flags);
 
+struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
+				    const struct flowi *fl, struct sock *sk,
+				    int flags);
+
 /* skb attached with this dst needs transformation if dst->xfrm is valid */
 static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
 {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaa4b00..173e7ea 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2265,9 +2265,9 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 		return rt;
 
 	if (flp4->flowi4_proto)
-		rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
-						   flowi4_to_flowi(flp4),
-						   sk, 0);
+		rt = (struct rtable *)xfrm_lookup_route(net, &rt->dst,
+							flowi4_to_flowi(flp4),
+							sk, 0);
 
 	return rt;
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 315a55d..0a3448b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1009,7 +1009,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 	if (final_dst)
 		fl6->daddr = *final_dst;
 
-	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
+	return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
 
@@ -1041,7 +1041,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 	if (final_dst)
 		fl6->daddr = *final_dst;
 
-	return xfrm_lookup(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
+	return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index beeed60..7505674 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2138,7 +2138,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 
-			return make_blackhole(net, family, dst_orig);
+			return ERR_PTR(-EREMOTE);
 		}
 
 		err = -EAGAIN;
@@ -2195,6 +2195,22 @@ dropdst:
 }
 EXPORT_SYMBOL(xfrm_lookup);
 
+/* Callers of xfrm_lookup_route() must ensure a call to dst_output().
+ * Otherwise we may send out blackholed packets.
+ */
+struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
+				    const struct flowi *fl,
+				    struct sock *sk, int flags)
+{
+	struct dst_entry *dst = xfrm_lookup(net, dst_orig, fl, sk, flags);
+
+	if (IS_ERR(dst) && PTR_ERR(dst) == -EREMOTE)
+		return make_blackhole(net, dst_orig->ops->family, dst_orig);
+
+	return dst;
+}
+EXPORT_SYMBOL(xfrm_lookup_route);
+
 static inline int
 xfrm_secpath_reject(int idx, struct sk_buff *skb, const struct flowi *fl)
 {
-- 
1.9.1
