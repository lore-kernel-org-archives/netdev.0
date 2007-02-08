From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][1/6] extending xfrm4_tunnel utility
Date: Thu, 8 Feb 2007 17:03:36 +0900
Message-ID: <20070208170336.7b05750b.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:45063 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1161546AbXBHIL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 03:11:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch extends xfrm4_tunnel utility to support inter address family
tunnel, which is IPv6 over IPv4 tunnel (aka sit).

signed-off-by Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
 include/net/xfrm.h     |    4 ++--
 net/ipv4/tunnel4.c     |   42 ++++++++++++++++++++++++++++++++++++++----
 net/ipv4/xfrm4_input.c |    4 +++-
 3 files changed, 43 insertions(+), 7 deletions(-)

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
diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 8d30c48..1112707 100644
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
@@ -86,6 +89,24 @@ drop:
 	return 0;
 }
 
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
+
 static void tunnel4_err(struct sk_buff *skb, u32 info)
 {
 	struct xfrm_tunnel *handler;
@@ -101,17 +122,30 @@ static struct net_protocol tunnel4_proto
 	.no_policy	=	1,
 };
 
+static struct net_protocol tunnel64_protocol = {
+	.handler	=	tunnel64_rcv,
+	.err_handler	=	tunnel4_err,
+	.no_policy	=	1,
+};
+
 static int __init tunnel4_init(void)
 {
 	if (inet_add_protocol(&tunnel4_protocol, IPPROTO_IPIP)) {
 		printk(KERN_ERR "tunnel4 init: can't add protocol\n");
 		return -EAGAIN;
 	}
+	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
+		printk(KERN_ERR "tunnel64 init: can't add protocol\n");
+		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
+		return -EAGAIN;
+	}
 	return 0;
 }
 
 static void __exit tunnel4_fini(void)
 {
+	if (inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6))
+		printk(KERN_ERR "tunnel64 close: can't remove protocol\n");
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
 
-- 
1.4.1

