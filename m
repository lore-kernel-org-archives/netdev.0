From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH RFC] net/ipv4: Use next hop exceptions also for input routes
Date: Thu, 23 May 2013 16:15:46 +0300
Message-ID: <1369314946-12692-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:45116 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757139Ab3EWNOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 09:14:12 -0400
Received: by mail-ea0-f174.google.com with SMTP id z7so1782236eaf.19
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 06:14:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d2d68ba9 (ipv4: Cache input routes in fib_info nexthops)
assmued that "locally destined, and routed packets, never trigger
PMTU events or redirects that will be processed by us".

However, it seems that tunnel devices do trigger PMTU events in certain
cases. At least ip_gre, ip6_gre, sit, and ipip do use the inner flow's
skb_dst(skb)->ops->update_pmtu to propage mtu information from the
outer flows. These can cause the inner flow mtu to be decreased. If
next hop exceptions are not consulted for pmtu, IP fragmentation will
not be done properly for these routes.

It also seems that we really need to have the PMTU information always
for netfilter TCPMSS' clamp-to-pmtu feature to work properly.

So for the time being, cache separate copies of input routes for
each next hop exception.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
I had ideas to make optimizations where pmtu information would not
be needed. This includes:
- Target devices with IFF_XMIT_DST_RELEASE set (practically all devices
  except tunnels). If skb_dst() is early freed the target device cannot
  generate PMTU events
- Add flag for input route generation if pmtu info is needed for
  fragmentation. Basically a flag saying if DF bit was set in ip_hdr.

However, TCPMSS clamp-to-pmtu prevents both optimizations.

I'm not yet all familiar with the recent changes in routing caching,
so there might be caveats that I missed. Basic testing shows this fixes
the fragmentation issues I'm seeing, and I have not yet found any ill
side effects either.

 include/net/ip_fib.h     |  3 ++-
 net/ipv4/fib_semantics.c |  3 ++-
 net/ipv4/route.c         | 41 +++++++++++++++++++++++++++++++---------=
-
 3 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e49db91..20529a6 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -55,7 +55,8 @@ struct fib_nh_exception {
 	u32				fnhe_pmtu;
 	__be32				fnhe_gw;
 	unsigned long			fnhe_expires;
-	struct rtable __rcu		*fnhe_rth;
+	struct rtable __rcu		*fnhe_rth_input;
+	struct rtable __rcu		*fnhe_rth_output;
 	unsigned long			fnhe_stamp;
 };
=20
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 8f6cb7a..d5dbca5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -169,7 +169,8 @@ static void free_nh_exceptions(struct fib_nh *nh)
 		=09
 			next =3D rcu_dereference_protected(fnhe->fnhe_next, 1);
=20
-			rt_fibinfo_free(&fnhe->fnhe_rth);
+			rt_fibinfo_free(&fnhe->fnhe_rth_input);
+			rt_fibinfo_free(&fnhe->fnhe_rth_output);
=20
 			kfree(fnhe);
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 550781a..073df96 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -576,9 +576,14 @@ static struct fib_nh_exception *fnhe_oldest(struct=
 fnhe_hash_bucket *hash)
 		if (time_before(fnhe->fnhe_stamp, oldest->fnhe_stamp))
 			oldest =3D fnhe;
 	}
-	orig =3D rcu_dereference(oldest->fnhe_rth);
+	orig =3D rcu_dereference(oldest->fnhe_rth_input);
 	if (orig) {
-		RCU_INIT_POINTER(oldest->fnhe_rth, NULL);
+		RCU_INIT_POINTER(oldest->fnhe_rth_input, NULL);
+		rt_free(orig);
+	}
+	orig =3D rcu_dereference(oldest->fnhe_rth_output);
+	if (orig) {
+		RCU_INIT_POINTER(oldest->fnhe_rth_output, NULL);
 		rt_free(orig);
 	}
 	return oldest;
@@ -1209,7 +1214,15 @@ static bool rt_bind_exception(struct rtable *rt,=
 struct fib_nh_exception *fnhe,
 	spin_lock_bh(&fnhe_lock);
=20
 	if (daddr =3D=3D fnhe->fnhe_daddr) {
-		struct rtable *orig =3D rcu_dereference(fnhe->fnhe_rth);
+		struct rtable __rcu **porig;
+		struct rtable *orig;
+
+		if (rt_is_input_route(rt))
+			porig =3D &fnhe->fnhe_rth_input;
+		else
+			porig =3D &fnhe->fnhe_rth_output;
+
+		orig =3D rcu_dereference(*porig);
 		if (orig && rt_is_expired(orig)) {
 			fnhe->fnhe_gw =3D 0;
 			fnhe->fnhe_pmtu =3D 0;
@@ -1231,12 +1244,14 @@ static bool rt_bind_exception(struct rtable *rt=
, struct fib_nh_exception *fnhe,
 		} else if (!rt->rt_gateway)
 			rt->rt_gateway =3D daddr;
=20
-		rcu_assign_pointer(fnhe->fnhe_rth, rt);
-		if (orig)
-			rt_free(orig);
+		if (!(rt->dst.flags & DST_NOCACHE)) {
+			rcu_assign_pointer(*porig, rt);
+			if (orig)
+				rt_free(orig);
+			ret =3D true;
+		}
=20
 		fnhe->fnhe_stamp =3D jiffies;
-		ret =3D true;
 	}
 	spin_unlock_bh(&fnhe_lock);
=20
@@ -1468,6 +1483,7 @@ static int __mkroute_input(struct sk_buff *skb,
 			   struct in_device *in_dev,
 			   __be32 daddr, __be32 saddr, u32 tos)
 {
+	struct fib_nh_exception *fnhe;
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
@@ -1514,8 +1530,13 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
=20
+	fnhe =3D find_exception(&FIB_RES_NH(*res), daddr);
 	if (do_cache) {
-		rth =3D rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
+		if (fnhe !=3D NULL)
+			rth =3D rcu_dereference(fnhe->fnhe_rth_input);
+		else
+			rth =3D rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
+
 		if (rt_cache_valid(rth)) {
 			skb_dst_set_noref(skb, &rth->dst);
 			goto out;
@@ -1543,7 +1564,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input =3D ip_forward;
 	rth->dst.output =3D ip_output;
=20
-	rt_set_nexthop(rth, daddr, res, NULL, res->fi, res->type, itag);
+	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
 	skb_dst_set(skb, &rth->dst);
 out:
 	err =3D 0;
@@ -1858,7 +1879,7 @@ static struct rtable *__mkroute_output(const stru=
ct fib_result *res,
=20
 		fnhe =3D find_exception(nh, fl4->daddr);
 		if (fnhe)
-			prth =3D &fnhe->fnhe_rth;
+			prth =3D &fnhe->fnhe_rth_output;
 		else {
 			if (unlikely(fl4->flowi4_flags &
 				     FLOWI_FLAG_KNOWN_NH &&
--=20
1.8.2.3
