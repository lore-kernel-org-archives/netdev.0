From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/4] Consolidate equal handlers in tunnel4.c
Date: Fri, 09 Nov 2007 16:18:48 +0300
Message-ID: <47345E38.4010407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56023 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756447AbXKINTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 08:19:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two sets - tunnel[6]4_rcv() and tunnel[6]4_err - do the same
thing, but scan for different lists of tunnels, so this code
is easily consolidated.

Signed-off-by: Pavel Emelyanov <xemul@openvz.ogr>

---

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index b662a9e..c85547d 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -101,14 +101,14 @@ void iptunnel_xmit(struct sk_buff *skb, struct rtable *rt,
 
 EXPORT_SYMBOL(iptunnel_xmit);
 
-static int tunnel4_rcv(struct sk_buff *skb)
+static int tunnel_rcv(struct xfrm_tunnel *handlers, struct sk_buff *skb)
 {
 	struct xfrm_tunnel *handler;
 
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto drop;
 
-	for (handler = tunnel4_handlers; handler; handler = handler->next)
+	for (handler = handlers; handler; handler = handler->next)
 		if (!handler->handler(skb))
 			return 0;
 
@@ -119,43 +119,36 @@ drop:
 	return 0;
 }
 
+static int tunnel4_rcv(struct sk_buff *skb)
+{
+	return tunnel_rcv(tunnel4_handlers, skb);
+}
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static int tunnel64_rcv(struct sk_buff *skb)
 {
-	struct xfrm_tunnel *handler;
-
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		goto drop;
-
-	for (handler = tunnel64_handlers; handler; handler = handler->next)
-		if (!handler->handler(skb))
-			return 0;
-
-	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
-
-drop:
-	kfree_skb(skb);
-	return 0;
+	return tunnel_rcv(tunnel64_handlers, skb);
 }
 #endif
 
-static void tunnel4_err(struct sk_buff *skb, u32 info)
+static void tunnel_err(struct xfrm_tunnel *handlers, struct sk_buff *skb, u32 i)
 {
 	struct xfrm_tunnel *handler;
 
-	for (handler = tunnel4_handlers; handler; handler = handler->next)
-		if (!handler->err_handler(skb, info))
+	for (handler = handlers; handler; handler = handler->next)
+		if (!handler->err_handler(skb, i))
 			break;
 }
 
+static void tunnel4_err(struct sk_buff *skb, u32 info)
+{
+	tunnel_err(tunnel4_handlers, skb, info);
+}
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static void tunnel64_err(struct sk_buff *skb, u32 info)
 {
-	struct xfrm_tunnel *handler;
-
-	for (handler = tunnel64_handlers; handler; handler = handler->next)
-		if (!handler->err_handler(skb, info))
-			break;
+	tunnel_err(tunnel64_handlers, skb, info);
 }
 #endif
 
-- 
1.5.3.4

