From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 4/4] tcp: various missing rcu_read_lock around __sk_dst_get
Date: Fri,  1 Apr 2016 01:29:42 +0200
Message-ID: <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50973 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753684AbcCaXaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:30:00 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 269E420C35
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 19:30:00 -0400 (EDT)
In-Reply-To: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various fixes which were discovered by this changeset. More probably
to come...

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/tcp.h      |  5 ++++-
 net/core/sock.c        |  7 +++++--
 net/ipv4/tcp_input.c   | 18 ++++++++++++++----
 net/ipv4/tcp_metrics.c | 12 +++++-------
 net/ipv4/tcp_output.c  | 22 ++++++++++++++++++++--
 5 files changed, 48 insertions(+), 16 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b91370f61be64a..541c99bf633d4b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -647,11 +647,14 @@ static inline void tcp_fast_path_check(struct sock *sk)
 /* Compute the actual rto_min value */
 static inline u32 tcp_rto_min(struct sock *sk)
 {
-	const struct dst_entry *dst = __sk_dst_get(sk);
+	const struct dst_entry *dst;
 	u32 rto_min = TCP_RTO_MIN;
 
+	rcu_read_lock();
+	dst = __sk_dst_get(sk);
 	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
 		rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
+	rcu_read_unlock();
 	return rto_min;
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index b67b9aedb230f9..963d0ba7aa4232 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -486,14 +486,17 @@ EXPORT_SYMBOL(sk_receive_skb);
 
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst;
 
+	rcu_read_lock();
+	dst = __sk_dst_get(sk);
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
 		sk_tx_queue_clear(sk);
 		RCU_INIT_POINTER(sk->sk_dst_cache, NULL);
 		dst_release(dst);
-		return NULL;
+		dst = NULL;
 	}
+	rcu_read_unlock();
 
 	return dst;
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e6e65f79ade821..8489e9e45f906c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -203,10 +203,16 @@ static void tcp_enter_quickack_mode(struct sock *sk)
 static bool tcp_in_quickack_mode(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	const struct dst_entry *dst = __sk_dst_get(sk);
+	const struct dst_entry *dst;
+	bool ret;
 
-	return (dst && dst_metric(dst, RTAX_QUICKACK)) ||
-		(icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong);
+	rcu_read_lock();
+	dst = __sk_dst_get(sk);
+	ret = (dst && dst_metric(dst, RTAX_QUICKACK)) ||
+	      (icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong);
+	rcu_read_unlock();
+
+	return ret;
 }
 
 static void tcp_ecn_queue_cwr(struct tcp_sock *tp)
@@ -3674,9 +3680,13 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		tcp_process_tlp_ack(sk, ack, flag);
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
-		struct dst_entry *dst = __sk_dst_get(sk);
+		struct dst_entry *dst;
+
+		rcu_read_lock();
+		dst = __sk_dst_get(sk);
 		if (dst)
 			dst_confirm(dst);
+		rcu_read_unlock();
 	}
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS)
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 7b7eec43990692..33a36648423e8b 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -488,22 +488,20 @@ out_unlock:
 
 void tcp_init_metrics(struct sock *sk)
 {
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_metrics_block *tm;
 	u32 val, crtt = 0; /* cached RTT scaled by 8 */
 
+	rcu_read_lock();
+	dst = __sk_dst_get(sk);
 	if (!dst)
 		goto reset;
-
 	dst_confirm(dst);
 
-	rcu_read_lock();
 	tm = tcp_get_metrics(sk, dst, true);
-	if (!tm) {
-		rcu_read_unlock();
+	if (!tm)
 		goto reset;
-	}
 
 	if (tcp_metric_locked(tm, TCP_METRIC_CWND))
 		tp->snd_cwnd_clamp = tcp_metric_get(tm, TCP_METRIC_CWND);
@@ -527,7 +525,6 @@ void tcp_init_metrics(struct sock *sk)
 	}
 
 	crtt = tcp_metric_get(tm, TCP_METRIC_RTT);
-	rcu_read_unlock();
 reset:
 	/* The initial RTT measurement from the SYN/SYN-ACK is not ideal
 	 * to seed the RTO for later data packets because SYN packets are
@@ -575,6 +572,7 @@ reset:
 	else
 		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
+	rcu_read_unlock();
 }
 
 bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7d2dc015cd19a6..ba3621834e7bfa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -548,6 +548,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	struct tcp_fastopen_request *fastopen = tp->fastopen_req;
 
 #ifdef CONFIG_TCP_MD5SIG
+	rcu_read_lock();
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
 	if (*md5) {
 		opts->options |= OPTION_MD5;
@@ -601,6 +602,10 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		}
 	}
 
+#ifdef CONFIG_TCP_MD5SIG
+	rcu_read_unlock();
+#endif
+
 	return MAX_TCP_OPTION_SPACE - remaining;
 }
 
@@ -928,6 +933,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
+#ifdef CONFIG_TCP_MD5SIG
+	rcu_read_lock();
+#endif
+
 	if (unlikely(tcb->tcp_flags & TCPHDR_SYN))
 		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
 	else
@@ -996,6 +1005,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tp->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, sk, skb);
 	}
+	rcu_read_unlock();
 #endif
 
 	icsk->icsk_af_ops->send_check(sk, skb);
@@ -1294,10 +1304,13 @@ static inline int __tcp_mtu_to_mss(struct sock *sk, int pmtu)
 
 	/* IPv6 adds a frag_hdr in case RTAX_FEATURE_ALLFRAG is set */
 	if (icsk->icsk_af_ops->net_frag_header_len) {
-		const struct dst_entry *dst = __sk_dst_get(sk);
+		const struct dst_entry *dst;
 
+		rcu_read_lock();
+		dst = __sk_dst_get(sk);
 		if (dst && dst_allfrag(dst))
 			mss_now -= icsk->icsk_af_ops->net_frag_header_len;
+		rcu_read_unlock();
 	}
 
 	/* Clamp it (mss_clamp does not include tcp options) */
@@ -1335,10 +1348,13 @@ int tcp_mss_to_mtu(struct sock *sk, int mss)
 
 	/* IPv6 adds a frag_hdr in case RTAX_FEATURE_ALLFRAG is set */
 	if (icsk->icsk_af_ops->net_frag_header_len) {
-		const struct dst_entry *dst = __sk_dst_get(sk);
+		const struct dst_entry *dst;
 
+		rcu_read_lock();
+		dst = __sk_dst_get(sk);
 		if (dst && dst_allfrag(dst))
 			mtu += icsk->icsk_af_ops->net_frag_header_len;
+		rcu_read_unlock();
 	}
 	return mtu;
 }
@@ -1424,8 +1440,10 @@ unsigned int tcp_current_mss(struct sock *sk)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
+	rcu_read_lock();
 	header_len = tcp_established_options(sk, NULL, &opts, &md5) +
 		     sizeof(struct tcphdr);
+	rcu_read_unlock();
 	/* The mss_cache is sized based on tp->tcp_header_len, which assumes
 	 * some common options. If this is an odd packet (because we have SACK
 	 * blocks etc) then our calculated header_len will be different, and
-- 
2.5.5
