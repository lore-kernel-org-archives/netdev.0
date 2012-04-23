From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for TCP
Date: Mon, 23 Apr 2012 11:38:54 +0200
Message-ID: <1335173934.3293.84.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Rick Jones <rick.jones2@hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61749 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894Ab2DWJjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 05:39:00 -0400
Received: by bkcik5 with SMTP id ik5so8416676bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 02:38:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

While investigating TCP performance problems on 10Gb+ links, we found a
tcp sender was dropping lot of incoming ACKS because of sk_rcvbuf limit
in sk_add_backlog(), especially if receiver doesnt use GRO/LRO and send=
s
one ACK every two MSS segments.

A sender usually tweaks sk_sndbuf, but sk_rcvbuf stays at its default
value (87380), allowing a too small backlog.

A TCP ACK, even being small, can consume nearly same truesize space tha=
n
outgoing packets. Using sk_rcvbuf + sk_sndbuf as a limit makes sense an=
d
is fast to compute.

Performance results on netperf, single flow, receiver with disabled
GRO/LRO : 7500 Mbits instead of 6050 Mbits, no more TCPBacklogDrop
increments at sender.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Rick Jones <rick.jones2@hp.com>
---
 net/ipv4/tcp_ipv4.c |    3 ++-
 net/ipv6/tcp_ipv6.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 917607e..cf97e98 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1752,7 +1752,8 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret =3D tcp_v4_do_rcv(sk, skb);
 		}
-	} else if (unlikely(sk_add_backlog(sk, skb, sk->sk_rcvbuf))) {
+	} else if (unlikely(sk_add_backlog(sk, skb,
+					   sk->sk_rcvbuf + sk->sk_sndbuf))) {
 		bh_unlock_sock(sk);
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b04e6d8..5fb19d3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1654,7 +1654,8 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret =3D tcp_v6_do_rcv(sk, skb);
 		}
-	} else if (unlikely(sk_add_backlog(sk, skb, sk->sk_rcvbuf))) {
+	} else if (unlikely(sk_add_backlog(sk, skb,
+					   sk->sk_rcvbuf + sk->sk_sndbuf))) {
 		bh_unlock_sock(sk);
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
