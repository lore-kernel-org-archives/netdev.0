From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 3/5] ipv6: sr: define core operations for seg6local lightweight tunnel
Date: Sat, 5 Aug 2017 12:38:26 +0200
Message-ID: <20170805103828.21458-4-david.lebrun@uclouvain.be>
References: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:37178 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdHEKia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 06:38:30 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp3.sgsi.ucl.ac.be (Postfix) with ESMTPS id DB89367DCB5
        for <netdev@vger.kernel.org>; Sat,  5 Aug 2017 12:38:19 +0200 (CEST)
In-Reply-To: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a new type of lightweight tunnel named seg6local.
A seg6local lwt is defined by a type of action and a set of parameters.
The action represents the operation to perform on the packets matching the
lwt's route, and is not necessarily an encapsulation. The set of parameters
are arguments for the processing function.

Each action is defined in a struct seg6_action_desc within
seg6_action_table[]. This structure contains the action, mandatory
attributes, the processing function, and a static headroom size required by
the action. The mandatory attributes are encoded as a bitmask field. The
static headroom is set to a non-zero value when the processing function
always add a constant number of bytes to the skb (e.g. the header size for
encapsulations).

To facilitate rtnetlink-related operations such as parsing, fill_encap,
and cmp_encap, each type of action parameter is associated to three
function pointers, in seg6_action_params[].

All actions defined in seg6_local.h are detailed in [1].

[1] https://tools.ietf.org/html/draft-filsfils-spring-srv6-network-programming-01

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/linux/seg6_local.h      |   6 +
 include/net/seg6.h              |   2 +
 include/uapi/linux/lwtunnel.h   |   1 +
 include/uapi/linux/seg6_local.h |  68 +++++++++
 net/core/lwtunnel.c             |   2 +
 net/ipv6/Kconfig                |   3 +-
 net/ipv6/Makefile               |   2 +-
 net/ipv6/seg6.c                 |   5 +
 net/ipv6/seg6_local.c           | 320 ++++++++++++++++++++++++++++++++++++++++
 9 files changed, 407 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/seg6_local.h
 create mode 100644 include/uapi/linux/seg6_local.h
 create mode 100644 net/ipv6/seg6_local.c

diff --git a/include/linux/seg6_local.h b/include/linux/seg6_local.h
new file mode 100644
index 0000000..ee63e76
--- /dev/null
+++ b/include/linux/seg6_local.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_SEG6_LOCAL_H
+#define _LINUX_SEG6_LOCAL_H
+
+#include <uapi/linux/seg6_local.h>
+
+#endif
diff --git a/include/net/seg6.h b/include/net/seg6.h
index a32abb0..5379f55 100644
--- a/include/net/seg6.h
+++ b/include/net/seg6.h
@@ -56,6 +56,8 @@ extern int seg6_init(void);
 extern void seg6_exit(void);
 extern int seg6_iptunnel_init(void);
 extern void seg6_iptunnel_exit(void);
+extern int seg6_local_init(void);
+extern void seg6_local_exit(void);
 
 extern bool seg6_validate_srh(struct ipv6_sr_hdr *srh, int len);
 extern int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh);
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index 92724cba..7fdd19c 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -11,6 +11,7 @@ enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_IP6,
 	LWTUNNEL_ENCAP_SEG6,
 	LWTUNNEL_ENCAP_BPF,
+	LWTUNNEL_ENCAP_SEG6_LOCAL,
 	__LWTUNNEL_ENCAP_MAX,
 };
 
