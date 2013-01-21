From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/5 v2] soreuseport: UDP/IPv4 implementation
Date: Sun, 20 Jan 2013 16:07:42 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301201542500.1469@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="296491395-1111469496-1358726862=:1469"
Cc: netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:44010 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab3AUAHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 19:07:43 -0500
Received: by mail-gg0-f202.google.com with SMTP id l4so81915ggi.5
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 16:07:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--296491395-1111469496-1358726862=:1469
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

Allow multiple UDP sockets to bind to the same port.

Motivation soreuseport would be something like a DNS server.  An
alternative would be to recv on the same socket from multiple threads.
As in the case of TCP, the load across these threads tends to be
disproportionate and we also see a lot of contection on the socketlock.
Note that SO_REUSEADDR already allows multiple UDP sockets to bind to
the same port, however there is no provision to prevent hijacking and
nothing to distribute packets across all the sockets sharing the same
bound port.  This patch does not change the semantics of SO_REUSEADDR,
but provides usable functionality of it for unicast.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp.c |   61 +++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 43 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..b360b30 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -139,6 +139,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 {
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
+	kuid_t uid = sock_i_uid(sk);
 
 	sk_nulls_for_each(sk2, node, &hslot->head)
 		if (net_eq(sock_net(sk2), net) &&
@@ -147,6 +148,8 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
+		      !uid_eq(uid, sock_i_uid(sk2))) &&
 		    (*saddr_comp)(sk, sk2)) {
 			if (bitmap)
 				__set_bit(udp_sk(sk2)->udp_port_hash >> log,
@@ -169,6 +172,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 {
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
+	kuid_t uid = sock_i_uid(sk);
 	int res = 0;
 
 	spin_lock(&hslot2->lock);
@@ -179,6 +183,8 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
+		      !uid_eq(uid, sock_i_uid(sk2))) &&
 		    (*saddr_comp)(sk, sk2)) {
 			res = 1;
 			break;
@@ -337,26 +343,26 @@ static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
 			!ipv6_only_sock(sk)) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		score = (sk->sk_family == PF_INET ? 1 : 0);
+		score = (sk->sk_family == PF_INET ? 2 : 1);
 		if (inet->inet_rcv_saddr) {
 			if (inet->inet_rcv_saddr != daddr)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (inet->inet_daddr) {
 			if (inet->inet_daddr != saddr)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (inet->inet_dport) {
 			if (inet->inet_dport != sport)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (sk->sk_bound_dev_if) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 	}
 	return score;
@@ -365,7 +371,6 @@ static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
 /*
  * In this second variant, we check (daddr, dport) matches (inet_rcv_sadd, inet_num)
  */
-#define SCORE2_MAX (1 + 2 + 2 + 2)
 static inline int compute_score2(struct sock *sk, struct net *net,
 				 __be32 saddr, __be16 sport,
 				 __be32 daddr, unsigned int hnum, int dif)
@@ -380,21 +385,21 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		if (inet->inet_num != hnum)
 			return -1;
 
-		score = (sk->sk_family == PF_INET ? 1 : 0);
+		score = (sk->sk_family == PF_INET ? 2 : 1);
 		if (inet->inet_daddr) {
 			if (inet->inet_daddr != saddr)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (inet->inet_dport) {
 			if (inet->inet_dport != sport)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 		if (sk->sk_bound_dev_if) {
 			if (sk->sk_bound_dev_if != dif)
 				return -1;
-			score += 2;
+			score += 4;
 		}
 	}
 	return score;
@@ -409,19 +414,29 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
-	int score, badness;
+	int score, badness, matches = 0, reuseport = 0;
+	u32 hash = 0;
 
 begin:
 	result = NULL;
-	badness = -1;
+	badness = 0;
 	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
 		score = compute_score2(sk, net, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
-			if (score == SCORE2_MAX)
-				goto exact_match;
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				hash = inet_ehashfn(net, daddr, hnum,
+						    saddr, htons(sport));
+				matches = 1;
+			}
+		} else if (score == badness && reuseport) {
+			matches++;
+			if (((u64)hash * matches) >> 32 == 0)
+				result = sk;
+			hash = next_pseudo_random32(hash);
 		}
 	}
 	/*
@@ -431,9 +446,7 @@ begin:
 	 */
 	if (get_nulls_value(node) != slot2)
 		goto begin;
-
 	if (result) {
-exact_match:
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score2(result, net, saddr, sport,
@@ -457,7 +470,8 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash2, slot2, slot = udp_hashfn(net, hnum, udptable->mask);
 	struct udp_hslot *hslot2, *hslot = &udptable->hash[slot];
-	int score, badness;
+	int score, badness, matches = 0, reuseport = 0;
+	u32 hash = 0;
 
 	rcu_read_lock();
 	if (hslot->count > 10) {
@@ -486,13 +500,24 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	}
 begin:
 	result = NULL;
-	badness = -1;
+	badness = 0;
 	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
 		score = compute_score(sk, net, saddr, hnum, sport,
 				      daddr, dport, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
+			reuseport = sk->sk_reuseport;
+			if (reuseport) {
+				hash = inet_ehashfn(net, daddr, hnum,
+						    saddr, htons(sport));
+				matches = 1;
+			}
+		} else if (score == badness && reuseport) {
+			matches++;
+			if (((u64)hash * matches) >> 32 == 0)
+				result = sk;
+			hash = next_pseudo_random32(hash);
 		}
 	}
 	/*
-- 
1.7.7.3

--296491395-1111469496-1358726862=:1469--
