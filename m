From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v3 01/12] xfrm4: Add IPsec protocol multiplexer
Date: Mon, 27 Jan 2014 11:29:26 +0100
Message-ID: <1390818577-19589-2-git-send-email-steffen.klassert@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43148 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753484AbaA0KaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 05:30:07 -0500
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add an IPsec protocol multiplexer. With this
it is possible to add alternative protocol handlers as
needed for IPsec virtual tunnel interfaces.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h        |   24 +++++
 net/ipv4/Makefile         |    2 +-
 net/ipv4/xfrm4_protocol.c |  242 +++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_input.c     |   18 ++--
 4 files changed, 279 insertions(+), 7 deletions(-)
 create mode 100644 net/ipv4/xfrm4_protocol.c

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index afa5730..34aef6f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1347,6 +1347,17 @@ struct xfrm_algo_desc {
 	struct sadb_alg desc;
 };
 
+
+/* XFRM protocol handlers.  */
+struct xfrm4_protocol {
+	int (*handler)(struct sk_buff *skb);
+	int (*cb_handler)(struct sk_buff *skb, int err);
+	int (*err_handler)(struct sk_buff *skb, u32 info);
+
+	struct xfrm4_protocol __rcu *next;
+	int priority;
+};
+
 /* XFRM tunnel handlers.  */
 struct xfrm_tunnel {
 	int (*handler)(struct sk_buff *skb);
@@ -1504,6 +1515,9 @@ int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm4_output(struct sk_buff *skb);
 int xfrm4_output_finish(struct sk_buff *skb);
+void xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err);
+int xfrm4_protocol_register(struct xfrm4_protocol *handler, unsigned char protocol);
+int xfrm4_protocol_deregister(struct xfrm4_protocol *handler, unsigned char protocol);
 int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
@@ -1737,4 +1751,14 @@ static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 	return ret;
 }
 
