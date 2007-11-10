From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/4] [TCP]: Fix reord detection due to snd_una covered holes
Date: Sat, 10 Nov 2007 12:56:00 +0200
Message-ID: <11946921621074-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11946921623177-git-send-email-ilpo.jarvinen@helsinki.fi> <11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36209 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbXKJK4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 05:56:06 -0500
In-Reply-To: <11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ixes subtle bug like the one with fastpath_cnt_hint happening
due to the way the GSO and hints interact. Because hints are not
reset when just a GSOed skb is partially ACKed, there's no
guarantee that the relevant part of the write queue is going to
be processed in sacktag at all (skbs below snd_una) because
fastpath hint can fast forward the entrypoint.

This was also on the way of future reductions in sacktag's skb
processing. Also future cleanups in sacktag can be made after
this (in 2.6.25).

This may make reordering update in tcp_try_undo_partial
redundant but I'm not too sure so I left it there.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   50 ++++++++++++++++++++++++++++++++----------=
--------
 1 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0f75757..9fc9096 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1417,11 +1417,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 					if ((dup_sack && in_sack) &&
 					    (sacked&TCPCB_SACKED_ACKED))
 						reord =3D min(fack_count, reord);
-				} else {
-					/* If it was in a hole, we detected reordering. */
-					if (fack_count < prior_fackets &&
-					    !(sacked&TCPCB_SACKED_ACKED))
-						reord =3D min(fack_count, reord);
 				}
=20
 				/* Nothing to do; acked frame is about to be dropped. */
@@ -2634,7 +2629,8 @@ static u32 tcp_tso_acked(struct sock *sk, struct =
sk_buff *skb)
  * is before the ack sequence we can discard it as it's confirmed to h=
ave
  * arrived at the other end.
  */
-static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
+static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
+			       int prior_fackets)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -2643,6 +2639,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p)
 	int fully_acked =3D 1;
 	int flag =3D 0;
 	int prior_packets =3D tp->packets_out;
+	u32 cnt =3D 0;
+	u32 reord =3D tp->packets_out;
 	s32 seq_rtt =3D -1;
 	ktime_t last_ackt =3D net_invalid_timestamp();
=20
@@ -2683,10 +2681,14 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 s32 *seq_rtt_p)
 				if ((flag & FLAG_DATA_ACKED) ||
 				    (packets_acked > 1))
 					flag |=3D FLAG_NONHEAD_RETRANS_ACKED;
-			} else if (seq_rtt < 0) {
-				seq_rtt =3D now - scb->when;
-				if (fully_acked)
-					last_ackt =3D skb->tstamp;
+			} else {
+				if (seq_rtt < 0) {
+					seq_rtt =3D now - scb->when;
+					if (fully_acked)
+						last_ackt =3D skb->tstamp;
+				}
+				if (!(sacked & TCPCB_SACKED_ACKED))
+					reord =3D min(cnt, reord);
 			}
=20
 			if (sacked & TCPCB_SACKED_ACKED)
@@ -2697,12 +2699,16 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 s32 *seq_rtt_p)
 			if ((sacked & TCPCB_URG) && tp->urg_mode &&
 			    !before(end_seq, tp->snd_up))
 				tp->urg_mode =3D 0;
-		} else if (seq_rtt < 0) {
-			seq_rtt =3D now - scb->when;
-			if (fully_acked)
-				last_ackt =3D skb->tstamp;
+		} else {
+			if (seq_rtt < 0) {
+				seq_rtt =3D now - scb->when;
+				if (fully_acked)
+					last_ackt =3D skb->tstamp;
+			}
+			reord =3D min(cnt, reord);
 		}
 		tp->packets_out -=3D packets_acked;
+		cnt +=3D packets_acked;
=20
 		/* Initial outgoing SYN's get put onto the write_queue
 		 * just like anything else we transmit.  It is not
@@ -2734,13 +2740,18 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 s32 *seq_rtt_p)
 		tcp_ack_update_rtt(sk, flag, seq_rtt);
 		tcp_rearm_rto(sk);
=20
+		if (tcp_is_reno(tp)) {
+			tcp_remove_reno_sacks(sk, pkts_acked);
+		} else {
+			/* Non-retransmitted hole got filled? That's reordering */
+			if (reord < prior_fackets)
+				tcp_update_reordering(sk, tp->fackets_out - reord, 0);
+		}
+
 		tp->fackets_out -=3D min(pkts_acked, tp->fackets_out);
 		/* hint's skb might be NULL but we don't need to care */
 		tp->fastpath_cnt_hint -=3D min_t(u32, pkts_acked,
 					       tp->fastpath_cnt_hint);
-		if (tcp_is_reno(tp))
-			tcp_remove_reno_sacks(sk, pkts_acked);
-
 		if (ca_ops->pkts_acked) {
 			s32 rtt_us =3D -1;
=20
@@ -3023,6 +3034,7 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 	u32 ack_seq =3D TCP_SKB_CB(skb)->seq;
 	u32 ack =3D TCP_SKB_CB(skb)->ack_seq;
 	u32 prior_in_flight;
+	u32 prior_fackets;
 	s32 seq_rtt;
 	int prior_packets;
 	int frto_cwnd =3D 0;
@@ -3047,6 +3059,8 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 			tp->bytes_acked +=3D min(ack - prior_snd_una, tp->mss_cache);
 	}
=20
+	prior_fackets =3D tp->fackets_out;
+
 	if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
 		 * No more checks are required.
@@ -3088,7 +3102,7 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 	prior_in_flight =3D tcp_packets_in_flight(tp);
=20
 	/* See if we can take anything off of the retransmit queue. */
-	flag |=3D tcp_clean_rtx_queue(sk, &seq_rtt);
+	flag |=3D tcp_clean_rtx_queue(sk, &seq_rtt, prior_fackets);
=20
 	/* Guarantee sacktag reordering detection against wrap-arounds */
 	if (before(tp->frto_highmark, tp->snd_una))
--=20
1.5.0.6

