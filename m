From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 1/5] tcp: move fastopen functions to tcp_fastopen.c
Date: Sun, 11 May 2014 20:22:09 -0700
Message-ID: <1399864933-28287-2-git-send-email-ycheng@google.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
Cc: longinus00@gmail.com, hkchu@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:48287 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaELDWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:22:51 -0400
Received: by mail-ob0-f202.google.com with SMTP id wm4so1343488obc.1
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 20:22:50 -0700 (PDT)
In-Reply-To: <1399864933-28287-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move common TFO functions that will be used by both v4 and v6
to tcp_fastopen.c. Create a helper tcp_fastopen_queue_check().

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Daniel Lee <longinus00@gmail.com>
Signed-off-by: Jerry Chu <hkchu@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h       |  10 ++-
 net/ipv4/tcp_fastopen.c | 190 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c     | 185 +---------------------------------------------
 3 files changed, 200 insertions(+), 185 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3c94184..0122368 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1329,8 +1329,14 @@ void tcp_free_fastopen_req(struct tcp_sock *tp);
 
 extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 int tcp_fastopen_reset_cipher(void *key, unsigned int len);
-void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
-			     struct tcp_fastopen_cookie *foc);
+int tcp_fastopen_create_child(struct sock *sk,
+			      struct sk_buff *skb,
+			      struct sk_buff *skb_synack,
+			      struct request_sock *req);
+bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
+			struct request_sock *req,
+			struct tcp_fastopen_cookie *foc,
+			struct tcp_fastopen_cookie *valid_foc);
 void tcp_fastopen_init_key_once(bool publish);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index f195d93..0606c91 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -94,3 +94,193 @@ void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 	}
 	rcu_read_unlock();
 }
