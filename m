From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] ipv6: force RTF_NONEXTHOP for SIT device
Date: Wed, 12 Sep 2012 14:01:06 +0200
Message-ID: <1347451266.13103.882.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35151 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755024Ab2ILMBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 08:01:11 -0400
Received: by eaac11 with SMTP id c11so799888eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 05:01:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

We have special handling of SIT devices in addrconf_prefix_route()
to avoid using a neighbour for each destination.

If routing entry is :

ip -6 route add 2001:db8::/64 dev sit1

Then the kernel will create a new route for every new address
under 2001:db8::/64 that we send a packet to (potentially, 2^64
routes).

Under load, we immediately get the infamous "Neighbour table overflow"
message and machine eventually crash.

This does not happen if we specify a next-hop explicitly, like so:

ip -6 route add 2001:db8::/64 via fe80:: dev sit1

We can avoid this hassle doing the SIT test in ip6_route_add() instead
of addrconf_prefix_route().

This permits ip6_pol_route() to clone route instead of calling
rt6_alloc_cow() and allocate a neighbour

Reported-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv6/addrconf.c |   10 ----------
 net/ipv6/route.c    |    9 +++++++++
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1237d5d..c6837d2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1679,16 +1679,6 @@ addrconf_prefix_route(struct in6_addr *pfx, int =
plen, struct net_device *dev,
 	};
=20
 	cfg.fc_dst =3D *pfx;
-
-	/* Prevent useless cloning on PtP SIT.
-	   This thing is done here expecting that the whole
-	   class of non-broadcast devices need not cloning.
-	 */
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
-	if (dev->type =3D=3D ARPHRD_SIT && (dev->flags & IFF_POINTOPOINT))
-		cfg.fc_flags |=3D RTF_NONEXTHOP;
-#endif
-
 	ip6_route_add(&cfg);
 }
=20
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 399613b..d4ba3fc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1540,6 +1540,15 @@ int ip6_route_add(struct fib6_config *cfg)
 	} else
 		rt->rt6i_prefsrc.plen =3D 0;
=20
+	/* Prevent useless cloning on PtP SIT.
+	 *  This thing is done here expecting that the whole
+	 *  class of non-broadcast devices need not cloning.
+	 */
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+	if (dev && dev->type =3D=3D ARPHRD_SIT && (dev->flags & IFF_POINTOPOI=
NT))
+		cfg->fc_flags |=3D RTF_NONEXTHOP;
+#endif
+
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
 		err =3D rt6_bind_neighbour(rt, dev);
 		if (err)
