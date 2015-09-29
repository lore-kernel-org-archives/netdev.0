From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/6] ila: Create net/ipv6/ila directory
Date: Tue, 29 Sep 2015 15:17:18 -0700
Message-ID: <1443565043-1287886-2-git-send-email-tom@herbertland.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17957 "EHLO
	m0001303.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755397AbbI2WRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:17:52 -0400
Received: from pps.filterd (m0001303 [127.0.0.1])
	by m0001303.ppops.net (8.14.5/8.14.5) with SMTP id t8TM8E8N001951
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1x82y2832e-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:50 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 eb07a8b066f711e59cdb0002c9dfb610-517f4240 for <netdev@vger.kernel.org>;	Tue,
 29 Sep 2015 15:17:49 -0700
In-Reply-To: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create ila directory in preparation for supporting other hooks in the
kernel than LWT for doing ILA. This includes:
  - Moving ila.c to ila/ila_lwt.c
  - Splitting out some common functions into ila_common.c

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/Makefile         |   2 +-
 net/ipv6/ila.c            | 229 ----------------------------------------------
 net/ipv6/ila/Makefile     |   7 ++
 net/ipv6/ila/ila.h        |  46 ++++++++++
 net/ipv6/ila/ila_common.c |  95 +++++++++++++++++++
 net/ipv6/ila/ila_lwt.c    | 152 ++++++++++++++++++++++++++++++
 6 files changed, 301 insertions(+), 230 deletions(-)
 delete mode 100644 net/ipv6/ila.c
 create mode 100644 net/ipv6/ila/Makefile
 create mode 100644 net/ipv6/ila/ila.h
 create mode 100644 net/ipv6/ila/ila_common.c
 create mode 100644 net/ipv6/ila/ila_lwt.c

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2c900c7..2fbd90b 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -34,7 +34,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
 obj-$(CONFIG_IPV6_MIP6) += mip6.o
