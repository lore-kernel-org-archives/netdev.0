From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH 3/5] tcp: request sock accept queue spinlock protection
Date: Wed, 27 Oct 2010 17:29:07 +0400
Message-ID: <AANLkTik2qqqT6ezX=MozOqht9H62JvqDqdAgkX89Qo-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Shan Wei <shanwei@cn.fujitsu.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42381 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933218Ab0J0N3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 09:29:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <dp@highloadlab.com>

Spinlock and active flag added for request sock accept queue.

This is needed to access this queue without main socket lock.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 include/net/inet_connection_sock.h |    7 ++++
 include/net/request_sock.h         |   59 +++++++++++++++++++++++++++++------
 net/core/request_sock.c            |    4 ++-
 net/ipv4/inet_connection_sock.c    |   22 ++++++++-----
 4 files changed, 73 insertions(+), 19 deletions(-)
diff --git a/include/net/inet_connection_sock.h
b/include/net/inet_connection_sock.h
index b6d3b55..430b58f 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -258,6 +258,13 @@ static inline void
inet_csk_reqsk_queue_add(struct sock *sk,
 	reqsk_queue_add(&inet_csk(sk)->icsk_accept_queue, req, sk, child);
 }

+static inline void inet_csk_reqsk_queue_do_add(struct sock *sk,
+					    struct request_sock *req,
+					    struct sock *child)
+{
+	reqsk_queue_do_add(&inet_csk(sk)->icsk_accept_queue, req, sk, child);
+}
+
 extern void inet_csk_reqsk_queue_hash_add(struct sock *sk,
 					  struct request_sock *req,
 					  unsigned long timeout);
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 99e6e19..870c46b 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -109,6 +109,8 @@ struct listen_sock {
  *
  * @rskq_accept_head - FIFO head of established children
  * @rskq_accept_tail - FIFO tail of established children
+ * @rskq_accept_lock - guard for FIFO of established children
+ * @rskq_active - != 0 if we're ready for children (LISTEN state), 0 otherwise
  * @rskq_defer_accept - User waits for some data after accept()
  * @syn_wait_lock - serializer
  *
@@ -124,9 +126,11 @@ struct listen_sock {
 struct request_sock_queue {
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
+	spinlock_t		rskq_accept_lock;
 	rwlock_t		syn_wait_lock;
 	u8			rskq_defer_accept;
-	/* 3 bytes hole, try to pack */
+	u8			rskq_active;
+	/* 2 bytes hole, try to pack */
 	struct listen_sock	*listen_opt;
 };

@@ -137,11 +141,24 @@ extern void __reqsk_queue_destroy(struct
request_sock_queue *queue);
 extern void reqsk_queue_destroy(struct request_sock_queue *queue);

 static inline struct request_sock *
-	reqsk_queue_yank_acceptq(struct request_sock_queue *queue)
+	reqsk_queue_do_yank_acceptq(struct request_sock_queue *queue)
 {
 	struct request_sock *req = queue->rskq_accept_head;

 	queue->rskq_accept_head = NULL;
+
+	return req;
+}
+
+static inline struct request_sock *
+	reqsk_queue_yank_acceptq(struct request_sock_queue *queue)
+{
+	struct request_sock *req;
+
+	spin_lock_bh(&queue->rskq_accept_lock);
+	req = reqsk_queue_do_yank_acceptq(queue);
+	spin_unlock_bh(&queue->rskq_accept_lock);
+
 	return req;
 }

@@ -159,13 +176,12 @@ static inline void reqsk_queue_unlink(struct
request_sock_queue *queue,
 	write_unlock(&queue->syn_wait_lock);
 }

-static inline void reqsk_queue_add(struct request_sock_queue *queue,
+static inline void reqsk_queue_do_add(struct request_sock_queue *queue,
 				   struct request_sock *req,
 				   struct sock *parent,
 				   struct sock *child)
 {
 	req->sk = child;
-	sk_acceptq_added(parent);

 	if (queue->rskq_accept_head == NULL)
 		queue->rskq_accept_head = req;
@@ -174,25 +190,48 @@ static inline void reqsk_queue_add(struct
request_sock_queue *queue,

 	queue->rskq_accept_tail = req;
 	req->dl_next = NULL;
+	sk_acceptq_added(parent);
 }

-static inline struct request_sock *reqsk_queue_remove(struct
request_sock_queue *queue)
+static inline void reqsk_queue_add(struct request_sock_queue *queue,
+				   struct request_sock *req,
+				   struct sock *parent,
+				   struct sock *child)
+{
+	spin_lock(&queue->rskq_accept_lock);
+	reqsk_queue_do_add(queue, req, parent, child);
+	spin_unlock(&queue->rskq_accept_lock);
+}
+
+static inline struct request_sock *
+	reqsk_queue_do_remove(struct request_sock_queue *queue)
 {
 	struct request_sock *req = queue->rskq_accept_head;

 	WARN_ON(req == NULL);

 	queue->rskq_accept_head = req->dl_next;
-	if (queue->rskq_accept_head == NULL)
-		queue->rskq_accept_tail = NULL;

 	return req;
 }

-static inline struct sock *reqsk_queue_get_child(struct
request_sock_queue *queue,
-						 struct sock *parent)
+static inline struct request_sock *
+	reqsk_queue_remove(struct request_sock_queue *queue)
+{
+	struct request_sock *req;
+
+	spin_lock_bh(&queue->rskq_accept_lock);
+	req = reqsk_queue_do_remove(queue);
+	spin_unlock_bh(&queue->rskq_accept_lock);
+
+	return req;
+}
+
+static inline struct sock *
+	reqsk_queue_do_get_child(struct request_sock_queue *queue,
+				 struct sock *parent)
 {
-	struct request_sock *req = reqsk_queue_remove(queue);
+	struct request_sock *req = reqsk_queue_do_remove(queue);
 	struct sock *child = req->sk;

 	WARN_ON(child == NULL);
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 7552495..a0f2955 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -58,8 +58,10 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	     lopt->max_qlen_log++);

 	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
-	rwlock_init(&queue->syn_wait_lock);
+	spin_lock_init(&queue->rskq_accept_lock);
 	queue->rskq_accept_head = NULL;
+	queue->rskq_active = 0;
+	rwlock_init(&queue->syn_wait_lock);
 	lopt->nr_table_entries = nr_table_entries;

 	write_lock_bh(&queue->syn_wait_lock);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7174370..ecf98d2 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -215,7 +215,7 @@ EXPORT_SYMBOL_GPL(inet_csk_get_port);

 /*
  * Wait for an incoming connection, avoid race conditions. This must be called
- * with the socket locked.
+ * with rskq_accept_lock locked.
  */
 static int inet_csk_wait_for_connect(struct sock *sk, long timeo)
 {
@@ -240,10 +240,12 @@ static int inet_csk_wait_for_connect(struct sock
*sk, long timeo)
 	for (;;) {
 		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
 					  TASK_INTERRUPTIBLE);
-		release_sock(sk);
+		spin_unlock_bh(&icsk->icsk_accept_queue.rskq_accept_lock);
+
 		if (reqsk_queue_empty(&icsk->icsk_accept_queue))
 			timeo = schedule_timeout(timeo);
-		lock_sock(sk);
+
+		spin_lock_bh(&icsk->icsk_accept_queue.rskq_accept_lock);
 		err = 0;
 		if (!reqsk_queue_empty(&icsk->icsk_accept_queue))
 			break;
@@ -270,13 +272,13 @@ struct sock *inet_csk_accept(struct sock *sk,
int flags, int *err)
 	struct sock *newsk;
 	int error;

-	lock_sock(sk);
+	spin_lock_bh(&icsk->icsk_accept_queue.rskq_accept_lock);

 	/* We need to make sure that this socket is listening,
 	 * and that it has something pending.
 	 */
 	error = -EINVAL;
-	if (sk->sk_state != TCP_LISTEN)
+	if (!icsk->icsk_accept_queue.rskq_active)
 		goto out_err;

 	/* Find already established connection */
@@ -293,10 +295,10 @@ struct sock *inet_csk_accept(struct sock *sk,
int flags, int *err)
 			goto out_err;
 	}

-	newsk = reqsk_queue_get_child(&icsk->icsk_accept_queue, sk);
+	newsk = reqsk_queue_do_get_child(&icsk->icsk_accept_queue, sk);
 	WARN_ON(newsk->sk_state == TCP_SYN_RECV);
 out:
-	release_sock(sk);
+	spin_unlock_bh(&icsk->icsk_accept_queue.rskq_accept_lock);
 	return newsk;
 out_err:
 	newsk = NULL;
@@ -632,6 +634,7 @@ int inet_csk_listen_start(struct sock *sk, const
int nr_table_entries)

 	sk->sk_max_ack_backlog = 0;
 	sk->sk_ack_backlog = 0;
+	icsk->icsk_accept_queue.rskq_active = 1;
 	inet_csk_delack_init(sk);

 	/* There is race window here: we announce ourselves listening,
@@ -668,7 +671,10 @@ void inet_csk_listen_stop(struct sock *sk)
 	inet_csk_delete_keepalive_timer(sk);

 	/* make all the listen_opt local to us */
-	acc_req = reqsk_queue_yank_acceptq(&icsk->icsk_accept_queue);
+	spin_lock_bh(&icsk->icsk_accept_queue.rskq_accept_lock);
+	icsk->icsk_accept_queue.rskq_active = 0;
+	acc_req = reqsk_queue_do_yank_acceptq(&icsk->icsk_accept_queue);
+	spin_unlock_bh(&icsk->icsk_accept_queue.rskq_accept_lock);

 	/* Following specs, it would be better either to send FIN
 	 * (and enter FIN-WAIT-1, it is normal close)
