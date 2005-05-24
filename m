From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [PATCH 1/2][NET] Generalise tcp_listen_opt
Date: Mon, 23 May 2005 22:16:45 -0300
Message-ID: <20050524011645.GI26989@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please consider pulling into your net-2.6.13 pending tree from:

rsync://rsync.kernel.org/pub/scm/linux/kernel/git/acme/net-2.6.13.git

	The bksend like output below was done using this script, people
starting to use git may find it useful :-)

http://dccp.ghostprotocols.net:81/acme-git-send-changeset

Best Regards,

- Arnaldo

tree f416accfe16809dce40f34fb711d42a67aea892d
parent 0642cf1e6afa649d8d9a9d3dc7275ceebb038ae0
author Arnaldo Carvalho de Melo <acme@ghostprotocols.net> 1113623934 -0300
committer Arnaldo Carvalho de Melo <acme@ghostprotocols.net> 1116886806 -0300

[NET] Generalise tcp_listen_opt

This chunks out the accept_queue and tcp_listen_opt code and moves them to
net/core/request_sock.c and include/net/request_sock.h, to make it useful for
other transport protocols, DCCP being the first one to use it.

Next patches will rename tcp_listen_opt to accept_sock and remove the inline
tcp functions that just call a reqsk_queue_ function.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

