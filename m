From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/17] tcp/dccp: install syn_recv requests into ehash table
Date: Fri,  2 Oct 2015 11:43:32 -0700
Message-ID: <1443811419-4798-11-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32855 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbbJBSoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:14 -0400
Received: by pacex6 with SMTP id ex6so113538701pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:13 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patch, we insert request sockets into TCP/DCCP
regular ehash table (where ESTABLISHED and TIMEWAIT sockets
are) instead of using the per listener hash table.

ACK packets find SYN_RECV pseudo sockets without having
to find and lock the listener.

In nominal conditions, this halves pressure on listener lock.

Note that this will allow for SO_REUSEPORT refinements,
so that we can select a listener using cpu/numa affinities instead
of the prior 'consistent hash', since only SYN packets will
apply this selection logic.

We will shrink listen_sock in the following patch to ease
code review.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ying Cai <ycai@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 include/net/inet_connection_sock.h |   4 --
 include/net/inet_hashtables.h      |   1 +
 include/net/request_sock.h         |   4 --
 include/net/tcp.h                  |   3 -
 net/core/request_sock.c            |  28 +--------
 net/dccp/ipv4.c                    |  64 +++++++-------------
 net/dccp/ipv6.c                    |  72 +++++++----------------
 net/ipv4/inet_connection_sock.c    | 103 +++++++-------------------------
 net/ipv4/inet_diag.c               |  96 +++---------------------------
 net/ipv4/inet_hashtables.c         |  14 ++++-
 net/ipv4/syncookies.c              |   4 ++
 net/ipv4/tcp_input.c               |   2 +-
 net/ipv4/tcp_ipv4.c                | 117 +++++++++++--------------------------
 net/ipv6/inet6_connection_sock.c   |  67 ---------------------
 net/ipv6/tcp_ipv6.c                |  82 ++++++++++++--------------
 15 files changed, 160 insertions(+), 501 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index b2e2e30befa9..730aa034cd3d 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -258,10 +258,6 @@ inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
 
 struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
-struct request_sock *inet_csk_search_req(struct sock *sk,
-					 const __be16 rport,
-					 const __be32 raddr,
-					 const __be32 laddr);
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb, bool relax);
 int inet_csk_get_port(struct sock *sk, unsigned short snum);
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 3fb778d7c875..6683ada25fef 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -205,6 +205,7 @@ void inet_put_port(struct sock *sk);
 
 void inet_hashinfo_init(struct inet_hashinfo *h);
 
+int inet_ehash_insert(struct sock *sk, struct sock *osk);
 void __inet_hash_nolisten(struct sock *sk, struct sock *osk);
 void __inet_hash(struct sock *sk, struct sock *osk);
 void inet_hash(struct sock *sk);
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 97c1ba61ed2d..e1850923c4f5 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -266,8 +266,4 @@ static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
 	return reqsk_queue_len(queue) >> queue->listen_opt->max_qlen_log;
 }
 
-void reqsk_queue_hash_req(struct request_sock_queue *queue,
-			  u32 hash, struct request_sock *req,
-			  unsigned long timeout);
-
 #endif /* _REQUEST_SOCK_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a26341d2ad67..225e9561af35 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1618,7 +1618,6 @@ static inline bool tcp_stream_is_thin(struct tcp_sock *tp)
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
-	TCP_SEQ_STATE_OPENREQ,
 	TCP_SEQ_STATE_ESTABLISHED,
 };
 
@@ -1717,8 +1716,6 @@ struct tcp_request_sock_ops {
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
 			   u16 queue_mapping, struct tcp_fastopen_cookie *foc);
-	void (*queue_hash_add)(struct sock *sk, struct request_sock *req,
-			       const unsigned long timeout);
 };
 
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 5ca624cea04c..a4b305d8ca2b 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -99,35 +99,9 @@ static inline struct listen_sock *reqsk_queue_yank_listen_sk(
 
 void reqsk_queue_destroy(struct request_sock_queue *queue)
 {
-	/* make all the listen_opt local to us */
 	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
 
-	if (reqsk_queue_len(queue) != 0) {
-		unsigned int i;
-
-		for (i = 0; i < lopt->nr_table_entries; i++) {
-			struct request_sock *req;
-
-			spin_lock_bh(&queue->syn_wait_lock);
-			while ((req = lopt->syn_table[i]) != NULL) {
-				lopt->syn_table[i] = req->dl_next;
-				/* Because of following del_timer_sync(),
-				 * we must release the spinlock here
-				 * or risk a dead lock.
-				 */
-				spin_unlock_bh(&queue->syn_wait_lock);
-				atomic_dec(&queue->qlen);
-				if (del_timer_sync(&req->rsk_timer))
-					reqsk_put(req);
-				reqsk_put(req);
-				spin_lock_bh(&queue->syn_wait_lock);
-			}
-			spin_unlock_bh(&queue->syn_wait_lock);
-		}
-	}
-
-	if (WARN_ON(reqsk_queue_len(queue) != 0))
-		pr_err("qlen %u\n", reqsk_queue_len(queue));
+	/* cleaning is done by req timers */
 	kvfree(lopt);
 }
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5b7818c63cec..8910c9567719 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -444,36 +444,6 @@ put_and_exit:
 }
 EXPORT_SYMBOL_GPL(dccp_v4_request_recv_sock);
 