-obj-$(CONFIG_IPV6_ILA) += ila.o
+obj-$(CONFIG_IPV6_ILA) += ila/
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
deleted file mode 100644
index 678d2df..0000000
--- a/net/ipv6/ila.c
+++ /dev/null
@@ -1,229 +0,0 @@
-#include <linux/errno.h>
-#include <linux/ip.h>
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/socket.h>
-#include <linux/types.h>
-#include <net/checksum.h>
-#include <net/ip.h>
-#include <net/ip6_fib.h>
-#include <net/lwtunnel.h>
-#include <net/protocol.h>
-#include <uapi/linux/ila.h>
-
-struct ila_params {
-	__be64 locator;
-	__be64 locator_match;
-	__wsum csum_diff;
-};
-
-static inline struct ila_params *ila_params_lwtunnel(
-	struct lwtunnel_state *lwstate)
-{
-	return (struct ila_params *)lwstate->data;
-}
-
-static inline __wsum compute_csum_diff8(const __be32 *from, const __be32 *to)
-{
-	__be32 diff[] = {
-		~from[0], ~from[1], to[0], to[1],
-	};
-
-	return csum_partial(diff, sizeof(diff), 0);
-}
-
-static inline __wsum get_csum_diff(struct ipv6hdr *ip6h, struct ila_params *p)
-{
-	if (*(__be64 *)&ip6h->daddr == p->locator_match)
-		return p->csum_diff;
-	else
-		return compute_csum_diff8((__be32 *)&ip6h->daddr,
-					  (__be32 *)&p->locator);
-}
-
-static void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
-{
-	__wsum diff;
-	struct ipv6hdr *ip6h = ipv6_hdr(skb);
-	size_t nhoff = sizeof(struct ipv6hdr);
-
-	/* First update checksum */
-	switch (ip6h->nexthdr) {
-	case NEXTHDR_TCP:
-		if (likely(pskb_may_pull(skb, nhoff + sizeof(struct tcphdr)))) {
-			struct tcphdr *th = (struct tcphdr *)
-					(skb_network_header(skb) + nhoff);
-
-			diff = get_csum_diff(ip6h, p);
-			inet_proto_csum_replace_by_diff(&th->check, skb,
-							diff, true);
-		}
-		break;
-	case NEXTHDR_UDP:
-		if (likely(pskb_may_pull(skb, nhoff + sizeof(struct udphdr)))) {
-			struct udphdr *uh = (struct udphdr *)
-					(skb_network_header(skb) + nhoff);
-
-			if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
-				diff = get_csum_diff(ip6h, p);
-				inet_proto_csum_replace_by_diff(&uh->check, skb,
-								diff, true);
-				if (!uh->check)
-					uh->check = CSUM_MANGLED_0;
-			}
-		}
-		break;
-	case NEXTHDR_ICMP:
-		if (likely(pskb_may_pull(skb,
-					 nhoff + sizeof(struct icmp6hdr)))) {
-			struct icmp6hdr *ih = (struct icmp6hdr *)
-					(skb_network_header(skb) + nhoff);
-
-			diff = get_csum_diff(ip6h, p);
-			inet_proto_csum_replace_by_diff(&ih->icmp6_cksum, skb,
-							diff, true);
-		}
-		break;
-	}
-
-	/* Now change destination address */
-	*(__be64 *)&ip6h->daddr = p->locator;
-}
-
-static int ila_output(struct sock *sk, struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-
-	if (skb->protocol != htons(ETH_P_IPV6))
-		goto drop;
-
-	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
-
-	return dst->lwtstate->orig_output(sk, skb);
-
-drop:
-	kfree_skb(skb);
-	return -EINVAL;
-}
-
-static int ila_input(struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-
-	if (skb->protocol != htons(ETH_P_IPV6))
-		goto drop;
-
-	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
-
-	return dst->lwtstate->orig_input(skb);
-
-drop:
-	kfree_skb(skb);
-	return -EINVAL;
-}
-
-static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
-	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
-};
-
-static int ila_build_state(struct net_device *dev, struct nlattr *nla,
-			   unsigned int family, const void *cfg,
-			   struct lwtunnel_state **ts)
-{
-	struct ila_params *p;
-	struct nlattr *tb[ILA_ATTR_MAX + 1];
-	size_t encap_len = sizeof(*p);
-	struct lwtunnel_state *newts;
-	const struct fib6_config *cfg6 = cfg;
-	int ret;
-
-	if (family != AF_INET6)
-		return -EINVAL;
-
-	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla,
-			       ila_nl_policy);
-	if (ret < 0)
-		return ret;
-
-	if (!tb[ILA_ATTR_LOCATOR])
-		return -EINVAL;
-
-	newts = lwtunnel_state_alloc(encap_len);
-	if (!newts)
-		return -ENOMEM;
-
-	newts->len = encap_len;
-	p = ila_params_lwtunnel(newts);
-
-	p->locator = (__force __be64)nla_get_u64(tb[ILA_ATTR_LOCATOR]);
-
-	if (cfg6->fc_dst_len > sizeof(__be64)) {
-		/* Precompute checksum difference for translation since we
-		 * know both the old locator and the new one.
-		 */
-		p->locator_match = *(__be64 *)&cfg6->fc_dst;
-		p->csum_diff = compute_csum_diff8(
-			(__be32 *)&p->locator_match, (__be32 *)&p->locator);
-	}
-
-	newts->type = LWTUNNEL_ENCAP_ILA;
-	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
-			LWTUNNEL_STATE_INPUT_REDIRECT;
-
-	*ts = newts;
-
-	return 0;
-}
-
-static int ila_fill_encap_info(struct sk_buff *skb,
-			       struct lwtunnel_state *lwtstate)
-{
-	struct ila_params *p = ila_params_lwtunnel(lwtstate);
-
-	if (nla_put_u64(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator))
-		goto nla_put_failure;
-
-	return 0;
-
-nla_put_failure:
-	return -EMSGSIZE;
-}
-
-static int ila_encap_nlsize(struct lwtunnel_state *lwtstate)
-{
-	/* No encapsulation overhead */
-	return 0;
-}
-
-static int ila_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
-{
-	struct ila_params *a_p = ila_params_lwtunnel(a);
-	struct ila_params *b_p = ila_params_lwtunnel(b);
-
-	return (a_p->locator != b_p->locator);
-}
-
-static const struct lwtunnel_encap_ops ila_encap_ops = {
-	.build_state = ila_build_state,
-	.output = ila_output,
-	.input = ila_input,
-	.fill_encap = ila_fill_encap_info,
-	.get_encap_size = ila_encap_nlsize,
-	.cmp_encap = ila_encap_cmp,
-};
-
-static int __init ila_init(void)
-{
-	return lwtunnel_encap_add_ops(&ila_encap_ops, LWTUNNEL_ENCAP_ILA);
-}
-
-static void __exit ila_fini(void)
-{
-	lwtunnel_encap_del_ops(&ila_encap_ops, LWTUNNEL_ENCAP_ILA);
-}
-
-module_init(ila_init);
-module_exit(ila_fini);
-MODULE_AUTHOR("Tom Herbert <tom@herbertland.com>");
-MODULE_LICENSE("GPL");
diff --git a/net/ipv6/ila/Makefile b/net/ipv6/ila/Makefile
new file mode 100644
index 0000000..31d136b
--- /dev/null
+++ b/net/ipv6/ila/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for ILA module
+#
+
+obj-$(CONFIG_IPV6_ILA) += ila.o
+
+ila-objs := ila_common.o ila_lwt.o
diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
new file mode 100644
index 0000000..b94081f
--- /dev/null
+++ b/net/ipv6/ila/ila.h
@@ -0,0 +1,46 @@
+/*
+ * Copyright (c) 2015 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ */
+
+#ifndef __ILA_H
+#define __ILA_H
+
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <net/checksum.h>
+#include <net/ip.h>
+#include <net/protocol.h>
+#include <uapi/linux/ila.h>
+
+struct ila_params {
+	__be64 locator;
+	__be64 locator_match;
+	__wsum csum_diff;
+};
+
+static inline __wsum compute_csum_diff8(const __be32 *from, const __be32 *to)
+{
+	__be32 diff[] = {
+		~from[0], ~from[1], to[0], to[1],
+	};
+
+	return csum_partial(diff, sizeof(diff), 0);
+}
+
+void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p);
+
+int ila_lwt_init(void);
+void ila_lwt_fini(void);
+
+#endif /* __ILA_H */
diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
new file mode 100644
index 0000000..1a1e1e0
--- /dev/null
+++ b/net/ipv6/ila/ila_common.c
@@ -0,0 +1,95 @@
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/types.h>
+#include <net/checksum.h>
+#include <net/ip.h>
+#include <net/ip6_fib.h>
+#include <net/lwtunnel.h>
+#include <net/protocol.h>
+#include <uapi/linux/ila.h>
+#include "ila.h"
+
+__wsum get_csum_diff(struct ipv6hdr *ip6h, struct ila_params *p)
+{
+	if (*(__be64 *)&ip6h->daddr == p->locator_match)
+		return p->csum_diff;
+	else
+		return compute_csum_diff8((__be32 *)&ip6h->daddr,
+					  (__be32 *)&p->locator);
+}
+
+void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
+{
+	__wsum diff;
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	size_t nhoff = sizeof(struct ipv6hdr);
+
+	/* First update checksum */
+	switch (ip6h->nexthdr) {
+	case NEXTHDR_TCP:
+		if (likely(pskb_may_pull(skb, nhoff + sizeof(struct tcphdr)))) {
+			struct tcphdr *th = (struct tcphdr *)
+					(skb_network_header(skb) + nhoff);
+
+			diff = get_csum_diff(ip6h, p);
+			inet_proto_csum_replace_by_diff(&th->check, skb,
+							diff, true);
+		}
+		break;
+	case NEXTHDR_UDP:
+		if (likely(pskb_may_pull(skb, nhoff + sizeof(struct udphdr)))) {
+			struct udphdr *uh = (struct udphdr *)
+					(skb_network_header(skb) + nhoff);
+
+			if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
+				diff = get_csum_diff(ip6h, p);
+				inet_proto_csum_replace_by_diff(&uh->check, skb,
+								diff, true);
+				if (!uh->check)
+					uh->check = CSUM_MANGLED_0;
+			}
+		}
+		break;
+	case NEXTHDR_ICMP:
+		if (likely(pskb_may_pull(skb,
+					 nhoff + sizeof(struct icmp6hdr)))) {
+			struct icmp6hdr *ih = (struct icmp6hdr *)
+					(skb_network_header(skb) + nhoff);
+
+			diff = get_csum_diff(ip6h, p);
+			inet_proto_csum_replace_by_diff(&ih->icmp6_cksum, skb,
+							diff, true);
+		}
+		break;
+	}
+
+	/* Now change destination address */
+	*(__be64 *)&ip6h->daddr = p->locator;
+}
+
+static int __init ila_init(void)
+{
+	int ret;
+
+	ret = ila_lwt_init();
+
+	if (ret)
+		goto fail_lwt;
+
+fail_lwt:
+	return ret;
+}
+
+static void __exit ila_fini(void)
+{
+	ila_lwt_fini();
+}
+
+module_init(ila_init);
+module_exit(ila_fini);
+MODULE_AUTHOR("Tom Herbert <tom@herbertland.com>");
+MODULE_LICENSE("GPL");
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
new file mode 100644
index 0000000..d4ed944
--- /dev/null
+++ b/net/ipv6/ila/ila_lwt.c
@@ -0,0 +1,152 @@
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/types.h>
+#include <net/checksum.h>
+#include <net/ip.h>
+#include <net/ip6_fib.h>
+#include <net/lwtunnel.h>
+#include <net/protocol.h>
+#include <uapi/linux/ila.h>
+#include "ila.h"
+
+static inline struct ila_params *ila_params_lwtunnel(
+	struct lwtunnel_state *lwstate)
+{
+	return (struct ila_params *)lwstate->data;
+}
+
+static int ila_output(struct sock *sk, struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	if (skb->protocol != htons(ETH_P_IPV6))
+		goto drop;
+
+	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
+
+	return dst->lwtstate->orig_output(sk, skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+static int ila_input(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	if (skb->protocol != htons(ETH_P_IPV6))
+		goto drop;
+
+	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
+
+	return dst->lwtstate->orig_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+static struct nla_policy ila_nl_policy[ILA_ATTR_MAX + 1] = {
+	[ILA_ATTR_LOCATOR] = { .type = NLA_U64, },
+};
+
+static int ila_build_state(struct net_device *dev, struct nlattr *nla,
+			   unsigned int family, const void *cfg,
+			   struct lwtunnel_state **ts)
+{
+	struct ila_params *p;
+	struct nlattr *tb[ILA_ATTR_MAX + 1];
+	size_t encap_len = sizeof(*p);
+	struct lwtunnel_state *newts;
+	const struct fib6_config *cfg6 = cfg;
+	int ret;
+
+	if (family != AF_INET6)
+		return -EINVAL;
+
+	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla,
+			       ila_nl_policy);
+	if (ret < 0)
+		return ret;
+
+	if (!tb[ILA_ATTR_LOCATOR])
+		return -EINVAL;
+
+	newts = lwtunnel_state_alloc(encap_len);
+	if (!newts)
+		return -ENOMEM;
+
+	newts->len = encap_len;
+	p = ila_params_lwtunnel(newts);
+
+	p->locator = (__force __be64)nla_get_u64(tb[ILA_ATTR_LOCATOR]);
+
+	if (cfg6->fc_dst_len > sizeof(__be64)) {
+		/* Precompute checksum difference for translation since we
+		 * know both the old locator and the new one.
+		 */
+		p->locator_match = *(__be64 *)&cfg6->fc_dst;
+		p->csum_diff = compute_csum_diff8(
+			(__be32 *)&p->locator_match, (__be32 *)&p->locator);
+	}
+
+	newts->type = LWTUNNEL_ENCAP_ILA;
+	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
+			LWTUNNEL_STATE_INPUT_REDIRECT;
+
+	*ts = newts;
+
+	return 0;
+}
+
+static int ila_fill_encap_info(struct sk_buff *skb,
+			       struct lwtunnel_state *lwtstate)
+{
+	struct ila_params *p = ila_params_lwtunnel(lwtstate);
+
+	if (nla_put_u64(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int ila_encap_nlsize(struct lwtunnel_state *lwtstate)
+{
+	/* No encapsulation overhead */
+	return 0;
+}
+
+static int ila_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
+{
+	struct ila_params *a_p = ila_params_lwtunnel(a);
+	struct ila_params *b_p = ila_params_lwtunnel(b);
+
+	return (a_p->locator != b_p->locator);
+}
+
+static const struct lwtunnel_encap_ops ila_encap_ops = {
+	.build_state = ila_build_state,
+	.output = ila_output,
+	.input = ila_input,
+	.fill_encap = ila_fill_encap_info,
+	.get_encap_size = ila_encap_nlsize,
+	.cmp_encap = ila_encap_cmp,
+};
+
+int ila_lwt_init(void)
+{
+	return lwtunnel_encap_add_ops(&ila_encap_ops, LWTUNNEL_ENCAP_ILA);
+}
+
+void ila_lwt_fini(void)
+{
+	lwtunnel_encap_del_ops(&ila_encap_ops, LWTUNNEL_ENCAP_ILA);
+}
-- 
2.4.6
