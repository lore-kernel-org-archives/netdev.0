From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net] tcp: add a wrapper for tcp_sock->pred_flags
Date: Tue, 14 May 2013 22:07:15 +0800
Message-ID: <9196da039b33675c3c053d934d92b9f6d2f7e197.1368540390.git.wpan@redhat.com>
Cc: Weiping Pan <panweiping3@gmail.com>, Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754624Ab3ENOHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 May 2013 10:07:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>

I think a wrapper is more meaningful here than the assignment.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 include/net/tcp.h        |    5 +++++
 net/ipv4/tcp_input.c     |   10 +++++-----
 net/ipv4/tcp_minisocks.c |    2 +-
 net/ipv4/tcp_output.c    |    2 +-
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5bba80f..75f3139 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -633,6 +633,11 @@ static inline void tcp_fast_path_check(struct sock *sk)
 		tcp_fast_path_on(tp);
 }
 
+static inline void tcp_fast_path_off(struct tcp_sock *tp)
+{
+	tp->pred_flags = 0;
+}
+
 /* Compute the actual rto_min value */
 static inline u32 tcp_rto_min(struct sock *sk)
 {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 08bbe60..b197929 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3233,7 +3233,7 @@ static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32
 			/* Note, it is the only place, where
 			 * fast path is recovered for sending TCP.
 			 */
-			tp->pred_flags = 0;
+			tcp_fast_path_off(tp);
 			tcp_fast_path_check(sk);
 
 			if (nwin > tp->max_window) {
@@ -4127,7 +4127,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* Disable header prediction. */
-	tp->pred_flags = 0;
+	tcp_fast_path_off(tp);
 	inet_csk_schedule_ack(sk);
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
@@ -4653,7 +4653,7 @@ static int tcp_prune_queue(struct sock *sk)
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_RCVPRUNED);
 
 	/* Massive buffer overcommit. */
-	tp->pred_flags = 0;
+	tcp_fast_path_off(tp);
 	return -1;
 }
 
@@ -4852,7 +4852,7 @@ static void tcp_check_urg(struct sock *sk, const struct tcphdr *th)
 	tp->urg_seq = ptr;
 
 	/* Disable header prediction. */
-	tp->pred_flags = 0;
+	tcp_fast_path_off(tp);
 }
 
 /* This is the 'fast' part of urgent handling. */
@@ -5314,7 +5314,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	if (!tp->rx_opt.snd_wscale)
 		__tcp_fast_path_on(tp, tp->snd_wnd);
 	else
-		tp->pred_flags = 0;
+		tcp_fast_path_off(tp);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		sk->sk_state_change(sk);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0f01788..716cb14 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -389,7 +389,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *newtp = tcp_sk(newsk);
 
 		/* Now setup tcp_sock */
-		newtp->pred_flags = 0;
+		tcp_fast_path_off(newtp);
 
 		newtp->rcv_wup = newtp->copied_seq =
 		newtp->rcv_nxt = treq->rcv_isn + 1;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 536d409..ce3260d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -291,7 +291,7 @@ static u16 tcp_select_window(struct sock *sk)
 
 	/* If we advertise zero window, disable fast path. */
 	if (new_win == 0)
-		tp->pred_flags = 0;
+		tcp_fast_path_off(tp);
 
 	return new_win;
 }
-- 
1.7.4.4