-static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
-{
-	const struct dccp_hdr *dh = dccp_hdr(skb);
-	const struct iphdr *iph = ip_hdr(skb);
-	struct sock *nsk;
-	/* Find possible connection requests. */
-	struct request_sock *req = inet_csk_search_req(sk, dh->dccph_sport,
-						       iph->saddr, iph->daddr);
-	if (req) {
-		nsk = dccp_check_req(sk, skb, req);
-		if (!nsk)
-			reqsk_put(req);
-		return nsk;
-	}
-	nsk = inet_lookup_established(sock_net(sk), &dccp_hashinfo,
-				      iph->saddr, dh->dccph_sport,
-				      iph->daddr, dh->dccph_dport,
-				      inet_iif(skb));
-	if (nsk != NULL) {
-		if (nsk->sk_state != DCCP_TIME_WAIT) {
-			bh_lock_sock(nsk);
-			return nsk;
-		}
-		inet_twsk_put(inet_twsk(nsk));
-		return NULL;
-	}
-
-	return sk;
-}
-
 static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 					   struct sk_buff *skb)
 {
@@ -705,18 +675,6 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	 * NOTE: the check for the packet types is done in
 	 *	 dccp_rcv_state_process
 	 */
-	if (sk->sk_state == DCCP_LISTEN) {
-		struct sock *nsk = dccp_v4_hnd_req(sk, skb);
-
-		if (nsk == NULL)
-			goto discard;
-
-		if (nsk != sk) {
-			if (dccp_child_process(sk, nsk, skb))
-				goto reset;
-			return 0;
-		}
-	}
 
 	if (dccp_rcv_state_process(sk, skb, dh, skb->len))
 		goto reset;
@@ -724,7 +682,6 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 reset:
 	dccp_v4_ctl_send_reset(sk, skb);
-discard:
 	kfree_skb(skb);
 	return 0;
 }
@@ -868,6 +825,27 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 		goto no_dccp_socket;
 	}
 
+	if (sk->sk_state == DCCP_NEW_SYN_RECV) {
+		struct request_sock *req = inet_reqsk(sk);
+		struct sock *nsk = NULL;
+
+		sk = req->rsk_listener;
+		if (sk->sk_state == DCCP_LISTEN)
+			nsk = dccp_check_req(sk, skb, req);
+		if (!nsk) {
+			reqsk_put(req);
+			goto discard_it;
+		}
+		if (nsk == sk) {
+			sock_hold(sk);
+			reqsk_put(req);
+		} else if (dccp_child_process(sk, nsk, skb)) {
+			dccp_v4_ctl_send_reset(sk, skb);
+			goto discard_it;
+		} else {
+			return 0;
+		}
+	}
 	/*
 	 * RFC 4340, sec. 9.2.1: Minimum Checksum Coverage
 	 *	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index e8753aa3b7a4..1361a3f45df7 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -290,37 +290,6 @@ static struct request_sock_ops dccp6_request_sock_ops = {
 	.syn_ack_timeout = dccp_syn_ack_timeout,
 };
 
-static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
-{
-	const struct dccp_hdr *dh = dccp_hdr(skb);
-	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct request_sock *req;
-	struct sock *nsk;
-
-	req = inet6_csk_search_req(sk, dh->dccph_sport, &iph->saddr,
-				   &iph->daddr, inet6_iif(skb));
-	if (req) {
-		nsk = dccp_check_req(sk, skb, req);
-		if (!nsk)
-			reqsk_put(req);
-		return nsk;
-	}
-	nsk = __inet6_lookup_established(sock_net(sk), &dccp_hashinfo,
-					 &iph->saddr, dh->dccph_sport,
-					 &iph->daddr, ntohs(dh->dccph_dport),
-					 inet6_iif(skb));
-	if (nsk != NULL) {
-		if (nsk->sk_state != DCCP_TIME_WAIT) {
-			bh_lock_sock(nsk);
-			return nsk;
-		}
-		inet_twsk_put(inet_twsk(nsk));
-		return NULL;
-	}
-
-	return sk;
-}
-
 static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct request_sock *req;
@@ -398,7 +367,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (dccp_v6_send_response(sk, req))
 		goto drop_and_free;
 
-	inet6_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
+	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
 	return 0;
 
 drop_and_free:
@@ -641,24 +610,6 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	 * NOTE: the check for the packet types is done in
 	 *	 dccp_rcv_state_process
 	 */
