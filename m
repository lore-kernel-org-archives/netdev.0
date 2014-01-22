From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next v2] tcp: metrics: Handle v6/v4-mapped sockets in tcp-metrics
Date: Wed, 22 Jan 2014 13:58:44 +0100
Message-ID: <1390395524-27930-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:43505 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755153AbaAVM6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 07:58:48 -0500
Received: by mail-wi0-f171.google.com with SMTP id cc10so5581913wib.10
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 04:58:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A socket may be v6/v4-mapped. In that case sk->sk_family is AF_INET6,
but the IP being used is actually an IPv4-address.
Current's tcp-metrics will thus represent it as an IPv6-address:

root@server:~# ip tcp_metrics
::ffff:10.1.1.2 age 22.920sec rtt 18750us rttvar 15000us cwnd 10
10.1.1.2 age 47.970sec rtt 16250us rttvar 10000us cwnd 10

This patch modifies the tcp-metrics so that they are able to handle the
v6/v4-mapped sockets correctly.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
v2: Respin to net-next.

 net/ipv4/tcp_metrics.c | 64 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 40 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index fa950941de65..9923cebf5709 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -274,24 +274,32 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 	unsigned int hash;
 	struct net *net;
 
-	saddr.family = tw->tw_family;
-	daddr.family = tw->tw_family;
-	switch (daddr.family) {
-	case AF_INET:
+	if (tw->tw_family == AF_INET) {
+		saddr.family = AF_INET;
 		saddr.addr.a4 = tw->tw_rcv_saddr;
+		daddr.family = AF_INET;
 		daddr.addr.a4 = tw->tw_daddr;
 		hash = (__force unsigned int) daddr.addr.a4;
-		break;
+	}
 #if IS_ENABLED(CONFIG_IPV6)
-	case AF_INET6:
-		*(struct in6_addr *)saddr.addr.a6 = tw->tw_v6_rcv_saddr;
-		*(struct in6_addr *)daddr.addr.a6 = tw->tw_v6_daddr;
-		hash = ipv6_addr_hash(&tw->tw_v6_daddr);
-		break;
+	else if (tw->tw_family == AF_INET6) {
+		if (ipv6_addr_v4mapped(&tw->tw_v6_daddr)) {
+			saddr.family = AF_INET;
+			saddr.addr.a4 = tw->tw_rcv_saddr;
+			daddr.family = AF_INET;
+			daddr.addr.a4 = tw->tw_daddr;
+			hash = (__force unsigned int) daddr.addr.a4;
+		} else {
+			saddr.family = AF_INET6;
+			*(struct in6_addr *)saddr.addr.a6 = tw->tw_v6_rcv_saddr;
+			daddr.family = AF_INET6;
+			*(struct in6_addr *)daddr.addr.a6 = tw->tw_v6_daddr;
+			hash = ipv6_addr_hash(&tw->tw_v6_daddr);
+		}
+	}
 #endif
-	default:
+	else
 		return NULL;
-	}
 
 	net = twsk_net(tw);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
@@ -314,24 +322,32 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	unsigned int hash;
 	struct net *net;
 
-	saddr.family = sk->sk_family;
-	daddr.family = sk->sk_family;
-	switch (daddr.family) {
-	case AF_INET:
+	if (sk->sk_family == AF_INET) {
+		saddr.family = AF_INET;
 		saddr.addr.a4 = inet_sk(sk)->inet_saddr;
+		daddr.family = AF_INET;
 		daddr.addr.a4 = inet_sk(sk)->inet_daddr;
 		hash = (__force unsigned int) daddr.addr.a4;
-		break;
+	}
 #if IS_ENABLED(CONFIG_IPV6)
-	case AF_INET6:
-		*(struct in6_addr *)saddr.addr.a6 = sk->sk_v6_rcv_saddr;
-		*(struct in6_addr *)daddr.addr.a6 = sk->sk_v6_daddr;
-		hash = ipv6_addr_hash(&sk->sk_v6_daddr);
-		break;
+	else if (sk->sk_family = AF_INET6) {
+		if (ipv6_addr_v4mapped(&sk->sk_v6_daddr)) {
+			saddr.family = AF_INET;
+			saddr.addr.a4 = inet_sk(sk)->inet_saddr;
+			daddr.family = AF_INET;
+			daddr.addr.a4 = inet_sk(sk)->inet_daddr;
+			hash = (__force unsigned int) daddr.addr.a4;
+		} else {
+			saddr.family = AF_INET6;
+			*(struct in6_addr *)saddr.addr.a6 = sk->sk_v6_rcv_saddr;
+			daddr.family = AF_INET6;
+			*(struct in6_addr *)daddr.addr.a6 = sk->sk_v6_daddr;
+			hash = ipv6_addr_hash(&sk->sk_v6_daddr);
+		}
+	}
 #endif
-	default:
+	else
 		return NULL;
-	}
 
 	net = dev_net(dst->dev);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
-- 
1.8.3.2
