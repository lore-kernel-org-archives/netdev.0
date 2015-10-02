From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 14/17] tcp/dccp: remove struct listen_sock
Date: Fri,  2 Oct 2015 11:43:36 -0700
Message-ID: <1443811419-4798-15-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35857 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbbJBSoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:24 -0400
Received: by pablk4 with SMTP id lk4so112695039pab.3
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:23 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is enough to check listener sk_state, no need for an extra
condition.

max_qlen_log can be moved into struct request_sock_queue

We can remove syn_wait_lock and the alignment it enforced.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h      | 26 ++++-------------------
 net/core/request_sock.c         | 47 +++--------------------------------------
 net/ipv4/inet_connection_sock.c | 14 ++++--------
 3 files changed, 11 insertions(+), 76 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 353cb61bb399..a66ab1345373 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -119,14 +119,6 @@ static inline void reqsk_put(struct request_sock *req)
 
 extern int sysctl_max_syn_backlog;
 
-/** struct listen_sock - listen state
- *
- * @max_qlen_log - log_2 of maximal queued SYNs/REQUESTs
- */
-struct listen_sock {
-	u32			max_qlen_log;
-};
-
 /*
  * For a TCP Fast Open listener -
  *	lock - protects the access to all the reqsk, which is co-owned by
@@ -160,36 +152,26 @@ struct fastopen_queue {
  * @rskq_accept_head - FIFO head of established children
  * @rskq_accept_tail - FIFO tail of established children
  * @rskq_defer_accept - User waits for some data after accept()
- * @syn_wait_lock - serializer
- *
- * %syn_wait_lock is necessary only to avoid proc interface having to grab the main
- * lock sock while browsing the listening hash (otherwise it's deadlock prone).
  *
  */
 struct request_sock_queue {
 	spinlock_t		rskq_lock;
 	u8			rskq_defer_accept;
+	u8			max_qlen_log;
 	u32			synflood_warned;
-
 	atomic_t		qlen;
 	atomic_t		young;
 
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
-	struct listen_sock	*listen_opt;
 	struct fastopen_queue	fastopenq;  /* Check max_qlen != 0 to determine
 					     * if TFO is enabled.
 					     */
-
-	/* temporary alignment, our goal is to get rid of this lock */
-	spinlock_t		syn_wait_lock ____cacheline_aligned_in_smp;
 };
 
-int reqsk_queue_alloc(struct request_sock_queue *queue,
-		      unsigned int nr_table_entries);
+void reqsk_queue_alloc(struct request_sock_queue *queue,
+		       unsigned int nr_table_entries);
 
-void __reqsk_queue_destroy(struct request_sock_queue *queue);
-void reqsk_queue_destroy(struct request_sock_queue *queue);
 void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 			   bool reset);
 
@@ -260,7 +242,7 @@ static inline int reqsk_queue_len_young(const struct request_sock_queue *queue)
 
 static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
 {
-	return reqsk_queue_len(queue) >> queue->listen_opt->max_qlen_log;
+	return reqsk_queue_len(queue) >> queue->max_qlen_log;
 }
 
 #endif /* _REQUEST_SOCK_H */
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 124f61c5bfef..ecf74189bd3f 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -37,22 +37,14 @@
 int sysctl_max_syn_backlog = 256;
 EXPORT_SYMBOL(sysctl_max_syn_backlog);
 
-int reqsk_queue_alloc(struct request_sock_queue *queue,
-		      unsigned int nr_table_entries)
+void reqsk_queue_alloc(struct request_sock_queue *queue,
+		       unsigned int nr_table_entries)
 {
-	size_t lopt_size = sizeof(struct listen_sock);
-	struct listen_sock *lopt = NULL;
-
 	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
 	nr_table_entries = max_t(u32, nr_table_entries, 8);
 	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
 
-	lopt = kzalloc(lopt_size, GFP_KERNEL);
-	if (!lopt)
-		return -ENOMEM;
-
 	spin_lock_init(&queue->rskq_lock);
-	spin_lock_init(&queue->syn_wait_lock);
 
 	spin_lock_init(&queue->fastopenq.lock);
 	queue->fastopenq.rskq_rst_head = NULL;
@@ -61,40 +53,7 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	queue->fastopenq.max_qlen = 0;
 
 	queue->rskq_accept_head = NULL;
-	lopt->max_qlen_log = ilog2(nr_table_entries);
-
-	spin_lock_bh(&queue->syn_wait_lock);
-	queue->listen_opt = lopt;
-	spin_unlock_bh(&queue->syn_wait_lock);
-
-	return 0;
-}
-
-void __reqsk_queue_destroy(struct request_sock_queue *queue)
-{
-	/* This is an error recovery path only, no locking needed */
-	kfree(queue->listen_opt);
-}
-
-static inline struct listen_sock *reqsk_queue_yank_listen_sk(
-		struct request_sock_queue *queue)
-{
-	struct listen_sock *lopt;
-
-	spin_lock_bh(&queue->syn_wait_lock);
-	lopt = queue->listen_opt;
-	queue->listen_opt = NULL;
-	spin_unlock_bh(&queue->syn_wait_lock);
-
-	return lopt;
-}
-
-void reqsk_queue_destroy(struct request_sock_queue *queue)
-{
-	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
-
-	/* cleaning is done by req timers */
-	kfree(lopt);
+	queue->max_qlen_log = ilog2(nr_table_entries);
 }
 
 /*
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 099e0ea9242a..775483283fa7 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -552,12 +552,11 @@ static void reqsk_timer_handler(unsigned long data)
 	struct sock *sk_listener = req->rsk_listener;
 	struct inet_connection_sock *icsk = inet_csk(sk_listener);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
-	struct listen_sock *lopt = queue->listen_opt;
 	int qlen, expire = 0, resend = 0;
 	int max_retries, thresh;
 	u8 defer_accept;
 
-	if (sk_listener->sk_state != TCP_LISTEN || !lopt)
+	if (sk_listener->sk_state != TCP_LISTEN)
 		goto drop;
 
 	max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
@@ -580,7 +579,7 @@ static void reqsk_timer_handler(unsigned long data)
 	 * ones are about to clog our table.
 	 */
 	qlen = reqsk_queue_len(queue);
-	if (qlen >> (lopt->max_qlen_log - 1)) {
+	if (qlen >> (queue->max_qlen_log - 1)) {
 		int young = reqsk_queue_len_young(queue) << 1;
 
 		while (thresh > 2) {
@@ -730,12 +729,10 @@ EXPORT_SYMBOL(inet_csk_prepare_forced_close);
 
 int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	int rc = reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries);
+	struct inet_sock *inet = inet_sk(sk);
 
-	if (rc != 0)
-		return rc;
+	reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries);
 
 	sk->sk_max_ack_backlog = 0;
 	sk->sk_ack_backlog = 0;
@@ -757,7 +754,6 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 	}
 
 	sk->sk_state = TCP_CLOSE;
-	__reqsk_queue_destroy(&icsk->icsk_accept_queue);
 	return -EADDRINUSE;
 }
 EXPORT_SYMBOL_GPL(inet_csk_listen_start);
@@ -780,8 +776,6 @@ void inet_csk_listen_stop(struct sock *sk)
 	 * To be honest, we are not able to make either
 	 * of the variants now.			--ANK
 	 */
-	reqsk_queue_destroy(queue);
-
 	while ((req = reqsk_queue_remove(queue, sk)) != NULL) {
 		struct sock *child = req->sk;
 
-- 
2.6.0.rc2.230.g3dd15c0
