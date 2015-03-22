From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/8] net: convert syn_wait_lock to a spinlock
Date: Sun, 22 Mar 2015 10:22:21 -0700
Message-ID: <1427044945-32608-5-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:32771 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbCVRXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:23:01 -0400
Received: by oiba3 with SMTP id a3so9363177oib.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:23:00 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a low hanging fruit, as we'll get rid of syn_wait_lock eventually.

We hold syn_wait_lock for such small sections, that it makes no sense to use
a read/write lock. A spin lock is simply faster.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h       | 11 +++--------
 net/core/request_sock.c          | 14 +++++++-------
 net/ipv4/inet_connection_sock.c  |  8 ++++----
 net/ipv4/inet_diag.c             |  4 ++--
 net/ipv4/tcp_ipv4.c              | 12 ++++++------
 net/ipv6/inet6_connection_sock.c |  4 ++--
 6 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 8603c350fad0..fe41f3ceb008 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -173,11 +173,6 @@ struct fastopen_queue {
  * %syn_wait_lock is necessary only to avoid proc interface having to grab the main
  * lock sock while browsing the listening hash (otherwise it's deadlock prone).
  *
- * This lock is acquired in read mode only from listening_get_next() seq_file
- * op and it's acquired in write mode _only_ from code that is actively
- * changing rskq_accept_head. All readers that are holding the master sock lock
- * don't need to grab this lock in read mode too as rskq_accept_head. writes
- * are always protected from the main sock lock.
  */
 struct request_sock_queue {
 	struct request_sock	*rskq_accept_head;
@@ -192,7 +187,7 @@ struct request_sock_queue {
 					     */
 
 	/* temporary alignment, our goal is to get rid of this lock */
-	rwlock_t		syn_wait_lock ____cacheline_aligned_in_smp;
+	spinlock_t		syn_wait_lock ____cacheline_aligned_in_smp;
 };
 
 int reqsk_queue_alloc(struct request_sock_queue *queue,
@@ -223,14 +218,14 @@ static inline void reqsk_queue_unlink(struct request_sock_queue *queue,
 	struct listen_sock *lopt = queue->listen_opt;
 	struct request_sock **prev;
 
-	write_lock(&queue->syn_wait_lock);
+	spin_lock(&queue->syn_wait_lock);
 
 	prev = &lopt->syn_table[req->rsk_hash];
 	while (*prev != req)
 		prev = &(*prev)->dl_next;
 	*prev = req->dl_next;
 
-	write_unlock(&queue->syn_wait_lock);
+	spin_unlock(&queue->syn_wait_lock);
 	if (del_timer(&req->rsk_timer))
 		reqsk_put(req);
 }
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index cdc0ddd9ac9f..87b22c0bc08c 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -58,14 +58,14 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 		return -ENOMEM;
 
 	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
-	rwlock_init(&queue->syn_wait_lock);
+	spin_lock_init(&queue->syn_wait_lock);
 	queue->rskq_accept_head = NULL;
 	lopt->nr_table_entries = nr_table_entries;
 	lopt->max_qlen_log = ilog2(nr_table_entries);
 
-	write_lock_bh(&queue->syn_wait_lock);
+	spin_lock_bh(&queue->syn_wait_lock);
 	queue->listen_opt = lopt;
-	write_unlock_bh(&queue->syn_wait_lock);
+	spin_unlock_bh(&queue->syn_wait_lock);
 
 	return 0;
 }
@@ -81,10 +81,10 @@ static inline struct listen_sock *reqsk_queue_yank_listen_sk(
 {
 	struct listen_sock *lopt;
 
-	write_lock_bh(&queue->syn_wait_lock);
+	spin_lock_bh(&queue->syn_wait_lock);
 	lopt = queue->listen_opt;
 	queue->listen_opt = NULL;
-	write_unlock_bh(&queue->syn_wait_lock);
+	spin_unlock_bh(&queue->syn_wait_lock);
 
 	return lopt;
 }
@@ -100,7 +100,7 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 		for (i = 0; i < lopt->nr_table_entries; i++) {
 			struct request_sock *req;
 
-			write_lock_bh(&queue->syn_wait_lock);
+			spin_lock_bh(&queue->syn_wait_lock);
 			while ((req = lopt->syn_table[i]) != NULL) {
 				lopt->syn_table[i] = req->dl_next;
 				atomic_inc(&lopt->qlen_dec);
@@ -108,7 +108,7 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 					reqsk_put(req);
 				reqsk_put(req);
 			}
-			write_unlock_bh(&queue->syn_wait_lock);
+			spin_unlock_bh(&queue->syn_wait_lock);
 		}
 	}
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 711ab143d4cb..79c0c9439fdc 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -495,7 +495,7 @@ struct request_sock *inet_csk_search_req(struct sock *sk,
 	u32 hash = inet_synq_hash(raddr, rport, lopt->hash_rnd,
 				  lopt->nr_table_entries);
 
-	write_lock(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
 	for (req = lopt->syn_table[hash]; req != NULL; req = req->dl_next) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 
@@ -508,7 +508,7 @@ struct request_sock *inet_csk_search_req(struct sock *sk,
 			break;
 		}
 	}
-	write_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	return req;
 }
@@ -650,10 +650,10 @@ void reqsk_queue_hash_req(struct request_sock_queue *queue,
 	setup_timer(&req->rsk_timer, reqsk_timer_handler, (unsigned long)req);
 	req->rsk_hash = hash;
 
-	write_lock(&queue->syn_wait_lock);
+	spin_lock(&queue->syn_wait_lock);
 	req->dl_next = lopt->syn_table[hash];
 	lopt->syn_table[hash] = req;
-	write_unlock(&queue->syn_wait_lock);
+	spin_unlock(&queue->syn_wait_lock);
 
 	mod_timer_pinned(&req->rsk_timer, jiffies + timeout);
 }
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index f984b2001d0a..76322c9867d5 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -728,7 +728,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
 	entry.family = sk->sk_family;
 
-	read_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	lopt = icsk->icsk_accept_queue.listen_opt;
 	if (!lopt || !listen_sock_qlen(lopt))
@@ -776,7 +776,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 	}
 
 out:
-	read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	return err;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5554b8f33d41..8028ad5920a4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1909,13 +1909,13 @@ get_req:
 		}
 		sk	  = sk_nulls_next(st->syn_wait_sk);
 		st->state = TCP_SEQ_STATE_LISTENING;
-		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 	} else {
 		icsk = inet_csk(sk);
-		read_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 		if (reqsk_queue_len(&icsk->icsk_accept_queue))
 			goto start_req;
-		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 		sk = sk_nulls_next(sk);
 	}
 get_sk:
