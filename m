From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipv6: Fix regression caused by efe4208 in
 udp_v6_mcast_next()
Date: Sun, 25 May 2014 16:14:08 +0200 (CEST)
Message-ID: <alpine.LNX.2.11.1405251611020.22222@titan.int.lan.stealer.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:50418 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaEYOUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 10:20:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit efe4208 ("ipv6: make lookups simpler and faster") introduced a
regression in udp_v6_mcast_next(), resulting in multicast packets not
reaching the destination sockets under certain conditions.

The packet's IPv6 addresses are wrongly compared to the IPv6 addresses
from the function's socket argument, which indicates the starting point
for looping, instead of the loop variable. If the addresses from the
first socket do not match the packet's addresses, no socket in the list
will match.

Fix this by shrinking the function to use one variable for the socket to
avoid confusion in the future.

Cc: Eric Dumazet <edumazet@google.com>
Cc: stable@vger.kernel.org # 3.13+
Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv6/udp.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d9..9b7a99d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -701,17 +701,16 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
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
@@ -720,16 +719,16 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
 				continue;
 
-			if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
+			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
 				continue;
 
 			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
 				if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr))
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
