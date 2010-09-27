From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: Fix IPv6 PMTU disc. w/ asymmetric routes
Date: Mon, 27 Sep 2010 03:05:57 -0700
Message-ID: <1285581957-30694-1-git-send-email-zenczykowski@gmail.com>
References: <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:39154 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab0I0KGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 06:06:45 -0400
Received: by pxi10 with SMTP id 10so1306527pxi.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 03:06:45 -0700 (PDT)
In-Reply-To: <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv6/route.c |   31 +++++++++++++++++++++++++++----
 1 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3a74f90..d700d1c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1559,14 +1559,13 @@ out:
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
@@ -1634,6 +1633,30 @@ out:
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
+	/* also support source address based routing */
+	rt6_do_pmtu_disc(daddr, NULL, net, pmtu, 0);
+	rt6_do_pmtu_disc(daddr, NULL, net, pmtu, dev->ifindex);
+}
+
 /*
  *	Misc support functions
  */
--=20
1.7.2.3