diff --git a/include/uapi/linux/seg6_local.h b/include/uapi/linux/seg6_local.h
new file mode 100644
index 0000000..ef2d8c3
--- /dev/null
+++ b/include/uapi/linux/seg6_local.h
@@ -0,0 +1,68 @@
+/*
+ *  SR-IPv6 implementation
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_SEG6_LOCAL_H
+#define _UAPI_LINUX_SEG6_LOCAL_H
+
+#include <linux/seg6.h>
+
+enum {
+	SEG6_LOCAL_UNSPEC,
+	SEG6_LOCAL_ACTION,
+	SEG6_LOCAL_SRH,
+	SEG6_LOCAL_TABLE,
+	SEG6_LOCAL_NH4,
+	SEG6_LOCAL_NH6,
+	SEG6_LOCAL_IIF,
+	SEG6_LOCAL_OIF,
+	__SEG6_LOCAL_MAX,
+};
+#define SEG6_LOCAL_MAX (__SEG6_LOCAL_MAX - 1)
+
+enum {
+	SEG6_LOCAL_ACTION_UNSPEC	= 0,
+	/* node segment */
+	SEG6_LOCAL_ACTION_END		= 1,
+	/* adjacency segment (IPv6 cross-connect) */
+	SEG6_LOCAL_ACTION_END_X		= 2,
+	/* lookup of next seg NH in table */
+	SEG6_LOCAL_ACTION_END_T		= 3,
+	/* decap and L2 cross-connect */
+	SEG6_LOCAL_ACTION_END_DX2	= 4,
+	/* decap and IPv6 cross-connect */
+	SEG6_LOCAL_ACTION_END_DX6	= 5,
+	/* decap and IPv4 cross-connect */
+	SEG6_LOCAL_ACTION_END_DX4	= 6,
+	/* decap and lookup of DA in v6 table */
+	SEG6_LOCAL_ACTION_END_DT6	= 7,
+	/* decap and lookup of DA in v4 table */
+	SEG6_LOCAL_ACTION_END_DT4	= 8,
+	/* binding segment with insertion */
+	SEG6_LOCAL_ACTION_END_B6	= 9,
+	/* binding segment with encapsulation */
+	SEG6_LOCAL_ACTION_END_B6_ENCAP	= 10,
+	/* binding segment with MPLS encap */
+	SEG6_LOCAL_ACTION_END_BM	= 11,
+	/* lookup last seg in table */
+	SEG6_LOCAL_ACTION_END_S		= 12,
+	/* forward to SR-unaware VNF with static proxy */
+	SEG6_LOCAL_ACTION_END_AS	= 13,
+	/* forward to SR-unaware VNF with masquerading */
+	SEG6_LOCAL_ACTION_END_AM	= 14,
+
+	__SEG6_LOCAL_ACTION_MAX,
+};
+
+#define SEG6_LOCAL_ACTION_MAX (__SEG6_LOCAL_ACTION_MAX - 1)
+
+#endif
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index d9cb353..3091001 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -44,6 +44,8 @@ static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
 		return "SEG6";
 	case LWTUNNEL_ENCAP_BPF:
 		return "BPF";
+	case LWTUNNEL_ENCAP_SEG6_LOCAL:
+		return "SEG6LOCAL";
 	case LWTUNNEL_ENCAP_IP6:
 	case LWTUNNEL_ENCAP_IP:
 	case LWTUNNEL_ENCAP_NONE:
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 50181a9..0d72239 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -311,7 +311,8 @@ config IPV6_SEG6_LWTUNNEL
 	---help---
 	  Support for encapsulation of packets within an outer IPv6
 	  header and a Segment Routing Header using the lightweight
-	  tunnels mechanism.
+	  tunnels mechanism. Also enable support for advanced local
+	  processing of SRv6 packets based on their active segment.
 
 	  If unsure, say N.
 
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index f8b24c2..10e3423 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -23,7 +23,7 @@ ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
 ipv6-$(CONFIG_PROC_FS) += proc.o
 ipv6-$(CONFIG_SYN_COOKIES) += syncookies.o
 ipv6-$(CONFIG_NETLABEL) += calipso.o
