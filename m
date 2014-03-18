From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 03/13] xfrm6: Add IPsec protocol multiplexer
Date: Tue, 18 Mar 2014 08:21:28 +0100
Message-ID: <1395127298-24083-4-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53252 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282AbaCRHVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:54 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an IPsec protocol multiplexer for ipv6. With
this it is possible to add alternative protocol handlers, as
needed for IPsec virtual tunnel interfaces.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h        |   15 +++
 net/ipv6/Makefile         |    2 +-
 net/ipv6/xfrm6_policy.c   |    7 ++
 net/ipv6/xfrm6_protocol.c |  270 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 293 insertions(+), 1 deletion(-)
 create mode 100644 net/ipv6/xfrm6_protocol.c

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index af13599..6304ec3 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1374,6 +1374,16 @@ struct xfrm4_protocol {
 	int priority;
 };
 
+struct xfrm6_protocol {
+	int (*handler)(struct sk_buff *skb);
+	int (*cb_handler)(struct sk_buff *skb, int err);
+	int (*err_handler)(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			   u8 type, u8 code, int offset, __be32 info);
+
+	struct xfrm6_protocol __rcu *next;
+	int priority;
+};
+
 /* XFRM tunnel handlers.  */
 struct xfrm_tunnel {
 	int (*handler)(struct sk_buff *skb);
@@ -1408,6 +1418,8 @@ int xfrm6_init(void);
 void xfrm6_fini(void);
 int xfrm6_state_init(void);
 void xfrm6_state_fini(void);
+int xfrm6_protocol_init(void);
+void xfrm6_protocol_fini(void);
 #else
 static inline int xfrm6_init(void)
 {
@@ -1552,6 +1564,9 @@ int xfrm6_rcv(struct sk_buff *skb);
 int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		     xfrm_address_t *saddr, u8 proto);
 void xfrm6_local_error(struct sk_buff *skb, u32 mtu);
+int xfrm6_rcv_cb(struct sk_buff *skb, u8 protocol, int err);
+int xfrm6_protocol_register(struct xfrm6_protocol *handler, unsigned char protocol);
+int xfrm6_protocol_deregister(struct xfrm6_protocol *handler, unsigned char protocol);
 int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
 int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family);
 __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 17bb830..2fe6836 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -16,7 +16,7 @@ ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
 
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
-	xfrm6_output.o
+	xfrm6_output.o xfrm6_protocol.o
 ipv6-$(CONFIG_NETFILTER) += netfilter.o
 ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
 ipv6-$(CONFIG_PROC_FS) += proc.o
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 5f8e128..2a0bbda 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -389,11 +389,17 @@ int __init xfrm6_init(void)
 	if (ret)
 		goto out_policy;
 
+	ret = xfrm6_protocol_init();
+	if (ret)
+		goto out_state;
+
 #ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&xfrm6_net_ops);
 #endif
 out:
 	return ret;
+out_state:
+	xfrm6_state_fini();
 out_policy:
 	xfrm6_policy_fini();
 	goto out;
@@ -404,6 +410,7 @@ void xfrm6_fini(void)
 #ifdef CONFIG_SYSCTL
 	unregister_pernet_subsys(&xfrm6_net_ops);
 #endif
+	xfrm6_protocol_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
 	dst_entries_destroy(&xfrm6_dst_ops);
