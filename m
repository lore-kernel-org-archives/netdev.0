From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH v2 net-next 1/4] tcp: consolidate SYNACK RTT sampling
Date: Mon, 22 Jul 2013 16:20:45 -0700
Message-ID: <1374535248-27418-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:64494 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303Ab3GVXVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 19:21:03 -0400
Received: by mail-vb0-f74.google.com with SMTP id w16so645029vbb.5
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 16:21:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series improve RTT sampling in three ways:
1. Sample RTT during fast recovery and reordering events.
2. Favor ack-based RTT to timestamps because of broken TS ECR fields
3. Consolidate the RTT measurement logic.

The first patch consolidates SYNACK and other RTT measurement to use a
central function tcp_ack_update_rtt(). A (small) bonus is now SYNACK
RTT measurement happens after PAWS check, potentially reducing the
impact of RTO seeding on bad TCP timestamps values.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
ChangeLog in v2:
	fix not calling tcp_synack_rtt_meas on regular TCP

 include/net/tcp.h        |  9 ---------
 net/ipv4/tcp_input.c     | 14 ++++++++++++--
 net/ipv4/tcp_ipv4.c      |  2 --
 net/ipv4/tcp_minisocks.c |  8 ++------
 net/ipv6/tcp_ipv6.c      |  2 --
 5 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d198005..f9777db 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1094,15 +1094,6 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->loc_port = tcp_hdr(skb)->dest;
 }
 
-/* Compute time elapsed between SYNACK and the ACK completing 3WHS */
-static inline void tcp_synack_rtt_meas(struct sock *sk,
-				       struct request_sock *req)
-{
-	if (tcp_rsk(req)->snt_synack)
-		tcp_valid_rtt_meas(sk,
-		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
-}
-
 extern void tcp_enter_memory_pressure(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28af45a..b531710 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2853,6 +2853,17 @@ static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
 		tcp_ack_no_tstamp(sk, seq_rtt, flag);
 }
 
+/* Compute time elapsed between (last) SYNACK and the ACK completing 3WHS. */
+static void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	s32 seq_rtt = -1;
+
+	if (tp->lsndtime && !tp->total_retrans)
+		seq_rtt = tcp_time_stamp - tp->lsndtime;
+	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt);
+}
+
 static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -5624,9 +5635,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		 * so release it.
 		 */
 		if (req) {
-			tcp_synack_rtt_meas(sk, req);
 			tp->total_retrans = req->num_retrans;
-
 			reqsk_fastopen_remove(sk, req, false);
 		} else {
 			/* Make sure socket is routed, for correct metrics. */
@@ -5651,6 +5660,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
 		tp->snd_wnd = ntohs(th->window) << tp->rx_opt.snd_wscale;
 		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
+		tcp_synack_rtt_meas(sk, req);
 
 		if (tp->rx_opt.tstamp_ok)
 			tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b299da5..2e3f129 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1671,8 +1671,6 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
 
 	tcp_initialize_rcv_mss(newsk);
-	tcp_synack_rtt_meas(newsk, req);
-	newtp->total_retrans = req->num_retrans;
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index ab1c086..58a3e69 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -411,6 +411,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 		tcp_enable_early_retrans(newtp);
 		newtp->tlp_high_seq = 0;
+		newtp->lsndtime = treq->snt_synack;
+		newtp->total_retrans = req->num_retrans;
 
 		/* So many TCP implementations out there (incorrectly) count the
 		 * initial SYN frame in their delayed-ACK and congestion control
@@ -666,12 +668,6 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (!(flg & TCP_FLAG_ACK))
 		return NULL;
 
-	/* Got ACK for our SYNACK, so update baseline for SYNACK RTT sample. */
-	if (tmp_opt.saw_tstamp && tmp_opt.rcv_tsecr)
-		tcp_rsk(req)->snt_synack = tmp_opt.rcv_tsecr;
-	else if (req->num_retrans) /* don't take RTT sample if retrans && ~TS */
-		tcp_rsk(req)->snt_synack = 0;
-
 	/* For Fast Open no more processing is needed (sk is the
 	 * child socket).
 	 */
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6e1649d..80fe69e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1237,8 +1237,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
 
 	tcp_initialize_rcv_mss(newsk);
-	tcp_synack_rtt_meas(newsk, req);
-	newtp->total_retrans = req->num_retrans;
 
 	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
 	newinet->inet_rcv_saddr = LOOPBACK4_IPV6;
-- 
1.8.3
