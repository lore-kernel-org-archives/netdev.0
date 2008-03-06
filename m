From: Patrick McManus <mcmanus@ducksong.com>
Subject: [PATCH 3/3 (spin 3) resend] TCP_DEFER_ACCEPT updates - process as
	established
Date: Thu, 06 Mar 2008 18:54:29 -0500
Message-ID: <1204847669.17097.23.camel@tng>
References: <1204847472.17097.17.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:59459 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759680AbYCFXyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:54:14 -0500
Received: from [192.168.16.214] (cpe-76-179-219-229.maine.res.rr.com [76.179.219.229])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linode.ducksong.com (Postfix) with ESMTP id 6AAB010162
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 18:54:12 -0500 (EST)
In-Reply-To: <1204847472.17097.17.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4a234b7dd1a5144fe5630f1b0739e3c8c28de2ed
Author: Patrick McManus <mcmanus@ducksong.com>
Date:   Sun Mar 2 16:52:37 2008 -0500

    Change TCP_DEFER_ACCEPT implementation so that it transitions a
    connection to ESTABLISHED after handshake is complete instead of
    leaving it in SYN-RECV until some data arrvies. Place connection in
    accept queue when first data packet arrives from slow path.
    
    Benefits:
      - established connection is now reset if it never makes it
       to the accept queue
    
     - diagnostic state of established matches with the packet traces
       showing completed handshake
    
     - TCP_DEFER_ACCEPT timeouts are expressed in seconds and can now be
       enforced with reasonable accuracy instead of rounding up to next
       exponential back-off of syn-ack retry.
    
    Signed-off-by: Patrick McManus <mcmanus@ducksong.com>

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 08027f1..d96d9b1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -239,6 +239,11 @@ static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
 	return (struct tcp_request_sock *)req;
 }
 
+struct tcp_deferred_accept_info {
+	struct sock *listen_sk;
+	struct request_sock *request;
+};
+
 struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
@@ -374,6 +379,8 @@ struct tcp_sock {
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 	int			linger2;
 
+	struct tcp_deferred_accept_info defer_tcp_accept;
+
 	unsigned long last_synq_overflow; 
 
 	u32	tso_deferred;
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index cff4608..389abc4 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -116,8 +116,8 @@ struct request_sock_queue {
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
 	rwlock_t		syn_wait_lock;
-	u8			rskq_defer_accept;
-	/* 3 bytes hole, try to pack */
+	u16			rskq_defer_accept;
+	/* 2 bytes hole, try to pack */
 	struct listen_sock	*listen_opt;
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7de4ea3..5780f62 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -138,6 +138,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define MAX_TCP_KEEPINTVL	32767
 #define MAX_TCP_KEEPCNT		127
 #define MAX_TCP_SYNCNT		127
+#define MAX_TCP_ACCEPT_DEFERRED 65535
 
 #define TCP_SYNQ_INTERVAL	(HZ/5)	/* Period of SYNACK timer */
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3380d04..9323405 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -414,8 +414,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 	struct inet_connection_sock *icsk = inet_csk(parent);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
 	struct listen_sock *lopt = queue->listen_opt;
-	int max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
-	int thresh = max_retries;
+	int thresh = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
 	unsigned long now = jiffies;
 	struct request_sock **reqp, *req;
 	int i, budget;
@@ -451,9 +450,6 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		}
 	}
 
-	if (queue->rskq_defer_accept)
-		max_retries = queue->rskq_defer_accept;
-
 	budget = 2 * (lopt->nr_table_entries / (timeout / interval));
 	i = lopt->clock_hand;
 
@@ -461,9 +457,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh)) &&
-				    (inet_rsk(req)->acked ||
-				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
+				if (req->retrans < thresh &&
+				    !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 071e83a..e0fbc25 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2105,15 +2105,12 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		break;
 
 	case TCP_DEFER_ACCEPT:
-		icsk->icsk_accept_queue.rskq_defer_accept = 0;
-		if (val > 0) {
-			/* Translate value in seconds to number of
-			 * retransmits */
-			while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
-			       val > ((TCP_TIMEOUT_INIT / HZ) <<
-				       icsk->icsk_accept_queue.rskq_defer_accept))
-				icsk->icsk_accept_queue.rskq_defer_accept++;
-			icsk->icsk_accept_queue.rskq_defer_accept++;
+		if (val < 0) {
+			err = -EINVAL;
+		} else {
+			if (val > MAX_TCP_ACCEPT_DEFERRED)
+				val = MAX_TCP_ACCEPT_DEFERRED;
+			icsk->icsk_accept_queue.rskq_defer_accept = val;
 		}
 		break;
 
@@ -2295,8 +2292,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 			val = (val ? : sysctl_tcp_fin_timeout) / HZ;
 		break;
 	case TCP_DEFER_ACCEPT:
-		val = !icsk->icsk_accept_queue.rskq_defer_accept ? 0 :
-			((TCP_TIMEOUT_INIT / HZ) << (icsk->icsk_accept_queue.rskq_defer_accept - 1));
+		val = icsk->icsk_accept_queue.rskq_defer_accept;
 		break;
 	case TCP_WINDOW_CLAMP:
 		val = tp->window_clamp;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7facdb0..b16714f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4451,6 +4451,49 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
 	}
 }
 
