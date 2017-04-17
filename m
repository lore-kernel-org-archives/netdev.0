From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next] net: ipv6: Fix UDP early demux lookup with udp_l3mdev_accept=0
Date: Mon, 17 Apr 2017 15:11:43 -0600
Message-ID: <1492463503-3351-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: dsa@cumulusnetworks.com, davem@davemloft.net,
        netdev@vger.kernel.org, rshearma@brocade.com,
        eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41746 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752484AbdDQVPX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 17:15:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern reported that 5425077d73e0c ("net: ipv6: Add early demux
handler for UDP unicast") breaks udp_l3mdev_accept=0 since early
demux for IPv6 UDP was doing a generic socket lookup which does not
require an exact match. Fix this by making UDPv6 early demux match
connected sockets only.

Fixes: 5425077d73e0c ("net: ipv6: Add early demux handler for UDP unicast")
Reported-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv6/udp.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b793ed1..0e307e5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -46,6 +46,7 @@
 #include <net/tcp_states.h>
 #include <net/ip6_checksum.h>
 #include <net/xfrm.h>
+#include <net/inet_hashtables.h>
 #include <net/inet6_hashtables.h>
 #include <net/busy_poll.h>
 #include <net/sock_reuseport.h>
@@ -864,21 +865,25 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	return 0;
 }
 
+
 static struct sock *__udp6_lib_demux_lookup(struct net *net,
 			__be16 loc_port, const struct in6_addr *loc_addr,
 			__be16 rmt_port, const struct in6_addr *rmt_addr,
 			int dif)
 {
+	unsigned short hnum = ntohs(loc_port);
+	unsigned int hash2 = udp6_portaddr_hash(net, loc_addr, hnum);
+	unsigned int slot2 = hash2 & udp_table.mask;
+	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
+	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
 	struct sock *sk;
 
-	rcu_read_lock();
-	sk = __udp6_lib_lookup(net, rmt_addr, rmt_port, loc_addr, loc_port,
-			       dif, &udp_table, NULL);
-	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
-		sk = NULL;
-	rcu_read_unlock();
-
-	return sk;
+	udp_portaddr_for_each_entry_rcu(sk, &hslot2->head) {
+		if (INET6_MATCH(sk, net, rmt_addr, loc_addr, ports, dif))
+			return sk;
+		break;
+	}
+	return NULL;
 }
 
 static void udp_v6_early_demux(struct sk_buff *skb)
-- 
1.9.1
