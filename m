From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Sat, 30 Jul 2011 07:00:53 +0200
Message-ID: <1312002053.2873.41.camel@edumazet-laptop>
References: <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32C76B.5010700@hippy.csoma.elte.hu>
	 <1311952306.2843.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110729.081902.300678107767426313.davem@davemloft.net>
	 <1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59427 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab1G3FA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2011 01:00:59 -0400
Received: by wwe5 with SMTP id 5so4124715wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 22:00:57 -0700 (PDT)
In-Reply-To: <1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 17:43 +0200, Eric Dumazet a =C3=A9cr=
it :

> Oh well, we already use RCU in neigh_destroy(), so adding rcu would n=
eed
> to change all dst_get_neighbour() callers to be in one rcu_read_lock(=
)
> section.
>=20
> I'll take a look, I suspect its mostly already done.
>=20
>=20

Here is the patch I finally cooked and tested.

Could you please test it as well Gergely ?

Thanks !

[PATCH] net: fix NULL dereferences in check_peer_redir()

Gergely Kalman reported crashes in check_peer_redir().

It appears commit f39925dbde778 (ipv4: Cache learned redirect
information in inetpeer.) added a race, leading to possible NULL ptr
dereference.

Since we can now change dst neighbour, we should make sure a reader can
safely use a neighbour.

Add RCU protection to dst neighbour, and make sure check_peer_redir()
can be called safely by different cpus in parallel.

As neighbours are already freed after one RCU grace period, this patch
should not add typical RCU penalty (cache cold effects)

Many thanks to Gergely for providing a pretty report pointing to the
bug.

Reported-by: Gergely Kalman <synapse@hippy.csoma.elte.hu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/dst.h     |   17 +++++++++++++----
 net/ipv4/ip_output.c  |   10 ++++++++--
 net/ipv4/route.c      |   14 ++++++++------
 net/ipv6/addrconf.c   |    2 +-
 net/ipv6/ip6_fib.c    |    2 +-
 net/ipv6/ip6_output.c |   13 +++++++++++--
 net/ipv6/route.c      |   35 +++++++++++++++++++++++++----------
 7 files changed, 67 insertions(+), 26 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 29e2557..13d507d 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -37,7 +37,7 @@ struct dst_entry {
 	unsigned long		_metrics;
 	unsigned long		expires;
 	struct dst_entry	*path;
-	struct neighbour	*_neighbour;
+	struct neighbour __rcu	*_neighbour;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
@@ -88,12 +88,17 @@ struct dst_entry {
=20
 static inline struct neighbour *dst_get_neighbour(struct dst_entry *ds=
t)
 {
-	return dst->_neighbour;
+	return rcu_dereference(dst->_neighbour);
+}
+
+static inline struct neighbour *dst_get_neighbour_raw(struct dst_entry=
 *dst)
+{
+	return rcu_dereference_raw(dst->_neighbour);
 }
=20
 static inline void dst_set_neighbour(struct dst_entry *dst, struct nei=
ghbour *neigh)
 {
-	dst->_neighbour =3D neigh;
+	rcu_assign_pointer(dst->_neighbour, neigh);
 }
=20
 extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned lo=
ng old);
@@ -382,8 +387,12 @@ static inline void dst_rcu_free(struct rcu_head *h=
ead)
 static inline void dst_confirm(struct dst_entry *dst)
 {
 	if (dst) {
-		struct neighbour *n =3D dst_get_neighbour(dst);
+		struct neighbour *n;
+
+		rcu_read_lock();
+		n =3D dst_get_neighbour(dst);
 		neigh_confirm(n);
+		rcu_read_unlock();
 	}
 }
=20
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ccaaa85..77d3ede 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -204,9 +204,15 @@ static inline int ip_finish_output2(struct sk_buff=
 *skb)
 		skb =3D skb2;
 	}
=20
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(dst);
-	if (neigh)
-		return neigh_output(neigh, skb);
+	if (neigh) {
+		int res =3D neigh_output(neigh, skb);
+
+		rcu_read_unlock();
+		return res;
+	}
+	rcu_read_unlock();
=20
 	if (net_ratelimit())
 		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbo=
