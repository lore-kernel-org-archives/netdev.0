From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: fix hashdance race for passive sessions
Date: Thu, 22 Oct 2015 08:20:46 -0700
Message-ID: <1445527246.22974.125.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34809 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964857AbbJVPUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 11:20:49 -0400
Received: by padhk11 with SMTP id hk11so89458437pad.1
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 08:20:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Multiple cpus can process duplicates of incoming ACK messages
matching a SYN_RECV request socket. This is a rare event under
normal operations, but definitely can happen.

Only one must win the race, otherwise corruption would occur.

To fix this without adding new atomic ops, we use logic in
inet_ehash_nolisten() to detect the request was present in the same
ehash bucket where we try to insert the new child.

If request socket was not found, we have to undo the child creation. 

This actually removes a spin_lock()/spin_unlock() pair in
reqsk_queue_unlink() for the fast path.

Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |    7 ++++
 include/net/inet_hashtables.h      |    4 +-
 include/net/tcp.h                  |    4 ++
 net/dccp/dccp.h                    |    4 ++
 net/dccp/ipv4.c                    |    6 ++--
 net/dccp/ipv6.c                    |    9 ++++--
 net/dccp/minisocks.c               |   14 ++++-----
 net/ipv4/inet_connection_sock.c    |   33 ++++++++++++++++++----
 net/ipv4/inet_hashtables.c         |   39 +++++++++++++++++----------
 net/ipv4/syncookies.c              |    4 ++
 net/ipv4/tcp_fastopen.c            |    4 ++
 net/ipv4/tcp_ipv4.c                |    6 ++--
 net/ipv4/tcp_minisocks.c           |   11 ++-----
 net/ipv6/tcp_ipv6.c                |    9 ++++--
 14 files changed, 102 insertions(+), 52 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 63615709839d..481fe1c9044c 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -43,7 +43,9 @@ struct inet_connection_sock_af_ops {
 	int	    (*conn_request)(struct sock *sk, struct sk_buff *skb);
 	struct sock *(*syn_recv_sock)(const struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req,
-				      struct dst_entry *dst);
+				      struct dst_entry *dst,
+				      struct request_sock *req_unhash,
+				      bool *own_req);
 	u16	    net_header_len;
 	u16	    net_frag_header_len;
 	u16	    sockaddr_len;
@@ -272,6 +274,9 @@ void inet_csk_reqsk_queue_add(struct sock *sk, struct request_sock *req,
 			      struct sock *child);
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 				   unsigned long timeout);
+struct sock *inet_csk_complete_hashdance(struct sock *sk, struct sock *child,
+					 struct request_sock *req,
+					 bool own_req);
 
 static inline void inet_csk_reqsk_queue_added(struct sock *sk)
 {
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 6683ada25fef..de2e3ade6102 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -205,8 +205,8 @@ void inet_put_port(struct sock *sk);
 
 void inet_hashinfo_init(struct inet_hashinfo *h);
 
-int inet_ehash_insert(struct sock *sk, struct sock *osk);
-void __inet_hash_nolisten(struct sock *sk, struct sock *osk);
+bool inet_ehash_insert(struct sock *sk, struct sock *osk);
+bool inet_ehash_nolisten(struct sock *sk, struct sock *osk);
 void __inet_hash(struct sock *sk, struct sock *osk);
 void inet_hash(struct sock *sk);
 void inet_unhash(struct sock *sk);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 11e320412216..f80e74c5ad18 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -457,7 +457,9 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 void tcp_ca_openreq_child(struct sock *sk, const struct dst_entry *dst);
 struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req,
-				  struct dst_entry *dst);
+				  struct dst_entry *dst,
+				  struct request_sock *req_unhash,
+				  bool *own_req);
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 int tcp_connect(struct sock *sk);
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 923f5a180134..b0e28d24e1a7 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -278,7 +278,9 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
 
 struct sock *dccp_v4_request_recv_sock(const struct sock *sk, struct sk_buff *skb,
 				       struct request_sock *req,
-				       struct dst_entry *dst);
+				       struct dst_entry *dst,
+				       struct request_sock *req_unhash,
+				       bool *own_req);
 struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			    struct request_sock *req);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 59bc180b02d8..5684e14932bd 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -393,7 +393,9 @@ static inline u64 dccp_v4_init_sequence(const struct sk_buff *skb)
 struct sock *dccp_v4_request_recv_sock(const struct sock *sk,
 				       struct sk_buff *skb,
 				       struct request_sock *req,
-				       struct dst_entry *dst)
+				       struct dst_entry *dst,
+				       struct request_sock *req_unhash,
+				       bool *own_req)
 {
 	struct inet_request_sock *ireq;
 	struct inet_sock *newinet;
@@ -426,7 +428,7 @@ struct sock *dccp_v4_request_recv_sock(const struct sock *sk,
 
 	if (__inet_inherit_port(sk, newsk) < 0)
 		goto put_and_exit;
-	__inet_hash_nolisten(newsk, NULL);
+	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
 
 	return newsk;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index d9cc731f2619..ef4e48ce9143 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -380,7 +380,9 @@ drop:
 static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 					      struct sk_buff *skb,
 					      struct request_sock *req,
-					      struct dst_entry *dst)
+					      struct dst_entry *dst,
+					      struct request_sock *req_unhash,
+					      bool *own_req)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *newnp;
@@ -393,7 +395,8 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 		/*
 		 *	v6 mapped
 		 */
