From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [PATCH net-next] tcp: move ir_mark initialization to tcp_openreq_init
Date: Tue, 17 Jun 2014 11:25:37 +0300
Message-ID: <1402993537-6411-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:49574 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932074AbaFQIZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 04:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ir_mark initialization is done for both TCP v4 and v6, move it in the
common tcp_openreq_init function.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 include/net/tcp.h   | 3 ++-
 net/ipv4/tcp_ipv4.c | 3 +--
 net/ipv6/tcp_ipv6.c | 3 +--
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7286db8..06a3023 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1098,7 +1098,7 @@ static inline int tcp_full_space(const struct sock *sk)
 
 static inline void tcp_openreq_init(struct request_sock *req,
 				    struct tcp_options_received *rx_opt,
-				    struct sk_buff *skb)
+				    struct sk_buff *skb, struct sock *sk)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 
@@ -1117,6 +1117,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->ecn_ok = 0;
 	ireq->ir_rmt_port = tcp_hdr(skb)->source;
 	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
+	ireq->ir_mark = inet_request_mark(sk, skb);
 }
 
 extern void tcp_openreq_init_rwin(struct request_sock *req,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 77cccda..180336d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1311,14 +1311,13 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		tcp_clear_options(&tmp_opt);
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-	tcp_openreq_init(req, &tmp_opt, skb);
+	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
 	ireq = inet_rsk(req);
 	ireq->ir_loc_addr = daddr;
 	ireq->ir_rmt_addr = saddr;
 	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(skb);
-	ireq->ir_mark = inet_request_mark(sk, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 229239a..08ae3da 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1025,7 +1025,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		tcp_clear_options(&tmp_opt);
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-	tcp_openreq_init(req, &tmp_opt, skb);
+	tcp_openreq_init(req, &tmp_opt, skb, sk);
 
 	ireq = inet_rsk(req);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
@@ -1034,7 +1034,6 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		TCP_ECN_create_request(req, skb, sock_net(sk));
 
 	ireq->ir_iif = sk->sk_bound_dev_if;
-	ireq->ir_mark = inet_request_mark(sk, skb);
 
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
-- 
1.8.3.2
