From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] inet: get rid of central tcp/dccp listener timer
Date: Thu, 19 Mar 2015 19:04:20 -0700
Message-ID: <1426817061-21421-3-git-send-email-edumazet@google.com>
References: <1426817061-21421-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:34168 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbbCTCEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:04:40 -0400
Received: by iebtr6 with SMTP id tr6so5777753ieb.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 19:04:40 -0700 (PDT)
In-Reply-To: <1426817061-21421-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the major issue for TCP is the SYNACK rtx handling,
done by inet_csk_reqsk_queue_prune(), fired by the keepalive
timer of a TCP_LISTEN socket.

This function runs for awful long times, with socket lock held,
meaning that other cpus needing this lock have to spin for hundred of ms.

SYNACK are sent in huge bursts, likely to cause severe drops anyway.

This model was OK 15 years ago when memory was very tight.

We now can afford to have a timer per request sock.

Timer invocations no longer need to lock the listener,
and can be run from all cpus in parallel.

With following patch increasing somaxconn width to 32 bits,
I tested a listener with more than 4 million active request sockets,
and a steady SYNFLOOD of ~200,000 SYN per second.
Host was sending ~830,000 SYNACK per second.

This is ~100 times more what we could achieve before this patch.

Later, we will get rid of the listener hash and use ehash instead.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet6_connection_sock.h |   2 +-
 include/net/inet_connection_sock.h  |  15 ++--
 include/net/request_sock.h          |  87 +++++++++++-----------
 net/core/request_sock.c             |  13 ++--
 net/core/sock.c                     |   2 +-
 net/dccp/ipv4.c                     |  10 ++-
 net/dccp/ipv6.c                     |  12 ++--
 net/dccp/timer.c                    |  24 +------
 net/ipv4/inet_connection_sock.c     | 139 ++++++++++++++++++------------------
 net/ipv4/inet_diag.c                |   4 +-
 net/ipv4/syncookies.c               |   1 -
 net/ipv4/tcp_fastopen.c             |   2 +-
 net/ipv4/tcp_ipv4.c                 |  11 ++-
 net/ipv4/tcp_minisocks.c            |   5 +-
 net/ipv4/tcp_timer.c                |  12 +---
 net/ipv6/inet6_connection_sock.c    |  19 ++---
 net/ipv6/syncookies.c               |   1 -
 net/ipv6/tcp_ipv6.c                 |  12 ++--
 18 files changed, 173 insertions(+), 198 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 15bd40878d2a..6d539e4e5ba7 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -28,7 +28,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 struct dst_entry *inet6_csk_route_req(struct sock *sk, struct flowi6 *fl6,
 				      const struct request_sock *req);
 
