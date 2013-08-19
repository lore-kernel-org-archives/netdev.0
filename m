From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [RFC 1/2] Use acked_out for reno-style ack acounting instead of sacked_out
Date: Mon, 19 Aug 2013 21:29:27 +0200
Message-ID: <1376940568-16512-2-git-send-email-christoph.paasch@uclouvain.be>
References: <1376935800.4226.71.camel@edumazet-glaptop>
 <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Benjamin Hesmans <benjamin.hesmans@uclouvain.be>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59656 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab3HST3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 15:29:47 -0400
In-Reply-To: <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds acked_out to tcp_sock, so that all acounting of acked
packets in case of non-sack connections is done within this field.

tcp_acked_out() sums up sacked_out and acked_out.

Tested-by: Benjamin Hesmans <benjamin.hesmans@uclouvain.be>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/linux/tcp.h      |  1 +
 include/net/tcp.h        | 17 ++++++++++++-----
 net/ipv4/tcp_input.c     | 44 +++++++++++++++++++++++++++-----------------
 net/ipv4/tcp_minisocks.c |  1 +
 net/ipv4/tcp_output.c    |  2 +-
 net/ipv4/tcp_timer.c     |  2 +-
 6 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d686334..6622595 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -241,6 +241,7 @@ struct tcp_sock {
 	u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
 	u32	lost_out;	/* Lost packets			*/
 	u32	sacked_out;	/* SACK'd packets			*/
+	u32	acked_out;	/* DupACK'd packets			*/
 	u32	fackets_out;	/* FACK'd packets			*/
 	u32	tso_deferred;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 09cb5c1..8210057 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -871,9 +871,14 @@ static inline void tcp_disable_early_retrans(struct tcp_sock *tp)
 	tp->do_early_retrans = 0;
 }
 
