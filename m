From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/4] MIB: add struct net to UDP_INC_STATS_BH
Date: Fri, 04 Jul 2008 16:02:40 +0400
Message-ID: <486E1160.3030003@openvz.org>
References: <486E1074.7040702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50229 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746AbYGDMFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:05:12 -0400
In-Reply-To: <486E1074.7040702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two special cases here - one is rxrpc - I put init_net there
explicitly, since we haven't touched this part yet. The second
place is in __udp4_lib_rcv - we already have a struct net there,
but I have to move its initialization above to make it ready
at the "drop" label.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Denis V. Lunev <den@openvz.org>

---
 include/net/udp.h    |    6 +++---
 net/ipv4/udp.c       |   18 ++++++++++--------
 net/rxrpc/ar-input.c |    5 +++--
 3 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 1331909..7b18cfb 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -161,7 +161,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 #define UDP_INC_STATS_USER(net, field, is_udplite)	      do { (void)net; \
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_statistics, field);       \
 	else		SNMP_INC_STATS_USER(udp_statistics, field);  }  while(0)
-#define UDP_INC_STATS_BH(field, is_udplite) 			       do  {  \
+#define UDP_INC_STATS_BH(net, field, is_udplite) 	      do { (void)net; \
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);         \
 	else		SNMP_INC_STATS_BH(udp_statistics, field);    }  while(0)
 
@@ -176,12 +176,12 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 #define UDPX_INC_STATS_BH(sk, field) \
 	do { \
 		if ((sk)->sk_family == AF_INET) \
-			UDP_INC_STATS_BH(field, 0); \
+			UDP_INC_STATS_BH(sock_net(sk), field, 0); \
 		else \
 			UDP6_INC_STATS_BH(field, 0); \
 	} while (0);
 #else
-#define UDPX_INC_STATS_BH(sk, field) UDP_INC_STATS_BH(field, 0)
+#define UDPX_INC_STATS_BH(sk, field) UDP_INC_STATS_BH(sock_net(sk), field, 0)
 #endif
 
 /* /proc */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c97da53..7187121 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -991,7 +991,8 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 
 			ret = (*up->encap_rcv)(sk, skb);
 			if (ret <= 0) {
-				UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS,
+				UDP_INC_STATS_BH(sock_net(sk),
+						 UDP_MIB_INDATAGRAMS,
 						 is_udplite);
 				return -ret;
 			}
@@ -1044,7 +1045,8 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM) {
-			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, is_udplite);
+			UDP_INC_STATS_BH(sock_net(sk),
+					UDP_MIB_RCVBUFERRORS, is_udplite);
 			atomic_inc(&sk->sk_drops);
 		}
 		goto drop;
@@ -1053,7 +1055,7 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	return 0;
 
 drop:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
 }
@@ -1161,7 +1163,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct rtable *rt = (struct rtable*)skb->dst;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
-	struct net *net;
+	struct net *net = dev_net(skb->dev);
 
 	/*
 	 *  Validate the packet.
@@ -1183,7 +1185,6 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (udp4_csum_init(skb, uh, proto))
 		goto csum_error;
 
-	net = dev_net(skb->dev);
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);
@@ -1217,7 +1218,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (udp_lib_checksum_complete(skb))
 		goto csum_error;
 
-	UDP_INC_STATS_BH(UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
+	UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 	/*
@@ -1251,7 +1252,7 @@ csum_error:
 		       ntohs(uh->dest),
 		       ulen);
 drop:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
+	UDP_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
 	return 0;
 }
@@ -1458,7 +1459,8 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 		spin_lock_bh(&rcvq->lock);
 		while ((skb = skb_peek(rcvq)) != NULL &&
 		       udp_lib_checksum_complete(skb)) {
-			UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_lite);
+			UDP_INC_STATS_BH(sock_net(sk),
+					UDP_MIB_INERRORS, is_lite);
 			__skb_unlink(skb, rcvq);
 			kfree_skb(skb);
 		}
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index f8a699e..f98c802 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -21,6 +21,7 @@
 #include <net/af_rxrpc.h>
 #include <net/ip.h>
 #include <net/udp.h>
+#include <net/net_namespace.h>
 #include "ar-internal.h"
 
 unsigned long rxrpc_ack_timeout = 1;
@@ -708,12 +709,12 @@ void rxrpc_data_ready(struct sock *sk, int count)
 	if (skb_checksum_complete(skb)) {
 		rxrpc_free_skb(skb);
 		rxrpc_put_local(local);
-		UDP_INC_STATS_BH(UDP_MIB_INERRORS, 0);
+		UDP_INC_STATS_BH(&init_net, UDP_MIB_INERRORS, 0);
 		_leave(" [CSUM failed]");
 		return;
 	}
 
-	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, 0);
+	UDP_INC_STATS_BH(&init_net, UDP_MIB_INDATAGRAMS, 0);
 
 	/* the socket buffer we have is owned by UDP, with UDP's data all over
 	 * it, but we really want our own */
-- 
1.5.3.4

