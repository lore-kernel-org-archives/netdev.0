From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 15:40:20 +0100
Message-ID: <1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EC2CA52.6020104@icdsoft.com>
	 <1321391355.2602.0.camel@edumazet-laptop> <4EC439F2.3080809@icdsoft.com>
	 <20111116223330.08de9e52@asterix.rh> <4EC4C160.6010804@icdsoft.com>
	 <20111117111145.252924f5@asterix.rh>
	 <1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Flavio Leitner <fbl@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60854 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab1KQOkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 09:40:24 -0500
Received: by wyh11 with SMTP id 11so2049047wyh.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 06:40:23 -0800 (PST)
In-Reply-To: <1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 14:15 +0100, Eric Dumazet a =C3=A9crit=
 :

> I'll take a look :)
>=20


While looking at it, I found that ICMP_MIB_INERRORS was incremented in
my (successful) ping tests.

netstat -s=20
=2E..
Icmp:
=2E..
    13 input ICMP message failed.
=2E..

[PATCH] ping: dont increment ICMP_MIB_INERRORS

ping module incorrectly increments ICMP_MIB_INERRORS if feeded with a
frame not belonging to its own sockets.

RFC 2011 states that ICMP_MIB_INERRORS should count "the number of ICMP
messages which the entiry received but determined as having
ICMP-specific errors (bad ICMP checksums, bad length, etc.)."

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Vasiliy Kulikov <segoon@openwall.com>
---
 net/ipv4/ping.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index a06f73f..43d4c3b 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -339,7 +339,6 @@ void ping_err(struct sk_buff *skb, u32 info)
 	sk =3D ping_v4_lookup(net, iph->daddr, iph->saddr,
 			    ntohs(icmph->un.echo.id), skb->dev->ifindex);
 	if (sk =3D=3D NULL) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		pr_debug("no socket, dropping\n");
 		return;	/* No socket for error */
 	}
@@ -679,7 +678,6 @@ static int ping_queue_rcv_skb(struct sock *sk, stru=
ct sk_buff *skb)
 	pr_debug("ping_queue_rcv_skb(sk=3D%p,sk->num=3D%d,skb=3D%p)\n",
 		inet_sk(sk), inet_sk(sk)->inet_num, skb);
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
-		ICMP_INC_STATS_BH(sock_net(sk), ICMP_MIB_INERRORS);
 		kfree_skb(skb);
 		pr_debug("ping_queue_rcv_skb -> failed\n");
 		return -1;