-ipv6-$(CONFIG_IPV6_SEG6_LWTUNNEL) += seg6_iptunnel.o
+ipv6-$(CONFIG_IPV6_SEG6_LWTUNNEL) += seg6_iptunnel.o seg6_local.o
 ipv6-$(CONFIG_IPV6_SEG6_HMAC) += seg6_hmac.o
 
 ipv6-objs += $(ipv6-y)
diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 81c2339..c814077 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -456,6 +456,10 @@ int __init seg6_init(void)
 	err = seg6_iptunnel_init();
 	if (err)
 		goto out_unregister_pernet;
+
+	err = seg6_local_init();
+	if (err)
+		goto out_unregister_pernet;
 #endif
 
 #ifdef CONFIG_IPV6_SEG6_HMAC
@@ -471,6 +475,7 @@ int __init seg6_init(void)
 #ifdef CONFIG_IPV6_SEG6_HMAC
 out_unregister_iptun:
 #ifdef CONFIG_IPV6_SEG6_LWTUNNEL
+	seg6_local_exit();
 	seg6_iptunnel_exit();
 #endif
 #endif
diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
new file mode 100644
index 0000000..53615d7
--- /dev/null
+++ b/net/ipv6/seg6_local.c
@@ -0,0 +1,320 @@
+/*
+ *  SR-IPv6 implementation
+ *
+ *  Author:
+ *  David Lebrun <david.lebrun@uclouvain.be>
+ *
+ *
+ *  This program is free software; you can redistribute it and/or
+ *        modify it under the terms of the GNU General Public License
+ *        as published by the Free Software Foundation; either version
+ *        2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/net.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <net/lwtunnel.h>
+#include <net/netevent.h>
+#include <net/netns/generic.h>
+#include <net/ip6_fib.h>
+#include <net/route.h>
+#include <net/seg6.h>
+#include <linux/seg6.h>
+#include <linux/seg6_local.h>
+#include <net/addrconf.h>
+#include <net/ip6_route.h>
+#include <net/dst_cache.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
+
+struct seg6_local_lwt;
+
+struct seg6_action_desc {
+	int action;
+	unsigned long attrs;
+	int (*input)(struct sk_buff *skb, struct seg6_local_lwt *slwt);
+	int static_headroom;
+};
+
+struct seg6_local_lwt {
+	int action;
+	struct ipv6_sr_hdr *srh;
+	int table;
+	struct in_addr nh4;
+	struct in6_addr nh6;
+	int iif;
+	int oif;
+
+	int headroom;
+	struct seg6_action_desc *desc;
+};
+
+static struct seg6_local_lwt *seg6_local_lwtunnel(struct lwtunnel_state *lwt)
+{
+	return (struct seg6_local_lwt *)lwt->data;
+}
+
+static struct seg6_action_desc seg6_action_table[] = {
+	{
+		.action		= SEG6_LOCAL_ACTION_END,
+		.attrs		= 0,
+	},
+};
+
+static struct seg6_action_desc *__get_action_desc(int action)
+{
+	struct seg6_action_desc *desc;
+	int i, count;
+
+	count = sizeof(seg6_action_table) / sizeof(struct seg6_action_desc);
+	for (i = 0; i < count; i++) {
+		desc = &seg6_action_table[i];
+		if (desc->action == action)
+			return desc;
+	}
+
+	return NULL;
+}
+
+static int seg6_local_input(struct sk_buff *skb)
+{
+	struct dst_entry *orig_dst = skb_dst(skb);
+	struct seg6_action_desc *desc;
+	struct seg6_local_lwt *slwt;
+
+	slwt = seg6_local_lwtunnel(orig_dst->lwtstate);
+	desc = slwt->desc;
+
+	return desc->input(skb, slwt);
+}
+
+static const struct nla_policy seg6_local_policy[SEG6_LOCAL_MAX + 1] = {
+	[SEG6_LOCAL_ACTION]	= { .type = NLA_U32 },
+	[SEG6_LOCAL_SRH]	= { .type = NLA_BINARY },
+	[SEG6_LOCAL_TABLE]	= { .type = NLA_U32 },
+	[SEG6_LOCAL_NH4]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct in_addr) },
+	[SEG6_LOCAL_NH6]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct in6_addr) },
+	[SEG6_LOCAL_IIF]	= { .type = NLA_U32 },
+	[SEG6_LOCAL_OIF]	= { .type = NLA_U32 },
+};
+
+struct seg6_action_param {
+	int (*parse)(struct nlattr **attrs, struct seg6_local_lwt *slwt);
+	int (*put)(struct sk_buff *skb, struct seg6_local_lwt *slwt);
+	int (*cmp)(struct seg6_local_lwt *a, struct seg6_local_lwt *b);
+};
+
+static struct seg6_action_param seg6_action_params[SEG6_LOCAL_MAX + 1] = {
+	[SEG6_LOCAL_SRH]	= { .parse = NULL,
+				    .put = NULL,
+				    .cmp = NULL },
+
+	[SEG6_LOCAL_TABLE]	= { .parse = NULL,
+				    .put = NULL,
+				    .cmp = NULL },
+
+	[SEG6_LOCAL_NH4]	= { .parse = NULL,
+				    .put = NULL,
+				    .cmp = NULL },
+
+	[SEG6_LOCAL_NH6]	= { .parse = NULL,
+				    .put = NULL,
+				    .cmp = NULL },
+
+	[SEG6_LOCAL_IIF]	= { .parse = NULL,
+				    .put = NULL,
+				    .cmp = NULL },
+
+	[SEG6_LOCAL_OIF]	= { .parse = NULL,
+				    .put = NULL,
+				    .cmp = NULL },
+};
+
+static int parse_nla_action(struct nlattr **attrs, struct seg6_local_lwt *slwt)
+{
+	struct seg6_action_param *param;
+	struct seg6_action_desc *desc;
+	int i, err;
+
+	desc = __get_action_desc(slwt->action);
+	if (!desc)
+		return -EINVAL;
+
+	if (!desc->input)
+		return -EOPNOTSUPP;
+
+	slwt->desc = desc;
+	slwt->headroom += desc->static_headroom;
+
+	for (i = 0; i < SEG6_LOCAL_MAX + 1; i++) {
+		if (desc->attrs & (1 << i)) {
+			if (!attrs[i])
+				return -EINVAL;
+
+			param = &seg6_action_params[i];
+
+			err = param->parse(attrs, slwt);
+			if (err < 0)
+				return err;
+		}
+	}
+
+	return 0;
+}
+
+static int seg6_local_build_state(struct nlattr *nla, unsigned int family,
+				  const void *cfg, struct lwtunnel_state **ts,
+				  struct netlink_ext_ack *extack)
+{
+	struct nlattr *tb[SEG6_LOCAL_MAX + 1];
+	struct lwtunnel_state *newts;
+	struct seg6_local_lwt *slwt;
+	int err;
+
+	err = nla_parse_nested(tb, SEG6_LOCAL_MAX, nla, seg6_local_policy,
+			       extack);
+
+	if (err < 0)
+		return err;
+
+	if (!tb[SEG6_LOCAL_ACTION])
+		return -EINVAL;
+
+	newts = lwtunnel_state_alloc(sizeof(*slwt));
+	if (!newts)
+		return -ENOMEM;
+
+	slwt = seg6_local_lwtunnel(newts);
+	slwt->action = nla_get_u32(tb[SEG6_LOCAL_ACTION]);
+
+	err = parse_nla_action(tb, slwt);
+	if (err < 0)
+		goto out_free;
+
+	newts->type = LWTUNNEL_ENCAP_SEG6_LOCAL;
+	newts->flags = LWTUNNEL_STATE_INPUT_REDIRECT;
+	newts->headroom = slwt->headroom;
+
+	*ts = newts;
+
+	return 0;
+
+out_free:
+	kfree(slwt->srh);
+	kfree(newts);
+	return err;
+}
+
+static void seg6_local_destroy_state(struct lwtunnel_state *lwt)
+{
+	struct seg6_local_lwt *slwt = seg6_local_lwtunnel(lwt);
+
+	kfree(slwt->srh);
+}
+
+static int seg6_local_fill_encap(struct sk_buff *skb,
+				 struct lwtunnel_state *lwt)
+{
+	struct seg6_local_lwt *slwt = seg6_local_lwtunnel(lwt);
+	struct seg6_action_param *param;
+	int i, err;
+
+	if (nla_put_u32(skb, SEG6_LOCAL_ACTION, slwt->action))
+		return -EMSGSIZE;
+
+	for (i = 0; i < SEG6_LOCAL_MAX + 1; i++) {
+		if (slwt->desc->attrs & (1 << i)) {
+			param = &seg6_action_params[i];
+			err = param->put(skb, slwt);
+			if (err < 0)
+				return err;
+		}
+	}
+
+	return 0;
+}
+
+static int seg6_local_get_encap_size(struct lwtunnel_state *lwt)
+{
+	struct seg6_local_lwt *slwt = seg6_local_lwtunnel(lwt);
+	unsigned long attrs;
+	int nlsize;
+
+	nlsize = nla_total_size(4); /* action */
+
+	attrs = slwt->desc->attrs;
+
+	if (attrs & (1 << SEG6_LOCAL_SRH))
+		nlsize += nla_total_size((slwt->srh->hdrlen + 1) << 3);
+
+	if (attrs & (1 << SEG6_LOCAL_TABLE))
+		nlsize += nla_total_size(4);
+
+	if (attrs & (1 << SEG6_LOCAL_NH4))
+		nlsize += nla_total_size(4);
+
+	if (attrs & (1 << SEG6_LOCAL_NH6))
+		nlsize += nla_total_size(16);
+
+	if (attrs & (1 << SEG6_LOCAL_IIF))
+		nlsize += nla_total_size(4);
+
+	if (attrs & (1 << SEG6_LOCAL_OIF))
+		nlsize += nla_total_size(4);
+
+	return nlsize;
+}
+
+static int seg6_local_cmp_encap(struct lwtunnel_state *a,
+				struct lwtunnel_state *b)
+{
+	struct seg6_local_lwt *slwt_a, *slwt_b;
+	struct seg6_action_param *param;
+	int i;
+
+	slwt_a = seg6_local_lwtunnel(a);
+	slwt_b = seg6_local_lwtunnel(b);
+
+	if (slwt_a->action != slwt_b->action)
+		return 1;
+
+	if (slwt_a->desc->attrs != slwt_b->desc->attrs)
+		return 1;
+
+	for (i = 0; i < SEG6_LOCAL_MAX + 1; i++) {
+		if (slwt_a->desc->attrs & (1 << i)) {
+			param = &seg6_action_params[i];
+			if (param->cmp(slwt_a, slwt_b))
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+static const struct lwtunnel_encap_ops seg6_local_ops = {
+	.build_state	= seg6_local_build_state,
+	.destroy_state	= seg6_local_destroy_state,
+	.input		= seg6_local_input,
+	.fill_encap	= seg6_local_fill_encap,
+	.get_encap_size	= seg6_local_get_encap_size,
+	.cmp_encap	= seg6_local_cmp_encap,
+	.owner		= THIS_MODULE,
+};
+
+int __init seg6_local_init(void)
+{
+	return lwtunnel_encap_add_ops(&seg6_local_ops,
+				      LWTUNNEL_ENCAP_SEG6_LOCAL);
+}
+
+void seg6_local_exit(void)
+{
+	lwtunnel_encap_del_ops(&seg6_local_ops, LWTUNNEL_ENCAP_SEG6_LOCAL);
+}
-- 
2.10.2
