From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: includes a sock_common in request_sock
Date: Wed, 09 Oct 2013 15:21:29 -0700
Message-ID: <1381357289.4971.35.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:54114 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834Ab3JIWVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 18:21:31 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1627722pdi.27
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 15:21:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP listener refactoring, part 5 :

We want to be able to insert request sockets (SYN_RECV) into main
ehash table instead of the per listener hash table to allow RCU
lookups and remove listener lock contention.

This patch includes the needed struct sock_common in front
of struct request_sock

This means there is no more inet6_request_sock IPv6 specific
structure.

Following inet_request_sock fields were renamed as they became
macros to reference fields from struct sock_common.
Prefix ir_ was chosen to avoid name collisions.

loc_port   -> ir_loc_port
loc_addr   -> ir_loc_addr
rmt_addr   -> ir_rmt_addr
rmt_port   -> ir_rmt_port
iif        -> ir_iif

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/ipv6.h             |   26 -----------
 include/net/inet_sock.h          |   16 ++++---
 include/net/request_sock.h       |    1 
 include/net/tcp.h                |    4 -
 net/dccp/ipv4.c                  |   18 ++++----
 net/dccp/ipv6.c                  |   63 ++++++++++++++---------------
 net/dccp/ipv6.h                  |    1 
 net/dccp/minisocks.c             |    4 -
 net/dccp/output.c                |    4 -
 net/ipv4/inet_connection_sock.c  |   23 +++++-----
 net/ipv4/inet_diag.c             |   22 +++++-----
 net/ipv4/syncookies.c            |   12 ++---
 net/ipv4/tcp_ipv4.c              |   38 ++++++++---------
 net/ipv4/tcp_metrics.c           |    8 ++-
 net/ipv4/tcp_output.c            |    4 -
 net/ipv6/inet6_connection_sock.c |   26 +++++------
 net/ipv6/syncookies.c            |   24 +++++------
 net/ipv6/tcp_ipv6.c              |   61 ++++++++++++++--------------
 net/netlabel/netlabel_kapi.c     |    2 
 19 files changed, 169 insertions(+), 188 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 35f6c1b..a80a63c 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -115,16 +115,8 @@ static inline int inet6_iif(const struct sk_buff *skb)
 	return IP6CB(skb)->iif;
 }
 
-struct inet6_request_sock {
-	struct in6_addr		loc_addr;
-	struct in6_addr		rmt_addr;
-	struct sk_buff		*pktopts;
-	int			iif;
-};
-
 struct tcp6_request_sock {
 	struct tcp_request_sock	  tcp6rsk_tcp;
-	struct inet6_request_sock tcp6rsk_inet6;
 };
 
 struct ipv6_mc_socklist;
@@ -264,26 +256,12 @@ static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 	return inet_sk(__sk)->pinet6;
 }
 
