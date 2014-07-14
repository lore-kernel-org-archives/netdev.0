From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next] tcp: Remove unnecessary arg from tcp_enter_cwr and tcp_init_cwnd_reduction
Date: Mon, 14 Jul 2014 16:58:32 +0200
Message-ID: <1405349912-9593-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37666 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829AbaGNO7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 10:59:22 -0400
Received: by mail-wi0-f182.google.com with SMTP id d1so2715987wiv.9
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 07:59:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since Yuchung's 9b44190dc11 (tcp: refactor F-RTO), tcp_enter_cwr is always
called with set_ssthresh = 1. Thus, we can remove this argument from
tcp_enter_cwr. Further, as we remove this one, tcp_init_cwnd_reduction
is then always called with set_ssthresh = true, and so we can get rid of
this argument as well.

Cc: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/net/tcp.h     |  2 +-
 net/ipv4/tcp_input.c  | 15 +++++++--------
 net/ipv4/tcp_output.c |  2 +-
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c9a75dbba0c7..0aeb2eb749dc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -928,7 +928,7 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 /* Use define here intentionally to get WARN_ON location shown at the caller */
 #define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
 
-void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
+void tcp_enter_cwr(struct sock *sk);
 __u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst);
 
 /* The maximum number of MSS of available cwnd for which TSO defers
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bb684967f7a7..2e16afba182c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2475,7 +2475,7 @@ static bool tcp_try_undo_loss(struct sock *sk, bool frto_undo)
  *	losses and/or application stalls), do not perform any further cwnd
  *	reductions, but instead slow start up to ssthresh.
  */
-static void tcp_init_cwnd_reduction(struct sock *sk, const bool set_ssthresh)
+static void tcp_init_cwnd_reduction(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2485,8 +2485,7 @@ static void tcp_init_cwnd_reduction(struct sock *sk, const bool set_ssthresh)
 	tp->prior_cwnd = tp->snd_cwnd;
 	tp->prr_delivered = 0;
 	tp->prr_out = 0;
-	if (set_ssthresh)
-		tp->snd_ssthresh = inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
+	tp->snd_ssthresh = inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
 	TCP_ECN_queue_cwr(tp);
 }
 
@@ -2528,14 +2527,14 @@ static inline void tcp_end_cwnd_reduction(struct sock *sk)
 }
 
 /* Enter CWR state. Disable cwnd undo since congestion is proven with ECN */
-void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
+void tcp_enter_cwr(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->prior_ssthresh = 0;
 	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
 		tp->undo_marker = 0;
-		tcp_init_cwnd_reduction(sk, set_ssthresh);
+		tcp_init_cwnd_reduction(sk);
 		tcp_set_ca_state(sk, TCP_CA_CWR);
 	}
 }
@@ -2564,7 +2563,7 @@ static void tcp_try_to_open(struct sock *sk, int flag, const int prior_unsacked)
 		tp->retrans_stamp = 0;
 
 	if (flag & FLAG_ECE)
-		tcp_enter_cwr(sk, 1);
+		tcp_enter_cwr(sk);
 
 	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
 		tcp_try_keep_open(sk);
@@ -2670,7 +2669,7 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
 		if (!ece_ack)
 			tp->prior_ssthresh = tcp_current_ssthresh(sk);
-		tcp_init_cwnd_reduction(sk, true);
+		tcp_init_cwnd_reduction(sk);
 	}
 	tcp_set_ca_state(sk, TCP_CA_Recovery);
 }
@@ -3346,7 +3345,7 @@ static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
 		tp->tlp_high_seq = 0;
 		/* Don't reduce cwnd if DSACK arrives for TLP retrans. */
 		if (!(flag & FLAG_DSACKING_ACK)) {
-			tcp_init_cwnd_reduction(sk, true);
+			tcp_init_cwnd_reduction(sk);
 			tcp_set_ca_state(sk, TCP_CA_CWR);
 			tcp_end_cwnd_reduction(sk);
 			tcp_try_keep_open(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bcee13c4627c..306dd5dead7d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -979,7 +979,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (likely(err <= 0))
 		return err;
 
-	tcp_enter_cwr(sk, 1);
+	tcp_enter_cwr(sk);
 
 	return net_xmit_eval(err);
 }
-- 
1.9.3
