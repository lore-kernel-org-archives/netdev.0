From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][1/4] changing API of xfrm4_tunnel_register
Date: Fri, 9 Feb 2007 16:12:20 +0900
Message-ID: <20070209161220.456183ab.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:59922 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1946181AbXBIHhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 02:37:33 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes xfrm4_tunnel register and deregister
interface to prepare for solving the conflict of device
tunnels with inter address family IPsec tunnel.

signed-off-by Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
 include/net/xfrm.h      |    4 ++--
 net/ipv4/ipip.c         |    6 +++---
 net/ipv4/tunnel4.c      |   50 +++++++++++++++++++++++++++++++++++++++++++----
 net/ipv4/xfrm4_input.c  |    4 +++-
 net/ipv4/xfrm4_tunnel.c |   29 ++++++++++++++++++++++++---
 5 files changed, 79 insertions(+), 14 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bf91d63..3ee0995 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -932,8 +932,8 @@ extern int xfrm_state_mtu(struct xfrm_st
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm4_rcv(struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff *skb);
-extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
-extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
+extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
+extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi);
 extern int xfrm6_rcv(struct sk_buff **pskb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 9d719d6..775e950 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -870,7 +870,7 @@ static int __init ipip_init(void)
 
 	printk(banner);
 
-	if (xfrm4_tunnel_register(&ipip_handler)) {
+	if (xfrm4_tunnel_register(&ipip_handler, AF_INET)) {
 		printk(KERN_INFO "ipip init: can't register tunnel\n");
 		return -EAGAIN;
 	}
@@ -892,7 +892,7 @@ static int __init ipip_init(void)
  err2:
 	free_netdev(ipip_fb_tunnel_dev);
  err1:
-	xfrm4_tunnel_deregister(&ipip_handler);
+	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 	goto out;
 }
 
@@ -912,7 +912,7 @@ static void __exit ipip_destroy_tunnels(
 
 static void __exit ipip_fini(void)
 {
-	if (xfrm4_tunnel_deregister(&ipip_handler))
+	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		printk(KERN_INFO "ipip close: can't deregister tunnel\n");
 
 	rtnl_lock();
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 8d30c48..a794a8c 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -14,9 +14,10 @@ #include <net/protocol.h>
 #include <net/xfrm.h>
 
 static struct xfrm_tunnel *tunnel4_handlers;
+static struct xfrm_tunnel *tunnel64_handlers;
 static DEFINE_MUTEX(tunnel4_mutex);
 
-int xfrm4_tunnel_register(struct xfrm_tunnel *handler)
+int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family)
 {
 	struct xfrm_tunnel **pprev;
 	int ret = -EEXIST;
@@ -24,7 +25,8 @@ int xfrm4_tunnel_register(struct xfrm_tu
 
 	mutex_lock(&tunnel4_mutex);
 
-	for (pprev = &tunnel4_handlers; *pprev; pprev = &(*pprev)->next) {
+	for (pprev = (family == AF_INET) ? &tunnel4_handlers : &tunnel64_handlers;
+	     *pprev; pprev = &(*pprev)->next) {
 		if ((*pprev)->priority > priority)
 			break;
 		if ((*pprev)->priority == priority)
@@ -44,14 +46,15 @@ err:
 
 EXPORT_SYMBOL(xfrm4_tunnel_register);
 
-int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler)
+int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family)
 {
 	struct xfrm_tunnel **pprev;
 	int ret = -ENOENT;
 
 	mutex_lock(&tunnel4_mutex);
 
-	for (pprev = &tunnel4_handlers; *pprev; pprev = &(*pprev)->next) {
+	for (pprev = (family == AF_INET) ? &tunnel4_handlers : &tunnel64_handlers;
+	     *pprev; pprev = &(*pprev)->next) {
 		if (*pprev == handler) {
 			*pprev = handler->next;
 			ret = 0;
@@ -86,6 +89,26 @@ drop:
 	return 0;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int tunnel64_rcv(struct sk_buff *skb)
+{
+	struct xfrm_tunnel *handler;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto drop;
+
+	for (handler = tunnel64_handlers; handler; handler = handler->next)
+		if (!handler->handler(skb))
+			return 0;
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+#endif
+
 static void tunnel4_err(struct sk_buff *skb, u32 info)
 {
 	struct xfrm_tunnel *handler;
@@ -101,17 +124,36 @@ static struct net_protocol tunnel4_proto
 	.no_policy	=	1,
 };
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct net_protocol tunnel64_protocol = {
+	.handler	=	tunnel64_rcv,
+	.err_handler	=	tunnel4_err,
+	.no_policy	=	1,
+};
+#endif
+
 static int __init tunnel4_init(void)
 {
 	if (inet_add_protocol(&tunnel4_protocol, IPPROTO_IPIP)) {
 		printk(KERN_ERR "tunnel4 init: can't add protocol\n");
 		return -EAGAIN;
 	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
+		printk(KERN_ERR "tunnel64 init: can't add protocol\n");
+		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
+		return -EAGAIN;
+	}
+#endif
 	return 0;
 }
 
 static void __exit tunnel4_fini(void)
 {
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	if (inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6))
+		printk(KERN_ERR "tunnel64 close: can't remove protocol\n");
+#endif
 	if (inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP))
 		printk(KERN_ERR "tunnel4 close: can't remove protocol\n");
 }
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 8655d03..2c6a5fd 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -27,6 +27,7 @@ static int xfrm4_parse_spi(struct sk_buf
 {
 	switch (nexthdr) {
 	case IPPROTO_IPIP:
+	case IPPROTO_IPV6:
 		*spi = skb->nh.iph->saddr;
 		*seq = 0;
 		return 0;
@@ -70,7 +71,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 		if (xfrm_nr == XFRM_MAX_DEPTH)
 			goto drop;
 
-		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi, iph->protocol, AF_INET);
+		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
+				iph->protocol != IPPROTO_IPV6 ? iph->protocol : IPPROTO_IPIP, AF_INET);
 		if (x == NULL)
 			goto drop;
 
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index f110af5..e9dda96 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -64,24 +64,45 @@ static struct xfrm_tunnel xfrm_tunnel_ha
 	.priority	=	2,
 };
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct xfrm_tunnel xfrm64_tunnel_handler = {
+	.handler	=	xfrm4_rcv,
+	.err_handler	=	xfrm_tunnel_err,
+	.priority	=	2,
+};
+#endif
+
 static int __init ipip_init(void)
 {
 	if (xfrm_register_type(&ipip_type, AF_INET) < 0) {
 		printk(KERN_INFO "ipip init: can't add xfrm type\n");
 		return -EAGAIN;
 	}
-	if (xfrm4_tunnel_register(&xfrm_tunnel_handler)) {
-		printk(KERN_INFO "ipip init: can't add xfrm handler\n");
+
+	if (xfrm4_tunnel_register(&xfrm_tunnel_handler, AF_INET)) {
+		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET\n");
+		xfrm_unregister_type(&ipip_type, AF_INET);
+		return -EAGAIN;
+	}
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	if (xfrm4_tunnel_register(&xfrm64_tunnel_handler, AF_INET6)) {
+		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET6\n");
+		xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET);
 		xfrm_unregister_type(&ipip_type, AF_INET);
 		return -EAGAIN;
 	}
+#endif
 	return 0;
 }
 
 static void __exit ipip_fini(void)
 {
-	if (xfrm4_tunnel_deregister(&xfrm_tunnel_handler))
-		printk(KERN_INFO "ipip close: can't remove xfrm handler\n");
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	if (xfrm4_tunnel_deregister(&xfrm64_tunnel_handler, AF_INET6))
+		printk(KERN_INFO "ipip close: can't remove xfrm handler for AF_INET6\n");
+#endif
+	if (xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET))
+		printk(KERN_INFO "ipip close: can't remove xfrm handler for AF_INET\n");
 	if (xfrm_unregister_type(&ipip_type, AF_INET) < 0)
 		printk(KERN_INFO "ipip close: can't remove xfrm type\n");
 }
-- 
1.4.1