-		newsk = dccp_v4_request_recv_sock(sk, skb, req, dst);
+		newsk = dccp_v4_request_recv_sock(sk, skb, req, dst,
+						  req_unhash, own_req);
 		if (newsk == NULL)
 			return NULL;
 
@@ -511,7 +514,7 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 		dccp_done(newsk);
 		goto out;
 	}
-	__inet_hash(newsk, NULL);
+	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
 
 	return newsk;
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index d10aace43672..1994f8af646b 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -143,6 +143,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 {
 	struct sock *child = NULL;
 	struct dccp_request_sock *dreq = dccp_rsk(req);
+	bool own_req;
 
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type == DCCP_PKT_REQUEST) {
@@ -182,14 +183,13 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (dccp_parse_options(sk, dreq, skb))
 		 goto drop;
 
-	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
-	if (child == NULL)
+	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL,
+							 req, &own_req);
+	if (!child)
 		goto listen_overflow;
 
-	inet_csk_reqsk_queue_drop(sk, req);
-	inet_csk_reqsk_queue_add(sk, req, child);
-out:
-	return child;
+	return inet_csk_complete_hashdance(sk, child, req, own_req);
+
 listen_overflow:
 	dccp_pr_debug("listen_overflow!\n");
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_TOO_BUSY;
@@ -198,7 +198,7 @@ drop:
 		req->rsk_ops->send_reset(sk, skb);
 
 	inet_csk_reqsk_queue_drop(sk, req);
