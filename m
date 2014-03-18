From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 10/13] xfrm6: Remove xfrm_tunnel_notifier
Date: Tue, 18 Mar 2014 08:21:35 +0100
Message-ID: <1395127298-24083-11-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53283 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533AbaCRHV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:57 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was used from vti and is replaced by the IPsec protocol
multiplexer hooks. It is now unused, so remove it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h           |    8 ------
 net/ipv6/xfrm6_mode_tunnel.c |   63 ------------------------------------------
 2 files changed, 71 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6304ec3..7c13ef6 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1393,12 +1393,6 @@ struct xfrm_tunnel {
 	int priority;
 };
 
-struct xfrm_tunnel_notifier {
-	int (*handler)(struct sk_buff *skb);
-	struct xfrm_tunnel_notifier __rcu *next;
-	int priority;
-};
-
 struct xfrm6_tunnel {
 	int (*handler)(struct sk_buff *skb);
 	int (*err_handler)(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -1554,8 +1548,6 @@ int xfrm4_protocol_deregister(struct xfrm4_protocol *handler, unsigned char prot
 int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
-int xfrm6_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler);
-int xfrm6_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler);
 int xfrm6_extract_header(struct sk_buff *skb);
 int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index cb04f7a..901ef6f 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -18,65 +18,6 @@
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
-/* Informational hook. The decap is still done here. */
-static struct xfrm_tunnel_notifier __rcu *rcv_notify_handlers __read_mostly;
-static DEFINE_MUTEX(xfrm6_mode_tunnel_input_mutex);
-
-int xfrm6_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler)
-{
-	struct xfrm_tunnel_notifier __rcu **pprev;
-	struct xfrm_tunnel_notifier *t;
-	int ret = -EEXIST;
-	int priority = handler->priority;
-
-	mutex_lock(&xfrm6_mode_tunnel_input_mutex);
-
-	for (pprev = &rcv_notify_handlers;
-	     (t = rcu_dereference_protected(*pprev,
-	     lockdep_is_held(&xfrm6_mode_tunnel_input_mutex))) != NULL;
-	     pprev = &t->next) {
-		if (t->priority > priority)
-			break;
-		if (t->priority == priority)
-			goto err;
-
-	}
-
-	handler->next = *pprev;
-	rcu_assign_pointer(*pprev, handler);
-
-	ret = 0;
-
-err:
-	mutex_unlock(&xfrm6_mode_tunnel_input_mutex);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(xfrm6_mode_tunnel_input_register);
-
-int xfrm6_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler)
-{
-	struct xfrm_tunnel_notifier __rcu **pprev;
-	struct xfrm_tunnel_notifier *t;
-	int ret = -ENOENT;
-
-	mutex_lock(&xfrm6_mode_tunnel_input_mutex);
-	for (pprev = &rcv_notify_handlers;
-	     (t = rcu_dereference_protected(*pprev,
-	     lockdep_is_held(&xfrm6_mode_tunnel_input_mutex))) != NULL;
-	     pprev = &t->next) {
-		if (t == handler) {
-			*pprev = handler->next;
-			ret = 0;
-			break;
-		}
-	}
-	mutex_unlock(&xfrm6_mode_tunnel_input_mutex);
-	synchronize_net();
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(xfrm6_mode_tunnel_input_deregister);
-
 static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
 {
 	const struct ipv6hdr *outer_iph = ipv6_hdr(skb);
@@ -130,7 +71,6 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct xfrm_tunnel_notifier *handler;
 	int err = -EINVAL;
 
 	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPV6)
@@ -138,9 +78,6 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
 
-	for_each_input_rcu(rcv_notify_handlers, handler)
-		handler->handler(skb);
-
 	err = skb_unclone(skb, GFP_ATOMIC);
 	if (err)
 		goto out;
-- 
1.7.9.5