+static inline void xfrm_rcv_cb(struct sk_buff *skb, unsigned int family,
+			       u8 protocol, int err)
+{
+	switch(family) {
+	case AF_INET:
+		xfrm4_rcv_cb(skb, protocol, err);
+		break;
+	}
+}
+
 #endif	/* _NET_XFRM_H */
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f8c49ce..f032688 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -55,4 +55,4 @@ obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
-		      xfrm4_output.o
+		      xfrm4_output.o xfrm4_protocol.o
diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
new file mode 100644
index 0000000..993ab39
--- /dev/null
+++ b/net/ipv4/xfrm4_protocol.c
@@ -0,0 +1,242 @@
+/* xfrm4_protocol.c - Generic xfrm protocol multiplexer.
+ *
+ * Copyright (C) 2013 secunet Security Networks AG
+ *
+ * Author:
+ * Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * Based on:
+ * net/ipv4/tunnel4.c
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/init.h>
+#include <linux/mutex.h>
+#include <linux/skbuff.h>
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/protocol.h>
+#include <net/xfrm.h>
+
+static struct xfrm4_protocol __rcu *esp4_handlers __read_mostly;
+static struct xfrm4_protocol __rcu *ah4_handlers __read_mostly;
+static struct xfrm4_protocol __rcu *ipcomp4_handlers __read_mostly;
+static DEFINE_MUTEX(xfrm4_protocol_mutex);
+
+static inline struct xfrm4_protocol __rcu **proto_handlers(u8 protocol)
+{
+	switch (protocol) {
+	case IPPROTO_ESP:
+		return &esp4_handlers;
+	case IPPROTO_AH:
+		return &ah4_handlers;
+	case IPPROTO_COMP:
+		return &ipcomp4_handlers;
+	}
+
+	return NULL;
+}
+
+#define for_each_protocol_rcu(head, handler)		\
+	for (handler = rcu_dereference(head);		\
+	     handler != NULL;				\
+	     handler = rcu_dereference(handler->next))	\
+
+void xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err)
+{
+	struct xfrm4_protocol *handler;
+
+	for_each_protocol_rcu(*proto_handlers(protocol), handler)
+		if (!handler->cb_handler(skb, err))
+			return;
+}
+EXPORT_SYMBOL(xfrm4_rcv_cb);
+
+static int xfrm4_esp_rcv(struct sk_buff *skb)
+{
+	struct xfrm4_protocol *handler;
+
+	for_each_protocol_rcu(esp4_handlers, handler)
+		if (!handler->handler(skb))
+			return 0;
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+
+	kfree_skb(skb);
+	return 0;
+}
+
+static void xfrm4_esp_err(struct sk_buff *skb, u32 info)
+{
+	struct xfrm4_protocol *handler;
+
+	for_each_protocol_rcu(esp4_handlers, handler)
+		if (!handler->err_handler(skb, info))
+			break;
+}
+
+static int xfrm4_ah_rcv(struct sk_buff *skb)
+{
+	struct xfrm4_protocol *handler;
+
+	for_each_protocol_rcu(ah4_handlers, handler)
+		if (!handler->handler(skb))
+			return 0;
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+
+	kfree_skb(skb);
+	return 0;
+}
+
+static void xfrm4_ah_err(struct sk_buff *skb, u32 info)
+{
+	struct xfrm4_protocol *handler;
+
+	for_each_protocol_rcu(ah4_handlers, handler)
+		if (!handler->err_handler(skb, info))
+			break;
+}
+
+static int xfrm4_ipcomp_rcv(struct sk_buff *skb)
+{
+	struct xfrm4_protocol *handler;
+
+	for_each_protocol_rcu(ipcomp4_handlers, handler)
+		if (!handler->handler(skb))
+			return 0;
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+
+	kfree_skb(skb);
+	return 0;
+}
+
+static void xfrm4_ipcomp_err(struct sk_buff *skb, u32 info)
+{
+	struct xfrm4_protocol *handler;
+
+	for_each_protocol_rcu(ipcomp4_handlers, handler)
+		if (!handler->err_handler(skb, info))
+			break;
+}
+
+static const struct net_protocol esp4_protocol = {
+	.handler	=	xfrm4_esp_rcv,
+	.err_handler	=	xfrm4_esp_err,
+	.no_policy	=	1,
+	.netns_ok	=	1,
+};
+
+static const struct net_protocol ah4_protocol = {
+	.handler	=	xfrm4_ah_rcv,
+	.err_handler	=	xfrm4_ah_err,
+	.no_policy	=	1,
+	.netns_ok	=	1,
+};
+
+static const struct net_protocol ipcomp4_protocol = {
+	.handler	=	xfrm4_ipcomp_rcv,
+	.err_handler	=	xfrm4_ipcomp_err,
+	.no_policy	=	1,
+	.netns_ok	=	1,
+};
+
+static inline const struct net_protocol *netproto(unsigned char protocol)
+{
+	switch (protocol) {
+	case IPPROTO_ESP:
+		return &esp4_protocol;
+	case IPPROTO_AH:
+		return &ah4_protocol;
+	case IPPROTO_COMP:
+		return &ipcomp4_protocol;
+	}
+
+	return NULL;
+}
+
+int xfrm4_protocol_register(struct xfrm4_protocol *handler,
+			    unsigned char protocol)
+{
+	struct xfrm4_protocol __rcu **pprev;
+	struct xfrm4_protocol *t;
+	bool add_netproto = false;
+
+	int ret = -EEXIST;
+	int priority = handler->priority;
+
+	mutex_lock(&xfrm4_protocol_mutex);
+
+	if (!rcu_dereference_protected(*proto_handlers(protocol),
+				       lockdep_is_held(&xfrm4_protocol_mutex)))
+		add_netproto = true;
+
+	for (pprev = proto_handlers(protocol);
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&xfrm4_protocol_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t->priority < priority)
+			break;
+		if (t->priority == priority)
+			goto err;
+	}
+
+	handler->next = *pprev;
+	rcu_assign_pointer(*pprev, handler);
+
+	ret = 0;
+
+err:
+	mutex_unlock(&xfrm4_protocol_mutex);
+
+	if (add_netproto) {
+		if (inet_add_protocol(netproto(protocol), protocol)) {
+			pr_err("%s: can't add protocol\n", __func__);
+			ret = -EAGAIN;
+		}
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(xfrm4_protocol_register);
+
+int xfrm4_protocol_deregister(struct xfrm4_protocol *handler,
+			      unsigned char protocol)
+{
+	struct xfrm4_protocol __rcu **pprev;
+	struct xfrm4_protocol *t;
+	int ret = -ENOENT;
+
+	mutex_lock(&xfrm4_protocol_mutex);
+
+	for (pprev = proto_handlers(protocol);
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&xfrm4_protocol_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t == handler) {
+			*pprev = handler->next;
+			ret = 0;
+			break;
+		}
+	}
+
+	if (!rcu_dereference_protected(*proto_handlers(protocol),
+				       lockdep_is_held(&xfrm4_protocol_mutex))) {
+		if (inet_del_protocol(netproto(protocol), protocol) < 0) {
+			pr_err("%s: can't remove protocol\n", __func__);
+			ret = -EAGAIN;
+		}
+	}
+
+	mutex_unlock(&xfrm4_protocol_mutex);
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(xfrm4_protocol_deregister);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 6c7ac01..9bf7559 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -108,7 +108,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	int err;
 	__be32 seq;
 	__be32 seq_hi;
-	struct xfrm_state *x;
+	struct xfrm_state *x = NULL;
 	xfrm_address_t *daddr;
 	struct xfrm_mode *inner_mode;
 	unsigned int family;
@@ -120,9 +120,14 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		async = 1;
 		x = xfrm_input_state(skb);
 		seq = XFRM_SKB_CB(skb)->seq.input.low;
+		family = x->outer_mode->afinfo->family;
 		goto resume;
 	}
 
+	daddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->daddroff);
+	family = XFRM_SPI_SKB_CB(skb)->family;
+
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
 		struct sec_path *sp;
@@ -137,10 +142,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb->sp = sp;
 	}
 
-	daddr = (xfrm_address_t *)(skb_network_header(skb) +
-				   XFRM_SPI_SKB_CB(skb)->daddroff);
-	family = XFRM_SPI_SKB_CB(skb)->family;
-
 	seq = 0;
 	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
@@ -199,8 +200,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		nexthdr = x->type->input(x, skb);
 
-		if (nexthdr == -EINPROGRESS)
+		if (nexthdr == -EINPROGRESS) {
+			xfrm_rcv_cb(skb, family, x->type->proto, nexthdr);
 			return 0;
+		}
 
 resume:
 		spin_lock(&x->lock);
@@ -263,6 +266,8 @@ resume:
 		}
 	} while (!err);
 
+	xfrm_rcv_cb(skb, family, x->type->proto, 0);
+
 	nf_reset(skb);
 
 	if (decaps) {
@@ -276,6 +281,7 @@ resume:
 drop_unlock:
 	spin_unlock(&x->lock);
 drop:
+	xfrm_rcv_cb(skb, family, x ? x->type->proto : nexthdr, -1);
 	kfree_skb(skb);
 	return 0;
 }
-- 
1.7.9.5