diff --git a/net/ipv6/xfrm6_protocol.c b/net/ipv6/xfrm6_protocol.c
new file mode 100644
index 0000000..6ab989c
--- /dev/null
+++ b/net/ipv6/xfrm6_protocol.c
@@ -0,0 +1,270 @@
+/* xfrm6_protocol.c - Generic xfrm protocol multiplexer for ipv6.
+ *
+ * Copyright (C) 2013 secunet Security Networks AG
+ *
+ * Author:
+ * Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * Based on:
+ * net/ipv4/xfrm4_protocol.c
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
+#include <linux/icmpv6.h>
+#include <net/ipv6.h>
+#include <net/protocol.h>
+#include <net/xfrm.h>
+
+static struct xfrm6_protocol __rcu *esp6_handlers __read_mostly;
+static struct xfrm6_protocol __rcu *ah6_handlers __read_mostly;
+static struct xfrm6_protocol __rcu *ipcomp6_handlers __read_mostly;
+static DEFINE_MUTEX(xfrm6_protocol_mutex);
+
+static inline struct xfrm6_protocol __rcu **proto_handlers(u8 protocol)
+{
+	switch (protocol) {
+	case IPPROTO_ESP:
+		return &esp6_handlers;
+	case IPPROTO_AH:
+		return &ah6_handlers;
+	case IPPROTO_COMP:
+		return &ipcomp6_handlers;
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
+int xfrm6_rcv_cb(struct sk_buff *skb, u8 protocol, int err)
+{
+	int ret;
+	struct xfrm6_protocol *handler;
+
+	for_each_protocol_rcu(*proto_handlers(protocol), handler)
+		if ((ret = handler->cb_handler(skb, err)) <= 0)
+			return ret;
+
+	return 0;
+}
+EXPORT_SYMBOL(xfrm6_rcv_cb);
+
+static int xfrm6_esp_rcv(struct sk_buff *skb)
+{
+	int ret;
+	struct xfrm6_protocol *handler;
+
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
+
+	for_each_protocol_rcu(esp6_handlers, handler)
+		if ((ret = handler->handler(skb)) != -EINVAL)
+			return ret;
+
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
+
+	kfree_skb(skb);
+	return 0;
+}
+
+static void xfrm6_esp_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			  u8 type, u8 code, int offset, __be32 info)
+{
+	struct xfrm6_protocol *handler;
+
+	for_each_protocol_rcu(esp6_handlers, handler)
+		if (!handler->err_handler(skb, opt, type, code, offset, info))
+			break;
+}
+
+static int xfrm6_ah_rcv(struct sk_buff *skb)
+{
+	int ret;
+	struct xfrm6_protocol *handler;
+
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
+
+	for_each_protocol_rcu(ah6_handlers, handler)
+		if ((ret = handler->handler(skb)) != -EINVAL)
+			return ret;
+
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
+
+	kfree_skb(skb);
+	return 0;
+}
+
+static void xfrm6_ah_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			 u8 type, u8 code, int offset, __be32 info)
+{
+	struct xfrm6_protocol *handler;
+
+	for_each_protocol_rcu(ah6_handlers, handler)
+		if (!handler->err_handler(skb, opt, type, code, offset, info))
+			break;
+}
+
+static int xfrm6_ipcomp_rcv(struct sk_buff *skb)
+{
+	int ret;
+	struct xfrm6_protocol *handler;
+
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
+
+	for_each_protocol_rcu(ipcomp6_handlers, handler)
+		if ((ret = handler->handler(skb)) != -EINVAL)
+			return ret;
+
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
+
+	kfree_skb(skb);
+	return 0;
+}
+
+static void xfrm6_ipcomp_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+			     u8 type, u8 code, int offset, __be32 info)
+{
+	struct xfrm6_protocol *handler;
+
+	for_each_protocol_rcu(ipcomp6_handlers, handler)
+		if (!handler->err_handler(skb, opt, type, code, offset, info))
+			break;
+}
+
+static const struct inet6_protocol esp6_protocol = {
+	.handler	=	xfrm6_esp_rcv,
+	.err_handler	=	xfrm6_esp_err,
+	.flags		=	INET6_PROTO_NOPOLICY,
+};
+
+static const struct inet6_protocol ah6_protocol = {
+	.handler	=	xfrm6_ah_rcv,
+	.err_handler	=	xfrm6_ah_err,
+	.flags		=	INET6_PROTO_NOPOLICY,
+};
+
+static const struct inet6_protocol ipcomp6_protocol = {
+	.handler	=	xfrm6_ipcomp_rcv,
+	.err_handler	=	xfrm6_ipcomp_err,
+	.flags		=	INET6_PROTO_NOPOLICY,
+};
+
+static struct xfrm_input_afinfo xfrm6_input_afinfo = {
+	.family		=	AF_INET6,
+	.owner		=	THIS_MODULE,
+	.callback	=	xfrm6_rcv_cb,
+};
+
+static inline const struct inet6_protocol *netproto(unsigned char protocol)
+{
+	switch (protocol) {
+	case IPPROTO_ESP:
+		return &esp6_protocol;
+	case IPPROTO_AH:
+		return &ah6_protocol;
+	case IPPROTO_COMP:
+		return &ipcomp6_protocol;
+	}
+
+	return NULL;
+}
+
+int xfrm6_protocol_register(struct xfrm6_protocol *handler,
+			    unsigned char protocol)
+{
+	struct xfrm6_protocol __rcu **pprev;
+	struct xfrm6_protocol *t;
+	bool add_netproto = false;
+
+	int ret = -EEXIST;
+	int priority = handler->priority;
+
+	mutex_lock(&xfrm6_protocol_mutex);
+
+	if (!rcu_dereference_protected(*proto_handlers(protocol),
+				       lockdep_is_held(&xfrm6_protocol_mutex)))
+		add_netproto = true;
+
+	for (pprev = proto_handlers(protocol);
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&xfrm6_protocol_mutex))) != NULL;
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
+	mutex_unlock(&xfrm6_protocol_mutex);
+
+	if (add_netproto) {
+		if (inet6_add_protocol(netproto(protocol), protocol)) {
+			pr_err("%s: can't add protocol\n", __func__);
+			ret = -EAGAIN;
+		}
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(xfrm6_protocol_register);
+
+int xfrm6_protocol_deregister(struct xfrm6_protocol *handler,
+			      unsigned char protocol)
+{
+	struct xfrm6_protocol __rcu **pprev;
+	struct xfrm6_protocol *t;
+	int ret = -ENOENT;
+
+	mutex_lock(&xfrm6_protocol_mutex);
+
+	for (pprev = proto_handlers(protocol);
+	     (t = rcu_dereference_protected(*pprev,
+			lockdep_is_held(&xfrm6_protocol_mutex))) != NULL;
+	     pprev = &t->next) {
+		if (t == handler) {
+			*pprev = handler->next;
+			ret = 0;
+			break;
+		}
+	}
+
+	if (!rcu_dereference_protected(*proto_handlers(protocol),
+				       lockdep_is_held(&xfrm6_protocol_mutex))) {
+		if (inet6_del_protocol(netproto(protocol), protocol) < 0) {
+			pr_err("%s: can't remove protocol\n", __func__);
+			ret = -EAGAIN;
+		}
+	}
+
+	mutex_unlock(&xfrm6_protocol_mutex);
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(xfrm6_protocol_deregister);
+
+int __init xfrm6_protocol_init(void)
+{
+	return xfrm_input_register_afinfo(&xfrm6_input_afinfo);
+}
+
+void xfrm6_protocol_fini(void)
+{
+	xfrm_input_unregister_afinfo(&xfrm6_input_afinfo);
+}
-- 
1.7.9.5