-	if (sk->sk_state == DCCP_LISTEN) {
-		struct sock *nsk = dccp_v6_hnd_req(sk, skb);
-
-		if (nsk == NULL)
-			goto discard;
-		/*
-		 * Queue it on the new socket if the new socket is active,
-		 * otherwise we just shortcircuit this and continue with
-		 * the new socket..
-		 */
-		if (nsk != sk) {
-			if (dccp_child_process(sk, nsk, skb))
-				goto reset;
-			if (opt_skb != NULL)
-				__kfree_skb(opt_skb);
-			return 0;
-		}
-	}
 
 	if (dccp_rcv_state_process(sk, skb, dccp_hdr(skb), skb->len))
 		goto reset;
@@ -732,6 +683,27 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 		goto no_dccp_socket;
 	}
 
+	if (sk->sk_state == DCCP_NEW_SYN_RECV) {
+		struct request_sock *req = inet_reqsk(sk);
+		struct sock *nsk = NULL;
+
+		sk = req->rsk_listener;
+		if (sk->sk_state == DCCP_LISTEN)
+			nsk = dccp_check_req(sk, skb, req);
+		if (!nsk) {
+			reqsk_put(req);
+			goto discard_it;
+		}
+		if (nsk == sk) {
+			sock_hold(sk);
+			reqsk_put(req);
+		} else if (dccp_child_process(sk, nsk, skb)) {
+			dccp_v6_ctl_send_reset(sk, skb);
+			goto discard_it;
+		} else {
+			return 0;
+		}
+	}
 	/*
 	 * RFC 4340, sec. 9.2.1: Minimum Checksum Coverage
 	 *	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index e62f04775c93..80904df02187 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -476,65 +476,12 @@ no_route:
 }
 EXPORT_SYMBOL_GPL(inet_csk_route_child_sock);
 
-static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
-				 const u32 rnd, const u32 synq_hsize)
-{
-	return jhash_2words((__force u32)raddr, (__force u32)rport, rnd) & (synq_hsize - 1);
-}
-
 #if IS_ENABLED(CONFIG_IPV6)
 #define AF_INET_FAMILY(fam) ((fam) == AF_INET)
 #else
 #define AF_INET_FAMILY(fam) true
 #endif
 
-/* Note: this is temporary :
- * req sock will no longer be in listener hash table
-*/
-struct request_sock *inet_csk_search_req(struct sock *sk,
-					 const __be16 rport,
-					 const __be32 raddr,
-					 const __be32 laddr)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	struct request_sock *req;
-	u32 hash = inet_synq_hash(raddr, rport, lopt->hash_rnd,
-				  lopt->nr_table_entries);
-
-	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
-	for (req = lopt->syn_table[hash]; req != NULL; req = req->dl_next) {
-		const struct inet_request_sock *ireq = inet_rsk(req);
-
-		if (ireq->ir_rmt_port == rport &&
-		    ireq->ir_rmt_addr == raddr &&
-		    ireq->ir_loc_addr == laddr &&
-		    AF_INET_FAMILY(req->rsk_ops->family)) {
-			atomic_inc(&req->rsk_refcnt);
-			WARN_ON(req->sk);
-			break;
-		}
-	}
-	spin_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
-
-	return req;
-}
-EXPORT_SYMBOL_GPL(inet_csk_search_req);
-
-void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
-				   unsigned long timeout)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	const u32 h = inet_synq_hash(inet_rsk(req)->ir_rmt_addr,
-				     inet_rsk(req)->ir_rmt_port,
-				     lopt->hash_rnd, lopt->nr_table_entries);
-
-	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
-	inet_csk_reqsk_queue_added(sk);
-}
-EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
-
 /* Only thing we need from tcp.h */
 extern int sysctl_tcp_synack_retries;
 
@@ -571,26 +518,20 @@ int inet_rtx_syn_ack(const struct sock *parent, struct request_sock *req)
 }
 EXPORT_SYMBOL(inet_rtx_syn_ack);
 
