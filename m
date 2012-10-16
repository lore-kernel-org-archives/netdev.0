From: David Miller <davem@davemloft.net>
Subject: Re: [stable 2.6.32.y] net/ipv4: fix cached ipv4 dsts never
 invalidated
Date: Tue, 16 Oct 2012 16:45:39 -0400 (EDT)
Message-ID: <20121016.164539.753785374589743655.davem@davemloft.net>
References: <20121016203449.GA25889@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: w@1wt.eu, stable@vger.kernel.org, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304Ab2JPUpl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 16:45:41 -0400
In-Reply-To: <20121016203449.GA25889@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 16 Oct 2012 16:41:04 -0400

> From: Timo Teras <timo.teras@iki.fi>
> commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92
> Author: Timo Ter=E4s <timo.teras@iki.fi>
> Date:   Thu Mar 18 23:20:20 2010 +0000
>=20
>     ipv4: check rt_genid in dst_check
>    =20
>     Xfrm_dst keeps a reference to ipv4 rtable entries on each
>     cached bundle. The only way to renew xfrm_dst when the underlying
>     route has changed, is to implement dst_check for this. This is
>     what ipv6 side does too.
>    =20
>     The problems started after 87c1e12b5eeb7b30b4b41291bef8e0b41fc3dd=
e9
>     ("ipsec: Fix bogus bundle flowi") which fixed a bug causing xfrm_=
dst
>     to not get reused, until that all lookups always generated new
>     xfrm_dst with new route reference and path mtu worked. But after =
the
>     fix, the old routes started to get reused even after they were ex=
pired
>     causing pmtu to break (well it would occationally work if the rta=
ble
>     gc had run recently and marked the route obsolete causing dst_che=
ck to
>     get called).
>    =20
>     Signed-off-by: Timo Teras <timo.teras@iki.fi>
>     Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> Hi Willy,
>=20
> Can you please consider applying d11a4dc18bf41719c9f0d7ed494d295dd297=
3b92=20
> to 2.6.32.y?  This fixes an issue with cached IPv4 routes never being=
=20
> invalidated.  For more details of the problem this causes, see=20
> http://marc.info/?l=3Dlinux-netdev&m=3D135015076708950&w=3D2 .  Thank=
s!

This is only a partial fix.

Only recently did this issue get resolved completely.

See commits surrounding:

=46rom b42664f898c976247f7f609b8bb9c94d7475ca10 Mon Sep 17 00:00:00 200=
1
=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 10 Sep 2012 22:09:44 +0000
Subject: [PATCH] netns: move net->ipv4.rt_genid to net->rt_genid

This commit prepares the use of rt_genid by both IPv4 and IPv6.
Initialization is left in IPv4 part.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/net_namespace.h | 10 ++++++++++
 include/net/netns/ipv4.h    |  1 -
 net/ipv4/route.c            |  9 ++-------
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index ae1cd6c..fd87963 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -102,6 +102,7 @@ struct net {
 #endif
 	struct netns_ipvs	*ipvs;
 	struct sock		*diag_nlsk;
+	atomic_t		rt_genid;
 };
=20
=20
@@ -300,5 +301,14 @@ static inline void unregister_net_sysctl_table(str=
uct ctl_table_header *header)
 }
 #endif
=20
+static inline int rt_genid(struct net *net)
+{
+	return atomic_read(&net->rt_genid);
+}
+
+static inline void rt_genid_bump(struct net *net)
+{
+	atomic_inc(&net->rt_genid);
+}
=20
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 1474dd6..eb24dbc 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -65,7 +65,6 @@ struct netns_ipv4 {
 	unsigned int sysctl_ping_group_range[2];
 	long sysctl_tcp_mem[3];
=20
-	atomic_t rt_genid;
 	atomic_t dev_addr_genid;
=20
 #ifdef CONFIG_IP_MROUTE
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index be27cfa9..fd9af60 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -202,11 +202,6 @@ EXPORT_SYMBOL(ip_tos2prio);
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 #define RT_CACHE_STAT_INC(field) __this_cpu_inc(rt_cache_stat.field)
=20
-static inline int rt_genid(struct net *net)
-{
-	return atomic_read(&net->ipv4.rt_genid);
-}
-
 #ifdef CONFIG_PROC_FS
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
@@ -449,7 +444,7 @@ static inline bool rt_is_expired(const struct rtabl=
e *rth)
=20
 void rt_cache_flush(struct net *net)
 {
-	atomic_inc(&net->ipv4.rt_genid);
+	rt_genid_bump(net);
 }
=20
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst=
,
@@ -2506,7 +2501,7 @@ static __net_initdata struct pernet_operations sy=
sctl_route_ops =3D {
=20
 static __net_init int rt_genid_init(struct net *net)
 {
-	atomic_set(&net->ipv4.rt_genid, 0);
+	atomic_set(&net->rt_genid, 0);
 	get_random_bytes(&net->ipv4.dev_addr_genid,
 			 sizeof(net->ipv4.dev_addr_genid));
 	return 0;
--=20
1.7.11.7
