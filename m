From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 15/17] tcp: remove max_qlen_log
Date: Fri,  2 Oct 2015 11:43:37 -0700
Message-ID: <1443811419-4798-16-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35745 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbbJBSo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:26 -0400
Received: by pacfv12 with SMTP id fv12so115656082pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:26 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This control variable was set at first listen(fd, backlog)
call, but not updated if application tried to increase or decrease
backlog. It made sense at the time listener had a non resizeable
hash table.

Also rounding to powers of two was not very friendly.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |  2 +-
 include/net/request_sock.h         | 10 ++--------
 net/core/request_sock.c            |  8 +-------
 net/ipv4/inet_connection_sock.c    |  4 ++--
 4 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 730aa034cd3d..3208a65d1c28 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -295,7 +295,7 @@ static inline int inet_csk_reqsk_queue_young(const struct sock *sk)
 
 static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
 {
-	return reqsk_queue_is_full(&inet_csk(sk)->icsk_accept_queue);
+	return inet_csk_reqsk_queue_len(sk) >= sk->sk_max_ack_backlog;
 }
 
 void inet_csk_reqsk_queue_drop(struct sock *sk, struct request_sock *req);
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index a66ab1345373..bae6936d75c4 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -157,7 +157,7 @@ struct fastopen_queue {
 struct request_sock_queue {
 	spinlock_t		rskq_lock;
 	u8			rskq_defer_accept;
-	u8			max_qlen_log;
+
 	u32			synflood_warned;
 	atomic_t		qlen;
 	atomic_t		young;
@@ -169,8 +169,7 @@ struct request_sock_queue {
 					     */
 };
 
-void reqsk_queue_alloc(struct request_sock_queue *queue,
-		       unsigned int nr_table_entries);
+void reqsk_queue_alloc(struct request_sock_queue *queue);
 
 void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 			   bool reset);
@@ -240,9 +239,4 @@ static inline int reqsk_queue_len_young(const struct request_sock_queue *queue)
 	return atomic_read(&queue->young);
 }
 
-static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
-{
-	return reqsk_queue_len(queue) >> queue->max_qlen_log;
-}
-
 #endif /* _REQUEST_SOCK_H */
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index ecf74189bd3f..15c853806518 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -37,13 +37,8 @@
 int sysctl_max_syn_backlog = 256;
 EXPORT_SYMBOL(sysctl_max_syn_backlog);
 
-void reqsk_queue_alloc(struct request_sock_queue *queue,
-		       unsigned int nr_table_entries)
+void reqsk_queue_alloc(struct request_sock_queue *queue)
 {
-	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
-	nr_table_entries = max_t(u32, nr_table_entries, 8);
-	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
-
 	spin_lock_init(&queue->rskq_lock);
 
 	spin_lock_init(&queue->fastopenq.lock);
@@ -53,7 +48,6 @@ void reqsk_queue_alloc(struct request_sock_queue *queue,
 	queue->fastopenq.max_qlen = 0;
 
 	queue->rskq_accept_head = NULL;
-	queue->max_qlen_log = ilog2(nr_table_entries);
 }
 
 /*
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 775483283fa7..5f6e31a4aeae 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -579,7 +579,7 @@ static void reqsk_timer_handler(unsigned long data)
 	 * ones are about to clog our table.
 	 */
 	qlen = reqsk_queue_len(queue);
-	if (qlen >> (queue->max_qlen_log - 1)) {
+	if ((qlen << 1) > sk_listener->sk_max_ack_backlog) {
 		int young = reqsk_queue_len_young(queue) << 1;
 
 		while (thresh > 2) {
@@ -732,7 +732,7 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 
-	reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries);
+	reqsk_queue_alloc(&icsk->icsk_accept_queue);
 
 	sk->sk_max_ack_backlog = 0;
 	sk->sk_ack_backlog = 0;
-- 
2.6.0.rc2.230.g3dd15c0