------------------------------------------------------------------------------

 include/linux/tcp.h        |   17 ----
 include/net/request_sock.h |  178 +++++++++++++++++++++++++++++++++++++++++++++
 include/net/tcp.h          |   46 ++---------
 net/core/Makefile          |    3 
 net/core/request_sock.c    |   48 ++++++++++++
 net/ipv4/tcp.c             |   67 +++++-----------
 net/ipv4/tcp_diag.c        |    6 -
 net/ipv4/tcp_ipv4.c        |   32 +++-----
 net/ipv4/tcp_minisocks.c   |    6 -
 net/ipv4/tcp_timer.c       |   10 --
 net/ipv6/tcp_ipv6.c        |   14 ---
 11 files changed, 281 insertions(+), 146 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -379,22 +379,7 @@ struct tcp_sock {
 
 	__u32	total_retrans;	/* Total retransmits for entire connection */
 
-	/* The syn_wait_lock is necessary only to avoid proc interface having
-	 * to grab the main lock sock while browsing the listening hash
-	 * (otherwise it's deadlock prone).
-	 * This lock is acquired in read mode only from listening_get_next()
-	 * and it's acquired in write mode _only_ from code that is actively
-	 * changing the syn_wait_queue. All readers that are holding
-	 * the master sock lock don't need to grab this lock in read mode
-	 * too as the syn_wait_queue writes are always protected from
-	 * the main sock lock.
-	 */
-	rwlock_t		syn_wait_lock;
-	struct tcp_listen_opt	*listen_opt;
-
-	/* FIFO of established children */
-	struct request_sock	*accept_queue;
-	struct request_sock	*accept_queue_tail;
+	struct request_sock_queue accept_queue; /* FIFO of established children */
 
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -16,7 +16,9 @@
 #define _REQUEST_SOCK_H
 
 #include <linux/slab.h>
+#include <linux/spinlock.h>
 #include <linux/types.h>
+
 #include <net/sock.h>
 
 struct request_sock;
@@ -74,4 +76,180 @@ static inline void reqsk_free(struct req
 	__reqsk_free(req);
 }
 
+extern int sysctl_max_syn_backlog;
+
+/** struct tcp_listen_opt - listen state
+ *
+ * @max_qlen_log - log_2 of maximal queued SYNs/REQUESTs
+ */
+struct tcp_listen_opt {
+	u8			max_qlen_log;
+	/* 3 bytes hole, try to use */
+	int			qlen;
+	int			qlen_young;
+	int			clock_hand;
+	u32			hash_rnd;
+	struct request_sock	*syn_table[0];
+};
+
+/** struct request_sock_queue - queue of request_socks
+ *
+ * @rskq_accept_head - FIFO head of established children
+ * @rskq_accept_tail - FIFO tail of established children
+ * @syn_wait_lock - serializer
+ *
+ * %syn_wait_lock is necessary only to avoid proc interface having to grab the main
+ * lock sock while browsing the listening hash (otherwise it's deadlock prone).
+ *
+ * This lock is acquired in read mode only from listening_get_next() seq_file
+ * op and it's acquired in write mode _only_ from code that is actively
+ * changing rskq_accept_head. All readers that are holding the master sock lock
+ * don't need to grab this lock in read mode too as rskq_accept_head. writes
+ * are always protected from the main sock lock.
+ */
+struct request_sock_queue {
+	struct request_sock	*rskq_accept_head;
+	struct request_sock	*rskq_accept_tail;
+	rwlock_t		syn_wait_lock;
+	struct tcp_listen_opt	*listen_opt;
+};
+
+extern int reqsk_queue_alloc(struct request_sock_queue *queue,
+			     const int nr_table_entries);
+
+static inline struct tcp_listen_opt *reqsk_queue_yank_listen_sk(struct request_sock_queue *queue)
+{
+	struct tcp_listen_opt *lopt;
+
+	write_lock_bh(&queue->syn_wait_lock);
+	lopt = queue->listen_opt;
+	queue->listen_opt = NULL;
+	write_unlock_bh(&queue->syn_wait_lock);
+
+	return lopt;
+}
+
+static inline void reqsk_queue_destroy(struct request_sock_queue *queue)
+{
+	kfree(reqsk_queue_yank_listen_sk(queue));
+}
+
+static inline struct request_sock *
+	reqsk_queue_yank_acceptq(struct request_sock_queue *queue)
+{
+	struct request_sock *req = queue->rskq_accept_head;
+
+	queue->rskq_accept_head = queue->rskq_accept_head = NULL;
+	return req;
+}
+
+static inline int reqsk_queue_empty(struct request_sock_queue *queue)
+{
+	return queue->rskq_accept_head == NULL;
+}
+
+static inline void reqsk_queue_unlink(struct request_sock_queue *queue,
+				      struct request_sock *req,
+				      struct request_sock **prev_req)
+{
+	write_lock(&queue->syn_wait_lock);
+	*prev_req = req->dl_next;
+	write_unlock(&queue->syn_wait_lock);
+}
+
+static inline void reqsk_queue_add(struct request_sock_queue *queue,
+				   struct request_sock *req,
+				   struct sock *parent,
+				   struct sock *child)
+{
+	req->sk = child;
+	sk_acceptq_added(parent);
+
+	if (queue->rskq_accept_head == NULL)
+		queue->rskq_accept_head = req;
+	else
+		queue->rskq_accept_tail->dl_next = req;
+
+	queue->rskq_accept_tail = req;
+	req->dl_next = NULL;
+}
+
+static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue *queue)
+{
+	struct request_sock *req = queue->rskq_accept_head;
+
+	BUG_TRAP(req != NULL);
+
+	queue->rskq_accept_head = req->dl_next;
+	if (queue->rskq_accept_head == NULL)
+		queue->rskq_accept_tail = NULL;
+
+	return req;
+}
+
+static inline struct sock *reqsk_queue_get_child(struct request_sock_queue *queue,
+						 struct sock *parent)
+{
+	struct request_sock *req = reqsk_queue_remove(queue);
+	struct sock *child = req->sk;
+
+	BUG_TRAP(child != NULL);
+
+	sk_acceptq_removed(parent);
+	__reqsk_free(req);
+	return child;
+}
+
+static inline int reqsk_queue_removed(struct request_sock_queue *queue,
+				      struct request_sock *req)
+{
+	struct tcp_listen_opt *lopt = queue->listen_opt;
+
+	if (req->retrans == 0)
+		--lopt->qlen_young;
+
+	return --lopt->qlen;
+}
+
+static inline int reqsk_queue_added(struct request_sock_queue *queue)
+{
+	struct tcp_listen_opt *lopt = queue->listen_opt;
+	const int prev_qlen = lopt->qlen;
+
+	lopt->qlen_young++;
+	lopt->qlen++;
+	return prev_qlen;
+}
+
+static inline int reqsk_queue_len(struct request_sock_queue *queue)
+{
+	return queue->listen_opt != NULL ? queue->listen_opt->qlen : 0;
+}
+
+static inline int reqsk_queue_len_young(struct request_sock_queue *queue)
+{
+	return queue->listen_opt->qlen_young;
+}
+
+static inline int reqsk_queue_is_full(struct request_sock_queue *queue)
+{
+	return queue->listen_opt->qlen >> queue->listen_opt->max_qlen_log;
+}
+
+static inline void reqsk_queue_hash_req(struct request_sock_queue *queue,
+					u32 hash, struct request_sock *req,
+					unsigned timeout)
+{
+	struct tcp_listen_opt *lopt = queue->listen_opt;
+
+	req->expires = jiffies + timeout;
+	req->retrans = 0;
+	req->sk = NULL;
+	req->dl_next = lopt->syn_table[hash];
+
+	write_lock(&queue->syn_wait_lock);
+	lopt->syn_table[hash] = req;
+	write_unlock(&queue->syn_wait_lock);
+}
+
 #endif /* _REQUEST_SOCK_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1686,71 +1686,41 @@ static inline int tcp_full_space(const s
 static inline void tcp_acceptq_queue(struct sock *sk, struct request_sock *req,
 					 struct sock *child)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	req->sk = child;
