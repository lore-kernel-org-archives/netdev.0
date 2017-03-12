From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 19/27] afnetns: add afnetns support for tcpv4
Date: Mon, 13 Mar 2017 00:01:43 +0100
Message-ID: <20170312230151.5185-20-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52377 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935626AbdCLXCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:13 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 8D49F20638
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:11 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id C1BAD240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:10 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the necessary checks to inet_hashtables, so that
sockets also have to match the corresponding afnetns.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_sock.h    |  1 +
 net/ipv4/inet_hashtables.c | 17 +++++++++++++++--
 net/ipv4/tcp_input.c       |  3 +++
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index aa95053dfc78d3..d348f150e8e2c9 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -81,6 +81,7 @@ struct inet_request_sock {
 #define ir_iif			req.__req_common.skc_bound_dev_if
 #define ir_cookie		req.__req_common.skc_cookie
 #define ireq_net		req.__req_common.skc_net
+#define ireq_afnet		req.__req_common.skc_afnet
 #define ireq_state		req.__req_common.skc_state
 #define ireq_family		req.__req_common.skc_family
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 8bea74298173f5..813a8fa1331944 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -28,6 +28,8 @@
 #include <net/tcp.h>
 #include <net/sock_reuseport.h>
 
+#include <linux/inetdevice.h>
+
 static u32 inet_ehashfn(const struct net *net, const __be32 laddr,
 			const __u16 lport, const __be32 faddr,
 			const __be16 fport)
@@ -169,6 +171,7 @@ int __inet_inherit_port(const struct sock *sk, struct sock *child)
 EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
 static inline int compute_score(struct sock *sk, struct net *net,
+				struct afnetns *afnetns,
 				const unsigned short hnum, const __be32 daddr,
 				const int dif, bool exact_dif)
 {
@@ -176,7 +179,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 	struct inet_sock *inet = inet_sk(sk);
 
 	if (net_eq(sock_net(sk), net) && inet->inet_num == hnum &&
-			!ipv6_only_sock(sk)) {
+	    afnetns == sock_afnetns(sk) && !ipv6_only_sock(sk)) {
 		__be32 rcv_saddr = inet->inet_rcv_saddr;
 		score = sk->sk_family == PF_INET ? 2 : 1;
 		if (rcv_saddr) {
@@ -215,10 +218,14 @@ struct sock *__inet_lookup_listener(struct net *net,
 	int score, hiscore = 0, matches = 0, reuseport = 0;
 	bool exact_dif = inet_exact_dif_match(net, skb);
 	struct sock *sk, *result = NULL;
+	struct afnetns *afnetns;
 	u32 phash = 0;
 
+	afnetns = ifa_find_afnetns_rcu(net, daddr);
+
 	sk_for_each_rcu(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
+		score = compute_score(sk, net, afnetns, hnum, daddr, dif,
+				      exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
@@ -272,6 +279,7 @@ struct sock *__inet_lookup_established(struct net *net,
 {
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
+	struct afnetns *afnetns;
 	struct sock *sk;
 	const struct hlist_nulls_node *node;
 	/* Optimize here for direct hit, only listening connections can
@@ -281,10 +289,14 @@ struct sock *__inet_lookup_established(struct net *net,
 	unsigned int slot = hash & hashinfo->ehash_mask;
 	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
+	afnetns = ifa_find_afnetns_rcu(net, daddr);
+
 begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
 			continue;
+		if (afnetns != sock_afnetns(sk))
+			continue;
 		if (likely(INET_MATCH(sk, net, acookie,
 				      saddr, daddr, ports, dif))) {
 			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
@@ -445,6 +457,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
 		    sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
 		    inet_csk(sk2)->icsk_bind_hash == tb &&
 		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
+		    sock_afnetns(sk) == sock_afnetns(sk2) &&
 		    inet_rcv_saddr_equal(sk, sk2, false))
 			return reuseport_add_sock(sk, sk2);
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 96b67a8b18c3c3..0fc69a32c9faea 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6211,6 +6211,9 @@ struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 		atomic64_set(&ireq->ir_cookie, 0);
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
 		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
+#if IS_ENABLED(CONFIG_AFNETNS)
+		ireq->ireq_afnet = sock_afnetns(sk_listener);
+#endif
 		ireq->ireq_family = sk_listener->sk_family;
 	}
 
-- 
2.9.3
