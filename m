From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 03/15] tcp: add helper for lost bit toggling
Date: Sat, 20 Sep 2008 20:52:21 +0300
Message-ID: <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39329 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbYITRwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:36 -0400
In-Reply-To: <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    1 +
 net/ipv4/tcp_input.c  |   36 +++++++++++++++++++-----------------
 net/ipv4/tcp_output.c |    3 +--
 3 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b716763..38551bb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -472,6 +472,7 @@ extern void tcp_send_delayed_ack(struct sock *sk);
=20
 /* tcp_input.c */
 extern void tcp_cwnd_application_limited(struct sock *sk);
+extern void tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *skb=
);
=20
 /* tcp_timer.c */
 extern void tcp_init_xmit_timers(struct sock *);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9e95ad6..f46c7fe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -992,6 +992,18 @@ static void tcp_verify_retransmit_hint(struct tcp_=
sock *tp, struct sk_buff *skb)
 		tp->retransmit_skb_hint =3D NULL;
 }
=20
+static void __tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *s=
kb)
+{
+	tp->lost_out +=3D tcp_skb_pcount(skb);
+	TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
+}
+
+void tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *skb)
+{
+	__tcp_skb_mark_lost(tp, skb);
+	tcp_verify_retransmit_hint(tp, skb);
+}
+
 /* This procedure tags the retransmission queue when SACKs arrive.
  *
  * We have three tag bits: SACKED(S), RETRANS(R) and LOST(L).
@@ -1168,13 +1180,9 @@ static void tcp_mark_lost_retrans(struct sock *s=
k)
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 			tp->retrans_out -=3D tcp_skb_pcount(skb);
=20
-			/* clear lost hint */
-			tp->retransmit_skb_hint =3D NULL;
-
-			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
-				tp->lost_out +=3D tcp_skb_pcount(skb);
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-			}
+			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED)))
+				__tcp_skb_mark_lost(tp, skb);
+			tcp_verify_retransmit_hint(tp, skb);
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
 		} else {
 			if (before(ack_seq, new_low_seq))
@@ -2216,11 +2224,8 @@ static void tcp_mark_head_lost(struct sock *sk, =
int packets)
 			cnt =3D packets;
 		}
=20
-		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
-			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-			tp->lost_out +=3D tcp_skb_pcount(skb);
-			tcp_verify_retransmit_hint(tp, skb);
-		}
+		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST)))
+			tcp_skb_mark_lost(tp, skb);
 	}
 	tcp_verify_left_out(tp);
 }
@@ -2262,11 +2267,8 @@ static void tcp_update_scoreboard(struct sock *s=
k, int fast_rexmit)
 			if (!tcp_skb_timedout(sk, skb))
 				break;
=20
-			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-				tp->lost_out +=3D tcp_skb_pcount(skb);
-				tcp_verify_retransmit_hint(tp, skb);
-			}
+			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST)))
+				tcp_skb_mark_lost(tp, skb);
 		}
=20
 		tp->scoreboard_skb_hint =3D skb;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2242c2c..1b8d980 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1848,8 +1848,7 @@ void tcp_simple_retransmit(struct sock *sk)
 				tp->retrans_out -=3D tcp_skb_pcount(skb);
 			}
 			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST)) {
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-				tp->lost_out +=3D tcp_skb_pcount(skb);
+				tcp_skb_mark_lost(tp, skb);
 				lost =3D 1;
 			}
 		}
--=20
1.5.2.2

