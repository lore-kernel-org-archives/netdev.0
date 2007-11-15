From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/10] [TCP]: non-FACK SACK follows conservative SACK loss recovery
Date: Thu, 15 Nov 2007 15:37:27 +0200
Message-ID: <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58594 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757154AbXKONhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:37 -0500
In-Reply-To: <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many assumptions that are true when no reordering or other
strange events happen are not a part of the RFC3517. FACK
implementation is based on such assumptions. Previously (before
the rewrite) the non-FACK SACK was basically doing fast rexmit
and then it times out all skbs when first cumulative ACK arrives,
which cannot really be called SACK based recovery :-).

RFC3517 SACK disables these things:
- Per SKB timeouts & head timeout entry to recovery
- Marking at least one skb while in recovery (RFC3517 does this
  only for the fast retransmission but not for the other skbs
  when cumulative ACKs arrive in the recovery)
- Sacktag's loss detection flavors B and C (see comment before
  tcp_sacktag_write_queue)

This does not implement the "last resort" rule 3 of NextSeg, which
allows retransmissions also when not enough SACK blocks have yet
arrived above a segment for IsLost to return true [RFC3517].

The implementation differs from RFC3517 in these points:
- Rate-halving is used instead of FlightSize / 2
- Instead of using dupACKs to trigger the recovery, the number
  of SACK blocks is used as FACK does with SACK blocks+holes
  (which provides more accurate number). It seems that the
  difference can affect negatively only if the receiver does not
  generate SACK blocks at all even though it claimed to be
  SACK-capable.
- Dupthresh is not a constant one. Dynamical adjustments include
  both holes and sacked segments (equal to what FACK has) due to
  complexity involved in determining the number sacked blocks
  between highest_sack and the reordered segment. Thus it's will
  be an over-estimate.

Implementation note:

tcp_clean_rtx_queue doesn't need a lost_cnt tweak because head
skb at that point cannot be SACKED_ACKED (nor would such
situation last for long enough to cause problems).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   80 ++++++++++++++++++++++++++++++++++++++----=
-------
 1 files changed, 62 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 48c059d..c1b5339 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -863,6 +863,9 @@ void tcp_enter_cwr(struct sock *sk, const int set_s=
sthresh)
  */
 static void tcp_disable_fack(struct tcp_sock *tp)
 {
+	/* RFC3517 uses different metric in lost marker =3D> reset on change =
*/
+	if (tcp_is_fack(tp))
+		tp->lost_skb_hint =3D NULL;
 	tp->rx_opt.sack_ok &=3D ~2;
 }
=20
@@ -1470,6 +1473,13 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 				tp->sacked_out +=3D tcp_skb_pcount(skb);
=20
 				fack_count +=3D tcp_skb_pcount(skb);
+
+				/* Lost marker hint past SACKed? Tweak RFC3517 cnt */
+				if (!tcp_is_fack(tp) && (tp->lost_skb_hint !=3D NULL) &&
+				    before(TCP_SKB_CB(skb)->seq,
+					   TCP_SKB_CB(tp->lost_skb_hint)->seq))
+					tp->lost_cnt_hint +=3D tcp_skb_pcount(skb);
+
 				if (fack_count > tp->fackets_out)
 					tp->fackets_out =3D fack_count;
=20
@@ -1504,7 +1514,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 			flag &=3D ~FLAG_ONLY_ORIG_SACKED;
 	}