-	sk_acceptq_added(sk);
-
-	if (!tp->accept_queue_tail) {
-		tp->accept_queue = req;
-	} else {
-		tp->accept_queue_tail->dl_next = req;
-	}
-	tp->accept_queue_tail = req;
-	req->dl_next = NULL;
+	reqsk_queue_add(&tcp_sk(sk)->accept_queue, req, sk, child);
 }
 
-struct tcp_listen_opt
-{
-	u8			max_qlen_log;	/* log_2 of maximal queued SYNs */
-	int			qlen;
-	int			qlen_young;
-	int			clock_hand;
-	u32			hash_rnd;
-	struct request_sock	*syn_table[TCP_SYNQ_HSIZE];
-};
-
 static inline void
 tcp_synq_removed(struct sock *sk, struct request_sock *req)
 {
-	struct tcp_listen_opt *lopt = tcp_sk(sk)->listen_opt;
-
-	if (--lopt->qlen == 0)
+	if (reqsk_queue_removed(&tcp_sk(sk)->accept_queue, req) == 0)
 		tcp_delete_keepalive_timer(sk);
-	if (req->retrans == 0)
-		lopt->qlen_young--;
 }
 
 static inline void tcp_synq_added(struct sock *sk)
 {
-	struct tcp_listen_opt *lopt = tcp_sk(sk)->listen_opt;
-
-	if (lopt->qlen++ == 0)
+	if (reqsk_queue_added(&tcp_sk(sk)->accept_queue) == 0)
 		tcp_reset_keepalive_timer(sk, TCP_TIMEOUT_INIT);
-	lopt->qlen_young++;
 }
 
 static inline int tcp_synq_len(struct sock *sk)
 {
-	return tcp_sk(sk)->listen_opt->qlen;
+	return reqsk_queue_len(&tcp_sk(sk)->accept_queue);
 }
 
 static inline int tcp_synq_young(struct sock *sk)
 {
-	return tcp_sk(sk)->listen_opt->qlen_young;
+	return reqsk_queue_len_young(&tcp_sk(sk)->accept_queue);
 }
 
 static inline int tcp_synq_is_full(struct sock *sk)
 {
-	return tcp_synq_len(sk) >> tcp_sk(sk)->listen_opt->max_qlen_log;
+	return reqsk_queue_is_full(&tcp_sk(sk)->accept_queue);
 }
 
 static inline void tcp_synq_unlink(struct tcp_sock *tp, struct request_sock *req,
-				       struct request_sock **prev)
+				   struct request_sock **prev)
 {
-	write_lock(&tp->syn_wait_lock);
-	*prev = req->dl_next;
-	write_unlock(&tp->syn_wait_lock);
+	reqsk_queue_unlink(&tp->accept_queue, req, prev);
 }
 
 static inline void tcp_synq_drop(struct sock *sk, struct request_sock *req,
diff --git a/net/core/Makefile b/net/core/Makefile
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -2,7 +2,8 @@
 # Makefile for the Linux networking core.
 #
 
-obj-y := sock.o skbuff.o iovec.o datagram.o stream.o scm.o gen_stats.o gen_estimator.o
+obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
+	 gen_stats.o gen_estimator.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
new file mode 100644
--- /dev/null
+++ b/net/core/request_sock.c
@@ -0,0 +1,48 @@
+/*
+ * NET		Generic infrastructure for Network protocols.
+ *
+ * Authors:	Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *
+ * 		From code originally in include/net/tcp.h
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/random.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+
+#include <net/request_sock.h>
+
+int reqsk_queue_alloc(struct request_sock_queue *queue,
+		      const int nr_table_entries)
+{
+	const int lopt_size = sizeof(struct tcp_listen_opt) +
+			      nr_table_entries * sizeof(struct request_sock *);
+	struct tcp_listen_opt *lopt = kmalloc(lopt_size, GFP_KERNEL);
+
+	if (lopt == NULL)
+		return -ENOMEM;
+
+	memset(lopt, 0, lopt_size);
+
+	for (lopt->max_qlen_log = 6;
+	     (1 << lopt->max_qlen_log) < sysctl_max_syn_backlog;
+	     lopt->max_qlen_log++);
+
+	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
+	rwlock_init(&queue->syn_wait_lock);
+	queue->rskq_accept_head = queue->rskq_accept_head = NULL;
+
+	write_lock_bh(&queue->syn_wait_lock);
+	queue->listen_opt = lopt;
+	write_unlock_bh(&queue->syn_wait_lock);
+
+	return 0;
+}
+
+EXPORT_SYMBOL(reqsk_queue_alloc);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -316,7 +316,7 @@ EXPORT_SYMBOL(tcp_enter_memory_pressure)
 static __inline__ unsigned int tcp_listen_poll(struct sock *sk,
 					       poll_table *wait)
 {
-	return tcp_sk(sk)->accept_queue ? (POLLIN | POLLRDNORM) : 0;
+	return !reqsk_queue_empty(&tcp_sk(sk)->accept_queue) ? (POLLIN | POLLRDNORM) : 0;
 }
 
 /*
@@ -462,28 +462,15 @@ int tcp_listen_start(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt;
+	int rc = reqsk_queue_alloc(&tp->accept_queue, TCP_SYNQ_HSIZE);
+
+	if (rc != 0)
+		return rc;
 
 	sk->sk_max_ack_backlog = 0;
 	sk->sk_ack_backlog = 0;
-	tp->accept_queue = tp->accept_queue_tail = NULL;
-	rwlock_init(&tp->syn_wait_lock);
 	tcp_delack_init(tp);
 
-	lopt = kmalloc(sizeof(struct tcp_listen_opt), GFP_KERNEL);
-	if (!lopt)
-		return -ENOMEM;
-
-	memset(lopt, 0, sizeof(struct tcp_listen_opt));
-	for (lopt->max_qlen_log = 6; ; lopt->max_qlen_log++)
-		if ((1 << lopt->max_qlen_log) >= sysctl_max_syn_backlog)
-			break;
-	get_random_bytes(&lopt->hash_rnd, 4);
-
-	write_lock_bh(&tp->syn_wait_lock);
-	tp->listen_opt = lopt;
-	write_unlock_bh(&tp->syn_wait_lock);
-
 	/* There is race window here: we announce ourselves listening,
 	 * but this transition is still not validated by get_port().
 	 * It is OK, because this socket enters to hash table only
@@ -500,10 +487,7 @@ int tcp_listen_start(struct sock *sk)
 	}
 
 	sk->sk_state = TCP_CLOSE;
-	write_lock_bh(&tp->syn_wait_lock);
-	tp->listen_opt = NULL;
-	write_unlock_bh(&tp->syn_wait_lock);
-	kfree(lopt);
+	reqsk_queue_destroy(&tp->accept_queue);
 	return -EADDRINUSE;
 }
 
@@ -515,18 +499,16 @@ int tcp_listen_start(struct sock *sk)
 static void tcp_listen_stop (struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt = tp->listen_opt;
-	struct request_sock *acc_req = tp->accept_queue;
+	struct tcp_listen_opt *lopt;
+	struct request_sock *acc_req;
 	struct request_sock *req;
 	int i;
 
 	tcp_delete_keepalive_timer(sk);
 
 	/* make all the listen_opt local to us */
-	write_lock_bh(&tp->syn_wait_lock);
-	tp->listen_opt = NULL;
-	write_unlock_bh(&tp->syn_wait_lock);
-	tp->accept_queue = tp->accept_queue_tail = NULL;
+	lopt = reqsk_queue_yank_listen_sk(&tp->accept_queue);
+	acc_req = reqsk_queue_yank_acceptq(&tp->accept_queue);
 
 	if (lopt->qlen) {
 		for (i = 0; i < TCP_SYNQ_HSIZE; i++) {
@@ -1867,11 +1849,11 @@ static int wait_for_connect(struct sock 
 		prepare_to_wait_exclusive(sk->sk_sleep, &wait,
 					  TASK_INTERRUPTIBLE);
 		release_sock(sk);
-		if (!tp->accept_queue)
+		if (reqsk_queue_empty(&tp->accept_queue))
 			timeo = schedule_timeout(timeo);
 		lock_sock(sk);
 		err = 0;
-		if (tp->accept_queue)
+		if (!reqsk_queue_empty(&tp->accept_queue))
 			break;
 		err = -EINVAL;
 		if (sk->sk_state != TCP_LISTEN)
@@ -1894,7 +1876,6 @@ static int wait_for_connect(struct sock 
 struct sock *tcp_accept(struct sock *sk, int flags, int *err)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct request_sock *req;
 	struct sock *newsk;
 	int error;
 
@@ -1905,37 +1886,31 @@ struct sock *tcp_accept(struct sock *sk,
 	 */
 	error = -EINVAL;
 	if (sk->sk_state != TCP_LISTEN)
-		goto out;
+		goto out_err;
 
 	/* Find already established connection */
-	if (!tp->accept_queue) {
+	if (reqsk_queue_empty(&tp->accept_queue)) {
 		long timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
 
 		/* If this is a non blocking socket don't sleep */
 		error = -EAGAIN;
 		if (!timeo)
-			goto out;
+			goto out_err;
 
 		error = wait_for_connect(sk, timeo);
 		if (error)
-			goto out;
+			goto out_err;
 	}
 
-	req = tp->accept_queue;
-	if ((tp->accept_queue = req->dl_next) == NULL)
-		tp->accept_queue_tail = NULL;
-
- 	newsk = req->sk;
-	sk_acceptq_removed(sk);
-	__reqsk_free(req);
+	newsk = reqsk_queue_get_child(&tp->accept_queue, sk);
 	BUG_TRAP(newsk->sk_state != TCP_SYN_RECV);
-	release_sock(sk);
-	return newsk;
-
 out:
 	release_sock(sk);
+	return newsk;
+out_err:
+	newsk = NULL;
 	*err = error;
-	return NULL;
+	goto out;
 }
 
 /*
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -529,9 +529,9 @@ static int tcpdiag_dump_reqs(struct sk_b
 
 	entry.family = sk->sk_family;
 
-	read_lock_bh(&tp->syn_wait_lock);
+	read_lock_bh(&tp->accept_queue.syn_wait_lock);
 
-	lopt = tp->listen_opt;
+	lopt = tp->accept_queue.listen_opt;
 	if (!lopt || !lopt->qlen)
 		goto out;
 
@@ -588,7 +588,7 @@ static int tcpdiag_dump_reqs(struct sk_b
 	}
 
 out:
-	read_unlock_bh(&tp->syn_wait_lock);
+	read_unlock_bh(&tp->accept_queue.syn_wait_lock);
 
 	return err;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -874,7 +874,7 @@ static struct request_sock *tcp_v4_searc
 					      __u16 rport,
 					      __u32 raddr, __u32 laddr)
 {
-	struct tcp_listen_opt *lopt = tp->listen_opt;
+	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
 	struct request_sock *req, **prev;
 
 	for (prev = &lopt->syn_table[tcp_v4_synq_hash(raddr, rport, lopt->hash_rnd)];
@@ -898,18 +898,10 @@ static struct request_sock *tcp_v4_searc
 static void tcp_v4_synq_add(struct sock *sk, struct request_sock *req)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt = tp->listen_opt;
+	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
 	u32 h = tcp_v4_synq_hash(inet_rsk(req)->rmt_addr, inet_rsk(req)->rmt_port, lopt->hash_rnd);
 
-	req->expires = jiffies + TCP_TIMEOUT_INIT;
-	req->retrans = 0;
-	req->sk = NULL;
-	req->dl_next = lopt->syn_table[h];
-
-	write_lock(&tp->syn_wait_lock);
-	lopt->syn_table[h] = req;
-	write_unlock(&tp->syn_wait_lock);
-
+	reqsk_queue_hash_req(&tp->accept_queue, h, req, TCP_TIMEOUT_INIT);
 	tcp_synq_added(sk);
 }
 
@@ -2167,17 +2159,17 @@ static void *listening_get_next(struct s
 			if (++st->sbucket >= TCP_SYNQ_HSIZE)
 				break;
 get_req:
-			req = tp->listen_opt->syn_table[st->sbucket];
+			req = tp->accept_queue.listen_opt->syn_table[st->sbucket];
 		}
 		sk	  = sk_next(st->syn_wait_sk);
 		st->state = TCP_SEQ_STATE_LISTENING;
-		read_unlock_bh(&tp->syn_wait_lock);
+		read_unlock_bh(&tp->accept_queue.syn_wait_lock);
 	} else {
 	       	tp = tcp_sk(sk);
-		read_lock_bh(&tp->syn_wait_lock);
-		if (tp->listen_opt && tp->listen_opt->qlen)
+		read_lock_bh(&tp->accept_queue.syn_wait_lock);
+		if (reqsk_queue_len(&tp->accept_queue))
 			goto start_req;
-		read_unlock_bh(&tp->syn_wait_lock);
+		read_unlock_bh(&tp->accept_queue.syn_wait_lock);
 		sk = sk_next(sk);
 	}
 get_sk:
@@ -2187,8 +2179,8 @@ get_sk:
 			goto out;
 		}
 	       	tp = tcp_sk(sk);
-		read_lock_bh(&tp->syn_wait_lock);
-		if (tp->listen_opt && tp->listen_opt->qlen) {
+		read_lock_bh(&tp->accept_queue.syn_wait_lock);
+		if (reqsk_queue_len(&tp->accept_queue)) {
 start_req:
 			st->uid		= sock_i_uid(sk);
 			st->syn_wait_sk = sk;
@@ -2196,7 +2188,7 @@ start_req:
 			st->sbucket	= 0;
 			goto get_req;
 		}
-		read_unlock_bh(&tp->syn_wait_lock);
+		read_unlock_bh(&tp->accept_queue.syn_wait_lock);
 	}
 	if (++st->bucket < TCP_LHTABLE_SIZE) {
 		sk = sk_head(&tcp_listening_hash[st->bucket]);
@@ -2383,7 +2375,7 @@ static void tcp_seq_stop(struct seq_file
 	case TCP_SEQ_STATE_OPENREQ:
 		if (v) {
 			struct tcp_sock *tp = tcp_sk(st->syn_wait_sk);
-			read_unlock_bh(&tp->syn_wait_lock);
+			read_unlock_bh(&tp->accept_queue.syn_wait_lock);
 		}
 	case TCP_SEQ_STATE_LISTENING:
 		if (v != SEQ_START_TOKEN)
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -790,10 +790,8 @@ struct sock *tcp_create_openreq_child(st
 		newtp->probes_out = 0;
 		newtp->rx_opt.num_sacks = 0;
 		newtp->urg_data = 0;
-		newtp->listen_opt = NULL;
-		newtp->accept_queue = newtp->accept_queue_tail = NULL;
-		/* Deinitialize syn_wait_lock to trap illegal accesses. */
-		memset(&newtp->syn_wait_lock, 0, sizeof(newtp->syn_wait_lock));
+		/* Deinitialize accept_queue to trap illegal accesses. */
+		memset(&newtp->accept_queue, 0, sizeof(newtp->accept_queue));
 
 		/* Back to base struct sock members. */
 		newsk->sk_err = 0;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -464,7 +464,7 @@ out_unlock:
 static void tcp_synack_timer(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt = tp->listen_opt;
+	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
 	int max_retries = tp->syn_retries ? : sysctl_tcp_synack_retries;
 	int thresh = max_retries;
 	unsigned long now = jiffies;
@@ -527,12 +527,8 @@ static void tcp_synack_timer(struct sock
 				}
 
 				/* Drop this request */
-				write_lock(&tp->syn_wait_lock);
-				*reqp = req->dl_next;
-				write_unlock(&tp->syn_wait_lock);
-				lopt->qlen--;
-				if (req->retrans == 0)
-					lopt->qlen_young--;
+				tcp_synq_unlink(tp, req, reqp);
+				reqsk_queue_removed(&tp->accept_queue, req);
 				reqsk_free(req);
 				continue;
 			}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -401,7 +401,7 @@ static struct request_sock *tcp_v6_searc
 					      struct in6_addr *laddr,
 					      int iif)
 {
-	struct tcp_listen_opt *lopt = tp->listen_opt;
+	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
 	struct request_sock *req, **prev;  
 
 	for (prev = &lopt->syn_table[tcp_v6_synq_hash(raddr, rport, lopt->hash_rnd)];
@@ -1267,18 +1267,10 @@ static struct sock *tcp_v6_hnd_req(struc
 static void tcp_v6_synq_add(struct sock *sk, struct request_sock *req)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt = tp->listen_opt;
+	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
 	u32 h = tcp_v6_synq_hash(&tcp6_rsk(req)->rmt_addr, inet_rsk(req)->rmt_port, lopt->hash_rnd);
 
-	req->sk = NULL;
-	req->expires = jiffies + TCP_TIMEOUT_INIT;
-	req->retrans = 0;
-	req->dl_next = lopt->syn_table[h];
-
-	write_lock(&tp->syn_wait_lock);
-	lopt->syn_table[h] = req;
-	write_unlock(&tp->syn_wait_lock);
-
+	reqsk_queue_hash_req(&tp->accept_queue, h, req, TCP_TIMEOUT_INIT);
 	tcp_synq_added(sk);
 }
 
