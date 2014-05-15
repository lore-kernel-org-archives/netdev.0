From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/6] xfrm6: Properly handle unsupported protocols
Date: Thu, 15 May 2014 09:07:54 +0200
Message-ID: <1400137676-27565-5-git-send-email-steffen.klassert@secunet.com>
References: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44773 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792AbaEOHIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:08:09 -0400
In-Reply-To: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't catch the case if an unsupported protocol is submitted
to the xfrm6 protocol handlers, this can lead to NULL pointer
dereferences. Fix this by adding the appropriate checks.

Fixes: 7e14ea15 ("xfrm6: Add IPsec protocol multiplexer")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_protocol.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_protocol.c b/net/ipv6/xfrm6_protocol.c
index 6ab989c..54d13f8 100644
--- a/net/ipv6/xfrm6_protocol.c
+++ b/net/ipv6/xfrm6_protocol.c
@@ -50,6 +50,10 @@ int xfrm6_rcv_cb(struct sk_buff *skb, u8 protocol, int err)
 {
 	int ret;
 	struct xfrm6_protocol *handler;
+	struct xfrm6_protocol __rcu **head = proto_handlers(protocol);
+
+	if (!head)
+		return 0;
 
 	for_each_protocol_rcu(*proto_handlers(protocol), handler)
 		if ((ret = handler->cb_handler(skb, err)) <= 0)
@@ -184,10 +188,12 @@ int xfrm6_protocol_register(struct xfrm6_protocol *handler,
 	struct xfrm6_protocol __rcu **pprev;
 	struct xfrm6_protocol *t;
 	bool add_netproto = false;
-
 	int ret = -EEXIST;
 	int priority = handler->priority;
 
+	if (!proto_handlers(protocol) || !netproto(protocol))
+		return -EINVAL;
+
 	mutex_lock(&xfrm6_protocol_mutex);
 
 	if (!rcu_dereference_protected(*proto_handlers(protocol),
@@ -230,6 +236,9 @@ int xfrm6_protocol_deregister(struct xfrm6_protocol *handler,
 	struct xfrm6_protocol *t;
 	int ret = -ENOENT;
 
+	if (!proto_handlers(protocol) || !netproto(protocol))
+		return -EINVAL;
+
 	mutex_lock(&xfrm6_protocol_mutex);
 
 	for (pprev = proto_handlers(protocol);
-- 
1.7.9.5
