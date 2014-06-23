From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [RFC net-next 04/12] tcp: add init_req method to tcp_request_sock_ops
Date: Mon, 23 Jun 2014 21:42:41 +0300
Message-ID: <1403548969-12303-5-git-send-email-octavian.purdila@intel.com>
References: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42127 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbaFWSo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 14:44:28 -0400
In-Reply-To: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the specific IPv4/IPv6 intializations to a new method in
tcp_request_sock_ops in preparation for unifying tcp_v4_conn_request
and tcp_v6_conn_request.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/linux/tcp.h |  3 ---
 include/net/tcp.h   |  2 ++
 net/ipv4/tcp_ipv4.c | 29 ++++++++++++++++------------
 net/ipv6/tcp_ipv6.c | 55 +++++++++++++++++++++++++++++++----------------------
 4 files changed, 51 insertions(+), 38 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a051321..fa5258f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -111,10 +111,7 @@ struct tcp_request_sock_ops;
 
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
-#ifdef CONFIG_TCP_MD5SIG
-	/* Only used by TCP MD5 Signature so far. */
 	const struct tcp_request_sock_ops *af_specific;
-#endif
 	struct sock			*listener; /* needed for TFO */
 	u32				rcv_isn;
 	u32				snt_isn;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 39e47c4..7ad8ce2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1613,6 +1613,8 @@ struct tcp_request_sock_ops {
 						  const struct request_sock *req,
 						  const struct sk_buff *skb);
 #endif
+	void (*init_req)(struct request_sock *req, struct sock *sk,
+			 struct sk_buff *skb);
 };
 
 int tcpv4_offload_init(void);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 145f640..f86a86b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1237,6 +1237,17 @@ static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 
 #endif
 
+static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
+			    struct sk_buff *skb)
+{
+	struct inet_request_sock *ireq = inet_rsk(req);
+
+	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
+	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
+	ireq->no_srccheck = inet_sk(sk)->transparent;
+	ireq->opt = tcp_v4_save_options(skb);
+}
+
 struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 	.family		=	PF_INET,
 	.obj_size	=	sizeof(struct tcp_request_sock),
@@ -1247,26 +1258,26 @@ struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 	.syn_ack_timeout = 	tcp_syn_ack_timeout,
 };
 
-#ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
+#ifdef CONFIG_TCP_MD5SIG
 	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
-};
 #endif
+	.init_req	=	tcp_v4_init_req,
+};
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tmp_opt;
 	struct request_sock *req;
-	struct inet_request_sock *ireq;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = NULL;
 	__be32 saddr = ip_hdr(skb)->saddr;
-	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	bool want_cookie = false, fastopen;
 	struct flowi4 fl4;
 	struct tcp_fastopen_cookie foc = { .len = -1 };
+	const struct tcp_request_sock_ops *af_ops;
 	int err;
 
 	/* Never answer to SYNs send to broadcast or multicast */
@@ -1298,9 +1309,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (!req)
 		goto drop;
 
-#ifdef CONFIG_TCP_MD5SIG
-	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
-#endif
+	af_ops = tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
@@ -1313,11 +1322,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
-	ireq = inet_rsk(req);
-	ireq->ir_loc_addr = daddr;
-	ireq->ir_rmt_addr = saddr;
-	ireq->no_srccheck = inet_sk(sk)->transparent;
-	ireq->opt = tcp_v4_save_options(skb);
+	af_ops->init_req(req, sk, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5e2d7e6..87a360c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -720,6 +720,31 @@ static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 }
 #endif
 
+static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
+			    struct sk_buff *skb)
+{
+	struct inet_request_sock *ireq = inet_rsk(req);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
+	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
+
+	ireq->ir_iif = sk->sk_bound_dev_if;
+
+	/* So that link locals have meaning */
+	if (!sk->sk_bound_dev_if &&
+	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
+		ireq->ir_iif = inet6_iif(skb);
+
+	if (!TCP_SKB_CB(skb)->when &&
+	    (ipv6_opt_accepted(sk, skb) || np->rxopt.bits.rxinfo ||
+	     np->rxopt.bits.rxoinfo || np->rxopt.bits.rxhlim ||
+	     np->rxopt.bits.rxohlim || np->repflow)) {
+		atomic_inc(&skb->users);
+		ireq->pktopts = skb;
+	}
+}
+
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.family		=	AF_INET6,
 	.obj_size	=	sizeof(struct tcp6_request_sock),
@@ -730,12 +755,13 @@ struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 	.syn_ack_timeout =	tcp_syn_ack_timeout,
 };
 
-#ifdef CONFIG_TCP_MD5SIG
 static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
+#ifdef CONFIG_TCP_MD5SIG
 	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
-};
 #endif
+	.init_req	=	tcp_v6_init_req,
+};
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 				 u32 tsval, u32 tsecr, int oif,
@@ -983,13 +1009,13 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct tcp_options_received tmp_opt;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
-	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
 	struct tcp_fastopen_cookie foc = { .len = -1 };
 	bool want_cookie = false, fastopen;
 	struct flowi6 fl6;
+	const struct tcp_request_sock_ops *af_ops;
 	int err;
 
 	if (skb->protocol == htons(ETH_P_IP))
@@ -1014,9 +1040,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (req == NULL)
 		goto drop;
 
-#ifdef CONFIG_TCP_MD5SIG
-	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
-#endif
+	af_ops = tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
 
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
@@ -1030,27 +1054,12 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
 	ireq = inet_rsk(req);
-	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
-	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
+	af_ops->init_req(req, sk, skb);
+
 	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, skb, sock_net(sk));
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
-
-	/* So that link locals have meaning */
-	if (!sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
-		ireq->ir_iif = inet6_iif(skb);
-
 	if (!isn) {
-		if (ipv6_opt_accepted(sk, skb) ||
-		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
-		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim ||
-		    np->repflow) {
-			atomic_inc(&skb->users);
-			ireq->pktopts = skb;
-		}
-
 		if (want_cookie) {
 			isn = cookie_v6_init_sequence(sk, skb, &req->mss);
 			req->cookie_ts = tmp_opt.tstamp_ok;
-- 
1.8.3.2