-static inline struct inet6_request_sock *
-			inet6_rsk(const struct request_sock *rsk)
-{
-	return (struct inet6_request_sock *)(((u8 *)rsk) +
-					     inet_rsk(rsk)->inet6_rsk_offset);
-}
-
-static inline u32 inet6_rsk_offset(struct request_sock *rsk)
-{
-	return rsk->rsk_ops->obj_size - sizeof(struct inet6_request_sock);
-}
-
 static inline struct request_sock *inet6_reqsk_alloc(struct request_sock_ops *ops)
 {
 	struct request_sock *req = reqsk_alloc(ops);
 
-	if (req != NULL) {
-		inet_rsk(req)->inet6_rsk_offset = inet6_rsk_offset(req);
-		inet6_rsk(req)->pktopts = NULL;
-	}
+	if (req)
+		inet_rsk(req)->pktopts = NULL;
 
 	return req;
 }
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 6d9a7e6..f912044 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -70,13 +70,14 @@ struct ip_options_data {
 
 struct inet_request_sock {
 	struct request_sock	req;
-#if IS_ENABLED(CONFIG_IPV6)
-	u16			inet6_rsk_offset;
-#endif
-	__be16			loc_port;
-	__be32			loc_addr;
-	__be32			rmt_addr;
-	__be16			rmt_port;
+#define ir_loc_addr		req.__req_common.skc_rcv_saddr
+#define ir_rmt_addr		req.__req_common.skc_daddr
+#define ir_loc_port		req.__req_common.skc_num
+#define ir_rmt_port		req.__req_common.skc_dport
+#define ir_v6_rmt_addr		req.__req_common.skc_v6_daddr
+#define ir_v6_loc_addr		req.__req_common.skc_v6_rcv_saddr
+#define ir_iif			req.__req_common.skc_bound_dev_if
+
 	kmemcheck_bitfield_begin(flags);
 	u16			snd_wscale : 4,
 				rcv_wscale : 4,
@@ -88,6 +89,7 @@ struct inet_request_sock {
 				no_srccheck: 1;
 	kmemcheck_bitfield_end(flags);
 	struct ip_options_rcu	*opt;
+	struct sk_buff		*pktopts;
 };
 
 static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 65c3e516..7f830ff 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -48,6 +48,7 @@ int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
 /* struct request_sock - mini sock to represent a connection request
  */
 struct request_sock {
+	struct sock_common		__req_common;
 	struct request_sock		*dl_next;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 39bbfa1..24a0616 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1109,8 +1109,8 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->wscale_ok = rx_opt->wscale_ok;
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
-	ireq->rmt_port = tcp_hdr(skb)->source;
-	ireq->loc_port = tcp_hdr(skb)->dest;
+	ireq->ir_rmt_port = tcp_hdr(skb)->source;
+	ireq->ir_loc_port = tcp_hdr(skb)->dest;
 }
 
 void tcp_enter_memory_pressure(struct sock *sk);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ebc54fe..720c362 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -409,9 +409,9 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newinet		   = inet_sk(newsk);
 	ireq		   = inet_rsk(req);
-	newinet->inet_daddr	= ireq->rmt_addr;
-	newinet->inet_rcv_saddr = ireq->loc_addr;
-	newinet->inet_saddr	= ireq->loc_addr;
+	newinet->inet_daddr	= ireq->ir_rmt_addr;
+	newinet->inet_rcv_saddr = ireq->ir_loc_addr;
+	newinet->inet_saddr	= ireq->ir_loc_addr;
 	newinet->inet_opt	= ireq->opt;
 	ireq->opt	   = NULL;
 	newinet->mc_index  = inet_iif(skb);
@@ -516,10 +516,10 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req)
 		const struct inet_request_sock *ireq = inet_rsk(req);
 		struct dccp_hdr *dh = dccp_hdr(skb);
 
-		dh->dccph_checksum = dccp_v4_csum_finish(skb, ireq->loc_addr,
-							      ireq->rmt_addr);
-		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
-					    ireq->rmt_addr,
+		dh->dccph_checksum = dccp_v4_csum_finish(skb, ireq->ir_loc_addr,
+							      ireq->ir_rmt_addr);
+		err = ip_build_and_send_pkt(skb, sk, ireq->ir_loc_addr,
+					    ireq->ir_rmt_addr,
 					    ireq->opt);
 		err = net_xmit_eval(err);
 	}
