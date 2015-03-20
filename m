From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] inet: drop prev pointer handling in request sock
Date: Thu, 19 Mar 2015 19:04:19 -0700
Message-ID: <1426817061-21421-2-git-send-email-edumazet@google.com>
References: <1426817061-21421-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:34579 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbbCTCEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:04:34 -0400
Received: by ykq142 with SMTP id 142so3431178ykq.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 19:04:33 -0700 (PDT)
In-Reply-To: <1426817061-21421-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When request sock are put in ehash table, the whole notion
of having a previous request to update dl_next is pointless.

Also, following patch will get rid of big purge timer,
so we want to delete a request sock without holding listener lock.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet6_connection_sock.h |  1 -
 include/net/inet_connection_sock.h  | 11 ++++-------
 include/net/request_sock.h          | 15 +++++++++++----
 include/net/tcp.h                   |  3 +--
 net/dccp/dccp.h                     |  3 +--
 net/dccp/ipv4.c                     | 14 ++++++--------
 net/dccp/ipv6.c                     | 19 ++++++++-----------
 net/dccp/minisocks.c                |  7 +++----
 net/ipv4/inet_connection_sock.c     | 22 ++++++++++++----------
 net/ipv4/tcp_input.c                |  2 +-
 net/ipv4/tcp_ipv4.c                 | 17 ++++++++---------
 net/ipv4/tcp_minisocks.c            |  5 ++---
 net/ipv6/inet6_connection_sock.c    | 10 ++++------
 net/ipv6/tcp_ipv6.c                 | 12 ++++++------
 14 files changed, 67 insertions(+), 74 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 74af137304be..15bd40878d2a 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -29,7 +29,6 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk, struct flowi6 *fl6,
 				      const struct request_sock *req);
 
 struct request_sock *inet6_csk_search_req(const struct sock *sk,
-					  struct request_sock ***prevp,
 					  const __be16 rport,
 					  const struct in6_addr *raddr,
 					  const struct in6_addr *laddr,
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index b9a6b0a94cc6..423a46106e57 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -257,7 +257,6 @@ inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
 struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
 struct request_sock *inet_csk_search_req(const struct sock *sk,
-					 struct request_sock ***prevp,
 					 const __be16 rport,
 					 const __be32 raddr,
 					 const __be32 laddr);
@@ -310,17 +309,15 @@ static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
 }
 
 static inline void inet_csk_reqsk_queue_unlink(struct sock *sk,
-					       struct request_sock *req,
-					       struct request_sock **prev)
+					       struct request_sock *req)
 {
-	reqsk_queue_unlink(&inet_csk(sk)->icsk_accept_queue, req, prev);
+	reqsk_queue_unlink(&inet_csk(sk)->icsk_accept_queue, req);
 }
 
 static inline void inet_csk_reqsk_queue_drop(struct sock *sk,
-					     struct request_sock *req,
-					     struct request_sock **prev)
+					     struct request_sock *req)
 {
-	inet_csk_reqsk_queue_unlink(sk, req, prev);
+	inet_csk_reqsk_queue_unlink(sk, req);
 	inet_csk_reqsk_queue_removed(sk, req);
 	reqsk_free(req);
 }
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index e7ef86340514..65223905d139 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -50,6 +50,7 @@ int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
 struct request_sock {
 	struct sock_common		__req_common;
 #define rsk_refcnt			__req_common.skc_refcnt
+#define rsk_hash			__req_common.skc_hash
 
 	struct request_sock		*dl_next;
 	struct sock			*rsk_listener;
@@ -216,11 +217,16 @@ static inline int reqsk_queue_empty(struct request_sock_queue *queue)
 }
 
 static inline void reqsk_queue_unlink(struct request_sock_queue *queue,
-				      struct request_sock *req,
-				      struct request_sock **prev_req)
+				      struct request_sock *req)
 {
+	struct listen_sock *lopt = queue->listen_opt;
+	struct request_sock **prev;
+
 	write_lock(&queue->syn_wait_lock);
-	*prev_req = req->dl_next;
+	prev = &lopt->syn_table[req->rsk_hash];
+	while (*prev != req)
+		prev = &(*prev)->dl_next;
+	*prev = req->dl_next;
 	write_unlock(&queue->syn_wait_lock);
 }
 
