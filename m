From: Nikola =?ISO-8859-1?Q?Forr=F3?= <nforro@redhat.com>
Subject: [PATCH v4] net: Fix behaviour of unreachable, blackhole and
 prohibit routes
Date: Thu, 17 Sep 2015 16:01:32 +0200
Message-ID: <1442498492.2914.1.camel@redhat.com>
Reply-To: nforro@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44426 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753AbbIQOBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:01:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Man page of ip-route(8) says following about route types:

  unreachable - these destinations are unreachable.  Packets are dis=E2=
=80=90
  carded and the ICMP message host unreachable is generated.  The local
  senders get an EHOSTUNREACH error.

  blackhole - these destinations are unreachable.  Packets are dis=E2=80=
=90
  carded silently.  The local senders get an EINVAL error.

  prohibit - these destinations are unreachable.  Packets are discarded
  and the ICMP message communication administratively prohibited is
  generated.  The local senders get an EACCES error.

In the inet6 address family, this was correct, except the local senders
got ENETUNREACH error instead of EHOSTUNREACH in case of unreachable ro=
ute.
In the inet address family, all three route types generated ICMP messag=
e
net unreachable, and the local senders got ENETUNREACH error.

In both address families all three route types now behave consistently
with documentation.

Signed-off-by: Nikola Forr=C3=B3 <nforro@redhat.com>
---
 include/net/ip_fib.h | 30 +++++++++++++++++++-----------
 net/ipv4/route.c     |  6 ++++--
 net/ipv6/route.c     |  4 +++-
 3 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index a37d043..727d6e9 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -236,8 +236,11 @@ static inline int fib_lookup(struct net *net, cons=
t struct flowi4 *flp,
 	rcu_read_lock();
=20
 	tb =3D fib_get_table(net, RT_TABLE_MAIN);
-	if (tb && !fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF))
-		err =3D 0;
+	if (tb)
+		err =3D fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
+
+	if (err =3D=3D -EAGAIN)
+		err =3D -ENETUNREACH;
=20
 	rcu_read_unlock();
=20
@@ -258,7 +261,7 @@ static inline int fib_lookup(struct net *net, struc=
t flowi4 *flp,
 			     struct fib_result *res, unsigned int flags)
 {
 	struct fib_table *tb;
-	int err;
+	int err =3D -ENETUNREACH;
=20
 	flags |=3D FIB_LOOKUP_NOREF;
 	if (net->ipv4.fib_has_custom_rules)
@@ -268,15 +271,20 @@ static inline int fib_lookup(struct net *net, str=
uct flowi4 *flp,
=20
 	res->tclassid =3D 0;
=20
-	for (err =3D 0; !err; err =3D -ENETUNREACH) {
-		tb =3D rcu_dereference_rtnl(net->ipv4.fib_main);
-		if (tb && !fib_table_lookup(tb, flp, res, flags))
-			break;
+	tb =3D rcu_dereference_rtnl(net->ipv4.fib_main);
+	if (tb)
+		err =3D fib_table_lookup(tb, flp, res, flags);
+
+	if (!err)
+		goto out;
+
+	tb =3D rcu_dereference_rtnl(net->ipv4.fib_default);
+	if (tb)
+		err =3D fib_table_lookup(tb, flp, res, flags);
=20
-		tb =3D rcu_dereference_rtnl(net->ipv4.fib_default);
-		if (tb && !fib_table_lookup(tb, flp, res, flags))
-			break;
-	}
+out:
+	if (err =3D=3D -EAGAIN)
+		err =3D -ENETUNREACH;
=20
 	rcu_read_unlock();
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5f4a556..c6ad99a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2045,6 +2045,7 @@ struct rtable *__ip_route_output_key(struct net *=
net, struct flowi4 *fl4)
 	struct fib_result res;
 	struct rtable *rth;
 	int orig_oif;
+	int err =3D -ENETUNREACH;
=20
 	res.tclassid	=3D 0;
 	res.fi		=3D NULL;
@@ -2153,7 +2154,8 @@ struct rtable *__ip_route_output_key(struct net *=
net, struct flowi4 *fl4)
 		goto make_route;
 	}
=20
-	if (fib_lookup(net, fl4, &res, 0)) {
+	err =3D fib_lookup(net, fl4, &res, 0);
+	if (err) {
 		res.fi =3D NULL;
 		res.table =3D NULL;
 		if (fl4->flowi4_oif) {
@@ -2181,7 +2183,7 @@ struct rtable *__ip_route_output_key(struct net *=
net, struct flowi4 *fl4)
 			res.type =3D RTN_UNICAST;
 			goto make_route;
 		}
-		rth =3D ERR_PTR(-ENETUNREACH);
+		rth =3D ERR_PTR(err);
 		goto out;
 	}
=20
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3d3c1b2..a608ace 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1885,9 +1885,11 @@ int ip6_route_info_create(struct fib6_config *cf=
g, struct rt6_info **rt_ret)
 			rt->dst.input =3D ip6_pkt_prohibit;
 			break;
 		case RTN_THROW:
+		case RTN_UNREACHABLE:
 		default:
 			rt->dst.error =3D (cfg->fc_type =3D=3D RTN_THROW) ? -EAGAIN
-					: -ENETUNREACH;
+					: (cfg->fc_type =3D=3D RTN_UNREACHABLE)
+					? -EHOSTUNREACH : -ENETUNREACH;
 			rt->dst.output =3D ip6_pkt_discard_out;
 			rt->dst.input =3D ip6_pkt_discard;
 			break;
--=20
2.4.3
