From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Tue, 07 Sep 2010 19:16:06 -0700 (PDT)
Message-ID: <20100907.191606.102548977.davem@davemloft.net>
References: <20100907.125947.39192078.davem@davemloft.net>
	<1283895316.2634.248.camel@edumazet-laptop>
	<4C86B402.5000205@ans.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320Ab0IHCPt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 22:15:49 -0400
In-Reply-To: <4C86B402.5000205@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ol=EAdzki <ole@ans.pl>
Date: Tue, 07 Sep 2010 23:52:02 +0200

>> [PATCH] inet: dont set inet_rcv_saddr in connect()
 ...
>> Reported-by: Krzysztof Ol=EAdzki <ole@ans.pl>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Eric, ipv6 has the same problem so I fixed it there too.

Here is the final patch I put into net-2.6, thanks!

--------------------
inet: dont set inet_rcv_saddr in connect()

The following sequence :

socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)

connect(fd, {sa_family=3DAF_INET, sin_port=3Dhtons(xx),
sin_addr=3Dinet_addr("1.2.3.4")}, 28)

1) Does an implicit inet_autobind()
  (using an INADDR_ANY address, and selecting a random port).

2) Does an ip4_datagram_connect() to specify the address/port of
remote end point.

Problem is ip4_datagram_connect() also sets inet->inet_rcv_saddr (from
INADDR_ANY to IP source address, given the current route to remote end
point). Only the first connect() on the socket does this. Following one=
s
dont change the (possibly wrong) source address.

This breaks the secondary UDP hash, based on (ADDRESS, port), that was
computed by inet_autobind(). If more than 10 sockets are linked in
primary hash chain, we can drop incoming packets because searches are
done in wrong secondary hash chain.

This also potentially breaks multiple connect() to change remote
endpoints, because old source address might be non usable for packets t=
o
new destination.

If route happens to change, then we should automatically change our
source address too, at next sendmsg() call, and UDP code deals with thi=
s
just fine.

If an application needs to specify a precise source address, it must us=
e
bind() system call. connect() man page only refers to remote address,
not local one.

[ IPV6 has the same problem so fix it there too. -DaveM ]

Reported-by: Krzysztof Ol=EAdzki <ole@ans.pl>
Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/datagram.c |   11 +++++++----
 net/ipv6/datagram.c |   31 +++++++++++++++----------------
 2 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index f055094..a59492c 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -60,10 +60,13 @@ int ip4_datagram_connect(struct sock *sk, struct so=
ckaddr *uaddr, int addr_len)
 		ip_rt_put(rt);
 		return -EACCES;
 	}
-	if (!inet->inet_saddr)
-		inet->inet_saddr =3D rt->rt_src;	/* Update source address */
-	if (!inet->inet_rcv_saddr)
-		inet->inet_rcv_saddr =3D rt->rt_src;
+	/*
+	 * Should connect() change inet_rcv_saddr / inet_saddr ?
+	 * It should not, because we want to specify the peer to which
+	 * datagrams are to be sent, regardless of our source address that
+	 * might change in the future, after a route change.
+	 * To specify our source address, bind() is the right API.
+	 */
 	inet->inet_daddr =3D rt->rt_dst;
 	inet->inet_dport =3D usin->sin_port;
 	sk->sk_state =3D TCP_ESTABLISHED;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 7d929a2..9c26556 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -102,13 +102,14 @@ ipv4_connected:
=20
 		ipv6_addr_set_v4mapped(inet->inet_daddr, &np->daddr);
=20
-		if (ipv6_addr_any(&np->saddr))
-			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
-
-		if (ipv6_addr_any(&np->rcv_saddr))
-			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
-					       &np->rcv_saddr);
-
+		/*
+		 * Should connect() change np->rcv_saddr / np->saddr ?
+		 * It should not, because we want to specify the
+		 * peer to which datagrams are to be sent, regardless
+		 * of our source address that might change in the
+		 * future, after a route change.  To specify our
+		 * source address, bind() is the right API.
+		 */
 		goto out;
 	}
=20
@@ -173,15 +174,13 @@ ipv4_connected:
 			goto out;
 	}
=20
-	/* source address lookup done in ip6_dst_lookup */
-
-	if (ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&np->saddr, &fl.fl6_src);
-
-	if (ipv6_addr_any(&np->rcv_saddr)) {
-		ipv6_addr_copy(&np->rcv_saddr, &fl.fl6_src);
-		inet->inet_rcv_saddr =3D LOOPBACK4_IPV6;
-	}
+	/*
+	 * Should connect() change np->rcv_saddr / np->saddr ?
+	 * It should not, because we want to specify the peer to which
+	 * datagrams are to be sent, regardless of our source address that
+	 * might change in the future, after a route change.
+	 * To specify our source address, bind() is the right API.
+	 */
=20
 	ip6_dst_store(sk, dst,
 		      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
--=20
1.7.2.2

