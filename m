From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [RFC net-next] Include selection of congestion control algorithm in that which is inherited across an accept() call
Date: Tue, 29 Nov 2011 16:31:12 -0800 (PST)
Message-ID: <20111130003112.C04FE29005FE@tardy>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:46754 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143Ab1K3AbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 19:31:14 -0500
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g1t0028.austin.hp.com (Postfix) with ESMTP id 784E61C168
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 00:31:13 +0000 (UTC)
Received: from tardy (tardy.cup.hp.com [16.89.64.213])
	by g1t0038.austin.hp.com (Postfix) with ESMTP id 532BE30078
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 00:31:13 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Include congestion control algorithm in what is inherited across an
accept() call.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Before patch, with cubic as the default:
raj@raj-ubuntu-guest:~$ ./tcp_congestion_test  reno
Will be requesting 'reno' as the congestion control algorithm
active socket has 'reno' for congestion control
passive socket has 'reno' for congestion control
after listen() passive socket has 'reno' for congestion control
after connect() active has 'reno' for congestion control
after accept() accepted has 'cubic' for congestion control 

After patch, still with cubic as the default:
raj@raj-ubuntu-guest:~$ ./tcp_congestion_test reno
Will be requesting 'reno' as the congestion control algorithm
active socket has 'reno' for congestion control
passive socket has 'reno' for congestion control
after listen() passive socket has 'reno' for congestion control
after connect() active has 'reno' for congestion control
after accept() accepted has 'reno' for congestion control

IPv6 portion compiled only.


 include/linux/ipv6.h     |    3 +++
 include/net/inet_sock.h  |    3 +++
 net/ipv4/tcp_ipv4.c      |    3 +++
 net/ipv4/tcp_minisocks.c |    2 +-
 net/ipv6/tcp_ipv6.c      |    3 +++
 5 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0c99776..1d0dde3 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -265,11 +265,14 @@ static inline int inet6_iif(const struct sk_buff *skb)
 	return IP6CB(skb)->iif;
 }
 
+struct tcp_congestion_ops;
+
 struct inet6_request_sock {
 	struct in6_addr		loc_addr;
 	struct in6_addr		rmt_addr;
 	struct sk_buff		*pktopts;
 	int			iif;
+	const struct tcp_congestion_ops *cong_ops;
 };
 
 struct tcp6_request_sock {
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index f941964..9ec68a3 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -69,6 +69,8 @@ struct ip_options_data {
 	char			data[40];
 };
 
+struct tcp_congestion_ops;
+
 struct inet_request_sock {
 	struct request_sock	req;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -89,6 +91,7 @@ struct inet_request_sock {
 				no_srccheck: 1;
 	kmemcheck_bitfield_end(flags);
 	struct ip_options_rcu	*opt;
+	const struct tcp_congestion_ops *cong_ops;
 };
 
 static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a9db4b1..79c02e2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1254,6 +1254,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	const u8 *hash_location;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = NULL;
 	__be32 saddr = ip_hdr(skb)->saddr;
@@ -1341,6 +1342,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->rmt_addr = saddr;
 	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(sk, skb);
+	ireq->cong_ops = (icsk->icsk_ca_ops) ? icsk->icsk_ca_ops :
+					&tcp_init_congestion_ops;
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 945efff..be338d7 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -495,7 +495,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->frto_counter = 0;
 		newtp->frto_highmark = 0;
 
-		newicsk->icsk_ca_ops = &tcp_init_congestion_ops;
+		newicsk->icsk_ca_ops = ireq->cong_ops;
 
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9d74eee..c689779 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1164,6 +1164,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	const u8 *hash_location;
 	struct request_sock *req;
 	struct inet6_request_sock *treq;
+	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
@@ -1254,6 +1255,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
 	treq->iif = sk->sk_bound_dev_if;
+	treq->cong_ops = (icsk->icsk_ca_ops) ? icsk->icsk_ca_ops :
+					&tcp_init_congestion_ops;
 
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