-	goto out;
+	return NULL;
 }
 
 EXPORT_SYMBOL_GPL(dccp_check_req);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8430bc8ccd58..1feb15f23de8 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -523,15 +523,15 @@ static bool reqsk_queue_unlink(struct request_sock_queue *queue,
 			       struct request_sock *req)
 {
 	struct inet_hashinfo *hashinfo = req_to_sk(req)->sk_prot->h.hashinfo;
-	spinlock_t *lock;
-	bool found;
+	bool found = false;
 
-	lock = inet_ehash_lockp(hashinfo, req->rsk_hash);
-
-	spin_lock(lock);
-	found = __sk_nulls_del_node_init_rcu(req_to_sk(req));
-	spin_unlock(lock);
+	if (sk_hashed(req_to_sk(req))) {
+		spinlock_t *lock = inet_ehash_lockp(hashinfo, req->rsk_hash);
 
+		spin_lock(lock);
+		found = __sk_nulls_del_node_init_rcu(req_to_sk(req));
+		spin_unlock(lock);
+	}
 	if (timer_pending(&req->rsk_timer) && del_timer_sync(&req->rsk_timer))
 		reqsk_put(req);
 	return found;
@@ -811,6 +811,25 @@ void inet_csk_reqsk_queue_add(struct sock *sk, struct request_sock *req,
 }
 EXPORT_SYMBOL(inet_csk_reqsk_queue_add);
 
+struct sock *inet_csk_complete_hashdance(struct sock *sk, struct sock *child,
+					 struct request_sock *req, bool own_req)
+{
+	if (own_req) {
+		inet_csk_reqsk_queue_drop(sk, req);
+		reqsk_queue_removed(&inet_csk(sk)->icsk_accept_queue, req);
+		inet_csk_reqsk_queue_add(sk, req, child);
+		/* Warning: caller must not call reqsk_put(req);
+		 * child stole last reference on it.
+		 */
+		return child;
+	}
+	/* Too bad, another child took ownership of the request, undo. */
+	bh_unlock_sock(child);
+	sock_put(child);
+	return NULL;
+}
+EXPORT_SYMBOL(inet_csk_complete_hashdance);
+
 /*
  *	This routine closes sockets which have been at least partially
  *	opened, but not yet accepted.
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 958728a22001..ccc5980797fc 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -407,13 +407,13 @@ static u32 inet_sk_port_offset(const struct sock *sk)
 /* insert a socket into ehash, and eventually remove another one
  * (The another one can be a SYN_RECV or TIMEWAIT
  */
-int inet_ehash_insert(struct sock *sk, struct sock *osk)
+bool inet_ehash_insert(struct sock *sk, struct sock *osk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_nulls_head *list;
 	struct inet_ehash_bucket *head;
 	spinlock_t *lock;
-	int ret = 0;
+	bool ret = true;
 
 	WARN_ON_ONCE(!sk_unhashed(sk));
 
@@ -423,30 +423,41 @@ int inet_ehash_insert(struct sock *sk, struct sock *osk)
 	lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 
 	spin_lock(lock);
-	__sk_nulls_add_node_rcu(sk, list);
 	if (osk) {
-		WARN_ON(sk->sk_hash != osk->sk_hash);
-		sk_nulls_del_node_init_rcu(osk);
+		WARN_ON_ONCE(sk->sk_hash != osk->sk_hash);
+		ret = sk_nulls_del_node_init_rcu(osk);
 	}
+	if (ret)
+		__sk_nulls_add_node_rcu(sk, list);
 	spin_unlock(lock);
 	return ret;
 }
 
-void __inet_hash_nolisten(struct sock *sk, struct sock *osk)
+bool inet_ehash_nolisten(struct sock *sk, struct sock *osk)
 {
-	inet_ehash_insert(sk, osk);
-	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	bool ok = inet_ehash_insert(sk, osk);
+
+	if (ok) {
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	} else {
+		percpu_counter_inc(sk->sk_prot->orphan_count);
+		sk->sk_state = TCP_CLOSE;
+		sock_set_flag(sk, SOCK_DEAD);
+		inet_csk_destroy_sock(sk);
+	}
+	return ok;
 }
-EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
+EXPORT_SYMBOL_GPL(inet_ehash_nolisten);
 
 void __inet_hash(struct sock *sk, struct sock *osk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct inet_listen_hashbucket *ilb;
 
-	if (sk->sk_state != TCP_LISTEN)
-		return __inet_hash_nolisten(sk, osk);
-
+	if (sk->sk_state != TCP_LISTEN) {
+		inet_ehash_nolisten(sk, osk);
+		return;
+	}
 	WARN_ON(!sk_unhashed(sk));
 	ilb = &hashinfo->listening_hash[inet_sk_listen_hashfn(sk)];
 
@@ -567,7 +578,7 @@ ok:
 		inet_bind_hash(sk, tb, port);
 		if (sk_unhashed(sk)) {
 			inet_sk(sk)->inet_sport = htons(port);
-			__inet_hash_nolisten(sk, (struct sock *)tw);
+			inet_ehash_nolisten(sk, (struct sock *)tw);
 		}
 		if (tw)
 			inet_twsk_bind_unhash(tw, hinfo);
@@ -584,7 +595,7 @@ ok:
 	tb  = inet_csk(sk)->icsk_bind_hash;
 	spin_lock_bh(&head->lock);
 	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
-		__inet_hash_nolisten(sk, NULL);
+		inet_ehash_nolisten(sk, NULL);
 		spin_unlock_bh(&head->lock);
 		return 0;
 	} else {
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4c0892badb8b..4cbe9f0a4281 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -221,8 +221,10 @@ struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sock *child;
+	bool own_req;
 
-	child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);
+	child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst,
+						 NULL, &own_req);
 	if (child) {
 		atomic_set(&req->rsk_refcnt, 1);
 		sock_rps_save_rxhash(child, skb);
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 93396bf7b475..55be6ac70cff 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -133,12 +133,14 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
 	struct sock *child;
 	u32 end_seq;
+	bool own_req;
 
 	req->num_retrans = 0;
 	req->num_timeout = 0;
 	req->sk = NULL;
 
-	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
+	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL,
+							 NULL, &own_req);
 	if (!child)
 		return NULL;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 30dd45c1f568..1c2648bbac4b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1247,7 +1247,9 @@ EXPORT_SYMBOL(tcp_v4_conn_request);
  */
 struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req,
