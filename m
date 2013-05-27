From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next 3/6] ipv4: properly refresh rtable entries on pmtu/redirect events
Date: Mon, 27 May 2013 14:16:13 +0300
Message-ID: <1369653376-4731-4-git-send-email-timo.teras@iki.fi>
References: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:48851 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757832Ab3E0LOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 07:14:45 -0400
Received: by mail-ee0-f50.google.com with SMTP id c41so3887727eek.37
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 04:14:44 -0700 (PDT)
In-Reply-To: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 05ab86c5 (xfrm4: Invalidate all ipv4 routes on
IPsec pmtu events). Flushing all cached entries is not needed.

Instead, invalidate only the related next hop dsts to recheck for
the added next hop exception where needed. This also fixes a subtle
race due to bumping generation id's before updating the pmtu.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/ipv4/ah4.c    |  7 ++-----
 net/ipv4/esp4.c   |  7 ++-----
 net/ipv4/ipcomp.c |  7 ++-----
 net/ipv4/route.c  | 63 ++++++++++++++++++++++++++++++++---------------=
--------
 4 files changed, 43 insertions(+), 41 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 2e7f194..7179026 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -419,12 +419,9 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 	if (!x)
 		return;
=20
-	if (icmp_hdr(skb)->type =3D=3D ICMP_DEST_UNREACH) {
-		atomic_inc(&flow_cache_genid);
-		rt_genid_bump(net);
-
+	if (icmp_hdr(skb)->type =3D=3D ICMP_DEST_UNREACH)
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_AH, 0);
-	} else
+	else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_AH, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4cfe34d..ab3d814 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -502,12 +502,9 @@ static void esp4_err(struct sk_buff *skb, u32 info=
)
 	if (!x)
 		return;
=20
-	if (icmp_hdr(skb)->type =3D=3D ICMP_DEST_UNREACH) {
-		atomic_inc(&flow_cache_genid);
-		rt_genid_bump(net);
-
+	if (icmp_hdr(skb)->type =3D=3D ICMP_DEST_UNREACH)
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ESP, 0);
-	} else
+	else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_ESP, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 59cb8c7..826be4c 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -47,12 +47,9 @@ static void ipcomp4_err(struct sk_buff *skb, u32 inf=
o)
 	if (!x)
 		return;
=20
-	if (icmp_hdr(skb)->type =3D=3D ICMP_DEST_UNREACH) {
-		atomic_inc(&flow_cache_genid);
-		rt_genid_bump(net);
-
+	if (icmp_hdr(skb)->type =3D=3D ICMP_DEST_UNREACH)
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_COMP, 0);
-	} else
+	else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_COMP, 0);
 	xfrm_state_put(x);
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 550781a..561a378 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -594,11 +594,25 @@ static inline u32 fnhe_hashfun(__be32 daddr)
 	return hval & (FNHE_HASH_SIZE - 1);
 }
=20
+static void fill_route_from_fnhe(struct rtable *rt, struct fib_nh_exce=
ption *fnhe)
+{
+	rt->rt_pmtu =3D fnhe->fnhe_pmtu;
+	rt->dst.expires =3D fnhe->fnhe_expires;
+
+	if (fnhe->fnhe_gw) {
+		rt->rt_flags |=3D RTCF_REDIRECTED;
+		rt->rt_gateway =3D fnhe->fnhe_gw;
+		rt->rt_uses_gateway =3D 1;
+	}
+}
+
 static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __b=