+
+int tcp_fastopen_create_child(struct sock *sk,
+			      struct sk_buff *skb,
+			      struct sk_buff *skb_synack,
+			      struct request_sock *req)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
+	const struct inet_request_sock *ireq = inet_rsk(req);
+	struct sock *child;
+	int err;
+
+	req->num_retrans = 0;
+	req->num_timeout = 0;
+	req->sk = NULL;
+
+	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
+	if (child == NULL) {
+		NET_INC_STATS_BH(sock_net(sk),
+				 LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
+		kfree_skb(skb_synack);
+		return -1;
+	}
+	err = ip_build_and_send_pkt(skb_synack, sk, ireq->ir_loc_addr,
+				    ireq->ir_rmt_addr, ireq->opt);
+	err = net_xmit_eval(err);
+	if (!err)
+		tcp_rsk(req)->snt_synack = tcp_time_stamp;
+	/* XXX (TFO) - is it ok to ignore error and continue? */
+
+	spin_lock(&queue->fastopenq->lock);
+	queue->fastopenq->qlen++;
+	spin_unlock(&queue->fastopenq->lock);
+
+	/* Initialize the child socket. Have to fix some values to take
+	 * into account the child is a Fast Open socket and is created
+	 * only out of the bits carried in the SYN packet.
+	 */
+	tp = tcp_sk(child);
+
+	tp->fastopen_rsk = req;
+	/* Do a hold on the listner sk so that if the listener is being
+	 * closed, the child that has been accepted can live on and still
+	 * access listen_lock.
+	 */
+	sock_hold(sk);
+	tcp_rsk(req)->listener = sk;
+
+	/* RFC1323: The window in SYN & SYN/ACK segments is never
+	 * scaled. So correct it appropriately.
+	 */
+	tp->snd_wnd = ntohs(tcp_hdr(skb)->window);
+
+	/* Activate the retrans timer so that SYNACK can be retransmitted.
+	 * The request socket is not added to the SYN table of the parent
+	 * because it's been added to the accept queue directly.
+	 */
+	inet_csk_reset_xmit_timer(child, ICSK_TIME_RETRANS,
+				  TCP_TIMEOUT_INIT, TCP_RTO_MAX);
+
+	/* Add the child socket directly into the accept queue */
+	inet_csk_reqsk_queue_add(sk, req, child);
+
+	/* Now finish processing the fastopen child socket. */
+	inet_csk(child)->icsk_af_ops->rebuild_header(child);
+	tcp_init_congestion_control(child);
+	tcp_mtup_init(child);
+	tcp_init_metrics(child);
+	tcp_init_buffer_space(child);
+
+	/* Queue the data carried in the SYN packet. We need to first
+	 * bump skb's refcnt because the caller will attempt to free it.
+	 *
+	 * XXX (TFO) - we honor a zero-payload TFO request for now.
+	 * (Any reason not to?)
+	 */
+	if (TCP_SKB_CB(skb)->end_seq == TCP_SKB_CB(skb)->seq + 1) {
+		/* Don't queue the skb if there is no payload in SYN.
+		 * XXX (TFO) - How about SYN+FIN?
+		 */
+		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+	} else {
+		skb = skb_get(skb);
+		skb_dst_drop(skb);
+		__skb_pull(skb, tcp_hdr(skb)->doff * 4);
+		skb_set_owner_r(skb, child);
+		__skb_queue_tail(&child->sk_receive_queue, skb);
+		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		tp->syn_data_acked = 1;
+	}
+	sk->sk_data_ready(sk);
+	bh_unlock_sock(child);
+	sock_put(child);
+	WARN_ON(req->sk == NULL);
+	return 0;
+}
+EXPORT_SYMBOL(tcp_fastopen_create_child);
+
+static bool tcp_fastopen_queue_check(struct sock *sk)
+{
+	struct fastopen_queue *fastopenq;
+
+	/* Make sure the listener has enabled fastopen, and we don't
+	 * exceed the max # of pending TFO requests allowed before trying
+	 * to validating the cookie in order to avoid burning CPU cycles
+	 * unnecessarily.
+	 *
+	 * XXX (TFO) - The implication of checking the max_qlen before
+	 * processing a cookie request is that clients can't differentiate
+	 * between qlen overflow causing Fast Open to be disabled
+	 * temporarily vs a server not supporting Fast Open at all.
+	 */
+	fastopenq = inet_csk(sk)->icsk_accept_queue.fastopenq;
+	if (fastopenq == NULL || fastopenq->max_qlen == 0)
+		return false;
+
+	if (fastopenq->qlen >= fastopenq->max_qlen) {
+		struct request_sock *req1;
+		spin_lock(&fastopenq->lock);
+		req1 = fastopenq->rskq_rst_head;
+		if ((req1 == NULL) || time_after(req1->expires, jiffies)) {
+			spin_unlock(&fastopenq->lock);
+			NET_INC_STATS_BH(sock_net(sk),
+					 LINUX_MIB_TCPFASTOPENLISTENOVERFLOW);
+			return false;
+		}
+		fastopenq->rskq_rst_head = req1->dl_next;
+		fastopenq->qlen--;
+		spin_unlock(&fastopenq->lock);
+		reqsk_free(req1);
+	}
+	return true;
+}
+
+bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
+			struct request_sock *req,
+			struct tcp_fastopen_cookie *foc,
+			struct tcp_fastopen_cookie *valid_foc)
+{
+	bool skip_cookie = false;
+
+	if (likely(!fastopen_cookie_present(foc))) {
+		/* See include/net/tcp.h for the meaning of these knobs */
+		if ((sysctl_tcp_fastopen & TFO_SERVER_ALWAYS) ||
+		    ((sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD) &&
+		    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1)))
+			skip_cookie = true; /* no cookie to validate */
+		else
+			return false;
+	}
+	/* A FO option is present; bump the counter. */
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVE);
+
+	if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) == 0 ||
+	    !tcp_fastopen_queue_check(sk))
+		return false;
+
+	if (skip_cookie) {
+		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		return true;
+	}
+
+	if (foc->len == TCP_FASTOPEN_COOKIE_SIZE) {
+		if ((sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_CHKED) == 0) {
+			tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
+						ip_hdr(skb)->daddr, valid_foc);
+			if ((valid_foc->len != TCP_FASTOPEN_COOKIE_SIZE) ||
+			    memcmp(&foc->val[0], &valid_foc->val[0],
+			    TCP_FASTOPEN_COOKIE_SIZE) != 0)
+				return false;
+			valid_foc->len = -1;
+		}
+		/* Acknowledge the data received from the peer. */
+		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		return true;
+	} else if (foc->len == 0) { /* Client requesting a cookie */
+		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
+					ip_hdr(skb)->daddr, valid_foc);
+		NET_INC_STATS_BH(sock_net(sk),
+		    LINUX_MIB_TCPFASTOPENCOOKIEREQD);
+	} else {
+		/* Client sent a cookie with wrong size. Treat it
+		 * the same as invalid and return a valid one.
+		 */
+		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
+					ip_hdr(skb)->daddr, valid_foc);
+	}
+	return false;
+}
+EXPORT_SYMBOL(tcp_fastopen_check);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ad166dc..032fcae 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1260,187 +1260,6 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 };
 #endif
 