-/* return true if req was found in the syn_table[] */
+/* return true if req was found in the ehash table */
 static bool reqsk_queue_unlink(struct request_sock_queue *queue,
 			       struct request_sock *req)
 {
-	struct listen_sock *lopt = queue->listen_opt;
-	struct request_sock **prev;
-	bool found = false;
+	struct inet_hashinfo *hashinfo = req_to_sk(req)->sk_prot->h.hashinfo;
+	spinlock_t *lock;
+	bool found;
 
-	spin_lock(&queue->syn_wait_lock);
+	lock = inet_ehash_lockp(hashinfo, req->rsk_hash);
 
-	for (prev = &lopt->syn_table[req->rsk_hash]; *prev != NULL;
-	     prev = &(*prev)->dl_next) {
-		if (*prev == req) {
-			*prev = req->dl_next;
-			found = true;
-			break;
-		}
-	}
+	spin_lock(lock);
+	found = __sk_nulls_del_node_init_rcu(req_to_sk(req));
+	spin_unlock(lock);
 
-	spin_unlock(&queue->syn_wait_lock);
 	if (timer_pending(&req->rsk_timer) && del_timer_sync(&req->rsk_timer))
 		reqsk_put(req);
 	return found;
@@ -616,10 +557,8 @@ static void reqsk_timer_handler(unsigned long data)
 	int max_retries, thresh;
 	u8 defer_accept;
 
-	if (sk_listener->sk_state != TCP_LISTEN || !lopt) {
-		reqsk_put(req);
-		return;
-	}
+	if (sk_listener->sk_state != TCP_LISTEN || !lopt)
+		goto drop;
 
 	max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
 	thresh = max_retries;
@@ -669,36 +608,36 @@ static void reqsk_timer_handler(unsigned long data)
 		mod_timer_pinned(&req->rsk_timer, jiffies + timeo);
 		return;
 	}
+drop:
 	inet_csk_reqsk_queue_drop(sk_listener, req);
 	reqsk_put(req);
 }
 
-void reqsk_queue_hash_req(struct request_sock_queue *queue,
-			  u32 hash, struct request_sock *req,
-			  unsigned long timeout)
+static void reqsk_queue_hash_req(struct request_sock *req,
+				 unsigned long timeout)
 {
-	struct listen_sock *lopt = queue->listen_opt;
-
 	req->num_retrans = 0;
 	req->num_timeout = 0;
 	req->sk = NULL;
 
 	setup_timer(&req->rsk_timer, reqsk_timer_handler, (unsigned long)req);
 	mod_timer_pinned(&req->rsk_timer, jiffies + timeout);
-	req->rsk_hash = hash;
 
+	inet_ehash_insert(req_to_sk(req), NULL);
 	/* before letting lookups find us, make sure all req fields
 	 * are committed to memory and refcnt initialized.
 	 */
 	smp_wmb();
 	atomic_set(&req->rsk_refcnt, 2);
+}
 
-	spin_lock(&queue->syn_wait_lock);
-	req->dl_next = lopt->syn_table[hash];
-	lopt->syn_table[hash] = req;
-	spin_unlock(&queue->syn_wait_lock);
+void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
+				   unsigned long timeout)
+{
+	reqsk_queue_hash_req(req, timeout);
+	inet_csk_reqsk_queue_added(sk);
 }
-EXPORT_SYMBOL(reqsk_queue_hash_req);
+EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
 
 /**
  *	inet_csk_clone_lock - clone an inet socket, and lock its clone
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 0ac1d68dc8a6..ab9f8a66615d 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -730,91 +730,21 @@ static void twsk_build_assert(void)
 #endif
 }
 
-static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
-			       struct netlink_callback *cb,
-			       const struct inet_diag_req_v2 *r,
-			       const struct nlattr *bc)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct inet_sock *inet = inet_sk(sk);
-	struct inet_diag_entry entry;
-	int j, s_j, reqnum, s_reqnum;
-	struct listen_sock *lopt;
-	int err = 0;
-
-	s_j = cb->args[3];
-	s_reqnum = cb->args[4];
-
-	if (s_j > 0)
-		s_j--;
-
-	entry.family = sk->sk_family;
-
-	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
-
-	lopt = icsk->icsk_accept_queue.listen_opt;
-	if (!lopt || !reqsk_queue_len(&icsk->icsk_accept_queue))
-		goto out;
-
-	if (bc) {
-		entry.sport = inet->inet_num;
-		entry.userlocks = sk->sk_userlocks;
-	}
-
-	for (j = s_j; j < lopt->nr_table_entries; j++) {
-		struct request_sock *req, *head = lopt->syn_table[j];
-
-		reqnum = 0;
-		for (req = head; req; reqnum++, req = req->dl_next) {
-			struct inet_request_sock *ireq = inet_rsk(req);
-
-			if (reqnum < s_reqnum)
-				continue;
-			if (r->id.idiag_dport != ireq->ir_rmt_port &&
-			    r->id.idiag_dport)
-				continue;
-
-			if (bc) {
-				/* Note: entry.sport and entry.userlocks are already set */
-				entry_fill_addrs(&entry, req_to_sk(req));
-				entry.dport = ntohs(ireq->ir_rmt_port);
-
-				if (!inet_diag_bc_run(bc, &entry))
-					continue;
-			}
-
-			err = inet_req_diag_fill(req_to_sk(req), skb,
-						 NETLINK_CB(cb->skb).portid,
-						 cb->nlh->nlmsg_seq,
-						 NLM_F_MULTI, cb->nlh);
-			if (err < 0) {
-				cb->args[3] = j + 1;
-				cb->args[4] = reqnum;
-				goto out;
-			}
-		}
-
-		s_reqnum = 0;
-	}
-
-out:
-	spin_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
-
-	return err;
-}
-
 void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			 struct netlink_callback *cb,
 			 const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	struct net *net = sock_net(skb->sk);
 	int i, num, s_i, s_num;
