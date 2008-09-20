From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 04/15] tcp: convert retransmit_cnt_hint to seqno
Date: Sat, 20 Sep 2008 20:52:22 +0300
Message-ID: <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59235 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbYITRwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:38 -0400
In-Reply-To: <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
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

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    2 +-
 include/net/tcp.h     |    3 +++
 net/ipv4/tcp_input.c  |   12 +++++++++---
 net/ipv4/tcp_output.c |   16 +++++-----------
 4 files changed, 18 insertions(+), 15 deletions(-)

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
index 38551bb..9be41c9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1044,6 +1044,9 @@ static inline void tcp_clear_all_retrans_hints(st=
ruct tcp_sock *tp)
 	tp->forward_skb_hint =3D NULL;
 }
=20
+extern void tcp_verify_retransmit_hint(struct tcp_sock *tp,
+				       struct sk_buff *skb);
+
 /* MD5 Signature */
 struct crypto_hash;
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f46c7fe..84935cf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -984,12 +984,16 @@ static void tcp_update_reordering(struct sock *sk=
, const int metric,
  * retransmitted past LOST markings in the first place? I'm not fully =
sure
  * about undo and end of connection cases, which can cause R without L=
?
  */
-static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_=
buff *skb)
+void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_buff *s=
kb)
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
 static void __tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *s=
kb)
@@ -1888,6 +1892,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
+			tp->retransmit_high =3D TCP_SKB_CB(skb)->end_seq;
 		}
 	}
 	tcp_verify_left_out(tp);
@@ -1972,6 +1977,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
+			tp->retransmit_high =3D TCP_SKB_CB(skb)->end_seq;
 		}
 	}
 	tcp_verify_left_out(tp);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1b8d980..fbe10f4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1851,6 +1851,7 @@ void tcp_simple_retransmit(struct sock *sk)
 				tcp_skb_mark_lost(tp, skb);
 				lost =3D 1;
 			}
+			tcp_verify_retransmit_hint(tp, skb);
 		}
 	}
=20
@@ -2006,15 +2007,11 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
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
@@ -2025,7 +2022,6 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 				break;
 			/* we could do better than to assign each time */
 			tp->retransmit_skb_hint =3D skb;
-			tp->retransmit_cnt_hint =3D packet_cnt;
=20
 			/* Assume this retransmit will generate
 			 * only one packet for congestion window
@@ -2036,6 +2032,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			 */
 			if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
 				return;
+			if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high))
+				break;
=20
 			if (sacked & TCPCB_LOST) {
 				if (!(sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
@@ -2056,10 +2054,6 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
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