-static bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
-			       struct request_sock *req,
-			       struct tcp_fastopen_cookie *foc,
-			       struct tcp_fastopen_cookie *valid_foc)
-{
-	bool skip_cookie = false;
-	struct fastopen_queue *fastopenq;
-
-	if (likely(!fastopen_cookie_present(foc))) {
-		/* See include/net/tcp.h for the meaning of these knobs */
-		if ((sysctl_tcp_fastopen & TFO_SERVER_ALWAYS) ||
-		    ((sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD) &&
-		    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1)))
-			skip_cookie = true; /* no cookie to validate */
-		else
-			return false;
-	}
-	fastopenq = inet_csk(sk)->icsk_accept_queue.fastopenq;
-	/* A FO option is present; bump the counter. */
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVE);
-
-	/* Make sure the listener has enabled fastopen, and we don't
-	 * exceed the max # of pending TFO requests allowed before trying
-	 * to validating the cookie in order to avoid burning CPU cycles
-	 * unnecessarily.
-	 *
-	 * XXX (TFO) - The implication of checking the max_qlen before
-	 * processing a cookie request is that clients can't differentiate
-	 * between qlen overflow causing Fast Open to be disabled
-	 * temporarily vs a server not supporting Fast Open at all.
-	 */
-	if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) == 0 ||
-	    fastopenq == NULL || fastopenq->max_qlen == 0)
-		return false;
-
-	if (fastopenq->qlen >= fastopenq->max_qlen) {
-		struct request_sock *req1;
-		spin_lock(&fastopenq->lock);
-		req1 = fastopenq->rskq_rst_head;
-		if ((req1 == NULL) || time_after(req1->expires, jiffies)) {
-			spin_unlock(&fastopenq->lock);
-			NET_INC_STATS_BH(sock_net(sk),
-			    LINUX_MIB_TCPFASTOPENLISTENOVERFLOW);
-			/* Avoid bumping LINUX_MIB_TCPFASTOPENPASSIVEFAIL*/
-			foc->len = -1;
-			return false;
-		}
-		fastopenq->rskq_rst_head = req1->dl_next;
-		fastopenq->qlen--;
-		spin_unlock(&fastopenq->lock);
-		reqsk_free(req1);
-	}
-	if (skip_cookie) {
-		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		return true;
-	}
-
-	if (foc->len == TCP_FASTOPEN_COOKIE_SIZE) {
-		if ((sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_CHKED) == 0) {
-			tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
-						ip_hdr(skb)->daddr, valid_foc);
-			if ((valid_foc->len != TCP_FASTOPEN_COOKIE_SIZE) ||
-			    memcmp(&foc->val[0], &valid_foc->val[0],
-			    TCP_FASTOPEN_COOKIE_SIZE) != 0)
-				return false;
-			valid_foc->len = -1;
-		}
-		/* Acknowledge the data received from the peer. */
-		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		return true;
-	} else if (foc->len == 0) { /* Client requesting a cookie */
-		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
-					ip_hdr(skb)->daddr, valid_foc);
-		NET_INC_STATS_BH(sock_net(sk),
-		    LINUX_MIB_TCPFASTOPENCOOKIEREQD);
-	} else {
-		/* Client sent a cookie with wrong size. Treat it
-		 * the same as invalid and return a valid one.
-		 */
-		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
-					ip_hdr(skb)->daddr, valid_foc);
-	}
-	return false;
-}
-
-static int tcp_v4_conn_req_fastopen(struct sock *sk,
-				    struct sk_buff *skb,
-				    struct sk_buff *skb_synack,
-				    struct request_sock *req)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
-	const struct inet_request_sock *ireq = inet_rsk(req);
-	struct sock *child;
-	int err;
-
-	req->num_retrans = 0;
-	req->num_timeout = 0;
-	req->sk = NULL;
-
-	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
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
-
-	spin_lock(&queue->fastopenq->lock);
-	queue->fastopenq->qlen++;
-	spin_unlock(&queue->fastopenq->lock);
-
-	/* Initialize the child socket. Have to fix some values to take
-	 * into account the child is a Fast Open socket and is created
-	 * only out of the bits carried in the SYN packet.
-	 */
-	tp = tcp_sk(child);
-
-	tp->fastopen_rsk = req;
-	/* Do a hold on the listner sk so that if the listener is being
-	 * closed, the child that has been accepted can live on and still
-	 * access listen_lock.
-	 */
-	sock_hold(sk);
-	tcp_rsk(req)->listener = sk;
-
-	/* RFC1323: The window in SYN & SYN/ACK segments is never
-	 * scaled. So correct it appropriately.
-	 */
-	tp->snd_wnd = ntohs(tcp_hdr(skb)->window);
-
-	/* Activate the retrans timer so that SYNACK can be retransmitted.
-	 * The request socket is not added to the SYN table of the parent
-	 * because it's been added to the accept queue directly.
-	 */
-	inet_csk_reset_xmit_timer(child, ICSK_TIME_RETRANS,
-	    TCP_TIMEOUT_INIT, TCP_RTO_MAX);
-
-	/* Add the child socket directly into the accept queue */
-	inet_csk_reqsk_queue_add(sk, req, child);
-
-	/* Now finish processing the fastopen child socket. */
-	inet_csk(child)->icsk_af_ops->rebuild_header(child);
-	tcp_init_congestion_control(child);
-	tcp_mtup_init(child);
-	tcp_init_metrics(child);
-	tcp_init_buffer_space(child);
-
-	/* Queue the data carried in the SYN packet. We need to first
-	 * bump skb's refcnt because the caller will attempt to free it.
-	 *
-	 * XXX (TFO) - we honor a zero-payload TFO request for now.
-	 * (Any reason not to?)
-	 */
-	if (TCP_SKB_CB(skb)->end_seq == TCP_SKB_CB(skb)->seq + 1) {
-		/* Don't queue the skb if there is no payload in SYN.
-		 * XXX (TFO) - How about SYN+FIN?
-		 */
-		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-	} else {
-		skb = skb_get(skb);
-		skb_dst_drop(skb);
-		__skb_pull(skb, tcp_hdr(skb)->doff * 4);
-		skb_set_owner_r(skb, child);
-		__skb_queue_tail(&child->sk_receive_queue, skb);
-		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		tp->syn_data_acked = 1;
-	}
-	sk->sk_data_ready(sk);
-	bh_unlock_sock(child);
-	sock_put(child);
-	WARN_ON(req->sk == NULL);
-	return 0;
-}
-
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tmp_opt;
@@ -1599,8 +1418,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (fastopen_cookie_present(&foc) && foc.len != 0)
 			NET_INC_STATS_BH(sock_net(sk),
 			    LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
-	} else if (tcp_v4_conn_req_fastopen(sk, skb, skb_synack, req))
-		goto drop_and_free;
+	} else if (tcp_fastopen_create_child(sk, skb, skb_synack, req))
+		goto drop_and_release;
 
 	return 0;
 
-- 
1.9.1.423.g4596e3a
