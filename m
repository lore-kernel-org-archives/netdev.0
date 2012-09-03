From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 1/3] tcp: move tcp_enter_cwr()
Date: Sun,  2 Sep 2012 20:38:02 -0700
Message-ID: <1346643484-12947-1-git-send-email-ycheng@google.com>
Cc: mattmathis@google.com, edumazet@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fa0-f74.google.com ([209.85.161.74]:54257 "EHLO
	mail-fa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755811Ab2ICDiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 23:38:21 -0400
Received: by fass10 with SMTP id s10so243337fas.1
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 20:38:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prepare replacing rate halving with PRR algorithm in CWR state.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |   46 +++++++++++++++++++++++-----------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8c304a4..3ab0c75 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -743,29 +743,6 @@ __u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst)
 	return min_t(__u32, cwnd, tp->snd_cwnd_clamp);
 }
 
-/* Set slow start threshold and cwnd not falling to slow start */
-void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-
-	tp->prior_ssthresh = 0;
-	tp->bytes_acked = 0;
-	if (icsk->icsk_ca_state < TCP_CA_CWR) {
-		tp->undo_marker = 0;
-		if (set_ssthresh)
-			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
-		tp->snd_cwnd = min(tp->snd_cwnd,
-				   tcp_packets_in_flight(tp) + 1U);
-		tp->snd_cwnd_cnt = 0;
-		tp->high_seq = tp->snd_nxt;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
-		TCP_ECN_queue_cwr(tp);
-
-		tcp_set_ca_state(sk, TCP_CA_CWR);
-	}
-}
-
 /*
  * Packet counting of FACK is based on in-order assumptions, therefore TCP
  * disables it when reordering is detected
@@ -2741,6 +2718,29 @@ static inline void tcp_complete_cwr(struct sock *sk)
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
 
+/* Set slow start threshold and cwnd not falling to slow start */
+void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	tp->prior_ssthresh = 0;
+	tp->bytes_acked = 0;
+	if (icsk->icsk_ca_state < TCP_CA_CWR) {
+		tp->undo_marker = 0;
+		if (set_ssthresh)
+			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
+		tp->snd_cwnd = min(tp->snd_cwnd,
+				   tcp_packets_in_flight(tp) + 1U);
+		tp->snd_cwnd_cnt = 0;
+		tp->high_seq = tp->snd_nxt;
+		tp->snd_cwnd_stamp = tcp_time_stamp;
+		TCP_ECN_queue_cwr(tp);
+
+		tcp_set_ca_state(sk, TCP_CA_CWR);
+	}
+}
+
 static void tcp_try_keep_open(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-- 
1.7.7.3
