From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next] ipv4: use next hop exceptions also for input routes
Date: Thu, 27 Jun 2013 10:27:05 +0300
Message-ID: <1372318025-7634-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:62427 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240Ab3F0H06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 03:26:58 -0400
Received: by mail-bk0-f49.google.com with SMTP id mz10so123608bkb.8
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 00:26:57 -0700 (PDT)
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
for netfilter TCPMSS clamp-to-pmtu feature to work properly.

So for the time being, cache separate copies of input routes for
each next hop exception.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Seems that the previous send was marked as RFC, and got no review
comments. No alternate patches seem to have been committed either.

I'm resending now without RFC tag, and rebased against current
net-next. I've been using this locally for several weeks and have
not found any problems, and this does fix the two regression bugs
mentioned above.

 include/net/ip_fib.h     |  3 ++-
 net/ipv4/fib_semantics.c |  3 ++-
 net/ipv4/route.c         | 65 +++++++++++++++++++++++++++++++++++++---=
--------
 3 files changed, 54 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 44424e9..aac8553 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -56,7 +56,8 @@ struct fib_nh_exception {
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
index f3fa42e..a9a54a2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -565,10 +565,25 @@ static inline void rt_free(struct rtable *rt)
=20
 static DEFINE_SPINLOCK(fnhe_lock);
=20
+static void fnhe_flush_routes(struct fib_nh_exception *fnhe)
+{
+	struct rtable *rt;
+
+	rt =3D rcu_dereference(fnhe->fnhe_rth_input);
+	if (rt) {
+		RCU_INIT_POINTER(fnhe->fnhe_rth_input, NULL);
+		rt_free(rt);
+	}
+	rt =3D rcu_dereference(fnhe->fnhe_rth_output);
+	if (rt) {
+		RCU_INIT_POINTER(fnhe->fnhe_rth_output, NULL);
+		rt_free(rt);
+	}
+}
+
 static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *h=
ash)
 {
 	struct fib_nh_exception *fnhe, *oldest;
-	struct rtable *orig;
=20
 	oldest =3D rcu_dereference(hash->chain);
 	for (fnhe =3D rcu_dereference(oldest->fnhe_next); fnhe;
@@ -576,11 +591,7 @@ static struct fib_nh_exception *fnhe_oldest(struct=
 fnhe_hash_bucket *hash)
 		if (time_before(fnhe->fnhe_stamp, oldest->fnhe_stamp))
 			oldest =3D fnhe;
 	}
-	orig =3D rcu_dereference(oldest->fnhe_rth);
-	if (orig) {
-		RCU_INIT_POINTER(oldest->fnhe_rth, NULL);
-		rt_free(orig);
-	}
+	fnhe_flush_routes(oldest);
 	return oldest;
 }
=20
@@ -644,7 +655,10 @@ static void update_or_create_fnhe(struct fib_nh *n=
h, __be32 daddr, __be32 gw,
 			fnhe->fnhe_expires =3D max(1UL, expires);
 		}
 		/* Update all cached dsts too */
-		rt =3D rcu_dereference(fnhe->fnhe_rth);
+		rt =3D rcu_dereference(fnhe->fnhe_rth_input);
+		if (rt)
+			fill_route_from_fnhe(rt, fnhe);
+		rt =3D rcu_dereference(fnhe->fnhe_rth_output);
 		if (rt)
 			fill_route_from_fnhe(rt, fnhe);
 	} else {
@@ -668,6 +682,10 @@ static void update_or_create_fnhe(struct fib_nh *n=
h, __be32 daddr, __be32 gw,
 		 * stale, so anyone caching it rechecks if this exception
 		 * applies to them.
 		 */
+		rt =3D rcu_dereference(nh->nh_rth_input);
+		if (rt)
+			rt->dst.obsolete =3D DST_OBSOLETE_KILL;
+
 		for_each_possible_cpu(i) {
 			struct rtable __rcu **prt;
 			prt =3D per_cpu_ptr(nh->nh_pcpu_rth_output, i);
@@ -1242,25 +1260,36 @@ static bool rt_bind_exception(struct rtable *rt=
, struct fib_nh_exception *fnhe,
 	spin_lock_bh(&fnhe_lock);
=20
 	if (daddr =3D=3D fnhe->fnhe_daddr) {
+		struct rtable __rcu **porig;
+		struct rtable *orig;
 		int genid =3D fnhe_genid(dev_net(rt->dst.dev));
-		struct rtable *orig =3D rcu_dereference(fnhe->fnhe_rth);
+
+		if (rt_is_input_route(rt))
+			porig =3D &fnhe->fnhe_rth_input;
+		else
+			porig =3D &fnhe->fnhe_rth_output;
+		orig =3D rcu_dereference(*porig);
=20
 		if (fnhe->fnhe_genid !=3D genid) {
 			fnhe->fnhe_genid =3D genid;
 			fnhe->fnhe_gw =3D 0;
 			fnhe->fnhe_pmtu =3D 0;
 			fnhe->fnhe_expires =3D 0;
+			fnhe_flush_routes(fnhe);
+			orig =3D NULL;
 		}
 		fill_route_from_fnhe(rt, fnhe);
 		if (!rt->rt_gateway)
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
@@ -1492,6 +1521,7 @@ static int __mkroute_input(struct sk_buff *skb,
 			   struct in_device *in_dev,
 			   __be32 daddr, __be32 saddr, u32 tos)
 {
+	struct fib_nh_exception *fnhe;
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
@@ -1538,8 +1568,13 @@ static int __mkroute_input(struct sk_buff *skb,
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
@@ -1567,7 +1602,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input =3D ip_forward;
 	rth->dst.output =3D ip_output;
=20
-	rt_set_nexthop(rth, daddr, res, NULL, res->fi, res->type, itag);
+	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
 	skb_dst_set(skb, &rth->dst);
 out:
 	err =3D 0;
@@ -1882,7 +1917,7 @@ static struct rtable *__mkroute_output(const stru=
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
1.8.3.1
