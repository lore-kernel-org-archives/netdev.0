From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Tue, 07 Sep 2010 23:35:16 +0200
Message-ID: <1283895316.2634.248.camel@edumazet-laptop>
References: <4C865C21.5010803@ans.pl>
	 <1283877391.2313.62.camel@edumazet-laptop>
	 <1283887569.2634.95.camel@edumazet-laptop>
	 <20100907.125947.39192078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ole@ans.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46774 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757589Ab0IGVfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 17:35:22 -0400
Received: by fxm16 with SMTP id 16so328854fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 14:35:20 -0700 (PDT)
In-Reply-To: <20100907.125947.39192078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 12:59 -0700, David Miller a =C3=A9cri=
t :

> Eric, please just delete the code block instead of leaving it
> there inside of an #if 0 block.
>=20
> If there is information conveyed by the unused code, add that
> information to the nice comment you're adding :-)
>=20

Indeed ;)

[PATCH] inet: dont set inet_rcv_saddr in connect()

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

Reported-by: Krzysztof Ol=C4=99dzki <ole@ans.pl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/datagram.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index f055094..656dc73 100644
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


