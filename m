From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 07 Sep 2010 13:39:12 +0200
Message-ID: <1283859552.2338.402.camel@edumazet-laptop>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
	 <20100906.221644.123986391.davem@davemloft.net>
	 <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
	 <20100906.223010.173858342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leandroal@gmail.com, netdev@vger.kernel.org,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56458 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996Ab0IGLjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 07:39:17 -0400
Received: by fxm13 with SMTP id 13so2894569fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 04:39:16 -0700 (PDT)
In-Reply-To: <20100906.223010.173858342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 septembre 2010 =C3=A0 22:30 -0700, David Miller a =C3=A9cri=
t :


> The small 78 byte window is why the sending system is splitting up th=
e
> writes into smaller pieces.
>=20
> I presume that the system advertises exactly a 78 byte window because
> this is how large the commands are.  But this is an extremely foolish
> and baroque thing to do, and it's why you are having problems.

I am not sure why TSO added a "Bound mss with half of window"
requirement for tcp_sync_mss()

I tried with MSS=3D1000 and WIN=3D1000, and segment size chosen is 500

With WIN=3D78, 78/2->39 is then capped to 48 (68U - tp->tcp_header_len)

Is there a hard requirement about segment size being at most half the
window ?

=46ollowing patch solves the problem for me :

[PATCH] tcp: bound mss to window in tcp_sync_mss()

Leandro Melo de Sales noticed that if a peer announces a very small
initial tcp window (78 in his case), first sent frames have unnecessary
small lengths (48 in his case)

CLNT->SRV    [SYN] Seq=3D0 Win=3D5840 Len=3D0 MSS=3D1460
SRV->CLNT    [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D78 Len=3D0 MSS=3D78
CLNT->SRV    [ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D0
CLNT->SRV    [PSH, ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D48
CLNT->SRV    [PSH, ACK] Seq=3D49 Ack=3D1 Win=3D5840 Len=3D30
SRV->CLNT    [ACK] Seq=3D1 Ack=3D49 Win=3D78 Len=3D0
SRV->CLNT    [RST, ACK] Seq=3D1 Ack=3D79 Win=3D78 Len=3D0

tcp_sync_mss() bounds mss to half the window, while it could use full
window:

CLNT->SRV    [SYN] Seq=3D0 Win=3D5840 Len=3D0 MSS=3D1460
SRV->CLNT    [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D78 Len=3D0 MSS=3D78
CLNT->SRV    [ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D0
CLNT->SRV    [PSH, ACK] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D78
SRV->CLNT    [ACK] Seq=3D1 Ack=3D79 Win=3D78 Len=3D0

Reported-by: =E3=83=84 Leandro Melo de Sales <leandroal@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    9 +++++++++
 net/ipv4/tcp_output.c |    2 +-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index eaa9582..c262676 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -481,6 +481,15 @@ static inline int tcp_bound_to_half_wnd(struct tcp=
_sock *tp, int pktsize)
 		return pktsize;
 }
=20
+/* Bound MSS / TSO packet size with the window */
+static inline int tcp_bound_to_wnd(struct tcp_sock *tp, int pktsize)
+{
+	if (tp->max_window && pktsize > tp->max_window)
+		return max(tp->max_window, 68U - tp->tcp_header_len);
+	else
+		return pktsize;
+}
+
 /* tcp.c */
 extern void tcp_get_info(struct sock *, struct tcp_info *);
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index de3bd84..49cdbe4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1224,7 +1224,7 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pm=
tu)
 		icsk->icsk_mtup.search_high =3D pmtu;
=20
 	mss_now =3D tcp_mtu_to_mss(sk, pmtu);
-	mss_now =3D tcp_bound_to_half_wnd(tp, mss_now);
+	mss_now =3D tcp_bound_to_wnd(tp, mss_now);
=20
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie =3D pmtu;


