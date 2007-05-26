From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 8/9] [TCP]: Reduce sacked_out with reno when purging write_queue
Date: Sat, 26 May 2007 11:36:01 +0300
Message-ID: <1180168562524-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi> <1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35531 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbXEZIgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:09 -0400
In-Reply-To: <11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Previously TCP had a transitional state during which reno
counted segments that are already below the current window into
sacked_out, which is now prevented. Re-try now unconditional
S+L catching (I wonder if we could get that BUG_ON place
pinpointed more exactly in oops because now inlining makes it
lose its original context as they always seem to be in
tcp_ack, #define helps?).

Beware, this change is not a trivial one and might have some
unexpected side-effects under obscure conditions since state
tracking is to happen much later on and the reno sack counting
was highly depending on the current state.

This approach conservatively calls just remove_sack and leaves
reset_sack() calls alone. The best solution to the whole problem
would be to first calculate the new sacked_out fully (this patch
does not move reno_sack_reset calls from original sites and thus
does not implement this). However, that would require very
invasive change to fastretrans_alert (perhaps even slicing it to
two halves). Alternatively, all callers of tcp_packets_in_flight
(i.e., users that depend on sacked_out) should be postponed
until the new sacked_out has been calculated but it isn't any
simpler alternative.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h    |    3 +--
 net/ipv4/tcp_input.c |   19 +++++++++++--------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6f88d13..5255d51 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -747,8 +747,7 @@ static inline __u32 tcp_current_ssthresh(const stru=
ct sock *sk)
=20
 static inline void tcp_sync_left_out(struct tcp_sock *tp)
 {
-	BUG_ON(tp->rx_opt.sack_ok &&
-	       (tp->sacked_out + tp->lost_out > tp->packets_out));
+	BUG_ON(tp->sacked_out + tp->lost_out > tp->packets_out);
 }
=20
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8c1e38a..9c12c90 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2295,7 +2295,7 @@ static void tcp_mtup_probe_success(struct sock *s=
k, struct sk_buff *skb)
  */
 static void
 tcp_fastretrans_alert(struct sock *sk, u32 prior_snd_una,
-		      int prior_packets, int flag, u32 mark_lost_entry_seq)
+		      int pkts_acked, int flag, u32 mark_lost_entry_seq)
 {
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -2380,12 +2380,8 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior=
_snd_una,
 		if (prior_snd_una =3D=3D tp->snd_una) {
 			if (IsReno(tp) && is_dupack)
 				tcp_add_reno_sack(sk);
-		} else {
-			int acked =3D prior_packets - tp->packets_out;
-			if (IsReno(tp))
-				tcp_remove_reno_sacks(sk, acked);
-			is_dupack =3D tcp_try_undo_partial(sk, acked);
-		}
+		} else
+			is_dupack =3D tcp_try_undo_partial(sk, pkts_acked);
 		break;
 	case TCP_CA_Loss:
 		if (flag&FLAG_DATA_ACKED)
@@ -2602,6 +2598,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 	struct sk_buff *skb;
 	__u32 now =3D tcp_time_stamp;
 	int acked =3D 0;
+	int prior_packets =3D tp->packets_out;
 	__s32 seq_rtt =3D -1;
 	u32 pkts_acked =3D 0;
 	ktime_t last_ackt =3D ktime_set(0,0);
@@ -2682,6 +2679,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
__s32 *seq_rtt_p)
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
 		tcp_ack_packets_out(sk);
=20
+		if (IsReno(tp)) {
+			int acked =3D prior_packets - tp->packets_out;
+			tcp_remove_reno_sacks(sk, acked);
+		}
+
 		if (ca_ops->pkts_acked)
 			ca_ops->pkts_acked(sk, pkts_acked, last_ackt);
 	}
@@ -3017,7 +3019,8 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
 		    tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack,  seq_rtt, prior_in_flight, 0);
-		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag,
+		tcp_fastretrans_alert(sk, prior_snd_una,
+				      prior_packets - tp->packets_out, flag,
 				      mark_lost_entry_seq);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
--=20
1.5.0.6

