From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/6] xfrm4: Properly handle unsupported protocols
Date: Thu, 15 May 2014 09:07:53 +0200
Message-ID: <1400137676-27565-4-git-send-email-steffen.klassert@secunet.com>
References: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44788 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064AbaEOHIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:08:14 -0400
In-Reply-To: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't catch the case if an unsupported protocol is submitted
to the xfrm4 protocol handlers, this can lead to NULL pointer
dereferences. Fix this by adding the appropriate checks.

Fixes: 3328715e ("xfrm4: Add IPsec protocol multiplexer")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_protocol.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index 7f7b243..a2ce010 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -50,8 +50,12 @@ int xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err)
 {
 	int ret;
 	struct xfrm4_protocol *handler;
+	struct xfrm4_protocol __rcu **head = proto_handlers(protocol);
 
-	for_each_protocol_rcu(*proto_handlers(protocol), handler)
+	if (!head)
+		return 0;
+
+	for_each_protocol_rcu(*head, handler)
 		if ((ret = handler->cb_handler(skb, err)) <= 0)
 			return ret;
 
@@ -64,15 +68,20 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 {
 	int ret;
 	struct xfrm4_protocol *handler;
+	struct xfrm4_protocol __rcu **head = proto_handlers(nexthdr);
 
 	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
 
-	for_each_protocol_rcu(*proto_handlers(nexthdr), handler)
+	if (!head)
+		goto out;
+
+	for_each_protocol_rcu(*head, handler)
 		if ((ret = handler->input_handler(skb, nexthdr, spi, encap_type)) != -EINVAL)
 			return ret;
 
+out:
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 	kfree_skb(skb);
@@ -208,6 +217,9 @@ int xfrm4_protocol_register(struct xfrm4_protocol *handler,
 	int ret = -EEXIST;
 	int priority = handler->priority;
 
+	if (!proto_handlers(protocol) || !netproto(protocol))
+		return -EINVAL;
+
 	mutex_lock(&xfrm4_protocol_mutex);
 
 	if (!rcu_dereference_protected(*proto_handlers(protocol),
@@ -250,6 +262,9 @@ int xfrm4_protocol_deregister(struct xfrm4_protocol *handler,
 	struct xfrm4_protocol *t;
 	int ret = -ENOENT;
 
+	if (!proto_handlers(protocol) || !netproto(protocol))
+		return -EINVAL;
+
 	mutex_lock(&xfrm4_protocol_mutex);
 
 	for (pprev = proto_handlers(protocol);
-- 
1.7.9.5
