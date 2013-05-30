From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 3/4 net-next] tcp: fix undo on partial ack in recovery
Date: Wed, 29 May 2013 17:20:13 -0700
Message-ID: <1369873214-29502-3-git-send-email-ycheng@google.com>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
Cc: aterzis@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f202.google.com ([209.85.213.202]:60052 "EHLO
	mail-ye0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967077Ab3E3AUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:20:35 -0400
Received: by mail-ye0-f202.google.com with SMTP id m13so670016yen.5
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:20:35 -0700 (PDT)
In-Reply-To: <1369873214-29502-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon detecting spurious fast retransmit via timestamps during recovery,
use PRR to clock out new data packet instead of retransmission. Once
all retransmission are proven spurious, the sender then reverts the
cwnd reduction and congestion state to open or disorder.

The current code does the opposite: it undoes cwnd as soon as any
retransmission is spurious and continues to retransmit until all
data are acked. This nullifies the point to undo the cwnd because
the sender is still retransmistting spuriously. This patch fixes
it. The undo_ssthresh argument of tcp_undo_cwnd_reductiuon() is no
longer needed and is removed.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 59 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 33 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fcb668d..c35b227 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2243,8 +2243,7 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 #define DBGUNDO(x...) do { } while (0)
 #endif
 
-static void tcp_undo_cwnd_reduction(struct sock *sk, const bool undo_ssthresh,
-				    bool unmark_loss)
+static void tcp_undo_cwnd_reduction(struct sock *sk, bool unmark_loss)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2268,7 +2267,7 @@ static void tcp_undo_cwnd_reduction(struct sock *sk, const bool undo_ssthresh,
 		else
 			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh << 1);
 
-		if (undo_ssthresh && tp->prior_ssthresh > tp->snd_ssthresh) {
+		if (tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
 			TCP_ECN_withdraw_cwr(tp);
 		}
@@ -2276,9 +2275,7 @@ static void tcp_undo_cwnd_reduction(struct sock *sk, const bool undo_ssthresh,
 		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh);
 	}
 	tp->snd_cwnd_stamp = tcp_time_stamp;
-
-	if (undo_ssthresh)
-		tp->undo_marker = 0;
+	tp->undo_marker = 0;
 }
 
 static inline bool tcp_may_undo(const struct tcp_sock *tp)
@@ -2298,7 +2295,7 @@ static bool tcp_try_undo_recovery(struct sock *sk)
 		 * or our original transmission succeeded.
 		 */
 		DBGUNDO(sk, inet_csk(sk)->icsk_ca_state == TCP_CA_Loss ? "loss" : "retrans");
-		tcp_undo_cwnd_reduction(sk, true, false);
+		tcp_undo_cwnd_reduction(sk, false);
 		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Loss)
 			mib_idx = LINUX_MIB_TCPLOSSUNDO;
 		else
@@ -2324,7 +2321,7 @@ static void tcp_try_undo_dsack(struct sock *sk)
 
 	if (tp->undo_marker && !tp->undo_retrans) {
 		DBGUNDO(sk, "D-SACK");
-		tcp_undo_cwnd_reduction(sk, true, false);
+		tcp_undo_cwnd_reduction(sk, false);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKUNDO);
 	}
 }
@@ -2364,7 +2361,7 @@ static bool tcp_try_undo_loss(struct sock *sk, bool frto_undo)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (frto_undo || tcp_may_undo(tp)) {
-		tcp_undo_cwnd_reduction(sk, true, true);
+		tcp_undo_cwnd_reduction(sk, true);
 
 		DBGUNDO(sk, "partial loss");
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSUNDO);
@@ -2644,32 +2641,37 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 }
 
 /* Undo during fast recovery after partial ACK. */
-static bool tcp_try_undo_partial(struct sock *sk, int acked)
+static bool tcp_try_undo_partial(struct sock *sk, const int acked,
+				 const int prior_unsacked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	/* Partial ACK arrived. Force Hoe's retransmit. */
-	bool failed = tcp_is_reno(tp) || (tcp_fackets_out(tp) > tp->reordering);
 
-	if (tcp_may_undo(tp)) {
+	if (tp->undo_marker && tcp_packet_delayed(tp)) {
 		/* Plain luck! Hole if filled with delayed
 		 * packet, rather than with a retransmit.
 		 */
+		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
+
+		/* We are getting evidence that the reordering degree is higher
+		 * than we realized. If there are no retransmits out then we
+		 * can undo. Otherwise we clock out new packets but do not
+		 * mark more packets lost or retransmit more.
+		 */
+		if (tp->retrans_out) {
+			tcp_cwnd_reduction(sk, prior_unsacked, 0);
+			return true;
+		}
+
 		if (!tcp_any_retrans_done(sk))
 			tp->retrans_stamp = 0;
 
-		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
-
-		DBGUNDO(sk, "Hoe");
-		tcp_undo_cwnd_reduction(sk, false, false);
+		DBGUNDO(sk, "partial recovery");
+		tcp_undo_cwnd_reduction(sk, true);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPARTIALUNDO);
-
-		/* So... Do not make Hoe's retransmit yet.
-		 * If the first packet was delayed, the rest
-		 * ones are most probably delayed as well.
-		 */
-		failed = false;
+		tcp_try_keep_open(sk);
+		return true;
 	}
-	return failed;
+	return false;
 }
 
 /* Process an event, which can update packets-in-flight not trivially.
@@ -2742,8 +2744,13 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 		if (!(flag & FLAG_SND_UNA_ADVANCED)) {
 			if (tcp_is_reno(tp) && is_dupack)
 				tcp_add_reno_sack(sk);
-		} else
-			do_lost = tcp_try_undo_partial(sk, acked);
+		} else {
+			if (tcp_try_undo_partial(sk, acked, prior_unsacked))
+				return;
+			/* Partial ACK arrived. Force fast retransmit. */
+			do_lost = tcp_is_reno(tp) ||
+				  tcp_fackets_out(tp) > tp->reordering;
+		}
 		break;
 	case TCP_CA_Loss:
 		tcp_process_loss(sk, flag, is_dupack);
-- 
1.8.2.1
