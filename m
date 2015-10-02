From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 01/17] tcp: add a spinlock to protect struct request_sock_queue
Date: Fri,  2 Oct 2015 11:43:23 -0700
Message-ID: <1443811419-4798-2-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33923 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbbJBSns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:43:48 -0400
Received: by padhy16 with SMTP id hy16so113385641pad.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:43:48 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct request_sock_queue fields are currently protected
by the listener 'lock' (not a real spinlock)

We need to add a private spinlock instead, so that softirq handlers
creating children do not have to worry with backlog notion
that the listener 'lock' carries.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h      | 37 ++++++++++++++++++-------------------
 net/core/request_sock.c         |  1 +
 net/ipv4/inet_connection_sock.c | 21 +++++++--------------
 3 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index d2544de329bd..202e36163ae3 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -176,9 +176,11 @@ struct fastopen_queue {
  *
  */
 struct request_sock_queue {
+	spinlock_t		rskq_lock;
+	u8			rskq_defer_accept;
+
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
-	u8			rskq_defer_accept;
 	struct listen_sock	*listen_opt;
 	struct fastopen_queue	fastopenq;  /* Check max_qlen != 0 to determine
 					     * if TFO is enabled.
@@ -196,16 +198,7 @@ void reqsk_queue_destroy(struct request_sock_queue *queue);
 void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 			   bool reset);
 
-static inline struct request_sock *
-	reqsk_queue_yank_acceptq(struct request_sock_queue *queue)
-{
-	struct request_sock *req = queue->rskq_accept_head;
-
-	queue->rskq_accept_head = NULL;
-	return req;
-}
-
-static inline int reqsk_queue_empty(struct request_sock_queue *queue)
+static inline bool reqsk_queue_empty(const struct request_sock_queue *queue)
 {
 	return queue->rskq_accept_head == NULL;
 }
@@ -215,6 +208,7 @@ static inline void reqsk_queue_add(struct request_sock_queue *queue,
 				   struct sock *parent,
 				   struct sock *child)
 {
+	spin_lock(&queue->rskq_lock);
 	req->sk = child;
 	sk_acceptq_added(parent);
 
@@ -225,18 +219,23 @@ static inline void reqsk_queue_add(struct request_sock_queue *queue,
 
 	queue->rskq_accept_tail = req;
 	req->dl_next = NULL;
+	spin_unlock(&queue->rskq_lock);
 }
 
-static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue *queue)
+static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue *queue,
+						      struct sock *parent)
 {
-	struct request_sock *req = queue->rskq_accept_head;
-
-	WARN_ON(req == NULL);
-
-	queue->rskq_accept_head = req->dl_next;
-	if (queue->rskq_accept_head == NULL)
-		queue->rskq_accept_tail = NULL;
+	struct request_sock *req;
 
+	spin_lock_bh(&queue->rskq_lock);
+	req = queue->rskq_accept_head;
+	if (req) {
+		sk_acceptq_removed(parent);
+		queue->rskq_accept_head = req->dl_next;
+		if (queue->rskq_accept_head == NULL)
+			queue->rskq_accept_tail = NULL;
+	}
+	spin_unlock_bh(&queue->rskq_lock);
 	return req;
 }
 
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index e22cfa4ed25f..8d9fd31d3d06 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -58,6 +58,7 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 		return -ENOMEM;
 
 	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
+	spin_lock_init(&queue->rskq_lock);
 	spin_lock_init(&queue->syn_wait_lock);
 
 	spin_lock_init(&queue->fastopenq.lock);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index e1527882a578..0085612b9e49 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -330,10 +330,9 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 		if (error)
 			goto out_err;
 	}
-	req = reqsk_queue_remove(queue);
+	req = reqsk_queue_remove(queue, sk);
 	newsk = req->sk;
 
-	sk_acceptq_removed(sk);
 	if (sk->sk_protocol == IPPROTO_TCP &&
 	    tcp_rsk(req)->tfo_listener) {
 		spin_lock_bh(&queue->fastopenq.lock);
@@ -832,11 +831,7 @@ void inet_csk_listen_stop(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
-	struct request_sock *acc_req;
-	struct request_sock *req;
-
-	/* make all the listen_opt local to us */
-	acc_req = reqsk_queue_yank_acceptq(queue);
+	struct request_sock *next, *req;
 
 	/* Following specs, it would be better either to send FIN
 	 * (and enter FIN-WAIT-1, it is normal close)
@@ -848,11 +843,9 @@ void inet_csk_listen_stop(struct sock *sk)
 	 */
 	reqsk_queue_destroy(queue);
 
-	while ((req = acc_req) != NULL) {
+	while ((req = reqsk_queue_remove(queue, sk)) != NULL) {
 		struct sock *child = req->sk;
 
-		acc_req = req->dl_next;
-
 		local_bh_disable();
 		bh_lock_sock(child);
 		WARN_ON(sock_owned_by_user(child));
@@ -882,18 +875,18 @@ void inet_csk_listen_stop(struct sock *sk)
 		local_bh_enable();
 		sock_put(child);
 
-		sk_acceptq_removed(sk);
 		reqsk_put(req);
 	}
 	if (queue->fastopenq.rskq_rst_head) {
 		/* Free all the reqs queued in rskq_rst_head. */
 		spin_lock_bh(&queue->fastopenq.lock);
-		acc_req = queue->fastopenq.rskq_rst_head;
+		req = queue->fastopenq.rskq_rst_head;
 		queue->fastopenq.rskq_rst_head = NULL;
 		spin_unlock_bh(&queue->fastopenq.lock);
-		while ((req = acc_req) != NULL) {
-			acc_req = req->dl_next;
+		while (req != NULL) {
+			next = req->dl_next;
 			reqsk_put(req);
+			req = next;
 		}
 	}
 	WARN_ON(sk->sk_ack_backlog);
-- 
2.6.0.rc2.230.g3dd15c0