+static inline unsigned int tcp_acked_out(const struct tcp_sock *tp)
+{
+	return tp->sacked_out + tp->acked_out;
+}
+
 static inline unsigned int tcp_left_out(const struct tcp_sock *tp)
 {
-	return tp->sacked_out + tp->lost_out;
+	return tcp_acked_out(tp) + tp->lost_out;
 }
 
 /* This determines how many packets are "in the network" to the best
@@ -1446,12 +1451,12 @@ static inline void tcp_push_pending_frames(struct sock *sk)
 }
 
 /* Start sequence of the skb just after the highest skb with SACKed
- * bit, valid only if sacked_out > 0 or when the caller has ensured
+ * bit, valid only if sacked_out or acked_out > 0 or when the caller has ensured
  * validity by itself.
  */
 static inline u32 tcp_highest_sack_seq(struct tcp_sock *tp)
 {
-	if (!tp->sacked_out)
+	if (!tp->sacked_out && !tp->acked_out)
 		return tp->snd_una;
 
 	if (tp->highest_sack == NULL)
@@ -1481,8 +1486,10 @@ static inline void tcp_highest_sack_combine(struct sock *sk,
 					    struct sk_buff *old,
 					    struct sk_buff *new)
 {
-	if (tcp_sk(sk)->sacked_out && (old == tcp_sk(sk)->highest_sack))
-		tcp_sk(sk)->highest_sack = new;
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if ((tp->sacked_out || tp->acked_out) && (old == tp->highest_sack))
+		tp->highest_sack = new;
 }
 
 /* Determines whether this is a thin stream (which may suffer from
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e965cc7..af764d0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1748,8 +1748,8 @@ out:
 	return state.flag;
 }
 
-/* Limits sacked_out so that sum with lost_out isn't ever larger than
- * packets_out. Returns false if sacked_out adjustement wasn't necessary.
+/* Limits acked_out so that sum with lost_out isn't ever larger than
+ * packets_out. Returns false if acked_out adjustement wasn't necessary.
  */
 static bool tcp_limit_reno_sacked(struct tcp_sock *tp)
 {
@@ -1758,8 +1758,8 @@ static bool tcp_limit_reno_sacked(struct tcp_sock *tp)
 	holes = max(tp->lost_out, 1U);
 	holes = min(holes, tp->packets_out);
 
-	if ((tp->sacked_out + holes) > tp->packets_out) {
-		tp->sacked_out = tp->packets_out - holes;
+	if ((tp->acked_out + holes) > tp->packets_out) {
+		tp->acked_out = tp->packets_out - holes;
 		return true;
 	}
 	return false;
@@ -1781,7 +1781,7 @@ static void tcp_check_reno_reordering(struct sock *sk, const int addend)
 static void tcp_add_reno_sack(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	tp->sacked_out++;
+	tp->acked_out++;
 	tcp_check_reno_reordering(sk, 0);
 	tcp_verify_left_out(tp);
 }
@@ -1794,10 +1794,10 @@ static void tcp_remove_reno_sacks(struct sock *sk, int acked)
 
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
-		if (acked - 1 >= tp->sacked_out)
-			tp->sacked_out = 0;
+		if (acked - 1 >= tp->acked_out)
+			tp->acked_out = 0;
 		else
-			tp->sacked_out -= acked - 1;
+			tp->acked_out -= acked - 1;
 	}
 	tcp_check_reno_reordering(sk, acked);
 	tcp_verify_left_out(tp);
@@ -1805,7 +1805,7 @@ static void tcp_remove_reno_sacks(struct sock *sk, int acked)
 
 static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
 {
-	tp->sacked_out = 0;
+	tp->acked_out = 0;
 }
 
 static void tcp_clear_retrans_partial(struct tcp_sock *tp)
@@ -1823,6 +1823,7 @@ void tcp_clear_retrans(struct tcp_sock *tp)
 
 	tp->fackets_out = 0;
 	tp->sacked_out = 0;
+	tp->acked_out = 0;
 }
 
 /* Enter Loss state. If "how" is not zero, forget all SACK information
@@ -1857,6 +1858,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tp->undo_marker = tp->snd_una;
 	if (how) {
 		tp->sacked_out = 0;
+		tp->acked_out = 0;
 		tp->fackets_out = 0;
 	}
 	tcp_clear_all_retrans_hints(tp);
@@ -1921,7 +1923,7 @@ static bool tcp_check_sack_reneging(struct sock *sk, int flag)
 
 static inline int tcp_fackets_out(const struct tcp_sock *tp)
 {
-	return tcp_is_reno(tp) ? tp->sacked_out + 1 : tp->fackets_out;
+	return tcp_is_reno(tp) ? tp->acked_out + 1 : tp->fackets_out;
 }
 
 /* Heurestics to calculate number of duplicate ACKs. There's no dupACKs
@@ -1941,7 +1943,7 @@ static inline int tcp_fackets_out(const struct tcp_sock *tp)
  */
 static inline int tcp_dupack_heuristics(const struct tcp_sock *tp)
 {
-	return tcp_is_fack(tp) ? tp->fackets_out : tp->sacked_out + 1;
+	return tcp_is_fack(tp) ? tp->fackets_out : tcp_acked_out(tp) + 1;
 }
 
 static bool tcp_pause_early_retransmit(struct sock *sk, int flag)
@@ -2077,7 +2079,7 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
 	 */
 	packets_out = tp->packets_out;
 	if (packets_out <= tp->reordering &&
-	    tp->sacked_out >= max_t(__u32, packets_out/2, sysctl_tcp_reordering) &&
+	    tcp_acked_out(tp) >= max_t(__u32, packets_out/2, sysctl_tcp_reordering) &&
 	    !tcp_may_send_now(sk)) {
 		/* We have nothing to send. This connection is limited
 		 * either by receiver window or by application.
@@ -2100,8 +2102,8 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
 	 * Mitigation A.3 in the RFC and delay the retransmission for a short
 	 * interval if appropriate.
 	 */
-	if (tp->do_early_retrans && !tp->retrans_out && tp->sacked_out &&
-	    (tp->packets_out >= (tp->sacked_out + 1) && tp->packets_out < 4) &&
+	if (tp->do_early_retrans && !tp->retrans_out && (tp->sacked_out || tp->acked_out) &&
+	    (tp->packets_out >= (tcp_acked_out(tp) + 1) && tp->packets_out < 4) &&
 	    !tcp_may_send_now(sk))
 		return !tcp_pause_early_retransmit(sk, flag);
 
@@ -2701,9 +2703,11 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0;
 
-	if (WARN_ON(!tp->packets_out && tp->sacked_out))
+	if (WARN_ON(!tp->packets_out && (tp->sacked_out || tp->acked_out))) {
 		tp->sacked_out = 0;
-	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
+		tp->acked_out = 0;
+	}
+	if (WARN_ON(!tp->sacked_out && !tp->acked_out && tp->fackets_out))
 		tp->fackets_out = 0;
 
 	/* Now state machine starts.
@@ -3078,6 +3082,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 #if FASTRETRANS_DEBUG > 0
 	WARN_ON((int)tp->sacked_out < 0);
+	WARN_ON((int)tp->acked_out < 0);
 	WARN_ON((int)tp->lost_out < 0);
 	WARN_ON((int)tp->retrans_out < 0);
 	if (!tp->packets_out && tcp_is_sack(tp)) {
@@ -3092,6 +3097,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 				 tp->sacked_out, icsk->icsk_ca_state);
 			tp->sacked_out = 0;
 		}
+		if (tp->acked_out) {
+			pr_debug("Leak a=%u %d\n",
+				 tp->acked_out, icsk->icsk_ca_state);
+			tp->acked_out = 0;
+		}
 		if (tp->retrans_out) {
 			pr_debug("Leak r=%u %d\n",
 				 tp->retrans_out, icsk->icsk_ca_state);
@@ -3270,7 +3280,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	u32 prior_in_flight;
 	u32 prior_fackets;
 	int prior_packets = tp->packets_out;
-	const int prior_unsacked = tp->packets_out - tp->sacked_out;
+	const int prior_unsacked = tp->packets_out - tcp_acked_out(tp);
 	int acked = 0; /* Number of packets newly acked */
 	s32 sack_rtt = -1;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 58a3e69..a2f5279 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -407,6 +407,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->packets_out = 0;
 		newtp->retrans_out = 0;
 		newtp->sacked_out = 0;
+		newtp->acked_out = 0;
 		newtp->fackets_out = 0;
 		newtp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 		tcp_enable_early_retrans(newtp);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 884efff..17ebbff 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1033,7 +1033,7 @@ static void tcp_adjust_pcount(struct sock *sk, const struct sk_buff *skb, int de
 
 	/* Reno case is special. Sigh... */
 	if (tcp_is_reno(tp) && decr > 0)
-		tp->sacked_out -= min_t(u32, tp->sacked_out, decr);
+		tp->acked_out -= min_t(u32, tp->acked_out, decr);
 
 	tcp_adjust_fackets_out(sk, skb, decr);
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 4b85e6f..82acaea 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -405,7 +405,7 @@ void tcp_retransmit_timer(struct sock *sk)
 		} else if (icsk->icsk_ca_state == TCP_CA_Loss) {
 			mib_idx = LINUX_MIB_TCPLOSSFAILURES;
 		} else if ((icsk->icsk_ca_state == TCP_CA_Disorder) ||
-			   tp->sacked_out) {
+			   tp->sacked_out || tp->acked_out) {
 			if (tcp_is_sack(tp))
 				mib_idx = LINUX_MIB_TCPSACKFAILURES;
 			else
-- 
1.8.1.2
