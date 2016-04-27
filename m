From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/17] net: udp: rename UDP_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:30 -0700
Message-ID: <1461800683-25034-5-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36365 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbcD0XpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:06 -0400
Received: by mail-pa0-f52.google.com with SMTP id bt5so24995398pac.3
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:06 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename UDP_INC_STATS_BH() to __UDP_INC_STATS(),
and UDP6_INC_STATS_BH() to __UDP6_INC_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/udp.h     | 12 ++++++------
 net/ipv4/udp.c        | 46 +++++++++++++++++++++++-----------------------
 net/ipv6/udp.c        | 38 +++++++++++++++++++-------------------
 net/rxrpc/ar-input.c  |  4 ++--
 net/sunrpc/xprtsock.c |  4 ++--
 5 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 2f37f689d85a..bf6a7c29cf6a 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -292,11 +292,11 @@ struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 #define UDP_INC_STATS(net, field, is_udplite)		      do { \
 	if (is_udplite) SNMP_INC_STATS((net)->mib.udplite_statistics, field);       \
 	else		SNMP_INC_STATS((net)->mib.udp_statistics, field);  }  while(0)
-#define UDP_INC_STATS_BH(net, field, is_udplite) 	      do { \
+#define __UDP_INC_STATS(net, field, is_udplite) 	      do { \
 	if (is_udplite) SNMP_INC_STATS_BH((net)->mib.udplite_statistics, field);         \
 	else		SNMP_INC_STATS_BH((net)->mib.udp_statistics, field);    }  while(0)
 
-#define UDP6_INC_STATS_BH(net, field, is_udplite)	    do { \
+#define __UDP6_INC_STATS(net, field, is_udplite)	    do { \
 	if (is_udplite) SNMP_INC_STATS_BH((net)->mib.udplite_stats_in6, field);\
 	else		SNMP_INC_STATS_BH((net)->mib.udp_stats_in6, field);  \
 } while(0)
@@ -306,15 +306,15 @@ struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 } while(0)
 
 #if IS_ENABLED(CONFIG_IPV6)
-#define UDPX_INC_STATS_BH(sk, field)					\
+#define __UDPX_INC_STATS(sk, field)					\
 do {									\
 	if ((sk)->sk_family == AF_INET)					\
-		UDP_INC_STATS_BH(sock_net(sk), field, 0);		\
+		__UDP_INC_STATS(sock_net(sk), field, 0);		\
 	else								\
-		UDP6_INC_STATS_BH(sock_net(sk), field, 0);		\
+		__UDP6_INC_STATS(sock_net(sk), field, 0);		\
 } while (0)
 #else
-#define UDPX_INC_STATS_BH(sk, field) UDP_INC_STATS_BH(sock_net(sk), field, 0)
+#define __UDPX_INC_STATS(sk, field) __UDP_INC_STATS(sock_net(sk), field, 0)
 #endif
 
 /* /proc */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6b004b838966..093284c5c03b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1242,10 +1242,10 @@ static unsigned int first_packet_length(struct sock *sk)
 	spin_lock_bh(&rcvq->lock);
 	while ((skb = skb_peek(rcvq)) != NULL &&
 		udp_lib_checksum_complete(skb)) {
-		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS,
-				 IS_UDPLITE(sk));
-		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
-				 IS_UDPLITE(sk));
+		__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
+				IS_UDPLITE(sk));
+		__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
+				IS_UDPLITE(sk));
 		atomic_inc(&sk->sk_drops);
 		__skb_unlink(skb, rcvq);
 		__skb_queue_tail(&list_kill, skb);
@@ -1514,9 +1514,9 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
-					 is_udplite);
-		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+			__UDP_INC_STATS(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+					is_udplite);
+		__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 		kfree_skb(skb);
 		trace_udp_fail_queue_rcv_skb(rc, sk);
 		return -1;
@@ -1580,9 +1580,9 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 			ret = encap_rcv(sk, skb);
 			if (ret <= 0) {
-				UDP_INC_STATS_BH(sock_net(sk),
-						 UDP_MIB_INDATAGRAMS,
-						 is_udplite);
+				__UDP_INC_STATS(sock_net(sk),
+						UDP_MIB_INDATAGRAMS,
+						is_udplite);
 				return -ret;
 			}
 		}
@@ -1633,8 +1633,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	udp_csum_pull_header(skb);
 	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
-		UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
-				 is_udplite);
+		__UDP_INC_STATS(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+				is_udplite);
 		goto drop;
 	}
 
@@ -1653,9 +1653,9 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	return rc;
 
 csum_error:
-	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
+	__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 drop:
-	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	atomic_inc(&sk->sk_drops);
 	kfree_skb(skb);
 	return -1;
@@ -1715,10 +1715,10 @@ start_lookup:
 
 		if (unlikely(!nskb)) {
 			atomic_inc(&sk->sk_drops);
-			UDP_INC_STATS_BH(net, UDP_MIB_RCVBUFERRORS,
-					 IS_UDPLITE(sk));
-			UDP_INC_STATS_BH(net, UDP_MIB_INERRORS,
-					 IS_UDPLITE(sk));
+			__UDP_INC_STATS(net, UDP_MIB_RCVBUFERRORS,
+					IS_UDPLITE(sk));
+			__UDP_INC_STATS(net, UDP_MIB_INERRORS,
+					IS_UDPLITE(sk));
 			continue;
 		}
 		if (udp_queue_rcv_skb(sk, nskb) > 0)