-struct request_sock *inet6_csk_search_req(const struct sock *sk,
+struct request_sock *inet6_csk_search_req(struct sock *sk,
 					  const __be16 rport,
 					  const struct in6_addr *raddr,
 					  const struct in6_addr *laddr,
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 423a46106e57..7b5887cd1172 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -256,7 +256,7 @@ inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
 
 struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
-struct request_sock *inet_csk_search_req(const struct sock *sk,
+struct request_sock *inet_csk_search_req(struct sock *sk,
 					 const __be16 rport,
 					 const __be32 raddr,
 					 const __be32 laddr);
@@ -282,15 +282,13 @@ void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 static inline void inet_csk_reqsk_queue_removed(struct sock *sk,
 						struct request_sock *req)
 {
-	if (reqsk_queue_removed(&inet_csk(sk)->icsk_accept_queue, req) == 0)
-		inet_csk_delete_keepalive_timer(sk);
+	reqsk_queue_removed(&inet_csk(sk)->icsk_accept_queue, req);
 }
 
 static inline void inet_csk_reqsk_queue_added(struct sock *sk,
 					      const unsigned long timeout)
 {
-	if (reqsk_queue_added(&inet_csk(sk)->icsk_accept_queue) == 0)
-		inet_csk_reset_keepalive_timer(sk, timeout);
+	reqsk_queue_added(&inet_csk(sk)->icsk_accept_queue);
 }
 
 static inline int inet_csk_reqsk_queue_len(const struct sock *sk)
@@ -319,14 +317,9 @@ static inline void inet_csk_reqsk_queue_drop(struct sock *sk,
 {
 	inet_csk_reqsk_queue_unlink(sk, req);
 	inet_csk_reqsk_queue_removed(sk, req);
-	reqsk_free(req);
+	reqsk_put(req);
 }
 
-void inet_csk_reqsk_queue_prune(struct sock *parent,
-				const unsigned long interval,
-				const unsigned long timeout,
-				const unsigned long max_rto);
-
 void inet_csk_destroy_sock(struct sock *sk);
 void inet_csk_prepare_forced_close(struct sock *sk);
 
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 65223905d139..6a91261d9b7b 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -62,7 +62,7 @@ struct request_sock {
 	u32				window_clamp; /* window clamp at creation time */
 	u32				rcv_wnd;	  /* rcv_wnd offered first time */
 	u32				ts_recent;
-	unsigned long			expires;
+	struct timer_list		rsk_timer;
 	const struct request_sock_ops	*rsk_ops;
 	struct sock			*sk;
 	u32				secid;
@@ -110,9 +110,6 @@ static inline void reqsk_free(struct request_sock *req)
 
 static inline void reqsk_put(struct request_sock *req)
 {
-	/* temporary debugging, until req sock are put into ehash table */
-	WARN_ON_ONCE(atomic_read(&req->rsk_refcnt) != 1);
-
 	if (atomic_dec_and_test(&req->rsk_refcnt))
 		reqsk_free(req);
 }
@@ -124,12 +121,16 @@ extern int sysctl_max_syn_backlog;
  * @max_qlen_log - log_2 of maximal queued SYNs/REQUESTs
  */
 struct listen_sock {
-	u8			max_qlen_log;
+	int			qlen_inc; /* protected by listener lock */
+	int			young_inc;/* protected by listener lock */
+
+	/* following fields can be updated by timer */
+	atomic_t		qlen_dec; /* qlen = qlen_inc - qlen_dec */
+	atomic_t		young_dec;
+
+	u8			max_qlen_log ____cacheline_aligned_in_smp;
 	u8			synflood_warned;
 	/* 2 bytes hole, try to use */
-	int			qlen;
-	int			qlen_young;
-	int			clock_hand;
 	u32			hash_rnd;
 	u32			nr_table_entries;
 	struct request_sock	*syn_table[0];
@@ -182,9 +183,7 @@ struct fastopen_queue {
 struct request_sock_queue {
 	struct request_sock	*rskq_accept_head;
 	struct request_sock	*rskq_accept_tail;
-	rwlock_t		syn_wait_lock;
 	u8			rskq_defer_accept;
-	/* 3 bytes hole, try to pack */
 	struct listen_sock	*listen_opt;
 	struct fastopen_queue	*fastopenq; /* This is non-NULL iff TFO has been
 					     * enabled on this listener. Check
@@ -192,6 +191,9 @@ struct request_sock_queue {
 					     * to determine if TFO is enabled
 					     * right at this moment.
 					     */
+
+	/* temporary alignment, our goal is to get rid of this lock */
+	rwlock_t		syn_wait_lock ____cacheline_aligned_in_smp;
 };
 
 int reqsk_queue_alloc(struct request_sock_queue *queue,
@@ -223,11 +225,15 @@ static inline void reqsk_queue_unlink(struct request_sock_queue *queue,
 	struct request_sock **prev;
 
 	write_lock(&queue->syn_wait_lock);
+
 	prev = &lopt->syn_table[req->rsk_hash];
 	while (*prev != req)
 		prev = &(*prev)->dl_next;
 	*prev = req->dl_next;
+
 	write_unlock(&queue->syn_wait_lock);
+	if (del_timer(&req->rsk_timer))
+		reqsk_put(req);
 }
 
 static inline void reqsk_queue_add(struct request_sock_queue *queue,
@@ -260,64 +266,53 @@ static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue
 	return req;
 }
 
-static inline int reqsk_queue_removed(struct request_sock_queue *queue,
-				      struct request_sock *req)
+static inline void reqsk_queue_removed(struct request_sock_queue *queue,
+				       const struct request_sock *req)
 {
 	struct listen_sock *lopt = queue->listen_opt;
 
 	if (req->num_timeout == 0)
-		--lopt->qlen_young;
-
-	return --lopt->qlen;
+		atomic_inc(&lopt->young_dec);
+	atomic_inc(&lopt->qlen_dec);
 }
 
-static inline int reqsk_queue_added(struct request_sock_queue *queue)
+static inline void reqsk_queue_added(struct request_sock_queue *queue)
 {
 	struct listen_sock *lopt = queue->listen_opt;
-	const int prev_qlen = lopt->qlen;
 
-	lopt->qlen_young++;
-	lopt->qlen++;
-	return prev_qlen;
+	lopt->young_inc++;
+	lopt->qlen_inc++;
 }
 
-static inline int reqsk_queue_len(const struct request_sock_queue *queue)
+static inline int listen_sock_qlen(const struct listen_sock *lopt)
 {
-	return queue->listen_opt != NULL ? queue->listen_opt->qlen : 0;
+	return lopt->qlen_inc - atomic_read(&lopt->qlen_dec);
 }
 
-static inline int reqsk_queue_len_young(const struct request_sock_queue *queue)
+static inline int listen_sock_young(const struct listen_sock *lopt)
 {
-	return queue->listen_opt->qlen_young;
+	return lopt->young_inc - atomic_read(&lopt->young_dec);
 }
 
-static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
+static inline int reqsk_queue_len(const struct request_sock_queue *queue)
 {
-	return queue->listen_opt->qlen >> queue->listen_opt->max_qlen_log;
+	const struct listen_sock *lopt = queue->listen_opt;
+
+	return lopt ? listen_sock_qlen(lopt) : 0;
 }
 
-static inline void reqsk_queue_hash_req(struct request_sock_queue *queue,
-					u32 hash, struct request_sock *req,
-					unsigned long timeout)
+static inline int reqsk_queue_len_young(const struct request_sock_queue *queue)
 {
-	struct listen_sock *lopt = queue->listen_opt;
-
-	req->expires = jiffies + timeout;
-	req->num_retrans = 0;
-	req->num_timeout = 0;
-	req->sk = NULL;
-
-	/* before letting lookups find us, make sure all req fields
-	 * are committed to memory and refcnt initialized.
-	 */
-	smp_wmb();
-	atomic_set(&req->rsk_refcnt, 1);
+	return listen_sock_young(queue->listen_opt);
+}
 
-	req->rsk_hash = hash;
-	write_lock(&queue->syn_wait_lock);
-	req->dl_next = lopt->syn_table[hash];
-	lopt->syn_table[hash] = req;
-	write_unlock(&queue->syn_wait_lock);
+static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
+{
+	return reqsk_queue_len(queue) >> queue->listen_opt->max_qlen_log;
 }
 
+void reqsk_queue_hash_req(struct request_sock_queue *queue,
+			  u32 hash, struct request_sock *req,
+			  unsigned long timeout);
+
 #endif /* _REQUEST_SOCK_H */
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index cc39a2aa663a..cdc0ddd9ac9f 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -94,21 +94,26 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 	/* make all the listen_opt local to us */
 	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
 
-	if (lopt->qlen != 0) {
+	if (listen_sock_qlen(lopt) != 0) {
 		unsigned int i;
 
 		for (i = 0; i < lopt->nr_table_entries; i++) {
 			struct request_sock *req;
 
+			write_lock_bh(&queue->syn_wait_lock);
 			while ((req = lopt->syn_table[i]) != NULL) {
 				lopt->syn_table[i] = req->dl_next;
-				lopt->qlen--;
+				atomic_inc(&lopt->qlen_dec);
+				if (del_timer(&req->rsk_timer))
+					reqsk_put(req);
 				reqsk_put(req);
 			}
+			write_unlock_bh(&queue->syn_wait_lock);
 		}
 	}
 
-	WARN_ON(lopt->qlen != 0);
+	if (WARN_ON(listen_sock_qlen(lopt) != 0))
+		pr_err("qlen %u\n", listen_sock_qlen(lopt));
 	kvfree(lopt);
 }
 
@@ -187,7 +192,7 @@ void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 	 *
 	 * For more details see CoNext'11 "TCP Fast Open" paper.
 	 */
-	req->expires = jiffies + 60*HZ;
+	req->rsk_timer.expires = jiffies + 60*HZ;
 	if (fastopenq->rskq_rst_head == NULL)
 		fastopenq->rskq_rst_head = req;
 	else
diff --git a/net/core/sock.c b/net/core/sock.c
index d9f9e4825362..744a04ddb61c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2739,7 +2739,7 @@ static int req_prot_init(const struct proto *prot)
 
 	rsk_prot->slab = kmem_cache_create(rsk_prot->slab_name,
 					   rsk_prot->obj_size, 0,
-					   SLAB_HWCACHE_ALIGN, NULL);
+					   0, NULL);
 
 	if (!rsk_prot->slab) {
 		pr_crit("%s: Can't create request sock SLAB cache!\n",
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5bffbbaf1fac..25a9615b3b88 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -306,6 +306,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		if (!between48(seq, dccp_rsk(req)->dreq_iss,
 				    dccp_rsk(req)->dreq_gss)) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
+			reqsk_put(req);
 			goto out;
 		}
 		/*
@@ -315,6 +316,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		 * errors returned from accept().
 		 */
 		inet_csk_reqsk_queue_drop(sk, req);
+		reqsk_put(req);
 		goto out;
 
 	case DCCP_REQUESTING:
@@ -451,9 +453,11 @@ static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	/* Find possible connection requests. */
 	struct request_sock *req = inet_csk_search_req(sk, dh->dccph_sport,
 						       iph->saddr, iph->daddr);
-	if (req)
-		return dccp_check_req(sk, skb, req);
-
+	if (req) {
+		nsk = dccp_check_req(sk, skb, req);
+		reqsk_put(req);
+		return nsk;
+	}
 	nsk = inet_lookup_established(sock_net(sk), &dccp_hashinfo,
 				      iph->saddr, dh->dccph_sport,
 				      iph->daddr, dh->dccph_dport,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index ae2184039fe3..69d8f13895ba 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -157,7 +157,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		req = inet6_csk_search_req(sk, dh->dccph_dport,
 					   &hdr->daddr, &hdr->saddr,
 					   inet6_iif(skb));
-		if (req == NULL)
+		if (!req)
 			goto out;
 
 		/*
@@ -169,10 +169,12 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		if (!between48(seq, dccp_rsk(req)->dreq_iss,
 				    dccp_rsk(req)->dreq_gss)) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
+			reqsk_put(req);
 			goto out;
 		}
 
 		inet_csk_reqsk_queue_drop(sk, req);
+		reqsk_put(req);
 		goto out;
 
 	case DCCP_REQUESTING:
@@ -322,9 +324,11 @@ static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 
 	req = inet6_csk_search_req(sk, dh->dccph_sport, &iph->saddr,
 				   &iph->daddr, inet6_iif(skb));
-	if (req != NULL)
-		return dccp_check_req(sk, skb, req);
-
+	if (req) {
+		nsk = dccp_check_req(sk, skb, req);
+		reqsk_put(req);
+		return nsk;
+	}
 	nsk = __inet6_lookup_established(sock_net(sk), &dccp_hashinfo,
 					 &iph->saddr, dh->dccph_sport,
 					 &iph->daddr, ntohs(dh->dccph_dport),
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 1cd46a345cb0..3ef7acef3ce8 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -161,33 +161,11 @@ out:
 	sock_put(sk);
 }
 
-/*
- *	Timer for listening sockets
- */
-static void dccp_response_timer(struct sock *sk)
-{
-	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL, DCCP_TIMEOUT_INIT,
-				   DCCP_RTO_MAX);
-}
-
 static void dccp_keepalive_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
 
-	/* Only process if socket is not in use. */
-	bh_lock_sock(sk);
-	if (sock_owned_by_user(sk)) {
-		/* Try again later. */
-		inet_csk_reset_keepalive_timer(sk, HZ / 20);
-		goto out;
-	}
-
-	if (sk->sk_state == DCCP_LISTEN) {
-		dccp_response_timer(sk);
-		goto out;
-	}
-out:
-	bh_unlock_sock(sk);
+	pr_err("dccp should not use a keepalive timer !\n");
 	sock_put(sk);
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 4f57a017928c..126a37a156cf 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -23,6 +23,7 @@
 #include <net/route.h>
 #include <net/tcp_states.h>
 #include <net/xfrm.h>
+#include <net/tcp.h>
 
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
@@ -476,31 +477,37 @@ static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
 #if IS_ENABLED(CONFIG_IPV6)
 #define AF_INET_FAMILY(fam) ((fam) == AF_INET)
 #else
-#define AF_INET_FAMILY(fam) 1
+#define AF_INET_FAMILY(fam) true
 #endif
 
-struct request_sock *inet_csk_search_req(const struct sock *sk,
-					 const __be16 rport, const __be32 raddr,
+/* Note: this is temporary :
+ * req sock will no longer be in listener hash table
+*/
+struct request_sock *inet_csk_search_req(struct sock *sk,
+					 const __be16 rport,
+					 const __be32 raddr,
 					 const __be32 laddr)
 {
-	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
 	struct request_sock *req;
+	u32 hash = inet_synq_hash(raddr, rport, lopt->hash_rnd,
+				  lopt->nr_table_entries);
 
-	for (req = lopt->syn_table[inet_synq_hash(raddr, rport, lopt->hash_rnd,
-						  lopt->nr_table_entries)];
-	     req != NULL;
-	     req = req->dl_next) {
+	write_lock(&icsk->icsk_accept_queue.syn_wait_lock);
+	for (req = lopt->syn_table[hash]; req != NULL; req = req->dl_next) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 
 		if (ireq->ir_rmt_port == rport &&
 		    ireq->ir_rmt_addr == raddr &&
 		    ireq->ir_loc_addr == laddr &&
 		    AF_INET_FAMILY(req->rsk_ops->family)) {
+			atomic_inc(&req->rsk_refcnt);
 			WARN_ON(req->sk);
 			break;
 		}
 	}
+	write_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	return req;
 }
@@ -556,23 +563,23 @@ int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req)
 }
 EXPORT_SYMBOL(inet_rtx_syn_ack);
 
-void inet_csk_reqsk_queue_prune(struct sock *parent,
-				const unsigned long interval,
-				const unsigned long timeout,
-				const unsigned long max_rto)
+static void reqsk_timer_handler(unsigned long data)
 {
-	struct inet_connection_sock *icsk = inet_csk(parent);
+	struct request_sock *req = (struct request_sock *)data;
+	struct sock *sk_listener = req->rsk_listener;
+	struct inet_connection_sock *icsk = inet_csk(sk_listener);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
 	struct listen_sock *lopt = queue->listen_opt;
-	int max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
-	int thresh = max_retries;
-	unsigned long now = jiffies;
-	struct request_sock **reqp, *req;
-	int i, budget;
+	int expire = 0, resend = 0;
+	int max_retries, thresh;
 
-	if (lopt == NULL || lopt->qlen == 0)
+	if (sk_listener->sk_state != TCP_LISTEN || !lopt) {
+		reqsk_put(req);
 		return;
+	}
 
+	max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
+	thresh = max_retries;
 	/* Normally all the openreqs are young and become mature
 	 * (i.e. converted to established socket) for first timeout.
 	 * If synack was not acknowledged for 1 second, it means
@@ -590,71 +597,63 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 	 * embrions; and abort old ones without pity, if old
 	 * ones are about to clog our table.
 	 */
-	if (lopt->qlen>>(lopt->max_qlen_log-1)) {
-		int young = (lopt->qlen_young<<1);
+	if (listen_sock_qlen(lopt) >> (lopt->max_qlen_log - 1)) {
+		int young = listen_sock_young(lopt) << 1;
 
 		while (thresh > 2) {
-			if (lopt->qlen < young)
+			if (listen_sock_qlen(lopt) < young)
 				break;
 			thresh--;
 			young <<= 1;
 		}
 	}
-
 	if (queue->rskq_defer_accept)
 		max_retries = queue->rskq_defer_accept;
+	syn_ack_recalc(req, thresh, max_retries, queue->rskq_defer_accept,
+		       &expire, &resend);
+	req->rsk_ops->syn_ack_timeout(sk_listener, req);
+	if (!expire &&
+	    (!resend ||
+	     !inet_rtx_syn_ack(sk_listener, req) ||
+	     inet_rsk(req)->acked)) {
+		unsigned long timeo;
+
+		if (req->num_timeout++ == 0)
+			atomic_inc(&lopt->young_dec);
+		timeo = min(TCP_TIMEOUT_INIT << req->num_timeout, TCP_RTO_MAX);
+		mod_timer_pinned(&req->rsk_timer, jiffies + timeo);
+		return;
+	}
+	inet_csk_reqsk_queue_drop(sk_listener, req);
+	reqsk_put(req);
+}
 
-	budget = 2 * (lopt->nr_table_entries / (timeout / interval));
-	i = lopt->clock_hand;
-
-	do {
-		reqp = &lopt->syn_table[i];
-		if (!*reqp)
-			goto next_bucket;
-		write_lock(&queue->syn_wait_lock);
-		while ((req = *reqp) != NULL) {
-			if (time_after_eq(now, req->expires)) {
-				int expire = 0, resend = 0;
-
-				syn_ack_recalc(req, thresh, max_retries,
-					       queue->rskq_defer_accept,
-					       &expire, &resend);
-				req->rsk_ops->syn_ack_timeout(parent, req);
-				if (!expire &&
-				    (!resend ||
-				     !inet_rtx_syn_ack(parent, req) ||
-				     inet_rsk(req)->acked)) {
-					unsigned long timeo;
-
-					if (req->num_timeout++ == 0)
-						lopt->qlen_young--;
-					timeo = min(timeout << req->num_timeout,
-						    max_rto);
-					req->expires = now + timeo;
-					reqp = &req->dl_next;
-					continue;
-				}
+void reqsk_queue_hash_req(struct request_sock_queue *queue,
+			  u32 hash, struct request_sock *req,
+			  unsigned long timeout)
+{
+	struct listen_sock *lopt = queue->listen_opt;
 
-				/* Drop this request */
-				*reqp = req->dl_next;
-				reqsk_queue_removed(queue, req);
-				reqsk_put(req);
-				continue;
-			}
-			reqp = &req->dl_next;
-		}
-		write_unlock(&queue->syn_wait_lock);
-next_bucket:
-		i = (i + 1) & (lopt->nr_table_entries - 1);
+	req->num_retrans = 0;
+	req->num_timeout = 0;
+	req->sk = NULL;
 
-	} while (--budget > 0);
+	/* before letting lookups find us, make sure all req fields
+	 * are committed to memory and refcnt initialized.
+	 */
+	smp_wmb();
+	atomic_set(&req->rsk_refcnt, 2);
+	setup_timer(&req->rsk_timer, reqsk_timer_handler, (unsigned long)req);
+	req->rsk_hash = hash;
 
-	lopt->clock_hand = i;
+	write_lock(&queue->syn_wait_lock);
+	req->dl_next = lopt->syn_table[hash];
+	lopt->syn_table[hash] = req;
+	write_unlock(&queue->syn_wait_lock);
 
-	if (lopt->qlen)
-		inet_csk_reset_keepalive_timer(parent, interval);
+	mod_timer_pinned(&req->rsk_timer, jiffies + timeout);
 }
-EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_prune);
+EXPORT_SYMBOL(reqsk_queue_hash_req);
 
 /**
  *	inet_csk_clone_lock - clone an inet socket, and lock its clone
@@ -790,8 +789,6 @@ void inet_csk_listen_stop(struct sock *sk)
 	struct request_sock *acc_req;
 	struct request_sock *req;
 
-	inet_csk_delete_keepalive_timer(sk);
-
 	/* make all the listen_opt local to us */
 	acc_req = reqsk_queue_yank_acceptq(queue);
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 74c39c9f3e11..34073bbe2700 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -285,7 +285,7 @@ static int inet_req_diag_fill(struct sock *sk, struct sk_buff *skb,
 	BUILD_BUG_ON(offsetof(struct inet_request_sock, ir_cookie) !=
 		     offsetof(struct sock, sk_cookie));
 
-	tmo = inet_reqsk(sk)->expires - jiffies;
+	tmo = inet_reqsk(sk)->rsk_timer.expires - jiffies;
 	r->idiag_expires = (tmo >= 0) ? jiffies_to_msecs(tmo) : 0;
 	r->idiag_rqueue	= 0;
 	r->idiag_wqueue	= 0;
@@ -719,7 +719,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 	read_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	lopt = icsk->icsk_accept_queue.listen_opt;
-	if (!lopt || !lopt->qlen)
+	if (!lopt || !listen_sock_qlen(lopt))
 		goto out;
 
 	if (bc) {
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index ef01d8570358..805dc444741d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -361,7 +361,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 	}
 
-	req->expires	= 0UL;
 	req->num_retrans = 0;
 
 	/*
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 82e375a0cbcf..2eb887ec0ce3 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -240,7 +240,7 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
 		struct request_sock *req1;
 		spin_lock(&fastopenq->lock);
 		req1 = fastopenq->rskq_rst_head;
-		if ((req1 == NULL) || time_after(req1->expires, jiffies)) {
+		if (!req1 || time_after(req1->rsk_timer.expires, jiffies)) {
 			spin_unlock(&fastopenq->lock);
 			NET_INC_STATS_BH(sock_net(sk),
 					 LINUX_MIB_TCPFASTOPENLISTENOVERFLOW);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 19c3770f1e97..5554b8f33d41 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -475,6 +475,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 
 		if (seq != tcp_rsk(req)->snt_isn) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
+			reqsk_put(req);
 			goto out;
 		}
 
@@ -486,6 +487,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		 */
 		inet_csk_reqsk_queue_drop(sk, req);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+		reqsk_put(req);
 		goto out;
 
 	case TCP_SYN_SENT:
@@ -1398,8 +1400,11 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	struct sock *nsk;
 
 	req = inet_csk_search_req(sk, th->source, iph->saddr, iph->daddr);
-	if (req)
-		return tcp_check_req(sk, skb, req, false);
+	if (req) {
+		nsk = tcp_check_req(sk, skb, req, false);
+		reqsk_put(req);
+		return nsk;
+	}
 
 	nsk = inet_lookup_established(sock_net(sk), &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
@@ -2208,7 +2213,7 @@ static void get_openreq4(const struct request_sock *req,
 			 struct seq_file *f, int i, kuid_t uid)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
-	long delta = req->expires - jiffies;
+	long delta = req->rsk_timer.expires - jiffies;
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK",
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 848bcab358e4..274e96fb369b 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -629,8 +629,9 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 					  &tcp_rsk(req)->last_oow_ack_time) &&
 
 		    !inet_rtx_syn_ack(sk, req))
-			req->expires = min(TCP_TIMEOUT_INIT << req->num_timeout,
-					   TCP_RTO_MAX) + jiffies;
+			mod_timer_pending(&req->rsk_timer, jiffies +
+				min(TCP_TIMEOUT_INIT << req->num_timeout,
+				    TCP_RTO_MAX));
 		return NULL;
 	}
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 15505936511d..3daa6b5d766d 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -539,16 +539,6 @@ static void tcp_write_timer(unsigned long data)
 	sock_put(sk);
 }
 
-/*
- *	Timer for listening sockets
- */
-
-static void tcp_synack_timer(struct sock *sk)
-{
-	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
-				   TCP_TIMEOUT_INIT, TCP_RTO_MAX);
-}
-
 void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req)
 {
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPTIMEOUTS);
@@ -583,7 +573,7 @@ static void tcp_keepalive_timer (unsigned long data)
 	}
 
 	if (sk->sk_state == TCP_LISTEN) {
-		tcp_synack_timer(sk);
+		pr_err("Hmm... keepalive on a LISTEN ???\n");
 		goto out;
 	}
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index b7acb9ebc4f5..2f3bbe569e8f 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -112,21 +112,20 @@ static u32 inet6_synq_hash(const struct in6_addr *raddr, const __be16 rport,
 	return c & (synq_hsize - 1);
 }
 
-struct request_sock *inet6_csk_search_req(const struct sock *sk,
+struct request_sock *inet6_csk_search_req(struct sock *sk,
 					  const __be16 rport,
 					  const struct in6_addr *raddr,
 					  const struct in6_addr *laddr,
 					  const int iif)
 {
-	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
 	struct request_sock *req;
+	u32 hash = inet6_synq_hash(raddr, rport, lopt->hash_rnd,
+				   lopt->nr_table_entries);
 
-	for (req = lopt->syn_table[inet6_synq_hash(raddr, rport,
-						     lopt->hash_rnd,
-						     lopt->nr_table_entries)];
-	     req != NULL;
-	     req = req->dl_next) {
+	write_lock(&icsk->icsk_accept_queue.syn_wait_lock);
+	for (req = lopt->syn_table[hash]; req != NULL; req = req->dl_next) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 
 		if (ireq->ir_rmt_port == rport &&
@@ -134,12 +133,14 @@ struct request_sock *inet6_csk_search_req(const struct sock *sk,
 		    ipv6_addr_equal(&ireq->ir_v6_rmt_addr, raddr) &&
 		    ipv6_addr_equal(&ireq->ir_v6_loc_addr, laddr) &&
 		    (!ireq->ir_iif || ireq->ir_iif == iif)) {
+			atomic_inc(&req->rsk_refcnt);
 			WARN_ON(req->sk != NULL);
-			return req;
+			break;
 		}
 	}
+	write_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
 
-	return NULL;
+	return req;
 }
 EXPORT_SYMBOL_GPL(inet6_csk_search_req);
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index da5823e5e5a7..2819137fc87d 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -222,7 +222,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	ireq->ir_mark = inet_request_mark(sk, skb);
 
-	req->expires = 0UL;
 	req->num_retrans = 0;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 146f123b52c9..6e3f90db038c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -421,11 +421,13 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		if (seq != tcp_rsk(req)->snt_isn) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
+			reqsk_put(req);
 			goto out;
 		}
 
 		inet_csk_reqsk_queue_drop(sk, req);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+		reqsk_put(req);
 		goto out;
 
 	case TCP_SYN_SENT:
@@ -988,9 +990,11 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
 	req = inet6_csk_search_req(sk, th->source,
 				   &ipv6_hdr(skb)->saddr,
 				   &ipv6_hdr(skb)->daddr, tcp_v6_iif(skb));
-	if (req)
-		return tcp_check_req(sk, skb, req, false);
-
+	if (req) {
+		nsk = tcp_check_req(sk, skb, req, false);
+		reqsk_put(req);
+		return nsk;
+	}
 	nsk = __inet6_lookup_established(sock_net(sk), &tcp_hashinfo,
 					 &ipv6_hdr(skb)->saddr, th->source,
 					 &ipv6_hdr(skb)->daddr, ntohs(th->dest),
@@ -1670,7 +1674,7 @@ static void tcp_v6_destroy_sock(struct sock *sk)
 static void get_openreq6(struct seq_file *seq,
 			 struct request_sock *req, int i, kuid_t uid)
 {
-	int ttd = req->expires - jiffies;
+	long ttd = req->rsk_timer.expires - jiffies;
 	const struct in6_addr *src = &inet_rsk(req)->ir_v6_loc_addr;
 	const struct in6_addr *dest = &inet_rsk(req)->ir_v6_rmt_addr;
 
-- 
2.2.0.rc0.207.ga3a616c
