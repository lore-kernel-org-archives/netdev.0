From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH 1/2] ipv6: Fix regression caused by efe4208 in udp_v6_mcast_next()
Date: Thu, 29 May 2014 20:27:05 +0000
Message-ID: <1401395226-10304-2-git-send-email-sven.wegener@stealer.net>
References: <1401395226-10304-1-git-send-email-sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:40536 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527AbaE2U11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 16:27:27 -0400
In-Reply-To: <1401395226-10304-1-git-send-email-sven.wegener@stealer.net>
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

Cc: Eric Dumazet <edumazet@google.com>
Cc: stable@vger.kernel.org # 3.13+
Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv6/udp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d9..20b63d2 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -716,15 +716,15 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 				if (inet->inet_dport != rmt_port)
 					continue;
 			}
-			if (!ipv6_addr_any(&sk->sk_v6_daddr) &&
-			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
+			if (!ipv6_addr_any(&s->sk_v6_daddr) &&
+			    !ipv6_addr_equal(&s->sk_v6_daddr, rmt_addr))
 				continue;
 
 			if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
 				continue;
 
-			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-				if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr))
+			if (!ipv6_addr_any(&s->sk_v6_rcv_saddr)) {
+				if (!ipv6_addr_equal(&s->sk_v6_rcv_saddr, loc_addr))
 					continue;
 			}
 			if (!inet6_mc_check(s, loc_addr, rmt_addr))
-- 
2.0.0