@@ -641,8 +641,8 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	ireq = inet_rsk(req);
-	ireq->loc_addr = ip_hdr(skb)->daddr;
-	ireq->rmt_addr = ip_hdr(skb)->saddr;
+	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
+	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
 
 	/*
 	 * Step 3: Process LISTEN state
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 7f075b8..5cc5b24 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -216,7 +216,7 @@ out:
 
 static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 {
-	struct inet6_request_sock *ireq6 = inet6_rsk(req);
+	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
 	struct in6_addr *final_p, final;
@@ -226,12 +226,12 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_DCCP;
-	fl6.daddr = ireq6->rmt_addr;
-	fl6.saddr = ireq6->loc_addr;
+	fl6.daddr = ireq->ir_v6_rmt_addr;
+	fl6.saddr = ireq->ir_v6_loc_addr;
 	fl6.flowlabel = 0;
-	fl6.flowi6_oif = ireq6->iif;
-	fl6.fl6_dport = inet_rsk(req)->rmt_port;
-	fl6.fl6_sport = inet_rsk(req)->loc_port;
+	fl6.flowi6_oif = ireq->ir_iif;
+	fl6.fl6_dport = ireq->ir_rmt_port;
+	fl6.fl6_sport = ireq->ir_loc_port;
 	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 
@@ -249,9 +249,9 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 		struct dccp_hdr *dh = dccp_hdr(skb);
 
 		dh->dccph_checksum = dccp_v6_csum_finish(skb,
-							 &ireq6->loc_addr,
-							 &ireq6->rmt_addr);
-		fl6.daddr = ireq6->rmt_addr;
+							 &ireq->ir_v6_loc_addr,
+							 &ireq->ir_v6_rmt_addr);
+		fl6.daddr = ireq->ir_v6_rmt_addr;
 		err = ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
@@ -264,8 +264,7 @@ done:
 static void dccp_v6_reqsk_destructor(struct request_sock *req)
 {
 	dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
-	if (inet6_rsk(req)->pktopts != NULL)
-		kfree_skb(inet6_rsk(req)->pktopts);
+	kfree_skb(inet_rsk(req)->pktopts);
 }
 
 static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
@@ -359,7 +358,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct request_sock *req;
 	struct dccp_request_sock *dreq;
-	struct inet6_request_sock *ireq6;
+	struct inet_request_sock *ireq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
@@ -398,22 +397,22 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	ireq6 = inet6_rsk(req);
-	ireq6->rmt_addr = ipv6_hdr(skb)->saddr;
-	ireq6->loc_addr = ipv6_hdr(skb)->daddr;
+	ireq = inet_rsk(req);
+	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
+	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
 		atomic_inc(&skb->users);
-		ireq6->pktopts = skb;
+		ireq->pktopts = skb;
 	}
-	ireq6->iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = sk->sk_bound_dev_if;
 
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&ireq6->rmt_addr) & IPV6_ADDR_LINKLOCAL)
-		ireq6->iif = inet6_iif(skb);
+	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
+		ireq->ir_iif = inet6_iif(skb);
 
 	/*
 	 * Step 3: Process LISTEN state
@@ -446,7 +445,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 					      struct request_sock *req,
 					      struct dst_entry *dst)
 {
-	struct inet6_request_sock *ireq6 = inet6_rsk(req);
+	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct inet_sock *newinet;
 	struct dccp6_sock *newdp6;
@@ -505,12 +504,12 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_DCCP;
-		fl6.daddr = ireq6->rmt_addr;
+		fl6.daddr = ireq->ir_v6_rmt_addr;
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
-		fl6.saddr = ireq6->loc_addr;
+		fl6.saddr = ireq->ir_v6_loc_addr;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
-		fl6.fl6_dport = inet_rsk(req)->rmt_port;
-		fl6.fl6_sport = inet_rsk(req)->loc_port;
+		fl6.fl6_dport = ireq->ir_rmt_port;
+		fl6.fl6_sport = ireq->ir_loc_port;
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
@@ -538,10 +537,10 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-	newsk->sk_v6_daddr = ireq6->rmt_addr;
-	newnp->saddr = ireq6->loc_addr;
-	newsk->sk_v6_rcv_saddr = ireq6->loc_addr;
-	newsk->sk_bound_dev_if = ireq6->iif;
+	newsk->sk_v6_daddr	= ireq->ir_v6_rmt_addr;
+	newnp->saddr		= ireq->ir_v6_loc_addr;
+	newsk->sk_v6_rcv_saddr	= ireq->ir_v6_loc_addr;
+	newsk->sk_bound_dev_if	= ireq->ir_iif;
 
 	/* Now IPv6 options...
 
@@ -554,10 +553,10 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 	/* Clone pktoptions received with SYN */
 	newnp->pktoptions = NULL;
