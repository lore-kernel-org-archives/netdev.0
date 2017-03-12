From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 21/27] afnetns: add support for tcpv6
Date: Mon, 13 Mar 2017 00:01:45 +0100
Message-ID: <20170312230151.5185-22-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50793 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935642AbdCLXCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:16 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 78CDD207D1
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:13 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id E3F0D240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:12 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same as the support for tcpv4, we simply add the necessary checks so we
just look at our own sockets.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/inet6_hashtables.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 8570e0e3016b65..05b71f0937e676 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -87,6 +87,7 @@ struct sock *__inet6_lookup_established(struct net *net,
 					   const u16 hnum,
 					   const int dif)
 {
+	struct afnetns *afnetns;
 	struct sock *sk;
 	const struct hlist_nulls_node *node;
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
@@ -97,11 +98,15 @@ struct sock *__inet6_lookup_established(struct net *net,
 	unsigned int slot = hash & hashinfo->ehash_mask;
 	struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 
+	afnetns = ipv6_get_ifaddr_afnetns_rcu(net, daddr,
+					      dev_get_by_index_rcu(net, dif));
 
 begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
 			continue;
+		if (sock_afnetns(sk) != afnetns)
+			continue;
 		if (!INET6_MATCH(sk, net, saddr, daddr, ports, dif))
 			continue;
 		if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
@@ -123,14 +128,15 @@ struct sock *__inet6_lookup_established(struct net *net,
 EXPORT_SYMBOL(__inet6_lookup_established);
 
 static inline int compute_score(struct sock *sk, struct net *net,
+				struct afnetns *afnetns,
 				const unsigned short hnum,
 				const struct in6_addr *daddr,
 				const int dif, bool exact_dif)
 {
 	int score = -1;
 
-	if (net_eq(sock_net(sk), net) && inet_sk(sk)->inet_num == hnum &&
-	    sk->sk_family == PF_INET6) {
+	if (net_eq(sock_net(sk), net) && sock_afnetns(sk) == afnetns &&
+	    inet_sk(sk)->inet_num == hnum && sk->sk_family == PF_INET6) {
 
 		score = 1;
 		if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
@@ -162,10 +168,14 @@ struct sock *inet6_lookup_listener(struct net *net,
 	int score, hiscore = 0, matches = 0, reuseport = 0;
 	bool exact_dif = inet6_exact_dif_match(net, skb);
 	struct sock *sk, *result = NULL;
+	struct afnetns *afnetns;
 	u32 phash = 0;
 
+	afnetns = ipv6_get_ifaddr_afnetns_rcu(net, daddr, skb->dev);
+
 	sk_for_each(sk, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif, exact_dif);
+		score = compute_score(sk, net, afnetns, hnum, daddr, dif,
+				      exact_dif);
 		if (score > hiscore) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-- 
2.9.3
