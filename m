From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 1/2 v2 net-next] tcp: fix cwnd undo in Reno and HTCP congestion controls
Date: Thu,  3 Aug 2017 20:38:51 -0700
Message-ID: <20170804033852.97986-2-ycheng@google.com>
References: <20170804033852.97986-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, unlcsewsun@gmail.com,
        stephen@networkplumber.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33701 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbdHDDjI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 23:39:08 -0400
Received: by mail-pg0-f41.google.com with SMTP id u5so2738541pgn.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 20:39:07 -0700 (PDT)
In-Reply-To: <20170804033852.97986-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using ssthresh to revert cwnd is less reliable when ssthresh is
bounded to 2 packets. This patch uses an existing variable in TCP
"prior_cwnd" that snapshots the cwnd right before entering fast
recovery and RTO recovery in Reno.  This fixes the issue discussed
in netdev thread: "A buggy behavior for Linux TCP Reno and HTCP"
https://www.spinics.net/lists/netdev/msg444955.html

Suggested-by: Neal Cardwell <ncardwell@google.com>
Reported-by: Wei Sun <unlcsewsun@gmail.com>
Signed-off-by: Yuchung Cheng <ncardwell@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/tcp.h  | 2 +-
 net/ipv4/tcp_cong.c  | 2 +-
 net/ipv4/tcp_htcp.c  | 3 +--
 net/ipv4/tcp_input.c | 1 +
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index d7389ea36e10..267164a1d559 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -258,7 +258,7 @@ struct tcp_sock {
 	u32	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
-	u32	prior_cwnd;	/* Congestion window at start of Recovery. */
+	u32	prior_cwnd;	/* cwnd right before starting loss recovery */
 	u32	prr_delivered;	/* Number of newly delivered packets to
 				 * receiver in Recovery. */
 	u32	prr_out;	/* Total number of pkts sent during Recovery. */
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index fde983f6376b..c2b174469645 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -456,7 +456,7 @@ u32 tcp_reno_undo_cwnd(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
-	return max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+	return max(tp->snd_cwnd, tp->prior_cwnd);
 }
 EXPORT_SYMBOL_GPL(tcp_reno_undo_cwnd);
 
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 3eb78cde6ff0..082d479462fa 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -66,7 +66,6 @@ static inline void htcp_reset(struct htcp *ca)
 
 static u32 htcp_cwnd_undo(struct sock *sk)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
 
 	if (ca->undo_last_cong) {
@@ -76,7 +75,7 @@ static u32 htcp_cwnd_undo(struct sock *sk)
 		ca->undo_last_cong = 0;
 	}
 
-	return max(tp->snd_cwnd, (tp->snd_ssthresh << 7) / ca->beta);
+	return tcp_reno_undo_cwnd(sk);
 }
 
 static inline void measure_rtt(struct sock *sk, u32 srtt)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 99cdf4ccabb8..842ed75ccb25 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1950,6 +1950,7 @@ void tcp_enter_loss(struct sock *sk)
 	    !after(tp->high_seq, tp->snd_una) ||
 	    (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
 		tp->prior_ssthresh = tcp_current_ssthresh(sk);
+		tp->prior_cwnd = tp->snd_cwnd;
 		tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
 		tcp_ca_event(sk, CA_EVENT_LOSS);
 		tcp_init_undo(tp);
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
