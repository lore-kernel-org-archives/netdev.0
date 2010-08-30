From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: tunnels should use rcu_dereference
Date: Mon, 30 Aug 2010 23:07:25 +0200
Message-ID: <1283202445.2405.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43137 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab0H3VHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 17:07:30 -0400
Received: by wwb28 with SMTP id 28so111513wwb.1
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 14:07:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tunnel4_handlers, tunnel64_handlers, tunnel6_handlers and
tunnel46_handlers are protected by RCU, but we dont use appropriate rcu
primitives to scan them. rcu_lock() is already held by caller.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tunnel4.c |   13 +++++++++----
 net/ipv6/tunnel6.c |   11 ++++++++---
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 59186ca..9edaa82 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -73,6 +73,11 @@ int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family)
 }
 EXPORT_SYMBOL(xfrm4_tunnel_deregister);
 
+#define for_each_tunnel_rcu(head, handler)		\
+	for (handler = rcu_dereference(head);		\
+	     handler != NULL;				\
+	     handler = rcu_dereference(handler->next))	\
+	
 static int tunnel4_rcv(struct sk_buff *skb)
 {
 	struct xfrm_tunnel *handler;
@@ -80,7 +85,7 @@ static int tunnel4_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto drop;
 
-	for (handler = tunnel4_handlers; handler; handler = handler->next)
+	for_each_tunnel_rcu(tunnel4_handlers, handler)
 		if (!handler->handler(skb))
 			return 0;
 
@@ -99,7 +104,7 @@ static int tunnel64_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto drop;
 
-	for (handler = tunnel64_handlers; handler; handler = handler->next)
+	for_each_tunnel_rcu(tunnel64_handlers, handler)
 		if (!handler->handler(skb))
 			return 0;
 
@@ -115,7 +120,7 @@ static void tunnel4_err(struct sk_buff *skb, u32 info)
 {
 	struct xfrm_tunnel *handler;
 
-	for (handler = tunnel4_handlers; handler; handler = handler->next)
+	for_each_tunnel_rcu(tunnel4_handlers, handler)
 		if (!handler->err_handler(skb, info))
 			break;
 }
@@ -125,7 +130,7 @@ static void tunnel64_err(struct sk_buff *skb, u32 info)
 {
 	struct xfrm_tunnel *handler;
 
-	for (handler = tunnel64_handlers; handler; handler = handler->next)
+	for_each_tunnel_rcu(tunnel64_handlers, handler)
 		if (!handler->err_handler(skb, info))
 			break;
 }
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index fc3c86a..c4edbff 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -88,6 +88,11 @@ int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
 
 EXPORT_SYMBOL(xfrm6_tunnel_deregister);
 
+#define for_each_tunnel_rcu(head, handler)		\
+	for (handler = rcu_dereference(head);		\
+	     handler != NULL;				\
+	     handler = rcu_dereference(handler->next))	\
+
 static int tunnel6_rcv(struct sk_buff *skb)
 {
 	struct xfrm6_tunnel *handler;
@@ -95,7 +100,7 @@ static int tunnel6_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto drop;
 
-	for (handler = tunnel6_handlers; handler; handler = handler->next)
+	for_each_tunnel_rcu(tunnel6_handlers, handler)
 		if (!handler->handler(skb))
 			return 0;
 
@@ -113,7 +118,7 @@ static int tunnel46_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto drop;
 
-	for (handler = tunnel46_handlers; handler; handler = handler->next)
+	for_each_tunnel_rcu(tunnel46_handlers, handler)
 		if (!handler->handler(skb))
 			return 0;
 
@@ -129,7 +134,7 @@ static void tunnel6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 {
 	struct xfrm6_tunnel *handler;
 
-	for (handler = tunnel6_handlers; handler; handler = handler->next)
+	for_each_tunnel_rcu(tunnel6_handlers, handler)
 		if (!handler->err_handler(skb, opt, type, code, offset, info))
 			break;
 }


