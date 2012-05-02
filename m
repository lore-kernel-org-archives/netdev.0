From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH v3 1/3] tcp: early retransmit: tcp_enter_recovery()
Date: Wed,  2 May 2012 11:46:29 -0700
Message-ID: <1335984391-31340-1-git-send-email-ycheng@google.com>
Cc: ncardwell@google.com, nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f74.google.com ([209.85.214.74]:52612 "EHLO
	mail-bk0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab2EBSqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 14:46:34 -0400
Received: by bkty5 with SMTP id y5so54679bkt.1
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 11:46:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This a prepartion patch that refactors the code to enter recovery
into a new function tcp_enter_recovery(). It's needed to implement
the delayed fast retransmit in ER.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
ChangeLog since v1:
 - swaped with part 1 and part2
ChangeLog since v2:
 - removed RFC in commit message
 
 net/ipv4/tcp_input.c |   61 +++++++++++++++++++++++++++----------------------
 1 files changed, 34 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c93b0cb..22df826 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3022,6 +3022,38 @@ static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
 	tp->snd_cwnd = tcp_packets_in_flight(tp) + sndcnt;
 }
 
+static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	int mib_idx;
+
+	if (tcp_is_reno(tp))
+		mib_idx = LINUX_MIB_TCPRENORECOVERY;
+	else
+		mib_idx = LINUX_MIB_TCPSACKRECOVERY;
+
+	NET_INC_STATS_BH(sock_net(sk), mib_idx);
+
+	tp->high_seq = tp->snd_nxt;
+	tp->prior_ssthresh = 0;
+	tp->undo_marker = tp->snd_una;
+	tp->undo_retrans = tp->retrans_out;
+
+	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
+		if (!ece_ack)
+			tp->prior_ssthresh = tcp_current_ssthresh(sk);
+		tp->snd_ssthresh = inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
+		TCP_ECN_queue_cwr(tp);
+	}
+
+	tp->bytes_acked = 0;
+	tp->snd_cwnd_cnt = 0;
+	tp->prior_cwnd = tp->snd_cwnd;
+	tp->prr_delivered = 0;
+	tp->prr_out = 0;
+	tcp_set_ca_state(sk, TCP_CA_Recovery);
+}
+
 /* Process an event, which can update packets-in-flight not trivially.
  * Main goal of this function is to calculate new estimate for left_out,
  * taking into account both packets sitting in receiver's buffer and
@@ -3041,7 +3073,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 	struct tcp_sock *tp = tcp_sk(sk);
 	int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
-	int fast_rexmit = 0, mib_idx;
+	int fast_rexmit = 0;
 
 	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out = 0;
@@ -3142,32 +3174,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 		}
 
 		/* Otherwise enter Recovery state */
-
-		if (tcp_is_reno(tp))
-			mib_idx = LINUX_MIB_TCPRENORECOVERY;
-		else
-			mib_idx = LINUX_MIB_TCPSACKRECOVERY;
-
-		NET_INC_STATS_BH(sock_net(sk), mib_idx);
-
-		tp->high_seq = tp->snd_nxt;
-		tp->prior_ssthresh = 0;
-		tp->undo_marker = tp->snd_una;
-		tp->undo_retrans = tp->retrans_out;
-
-		if (icsk->icsk_ca_state < TCP_CA_CWR) {
-			if (!(flag & FLAG_ECE))
-				tp->prior_ssthresh = tcp_current_ssthresh(sk);
-			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
-			TCP_ECN_queue_cwr(tp);
-		}
-
-		tp->bytes_acked = 0;
-		tp->snd_cwnd_cnt = 0;
-		tp->prior_cwnd = tp->snd_cwnd;
-		tp->prr_delivered = 0;
-		tp->prr_out = 0;
-		tcp_set_ca_state(sk, TCP_CA_Recovery);
+		tcp_enter_recovery(sk, (flag & FLAG_ECE));
 		fast_rexmit = 1;
 	}
 
-- 
1.7.7.3
