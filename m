From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/4] Add missed tunnel64_err handler
Date: Fri, 09 Nov 2007 16:14:12 +0300
Message-ID: <47345D24.7010603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45253 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298AbXKINOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 08:14:33 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tunnel64_protocol uses the tunnel4_protocol's err_handler and
thus calls the tunnel4_protocol's handlers.

This is not very good, as in case of (icmp) error the wrong error
handlers will be called (e.g. ipip ones instead of sit) and this
won't be noticed at all, because the error is not reported.

Was that made deliberately and I miss something?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index c71617c..7938430 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -145,6 +145,17 @@ static void tunnel4_err(struct sk_buff *skb, u32 info)
 			break;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void tunnel64_err(struct sk_buff *skb, u32 info)
+{
+	struct xfrm_tunnel *handler;
+
+	for (handler = tunnel64_handlers; handler; handler = handler->next)
+		if (!handler->err_handler(skb, info))
+			break;
+}
+#endif
+
 static struct net_protocol tunnel4_protocol = {
 	.handler	=	tunnel4_rcv,
 	.err_handler	=	tunnel4_err,
@@ -154,7 +165,7 @@ static struct net_protocol tunnel4_protocol = {
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static struct net_protocol tunnel64_protocol = {
 	.handler	=	tunnel64_rcv,
-	.err_handler	=	tunnel4_err,
+	.err_handler	=	tunnel64_err,
 	.no_policy	=	1,
 };
 #endif
-- 
1.5.3.4