ur!\n");
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1730689..6afc4eb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1628,16 +1628,18 @@ static int check_peer_redir(struct dst_entry *d=
st, struct inet_peer *peer)
 {
 	struct rtable *rt =3D (struct rtable *) dst;
 	__be32 orig_gw =3D rt->rt_gateway;
-	struct neighbour *n;
+	struct neighbour *n, *old_n;
=20
 	dst_confirm(&rt->dst);
=20
-	neigh_release(dst_get_neighbour(&rt->dst));
-	dst_set_neighbour(&rt->dst, NULL);
-
 	rt->rt_gateway =3D peer->redirect_learned.a4;
-	rt_bind_neighbour(rt);
-	n =3D dst_get_neighbour(&rt->dst);
+
+	n =3D ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
+	if (IS_ERR(n))
+		return PTR_ERR(n);
+	old_n =3D xchg(&rt->dst._neighbour, n);
+	if (old_n)
+		neigh_release(old_n);
 	if (!n || !(n->nud_state & NUD_VALID)) {
 		if (n)
 			neigh_event_send(n, NULL);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a55500c..f012ebd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -656,7 +656,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct =
in6_addr *addr, int pfxlen,
 	 * layer address of our nexhop router
 	 */
=20
-	if (dst_get_neighbour(&rt->dst) =3D=3D NULL)
+	if (dst_get_neighbour_raw(&rt->dst) =3D=3D NULL)
 		ifa->flags &=3D ~IFA_F_OPTIMISTIC;
=20
 	ifa->idev =3D idev;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 54a4678..320d91d 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1455,7 +1455,7 @@ static int fib6_age(struct rt6_info *rt, void *ar=
g)
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
-			   (!(dst_get_neighbour(&rt->dst)->flags & NTF_ROUTER))) {
+			   (!(dst_get_neighbour_raw(&rt->dst)->flags & NTF_ROUTER))) {
 			RT6_TRACE("purging route %p via non-router but gateway\n",
 				  rt);
 			return -1;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 32e5339..4c882cf 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -135,10 +135,15 @@ static int ip6_finish_output2(struct sk_buff *skb=
)
 				skb->len);
 	}
=20
+	rcu_read_lock();
 	neigh =3D dst_get_neighbour(dst);
-	if (neigh)
-		return neigh_output(neigh, skb);
+	if (neigh) {
+		int res =3D neigh_output(neigh, skb);
=20
+		rcu_read_unlock();
+		return res;
+	}
+	rcu_read_unlock();
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
@@ -975,12 +980,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry and replace it instead with the
 	 * dst entry of the nexthop router
 	 */
+	rcu_read_lock();
 	n =3D dst_get_neighbour(*dst);
 	if (n && !(n->nud_state & NUD_VALID)) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
 		int redirect;
=20
+		rcu_read_unlock();
 		ifp =3D ipv6_get_ifaddr(net, &fl6->saddr,
 				      (*dst)->dev, 1);
=20
@@ -1000,6 +1007,8 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			if ((err =3D (*dst)->error))
 				goto out_err_release;
 		}
+	} else {
+		rcu_read_unlock();
 	}
 #endif
=20
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e8987da..9e69eb0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -364,7 +364,7 @@ out:
 #ifdef CONFIG_IPV6_ROUTER_PREF
 static void rt6_probe(struct rt6_info *rt)
 {
-	struct neighbour *neigh =3D rt ? dst_get_neighbour(&rt->dst) : NULL;
+	struct neighbour *neigh;
 	/*
 	 * Okay, this does not seem to be appropriate
 	 * for now, however, we need to check if it
@@ -373,8 +373,10 @@ static void rt6_probe(struct rt6_info *rt)
 	 * Router Reachability Probe MUST be rate-limited
 	 * to no more than one per minute.
 	 */
+	rcu_read_lock();
+	neigh =3D rt ? dst_get_neighbour(&rt->dst) : NULL;
 	if (!neigh || (neigh->nud_state & NUD_VALID))
-		return;
+		goto out;
 	read_lock_bh(&neigh->lock);
 	if (!(neigh->nud_state & NUD_VALID) &&
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe=
_interval)) {
@@ -387,8 +389,11 @@ static void rt6_probe(struct rt6_info *rt)
 		target =3D (struct in6_addr *)&neigh->primary_key;
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(rt->rt6i_dev, NULL, target, &mcaddr, NULL);
-	} else
+	} else {
 		read_unlock_bh(&neigh->lock);
+	}
+out:
+	rcu_read_unlock();
 }
 #else
 static inline void rt6_probe(struct rt6_info *rt)
