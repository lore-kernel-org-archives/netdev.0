From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 2/2] ipv6: Shrink udp_v6_mcast_next() to one socket variable
Date: Thu, 29 May 2014 20:27:06 +0000
Message-ID: <1401395226-10304-3-git-send-email-sven.wegener@stealer.net>
References: <1401395226-10304-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:40544 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbaE2U11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 16:27:27 -0400
In-Reply-To: <1401395226-10304-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid the confusion of having two variables, shrink the function to
only use the parameter variable for looping.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv6/udp.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 20b63d2..9b7a99d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -701,35 +701,34 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 				      int dif)
 {
 	struct hlist_nulls_node *node;
-	struct sock *s = sk;
 	unsigned short num = ntohs(loc_port);
 
-	sk_nulls_for_each_from(s, node) {
-		struct inet_sock *inet = inet_sk(s);
+	sk_nulls_for_each_from(sk, node) {
+		struct inet_sock *inet = inet_sk(sk);
 
-		if (!net_eq(sock_net(s), net))
+		if (!net_eq(sock_net(sk), net))
 			continue;
 
-		if (udp_sk(s)->udp_port_hash == num &&
-		    s->sk_family == PF_INET6) {
+		if (udp_sk(sk)->udp_port_hash == num &&
+		    sk->sk_family == PF_INET6) {
 			if (inet->inet_dport) {
 				if (inet->inet_dport != rmt_port)
 					continue;
 			}
-			if (!ipv6_addr_any(&s->sk_v6_daddr) &&
-			    !ipv6_addr_equal(&s->sk_v6_daddr, rmt_addr))
+			if (!ipv6_addr_any(&sk->sk_v6_daddr) &&
+			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
 				continue;
 
-			if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
+			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
 				continue;
 
-			if (!ipv6_addr_any(&s->sk_v6_rcv_saddr)) {
-				if (!ipv6_addr_equal(&s->sk_v6_rcv_saddr, loc_addr))
+			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
+				if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr))
 					continue;
 			}
-			if (!inet6_mc_check(s, loc_addr, rmt_addr))
+			if (!inet6_mc_check(sk, loc_addr, rmt_addr))
 				continue;
-			return s;
+			return sk;
 		}
 	}
 	return NULL;
-- 
2.0.0
