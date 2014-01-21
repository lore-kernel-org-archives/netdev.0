From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net] tcp: metrics: Handle v6/v4-mapped sockets in tcp-metrics
Date: Tue, 21 Jan 2014 08:17:12 +0100
Message-ID: <1390288632-28729-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:49850 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaAUHRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:17:21 -0500
Received: by mail-ea0-f178.google.com with SMTP id a15so2369758eae.23
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 23:17:20 -0800 (PST)
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

Fixes: 51c5d0c4b169b (tcp: Maintain dynamic metrics in local cache.)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_metrics.c | 50 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 098b3a29f6f3..3144524fe20f 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -264,21 +264,26 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 	unsigned int hash;
 	struct net *net;
 
-	addr.family = tw->tw_family;
-	switch (addr.family) {
-	case AF_INET:
+	if (tw->tw_family == AF_INET) {
+		addr.family = AF_INET;
 		addr.addr.a4 = tw->tw_daddr;
 		hash = (__force unsigned int) addr.addr.a4;
-		break;
+	}
 #if IS_ENABLED(CONFIG_IPV6)
-	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = tw->tw_v6_daddr;
-		hash = ipv6_addr_hash(&tw->tw_v6_daddr);
-		break;
+	else if (tw->tw_family == AF_INET6) {
+		if (ipv6_addr_v4mapped(&tw->tw_v6_daddr)) {
+			addr.family = AF_INET;
+			addr.addr.a4 = tw->tw_daddr;
+			hash = (__force unsigned int) addr.addr.a4;
+		} else {
+			addr.family = AF_INET6;
+			*(struct in6_addr *)addr.addr.a6 = tw->tw_v6_daddr;
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
@@ -300,21 +305,26 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	unsigned int hash;
 	struct net *net;
 
-	addr.family = sk->sk_family;
-	switch (addr.family) {
-	case AF_INET:
+	if (sk->sk_family == AF_INET) {
+		addr.family = AF_INET;
 		addr.addr.a4 = inet_sk(sk)->inet_daddr;
 		hash = (__force unsigned int) addr.addr.a4;
-		break;
+	}
 #if IS_ENABLED(CONFIG_IPV6)
-	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = sk->sk_v6_daddr;
-		hash = ipv6_addr_hash(&sk->sk_v6_daddr);
-		break;
+	else if (sk->sk_family == AF_INET6) {
+		if (ipv6_addr_v4mapped(&sk->sk_v6_daddr)) {
+			addr.family = AF_INET;
+			addr.addr.a4 = inet_sk(sk)->inet_daddr;
+			hash = (__force unsigned int) addr.addr.a4;
+		} else {
+			addr.family = AF_INET6;
+			*(struct in6_addr *)addr.addr.a6 = sk->sk_v6_daddr;
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
