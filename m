From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 3/5] tcp: use tcp_v4_send_synack on first SYN-ACK
Date: Sun, 11 May 2014 20:22:11 -0700
Message-ID: <1399864933-28287-4-git-send-email-ycheng@google.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
Cc: longinus00@gmail.com, hkchu@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:33063 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbaELDWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:22:51 -0400
Received: by mail-ob0-f201.google.com with SMTP id wn1so1344281obc.2
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 20:22:50 -0700 (PDT)
In-Reply-To: <1399864933-28287-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid large code duplication in IPv6, we need to first simplify
the complicate SYN-ACK sending code in tcp_v4_conn_request().

To use tcp_v4(6)_send_synack() to send all SYN-ACKs, we need to
initialize the mini socket's receive window before trying to
create the child socket and/or building the SYN-ACK packet. So we move
that initialization from tcp_make_synack() to tcp_v4_conn_request()
as a new function tcp_openreq_init_req_rwin().

After this refactoring the SYN-ACK sending code is simpler and easier
to implement Fast Open for IPv6.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Daniel Lee <longinus00@gmail.com>
Signed-off-by: Jerry Chu <hkchu@google.com>
---
 include/net/tcp.h        | 14 +++++-----
 net/ipv4/tcp_fastopen.c  | 67 ++++++++++++++++++++++--------------------------
 net/ipv4/tcp_ipv4.c      | 57 ++++++++++++----------------------------
 net/ipv4/tcp_minisocks.c | 31 ++++++++++++++++++++++
 net/ipv4/tcp_output.c    | 21 ---------------
 5 files changed, 85 insertions(+), 105 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 17d7c6a..f5d6ca4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1114,6 +1114,9 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
 }
 
+extern void tcp_openreq_init_rwin(struct request_sock *req,
+				  struct sock *sk, struct dst_entry *dst);
+
 void tcp_enter_memory_pressure(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
@@ -1323,13 +1326,10 @@ void tcp_free_fastopen_req(struct tcp_sock *tp);
 
 extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 int tcp_fastopen_reset_cipher(void *key, unsigned int len);
-int tcp_fastopen_create_child(struct sock *sk,
-			      struct sk_buff *skb,
-			      struct sk_buff *skb_synack,
-			      struct request_sock *req);
-bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
-			struct request_sock *req,
-			struct tcp_fastopen_cookie *foc);
+bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
+		      struct request_sock *req,
+		      struct tcp_fastopen_cookie *foc,
+		      struct dst_entry *dst);
 void tcp_fastopen_init_key_once(bool publish);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 5a98277..9b947a9 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -95,34 +95,22 @@ void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 	rcu_read_unlock();
 }
 
