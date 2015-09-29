From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 14/14] tcp: prepare fastopen code for upcoming listener changes
Date: Tue, 29 Sep 2015 07:42:52 -0700
Message-ID: <1443537772-15305-15-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35718 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995AbbI2OsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:48:00 -0400
Received: by pacfv12 with SMTP id fv12so8538312pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:47:59 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While auditing TCP stack for upcoming 'lockless' listener changes,
I found I had to change fastopen_init_queue() to properly init the object
before publishing it.

Otherwise an other cpu could try to lock the spinlock before it gets
properly initialized.

Instead of adding appropriate barriers, just remove dynamic memory
allocations :
- Structure is 28 bytes on 64bit arches. Using additional 8 bytes
  for holding a pointer seems overkill.
- Two listeners can share same cache line and performance would suffer.

If we really want to save few bytes, we would instead dynamically allocate
whole struct request_sock_queue in the future.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h             | 22 ++++------------------
 include/net/request_sock.h      |  7 ++-----
 net/core/request_sock.c         |  9 ++++++++-
 net/ipv4/af_inet.c              | 10 +++-------
 net/ipv4/inet_connection_sock.c | 17 ++++++++---------
 net/ipv4/tcp.c                  | 14 ++------------
 net/ipv4/tcp_fastopen.c         | 10 +++++-----
 net/ipv4/tcp_ipv4.c             |  2 +-
 net/ipv6/tcp_ipv6.c             |  4 ++--
 9 files changed, 35 insertions(+), 60 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index fcb573be75d9..e442e6e9a365 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -382,25 +382,11 @@ static inline bool tcp_passive_fastopen(const struct sock *sk)
 		tcp_sk(sk)->fastopen_rsk != NULL);
 }
 
-extern void tcp_sock_destruct(struct sock *sk);
-
-static inline int fastopen_init_queue(struct sock *sk, int backlog)
+static inline void fastopen_queue_tune(struct sock *sk, int backlog)
 {
-	struct request_sock_queue *queue =
-	    &inet_csk(sk)->icsk_accept_queue;
-
-	if (queue->fastopenq == NULL) {
-		queue->fastopenq = kzalloc(
-		    sizeof(struct fastopen_queue),
-		    sk->sk_allocation);
-		if (queue->fastopenq == NULL)
-			return -ENOMEM;
-
-		sk->sk_destruct = tcp_sock_destruct;
-		spin_lock_init(&queue->fastopenq->lock);
-	}
-	queue->fastopenq->max_qlen = backlog;
-	return 0;
+	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
+
+	queue->fastopenq.max_qlen = backlog;
 }
 
 static inline void tcp_saved_syn_free(struct tcp_sock *tp)
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index c146b5284786..d2544de329bd 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -180,11 +180,8 @@ struct request_sock_queue {
 	struct request_sock	*rskq_accept_tail;
 	u8			rskq_defer_accept;
 	struct listen_sock	*listen_opt;
-	struct fastopen_queue	*fastopenq; /* This is non-NULL iff TFO has been
-					     * enabled on this listener. Check
-					     * max_qlen != 0 in fastopen_queue
-					     * to determine if TFO is enabled
-					     * right at this moment.
+	struct fastopen_queue	fastopenq;  /* Check max_qlen != 0 to determine
+					     * if TFO is enabled.
 					     */
 
 	/* temporary alignment, our goal is to get rid of this lock */
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index b42f0e26f89e..e22cfa4ed25f 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -59,6 +59,13 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 
 	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
 	spin_lock_init(&queue->syn_wait_lock);
+
+	spin_lock_init(&queue->fastopenq.lock);
+	queue->fastopenq.rskq_rst_head = NULL;
+	queue->fastopenq.rskq_rst_tail = NULL;
+	queue->fastopenq.qlen = 0;
+	queue->fastopenq.max_qlen = 0;
+
 	queue->rskq_accept_head = NULL;
 	lopt->nr_table_entries = nr_table_entries;
 	lopt->max_qlen_log = ilog2(nr_table_entries);
@@ -174,7 +181,7 @@ void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 	struct sock *lsk = req->rsk_listener;
 	struct fastopen_queue *fastopenq;
 
-	fastopenq = inet_csk(lsk)->icsk_accept_queue.fastopenq;
+	fastopenq = &inet_csk(lsk)->icsk_accept_queue.fastopenq;
 
 	tcp_sk(sk)->fastopen_rsk = NULL;
 	spin_lock_bh(&fastopenq->lock);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8a556643b874..3af85eecbe11 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -219,17 +219,13 @@ int inet_listen(struct socket *sock, int backlog)
 		 * shutdown() (rather than close()).
 		 */
 		if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) != 0 &&
-		    !inet_csk(sk)->icsk_accept_queue.fastopenq) {
+		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
 			if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) != 0)
-				err = fastopen_init_queue(sk, backlog);
+				fastopen_queue_tune(sk, backlog);
 			else if ((sysctl_tcp_fastopen &
 				  TFO_SERVER_WO_SOCKOPT2) != 0)
