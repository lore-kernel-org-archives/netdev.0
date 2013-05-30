From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 2/4 net-next] tcp: refactor undo functions
Date: Wed, 29 May 2013 17:20:12 -0700
Message-ID: <1369873214-29502-2-git-send-email-ycheng@google.com>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
Cc: aterzis@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:45601 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967244Ab3E3AUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:20:36 -0400
Received: by mail-vc0-f202.google.com with SMTP id m17so1011816vca.5
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:20:35 -0700 (PDT)
In-Reply-To: <1369873214-29502-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor and relocate various functions or variables to prepare the
undo fix.  Remove some unused function arguments. Rename tcp_undo_cwr
to tcp_undo_cwnd_reduction to be consistent with the rest of
CWR related function names.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 97 +++++++++++++++++++++++++++-------------------------
 1 file changed, 50 insertions(+), 47 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 86b5fa7..fcb668d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2243,10 +2243,23 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 #define DBGUNDO(x...) do { } while (0)
 #endif
 
-static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
+static void tcp_undo_cwnd_reduction(struct sock *sk, const bool undo_ssthresh,
+				    bool unmark_loss)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	if (unmark_loss) {
+		struct sk_buff *skb;
+
+		tcp_for_write_queue(skb, sk) {
+			if (skb == tcp_send_head(sk))
+				break;
+			TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
+		}
+		tp->lost_out = 0;
+		tcp_clear_all_retrans_hints(tp);
+	}
+
 	if (tp->prior_ssthresh) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 
@@ -2263,6 +2276,9 @@ static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
 		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh);
 	}
 	tp->snd_cwnd_stamp = tcp_time_stamp;
+
+	if (undo_ssthresh)
+		tp->undo_marker = 0;
 }
 
 static inline bool tcp_may_undo(const struct tcp_sock *tp)
@@ -2282,14 +2298,13 @@ static bool tcp_try_undo_recovery(struct sock *sk)
 		 * or our original transmission succeeded.
 		 */
 		DBGUNDO(sk, inet_csk(sk)->icsk_ca_state == TCP_CA_Loss ? "loss" : "retrans");
-		tcp_undo_cwr(sk, true);
+		tcp_undo_cwnd_reduction(sk, true, false);
 		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Loss)
 			mib_idx = LINUX_MIB_TCPLOSSUNDO;
 		else
 			mib_idx = LINUX_MIB_TCPFULLUNDO;
 
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
-		tp->undo_marker = 0;
 	}
 	if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
 		/* Hold old state until something *above* high_seq
@@ -2309,8 +2324,7 @@ static void tcp_try_undo_dsack(struct sock *sk)
 
 	if (tp->undo_marker && !tp->undo_retrans) {
 		DBGUNDO(sk, "D-SACK");
-		tcp_undo_cwr(sk, true);
-		tp->undo_marker = 0;
+		tcp_undo_cwnd_reduction(sk, true, false);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKUNDO);
 	}
 }
@@ -2344,60 +2358,20 @@ static bool tcp_any_retrans_done(const struct sock *sk)
 	return false;
 }
 
-/* Undo during fast recovery after partial ACK. */
-
-static int tcp_try_undo_partial(struct sock *sk, int acked)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	/* Partial ACK arrived. Force Hoe's retransmit. */
-	int failed = tcp_is_reno(tp) || (tcp_fackets_out(tp) > tp->reordering);
-
-	if (tcp_may_undo(tp)) {
-		/* Plain luck! Hole if filled with delayed
-		 * packet, rather than with a retransmit.
-		 */
-		if (!tcp_any_retrans_done(sk))
-			tp->retrans_stamp = 0;
-
-		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
-
-		DBGUNDO(sk, "Hoe");
-		tcp_undo_cwr(sk, false);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPARTIALUNDO);
-
-		/* So... Do not make Hoe's retransmit yet.
-		 * If the first packet was delayed, the rest
-		 * ones are most probably delayed as well.
-		 */
-		failed = 0;
-	}
-	return failed;
-}
-
 /* Undo during loss recovery after partial ACK or using F-RTO. */
 static bool tcp_try_undo_loss(struct sock *sk, bool frto_undo)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (frto_undo || tcp_may_undo(tp)) {
-		struct sk_buff *skb;
-		tcp_for_write_queue(skb, sk) {
-			if (skb == tcp_send_head(sk))
-				break;
-			TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
-		}
-
-		tcp_clear_all_retrans_hints(tp);
+		tcp_undo_cwnd_reduction(sk, true, true);
 
 		DBGUNDO(sk, "partial loss");
-		tp->lost_out = 0;
-		tcp_undo_cwr(sk, true);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSUNDO);
 		if (frto_undo)
 			NET_INC_STATS_BH(sock_net(sk),
 					 LINUX_MIB_TCPSPURIOUSRTOS);
 		inet_csk(sk)->icsk_retransmits = 0;
-		tp->undo_marker = 0;
 		if (frto_undo || tcp_is_sack(tp))
 			tcp_set_ca_state(sk, TCP_CA_Open);
 		return true;
@@ -2669,6 +2643,35 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 	tcp_xmit_retransmit_queue(sk);
 }
 
+/* Undo during fast recovery after partial ACK. */
+static bool tcp_try_undo_partial(struct sock *sk, int acked)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	/* Partial ACK arrived. Force Hoe's retransmit. */
+	bool failed = tcp_is_reno(tp) || (tcp_fackets_out(tp) > tp->reordering);
+
+	if (tcp_may_undo(tp)) {
+		/* Plain luck! Hole if filled with delayed
+		 * packet, rather than with a retransmit.
+		 */
+		if (!tcp_any_retrans_done(sk))
+			tp->retrans_stamp = 0;
+
+		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
+
+		DBGUNDO(sk, "Hoe");
+		tcp_undo_cwnd_reduction(sk, false, false);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPARTIALUNDO);
+
+		/* So... Do not make Hoe's retransmit yet.
+		 * If the first packet was delayed, the rest
+		 * ones are most probably delayed as well.
+		 */
+		failed = false;
+	}
+	return failed;
+}
+
 /* Process an event, which can update packets-in-flight not trivially.
  * Main goal of this function is to calculate new estimate for left_out,
  * taking into account both packets sitting in receiver's buffer and
@@ -2686,7 +2689,7 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
+	bool do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0;
 
-- 
1.8.2.1
