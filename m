From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 1/2] ipv6: Add a receive path hook for vti6 in
 xfrm6_mode_tunnel.
Date: Mon, 19 Aug 2013 08:26:56 +0200
Message-ID: <20130819062656.GO26773@secunet.com>
References: <20130819062623.GN26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34881 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938Ab3HSG07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:26:59 -0400
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id 92DDB1A007E
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:26:57 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id Wvum1JHIOQbM for <netdev@vger.kernel.org>;
	Mon, 19 Aug 2013 08:26:56 +0200 (CEST)
Received: from mail-srv1.secumail.de (unknown [10.53.40.200])
	by a.mx.secunet.com (Postfix) with ESMTP id 5FB071A007A
	for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:26:56 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20130819062623.GN26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a receive path hook for the IPsec vritual tunnel interface.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h           |    2 ++
 net/ipv6/xfrm6_mode_tunnel.c |   69 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 94ce082..1e7700f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1497,6 +1497,8 @@ extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short fam
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler);
 extern int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler);
+extern int xfrm6_mode_tunnel_input_register(struct xfrm6_tunnel *handler);
+extern int xfrm6_mode_tunnel_input_deregister(struct xfrm6_tunnel *handler);
 extern int xfrm6_extract_header(struct sk_buff *skb);
 extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 4770d51..77e2f23 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -18,6 +18,65 @@
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
+/* Informational hook. The decap is still done here. */
+static struct xfrm6_tunnel __rcu *rcv_notify_handlers __read_mostly;
+static DEFINE_MUTEX(xfrm6_mode_tunnel_input_mutex);
+
+int xfrm6_mode_tunnel_input_register(struct xfrm6_tunnel *handler)
+{
+	struct xfrm6_tunnel __rcu **pprev;
+	struct xfrm6_tunnel *t;
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
+int xfrm6_mode_tunnel_input_deregister(struct xfrm6_tunnel *handler)
+{
+	struct xfrm6_tunnel __rcu **pprev;
+	struct xfrm6_tunnel *t;
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
+	struct xfrm6_tunnel *handler;
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
