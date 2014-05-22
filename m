From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: make cwnd-limited checks measurement-based, and gentler
Date: Thu, 22 May 2014 10:41:08 -0400
Message-ID: <1400769668-4908-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:40587 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbaEVOlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 10:41:18 -0400
Received: by mail-pb0-f73.google.com with SMTP id ma3so436904pbc.2
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 07:41:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Experience with the recent e114a710aa50 ("tcp: fix cwnd limited
checking to improve congestion control") has shown that there are
common cases where that commit can cause cwnd to be much larger than
necessary. This leads to TSO autosizing cooking skbs that are too
large, among other things.

The main problems seemed to be:

(1) That commit attempted to predict the future behavior of the
connection by looking at the write queue (if TSO or TSQ limit
sending). That prediction sometimes overestimated future outstanding
packets.

(2) That commit always allowed cwnd to grow to twice the number of
outstanding packets (even in congestion avoidance, where this is not
needed).

This commit improves both of these, by:

(1) Switching to a measurement-based approach where we explicitly
track the largest number of packets in flight during the past window
("max_packets_out"), and remember whether we were cwnd-limited at the
moment we finished sending that flight.

(2) Only allowing cwnd to grow to twice the number of outstanding
packets ("max_packets_out") in slow start. In congestion avoidance
mode we now only allow cwnd to grow if it was fully utilized.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h   |  6 ++++--
 include/net/tcp.h     | 11 ++++++++---
 net/ipv4/tcp_output.c | 37 +++++++++++++++++++++++--------------
 3 files changed, 35 insertions(+), 19 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index bc35e47..a051321 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -197,7 +197,8 @@ struct tcp_sock {
 	u8	do_early_retrans:1,/* Enable RFC5827 early-retransmit  */
 		syn_data:1,	/* SYN includes data */
 		syn_fastopen:1,	/* SYN includes Fast Open option */
-		syn_data_acked:1;/* data in SYN is acked by SYN-ACK */
+		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
+		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
@@ -209,6 +210,8 @@ struct tcp_sock {
 
 	u32	packets_out;	/* Packets which are "in flight"	*/
 	u32	retrans_out;	/* Retransmitted packets out		*/
+	u32	max_packets_out;  /* max packets_out in last window */
+	u32	max_packets_seq;  /* right edge of max_packets_out flight */
 
 	u16	urg_data;	/* Saved octet of OOB data and control flags */
 	u8	ecn_flags;	/* ECN status bits.			*/
@@ -230,7 +233,6 @@ struct tcp_sock {
 	u32	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
-	u32	lsnd_pending;	/* packets inflight or unsent since last xmit */
 	u32	prior_cwnd;	/* Congestion window at start of Recovery. */
 	u32	prr_delivered;	/* Number of newly delivered packets to
 				 * receiver in Recovery. */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f5d6ca4..e80abe4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -971,8 +971,9 @@ static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
 
 /* We follow the spirit of RFC2861 to validate cwnd but implement a more
  * flexible approach. The RFC suggests cwnd should not be raised unless
- * it was fully used previously. But we allow cwnd to grow as long as the
- * application has used half the cwnd.
+ * it was fully used previously. And that's exactly what we do in
+ * congestion avoidance mode. But in slow start we allow cwnd to grow
+ * as long as the application has used half the cwnd.
  * Example :
  *    cwnd is 10 (IW10), but application sends 9 frames.
  *    We allow cwnd to reach 18 when all frames are ACKed.
@@ -985,7 +986,11 @@ static inline bool tcp_is_cwnd_limited(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
-	return tp->snd_cwnd < 2 * tp->lsnd_pending;
+	/* If in slow start, ensure cwnd grows to twice what was ACKed. */
+	if (tp->snd_cwnd <= tp->snd_ssthresh)
+		return tp->snd_cwnd < 2 * tp->max_packets_out;
+
+	return tp->is_cwnd_limited;
 }
 
 static inline void tcp_check_probe_timer(struct sock *sk)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3d61c52..d463c35 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1402,11 +1402,19 @@ static void tcp_cwnd_application_limited(struct sock *sk)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static void tcp_cwnd_validate(struct sock *sk, u32 unsent_segs)
+static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	tp->lsnd_pending = tp->packets_out + unsent_segs;
+	/* Track the maximum number of outstanding packets in each
+	 * window, and remember whether we were cwnd-limited then.
+	 */
+	if (!before(tp->snd_una, tp->max_packets_seq) ||
+	    tp->packets_out > tp->max_packets_out) {
+		tp->max_packets_out = tp->packets_out;
+		tp->max_packets_seq = tp->snd_nxt;
+		tp->is_cwnd_limited = is_cwnd_limited;
+	}
 
 	if (tcp_is_cwnd_limited(sk)) {
 		/* Network is feed fully. */
@@ -1660,7 +1668,8 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
  *
  * This algorithm is from John Heffner.
  */
-static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
+static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
+				 bool *is_cwnd_limited)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -1724,6 +1733,9 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 	if (!tp->tso_deferred)
 		tp->tso_deferred = 1 | (jiffies << 1);
 
+	if (cong_win < send_win && cong_win < skb->len)
+		*is_cwnd_limited = true;
+
 	return true;
 
 send_now:
@@ -1881,9 +1893,10 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	unsigned int tso_segs, sent_pkts, unsent_segs = 0;
+	unsigned int tso_segs, sent_pkts;
 	int cwnd_quota;
 	int result;
+	bool is_cwnd_limited = false;
 
 	sent_pkts = 0;
 
@@ -1908,6 +1921,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 		cwnd_quota = tcp_cwnd_test(tp, skb);
 		if (!cwnd_quota) {
+			is_cwnd_limited = true;
 			if (push_one == 2)
 				/* Force out a loss probe pkt. */
 				cwnd_quota = 1;
@@ -1924,8 +1938,9 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 						      nonagle : TCP_NAGLE_PUSH))))
 				break;
 		} else {
-			if (!push_one && tcp_tso_should_defer(sk, skb))
-				goto compute_unsent_segs;
+			if (!push_one &&
+			    tcp_tso_should_defer(sk, skb, &is_cwnd_limited))
+				break;
 		}
 
 		/* TCP Small Queues :
@@ -1950,14 +1965,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			 * there is no smp_mb__after_set_bit() yet
 			 */
 			smp_mb__after_clear_bit();
-			if (atomic_read(&sk->sk_wmem_alloc) > limit) {
-				u32 unsent_bytes;
-
-compute_unsent_segs:
-				unsent_bytes = tp->write_seq - tp->snd_nxt;
-				unsent_segs = DIV_ROUND_UP(unsent_bytes, mss_now);
+			if (atomic_read(&sk->sk_wmem_alloc) > limit)
 				break;
-			}
 		}
 
 		limit = mss_now;
@@ -1997,7 +2006,7 @@ repair:
 		/* Send one loss probe per tail loss episode. */
 		if (push_one != 2)
 			tcp_schedule_loss_probe(sk);
-		tcp_cwnd_validate(sk, unsent_segs);
+		tcp_cwnd_validate(sk, is_cwnd_limited);
 		return false;
 	}
 	return (push_one == 2) || (!tp->packets_out && tcp_send_head(sk));
-- 
1.9.1.423.g4596e3a
