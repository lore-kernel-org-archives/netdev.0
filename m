From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] ipv6: Add a receive path hook for vti6 in xfrm6_mode_tunnel.
Date: Fri, 18 Oct 2013 10:42:09 +0200
Message-ID: <1382085730-3415-4-git-send-email-steffen.klassert@secunet.com>
References: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51712 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198Ab3JRImW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 04:42:22 -0400
In-Reply-To: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a receive path hook for the IPsec vritual tunnel interface.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h           |    2 ++
 net/ipv6/xfrm6_mode_tunnel.c |   69 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b8a9ed8..6b82fdf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1508,6 +1508,8 @@ int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
 int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler);
 int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler);
+int xfrm6_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler);
+int xfrm6_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler);
 int xfrm6_extract_header(struct sk_buff *skb);
 int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 4770d51..cb04f7a 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -18,6 +18,65 @@
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
+/* Informational hook. The decap is still done here. */
+static struct xfrm_tunnel_notifier __rcu *rcv_notify_handlers __read_mostly;
+static DEFINE_MUTEX(xfrm6_mode_tunnel_input_mutex);
+
+int xfrm6_mode_tunnel_input_register(struct xfrm_tunnel_notifier *handler)
+{
+	struct xfrm_tunnel_notifier __rcu **pprev;
+	struct xfrm_tunnel_notifier *t;
+	int ret = -EEXIST;
+	int priority = handler->priority;
+
+	mutex_lock(&xfrm6_mode_tunnel_input_mutex);
+
+	for (pprev = &rcv_notify_handlers;
+	     (t = rcu_dereference_protected(*pprev,
+	     lockdep_is_held(&xfrm6_mode_tunnel_input_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t->priority > priority)
+			break;
+		if (t->priority == priority)
+			goto err;
+
+	}
+
+	handler->next = *pprev;
+	rcu_assign_pointer(*pprev, handler);
+
+	ret = 0;
+
+err:
+	mutex_unlock(&xfrm6_mode_tunnel_input_mutex);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xfrm6_mode_tunnel_input_register);
+
+int xfrm6_mode_tunnel_input_deregister(struct xfrm_tunnel_notifier *handler)
+{
+	struct xfrm_tunnel_notifier __rcu **pprev;
+	struct xfrm_tunnel_notifier *t;
+	int ret = -ENOENT;
+
+	mutex_lock(&xfrm6_mode_tunnel_input_mutex);
+	for (pprev = &rcv_notify_handlers;
+	     (t = rcu_dereference_protected(*pprev,
+	     lockdep_is_held(&xfrm6_mode_tunnel_input_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t == handler) {
+			*pprev = handler->next;
+			ret = 0;
+			break;
+		}
+	}
+	mutex_unlock(&xfrm6_mode_tunnel_input_mutex);
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xfrm6_mode_tunnel_input_deregister);
+
 static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
 {
 	const struct ipv6hdr *outer_iph = ipv6_hdr(skb);
@@ -63,8 +122,15 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
+#define for_each_input_rcu(head, handler)	\
+	for (handler = rcu_dereference(head);	\
+	     handler != NULL;			\
+	     handler = rcu_dereference(handler->next))
+
+
 static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	struct xfrm_tunnel_notifier *handler;
 	int err = -EINVAL;
 
 	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPV6)
@@ -72,6 +138,9 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
 
+	for_each_input_rcu(rcv_notify_handlers, handler)
+		handler->handler(skb);
+
 	err = skb_unclone(skb, GFP_ATOMIC);
 	if (err)
 		goto out;
-- 
1.7.9.5