-	if (ireq6->pktopts != NULL) {
-		newnp->pktoptions = skb_clone(ireq6->pktopts, GFP_ATOMIC);
-		consume_skb(ireq6->pktopts);
-		ireq6->pktopts = NULL;
+	if (ireq->pktopts != NULL) {
+		newnp->pktoptions = skb_clone(ireq->pktopts, GFP_ATOMIC);
+		consume_skb(ireq->pktopts);
+		ireq->pktopts = NULL;
 		if (newnp->pktoptions)
 			skb_set_owner_r(newnp->pktoptions, newsk);
 	}
diff --git a/net/dccp/ipv6.h b/net/dccp/ipv6.h
index 6604fc3..af259e1 100644
--- a/net/dccp/ipv6.h
+++ b/net/dccp/ipv6.h
@@ -25,7 +25,6 @@ struct dccp6_sock {
 
 struct dccp6_request_sock {
 	struct dccp_request_sock  dccp;
-	struct inet6_request_sock inet6;
 };
 
 struct dccp6_timewait_sock {
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 32e80d9..66afbce 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -266,8 +266,8 @@ int dccp_reqsk_init(struct request_sock *req,
 {
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
-	inet_rsk(req)->rmt_port	  = dccp_hdr(skb)->dccph_sport;
-	inet_rsk(req)->loc_port	  = dccp_hdr(skb)->dccph_dport;
+	inet_rsk(req)->ir_rmt_port	  = dccp_hdr(skb)->dccph_sport;
+	inet_rsk(req)->ir_loc_port	  = dccp_hdr(skb)->dccph_dport;
 	inet_rsk(req)->acked	  = 0;
 	dreq->dreq_timestamp_echo = 0;
 
diff --git a/net/dccp/output.c b/net/dccp/output.c
index d17fc90..9bf195d 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -424,8 +424,8 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 	/* Build and checksum header */
 	dh = dccp_zeroed_hdr(skb, dccp_header_size);
 
-	dh->dccph_sport	= inet_rsk(req)->loc_port;
-	dh->dccph_dport	= inet_rsk(req)->rmt_port;
+	dh->dccph_sport	= inet_rsk(req)->ir_loc_port;
+	dh->dccph_dport	= inet_rsk(req)->ir_rmt_port;
 	dh->dccph_doff	= (dccp_header_size +
 			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
 	dh->dccph_type	= DCCP_PKT_RESPONSE;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 56e82a4..2ffd931 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -412,8 +412,8 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol,
 			   flags,
-			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->rmt_addr,
-			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
+			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
+			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
@@ -448,8 +448,8 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
-			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->rmt_addr,
-			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
+			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
+			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
@@ -495,9 +495,9 @@ struct request_sock *inet_csk_search_req(const struct sock *sk,
 	     prev = &req->dl_next) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
 
-		if (ireq->rmt_port == rport &&
-		    ireq->rmt_addr == raddr &&
-		    ireq->loc_addr == laddr &&
+		if (ireq->ir_rmt_port == rport &&
+		    ireq->ir_rmt_addr == raddr &&
+		    ireq->ir_loc_addr == laddr &&
 		    AF_INET_FAMILY(req->rsk_ops->family)) {
 			WARN_ON(req->sk);
 			*prevp = prev;
@@ -514,7 +514,8 @@ void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	const u32 h = inet_synq_hash(inet_rsk(req)->rmt_addr, inet_rsk(req)->rmt_port,
+	const u32 h = inet_synq_hash(inet_rsk(req)->ir_rmt_addr,
+				     inet_rsk(req)->ir_rmt_port,
 				     lopt->hash_rnd, lopt->nr_table_entries);
 
 	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
@@ -674,9 +675,9 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 		newsk->sk_state = TCP_SYN_RECV;
 		newicsk->icsk_bind_hash = NULL;
 
-		inet_sk(newsk)->inet_dport = inet_rsk(req)->rmt_port;
-		inet_sk(newsk)->inet_num = ntohs(inet_rsk(req)->loc_port);
-		inet_sk(newsk)->inet_sport = inet_rsk(req)->loc_port;
+		inet_sk(newsk)->inet_dport = inet_rsk(req)->ir_rmt_port;
+		inet_sk(newsk)->inet_num = ntohs(inet_rsk(req)->ir_loc_port);
+		inet_sk(newsk)->inet_sport = inet_rsk(req)->ir_loc_port;
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index ecc179d..41e1c3e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -679,12 +679,12 @@ static inline void inet_diag_req_addrs(const struct sock *sk,
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == AF_INET6) {
 		if (req->rsk_ops->family == AF_INET6) {
-			entry->saddr = inet6_rsk(req)->loc_addr.s6_addr32;
-			entry->daddr = inet6_rsk(req)->rmt_addr.s6_addr32;
+			entry->saddr = ireq->ir_v6_loc_addr.s6_addr32;
+			entry->daddr = ireq->ir_v6_rmt_addr.s6_addr32;
 		} else if (req->rsk_ops->family == AF_INET) {
-			ipv6_addr_set_v4mapped(ireq->loc_addr,
+			ipv6_addr_set_v4mapped(ireq->ir_loc_addr,
 					       &entry->saddr_storage);
-			ipv6_addr_set_v4mapped(ireq->rmt_addr,
+			ipv6_addr_set_v4mapped(ireq->ir_rmt_addr,
 					       &entry->daddr_storage);
 			entry->saddr = entry->saddr_storage.s6_addr32;
 			entry->daddr = entry->daddr_storage.s6_addr32;
@@ -692,8 +692,8 @@ static inline void inet_diag_req_addrs(const struct sock *sk,
 	} else
 #endif
 	{
-		entry->saddr = &ireq->loc_addr;
-		entry->daddr = &ireq->rmt_addr;
+		entry->saddr = &ireq->ir_loc_addr;
+		entry->daddr = &ireq->ir_rmt_addr;
 	}
 }
 
@@ -728,9 +728,9 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 		tmo = 0;
 
 	r->id.idiag_sport = inet->inet_sport;
-	r->id.idiag_dport = ireq->rmt_port;
-	r->id.idiag_src[0] = ireq->loc_addr;
-	r->id.idiag_dst[0] = ireq->rmt_addr;
+	r->id.idiag_dport = ireq->ir_rmt_port;
+	r->id.idiag_src[0] = ireq->ir_loc_addr;
+	r->id.idiag_dst[0] = ireq->ir_rmt_addr;
 	r->idiag_expires = jiffies_to_msecs(tmo);
 	r->idiag_rqueue = 0;
 	r->idiag_wqueue = 0;
@@ -789,13 +789,13 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
 			if (reqnum < s_reqnum)
 				continue;
-			if (r->id.idiag_dport != ireq->rmt_port &&
+			if (r->id.idiag_dport != ireq->ir_rmt_port &&
 			    r->id.idiag_dport)
 				continue;
 
 			if (bc) {
 				inet_diag_req_addrs(sk, req, &entry);
-				entry.dport = ntohs(ireq->rmt_port);
+				entry.dport = ntohs(ireq->ir_rmt_port);
 
 				if (!inet_diag_bc_run(bc, &entry))
 					continue;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 15e0241..984e21c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -304,10 +304,10 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	treq->rcv_isn		= ntohl(th->seq) - 1;
 	treq->snt_isn		= cookie;
 	req->mss		= mss;
-	ireq->loc_port		= th->dest;
-	ireq->rmt_port		= th->source;
-	ireq->loc_addr		= ip_hdr(skb)->daddr;
-	ireq->rmt_addr		= ip_hdr(skb)->saddr;
+	ireq->ir_loc_port		= th->dest;
+	ireq->ir_rmt_port		= th->source;
+	ireq->ir_loc_addr		= ip_hdr(skb)->daddr;
+	ireq->ir_rmt_addr		= ip_hdr(skb)->saddr;
 	ireq->ecn_ok		= ecn_ok;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
@@ -347,8 +347,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	flowi4_init_output(&fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
-			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
-			   ireq->loc_addr, th->source, th->dest);
+			   (opt && opt->srr) ? opt->faddr : ireq->ir_rmt_addr,
+			   ireq->ir_loc_addr, th->source, th->dest);
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
 	if (IS_ERR(rt)) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e4695dd..114d1b74 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -835,11 +835,11 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	skb = tcp_make_synack(sk, dst, req, NULL);
 
 	if (skb) {
-		__tcp_v4_send_check(skb, ireq->loc_addr, ireq->rmt_addr);
+		__tcp_v4_send_check(skb, ireq->ir_loc_addr, ireq->ir_rmt_addr);
 
 		skb_set_queue_mapping(skb, queue_mapping);
-		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
-					    ireq->rmt_addr,
+		err = ip_build_and_send_pkt(skb, sk, ireq->ir_loc_addr,
+					    ireq->ir_rmt_addr,
 					    ireq->opt);
 		err = net_xmit_eval(err);
 		if (!tcp_rsk(req)->snt_synack && !err)
@@ -972,7 +972,7 @@ static struct tcp_md5sig_key *tcp_v4_reqsk_md5_lookup(struct sock *sk,
 {
 	union tcp_md5_addr *addr;
 
-	addr = (union tcp_md5_addr *)&inet_rsk(req)->rmt_addr;
+	addr = (union tcp_md5_addr *)&inet_rsk(req)->ir_rmt_addr;
 	return tcp_md5_do_lookup(sk, addr, AF_INET);
 }
 
@@ -1149,8 +1149,8 @@ int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 		saddr = inet_sk(sk)->inet_saddr;
 		daddr = inet_sk(sk)->inet_daddr;
 	} else if (req) {
-		saddr = inet_rsk(req)->loc_addr;
-		daddr = inet_rsk(req)->rmt_addr;
+		saddr = inet_rsk(req)->ir_loc_addr;
+		daddr = inet_rsk(req)->ir_rmt_addr;
 	} else {
 		const struct iphdr *iph = ip_hdr(skb);
 		saddr = iph->saddr;
@@ -1366,8 +1366,8 @@ static int tcp_v4_conn_req_fastopen(struct sock *sk,
 		kfree_skb(skb_synack);
 		return -1;
 	}
-	err = ip_build_and_send_pkt(skb_synack, sk, ireq->loc_addr,
-				    ireq->rmt_addr, ireq->opt);
+	err = ip_build_and_send_pkt(skb_synack, sk, ireq->ir_loc_addr,
+				    ireq->ir_rmt_addr, ireq->opt);
 	err = net_xmit_eval(err);
 	if (!err)
 		tcp_rsk(req)->snt_synack = tcp_time_stamp;
@@ -1502,8 +1502,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_openreq_init(req, &tmp_opt, skb);
 
 	ireq = inet_rsk(req);
-	ireq->loc_addr = daddr;
-	ireq->rmt_addr = saddr;
+	ireq->ir_loc_addr = daddr;
+	ireq->ir_rmt_addr = saddr;
 	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
 
@@ -1578,15 +1578,15 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	    fastopen_cookie_present(&valid_foc) ? &valid_foc : NULL);
 
 	if (skb_synack) {
-		__tcp_v4_send_check(skb_synack, ireq->loc_addr, ireq->rmt_addr);
+		__tcp_v4_send_check(skb_synack, ireq->ir_loc_addr, ireq->ir_rmt_addr);
 		skb_set_queue_mapping(skb_synack, skb_get_queue_mapping(skb));
 	} else
 		goto drop_and_free;
 
 	if (likely(!do_fastopen)) {
 		int err;
-		err = ip_build_and_send_pkt(skb_synack, sk, ireq->loc_addr,
-		     ireq->rmt_addr, ireq->opt);
+		err = ip_build_and_send_pkt(skb_synack, sk, ireq->ir_loc_addr,
+		     ireq->ir_rmt_addr, ireq->opt);
 		err = net_xmit_eval(err);
 		if (err || want_cookie)
 			goto drop_and_free;
@@ -1644,9 +1644,9 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newtp		      = tcp_sk(newsk);
 	newinet		      = inet_sk(newsk);
 	ireq		      = inet_rsk(req);
-	newinet->inet_daddr   = ireq->rmt_addr;
-	newinet->inet_rcv_saddr = ireq->loc_addr;
-	newinet->inet_saddr	      = ireq->loc_addr;
+	newinet->inet_daddr   = ireq->ir_rmt_addr;
+	newinet->inet_rcv_saddr = ireq->ir_loc_addr;
+	newinet->inet_saddr	      = ireq->ir_loc_addr;
 	inet_opt	      = ireq->opt;
 	rcu_assign_pointer(newinet->inet_opt, inet_opt);
 	ireq->opt	      = NULL;
@@ -2548,10 +2548,10 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK%n",
 		i,
-		ireq->loc_addr,
+		ireq->ir_loc_addr,
 		ntohs(inet_sk(sk)->inet_sport),
-		ireq->rmt_addr,
-		ntohs(ireq->rmt_port),
+		ireq->ir_rmt_addr,
+		ntohs(ireq->ir_rmt_port),
 		TCP_SYN_RECV,
 		0, 0, /* could print option size, but that is af dependent. */
 		1,    /* timers active (only the expire timer) */
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 8fcc2cb..4a2a841 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -215,13 +215,15 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 	addr.family = req->rsk_ops->family;
 	switch (addr.family) {
 	case AF_INET:
-		addr.addr.a4 = inet_rsk(req)->rmt_addr;
+		addr.addr.a4 = inet_rsk(req)->ir_rmt_addr;
 		hash = (__force unsigned int) addr.addr.a4;
 		break;
+#if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = inet6_rsk(req)->rmt_addr;
-		hash = ipv6_addr_hash(&inet6_rsk(req)->rmt_addr);
+		*(struct in6_addr *)addr.addr.a6 = inet_rsk(req)->ir_v6_rmt_addr;
+		hash = ipv6_addr_hash(&inet_rsk(req)->ir_v6_rmt_addr);
 		break;
+#endif
 	default:
 		return NULL;
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c6f01f2..faec813 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2734,8 +2734,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->syn = 1;
 	th->ack = 1;
 	TCP_ECN_make_synack(req, th);
-	th->source = ireq->loc_port;
-	th->dest = ireq->rmt_port;
+	th->source = ireq->ir_loc_port;
+	th->dest = ireq->ir_rmt_port;
 	/* Setting of flags are superfluous here for callers (and ECE is
 	 * not even correctly set)
 	 */
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index b7400b4..1317c56 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -70,20 +70,20 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 				      struct flowi6 *fl6,
 				      const struct request_sock *req)
 {
-	struct inet6_request_sock *treq = inet6_rsk(req);
+	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *final_p, final;
 	struct dst_entry *dst;
 
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->flowi6_proto = IPPROTO_TCP;
-	fl6->daddr = treq->rmt_addr;
+	fl6->daddr = ireq->ir_v6_rmt_addr;
 	final_p = fl6_update_dst(fl6, np->opt, &final);
-	fl6->saddr = treq->loc_addr;
-	fl6->flowi6_oif = treq->iif;
+	fl6->saddr = ireq->ir_v6_loc_addr;
+	fl6->flowi6_oif = ireq->ir_iif;
 	fl6->flowi6_mark = sk->sk_mark;
-	fl6->fl6_dport = inet_rsk(req)->rmt_port;
-	fl6->fl6_sport = inet_rsk(req)->loc_port;
+	fl6->fl6_dport = ireq->ir_rmt_port;
+	fl6->fl6_sport = ireq->ir_loc_port;
 	security_req_classify_flow(req, flowi6_to_flowi(fl6));
 
 	dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
@@ -129,13 +129,13 @@ struct request_sock *inet6_csk_search_req(const struct sock *sk,
 						     lopt->nr_table_entries)];
 	     (req = *prev) != NULL;
 	     prev = &req->dl_next) {
-		const struct inet6_request_sock *treq = inet6_rsk(req);
+		const struct inet_request_sock *ireq = inet_rsk(req);
 
-		if (inet_rsk(req)->rmt_port == rport &&
+		if (ireq->ir_rmt_port == rport &&
 		    req->rsk_ops->family == AF_INET6 &&
-		    ipv6_addr_equal(&treq->rmt_addr, raddr) &&
-		    ipv6_addr_equal(&treq->loc_addr, laddr) &&
-		    (!treq->iif || treq->iif == iif)) {
+		    ipv6_addr_equal(&ireq->ir_v6_rmt_addr, raddr) &&
+		    ipv6_addr_equal(&ireq->ir_v6_loc_addr, laddr) &&
+		    (!ireq->ir_iif || ireq->ir_iif == iif)) {
 			WARN_ON(req->sk != NULL);
 			*prevp = prev;
 			return req;
@@ -153,8 +153,8 @@ void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	const u32 h = inet6_synq_hash(&inet6_rsk(req)->rmt_addr,
-				      inet_rsk(req)->rmt_port,
+	const u32 h = inet6_synq_hash(&inet_rsk(req)->ir_v6_rmt_addr,
+				      inet_rsk(req)->ir_rmt_port,
 				      lopt->hash_rnd, lopt->nr_table_entries);
 
 	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d703218..bc5698f9 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -150,7 +150,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tcp_opt;
 	struct inet_request_sock *ireq;
-	struct inet6_request_sock *ireq6;
 	struct tcp_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -187,7 +186,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	ireq = inet_rsk(req);
-	ireq6 = inet6_rsk(req);
 	treq = tcp_rsk(req);
 	treq->listener = NULL;
 
@@ -195,22 +193,22 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		goto out_free;
 
 	req->mss = mss;
-	ireq->rmt_port = th->source;
-	ireq->loc_port = th->dest;
-	ireq6->rmt_addr = ipv6_hdr(skb)->saddr;
-	ireq6->loc_addr = ipv6_hdr(skb)->daddr;
+	ireq->ir_rmt_port = th->source;
+	ireq->ir_loc_port = th->dest;
+	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
+	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
 		atomic_inc(&skb->users);
-		ireq6->pktopts = skb;
+		ireq->pktopts = skb;
 	}
 
-	ireq6->iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = sk->sk_bound_dev_if;
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&ireq6->rmt_addr) & IPV6_ADDR_LINKLOCAL)
-		ireq6->iif = inet6_iif(skb);
+	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
+		ireq->ir_iif = inet6_iif(skb);
 
 	req->expires = 0UL;
 	req->num_retrans = 0;
@@ -234,12 +232,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		struct flowi6 fl6;
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_TCP;
-		fl6.daddr = ireq6->rmt_addr;
+		fl6.daddr = ireq->ir_v6_rmt_addr;
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
-		fl6.saddr = ireq6->loc_addr;
+		fl6.saddr = ireq->ir_v6_loc_addr;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.flowi6_mark = sk->sk_mark;
-		fl6.fl6_dport = inet_rsk(req)->rmt_port;
+		fl6.fl6_dport = ireq->ir_rmt_port;
 		fl6.fl6_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 541dfc4..db234d6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -465,7 +465,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
 			      u16 queue_mapping)
 {
-	struct inet6_request_sock *treq = inet6_rsk(req);
+	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff * skb;
 	int err = -ENOMEM;
@@ -477,9 +477,10 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 	skb = tcp_make_synack(sk, dst, req, NULL);
 
 	if (skb) {
-		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
+		__tcp_v6_send_check(skb, &ireq->ir_v6_loc_addr,
+				    &ireq->ir_v6_rmt_addr);
 
-		fl6->daddr = treq->rmt_addr;
+		fl6->daddr = ireq->ir_v6_rmt_addr;
 		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
@@ -502,7 +503,7 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
-	kfree_skb(inet6_rsk(req)->pktopts);
+	kfree_skb(inet_rsk(req)->pktopts);
 }
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -521,7 +522,7 @@ static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
 static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
 						      struct request_sock *req)
 {
-	return tcp_v6_md5_do_lookup(sk, &inet6_rsk(req)->rmt_addr);
+	return tcp_v6_md5_do_lookup(sk, &inet_rsk(req)->ir_v6_rmt_addr);
 }
 
 static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
@@ -623,8 +624,8 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 		saddr = &inet6_sk(sk)->saddr;
 		daddr = &sk->sk_v6_daddr;
 	} else if (req) {
-		saddr = &inet6_rsk(req)->loc_addr;
-		daddr = &inet6_rsk(req)->rmt_addr;
+		saddr = &inet_rsk(req)->ir_v6_loc_addr;
+		daddr = &inet_rsk(req)->ir_v6_rmt_addr;
 	} else {
 		const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 		saddr = &ip6h->saddr;
@@ -949,7 +950,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tmp_opt;
 	struct request_sock *req;
-	struct inet6_request_sock *treq;
+	struct inet_request_sock *ireq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
@@ -994,25 +995,25 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb);
 
-	treq = inet6_rsk(req);
-	treq->rmt_addr = ipv6_hdr(skb)->saddr;
-	treq->loc_addr = ipv6_hdr(skb)->daddr;
+	ireq = inet_rsk(req);
+	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
+	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, skb, sock_net(sk));
 
-	treq->iif = sk->sk_bound_dev_if;
+	ireq->ir_iif = sk->sk_bound_dev_if;
 
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
-		treq->iif = inet6_iif(skb);
+	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
+		ireq->ir_iif = inet6_iif(skb);
 
 	if (!isn) {
 		if (ipv6_opt_accepted(sk, skb) ||
 		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
 			atomic_inc(&skb->users);
-			treq->pktopts = skb;
+			ireq->pktopts = skb;
 		}
 
 		if (want_cookie) {
@@ -1051,7 +1052,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 			 * to the moment of synflood.
 			 */
 			LIMIT_NETDEBUG(KERN_DEBUG "TCP: drop open request from %pI6/%u\n",
-				       &treq->rmt_addr, ntohs(tcp_hdr(skb)->source));
+				       &ireq->ir_v6_rmt_addr, ntohs(tcp_hdr(skb)->source));
 			goto drop_and_release;
 		}
 
@@ -1086,7 +1087,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 					  struct request_sock *req,
 					  struct dst_entry *dst)
 {
-	struct inet6_request_sock *treq;
+	struct inet_request_sock *ireq;
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct tcp6_sock *newtcp6sk;
 	struct inet_sock *newinet;
@@ -1151,7 +1152,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		return newsk;
 	}
 
-	treq = inet6_rsk(req);
+	ireq = inet_rsk(req);
 
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
@@ -1185,10 +1186,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-	newsk->sk_v6_daddr = treq->rmt_addr;
-	newnp->saddr = treq->loc_addr;
-	newsk->sk_v6_rcv_saddr = treq->loc_addr;
-	newsk->sk_bound_dev_if = treq->iif;
+	newsk->sk_v6_daddr = ireq->ir_v6_rmt_addr;
+	newnp->saddr = ireq->ir_v6_loc_addr;
+	newsk->sk_v6_rcv_saddr = ireq->ir_v6_loc_addr;
+	newsk->sk_bound_dev_if = ireq->ir_iif;
 
 	/* Now IPv6 options...
 
@@ -1203,11 +1204,11 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	/* Clone pktoptions received with SYN */
 	newnp->pktoptions = NULL;
-	if (treq->pktopts != NULL) {
-		newnp->pktoptions = skb_clone(treq->pktopts,
+	if (ireq->pktopts != NULL) {
+		newnp->pktoptions = skb_clone(ireq->pktopts,
 					      sk_gfp_atomic(sk, GFP_ATOMIC));
-		consume_skb(treq->pktopts);
-		treq->pktopts = NULL;
+		consume_skb(ireq->pktopts);
+		ireq->pktopts = NULL;
 		if (newnp->pktoptions)
 			skb_set_owner_r(newnp->pktoptions, newsk);
 	}
@@ -1722,8 +1723,8 @@ static void get_openreq6(struct seq_file *seq,
 			 const struct sock *sk, struct request_sock *req, int i, kuid_t uid)
 {
 	int ttd = req->expires - jiffies;
-	const struct in6_addr *src = &inet6_rsk(req)->loc_addr;
-	const struct in6_addr *dest = &inet6_rsk(req)->rmt_addr;
+	const struct in6_addr *src = &inet_rsk(req)->ir_v6_loc_addr;
+	const struct in6_addr *dest = &inet_rsk(req)->ir_v6_rmt_addr;
 
 	if (ttd < 0)
 		ttd = 0;
@@ -1734,10 +1735,10 @@ static void get_openreq6(struct seq_file *seq,
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3],
-		   ntohs(inet_rsk(req)->loc_port),
+		   ntohs(inet_rsk(req)->ir_loc_port),
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3],
-		   ntohs(inet_rsk(req)->rmt_port),
+		   ntohs(inet_rsk(req)->ir_rmt_port),
 		   TCP_SYN_RECV,
 		   0,0, /* could print option size, but that is af dependent. */
 		   1,   /* timers active (only the expire timer) */
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 96a458e..dce1beb 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -817,7 +817,7 @@ int netlbl_req_setattr(struct request_sock *req,
 	switch (req->rsk_ops->family) {
 	case AF_INET:
 		entry = netlbl_domhsh_getentry_af4(secattr->domain,
-						   inet_rsk(req)->rmt_addr);
+						   inet_rsk(req)->ir_rmt_addr);
 		if (entry == NULL) {
 			ret_val = -ENOENT;
 			goto req_setattr_return;