-int tcp_fastopen_create_child(struct sock *sk,
-			      struct sk_buff *skb,
-			      struct sk_buff *skb_synack,
-			      struct request_sock *req)
+static bool tcp_fastopen_create_child(struct sock *sk,
+				      struct sk_buff *skb,
+				      struct dst_entry *dst,
+				      struct request_sock *req)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
-	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct sock *child;
-	int err;
 
 	req->num_retrans = 0;
 	req->num_timeout = 0;
 	req->sk = NULL;
 
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
-	if (child == NULL) {
-		NET_INC_STATS_BH(sock_net(sk),
-				 LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
-		kfree_skb(skb_synack);
-		return -1;
-	}
-	err = ip_build_and_send_pkt(skb_synack, sk, ireq->ir_loc_addr,
-				    ireq->ir_rmt_addr, ireq->opt);
-	err = net_xmit_eval(err);
-	if (!err)
-		tcp_rsk(req)->snt_synack = tcp_time_stamp;
-	/* XXX (TFO) - is it ok to ignore error and continue? */
+	if (child == NULL)
+		return false;
 
 	spin_lock(&queue->fastopenq->lock);
 	queue->fastopenq->qlen++;
@@ -167,28 +155,24 @@ int tcp_fastopen_create_child(struct sock *sk,
 	/* Queue the data carried in the SYN packet. We need to first
 	 * bump skb's refcnt because the caller will attempt to free it.
 	 *
-	 * XXX (TFO) - we honor a zero-payload TFO request for now.
-	 * (Any reason not to?)
+	 * XXX (TFO) - we honor a zero-payload TFO request for now,
+	 * (any reason not to?) but no need to queue the skb since
+	 * there is no data. How about SYN+FIN?
 	 */
-	if (TCP_SKB_CB(skb)->end_seq == TCP_SKB_CB(skb)->seq + 1) {
-		/* Don't queue the skb if there is no payload in SYN.
-		 * XXX (TFO) - How about SYN+FIN?
-		 */
-		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-	} else {
+	if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1) {
 		skb = skb_get(skb);
 		skb_dst_drop(skb);
 		__skb_pull(skb, tcp_hdr(skb)->doff * 4);
 		skb_set_owner_r(skb, child);
 		__skb_queue_tail(&child->sk_receive_queue, skb);
-		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		tp->syn_data_acked = 1;
 	}
+	tcp_rsk(req)->rcv_nxt = tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 	sk->sk_data_ready(sk);
 	bh_unlock_sock(child);
 	sock_put(child);
 	WARN_ON(req->sk == NULL);
-	return 0;
+	return true;
 }
 EXPORT_SYMBOL(tcp_fastopen_create_child);
 
@@ -232,9 +216,10 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
  * may be updated and return the client in the SYN-ACK later. E.g., Fast Open
  * cookie request (foc->len == 0).
  */
-bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
-			struct request_sock *req,
-			struct tcp_fastopen_cookie *foc)
+bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
+		      struct request_sock *req,
+		      struct tcp_fastopen_cookie *foc,
+		      struct dst_entry *dst)
 {
 	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
@@ -255,11 +240,21 @@ bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
 	if (foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
 	    foc->len == valid_foc.len &&
 	    !memcmp(foc->val, valid_foc.val, foc->len)) {
+		/* Cookie is valid. Create a (full) child socket to accept
+		 * the data in SYN before returning a SYN-ACK to ack the
+		 * data. If we fail to create the socket, fall back and
+		 * ack the ISN only but includes the same cookie.
+		 *
+		 * Note: Data-less SYN with valid cookie is allowed to send
+		 * data in SYN_RECV state.
+		 */
 fastopen:
-		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		foc->len = -1;
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVE);
-		return true;
+		if (tcp_fastopen_create_child(sk, skb, dst, req)) {
+			foc->len = -1;
+			NET_INC_STATS_BH(sock_net(sk),
+					 LINUX_MIB_TCPFASTOPENPASSIVE);
+			return true;
+		}
 	}
 
 	NET_INC_STATS_BH(sock_net(sk), foc->len ?
@@ -268,4 +263,4 @@ fastopen:
 	*foc = valid_foc;
 	return false;
 }
-EXPORT_SYMBOL(tcp_fastopen_check);
+EXPORT_SYMBOL(tcp_try_fastopen);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5ea0949..1665f0f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -822,7 +822,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  */
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
-			      u16 queue_mapping)
+			      u16 queue_mapping,
+			      struct tcp_fastopen_cookie *foc)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
@@ -833,7 +834,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		return -1;
 
-	skb = tcp_make_synack(sk, dst, req, NULL);
+	skb = tcp_make_synack(sk, dst, req, foc);
 
 	if (skb) {
 		__tcp_v4_send_check(skb, ireq->ir_loc_addr, ireq->ir_rmt_addr);
@@ -852,7 +853,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 
 static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req)
 {
-	int res = tcp_v4_send_synack(sk, NULL, req, 0);
+	int res = tcp_v4_send_synack(sk, NULL, req, 0, NULL);
 
 	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
@@ -1270,11 +1271,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
-	bool want_cookie = false;
+	bool want_cookie = false, fastopen;
 	struct flowi4 fl4;
 	struct tcp_fastopen_cookie foc = { .len = -1 };
-	struct sk_buff *skb_synack;
-	int do_fastopen;
+	int err;
 
 	/* Never answer to SYNs send to broadcast or multicast */
 	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
@@ -1373,49 +1373,24 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 		isn = tcp_v4_init_sequence(skb);
 	}