+	u32 idiag_states = r->idiag_states;
 
+	if (idiag_states & TCPF_SYN_RECV)
+		idiag_states |= TCPF_NEW_SYN_RECV;
 	s_i = cb->args[1];
 	s_num = num = cb->args[2];
 
 	if (cb->args[0] == 0) {
-		if (!(r->idiag_states & (TCPF_LISTEN | TCPF_SYN_RECV)))
+		if (!(idiag_states & TCPF_LISTEN))
 			goto skip_listen_ht;
 
 		for (i = s_i; i < INET_LHTABLE_SIZE; i++) {
@@ -844,21 +774,11 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 				    r->id.idiag_sport)
 					goto next_listen;
 
-				if (!(r->idiag_states & TCPF_LISTEN) ||
-				    r->id.idiag_dport ||
+				if (r->id.idiag_dport ||
 				    cb->args[3] > 0)
-					goto syn_recv;
-
-				if (inet_csk_diag_dump(sk, skb, cb, r, bc) < 0) {
-					spin_unlock_bh(&ilb->lock);
-					goto done;
-				}
-
-syn_recv:
-				if (!(r->idiag_states & TCPF_SYN_RECV))
 					goto next_listen;
 
-				if (inet_diag_dump_reqs(skb, sk, cb, r, bc) < 0) {
+				if (inet_csk_diag_dump(sk, skb, cb, r, bc) < 0) {
 					spin_unlock_bh(&ilb->lock);
 					goto done;
 				}
@@ -879,7 +799,7 @@ skip_listen_ht:
 		s_i = num = s_num = 0;
 	}
 
-	if (!(r->idiag_states & ~(TCPF_LISTEN | TCPF_SYN_RECV)))
+	if (!(idiag_states & ~TCPF_LISTEN))
 		goto out;
 
 	for (i = s_i; i <= hashinfo->ehash_mask; i++) {
@@ -906,7 +826,7 @@ skip_listen_ht:
 				goto next_normal;
 			state = (sk->sk_state == TCP_TIME_WAIT) ?
 				inet_twsk(sk)->tw_substate : sk->sk_state;
-			if (!(r->idiag_states & (1 << state)))
+			if (!(idiag_states & (1 << state)))
 				goto next_normal;
 			if (r->sdiag_family != AF_UNSPEC &&
 			    sk->sk_family != r->sdiag_family)
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 56742e995dd3..bed8886a4b6c 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -398,14 +398,18 @@ static u32 inet_sk_port_offset(const struct sock *sk)
 					  inet->inet_dport);
 }
 
-void __inet_hash_nolisten(struct sock *sk, struct sock *osk)
+/* insert a socket into ehash, and eventually remove another one
+ * (The another one can be a SYN_RECV or TIMEWAIT
+ */
+int inet_ehash_insert(struct sock *sk, struct sock *osk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_nulls_head *list;
 	struct inet_ehash_bucket *head;
 	spinlock_t *lock;
+	int ret = 0;
 
-	WARN_ON(!sk_unhashed(sk));
+	WARN_ON_ONCE(!sk_unhashed(sk));
 
 	sk->sk_hash = sk_ehashfn(sk);
 	head = inet_ehash_bucket(hashinfo, sk->sk_hash);
@@ -419,6 +423,12 @@ void __inet_hash_nolisten(struct sock *sk, struct sock *osk)
 		sk_nulls_del_node_init_rcu(osk);
 	}
 	spin_unlock(lock);
+	return ret;
+}
+
+void __inet_hash_nolisten(struct sock *sk, struct sock *osk)
+{
+	inet_ehash_insert(sk, osk);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 }
 EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 6b97b5f6457c..729ceb5f63c6 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -284,6 +284,10 @@ bool cookie_ecn_ok(const struct tcp_options_received *tcp_opt,
 }
 EXPORT_SYMBOL(cookie_ecn_ok);
 
+/* On input, sk is a listener.
+ * Output is listener if incoming packet would not create a child
+ *           NULL if memory could not be allocated.
+ */
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip_options *opt = &TCP_SKB_CB(skb)->header.h4.opt;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8b0ce73c2049..a56912772354 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6241,7 +6241,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			goto drop_and_free;
 
 		tcp_rsk(req)->tfo_listener = false;
