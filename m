From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/3] net: Identifier Locator Addressing module
Date: Thu, 13 Aug 2015 09:54:03 -0700
Message-ID: <1439484843-3848061-4-git-send-email-tom@herbertland.com>
References: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tgraf@suug.ch>, <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33987 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613AbbHMQyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 12:54:45 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7DGrh3G016762
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:54:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w8wbt894k-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:54:45 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 ff02df1041db11e5bb5124be0593f280-d63f12b0 for <netdev@vger.kernel.org>;	Thu,
 13 Aug 2015 09:54:43 -0700
In-Reply-To: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding new module name ila. This implements ILA translation. Light
weight tunnel redirection is used to perform the translation in
the data path. This is configured by the "ip -6 route" command
using the "encap ila <locator>" option, where <locator> is the
value to set in destination locator of the packet. e.g.

ip -6 route add 3333:0:0:1:5555:0:1:0/128 \
          encap ila 2001:0:0:1 via 2401:db00:20:911a:face:0:25:0

Sets a route where 3333:0:0:1 will be overwritten by
2001:0:0:1 on output.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/ila.h      |  15 +++++
 include/uapi/linux/lwtunnel.h |   1 +
 net/ipv6/Kconfig              |  18 ++++++
 net/ipv6/Makefile             |   1 +
 net/ipv6/ila/Makefile         |   7 +++
 net/ipv6/ila/ila.h            |  50 ++++++++++++++++
 net/ipv6/ila/ila_lwt.c        | 133 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ila/ila_main.c       |  69 ++++++++++++++++++++++
 8 files changed, 294 insertions(+)
 create mode 100644 include/uapi/linux/ila.h
 create mode 100644 net/ipv6/ila/Makefile
 create mode 100644 net/ipv6/ila/ila.h
 create mode 100644 net/ipv6/ila/ila_lwt.c
 create mode 100644 net/ipv6/ila/ila_main.c

diff --git a/include/uapi/linux/ila.h b/include/uapi/linux/ila.h
new file mode 100644
index 0000000..7ed9e67
--- /dev/null
+++ b/include/uapi/linux/ila.h
@@ -0,0 +1,15 @@
+/* ila.h - ILA Interface */
+
+#ifndef _UAPI_LINUX_ILA_H
+#define _UAPI_LINUX_ILA_H
+
+enum {
+	ILA_ATTR_UNSPEC,
+	ILA_ATTR_LOCATOR,			/* u64 */
+
+	__ILA_ATTR_MAX,
+};
+
+#define ILA_ATTR_MAX		(__ILA_ATTR_MAX - 1)
+
+#endif /* _UAPI_LINUX_ILA_H */
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index 31377bb..04bac3b 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -7,6 +7,7 @@ enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_NONE,
 	LWTUNNEL_ENCAP_MPLS,
 	LWTUNNEL_ENCAP_IP,
+	LWTUNNEL_ENCAP_ILA,
 	__LWTUNNEL_ENCAP_MAX,
 };
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 643f613..c732e27 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -92,6 +92,24 @@ config IPV6_MIP6
 
 	  If unsure, say N.
 
+config IPV6_ILA
+	tristate "IPv6: Identifier Locator Addressing (ILA)"
+	---help---
+	  Support for IPv6 Identifier Locator Addressing (ILA).
+
+	  ILA is a mechanism to do network virtualization without
+	  encapsulation. The basic concept of ILA is that we split an
+	  IPv6 address into a 64 bit locator and 64 bit identifier. The
+	  identifier is the identity of an entity in communication
+	  ("who") and the locator expresses the location of the
+	  entity ("where").
+
+	  ILA can be configured using the "encap ila" option with
+	  "ip -6 route" command. ILA is described in
+	  https://tools.ietf.org/html/draft-herbert-nvo3-ila-00.
+
+	  If unsure, say N.
+
 config INET6_XFRM_TUNNEL
 	tristate
 	select INET6_TUNNEL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 0f3f199..2fbd90b 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
 obj-$(CONFIG_IPV6_MIP6) += mip6.o
+obj-$(CONFIG_IPV6_ILA) += ila/
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
diff --git a/net/ipv6/ila/Makefile b/net/ipv6/ila/Makefile
new file mode 100644
index 0000000..cc0c202
--- /dev/null
+++ b/net/ipv6/ila/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for ILA module
+#
+
+obj-$(CONFIG_IPV6_ILA) += ila.o
+
+ila-objs := ila_main.o ila_lwt.o
diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
new file mode 100644
index 0000000..d2298b3
--- /dev/null
+++ b/net/ipv6/ila/ila.h
@@ -0,0 +1,50 @@
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
+static inline __wsum get_csum_diff(struct ipv6hdr *ip6h, struct ila_params *p)
+{
+		return compute_csum_diff8((__be32 *)&ip6h->daddr,
+					  (__be32 *)&p->locator);
+}
+
+void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p);
+
+int ila_lwt_init(void);
+void ila_lwt_fini(void);
+
+#endif /* __ILA_H */
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
new file mode 100644
index 0000000..8a06a6c
--- /dev/null
+++ b/net/ipv6/ila/ila_lwt.c
@@ -0,0 +1,133 @@
+#include "ila.h"
+#include <net/ip6_fib.h>
+#include <net/lwtunnel.h>
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
+	struct rt6_info *rt6 = NULL;
+
+	if (skb->protocol != htons(ETH_P_IPV6))
+		goto drop;
+
+	rt6 = (struct rt6_info *)dst;
+
+	update_ipv6_locator(skb, ila_params_lwtunnel(rt6->rt6i_lwtstate));
+
+	return rt6->rt6i_lwtstate->orig_output(sk, skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+static int ila_input(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct rt6_info *rt6 = NULL;
+
+	if (skb->protocol != htons(ETH_P_IPV6))
+		goto drop;
+
+	rt6 = (struct rt6_info *)dst;
+
+	update_ipv6_locator(skb, ila_params_lwtunnel(rt6->rt6i_lwtstate));
+
+	return rt6->rt6i_lwtstate->orig_input(skb);
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
+			   struct lwtunnel_state **ts)
+{
+	struct ila_params *p;
+	struct nlattr *tb[ILA_ATTR_MAX + 1];
+	size_t encap_len = sizeof(*p);
+	struct lwtunnel_state *newts;
+	int ret;
+
+	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla,
+			       ila_nl_policy);
+	if (ret < 0)
+		return ret;
+
+	newts = lwtunnel_state_alloc(encap_len);
+	if (!newts)
+		return -ENOMEM;
+
+	newts->len = encap_len;
+	p = ila_params_lwtunnel(newts);
+
+	if (!tb[ILA_ATTR_LOCATOR])
+		return -EINVAL;
+
+	p->locator = (__force __be64)nla_get_u64(tb[ILA_ATTR_LOCATOR]);
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
diff --git a/net/ipv6/ila/ila_main.c b/net/ipv6/ila/ila_main.c
new file mode 100644
index 0000000..b081084
--- /dev/null
+++ b/net/ipv6/ila/ila_main.c
@@ -0,0 +1,69 @@
+#include "ila.h"
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
+							diff, 1);
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
+								diff, 1);
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
+							diff, 1);
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
-- 
1.8.1
