From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 3/6] tcp: introduce tcp_under_memory_pressure()
Date: Fri, 15 May 2015 12:39:27 -0700
Message-ID: <1431718770-3815-4-git-send-email-edumazet@google.com>
References: <1431718770-3815-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:34239 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934138AbbEOTk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 15:40:29 -0400
Received: by oiax69 with SMTP id x69so6773645oia.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 12:40:28 -0700 (PDT)
In-Reply-To: <1431718770-3815-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce an optimized version of sk_under_memory_pressure()
for TCP. Our intent is to use it in fast paths.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 8 ++++++++
 net/ipv4/tcp_input.c  | 8 ++++----
 net/ipv4/tcp_output.c | 4 ++--
 net/ipv4/tcp_timer.c  | 2 +-
 4 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 841691a296dc..0d85223efa4c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -286,6 +286,14 @@ extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
 extern int tcp_memory_pressure;
 
+/* optimized version of sk_under_memory_pressure() for TCP sockets */
+static inline bool tcp_under_memory_pressure(const struct sock *sk)
+{
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		return !!sk->sk_cgrp->memory_pressure;
+
+	return tcp_memory_pressure;
+}
 /*
  * The next routines deal with comparing 32 bit unsigned ints
  * and worry about wraparound (automatic with unsigned arithmetic).
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cf8b20ff6658..093779f7e893 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -359,7 +359,7 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
-	    !sk_under_memory_pressure(sk)) {
+	    !tcp_under_memory_pressure(sk)) {
 		int incr;
 
 		/* Check #2. Increase window, if skb with such overhead
@@ -446,7 +446,7 @@ static void tcp_clamp_window(struct sock *sk)
 
 	if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
 	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
-	    !sk_under_memory_pressure(sk) &&
+	    !tcp_under_memory_pressure(sk) &&
 	    sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)) {
 		sk->sk_rcvbuf = min(atomic_read(&sk->sk_rmem_alloc),
 				    sysctl_tcp_rmem[2]);
@@ -4781,7 +4781,7 @@ static int tcp_prune_queue(struct sock *sk)
 
 	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		tcp_clamp_window(sk);
-	else if (sk_under_memory_pressure(sk))
+	else if (tcp_under_memory_pressure(sk))
 		tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
 
 	tcp_collapse_ofo_queue(sk);
@@ -4825,7 +4825,7 @@ static bool tcp_should_expand_sndbuf(const struct sock *sk)
 		return false;
 
 	/* If we are under global TCP memory pressure, do not expand.  */
-	if (sk_under_memory_pressure(sk))
+	if (tcp_under_memory_pressure(sk))
 		return false;
 
 	/* If we are under soft global TCP memory pressure, do not expand.  */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bac1a950d087..08c2cc40b26d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2392,7 +2392,7 @@ u32 __tcp_select_window(struct sock *sk)
 	if (free_space < (full_space >> 1)) {
 		icsk->icsk_ack.quick = 0;
 
-		if (sk_under_memory_pressure(sk))
+		if (tcp_under_memory_pressure(sk))
 			tp->rcv_ssthresh = min(tp->rcv_ssthresh,
 					       4U * tp->advmss);
 
@@ -2843,7 +2843,7 @@ void tcp_send_fin(struct sock *sk)
 	 * Note: in the latter case, FIN packet will be sent after a timeout,
 	 * as TCP stack thinks it has already been transmitted.
 	 */
-	if (tskb && (tcp_send_head(sk) || sk_under_memory_pressure(sk))) {
+	if (tskb && (tcp_send_head(sk) || tcp_under_memory_pressure(sk))) {
 coalesce:
 		TCP_SKB_CB(tskb)->tcp_flags |= TCPHDR_FIN;
 		TCP_SKB_CB(tskb)->end_seq++;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 65bf670e8714..5b752f58a900 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -247,7 +247,7 @@ void tcp_delack_timer_handler(struct sock *sk)
 	}
 
 out:
-	if (sk_under_memory_pressure(sk))
+	if (tcp_under_memory_pressure(sk))
 		sk_mem_reclaim(sk);
 }
 
-- 
2.2.0.rc0.207.ga3a616c
