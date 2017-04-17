From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Sun, 16 Apr 2017 18:44:30 -0600
Message-ID: <1492389870-22733-1-git-send-email-subashab@codeaurora.org>
References: <3639a683-2839-4363-2cd2-c2a040402c93@cumulusnetworks.com>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: dsa@cumulusnetworks.com, davem@davemloft.net,
        netdev@vger.kernel.org, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44508 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757011AbdDQApB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 20:45:01 -0400
In-Reply-To: <3639a683-2839-4363-2cd2-c2a040402c93@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you try this

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
