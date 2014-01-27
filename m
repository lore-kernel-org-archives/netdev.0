From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v3 08/12] xfrm4: Remove xfrm_tunnel_notifier
Date: Mon, 27 Jan 2014 11:29:33 +0100
Message-ID: <1390818577-19589-9-git-send-email-steffen.klassert@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43181 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835AbaA0KaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 05:30:12 -0500
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was used from vti and is replaced by the IPsec protocol
multiplexer hooks. It is now unused, so remove it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h           |    2 --
 net/ipv4/xfrm4_mode_tunnel.c |   68 ------------------------------------------
 2 files changed, 70 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c8f84171..8f28b9e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1526,8 +1526,6 @@ int xfrm4_protocol_deregister(struct xfrm4_protocol *handler, unsigned char prot
 int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
-int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler);
-int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler);
 int xfrm6_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler);
 int xfrm6_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler);
 int xfrm6_extract_header(struct sk_buff *skb);
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 31b1815..05f2b48 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -15,65 +15,6 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 
-/* Informational hook. The decap is still done here. */
-static struct xfrm_tunnel_notifier __rcu *rcv_notify_handlers __read_mostly;
-static DEFINE_MUTEX(xfrm4_mode_tunnel_input_mutex);
-
-int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler)
-{
-	struct xfrm_tunnel_notifier __rcu **pprev;
-	struct xfrm_tunnel_notifier *t;
-	int ret = -EEXIST;
-	int priority = handler->priority;
-
-	mutex_lock(&xfrm4_mode_tunnel_input_mutex);
-
-	for (pprev = &rcv_notify_handlers;
-	     (t = rcu_dereference_protected(*pprev,
-	     lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) != NULL;
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
-	mutex_unlock(&xfrm4_mode_tunnel_input_mutex);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(xfrm4_mode_tunnel_input_register);
-
-int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler)
-{
-	struct xfrm_tunnel_notifier __rcu **pprev;
-	struct xfrm_tunnel_notifier *t;
-	int ret = -ENOENT;
-
-	mutex_lock(&xfrm4_mode_tunnel_input_mutex);
-	for (pprev = &rcv_notify_handlers;
-	     (t = rcu_dereference_protected(*pprev,
-	     lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) != NULL;
-	     pprev = &t->next) {
-		if (t == handler) {
-			*pprev = handler->next;
-			ret = 0;
-			break;
-		}
-	}
-	mutex_unlock(&xfrm4_mode_tunnel_input_mutex);
-	synchronize_net();
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(xfrm4_mode_tunnel_input_deregister);
-
 static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
 {
 	struct iphdr *inner_iph = ipip_hdr(skb);
@@ -127,14 +68,8 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
-#define for_each_input_rcu(head, handler)	\
-	for (handler = rcu_dereference(head);	\
-	     handler != NULL;			\
-	     handler = rcu_dereference(handler->next))
-
 static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct xfrm_tunnel_notifier *handler;
 	int err = -EINVAL;
 
 	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPIP)
@@ -143,9 +78,6 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto out;
 
-	for_each_input_rcu(rcv_notify_handlers, handler)
-		handler->handler(skb);
-
 	err = skb_unclone(skb, GFP_ATOMIC);
 	if (err)
 		goto out;
-- 
1.7.9.5
