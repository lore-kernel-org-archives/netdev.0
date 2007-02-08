From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][2/6] extending xfrm6_tunnel utility
Date: Thu, 8 Feb 2007 17:03:59 +0900
Message-ID: <20070208170359.5b2faa47.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:49194 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1161547AbXBHIL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 03:11:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch extends xfrm6_tunnel utility to support inter address family
tunnel, which is IPv4 over IPv6 tunnel.

signed-off-by Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
 include/net/xfrm.h     |    4 ++--
 net/ipv6/tunnel6.c     |   43 +++++++++++++++++++++++++++++++++++++++----
 net/ipv6/xfrm6_input.c |    3 ++-
 3 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 3ee0995..0ecc6a7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -938,8 +938,8 @@ extern int xfrm6_rcv_spi(struct sk_buff 
 extern int xfrm6_rcv(struct sk_buff **pskb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			    xfrm_address_t *saddr, u8 proto);
-extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler);
-extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler);
+extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
+extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family);
 extern __be32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
 extern void xfrm6_tunnel_free_spi(xfrm_address_t *saddr);
 extern __be32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr);
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 918d07d..23e2809 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -30,9 +30,10 @@ #include <net/protocol.h>
 #include <net/xfrm.h>
 
 static struct xfrm6_tunnel *tunnel6_handlers;
+static struct xfrm6_tunnel *tunnel46_handlers;
 static DEFINE_MUTEX(tunnel6_mutex);
 
-int xfrm6_tunnel_register(struct xfrm6_tunnel *handler)
+int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family)
 {
 	struct xfrm6_tunnel **pprev;
 	int ret = -EEXIST;
@@ -40,7 +41,8 @@ int xfrm6_tunnel_register(struct xfrm6_t
 
 	mutex_lock(&tunnel6_mutex);
 
-	for (pprev = &tunnel6_handlers; *pprev; pprev = &(*pprev)->next) {
+	for (pprev = (family == AF_INET6) ? &tunnel6_handlers : &tunnel46_handlers;
+	     *pprev; pprev = &(*pprev)->next) {
 		if ((*pprev)->priority > priority)
 			break;
 		if ((*pprev)->priority == priority)
@@ -60,14 +62,15 @@ err:
 
 EXPORT_SYMBOL(xfrm6_tunnel_register);
 
-int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler)
+int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
 {
 	struct xfrm6_tunnel **pprev;
 	int ret = -ENOENT;
 
 	mutex_lock(&tunnel6_mutex);
 
-	for (pprev = &tunnel6_handlers; *pprev; pprev = &(*pprev)->next) {
+	for (pprev = (family == AF_INET6) ? &tunnel6_handlers : &tunnel46_handlers;
+	     *pprev; pprev = &(*pprev)->next) {
 		if (*pprev == handler) {
 			*pprev = handler->next;
 			ret = 0;
@@ -103,6 +106,25 @@ drop:
 	return 0;
 }
 
+static int tunnel46_rcv(struct sk_buff **pskb)
+{
+	struct sk_buff *skb = *pskb;
+	struct xfrm6_tunnel *handler;
+
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+		goto drop;
+
+	for (handler = tunnel46_handlers; handler; handler = handler->next)
+		if (!handler->handler(skb))
+			return 0;
+
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, skb->dev);
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
 static void tunnel6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			int type, int code, int offset, __be32 info)
 {
@@ -119,17 +141,30 @@ static struct inet6_protocol tunnel6_pro
 	.flags          = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
+static struct inet6_protocol tunnel46_protocol = {
+	.handler	= tunnel46_rcv,
+	.err_handler	= tunnel6_err,
+	.flags          = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
+};
+
 static int __init tunnel6_init(void)
 {
 	if (inet6_add_protocol(&tunnel6_protocol, IPPROTO_IPV6)) {
 		printk(KERN_ERR "tunnel6 init(): can't add protocol\n");
 		return -EAGAIN;
 	}
+	if (inet6_add_protocol(&tunnel46_protocol, IPPROTO_IPIP)) {
+		printk(KERN_ERR "tunnel6 init(): can't add protocol\n");
+		inet6_del_protocol(&tunnel6_protocol, IPPROTO_IPV6);
+		return -EAGAIN;
+	}
 	return 0;
 }
 
 static void __exit tunnel6_fini(void)
 {
+	if (inet6_del_protocol(&tunnel46_protocol, IPPROTO_IPIP))
+		printk(KERN_ERR "tunnel6 close: can't remove protocol\n");
 	if (inet6_del_protocol(&tunnel6_protocol, IPPROTO_IPV6))
 		printk(KERN_ERR "tunnel6 close: can't remove protocol\n");
 }
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 5c8b7a5..b7e90e3 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -40,7 +40,8 @@ int xfrm6_rcv_spi(struct sk_buff *skb, _
 		if (xfrm_nr == XFRM_MAX_DEPTH)
 			goto drop;
 
-		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi, nexthdr, AF_INET6);
+		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
+				nexthdr != IPPROTO_IPIP ? nexthdr : IPPROTO_IPV6, AF_INET6);
 		if (x == NULL)
 			goto drop;
 		spin_lock(&x->lock);
-- 
1.4.1

