From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 04/15] tcp: convert retransmit_cnt_hint to seqno
Date: Sun, 21 Sep 2008 00:47:47 +0300
Message-ID: <1221947278-16715-5-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36807 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbYITVsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:02 -0400
In-Reply-To: <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Main benefit in this is that we can then freely point
the retransmit_skb_hint to anywhere we want to because
there's no longer need to know what would be the count
changes involve, and since this is really used only as a
terminator, unnecessary work is one time walk at most,
and if some retransmissions are necessary after that
point later on, the walk is not full waste of time
anyway.

Since retransmit_high must be kept valid, all lost
markers must ensure that.

Now I also have learned how those "holes" in the
rexmittable skbs can appear, mtu probe does them. So
I removed the misleading comment as well.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    2 +-
 include/net/tcp.h     |    2 ++
 net/ipv4/tcp_input.c  |   34 ++++++++++++++++++++--------------
 net/ipv4/tcp_output.c |   25 +++++++------------------
 4 files changed, 30 insertions(+), 33 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 2e25573..d7637c4 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -358,7 +358,7 @@ struct tcp_sock {
 					 */
=20
 	int     lost_cnt_hint;
-	int     retransmit_cnt_hint;
+	u32     retransmit_high;	/* L-bits may be on up to this seqno */
=20
 	u32	lost_retrans_low;	/* Sent seq after any rxmit (lowest) */
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b716763..d0e90c5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -472,6 +472,8 @@ extern void tcp_send_delayed_ack(struct sock *sk);
=20
 /* tcp_input.c */
 extern void tcp_cwnd_application_limited(struct sock *sk);
+extern void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
+					    struct sk_buff *skb);
=20
 /* tcp_timer.c */
 extern void tcp_init_xmit_timers(struct sock *);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1251233..d271cc8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -979,17 +979,17 @@ static void tcp_update_reordering(struct sock *sk=
, const int metric,
 	}
 }
=20
-/* RFC: This is from the original, I doubt that this is necessary at a=
ll:
- * clear xmit_retrans hint if seq of this skb is beyond hint. How coul=
d we
- * retransmitted past LOST markings in the first place? I'm not fully =
sure
- * about undo and end of connection cases, which can cause R without L=
?
- */
+/* This must be called before lost_out is incremented */
 static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_=
buff *skb)
 {
-	if ((tp->retransmit_skb_hint !=3D NULL) &&
+	if ((tp->retransmit_skb_hint =3D=3D NULL) ||
 	    before(TCP_SKB_CB(skb)->seq,
 		   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
-		tp->retransmit_skb_hint =3D NULL;
+		tp->retransmit_skb_hint =3D skb;
+
+	if (!tp->lost_out ||
+	    after(TCP_SKB_CB(skb)->end_seq, tp->retransmit_high))
+		tp->retransmit_high =3D TCP_SKB_CB(skb)->end_seq;
 }
=20
 static void tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *skb=
)
@@ -1002,6 +1002,16 @@ static void tcp_skb_mark_lost(struct tcp_sock *t=
p, struct sk_buff *skb)
 	}
 }
=20
+void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_bu=
ff *skb)
+{
+	tcp_verify_retransmit_hint(tp, skb);
+
+	if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
+		tp->lost_out +=3D tcp_skb_pcount(skb);
+		TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
+	}
+}
+
 /* This procedure tags the retransmission queue when SACKs arrive.
  *
  * We have three tag bits: SACKED(S), RETRANS(R) and LOST(L).
@@ -1178,13 +1188,7 @@ static void tcp_mark_lost_retrans(struct sock *s=
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
+			tcp_skb_mark_lost_uncond_verify(tp, skb);
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
 		} else {
 			if (before(ack_seq, new_low_seq))
@@ -1890,6 +1894,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
+			tp->retransmit_high =3D TCP_SKB_CB(skb)->end_seq;
 		}
 	}
 	tcp_verify_left_out(tp);
@@ -1974,6 +1979,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
+			tp->retransmit_high =3D TCP_SKB_CB(skb)->end_seq;
 		}
 	}
 	tcp_verify_left_out(tp);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2242c2c..bb30e68 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1836,7 +1836,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
 	unsigned int mss =3D tcp_current_mss(sk, 0);
-	int lost =3D 0;
+	u32 prior_lost =3D tp->lost_out;
=20
 	tcp_for_write_queue(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
@@ -1847,17 +1847,13 @@ void tcp_simple_retransmit(struct sock *sk)
 				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 				tp->retrans_out -=3D tcp_skb_pcount(skb);
 			}
-			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST)) {
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-				tp->lost_out +=3D tcp_skb_pcount(skb);
-				lost =3D 1;
-			}
+			tcp_skb_mark_lost_uncond_verify(tp, skb);
 		}
 	}
=20
 	tcp_clear_all_retrans_hints(tp);
=20
-	if (!lost)
+	if (prior_lost =3D=3D tp->lost_out)
 		return;
=20
 	if (tcp_is_reno(tp))
@@ -2007,15 +2003,11 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
-	int packet_cnt;
=20
-	if (tp->retransmit_skb_hint) {
+	if (tp->retransmit_skb_hint)
 		skb =3D tp->retransmit_skb_hint;
-		packet_cnt =3D tp->retransmit_cnt_hint;
-	} else {
+	else
 		skb =3D tcp_write_queue_head(sk);
-		packet_cnt =3D 0;
-	}
=20
 	/* First pass: retransmit lost packets. */
 	if (tp->lost_out) {
@@ -2026,7 +2018,6 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 				break;
 			/* we could do better than to assign each time */
 			tp->retransmit_skb_hint =3D skb;
-			tp->retransmit_cnt_hint =3D packet_cnt;
=20
 			/* Assume this retransmit will generate
 			 * only one packet for congestion window
@@ -2037,6 +2028,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			 */
 			if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
 				return;
+			if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high))
+				break;
=20
 			if (sacked & TCPCB_LOST) {
 				if (!(sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
@@ -2057,10 +2050,6 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 									  inet_csk(sk)->icsk_rto,
 									  TCP_RTO_MAX);
 				}
-
-				packet_cnt +=3D tcp_skb_pcount(skb);
-				if (packet_cnt >=3D tp->lost_out)
-					break;
 			}
 		}
 	}
--=20
1.5.2.2

