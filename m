From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] UDP: Make use of inet_iif() when doing socket lookups.
Date: Tue, 23 Oct 2007 14:40:58 -0400
Message-ID: <471E403A.7040705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:38199 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbXJWSlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 14:41:10 -0400
Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id A19F834D93
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 14:40:59 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

UDP currently uses skb->dev->ifindex which may provide the wrong
information when the socket bound to a specific interface.
This patch makes inet_iif() accessible to UDP and makes UDP use it.

The scenario we are trying to fix is when a client is running on
the same system and the server and both client and server bind to
a non-loopback device.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/inet_hashtables.h |    6 ------
 include/net/inet_sock.h       |    7 +++++++
 net/ipv4/udp.c                |    2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 8228b57..4427dcd 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -26,7 +26,6 @@
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_sock.h>
-#include <net/route.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
 
@@ -266,11 +265,6 @@ out:
 		wake_up(&hashinfo->lhash_wait);
 }
 
-static inline int inet_iif(const struct sk_buff *skb)
-{
-	return ((struct rtable *)skb->dst)->rt_iif;
-}
-
 extern struct sock *__inet_lookup_listener(struct inet_hashinfo *hashinfo,
 					   const __be32 daddr,
 					   const unsigned short hnum,
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 62daf21..70013c5 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -24,6 +24,7 @@
 #include <net/flow.h>
 #include <net/sock.h>
 #include <net/request_sock.h>
+#include <net/route.h>
 
 /** struct ip_options - IP Options
  *
@@ -190,4 +191,10 @@ static inline int inet_sk_ehashfn(const struct sock *sk)
 	return inet_ehashfn(laddr, lport, faddr, fport);
 }
 
+
+static inline int inet_iif(const struct sk_buff *skb)
+{
+	return ((struct rtable *)skb->dst)->rt_iif;
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 35d2b0e..4bc25b4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1152,7 +1152,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
 	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
-			       skb->dev->ifindex, udptable        );
+			       inet_iif(skb), udptable);
 
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
-- 
1.5.2.4