+static int tcp_defer_accept_check(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (tp->defer_tcp_accept.request) {
+		int queued_data =  tp->rcv_nxt - tp->copied_seq;
+		int hasfin =  !skb_queue_empty(&sk->sk_receive_queue) ?
+			tcp_hdr((struct sk_buff *)
+				sk->sk_receive_queue.prev)->fin : 0;
+
+		if (queued_data && hasfin)
+			queued_data--;
+
+		if (queued_data &&
+		    tp->defer_tcp_accept.listen_sk->sk_state == TCP_LISTEN) {
+			if (sock_flag(sk, SOCK_KEEPOPEN)) {
+				inet_csk_reset_keepalive_timer(sk,
+							       keepalive_time_when(tp));
+			} else {
+				inet_csk_delete_keepalive_timer(sk);
+			}
+
+			inet_csk_reqsk_queue_add(
+				tp->defer_tcp_accept.listen_sk,
+				tp->defer_tcp_accept.request,
+				sk);
+
+			tp->defer_tcp_accept.listen_sk->sk_data_ready(
+				tp->defer_tcp_accept.listen_sk, 0);
+
+			sock_put(tp->defer_tcp_accept.listen_sk);
+			sock_put(sk);
+			tp->defer_tcp_accept.listen_sk = NULL;
+			tp->defer_tcp_accept.request = NULL;
+		} else if (hasfin ||
+			   tp->defer_tcp_accept.listen_sk->sk_state != TCP_LISTEN) {
+			tcp_reset(sk);
+			return -1;
+		}
+	}
+	return 0;
+}
+
 static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -4811,6 +4854,9 @@ step5:
 
 	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
+
+	if (tcp_defer_accept_check(sk))
+		return -1;
 	return 0;
 
 csum_error:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00156bf..d4c9d03 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1921,6 +1921,14 @@ int tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+	if (tp->defer_tcp_accept.request) {
+		reqsk_free(tp->defer_tcp_accept.request);
+		sock_put(tp->defer_tcp_accept.listen_sk);
+		sock_put(sk);
+		tp->defer_tcp_accept.listen_sk = NULL;
+		tp->defer_tcp_accept.request = NULL;
+	}
+
 	atomic_dec(&tcp_sockets_allocated);
 
 	return 0;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b61b768..ab519d8 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -569,10 +569,8 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 	   does sequence test, SYN is truncated, and thus we consider
 	   it a bare ACK.
 
-	   If icsk->icsk_accept_queue.rskq_defer_accept, we silently drop this
-	   bare ACK.  Otherwise, we create an established connection.  Both
-	   ends (listening sockets) accept the new incoming connection and try
-	   to talk to each other. 8-)
+	   Both ends (listening sockets) accept the new incoming
+	   connection and try to talk to each other. 8-)
 
 	   Note: This case is both harmless, and rare.  Possibility is about the
 	   same as us discovering intelligent life on another plant tomorrow.
@@ -640,13 +638,6 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		if (!(flg & TCP_FLAG_ACK))
 			return NULL;
 
-		/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
-		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
-		    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
-			inet_rsk(req)->acked = 1;
-			return NULL;
-		}
-
 		/* OK, ACK is valid, create big socket and
 		 * feed this segment to it. It will repeat all
 		 * the tests. THIS SEGMENT MUST MOVE SOCKET TO
@@ -685,7 +676,24 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		inet_csk_reqsk_queue_unlink(sk, req, prev);
 		inet_csk_reqsk_queue_removed(sk, req);
 
-		inet_csk_reqsk_queue_add(sk, req, child);
+		if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+		    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
+
+			/* the accept queue handling is done is est recv slow
+			 * path so lets make sure to start there
+			 */
+			tcp_sk(child)->pred_flags = 0;
+			sock_hold(sk);
+			sock_hold(child);
+			tcp_sk(child)->defer_tcp_accept.listen_sk = sk;
+			tcp_sk(child)->defer_tcp_accept.request = req;
+
+			inet_csk_reset_keepalive_timer(child,
+						       inet_csk(sk)->icsk_accept_queue.rskq_defer_accept * HZ);
+		} else {
+			inet_csk_reqsk_queue_add(sk, req, child);
+		}
+
 		return child;
 
 	listen_overflow:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 803d758..160d16f 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -481,6 +481,11 @@ static void tcp_keepalive_timer (unsigned long data)
 		goto death;
 	}
 
+	if (tp->defer_tcp_accept.request && sk->sk_state == TCP_ESTABLISHED) {
+		tcp_send_active_reset(sk, GFP_ATOMIC);
+		goto death;
+	}
+
 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
 		goto out;
 