@@ -1736,8 +1736,8 @@ start_lookup:
 			consume_skb(skb);
 	} else {
 		kfree_skb(skb);
-		UDP_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
-				 proto == IPPROTO_UDPLITE);
+		__UDP_INC_STATS(net, UDP_MIB_IGNOREDMULTI,
+				proto == IPPROTO_UDPLITE);
 	}
 	return 0;
 }
@@ -1851,7 +1851,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (udp_lib_checksum_complete(skb))
 		goto csum_error;
 
-	UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
+	__UDP_INC_STATS(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 	/*
@@ -1878,9 +1878,9 @@ csum_error:
 			    proto == IPPROTO_UDPLITE ? "Lite" : "",
 			    &saddr, ntohs(uh->source), &daddr, ntohs(uh->dest),
 			    ulen);
-	UDP_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
+	__UDP_INC_STATS(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
 drop:
-	UDP_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
+	__UDP_INC_STATS(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
 	return 0;
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index baa56ca41a31..1243d22e2b1d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -570,9 +570,9 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP6_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_RCVBUFERRORS, is_udplite);
-		UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+			__UDP6_INC_STATS(sock_net(sk),
+					 UDP_MIB_RCVBUFERRORS, is_udplite);
+		__UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -628,9 +628,9 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 			ret = encap_rcv(sk, skb);
 			if (ret <= 0) {
-				UDP_INC_STATS_BH(sock_net(sk),
-						 UDP_MIB_INDATAGRAMS,
-						 is_udplite);
+				__UDP_INC_STATS(sock_net(sk),
+						UDP_MIB_INDATAGRAMS,
+						is_udplite);
 				return -ret;
 			}
 		}
@@ -664,8 +664,8 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	udp_csum_pull_header(skb);
 	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
-		UDP6_INC_STATS_BH(sock_net(sk),
-				  UDP_MIB_RCVBUFERRORS, is_udplite);
+		__UDP6_INC_STATS(sock_net(sk),
+				 UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
 	}
 
@@ -684,9 +684,9 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	return rc;
 
 csum_error:
-	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
+	__UDP6_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 drop:
-	UDP6_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	__UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	atomic_inc(&sk->sk_drops);
 	kfree_skb(skb);
 	return -1;
@@ -769,10 +769,10 @@ start_lookup:
 		nskb = skb_clone(skb, GFP_ATOMIC);
 		if (unlikely(!nskb)) {
 			atomic_inc(&sk->sk_drops);
-			UDP6_INC_STATS_BH(net, UDP_MIB_RCVBUFERRORS,
-					  IS_UDPLITE(sk));
-			UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS,
-					  IS_UDPLITE(sk));
+			__UDP6_INC_STATS(net, UDP_MIB_RCVBUFERRORS,
+					 IS_UDPLITE(sk));
+			__UDP6_INC_STATS(net, UDP_MIB_INERRORS,
+					 IS_UDPLITE(sk));
 			continue;
 		}
 
@@ -791,8 +791,8 @@ start_lookup:
 			consume_skb(skb);
 	} else {
 		kfree_skb(skb);
-		UDP6_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
-				  proto == IPPROTO_UDPLITE);
+		__UDP6_INC_STATS(net, UDP_MIB_IGNOREDMULTI,
+				 proto == IPPROTO_UDPLITE);
 	}
 	return 0;
 }
@@ -885,7 +885,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (udp_lib_checksum_complete(skb))
 		goto csum_error;
 
-	UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
+	__UDP6_INC_STATS(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
 	kfree_skb(skb);
@@ -899,9 +899,9 @@ short_packet:
 			    daddr, ntohs(uh->dest));
 	goto discard;
 csum_error:
-	UDP6_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
+	__UDP6_INC_STATS(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
 discard:
-	UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
+	__UDP6_INC_STATS(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
 	return 0;
 }
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 01e038146b7c..6ff97412a0bb 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -698,12 +698,12 @@ void rxrpc_data_ready(struct sock *sk)
 	if (skb_checksum_complete(skb)) {
 		rxrpc_free_skb(skb);
 		rxrpc_put_local(local);
-		UDP_INC_STATS_BH(&init_net, UDP_MIB_INERRORS, 0);
+		__UDP_INC_STATS(&init_net, UDP_MIB_INERRORS, 0);
 		_leave(" [CSUM failed]");
 		return;
 	}
 
-	UDP_INC_STATS_BH(&init_net, UDP_MIB_INDATAGRAMS, 0);
+	__UDP_INC_STATS(&init_net, UDP_MIB_INDATAGRAMS, 0);
 
 	/* The socket buffer we have is owned by UDP, with UDP's data all over
 	 * it, but we really want our own data there.
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d0756ac5c0f2..a6c68dc086af 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1018,11 +1018,11 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 
 	/* Suck it into the iovec, verify checksum if not done by hw. */
 	if (csum_partial_copy_to_xdr(&rovr->rq_private_buf, skb)) {
-		UDPX_INC_STATS_BH(sk, UDP_MIB_INERRORS);
+		__UDPX_INC_STATS(sk, UDP_MIB_INERRORS);
 		goto out_unlock;
 	}
 
-	UDPX_INC_STATS_BH(sk, UDP_MIB_INDATAGRAMS);
+	__UDPX_INC_STATS(sk, UDP_MIB_INDATAGRAMS);
 
 	xprt_adjust_cwnd(xprt, task, copied);
 	xprt_complete_rqst(task, copied);
-- 
2.8.0.rc3.226.g39d4020
