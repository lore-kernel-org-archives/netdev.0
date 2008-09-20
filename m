From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 13/15] tcp: don't clear retransmit_skb_hint when not necessary
Date: Sun, 21 Sep 2008 00:47:56 +0300
Message-ID: <1221947278-16715-14-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-10-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-11-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-12-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-13-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45382 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbYITVsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:07 -0400
In-Reply-To: <1221947278-16715-13-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most importantly avoid doing it with cumulative ACK. Not clearing
means that we no longer need n^2 processing in resolution of each
fast recovery.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    7 ++++++-
 net/ipv4/tcp_input.c  |    4 +++-
 net/ipv4/tcp_output.c |    8 +++++---
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 220f54c..ea81572 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1037,10 +1037,15 @@ static inline void tcp_mib_init(struct net *net=
)
 }
=20
 /* from STCP */
-static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
+static inline void tcp_clear_retrans_hints_partial(struct tcp_sock *tp=
)
 {
 	tp->lost_skb_hint =3D NULL;
 	tp->scoreboard_skb_hint =3D NULL;
+}
+
+static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
+{
+	tcp_clear_retrans_hints_partial(tp);
 	tp->retransmit_skb_hint =3D NULL;
 }
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d017aed..44a4fff 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2925,7 +2925,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, i=
nt prior_fackets)
=20
 		tcp_unlink_write_queue(skb, sk);
 		sk_wmem_free_skb(sk, skb);
-		tcp_clear_all_retrans_hints(tp);
+		tcp_clear_retrans_hints_partial(tp);
+		if (skb =3D=3D tp->retransmit_skb_hint)
+			tp->retransmit_skb_hint =3D NULL;
 	}
=20
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 97873cc..63b9ce1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -748,7 +748,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len,
=20
 	BUG_ON(len > skb->len);
=20
-	tcp_clear_all_retrans_hints(tp);
+	tcp_clear_retrans_hints_partial(tp);
 	nsize =3D skb_headlen(skb) - len;
 	if (nsize < 0)
 		nsize =3D 0;
@@ -1821,7 +1821,9 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb,
 	tp->packets_out -=3D tcp_skb_pcount(next_skb);
=20
 	/* changed transmit queue under us so clear hints */
-	tcp_clear_all_retrans_hints(tp);
+	tcp_clear_retrans_hints_partial(tp);
+	if (next_skb =3D=3D tp->retransmit_skb_hint)
+		tp->retransmit_skb_hint =3D skb;
=20
 	sk_wmem_free_skb(sk, next_skb);
 }
@@ -1851,7 +1853,7 @@ void tcp_simple_retransmit(struct sock *sk)
 		}
 	}
=20
-	tcp_clear_all_retrans_hints(tp);
+	tcp_clear_retrans_hints_partial(tp);
=20
 	if (prior_lost =3D=3D tp->lost_out)
 		return;
--=20
1.5.2.2

