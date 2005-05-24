From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [PATCH 2/2][NET] rename struct tcp_listen_opt to struct listen_sock
Date: Mon, 23 May 2005 22:17:58 -0300
Message-ID: <20050524011758.GJ26989@conectiva.com.br>
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
	
Best Regards,

- Arnaldo

tree b1aabc6ec772af37643e4eab8d35a48f5ca5d799
parent a48a17a6700bb4e6eed677e25422adf478f85c4d
author Arnaldo Carvalho de Melo <acme@ghostprotocols.net> 1113624884 -0300
committer Arnaldo Carvalho de Melo <acme@ghostprotocols.net> 1116888488 -0300

[NET] rename struct tcp_listen_opt to struct listen_sock

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

------------------------------------------------------------------------------

 include/net/request_sock.h |   16 ++++++++--------
 net/core/request_sock.c    |    4 ++--
 net/ipv4/tcp.c             |    2 +-
 net/ipv4/tcp_diag.c        |    2 +-
 net/ipv4/tcp_ipv4.c        |    4 ++--
 net/ipv4/tcp_timer.c       |    2 +-
 net/ipv6/tcp_ipv6.c        |    4 ++--
 7 files changed, 17 insertions(+), 17 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -78,11 +78,11 @@ static inline void reqsk_free(struct req
 
 extern int sysctl_max_syn_backlog;
 
-/** struct tcp_listen_opt - listen state
+/** struct listen_sock - listen state
  *
  * @max_qlen_log - log_2 of maximal queued SYNs/REQUESTs
  */
-struct tcp_listen_opt {
+struct listen_sock {
 	u8			max_qlen_log;
 	/* 3 bytes hole, try to use */
 	int			qlen;
@@ -111,15 +111,15 @@ struct request_sock_queue {
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
 	rwlock_t		syn_wait_lock;
-	struct tcp_listen_opt	*listen_opt;
+	struct listen_sock	*listen_opt;
 };
 
 extern int reqsk_queue_alloc(struct request_sock_queue *queue,
 			     const int nr_table_entries);
 
-static inline struct tcp_listen_opt *reqsk_queue_yank_listen_sk(struct request_sock_queue *queue)
+static inline struct listen_sock *reqsk_queue_yank_listen_sk(struct request_sock_queue *queue)
 {
-	struct tcp_listen_opt *lopt;
+	struct listen_sock *lopt;
 
 	write_lock_bh(&queue->syn_wait_lock);
 	lopt = queue->listen_opt;
@@ -203,7 +203,7 @@ static inline struct sock *reqsk_queue_g
 static inline int reqsk_queue_removed(struct request_sock_queue *queue,
 				      struct request_sock *req)
 {
-	struct tcp_listen_opt *lopt = queue->listen_opt;
+	struct listen_sock *lopt = queue->listen_opt;
 
 	if (req->retrans == 0)
 		--lopt->qlen_young;
@@ -213,7 +213,7 @@ static inline int reqsk_queue_removed(st
 
 static inline int reqsk_queue_added(struct request_sock_queue *queue)
 {
-	struct tcp_listen_opt *lopt = queue->listen_opt;
+	struct listen_sock *lopt = queue->listen_opt;
 	const int prev_qlen = lopt->qlen;
 
 	lopt->qlen_young++;
@@ -240,7 +240,7 @@ static inline void reqsk_queue_hash_req(
 					u32 hash, struct request_sock *req,
 					unsigned timeout)
 {
-	struct tcp_listen_opt *lopt = queue->listen_opt;
+	struct listen_sock *lopt = queue->listen_opt;
 
 	req->expires = jiffies + timeout;
 	req->retrans = 0;
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -21,9 +21,9 @@
 int reqsk_queue_alloc(struct request_sock_queue *queue,
 		      const int nr_table_entries)
 {
-	const int lopt_size = sizeof(struct tcp_listen_opt) +
+	const int lopt_size = sizeof(struct listen_sock) +
 			      nr_table_entries * sizeof(struct request_sock *);
-	struct tcp_listen_opt *lopt = kmalloc(lopt_size, GFP_KERNEL);
+	struct listen_sock *lopt = kmalloc(lopt_size, GFP_KERNEL);
 
 	if (lopt == NULL)
 		return -ENOMEM;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -499,7 +499,7 @@ int tcp_listen_start(struct sock *sk)
 static void tcp_listen_stop (struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt;
+	struct listen_sock *lopt;
 	struct request_sock *acc_req;
 	struct request_sock *req;
 	int i;
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -514,7 +514,7 @@ static int tcpdiag_dump_reqs(struct sk_b
 	struct tcpdiag_entry entry;
 	struct tcpdiagreq *r = NLMSG_DATA(cb->nlh);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt;
+	struct listen_sock *lopt;
 	struct rtattr *bc = NULL;
 	struct inet_sock *inet = inet_sk(sk);
 	int j, s_j;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -874,7 +874,7 @@ static struct request_sock *tcp_v4_searc
 					      __u16 rport,
 					      __u32 raddr, __u32 laddr)
 {
-	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
+	struct listen_sock *lopt = tp->accept_queue.listen_opt;
 	struct request_sock *req, **prev;
 
 	for (prev = &lopt->syn_table[tcp_v4_synq_hash(raddr, rport, lopt->hash_rnd)];
@@ -898,7 +898,7 @@ static struct request_sock *tcp_v4_searc
 static void tcp_v4_synq_add(struct sock *sk, struct request_sock *req)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
+	struct listen_sock *lopt = tp->accept_queue.listen_opt;
 	u32 h = tcp_v4_synq_hash(inet_rsk(req)->rmt_addr, inet_rsk(req)->rmt_port, lopt->hash_rnd);
 
 	reqsk_queue_hash_req(&tp->accept_queue, h, req, TCP_TIMEOUT_INIT);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -464,7 +464,7 @@ out_unlock:
 static void tcp_synack_timer(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
+	struct listen_sock *lopt = tp->accept_queue.listen_opt;
 	int max_retries = tp->syn_retries ? : sysctl_tcp_synack_retries;
 	int thresh = max_retries;
 	unsigned long now = jiffies;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -401,7 +401,7 @@ static struct request_sock *tcp_v6_searc
 					      struct in6_addr *laddr,
 					      int iif)
 {
-	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
+	struct listen_sock *lopt = tp->accept_queue.listen_opt;
 	struct request_sock *req, **prev;  
 
 	for (prev = &lopt->syn_table[tcp_v6_synq_hash(raddr, rport, lopt->hash_rnd)];
@@ -1267,7 +1267,7 @@ static struct sock *tcp_v6_hnd_req(struc
 static void tcp_v6_synq_add(struct sock *sk, struct request_sock *req)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcp_listen_opt *lopt = tp->accept_queue.listen_opt;
+	struct listen_sock *lopt = tp->accept_queue.listen_opt;
 	u32 h = tcp_v6_synq_hash(&tcp6_rsk(req)->rmt_addr, inet_rsk(req)->rmt_port, lopt->hash_rnd);
 
 	reqsk_queue_hash_req(&tp->accept_queue, h, req, TCP_TIMEOUT_INIT);
