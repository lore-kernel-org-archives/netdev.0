From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/17] tcp: move qlen/young out of struct listen_sock
Date: Fri,  2 Oct 2015 11:43:24 -0700
Message-ID: <1443811419-4798-3-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35263 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbbJBSnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:43:51 -0400
Received: by pacfv12 with SMTP id fv12so115644200pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:43:51 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qlen_inc & young_inc were protected by listener lock,
while qlen_dec & young_dec were atomic fields.

Everything needs to be atomic for upcoming lockless listener.

Also move qlen/young in request_sock_queue as we'll get rid
of struct listen_sock eventually.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h      | 40 ++++++++++------------------------------
 net/core/request_sock.c         |  8 ++++----
 net/ipv4/inet_connection_sock.c |  6 +++---
 net/ipv4/inet_diag.c            |  2 +-
 4 files changed, 18 insertions(+), 38 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 202e36163ae3..d128e7f89042 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -122,14 +122,7 @@ extern int sysctl_max_syn_backlog;
  * @max_qlen_log - log_2 of maximal queued SYNs/REQUESTs
  */
 struct listen_sock {
-	int			qlen_inc; /* protected by listener lock */
-	int			young_inc;/* protected by listener lock */
-
-	/* following fields can be updated by timer */
-	atomic_t		qlen_dec; /* qlen = qlen_inc - qlen_dec */
-	atomic_t		young_dec;
-
-	u32			max_qlen_log ____cacheline_aligned_in_smp;
+	u32			max_qlen_log;
 	u32			synflood_warned;
 	u32			hash_rnd;
 	u32			nr_table_entries;
@@ -179,6 +172,9 @@ struct request_sock_queue {
 	spinlock_t		rskq_lock;
 	u8			rskq_defer_accept;
 
+	atomic_t		qlen;
+	atomic_t		young;
+
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
 	struct listen_sock	*listen_opt;
@@ -242,41 +238,25 @@ static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue
 static inline void reqsk_queue_removed(struct request_sock_queue *queue,
 				       const struct request_sock *req)
 {
-	struct listen_sock *lopt = queue->listen_opt;
-
 	if (req->num_timeout == 0)
-		atomic_inc(&lopt->young_dec);
-	atomic_inc(&lopt->qlen_dec);
+		atomic_dec(&queue->young);
+	atomic_dec(&queue->qlen);
 }
 
 static inline void reqsk_queue_added(struct request_sock_queue *queue)
 {
-	struct listen_sock *lopt = queue->listen_opt;
-
-	lopt->young_inc++;
-	lopt->qlen_inc++;
-}
-
-static inline int listen_sock_qlen(const struct listen_sock *lopt)
-{
-	return lopt->qlen_inc - atomic_read(&lopt->qlen_dec);
-}
-
-static inline int listen_sock_young(const struct listen_sock *lopt)
-{
-	return lopt->young_inc - atomic_read(&lopt->young_dec);
+	atomic_inc(&queue->young);
+	atomic_inc(&queue->qlen);
 }
 
 static inline int reqsk_queue_len(const struct request_sock_queue *queue)
 {
-	const struct listen_sock *lopt = queue->listen_opt;
-
-	return lopt ? listen_sock_qlen(lopt) : 0;
+	return atomic_read(&queue->qlen);
 }
 
 static inline int reqsk_queue_len_young(const struct request_sock_queue *queue)
 {
-	return listen_sock_young(queue->listen_opt);
+	return atomic_read(&queue->young);
 }
 
 static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 8d9fd31d3d06..5ca624cea04c 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -102,7 +102,7 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 	/* make all the listen_opt local to us */
 	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
 
-	if (listen_sock_qlen(lopt) != 0) {
+	if (reqsk_queue_len(queue) != 0) {
 		unsigned int i;
 
 		for (i = 0; i < lopt->nr_table_entries; i++) {
@@ -116,7 +116,7 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 				 * or risk a dead lock.
 				 */
 				spin_unlock_bh(&queue->syn_wait_lock);
-				atomic_inc(&lopt->qlen_dec);
+				atomic_dec(&queue->qlen);
 				if (del_timer_sync(&req->rsk_timer))
 					reqsk_put(req);
 				reqsk_put(req);
@@ -126,8 +126,8 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 		}
 	}
 
-	if (WARN_ON(listen_sock_qlen(lopt) != 0))
-		pr_err("qlen %u\n", listen_sock_qlen(lopt));
+	if (WARN_ON(reqsk_queue_len(queue) != 0))
+		pr_err("qlen %u\n", reqsk_queue_len(queue));
 	kvfree(lopt);
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 0085612b9e49..093ef04e6ebf 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -640,9 +640,9 @@ static void reqsk_timer_handler(unsigned long data)
 	 * embrions; and abort old ones without pity, if old
 	 * ones are about to clog our table.
 	 */
-	qlen = listen_sock_qlen(lopt);
+	qlen = reqsk_queue_len(queue);
 	if (qlen >> (lopt->max_qlen_log - 1)) {
-		int young = listen_sock_young(lopt) << 1;
+		int young = reqsk_queue_len_young(queue) << 1;
 
 		while (thresh > 2) {
 			if (qlen < young)
@@ -664,7 +664,7 @@ static void reqsk_timer_handler(unsigned long data)
 		unsigned long timeo;
 
 		if (req->num_timeout++ == 0)
-			atomic_inc(&lopt->young_dec);
+			atomic_dec(&queue->young);
 		timeo = min(TCP_TIMEOUT_INIT << req->num_timeout, TCP_RTO_MAX);
 		mod_timer_pinned(&req->rsk_timer, jiffies + timeo);
 		return;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index c3b1f3a0f4cf..0ac1d68dc8a6 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -753,7 +753,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	lopt = icsk->icsk_accept_queue.listen_opt;
-	if (!lopt || !listen_sock_qlen(lopt))
+	if (!lopt || !reqsk_queue_len(&icsk->icsk_accept_queue))
 		goto out;
 
 	if (bc) {
-- 
2.6.0.rc2.230.g3dd15c0
