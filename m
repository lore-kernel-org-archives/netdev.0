From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] tcp/dccp: fix race at listener dismantle phase
Date: Wed, 14 Oct 2015 10:58:39 -0700
Message-ID: <1444845519-20064-4-git-send-email-edumazet@google.com>
References: <1444845519-20064-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34838 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbJNR67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:58:59 -0400
Received: by padcn9 with SMTP id cn9so29514455pad.2
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:58:59 -0700 (PDT)
In-Reply-To: <1444845519-20064-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under stress, a close() on a listener can trigger the
WARN_ON(sk->sk_ack_backlog) in inet_csk_listen_stop()

We need to test if listener is still active before queueing
a child in inet_csk_reqsk_queue_add()

Create a common inet_child_forget() helper, and use it
from inet_csk_reqsk_queue_add() and inet_csk_listen_stop()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |  9 ++---
 include/net/request_sock.h         | 19 ----------
 net/ipv4/inet_connection_sock.c    | 73 ++++++++++++++++++++++++++------------
 3 files changed, 52 insertions(+), 49 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 89ecbc80b2ce..8b0e3d8a4d81 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -268,13 +268,8 @@ struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
 					    struct sock *newsk,
 					    const struct request_sock *req);
 
-static inline void inet_csk_reqsk_queue_add(struct sock *sk,
-					    struct request_sock *req,
-					    struct sock *child)
-{
-	reqsk_queue_add(&inet_csk(sk)->icsk_accept_queue, req, sk, child);
-}
-
+void inet_csk_reqsk_queue_add(struct sock *sk, struct request_sock *req,
+			      struct sock *child);
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 				   unsigned long timeout);
 
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 2e73748956d5..a0dde04eb178 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -186,25 +186,6 @@ static inline bool reqsk_queue_empty(const struct request_sock_queue *queue)
 	return queue->rskq_accept_head == NULL;
 }
 
-static inline void reqsk_queue_add(struct request_sock_queue *queue,
-				   struct request_sock *req,
-				   struct sock *parent,
-				   struct sock *child)
-{
-	spin_lock(&queue->rskq_lock);
-	req->sk = child;
-	sk_acceptq_added(parent);
-
-	if (queue->rskq_accept_head == NULL)
-		queue->rskq_accept_head = req;
-	else
-		queue->rskq_accept_tail->dl_next = req;
-
-	queue->rskq_accept_tail = req;
-	req->dl_next = NULL;
-	spin_unlock(&queue->rskq_lock);
-}
-
 static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue *queue,
 						      struct sock *parent)
 {
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index a5a1b54915e5..38b7ef8b0b78 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -740,7 +740,7 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 
 	reqsk_queue_alloc(&icsk->icsk_accept_queue);
 
-	sk->sk_max_ack_backlog = 0;
+	sk->sk_max_ack_backlog = nr_table_entries;
 	sk->sk_ack_backlog = 0;
 	inet_csk_delack_init(sk);
 
@@ -764,6 +764,53 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 }
 EXPORT_SYMBOL_GPL(inet_csk_listen_start);
 
+static void inet_child_forget(struct sock *sk, struct request_sock *req,
+			      struct sock *child)
+{
+	sk->sk_prot->disconnect(child, O_NONBLOCK);
+
+	sock_orphan(child);
+
+	percpu_counter_inc(sk->sk_prot->orphan_count);
+
+	if (sk->sk_protocol == IPPROTO_TCP && tcp_rsk(req)->tfo_listener) {
+		BUG_ON(tcp_sk(child)->fastopen_rsk != req);
+		BUG_ON(sk != req->rsk_listener);
+
+		/* Paranoid, to prevent race condition if
+		 * an inbound pkt destined for child is
+		 * blocked by sock lock in tcp_v4_rcv().
+		 * Also to satisfy an assertion in
+		 * tcp_v4_destroy_sock().
+		 */
+		tcp_sk(child)->fastopen_rsk = NULL;
+	}
+	inet_csk_destroy_sock(child);
+	reqsk_put(req);
+}
+
+void inet_csk_reqsk_queue_add(struct sock *sk, struct request_sock *req,
+			      struct sock *child)
+{
+	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
+
+	spin_lock(&queue->rskq_lock);
+	if (unlikely(sk->sk_state != TCP_LISTEN)) {
+		inet_child_forget(sk, req, child);
+	} else {
+		req->sk = child;
+		req->dl_next = NULL;
+		if (queue->rskq_accept_head == NULL)
+			queue->rskq_accept_head = req;
+		else
+			queue->rskq_accept_tail->dl_next = req;
+		queue->rskq_accept_tail = req;
+		sk_acceptq_added(sk);
+	}
+	spin_unlock(&queue->rskq_lock);
+}
+EXPORT_SYMBOL(inet_csk_reqsk_queue_add);
+
 /*
  *	This routine closes sockets which have been at least partially
  *	opened, but not yet accepted.
@@ -790,31 +837,11 @@ void inet_csk_listen_stop(struct sock *sk)
 		WARN_ON(sock_owned_by_user(child));
 		sock_hold(child);
 
-		sk->sk_prot->disconnect(child, O_NONBLOCK);
-
-		sock_orphan(child);
-
-		percpu_counter_inc(sk->sk_prot->orphan_count);
-
-		if (sk->sk_protocol == IPPROTO_TCP && tcp_rsk(req)->tfo_listener) {
-			BUG_ON(tcp_sk(child)->fastopen_rsk != req);
-			BUG_ON(sk != req->rsk_listener);
-
-			/* Paranoid, to prevent race condition if
-			 * an inbound pkt destined for child is
-			 * blocked by sock lock in tcp_v4_rcv().
-			 * Also to satisfy an assertion in
-			 * tcp_v4_destroy_sock().
-			 */
-			tcp_sk(child)->fastopen_rsk = NULL;
-		}
-		inet_csk_destroy_sock(child);
-
+		inet_child_forget(sk, req, child);
 		bh_unlock_sock(child);
 		local_bh_enable();
 		sock_put(child);
 
-		reqsk_put(req);
 		cond_resched();
 	}
 	if (queue->fastopenq.rskq_rst_head) {
@@ -829,7 +856,7 @@ void inet_csk_listen_stop(struct sock *sk)
 			req = next;
 		}
 	}
-	WARN_ON(sk->sk_ack_backlog);
+	WARN_ON_ONCE(sk->sk_ack_backlog);
 }
 EXPORT_SYMBOL_GPL(inet_csk_listen_stop);
 
-- 
2.6.0.rc2.230.g3dd15c0