@@ -300,7 +306,6 @@ static inline void reqsk_queue_hash_req(struct request_sock_queue *queue,
 	req->num_retrans = 0;
 	req->num_timeout = 0;
 	req->sk = NULL;
-	req->dl_next = lopt->syn_table[hash];
 
 	/* before letting lookups find us, make sure all req fields
 	 * are committed to memory and refcnt initialized.
@@ -308,7 +313,9 @@ static inline void reqsk_queue_hash_req(struct request_sock_queue *queue,
 	smp_wmb();
 	atomic_set(&req->rsk_refcnt, 1);
 
+	req->rsk_hash = hash;
 	write_lock(&queue->syn_wait_lock);
+	req->dl_next = lopt->syn_table[hash];
 	lopt->syn_table[hash] = req;
 	write_unlock(&queue->syn_wait_lock);
 }
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5b29835b81d8..082fd79132b7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -406,8 +406,7 @@ enum tcp_tw_status tcp_timewait_state_process(struct inet_timewait_sock *tw,
 					      struct sk_buff *skb,
 					      const struct tcphdr *th);
 struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
-			   struct request_sock *req, struct request_sock **prev,
-			   bool fastopen);
+			   struct request_sock *req, bool fastopen);
 int tcp_child_process(struct sock *parent, struct sock *child,
 		      struct sk_buff *skb);
 void tcp_enter_loss(struct sock *sk);
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 3b1d64d6e093..2396f50c5b04 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -280,8 +280,7 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 				       struct request_sock *req,
 				       struct dst_entry *dst);
 struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
-			    struct request_sock *req,
-			    struct request_sock **prev);
+			    struct request_sock *req);
 
 int dccp_child_process(struct sock *parent, struct sock *child,
 		       struct sk_buff *skb);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index e7ad291cd96b..5bffbbaf1fac 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -288,11 +288,11 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	}
 
 	switch (sk->sk_state) {
-		struct request_sock *req , **prev;
+		struct request_sock *req;
 	case DCCP_LISTEN:
 		if (sock_owned_by_user(sk))
 			goto out;
-		req = inet_csk_search_req(sk, &prev, dh->dccph_dport,
+		req = inet_csk_search_req(sk, dh->dccph_dport,
 					  iph->daddr, iph->saddr);
 		if (!req)
 			goto out;
@@ -314,7 +314,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		 * created socket, and POSIX does not want network
 		 * errors returned from accept().
 		 */
-		inet_csk_reqsk_queue_drop(sk, req, prev);
+		inet_csk_reqsk_queue_drop(sk, req);
 		goto out;
 
 	case DCCP_REQUESTING:
@@ -448,13 +448,11 @@ static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct sock *nsk;
-	struct request_sock **prev;
 	/* Find possible connection requests. */
-	struct request_sock *req = inet_csk_search_req(sk, &prev,
-						       dh->dccph_sport,
+	struct request_sock *req = inet_csk_search_req(sk, dh->dccph_sport,
 						       iph->saddr, iph->daddr);
-	if (req != NULL)
-		return dccp_check_req(sk, skb, req, prev);
+	if (req)
+		return dccp_check_req(sk, skb, req);
 
 	nsk = inet_lookup_established(sock_net(sk), &dccp_hashinfo,
 				      iph->saddr, dh->dccph_sport,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c655de5f67c9..ae2184039fe3 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -149,12 +149,12 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	/* Might be for an request_sock */
 	switch (sk->sk_state) {
-		struct request_sock *req, **prev;
+		struct request_sock *req;
 	case DCCP_LISTEN:
 		if (sock_owned_by_user(sk))
 			goto out;
 
-		req = inet6_csk_search_req(sk, &prev, dh->dccph_dport,
+		req = inet6_csk_search_req(sk, dh->dccph_dport,
 					   &hdr->daddr, &hdr->saddr,
 					   inet6_iif(skb));
 		if (req == NULL)
@@ -172,7 +172,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			goto out;
 		}
 
-		inet_csk_reqsk_queue_drop(sk, req, prev);
+		inet_csk_reqsk_queue_drop(sk, req);
 		goto out;
 
 	case DCCP_REQUESTING:
@@ -317,16 +317,13 @@ static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct request_sock *req;
 	struct sock *nsk;
-	struct request_sock **prev;
-	/* Find possible connection requests. */
-	struct request_sock *req = inet6_csk_search_req(sk, &prev,
-							dh->dccph_sport,
-							&iph->saddr,
-							&iph->daddr,
-							inet6_iif(skb));
+
+	req = inet6_csk_search_req(sk, dh->dccph_sport, &iph->saddr,
+				   &iph->daddr, inet6_iif(skb));
 	if (req != NULL)
-		return dccp_check_req(sk, skb, req, prev);
+		return dccp_check_req(sk, skb, req);
 
 	nsk = __inet6_lookup_established(sock_net(sk), &dccp_hashinfo,
 					 &iph->saddr, dh->dccph_sport,
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index b50dc436db1f..332f7d6d9942 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -152,8 +152,7 @@ EXPORT_SYMBOL_GPL(dccp_create_openreq_child);
  * as an request_sock.
  */
 struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
-			    struct request_sock *req,
-			    struct request_sock **prev)
+			    struct request_sock *req)
 {
 	struct sock *child = NULL;
 	struct dccp_request_sock *dreq = dccp_rsk(req);
@@ -200,7 +199,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (child == NULL)
 		goto listen_overflow;
 
-	inet_csk_reqsk_queue_unlink(sk, req, prev);
+	inet_csk_reqsk_queue_unlink(sk, req);
 	inet_csk_reqsk_queue_removed(sk, req);
 	inet_csk_reqsk_queue_add(sk, req, child);
 out:
@@ -212,7 +211,7 @@ drop:
 	if (dccp_hdr(skb)->dccph_type != DCCP_PKT_RESET)
 		req->rsk_ops->send_reset(sk, skb);
 
-	inet_csk_reqsk_queue_drop(sk, req, prev);
+	inet_csk_reqsk_queue_drop(sk, req);
 	goto out;
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f0f91858aecf..4f57a017928c 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -480,18 +480,17 @@ static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
 #endif
 
 struct request_sock *inet_csk_search_req(const struct sock *sk,
-					 struct request_sock ***prevp,
 					 const __be16 rport, const __be32 raddr,
 					 const __be32 laddr)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	struct request_sock *req, **prev;
+	struct request_sock *req;
 
-	for (prev = &lopt->syn_table[inet_synq_hash(raddr, rport, lopt->hash_rnd,
-						    lopt->nr_table_entries)];
-	     (req = *prev) != NULL;
-	     prev = &req->dl_next) {
+	for (req = lopt->syn_table[inet_synq_hash(raddr, rport, lopt->hash_rnd,
+						  lopt->nr_table_entries)];
+	     req != NULL;
+	     req = req->dl_next) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 
 		if (ireq->ir_rmt_port == rport &&
@@ -499,7 +498,6 @@ struct request_sock *inet_csk_search_req(const struct sock *sk,
 		    ireq->ir_loc_addr == laddr &&
 		    AF_INET_FAMILY(req->rsk_ops->family)) {
 			WARN_ON(req->sk);
-			*prevp = prev;
 			break;
 		}
 	}
@@ -610,7 +608,10 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 	i = lopt->clock_hand;
 
 	do {
-		reqp=&lopt->syn_table[i];
+		reqp = &lopt->syn_table[i];
+		if (!*reqp)
+			goto next_bucket;
+		write_lock(&queue->syn_wait_lock);
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
 				int expire = 0, resend = 0;
@@ -635,14 +636,15 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 				}
 
 				/* Drop this request */
-				inet_csk_reqsk_queue_unlink(parent, req, reqp);
+				*reqp = req->dl_next;
 				reqsk_queue_removed(queue, req);
 				reqsk_put(req);
 				continue;
 			}
 			reqp = &req->dl_next;
 		}
-
+		write_unlock(&queue->syn_wait_lock);
+next_bucket:
 		i = (i + 1) & (lopt->nr_table_entries - 1);
 
 	} while (--budget > 0);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1dfbaee3554e..95caea707f54 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5694,7 +5694,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		WARN_ON_ONCE(sk->sk_state != TCP_SYN_RECV &&
 		    sk->sk_state != TCP_FIN_WAIT1);
 
-		if (tcp_check_req(sk, skb, req, NULL, true) == NULL)
+		if (tcp_check_req(sk, skb, req, true) == NULL)
 			goto discard;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ddd0b1f25b96..19c3770f1e97 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -458,12 +458,12 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	}
 
 	switch (sk->sk_state) {
-		struct request_sock *req, **prev;
+		struct request_sock *req;
 	case TCP_LISTEN:
 		if (sock_owned_by_user(sk))
 			goto out;
 
-		req = inet_csk_search_req(sk, &prev, th->dest,
+		req = inet_csk_search_req(sk, th->dest,
 					  iph->daddr, iph->saddr);
 		if (!req)
 			goto out;
@@ -484,7 +484,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		 * created socket, and POSIX does not want network
 		 * errors returned from accept().
 		 */
-		inet_csk_reqsk_queue_drop(sk, req, prev);
+		inet_csk_reqsk_queue_drop(sk, req);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto out;
 
@@ -1392,15 +1392,14 @@ EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
 
 static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 {
-	struct tcphdr *th = tcp_hdr(skb);
+	const struct tcphdr *th = tcp_hdr(skb);
 	const struct iphdr *iph = ip_hdr(skb);
+	struct request_sock *req;
 	struct sock *nsk;
-	struct request_sock **prev;
-	/* Find possible connection requests. */
-	struct request_sock *req = inet_csk_search_req(sk, &prev, th->source,
-						       iph->saddr, iph->daddr);
+
+	req = inet_csk_search_req(sk, th->source, iph->saddr, iph->daddr);
 	if (req)
-		return tcp_check_req(sk, skb, req, prev, false);
+		return tcp_check_req(sk, skb, req, false);
 
 	nsk = inet_lookup_established(sock_net(sk), &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index dd11ac7798c6..848bcab358e4 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -572,7 +572,6 @@ EXPORT_SYMBOL(tcp_create_openreq_child);
 
 struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   struct request_sock *req,
-			   struct request_sock **prev,
 			   bool fastopen)
 {
 	struct tcp_options_received tmp_opt;
@@ -766,7 +765,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (child == NULL)
 		goto listen_overflow;
 
-	inet_csk_reqsk_queue_unlink(sk, req, prev);
+	inet_csk_reqsk_queue_unlink(sk, req);
 	inet_csk_reqsk_queue_removed(sk, req);
 
 	inet_csk_reqsk_queue_add(sk, req, child);
@@ -791,7 +790,7 @@ embryonic_reset:
 		tcp_reset(sk);
 	}
 	if (!fastopen) {
-		inet_csk_reqsk_queue_drop(sk, req, prev);
+		inet_csk_reqsk_queue_drop(sk, req);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_EMBRYONICRSTS);
 	}
 	return NULL;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 29b32206e494..b7acb9ebc4f5 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -113,7 +113,6 @@ static u32 inet6_synq_hash(const struct in6_addr *raddr, const __be16 rport,
 }
 
 struct request_sock *inet6_csk_search_req(const struct sock *sk,
-					  struct request_sock ***prevp,
 					  const __be16 rport,
 					  const struct in6_addr *raddr,
 					  const struct in6_addr *laddr,
@@ -121,13 +120,13 @@ struct request_sock *inet6_csk_search_req(const struct sock *sk,
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	struct request_sock *req, **prev;
+	struct request_sock *req;
 
-	for (prev = &lopt->syn_table[inet6_synq_hash(raddr, rport,
+	for (req = lopt->syn_table[inet6_synq_hash(raddr, rport,
 						     lopt->hash_rnd,
 						     lopt->nr_table_entries)];
-	     (req = *prev) != NULL;
-	     prev = &req->dl_next) {
+	     req != NULL;
+	     req = req->dl_next) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 
 		if (ireq->ir_rmt_port == rport &&
@@ -136,7 +135,6 @@ struct request_sock *inet6_csk_search_req(const struct sock *sk,
 		    ipv6_addr_equal(&ireq->ir_v6_loc_addr, laddr) &&
 		    (!ireq->ir_iif || ireq->ir_iif == iif)) {
 			WARN_ON(req->sk != NULL);
-			*prevp = prev;
 			return req;
 		}
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 720676d073d9..146f123b52c9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -403,13 +403,13 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	/* Might be for an request_sock */
 	switch (sk->sk_state) {
-		struct request_sock *req, **prev;
+		struct request_sock *req;
 	case TCP_LISTEN:
 		if (sock_owned_by_user(sk))
 			goto out;
 
 		/* Note : We use inet6_iif() here, not tcp_v6_iif() */
-		req = inet6_csk_search_req(sk, &prev, th->dest, &hdr->daddr,
+		req = inet6_csk_search_req(sk, th->dest, &hdr->daddr,
 					   &hdr->saddr, inet6_iif(skb));
 		if (!req)
 			goto out;
@@ -424,7 +424,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			goto out;
 		}
 
-		inet_csk_reqsk_queue_drop(sk, req, prev);
+		inet_csk_reqsk_queue_drop(sk, req);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto out;
 
@@ -980,16 +980,16 @@ static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 
 static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
 {
-	struct request_sock *req, **prev;
 	const struct tcphdr *th = tcp_hdr(skb);
+	struct request_sock *req;
 	struct sock *nsk;
 
 	/* Find possible connection requests. */
-	req = inet6_csk_search_req(sk, &prev, th->source,
+	req = inet6_csk_search_req(sk, th->source,
 				   &ipv6_hdr(skb)->saddr,
 				   &ipv6_hdr(skb)->daddr, tcp_v6_iif(skb));
 	if (req)
-		return tcp_check_req(sk, skb, req, prev, false);
+		return tcp_check_req(sk, skb, req, false);
 
 	nsk = __inet6_lookup_established(sock_net(sk), &tcp_hashinfo,
 					 &ipv6_hdr(skb)->saddr, th->source,
-- 
2.2.0.rc0.207.ga3a616c
