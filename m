From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] udp: restore UDPlite many-cast delivery
Date: Mon, 14 Nov 2016 23:40:30 +0100
Message-ID: <1479163230-8734-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, edumazet@google.com, drheld@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56678 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752842AbcKNWko (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 17:40:44 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0D00220942F
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 23:40:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F27CFDA871
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 23:40:42 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B8187DA853
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 23:40:38 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Honor udptable parameter that is passed to __udp*_lib_mcast_deliver(),
otherwise udplite broadcast/multicast use the wrong table and it breaks.

Fixes: 2dc41cff7545 ("udp: Use hash2 for long hash1 chains in __udp*_lib_mcast_deliver.")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
It looks like UDPlite accidentally broke when dealing with long UDP many-cast
chains, give the wrong table is used for udplite. Compile tested only.

 net/ipv4/udp.c | 6 +++---
 net/ipv6/udp.c | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 195992e0440d..5b5a552a2804 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1731,10 +1731,10 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 
 	if (use_hash2) {
 		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
-			    udp_table.mask;
-		hash2 = udp4_portaddr_hash(net, daddr, hnum) & udp_table.mask;
+			    udptable->mask;
+		hash2 = udp4_portaddr_hash(net, daddr, hnum) & udptable->mask;
 start_lookup:
-		hslot = &udp_table.hash2[hash2];
+		hslot = &udptable->hash2[hash2];
 		offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
 	}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a7700bbf6788..a9dd23d5c3c4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -688,10 +688,10 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 
 	if (use_hash2) {
 		hash2_any = udp6_portaddr_hash(net, &in6addr_any, hnum) &
-			    udp_table.mask;
-		hash2 = udp6_portaddr_hash(net, daddr, hnum) & udp_table.mask;
+			    udptable->mask;
+		hash2 = udp6_portaddr_hash(net, daddr, hnum) & udptable->mask;
 start_lookup:
-		hslot = &udp_table.hash2[hash2];
+		hslot = &udptable->hash2[hash2];
 		offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
 	}
 
-- 
2.1.4
