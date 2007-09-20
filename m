From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/9] [TCP]: Make fackets_out accurate
Date: Thu, 20 Sep 2007 15:17:45 +0300
Message-ID: <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51979 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbXITMRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:54 -0400
In-Reply-To: <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Substraction for fackets_out is unconditional when snd_una
advances, thus there's no need to do it inside the loop. Just
make sure correct bounds are honored.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c  |   10 +++-------
 net/ipv4/tcp_output.c |   44 ++++++++++++++++++++++++++---------------=
---
 2 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fd0ae4d..09b6b1d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2302,8 +2302,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_a=
cked, int flag)
 	 * 1. Reno does not count dupacks (sacked_out) automatically. */
 	if (!tp->packets_out)
 		tp->sacked_out =3D 0;
-	/* 2. SACK counts snd_fack in packets inaccurately. */
-	if (tp->sacked_out =3D=3D 0)
+
+	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
 		tp->fackets_out =3D 0;
=20
 	/* Now state machine starts.
@@ -2571,10 +2571,6 @@ static int tcp_tso_acked(struct sock *sk, struct=
 sk_buff *skb,
 		} else if (*seq_rtt < 0)
 			*seq_rtt =3D now - scb->when;
=20
-		if (tp->fackets_out) {
-			__u32 dval =3D min(tp->fackets_out, packets_acked);
-			tp->fackets_out -=3D dval;
-		}
 		tp->packets_out -=3D packets_acked;
=20
 		BUG_ON(tcp_skb_pcount(skb) =3D=3D 0);
@@ -2657,7 +2653,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 			seq_rtt =3D now - scb->when;
 			last_ackt =3D skb->tstamp;
 		}
-		tcp_dec_pcount_approx(&tp->fackets_out, skb);
 		tp->packets_out -=3D tcp_skb_pcount(skb);
 		tcp_unlink_write_queue(skb, sk);
 		sk_stream_free_skb(sk, skb);
@@ -2672,6 +2667,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
 		tcp_rearm_rto(sk);
=20
+		tp->fackets_out -=3D min(pkts_acked, tp->fackets_out);
 		if (tcp_is_reno(tp))
 			tcp_remove_reno_sacks(sk, pkts_acked);
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9df5b2a..cbe8bf6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -652,6 +652,26 @@ static void tcp_set_skb_tso_segs(struct sock *sk, =
struct sk_buff *skb, unsigned
 	}
 }
=20
+/* When a modification to fackets out becomes necessary, we need to ch=
eck
+ * skb is counted to fackets_out or not. Another important thing is to
+ * tweak SACK fastpath hint too as it would overwrite all changes unle=
ss
+ * hint is also changed.
+ */
+static void tcp_adjust_fackets_out(struct tcp_sock *tp, struct sk_buff=
 *skb,
+				   int decr)
+{
+	if (!tp->sacked_out)
+		return;
+
+	if (!before(tp->highest_sack, TCP_SKB_CB(skb)->seq))
+		tp->fackets_out -=3D decr;
+
+	/* cnt_hint is "off-by-one" compared with fackets_out (see sacktag) *=
/
+	if (tp->fastpath_skb_hint !=3D NULL &&
+	    after(TCP_SKB_CB(tp->fastpath_skb_hint)->seq, TCP_SKB_CB(skb)->se=
q))
+		tp->fastpath_cnt_hint -=3D decr;
+}
+
 /* Function to create two new TCP segments.  Shrinks the given segment
  * to the specified size and appends a new segment with the rest of th=
e
  * packet to the list.  This won't be called frequently, I hope.
@@ -746,21 +766,12 @@ int tcp_fragment(struct sock *sk, struct sk_buff =
*skb, u32 len, unsigned int mss
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
 			tp->lost_out -=3D diff;
=20
-		if (diff > 0) {
-			/* Adjust Reno SACK estimate. */
-			if (tcp_is_reno(tp)) {
-				tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
-				tcp_verify_left_out(tp);
-			}
-
-			tcp_dec_pcount_approx_int(&tp->fackets_out, diff);
-			/* SACK fastpath might overwrite it unless dealt with */
-			if (tp->fastpath_skb_hint !=3D NULL &&
-			    after(TCP_SKB_CB(tp->fastpath_skb_hint)->seq,
-				  TCP_SKB_CB(skb)->seq)) {
-				tcp_dec_pcount_approx_int(&tp->fastpath_cnt_hint, diff);
-			}
+		/* Adjust Reno SACK estimate. */
+		if (tcp_is_reno(tp) && diff > 0) {
+			tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
+			tcp_verify_left_out(tp);
 		}
+		tcp_adjust_fackets_out(tp, skb, diff);
 	}
=20
 	/* Link BUFF into the send queue. */
@@ -1746,10 +1757,7 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb, int m
 		if (tcp_is_reno(tp) && tp->sacked_out)
 			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
=20
-		/* Not quite right: it can be > snd.fack, but
-		 * it is better to underestimate fackets.
-		 */
-		tcp_dec_pcount_approx(&tp->fackets_out, next_skb);
+		tcp_adjust_fackets_out(tp, skb, tcp_skb_pcount(next_skb));
 		tp->packets_out -=3D tcp_skb_pcount(next_skb);
 		sk_stream_free_skb(sk, next_skb);
 	}
--=20
1.5.0.6