-		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	}
 	tcp_reqsk_record_syn(sk, req, skb);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a33101616215..bfe9d39ee87d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1224,7 +1224,6 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.route_req	=	tcp_v4_route_req,
 	.init_seq	=	tcp_v4_init_sequence,
 	.send_synack	=	tcp_v4_send_synack,
-	.queue_hash_add =	inet_csk_reqsk_queue_hash_add,
 };
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
@@ -1343,34 +1342,11 @@ put_and_exit:
 }
 EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
 
-static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
+static struct sock *tcp_v4_cookie_check(struct sock *sk, struct sk_buff *skb)
 {
+#ifdef CONFIG_SYN_COOKIES
 	const struct tcphdr *th = tcp_hdr(skb);
-	const struct iphdr *iph = ip_hdr(skb);
-	struct request_sock *req;
-	struct sock *nsk;
-
-	req = inet_csk_search_req(sk, th->source, iph->saddr, iph->daddr);
-	if (req) {
-		nsk = tcp_check_req(sk, skb, req, false);
-		if (!nsk || nsk == sk)
-			reqsk_put(req);
-		return nsk;
-	}
-
-	nsk = inet_lookup_established(sock_net(sk), &tcp_hashinfo, iph->saddr,
-			th->source, iph->daddr, th->dest, inet_iif(skb));
-
-	if (nsk) {
-		if (nsk->sk_state != TCP_TIME_WAIT) {
-			bh_lock_sock(nsk);
-			return nsk;
-		}
-		inet_twsk_put(inet_twsk(nsk));
-		return NULL;
-	}
 
-#ifdef CONFIG_SYN_COOKIES
 	if (!th->syn)
 		sk = cookie_v4_check(sk, skb);
 #endif
@@ -1409,10 +1385,10 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		goto csum_err;
 
 	if (sk->sk_state == TCP_LISTEN) {
-		struct sock *nsk = tcp_v4_hnd_req(sk, skb);
+		struct sock *nsk = tcp_v4_cookie_check(sk, skb);
+
 		if (!nsk)
 			goto discard;
-
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
 			sk_mark_napi_id(nsk, skb);
@@ -1603,6 +1579,29 @@ process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	if (sk->sk_state == TCP_NEW_SYN_RECV) {
+		struct request_sock *req = inet_reqsk(sk);
+		struct sock *nsk = NULL;
+
+		sk = req->rsk_listener;
+		if (tcp_v4_inbound_md5_hash(sk, skb))
+			goto discard_and_relse;
+		if (sk->sk_state == TCP_LISTEN)
+			nsk = tcp_check_req(sk, skb, req, false);
+		if (!nsk) {
+			reqsk_put(req);
+			goto discard_it;
+		}
+		if (nsk == sk) {
+			sock_hold(sk);
+			reqsk_put(req);
+		} else if (tcp_child_process(sk, nsk, skb)) {
+			tcp_v4_send_reset(nsk, skb);
+			goto discard_it;
+		} else {
+			return 0;
+		}
+	}
 	if (unlikely(iph->ttl < inet_sk(sk)->min_ttl)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
 		goto discard_and_relse;
@@ -1830,35 +1829,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	++st->num;
 	++st->offset;
 
-	if (st->state == TCP_SEQ_STATE_OPENREQ) {
-		struct request_sock *req = cur;
-
-		icsk = inet_csk(st->syn_wait_sk);
-		req = req->dl_next;
-		while (1) {
-			while (req) {
-				if (req->rsk_ops->family == st->family) {
-					cur = req;
-					goto out;
-				}
-				req = req->dl_next;
-			}
-			if (++st->sbucket >= icsk->icsk_accept_queue.listen_opt->nr_table_entries)
-				break;
-get_req:
-			req = icsk->icsk_accept_queue.listen_opt->syn_table[st->sbucket];
-		}
-		sk	  = sk_nulls_next(st->syn_wait_sk);
-		st->state = TCP_SEQ_STATE_LISTENING;
-		spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-	} else {
-		icsk = inet_csk(sk);
-		spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-		if (reqsk_queue_len(&icsk->icsk_accept_queue))
-			goto start_req;
-		spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-		sk = sk_nulls_next(sk);
-	}
+	sk = sk_nulls_next(sk);
 get_sk:
 	sk_nulls_for_each_from(sk, node) {
 		if (!net_eq(sock_net(sk), net))
@@ -1868,15 +1839,6 @@ get_sk:
 			goto out;
 		}
 		icsk = inet_csk(sk);
-		spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-		if (reqsk_queue_len(&icsk->icsk_accept_queue)) {
-start_req:
-			st->syn_wait_sk = sk;
-			st->state	= TCP_SEQ_STATE_OPENREQ;
-			st->sbucket	= 0;
-			goto get_req;
-		}
-		spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
 	}
 	spin_unlock_bh(&ilb->lock);
 	st->offset = 0;
@@ -2008,7 +1970,6 @@ static void *tcp_seek_last_pos(struct seq_file *seq)
 	void *rc = NULL;
 
 	switch (st->state) {
-	case TCP_SEQ_STATE_OPENREQ:
 	case TCP_SEQ_STATE_LISTENING:
 		if (st->bucket >= INET_LHTABLE_SIZE)
 			break;
@@ -2067,7 +2028,6 @@ static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 
 	switch (st->state) {
-	case TCP_SEQ_STATE_OPENREQ:
 	case TCP_SEQ_STATE_LISTENING:
 		rc = listening_get_next(seq, v);
 		if (!rc) {
@@ -2092,11 +2052,6 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 	struct tcp_iter_state *st = seq->private;
 
 	switch (st->state) {
-	case TCP_SEQ_STATE_OPENREQ:
-		if (v) {
-			struct inet_connection_sock *icsk = inet_csk(st->syn_wait_sk);
-			spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
-		}
 	case TCP_SEQ_STATE_LISTENING:
 		if (v != SEQ_START_TOKEN)
 			spin_unlock_bh(&tcp_hashinfo.listening_hash[st->bucket].lock);
@@ -2269,18 +2224,12 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 	}
 	st = seq->private;
 
-	switch (st->state) {
-	case TCP_SEQ_STATE_LISTENING:
-	case TCP_SEQ_STATE_ESTABLISHED:
-		if (sk->sk_state == TCP_TIME_WAIT)
-			get_timewait4_sock(v, seq, st->num);
-		else
-			get_tcp4_sock(v, seq, st->num);
-		break;
-	case TCP_SEQ_STATE_OPENREQ:
+	if (sk->sk_state == TCP_TIME_WAIT)
+		get_timewait4_sock(v, seq, st->num);
+	else if (sk->sk_state == TCP_NEW_SYN_RECV)
 		get_openreq4(v, seq, st->num);
-		break;
-	}
+	else
+		get_tcp4_sock(v, seq, st->num);
 out:
 	seq_pad(seq, '\n');
 	return 0;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index ea915aa5e4e2..5d1c7cee2cb2 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -94,73 +94,6 @@ struct dst_entry *inet6_csk_route_req(const struct sock *sk,
 }
 EXPORT_SYMBOL(inet6_csk_route_req);
 
-/*
- * request_sock (formerly open request) hash tables.
- */
-static u32 inet6_synq_hash(const struct in6_addr *raddr, const __be16 rport,
-			   const u32 rnd, const u32 synq_hsize)
-{
-	u32 c;
-
-	c = jhash_3words((__force u32)raddr->s6_addr32[0],
-			 (__force u32)raddr->s6_addr32[1],
-			 (__force u32)raddr->s6_addr32[2],
-			 rnd);
-
-	c = jhash_2words((__force u32)raddr->s6_addr32[3],
-			 (__force u32)rport,
-			 c);
-
-	return c & (synq_hsize - 1);
-}
-
-struct request_sock *inet6_csk_search_req(struct sock *sk,
-					  const __be16 rport,
-					  const struct in6_addr *raddr,
-					  const struct in6_addr *laddr,
-					  const int iif)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	struct request_sock *req;
-	u32 hash = inet6_synq_hash(raddr, rport, lopt->hash_rnd,
-				   lopt->nr_table_entries);
-
-	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
-	for (req = lopt->syn_table[hash]; req != NULL; req = req->dl_next) {
-		const struct inet_request_sock *ireq = inet_rsk(req);
-
-		if (ireq->ir_rmt_port == rport &&
-		    req->rsk_ops->family == AF_INET6 &&
-		    ipv6_addr_equal(&ireq->ir_v6_rmt_addr, raddr) &&
-		    ipv6_addr_equal(&ireq->ir_v6_loc_addr, laddr) &&
-		    (!ireq->ir_iif || ireq->ir_iif == iif)) {
-			atomic_inc(&req->rsk_refcnt);
-			WARN_ON(req->sk != NULL);
-			break;
-		}
-	}
-	spin_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
-
-	return req;
-}
-EXPORT_SYMBOL_GPL(inet6_csk_search_req);
-
-void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
-				    struct request_sock *req,
-				    const unsigned long timeout)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	const u32 h = inet6_synq_hash(&inet_rsk(req)->ir_v6_rmt_addr,
-				      inet_rsk(req)->ir_rmt_port,
-				      lopt->hash_rnd, lopt->nr_table_entries);
-
-	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
-	inet_csk_reqsk_queue_added(sk);
-}
-EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
-
 void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 {
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) uaddr;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index cadb44a2d34e..a215614cfb2b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -727,7 +727,6 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.route_req	=	tcp_v6_route_req,
 	.init_seq	=	tcp_v6_init_sequence,
 	.send_synack	=	tcp_v6_send_synack,
-	.queue_hash_add =	inet6_csk_reqsk_queue_hash_add,
 };
 
 static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32 seq,
@@ -938,37 +937,11 @@ static void tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 }
 
 
-static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
+static struct sock *tcp_v6_cookie_check(struct sock *sk, struct sk_buff *skb)
 {
+#ifdef CONFIG_SYN_COOKIES
 	const struct tcphdr *th = tcp_hdr(skb);
-	struct request_sock *req;
-	struct sock *nsk;
-
-	/* Find possible connection requests. */
-	req = inet6_csk_search_req(sk, th->source,
-				   &ipv6_hdr(skb)->saddr,
-				   &ipv6_hdr(skb)->daddr, tcp_v6_iif(skb));
-	if (req) {
-		nsk = tcp_check_req(sk, skb, req, false);
-		if (!nsk || nsk == sk)
-			reqsk_put(req);
-		return nsk;
-	}
-	nsk = __inet6_lookup_established(sock_net(sk), &tcp_hashinfo,
-					 &ipv6_hdr(skb)->saddr, th->source,
-					 &ipv6_hdr(skb)->daddr, ntohs(th->dest),
-					 tcp_v6_iif(skb));
-
-	if (nsk) {
-		if (nsk->sk_state != TCP_TIME_WAIT) {
-			bh_lock_sock(nsk);
-			return nsk;
-		}
-		inet_twsk_put(inet_twsk(nsk));
-		return NULL;
-	}
 
-#ifdef CONFIG_SYN_COOKIES
 	if (!th->syn)
 		sk = cookie_v6_check(sk, skb);
 #endif
@@ -1258,15 +1231,11 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		goto csum_err;
 
 	if (sk->sk_state == TCP_LISTEN) {
-		struct sock *nsk = tcp_v6_hnd_req(sk, skb);
+		struct sock *nsk = tcp_v6_cookie_check(sk, skb);
+
 		if (!nsk)
 			goto discard;
 
-		/*
-		 * Queue it on the new socket if the new socket is active,
-		 * otherwise we just shortcircuit this and continue with
-		 * the new socket..
-		 */
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
 			sk_mark_napi_id(nsk, skb);
@@ -1402,6 +1371,33 @@ process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
+	if (sk->sk_state == TCP_NEW_SYN_RECV) {
+		struct request_sock *req = inet_reqsk(sk);
+		struct sock *nsk = NULL;
+
+		sk = req->rsk_listener;
+		tcp_v6_fill_cb(skb, hdr, th);
+		if (tcp_v6_inbound_md5_hash(sk, skb)) {
+			reqsk_put(req);
+			goto discard_it;
+		}
+		if (sk->sk_state == TCP_LISTEN)
+			nsk = tcp_check_req(sk, skb, req, false);
+		if (!nsk) {
+			reqsk_put(req);
+			goto discard_it;
+		}
+		if (nsk == sk) {
+			sock_hold(sk);
+			reqsk_put(req);
+			tcp_v6_restore_cb(skb);
+		} else if (tcp_child_process(sk, nsk, skb)) {
+			tcp_v6_send_reset(nsk, skb);
+			goto discard_it;
+		} else {
+			return 0;
+		}
+	}
 	if (hdr->hop_limit < inet6_sk(sk)->min_hopcount) {
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPMINTTLDROP);
 		goto discard_and_relse;
@@ -1765,18 +1761,12 @@ static int tcp6_seq_show(struct seq_file *seq, void *v)
 	}
 	st = seq->private;
 
-	switch (st->state) {
-	case TCP_SEQ_STATE_LISTENING:
-	case TCP_SEQ_STATE_ESTABLISHED:
-		if (sk->sk_state == TCP_TIME_WAIT)
-			get_timewait6_sock(seq, v, st->num);
-		else
-			get_tcp6_sock(seq, v, st->num);
-		break;
-	case TCP_SEQ_STATE_OPENREQ:
+	if (sk->sk_state == TCP_TIME_WAIT)
+		get_timewait6_sock(seq, v, st->num);
+	else if (sk->sk_state == TCP_NEW_SYN_RECV)
 		get_openreq6(seq, v, st->num);
-		break;
-	}
+	else
+		get_tcp6_sock(seq, v, st->num);
 out:
 	return 0;
 }
-- 
2.6.0.rc2.230.g3dd15c0