-				err = fastopen_init_queue(sk,
+				fastopen_queue_tune(sk,
 				    ((uint)sysctl_tcp_fastopen) >> 16);
-			else
-				err = 0;
-			if (err)
-				goto out;
 
 			tcp_fastopen_init_key_once(true);
 		}
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 694a5e8f4f9f..e1527882a578 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -335,9 +335,8 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 
 	sk_acceptq_removed(sk);
 	if (sk->sk_protocol == IPPROTO_TCP &&
-	    tcp_rsk(req)->tfo_listener &&
-	    queue->fastopenq) {
-		spin_lock_bh(&queue->fastopenq->lock);
+	    tcp_rsk(req)->tfo_listener) {
+		spin_lock_bh(&queue->fastopenq.lock);
 		if (tcp_rsk(req)->tfo_listener) {
 			/* We are still waiting for the final ACK from 3WHS
 			 * so can't free req now. Instead, we set req->sk to
@@ -348,7 +347,7 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 			req->sk = NULL;
 			req = NULL;
 		}
-		spin_unlock_bh(&queue->fastopenq->lock);
+		spin_unlock_bh(&queue->fastopenq.lock);
 	}
 out:
 	release_sock(sk);
@@ -886,12 +885,12 @@ void inet_csk_listen_stop(struct sock *sk)
 		sk_acceptq_removed(sk);
 		reqsk_put(req);
 	}
-	if (queue->fastopenq) {
+	if (queue->fastopenq.rskq_rst_head) {
 		/* Free all the reqs queued in rskq_rst_head. */
-		spin_lock_bh(&queue->fastopenq->lock);
-		acc_req = queue->fastopenq->rskq_rst_head;
-		queue->fastopenq->rskq_rst_head = NULL;
-		spin_unlock_bh(&queue->fastopenq->lock);
+		spin_lock_bh(&queue->fastopenq.lock);
+		acc_req = queue->fastopenq.rskq_rst_head;
+		queue->fastopenq.rskq_rst_head = NULL;
+		spin_unlock_bh(&queue->fastopenq.lock);
 		while ((req = acc_req) != NULL) {
 			acc_req = req->dl_next;
 			reqsk_put(req);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b8b8fa184f75..3c96fa87ff9e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2253,13 +2253,6 @@ int tcp_disconnect(struct sock *sk, int flags)
 }
 EXPORT_SYMBOL(tcp_disconnect);
 
-void tcp_sock_destruct(struct sock *sk)
-{
-	inet_sock_destruct(sk);
-
-	kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
-}
-
 static inline bool tcp_can_repair_sock(const struct sock *sk)
 {
 	return ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN) &&
@@ -2581,7 +2574,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		    TCPF_LISTEN))) {
 			tcp_fastopen_init_key_once(true);
 
-			err = fastopen_init_queue(sk, val);
+			fastopen_queue_tune(sk, val);
 		} else {
 			err = -EINVAL;
 		}
@@ -2849,10 +2842,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		break;
 
 	case TCP_FASTOPEN:
-		if (icsk->icsk_accept_queue.fastopenq)
-			val = icsk->icsk_accept_queue.fastopenq->max_qlen;
-		else
-			val = 0;
+		val = icsk->icsk_accept_queue.fastopenq.max_qlen;
 		break;
 
 	case TCP_TIMESTAMP:
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index db43c6286cf7..f69f436fcbcc 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -142,9 +142,9 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	if (!child)
 		return NULL;
 
-	spin_lock(&queue->fastopenq->lock);
-	queue->fastopenq->qlen++;
-	spin_unlock(&queue->fastopenq->lock);
+	spin_lock(&queue->fastopenq.lock);
+	queue->fastopenq.qlen++;
+	spin_unlock(&queue->fastopenq.lock);
 
 	/* Initialize the child socket. Have to fix some values to take
 	 * into account the child is a Fast Open socket and is created
@@ -237,8 +237,8 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
 	 * between qlen overflow causing Fast Open to be disabled
 	 * temporarily vs a server not supporting Fast Open at all.
 	 */
-	fastopenq = inet_csk(sk)->icsk_accept_queue.fastopenq;
-	if (!fastopenq || fastopenq->max_qlen == 0)
+	fastopenq = &inet_csk(sk)->icsk_accept_queue.fastopenq;
+	if (fastopenq->max_qlen == 0)
 		return false;
 
 	if (fastopenq->qlen >= fastopenq->max_qlen) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f551e9e862db..64ece718d66c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2186,7 +2186,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
-	struct fastopen_queue *fastopenq = icsk->icsk_accept_queue.fastopenq;
+	const struct fastopen_queue *fastopenq = &icsk->icsk_accept_queue.fastopenq;
 	__be32 dest = inet->inet_daddr;
 	__be32 src = inet->inet_rcv_saddr;
 	__u16 destp = ntohs(inet->inet_dport);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 97bc26e0cd0f..0ac64f47f882 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1672,7 +1672,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	const struct inet_sock *inet = inet_sk(sp);
 	const struct tcp_sock *tp = tcp_sk(sp);
 	const struct inet_connection_sock *icsk = inet_csk(sp);
-	struct fastopen_queue *fastopenq = icsk->icsk_accept_queue.fastopenq;
+	const struct fastopen_queue *fastopenq = &icsk->icsk_accept_queue.fastopenq;
 
 	dest  = &sp->sk_v6_daddr;
 	src   = &sp->sk_v6_rcv_saddr;
@@ -1716,7 +1716,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		   (icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		   tp->snd_cwnd,
 		   sp->sk_state == TCP_LISTEN ?
-			(fastopenq ? fastopenq->max_qlen : 0) :
+			fastopenq->max_qlen :
 			(tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh)
 		   );
 }
-- 
2.6.0.rc2.230.g3dd15c0