@@ -1927,7 +1927,7 @@ get_sk:
 			goto out;
 		}
 		icsk = inet_csk(sk);
-		read_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 		if (reqsk_queue_len(&icsk->icsk_accept_queue)) {
 start_req:
 			st->uid		= sock_i_uid(sk);
@@ -1936,7 +1936,7 @@ start_req:
 			st->sbucket	= 0;
 			goto get_req;
 		}
-		read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+		spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 	}
 	spin_unlock_bh(&ilb->lock);
 	st->offset = 0;
@@ -2155,7 +2155,7 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 	case TCP_SEQ_STATE_OPENREQ:
 		if (v) {
 			struct inet_connection_sock *icsk = inet_csk(st->syn_wait_sk);
-			read_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+			spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 		}
 	case TCP_SEQ_STATE_LISTENING:
 		if (v != SEQ_START_TOKEN)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 2f3bbe569e8f..6927f3fb5597 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -124,7 +124,7 @@ struct request_sock *inet6_csk_search_req(struct sock *sk,
 	u32 hash = inet6_synq_hash(raddr, rport, lopt->hash_rnd,
 				   lopt->nr_table_entries);
 
-	write_lock(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
 	for (req = lopt->syn_table[hash]; req != NULL; req = req->dl_next) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 
@@ -138,7 +138,7 @@ struct request_sock *inet6_csk_search_req(struct sock *sk,
 			break;
 		}
 	}
-	write_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	return req;
 }
-- 
2.2.0.rc0.207.ga3a616c
