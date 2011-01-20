From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: raw: rcu annotations
Date: Thu, 20 Jan 2011 18:37:53 +0100
Message-ID: <1295545073.2825.436.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39996 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab1ATRiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 12:38:06 -0500
Received: by wwi17 with SMTP id 17so1746968wwi.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 09:38:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove sparse warnings, using a function typedef to be able to use __rcu
annotation on mh_filter pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/raw.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 86c3952..2bc6cd7 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -123,18 +123,18 @@ static __inline__ int icmpv6_filter(struct sock *sk, struct sk_buff *skb)
 }
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-static int (*mh_filter)(struct sock *sock, struct sk_buff *skb);
+typedef int mh_filter_t(struct sock *sock, struct sk_buff *skb);
 
-int rawv6_mh_filter_register(int (*filter)(struct sock *sock,
-					   struct sk_buff *skb))
+static mh_filter_t __rcu *mh_filter __read_mostly;
+
+int rawv6_mh_filter_register(mh_filter_t filter)
 {
 	rcu_assign_pointer(mh_filter, filter);
 	return 0;
 }
 EXPORT_SYMBOL(rawv6_mh_filter_register);
 
-int rawv6_mh_filter_unregister(int (*filter)(struct sock *sock,
-					     struct sk_buff *skb))
+int rawv6_mh_filter_unregister(mh_filter_t filter)
 {
 	rcu_assign_pointer(mh_filter, NULL);
 	synchronize_rcu();
@@ -192,10 +192,10 @@ static int ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 			 * policy is placed in rawv6_rcv() because it is
 			 * required for each socket.
 			 */
-			int (*filter)(struct sock *sock, struct sk_buff *skb);
+			mh_filter_t *filter;
 
 			filter = rcu_dereference(mh_filter);
-			filtered = filter ? filter(sk, skb) : 0;
+			filtered = filter ? (*filter)(sk, skb) : 0;
 			break;
 		}
 #endif


