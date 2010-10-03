From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix IPv6 PMTU disc. w/ asymmetric routes
Date: Sun, 03 Oct 2010 14:49:31 -0700 (PDT)
Message-ID: <20101003.144931.71122620.davem@davemloft.net>
References: <20100928.135800.39205209.davem@davemloft.net>
	<AANLkTi=9THOcD9FieK3uy635C1kNDc=uEdtDe4qm1WU6@mail.gmail.com>
	<20100930.004136.91329579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751647Ab0JCVtL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Oct 2010 17:49:11 -0400
In-Reply-To: <20100930.004136.91329579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Thu, 30 Sep 2010 00:41:36 -0700 (PDT)

> Maybe the problem is that the ipv6 side uses the same saddr for both
> the lookup and the entry comparison in these PMTU code paths?  Does i=
t
> not allow specifying them seperately as the ipv4 PMTU (and incidently
> the RT redirect) code paths do?
>=20
> Or is this not an issue on the ipv6 side for some reason?

Ok, meanwhile I did the research.

What ipv6 does is that when you lookup a route, it clones or copies
the prefixes route into one that is fully specified for a specific
SADDR/DADDR pair, and then inserts that specific route into the FIB6
tree.

Therefore the only cases we should lookup for PMTU discovery for ipv6
are:

	{ daddr, saddr, ifindex =3D=3D 0 }
	{ daddr, saddr, ifindex =3D=3D dev->ifindex }

This achieves the same effect as what ipv4 is doing.

So Maciej your original attempt was correct all along, and as a result
I'll commit the following.

Thanks!

--------------------
net: Fix IPv6 PMTU disc. w/ asymmetric routes

Signed-off-by: Maciej =AFenczykowski <maze@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8323136..a275c6e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1556,14 +1556,13 @@ out:
  *	i.e. Path MTU discovery
  */
=20
-void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr=
,
-			struct net_device *dev, u32 pmtu)
+static void rt6_do_pmtu_disc(struct in6_addr *daddr, struct in6_addr *=
saddr,
+			     struct net *net, u32 pmtu, int ifindex)
 {
 	struct rt6_info *rt, *nrt;
-	struct net *net =3D dev_net(dev);
 	int allfrag =3D 0;
=20
-	rt =3D rt6_lookup(net, daddr, saddr, dev->ifindex, 0);
+	rt =3D rt6_lookup(net, daddr, saddr, ifindex, 0);
 	if (rt =3D=3D NULL)
 		return;
=20
@@ -1631,6 +1630,27 @@ out:
 	dst_release(&rt->dst);
 }
=20
+void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr=
,
+			struct net_device *dev, u32 pmtu)
+{
+	struct net *net =3D dev_net(dev);
+
+	/*
+	 * RFC 1981 states that a node "MUST reduce the size of the packets i=
t
+	 * is sending along the path" that caused the Packet Too Big message.
+	 * Since it's not possible in the general case to determine which
+	 * interface was used to send the original packet, we update the MTU
+	 * on the interface that will be used to send future packets. We also
+	 * update the MTU on the interface that received the Packet Too Big i=
n
+	 * case the original packet was forced out that interface with
+	 * SO_BINDTODEVICE or similar. This is the next best thing to the
+	 * correct behaviour, which would be to update the MTU on all
+	 * interfaces.
+	 */
+	rt6_do_pmtu_disc(daddr, saddr, net, pmtu, 0);
+	rt6_do_pmtu_disc(daddr, saddr, net, pmtu, dev->ifindex);
+}
+
 /*
  *	Misc support functions
  */
--=20
1.7.3.1