-				  struct dst_entry *dst)
+				  struct dst_entry *dst,
+				  struct request_sock *req_unhash,
+				  bool *own_req)
 {
 	struct inet_request_sock *ireq;
 	struct inet_sock *newinet;
@@ -1323,7 +1325,7 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 
 	if (__inet_inherit_port(sk, newsk) < 0)
 		goto put_and_exit;
-	__inet_hash_nolisten(newsk, NULL);
+	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
 
 	return newsk;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 1fd5d413a664..3575dd1e5b67 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -580,6 +580,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	bool paws_reject = false;
+	bool own_req;
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
@@ -767,18 +768,14 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 * ESTABLISHED STATE. If it will be dropped after
 	 * socket is created, wait for troubles.
 	 */
-	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
+	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL,
+							 req, &own_req);
 	if (!child)
 		goto listen_overflow;
 
 	sock_rps_save_rxhash(child, skb);
 	tcp_synack_rtt_meas(child, req);
-	inet_csk_reqsk_queue_drop(sk, req);
-	inet_csk_reqsk_queue_add(sk, req, child);
-	/* Warning: caller must not call reqsk_put(req);
-	 * child stole last reference on it.
-	 */
-	return child;
+	return inet_csk_complete_hashdance(sk, child, req, own_req);
 
 listen_overflow:
 	if (!sysctl_tcp_abort_on_overflow) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f495d189f5e0..714bc5ad096e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -965,7 +965,9 @@ drop:
 
 static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 					 struct request_sock *req,
-					 struct dst_entry *dst)
+					 struct dst_entry *dst,
+					 struct request_sock *req_unhash,
+					 bool *own_req)
 {
 	struct inet_request_sock *ireq;
 	struct ipv6_pinfo *newnp;
@@ -984,7 +986,8 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		 *	v6 mapped
 		 */
 
-		newsk = tcp_v4_syn_recv_sock(sk, skb, req, dst);
+		newsk = tcp_v4_syn_recv_sock(sk, skb, req, dst,
+					     req_unhash, own_req);
 
 		if (!newsk)
 			return NULL;
@@ -1145,7 +1148,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		tcp_done(newsk);
 		goto out;
 	}
-	__inet_hash(newsk, NULL);
+	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
 
 	return newsk;
 
