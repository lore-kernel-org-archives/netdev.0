From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 21:26:09 +0200
Message-ID: <1283887569.2634.95.camel@edumazet-laptop>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>
	 <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl>
	 <4C855385.7030203@ans.pl>  <4C865C21.5010803@ans.pl>
	 <1283877391.2313.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35787 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757519Ab0IGT0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 15:26:15 -0400
Received: by fxm16 with SMTP id 16so242711fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 12:26:14 -0700 (PDT)
In-Reply-To: <1283877391.2313.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 18:36 +0200, Eric Dumazet a =C3=A9cri=
t :

> Hmm, I have a pretty good idea of what the problem is, and will post =
a
> fix soon ;)

David, if you feel this is too invasive for stable, we can make UDP
rehash the socket in case we dont want to change ip4_datagram_connect()


[PATCH] inet: Dont set inet_rcv_saddr in connect()

So the problem is that the sequence :

socket(PF_INET, SOCK_DGRAM, IPPROTO_IP)

connect(fd, {sa_family=3DAF_INET, sin_port=3Dhtons(xx),
sin_addr=3Dinet_addr("1.2.3.4")}, 28)

1) Does an implicit inet_autobind()
  (using an INADDR_ANY address, and selecting a random port).

2) Then does an ip4_datagram_connect() to specify the address/port of
remote end point.

Problem is ip4_datagram_connect() also sets inet->inet_rcv_saddr (from
INADDR_ANY to IP source address, given the current route to remote end
point). Only the first connect() on the socket does this. Following one=
s
dont change the (possibly wrong) source address.

This breaks the secondary UDP hash, based on (ADDRESS, port), that was
computed by inet_autobind().

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
 net/ipv4/datagram.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index f055094..8a17241 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -60,10 +60,19 @@ int ip4_datagram_connect(struct sock *sk, struct so=
ckaddr *uaddr, int addr_len)
 		ip_rt_put(rt);
 		return -EACCES;
 	}
+/*
+ * Should connect() change inet_rcv_saddr ?
+ * It should not IMHO, because we want to specify the peer to which
+ * datagrams are to be sent, regardless of our source address that mig=
ht
+ * change in the future, after a route change.
+ * To specify our source address, bind() is the right API.
+ */
+#if 0
 	if (!inet->inet_saddr)
 		inet->inet_saddr =3D rt->rt_src;	/* Update source address */
 	if (!inet->inet_rcv_saddr)
 		inet->inet_rcv_saddr =3D rt->rt_src;
+#endif
 	inet->inet_daddr =3D rt->rt_dst;
 	inet->inet_dport =3D usin->sin_port;
 	sk->sk_state =3D TCP_ESTABLISHED;