@@ -412,8 +417,11 @@ static inline int rt6_check_dev(struct rt6_info *r=
t, int oif)
=20
 static inline int rt6_check_neigh(struct rt6_info *rt)
 {
-	struct neighbour *neigh =3D dst_get_neighbour(&rt->dst);
+	struct neighbour *neigh;
 	int m;
+
+	rcu_read_lock();
+	neigh =3D dst_get_neighbour(&rt->dst);
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
 		m =3D 1;
@@ -430,6 +438,7 @@ static inline int rt6_check_neigh(struct rt6_info *=
rt)
 		read_unlock_bh(&neigh->lock);
 	} else
 		m =3D 0;
+	rcu_read_unlock();
 	return m;
 }
=20
@@ -769,7 +778,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_=
info *ort,
 		rt->rt6i_dst.plen =3D 128;
 		rt->rt6i_flags |=3D RTF_CACHE;
 		rt->dst.flags |=3D DST_HOST;
-		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour(&ort->dst)=
));
+		dst_set_neighbour(&rt->dst, neigh_clone(dst_get_neighbour_raw(&ort->=
dst)));
 	}
 	return rt;
 }
@@ -803,7 +812,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
=20
-	if (!dst_get_neighbour(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP)=
)
+	if (!dst_get_neighbour_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXT=
HOP))
 		nrt =3D rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt =3D rt6_alloc_clone(rt, &fl6->daddr);
@@ -1587,7 +1596,7 @@ void rt6_redirect(const struct in6_addr *dest, co=
nst struct in6_addr *src,
 	dst_confirm(&rt->dst);
=20
 	/* Duplicate redirect: silently ignore. */
-	if (neigh =3D=3D dst_get_neighbour(&rt->dst))
+	if (neigh =3D=3D dst_get_neighbour_raw(&rt->dst))
 		goto out;
=20
 	nrt =3D ip6_rt_copy(rt, dest);
@@ -1682,7 +1691,7 @@ again:
 	   1. It is connected route. Action: COW
 	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
 	 */
-	if (!dst_get_neighbour(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP)=
)
+	if (!dst_get_neighbour_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXT=
HOP))
 		nrt =3D rt6_alloc_cow(rt, daddr, saddr);
 	else
 		nrt =3D rt6_alloc_clone(rt, daddr);
@@ -2326,6 +2335,7 @@ static int rt6_fill_node(struct net *net,
 	struct nlmsghdr *nlh;
 	long expires;
 	u32 table;
+	struct neighbour *n;
=20
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2414,8 +2424,11 @@ static int rt6_fill_node(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
=20
-	if (dst_get_neighbour(&rt->dst))
-		NLA_PUT(skb, RTA_GATEWAY, 16, &dst_get_neighbour(&rt->dst)->primary_=
key);
+	rcu_read_lock();
+	n =3D dst_get_neighbour(&rt->dst);
+	if (n)
+		NLA_PUT(skb, RTA_GATEWAY, 16, &n->primary_key);
+	rcu_read_unlock();
=20
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
@@ -2608,12 +2621,14 @@ static int rt6_info_route(struct rt6_info *rt, =
void *p_arg)
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
+	rcu_read_lock();
 	n =3D dst_get_neighbour(&rt->dst);
 	if (n) {
 		seq_printf(m, "%pi6", n->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
+	rcu_read_unlock();
 	seq_printf(m, " %08x %08x %08x %08x %8s\n",
 		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
 		   rt->dst.__use, rt->rt6i_flags,


