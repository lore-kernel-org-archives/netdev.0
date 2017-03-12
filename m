From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 12/27] afnetns: ipv4/udp integration
Date: Mon, 13 Mar 2017 00:01:36 +0100
Message-ID: <20170312230151.5185-13-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50793 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935602AbdCLXCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:08 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 7922920795
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:03 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 5FF882423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:02 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/udp.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ea6e4cff9fafe9..5bfe2d9f5583da 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -155,6 +155,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 
 	sk_for_each(sk2, &hslot->head) {
 		if (net_eq(sock_net(sk2), net) &&
+		    sock_afnetns(sk) == sock_afnetns(sk2) &&
 		    sk2 != sk &&
 		    (bitmap || udp_sk(sk2)->udp_port_hash == num) &&
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
@@ -192,6 +193,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 	spin_lock(&hslot2->lock);
 	udp_portaddr_for_each_entry(sk2, &hslot2->head) {
 		if (net_eq(sock_net(sk2), net) &&
+		    sock_afnetns(sk) == sock_afnetns(sk2) &&
 		    sk2 != sk &&
 		    (udp_sk(sk2)->udp_port_hash == num) &&
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
@@ -220,6 +222,7 @@ static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot)
 
 	sk_for_each(sk2, &hslot->head) {
 		if (net_eq(sock_net(sk2), net) &&
+		    sock_afnetns(sk) == sock_afnetns(sk2) &&
 		    sk2 != sk &&
 		    sk2->sk_family == sk->sk_family &&
 		    ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
@@ -379,6 +382,7 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 }
 
 static int compute_score(struct sock *sk, struct net *net,
+			 struct afnetns *afnetns,
 			 __be32 saddr, __be16 sport,
 			 __be32 daddr, unsigned short hnum, int dif,
 			 bool exact_dif)
@@ -391,6 +395,9 @@ static int compute_score(struct sock *sk, struct net *net,
 	    ipv6_only_sock(sk))
 		return -1;
 
+	if (sock_afnetns(sk) != afnetns)
+		return -1;
+
 	score = (sk->sk_family == PF_INET) ? 2 : 1;
 	inet = inet_sk(sk);
 
@@ -436,6 +443,7 @@ static u32 udp_ehashfn(const struct net *net, const __be32 laddr,
 
 /* called with rcu_read_lock() */
 static struct sock *udp4_lib_lookup2(struct net *net,
+		struct afnetns *afnetns,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif, bool exact_dif,
 		struct udp_hslot *hslot2,
@@ -448,7 +456,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	result = NULL;
 	badness = 0;
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
-		score = compute_score(sk, net, saddr, sport,
+		score = compute_score(sk, net, afnetns, saddr, sport,
 				      daddr, hnum, dif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
@@ -486,8 +494,11 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
 	bool exact_dif = udp_lib_exact_dif_match(net, skb);
 	int score, badness, matches = 0, reuseport = 0;
+	struct afnetns *afnetns;
 	u32 hash = 0;
 
+	afnetns = ifa_find_afnetns_rcu(net, daddr);
+
 	if (hslot->count > 10) {
 		hash2 = udp4_portaddr_hash(net, daddr, hnum);
 		slot2 = hash2 & udptable->mask;
@@ -495,7 +506,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		if (hslot->count < hslot2->count)
 			goto begin;
 
-		result = udp4_lib_lookup2(net, saddr, sport,
+		result = udp4_lib_lookup2(net, afnetns, saddr, sport,
 					  daddr, hnum, dif,
 					  exact_dif, hslot2, skb);
 		if (!result) {
@@ -510,7 +521,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			if (hslot->count < hslot2->count)
 				goto begin;
 
-			result = udp4_lib_lookup2(net, saddr, sport,
+			result = udp4_lib_lookup2(net, afnetns, saddr, sport,
 						  daddr, hnum, dif,
 						  exact_dif, hslot2, skb);
 		}
@@ -520,7 +531,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	result = NULL;
 	badness = 0;
 	sk_for_each_rcu(sk, &hslot->head) {
-		score = compute_score(sk, net, saddr, sport,
+		score = compute_score(sk, net, afnetns, saddr, sport,
 				      daddr, hnum, dif, exact_dif);
 		if (score > badness) {
 			reuseport = sk->sk_reuseport;
@@ -2031,9 +2042,12 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
 	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr);
 	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
+	struct afnetns *afnetns = ifa_find_afnetns_rcu(net, loc_addr);
 	struct sock *sk;
 
 	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
+		if (afnetns != sock_afnetns(sk))
+			continue;
 		if (INET_MATCH(sk, net, acookie, rmt_addr,
 			       loc_addr, ports, dif))
 			return sk;
-- 
2.9.3