e32 gw,
 				  u32 pmtu, unsigned long expires)
 {
 	struct fnhe_hash_bucket *hash;
 	struct fib_nh_exception *fnhe;
+	struct rtable *rt;
+	unsigned int i;
 	int depth;
 	u32 hval =3D fnhe_hashfun(daddr);
=20
@@ -627,8 +641,12 @@ static void update_or_create_fnhe(struct fib_nh *n=
h, __be32 daddr, __be32 gw,
 			fnhe->fnhe_gw =3D gw;
 		if (pmtu) {
 			fnhe->fnhe_pmtu =3D pmtu;
-			fnhe->fnhe_expires =3D expires;
+			fnhe->fnhe_expires =3D max(1UL, expires);
 		}
+		/* Update all cached dsts too */
+		rt =3D rcu_dereference(fnhe->fnhe_rth);
+		if (rt)
+			fill_route_from_fnhe(rt, fnhe);
 	} else {
 		if (depth > FNHE_RECLAIM_DEPTH)
 			fnhe =3D fnhe_oldest(hash);
@@ -644,6 +662,18 @@ static void update_or_create_fnhe(struct fib_nh *n=
h, __be32 daddr, __be32 gw,
 		fnhe->fnhe_gw =3D gw;
 		fnhe->fnhe_pmtu =3D pmtu;
 		fnhe->fnhe_expires =3D expires;
+
+		/* Exception created; mark the cached routes for the nexthop
+		 * stale, so anyone caching it rechecks if this exception
+		 * applies to them.
+		 */
+		for_each_possible_cpu(i) {
+			struct rtable __rcu **prt;
+			prt =3D per_cpu_ptr(nh->nh_pcpu_rth_output, i);
+			rt =3D rcu_dereference(*prt);
+			if (rt)
+				rt->dst.obsolete =3D DST_OBSOLETE_KILL;
+		}
 	}
=20
 	fnhe->fnhe_stamp =3D jiffies;
@@ -917,13 +947,6 @@ static void __ip_rt_update_pmtu(struct rtable *rt,=
 struct flowi4 *fl4, u32 mtu)
 	if (mtu < ip_rt_min_pmtu)
 		mtu =3D ip_rt_min_pmtu;
=20
-	if (!rt->rt_pmtu) {
-		dst->obsolete =3D DST_OBSOLETE_KILL;
-	} else {
-		rt->rt_pmtu =3D mtu;
-		dst->expires =3D max(1UL, jiffies + ip_rt_mtu_expires);
-	}
-
 	rcu_read_lock();
 	if (fib_lookup(dev_net(dst->dev), fl4, &res) =3D=3D 0) {
 		struct fib_nh *nh =3D &FIB_RES_NH(res);
@@ -1063,11 +1086,11 @@ static struct dst_entry *ipv4_dst_check(struct =
dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 *
-	 * When a PMTU/redirect information update invalidates a
-	 * route, this is indicated by setting obsolete to
-	 * DST_OBSOLETE_KILL.
+	 * When a PMTU/redirect information update invalidates a route,
+	 * this is indicated by setting obsolete to DST_OBSOLETE_KILL or
+	 * DST_OBSOLETE_DEAD by dst_free().
 	 */
-	if (dst->obsolete =3D=3D DST_OBSOLETE_KILL || rt_is_expired(rt))
+	if (dst->obsolete !=3D DST_OBSOLETE_FORCE_CHK || rt_is_expired(rt))
 		return NULL;
 	return dst;
 }
@@ -1215,20 +1238,8 @@ static bool rt_bind_exception(struct rtable *rt,=
 struct fib_nh_exception *fnhe,
 			fnhe->fnhe_pmtu =3D 0;
 			fnhe->fnhe_expires =3D 0;
 		}
-		if (fnhe->fnhe_pmtu) {
-			unsigned long expires =3D fnhe->fnhe_expires;
-			unsigned long diff =3D expires - jiffies;
-
-			if (time_before(jiffies, expires)) {
-				rt->rt_pmtu =3D fnhe->fnhe_pmtu;
-				dst_set_expires(&rt->dst, diff);
-			}
-		}
-		if (fnhe->fnhe_gw) {
-			rt->rt_flags |=3D RTCF_REDIRECTED;
-			rt->rt_gateway =3D fnhe->fnhe_gw;
-			rt->rt_uses_gateway =3D 1;
-		} else if (!rt->rt_gateway)
+		fill_route_from_fnhe(rt, fnhe);
+		if (!rt->rt_gateway)
 			rt->rt_gateway =3D daddr;
=20
 		rcu_assign_pointer(fnhe->fnhe_rth, rt);
--=20
1.8.2.3