-	tcp_rsk(req)->snt_isn = isn;
-
-	if (dst == NULL) {
-		dst = inet_csk_route_req(sk, &fl4, req);
-		if (dst == NULL)
-			goto drop_and_free;
-	}
-	do_fastopen = !want_cookie &&
-		      tcp_fastopen_check(sk, skb, req, &foc);
-
-	/* We don't call tcp_v4_send_synack() directly because we need
-	 * to make sure a child socket can be created successfully before
-	 * sending back synack!
-	 *
-	 * XXX (TFO) - Ideally one would simply call tcp_v4_send_synack()
-	 * (or better yet, call tcp_send_synack() in the child context
-	 * directly, but will have to fix bunch of other code first)
-	 * after syn_recv_sock() except one will need to first fix the
-	 * latter to remove its dependency on the current implementation
-	 * of tcp_v4_send_synack()->tcp_select_initial_window().
-	 */
-	skb_synack = tcp_make_synack(sk, dst, req, &foc);
-
-	if (skb_synack) {
-		__tcp_v4_send_check(skb_synack, ireq->ir_loc_addr, ireq->ir_rmt_addr);
-		skb_set_queue_mapping(skb_synack, skb_get_queue_mapping(skb));
-	} else
+	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		goto drop_and_free;
 
-	if (likely(!do_fastopen)) {
-		int err;
-		err = ip_build_and_send_pkt(skb_synack, sk, ireq->ir_loc_addr,
-		     ireq->ir_rmt_addr, ireq->opt);
-		err = net_xmit_eval(err);
+	tcp_rsk(req)->snt_isn = isn;
+	tcp_rsk(req)->snt_synack = tcp_time_stamp;
+	tcp_openreq_init_rwin(req, sk, dst);
+	fastopen = !want_cookie &&
+		   tcp_try_fastopen(sk, skb, req, &foc, dst);
+	err = tcp_v4_send_synack(sk, dst, req,
+				 skb_get_queue_mapping(skb), &foc);
+	if (!fastopen) {
 		if (err || want_cookie)
 			goto drop_and_free;
 
 		tcp_rsk(req)->snt_synack = tcp_time_stamp;
 		tcp_rsk(req)->listener = NULL;
-		/* Add the request_sock to the SYN table */
 		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-	} else if (tcp_fastopen_create_child(sk, skb, skb_synack, req))
-		goto drop_and_release;
+	}
 
 	return 0;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 05c1b15..e68e0d4 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -362,6 +362,37 @@ void tcp_twsk_destructor(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
 
+void tcp_openreq_init_rwin(struct request_sock *req,
+			   struct sock *sk, struct dst_entry *dst)
+{
+	struct inet_request_sock *ireq = inet_rsk(req);
+	struct tcp_sock *tp = tcp_sk(sk);
+	__u8 rcv_wscale;
+	int mss = dst_metric_advmss(dst);
+
+	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
+		mss = tp->rx_opt.user_mss;
+
+	/* Set this up on the first call only */
+	req->window_clamp = tp->window_clamp ? : dst_metric(dst, RTAX_WINDOW);
+
+	/* limit the window selection if the user enforce a smaller rx buffer */
+	if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
+	    (req->window_clamp > tcp_full_space(sk) || req->window_clamp == 0))
+		req->window_clamp = tcp_full_space(sk);
+
+	/* tcp_full_space because it is guaranteed to be the first packet */
+	tcp_select_initial_window(tcp_full_space(sk),
+		mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
+		&req->rcv_wnd,
+		&req->window_clamp,
+		ireq->wscale_ok,
+		&rcv_wscale,
+		dst_metric(dst, RTAX_INITRWND));
+	ireq->rcv_wscale = rcv_wscale;
+}
+EXPORT_SYMBOL(tcp_openreq_init_rwin);
+
 static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
 					 struct request_sock *req)
 {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 14b7981..b8ec9ec 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2803,27 +2803,6 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
 		mss = tp->rx_opt.user_mss;
 
-	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
-		__u8 rcv_wscale;
-		/* Set this up on the first call only */
-		req->window_clamp = tp->window_clamp ? : dst_metric(dst, RTAX_WINDOW);
-
-		/* limit the window selection if the user enforce a smaller rx buffer */
-		if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
-		    (req->window_clamp > tcp_full_space(sk) || req->window_clamp == 0))
-			req->window_clamp = tcp_full_space(sk);
-
-		/* tcp_full_space because it is guaranteed to be the first packet */
-		tcp_select_initial_window(tcp_full_space(sk),
-			mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
-			&req->rcv_wnd,
-			&req->window_clamp,
-			ireq->wscale_ok,
-			&rcv_wscale,
-			dst_metric(dst, RTAX_INITRWND));
-		ireq->rcv_wscale = rcv_wscale;
-	}
-
 	memset(&opts, 0, sizeof(opts));
 #ifdef CONFIG_SYN_COOKIES
 	if (unlikely(req->cookie_ts))
-- 
1.9.1.423.g4596e3a
