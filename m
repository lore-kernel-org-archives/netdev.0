From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/4] MIB: add struct net to UDP6_INC_STATS_BH
Date: Fri, 04 Jul 2008 16:04:53 +0400
Message-ID: <486E11E5.7040500@openvz.org>
References: <486E1074.7040702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50240 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863AbYGDMHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:07:24 -0400
In-Reply-To: <486E1074.7040702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Denis V. Lunev <den@openvz.org>


---
 include/net/udp.h |    4 ++--
 net/ipv6/udp.c    |   13 +++++++------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index bb5b9ec..3e55159 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -165,7 +165,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);         \
 	else		SNMP_INC_STATS_BH(udp_statistics, field);    }  while(0)
 
-#define UDP6_INC_STATS_BH(field, is_udplite) 			      do  {  \
+#define UDP6_INC_STATS_BH(net, field, is_udplite) 	    do { (void)net;  \
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
 	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
 #define UDP6_INC_STATS_USER(net, field, is_udplite)	    do { (void)net;    \
@@ -178,7 +178,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 		if ((sk)->sk_family == AF_INET) \
 			UDP_INC_STATS_BH(sock_net(sk), field, 0); \
 		else \
-			UDP6_INC_STATS_BH(field, 0); \
+			UDP6_INC_STATS_BH(sock_net(sk), field, 0); \
 	} while (0);
 #else
 #define UDPX_INC_STATS_BH(sk, field) UDP_INC_STATS_BH(sock_net(sk), field, 0)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 833f715..d1477b3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -299,7 +299,8 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM) {
-			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, is_udplite);
+			UDP6_INC_STATS_BH(sock_net(sk),
+					UDP_MIB_RCVBUFERRORS, is_udplite);
 			atomic_inc(&sk->sk_drops);
 		}
 		goto drop;
@@ -307,7 +308,7 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 
 	return 0;
 drop:
-	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
 }
@@ -439,7 +440,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct net_device *dev = skb->dev;
 	struct in6_addr *saddr, *daddr;
 	u32 ulen = 0;
-	struct net *net;
+	struct net *net = dev_net(skb->dev);
 
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		goto short_packet;
@@ -474,7 +475,6 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (udp6_csum_init(skb, uh, proto))
 		goto discard;
 
-	net = dev_net(skb->dev);
 	/*
 	 *	Multicast receive code
 	 */
@@ -497,7 +497,8 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 
 		if (udp_lib_checksum_complete(skb))
 			goto discard;
-		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
+		UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS,
+				proto == IPPROTO_UDPLITE);
 
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
 
@@ -522,7 +523,7 @@ short_packet:
 		       ulen, skb->len);
 
 discard:
-	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
+	UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
 	return 0;
 }
-- 
1.5.3.4

