From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 16/27] afnetns: add udpv6 support
Date: Mon, 13 Mar 2017 00:01:40 +0100
Message-ID: <20170312230151.5185-17-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:34973 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935672AbdCLXCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:21 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id F2EC0206E6
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:07 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id DA3A92436A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:06 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/datagram.c |  6 ++++--
 net/ipv6/udp.c      | 18 +++++++++++++-----
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index eec27f87efaca1..cd811e8b1ba824 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -804,8 +804,10 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			if (addr_type != IPV6_ADDR_ANY) {
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
 				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
-				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
-						   strict ? dev : NULL, 0) &&
+				    !ipv6_chk_addr_and_flags(net, sock_afnetns(sk),
+							     &src_info->ipi6_addr,
+							     strict ? dev : NULL, 0,
+							     IFA_F_TENTATIVE) &&
 				    !ipv6_chk_acast_addr_src(net, dev,
 							     &src_info->ipi6_addr))
 					err = -EINVAL;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4e4c401e3bc690..d63e0e362fe72b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -126,6 +126,7 @@ static void udp_v6_rehash(struct sock *sk)
 }
 
 static int compute_score(struct sock *sk, struct net *net,
+			 struct afnetns *afnetns,
 			 const struct in6_addr *saddr, __be16 sport,
 			 const struct in6_addr *daddr, unsigned short hnum,
 			 int dif, bool exact_dif)
@@ -138,6 +139,9 @@ static int compute_score(struct sock *sk, struct net *net,
 	    sk->sk_family != PF_INET6)
 		return -1;
 
+	if (sock_afnetns(sk) != afnetns)
+		return -1;
+
 	score = 0;
 	inet = inet_sk(sk);
 
@@ -173,6 +177,7 @@ static int compute_score(struct sock *sk, struct net *net,
 
 /* called with rcu_read_lock() */
 static struct sock *udp6_lib_lookup2(struct net *net,
+		struct afnetns *afnetns,
 		const struct in6_addr *saddr, __be16 sport,
 		const struct in6_addr *daddr, unsigned int hnum, int dif,
 		bool exact_dif, struct udp_hslot *hslot2,
@@ -185,7 +190,7 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 	result = NULL;
 	badness = -1;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		score = compute_score(sk, net, saddr, sport,
+		score = compute_score(sk, net, afnetns, saddr, sport,
 				      daddr, hnum, dif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
@@ -224,8 +229,11 @@ struct sock *__udp6_lib_lookup(struct net *net,
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
 	bool exact_dif = udp6_lib_exact_dif_match(net, skb);
 	int score, badness, matches = 0, reuseport = 0;
+	struct afnetns *afnetns;
 	u32 hash = 0;
 
+	afnetns = ipv6_get_ifaddr_afnetns_rcu(net, daddr, skb->dev);
+
 	if (hslot->count > 10) {
 		hash2 = udp6_portaddr_hash(net, daddr, hnum);
 		slot2 = hash2 & udptable->mask;
@@ -233,7 +241,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 		if (hslot->count < hslot2->count)
 			goto begin;
 
-		result = udp6_lib_lookup2(net, saddr, sport,
+		result = udp6_lib_lookup2(net, afnetns, saddr, sport,
 					  daddr, hnum, dif, exact_dif,
 					  hslot2, skb);
 		if (!result) {
@@ -248,7 +256,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			if (hslot->count < hslot2->count)
 				goto begin;
 
-			result = udp6_lib_lookup2(net, saddr, sport,
+			result = udp6_lib_lookup2(net, afnetns, saddr, sport,
 						  daddr, hnum, dif,
 						  exact_dif, hslot2,
 						  skb);
@@ -259,8 +267,8 @@ struct sock *__udp6_lib_lookup(struct net *net,
 	result = NULL;
 	badness = -1;
 	sk_for_each_rcu(sk, &hslot->head) {
-		score = compute_score(sk, net, saddr, sport, daddr, hnum, dif,
-				      exact_dif);
+		score = compute_score(sk, net, afnetns, saddr, sport, daddr,
+				      hnum, dif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
-- 
2.9.3