=20
-	if (tp->retrans_out &&
+	if (tcp_is_fack(tp) && tp->retrans_out &&
 	    after(highest_sack_end_seq, tp->lost_retrans_low) &&
 	    icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
 		flag |=3D tcp_mark_lost_retrans(sk, highest_sack_end_seq);
@@ -1858,6 +1868,26 @@ static inline int tcp_fackets_out(struct tcp_soc=
k *tp)
 	return tcp_is_reno(tp) ? tp->sacked_out+1 : tp->fackets_out;
 }
=20
+/* Heurestics to calculate number of duplicate ACKs. There's no dupACK=
s
+ * counter when SACK is enabled (without SACK, sacked_out is used for
+ * that purpose).
+ *
+ * Instead, with FACK TCP uses fackets_out that includes both SACKed
+ * segments up to the highest received SACK block so far and holes in
+ * between them.
+ *
+ * With reordering, holes may still be in flight, so RFC3517 recovery
+ * uses pure sacked_out (total number of SACKed segments) even though
+ * it violates the RFC that uses duplicate ACKs, often these are equal
+ * but when e.g. out-of-window ACKs or packet duplication occurs,
+ * they differ. Since neither occurs due to loss, TCP should really
+ * ignore them.
+ */
+static inline int tcp_dupack_heurestics(struct tcp_sock *tp)
+{
+	return tcp_is_fack(tp) ? tp->fackets_out : tp->sacked_out + 1;
+}
+
 static inline int tcp_skb_timedout(struct sock *sk, struct sk_buff *sk=
b)
 {
 	return (tcp_time_stamp - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_r=
to);
@@ -1978,13 +2008,13 @@ static int tcp_time_to_recover(struct sock *sk)
 		return 1;
=20
 	/* Not-A-Trick#2 : Classic rule... */
-	if (tcp_fackets_out(tp) > tp->reordering)
+	if (tcp_dupack_heurestics(tp) > tp->reordering)
 		return 1;
=20
 	/* Trick#3 : when we use RFC2988 timer restart, fast
 	 * retransmit can be triggered by timeout of queue head.
 	 */
-	if (tcp_head_timedout(sk))
+	if (tcp_is_fack(tp) && tcp_head_timedout(sk))
 		return 1;
=20
 	/* Trick#4: It is still not OK... But will it be useful to delay
@@ -2017,8 +2047,10 @@ static void tcp_verify_retransmit_hint(struct tc=
p_sock *tp,
 		tp->retransmit_skb_hint =3D NULL;
 }
=20
-/* Mark head of queue up as lost. */
-static void tcp_mark_head_lost(struct sock *sk, int packets)
+/* Mark head of queue up as lost. With RFC3517 SACK, the packets is
+ * is against sacked "cnt", otherwise it's against facked "cnt"
+ */
+static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_=
rexmit)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
@@ -2040,8 +2072,13 @@ static void tcp_mark_head_lost(struct sock *sk, =
int packets)
 		/* this is not the most efficient way to do this... */
 		tp->lost_skb_hint =3D skb;
 		tp->lost_cnt_hint =3D cnt;
-		cnt +=3D tcp_skb_pcount(skb);
-		if (cnt > packets || after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
+
+		if (tcp_is_fack(tp) ||
+		    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+			cnt +=3D tcp_skb_pcount(skb);
+
+		if (((!fast_rexmit || (tp->lost_out > 0)) && (cnt > packets)) ||
+		     after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
 			break;
 		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
@@ -2054,17 +2091,22 @@ static void tcp_mark_head_lost(struct sock *sk,=
 int packets)
=20
 /* Account newly detected lost packet(s) */
=20
-static void tcp_update_scoreboard(struct sock *sk)
+static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	if (tcp_is_fack(tp)) {
+	if (tcp_is_reno(tp)) {
+		tcp_mark_head_lost(sk, 1, fast_rexmit);
+	} else if (tcp_is_fack(tp)) {
 		int lost =3D tp->fackets_out - tp->reordering;
 		if (lost <=3D 0)
 			lost =3D 1;
-		tcp_mark_head_lost(sk, lost);
+		tcp_mark_head_lost(sk, lost, fast_rexmit);
 	} else {
-		tcp_mark_head_lost(sk, 1);
+		int sacked_upto =3D tp->sacked_out - tp->reordering;
+		if (sacked_upto < 0)
+			sacked_upto =3D 0;
+		tcp_mark_head_lost(sk, sacked_upto, fast_rexmit);
 	}
=20
 	/* New heuristics: it is possible only after we switched
@@ -2072,7 +2114,7 @@ static void tcp_update_scoreboard(struct sock *sk=
)
 	 * Hence, we can detect timed out packets during fast
 	 * retransmit without falling to slow start.
 	 */
-	if (!tcp_is_reno(tp) && tcp_head_timedout(sk)) {
+	if (tcp_is_fack(tp) && tcp_head_timedout(sk)) {
 		struct sk_buff *skb;
=20
 		skb =3D tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
@@ -2245,7 +2287,7 @@ static int tcp_try_undo_partial(struct sock *sk, =
int acked)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	/* Partial ACK arrived. Force Hoe's retransmit. */
-	int failed =3D tcp_is_reno(tp) || tp->fackets_out>tp->reordering;
+	int failed =3D tcp_is_reno(tp) || (tcp_fackets_out(tp) > tp->reorderi=
ng);
=20
 	if (tcp_may_undo(tp)) {
 		/* Plain luck! Hole if filled with delayed
@@ -2379,7 +2421,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_a=
cked, int flag)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	int is_dupack =3D !(flag&(FLAG_SND_UNA_ADVANCED|FLAG_NOT_DUP));
 	int do_lost =3D is_dupack || ((flag&FLAG_DATA_SACKED) &&
-				    (tp->fackets_out > tp->reordering));
+				    (tcp_fackets_out(tp) > tp->reordering));
+	int fast_rexmit =3D 0;
=20
 	/* Some technical things:
 	 * 1. Reno does not count dupacks (sacked_out) automatically. */
@@ -2399,11 +2442,11 @@ tcp_fastretrans_alert(struct sock *sk, int pkts=
_acked, int flag)
 		return;
=20
 	/* C. Process data loss notification, provided it is valid. */
-	if ((flag&FLAG_DATA_LOST) &&
+	if (tcp_is_fack(tp) && (flag & FLAG_DATA_LOST) &&
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering);
+		tcp_mark_head_lost(sk, tp->fackets_out-tp->reordering, 0);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
=20
@@ -2522,10 +2565,11 @@ tcp_fastretrans_alert(struct sock *sk, int pkts=
_acked, int flag)
 		tp->bytes_acked =3D 0;
 		tp->snd_cwnd_cnt =3D 0;
 		tcp_set_ca_state(sk, TCP_CA_Recovery);
+		fast_rexmit =3D 1;
 	}
=20
-	if (do_lost || tcp_head_timedout(sk))
-		tcp_update_scoreboard(sk);
+	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
+		tcp_update_scoreboard(sk, fast_rexmit);
 	tcp_cwnd_down(sk, flag);
 	tcp_xmit_retransmit_queue(sk);
 }
--=20
1.5.0.6

