From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Fri, 8 Jan 2010 16:12:55 -0800
Message-ID: <b91784ff1001081612g7c15e968u5e77931289af25c@mail.gmail.com>
References: <65634d661001062043s1b4eb204v63566149bb44f144@mail.gmail.com>
	<20100107.012701.257511338.davem@davemloft.net> <55a4f86e1001071705i33f8c58cubae56f5616216de4@mail.gmail.com>
	<20100107.171015.29035630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:8039 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340Ab0AIANU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 19:13:20 -0500
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o090DI4j029720
	for <netdev@vger.kernel.org>; Sat, 9 Jan 2010 00:13:18 GMT
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by wpaz17.hot.corp.google.com with ESMTP id o090DFfS028101
	for <netdev@vger.kernel.org>; Fri, 8 Jan 2010 16:13:16 -0800
Received: by pzk27 with SMTP id 27so30200pzk.12
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2010 16:13:15 -0800 (PST)
In-Reply-To: <20100107.171015.29035630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/1/7 David Miller <davem@davemloft.net>
> =A0=A0 ipv4: Update MTU to all related cache entries in ip_rt_frag_ne=
eded()
>
> =A0 =A0Add struct net_device parameter to ip_rt_frag_needed() and upd=
ate MTU to
> =A0 =A0cache entries where ifindex is specified. This is similar to w=
hat is
> =A0 =A0already done in ip_rt_redirect().
> [...]
> + =A0 =A0 =A0 int =A0ikeys[2] =3D { dev->ifindex, 0 };
> =A0 =A0 =A0 =A0__be32 =A0skeys[2] =3D { iph->saddr, 0, };
> =A0 =A0 =A0 =A0__be32 =A0daddr =3D iph->daddr;
> [...]

That patch makes it so that if a fragmentation needed message is
received on an interface other than the one that the kernel would
normally use to send a message to the original destination, then any
route cache entries pointing out that interface are updated as well.
AFAICT it was motivated by a scenario where traffic =A0was intended to
be sent through a particular interface with SO_BINDTODEVICE set:
http://lists.openwall.net/netdev/2008/04/24/44

The correct thing to do would be to update the MTU on all the route
cache entries, including entries pointing to other interfaces on the
box (for example, consider a box with a default route pointing at
eth0, the packet too big coming in on eth1, and the original packet
having been sent through gre1 with SO_BINDTODEVICE; in this case, the
existing IPv4 code would silently fail). However, this=A0is expensive
and doing it for the two common cases seems a reasonable compromise,
so it's probably worth doing it for IPv6 as well.

How about this patch instead?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2bd74c..c27464d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1562,14 +1562,13 @@ out:
  *	i.e. Path MTU discovery
  */

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

-	rt =3D rt6_lookup(net, daddr, saddr, dev->ifindex, 0);
+	rt =3D rt6_lookup(net, daddr, saddr, ifindex, 0);
 	if (rt =3D=3D NULL)
 		return;

@@ -1637,6 +1636,28 @@ out:
 	dst_release(&rt->u.dst);
 }

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
+
 /*
  *	Misc support functions
  */
