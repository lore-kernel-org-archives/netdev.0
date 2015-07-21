From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 09/22] mpls: ip tunnel support
Date: Tue, 21 Jul 2015 10:43:53 +0200
Message-ID: <4e19277f267e125782a204c29a4919f0abe17d54.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39997 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbbGUIoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 04:44:22 -0400
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This implementation uses lwtunnel infrastructure to register
hooks for mpls tunnel encaps.

It picks cues from iptunnel_encaps infrastructure and previous
mpls iptunnel RFC patches from Eric W. Biederman and Robert Shearman

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/mpls_iptunnel.h      |   6 +
 include/net/mpls_iptunnel.h        |  29 +++++
 include/uapi/linux/mpls_iptunnel.h |  28 +++++
 net/mpls/Kconfig                   |   8 +-
 net/mpls/Makefile                  |   1 +
 net/mpls/mpls_iptunnel.c           | 233 +++++++++++++++++++++++++++++++++++++
 6 files changed, 304 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/mpls_iptunnel.h
 create mode 100644 include/net/mpls_iptunnel.h
 create mode 100644 include/uapi/linux/mpls_iptunnel.h
 create mode 100644 net/mpls/mpls_iptunnel.c

diff --git a/include/linux/mpls_iptunnel.h b/include/linux/mpls_iptunnel.h
new file mode 100644
index 0000000..ef29eb2
--- /dev/null
+++ b/include/linux/mpls_iptunnel.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_MPLS_IPTUNNEL_H
+#define _LINUX_MPLS_IPTUNNEL_H
+
+#include <uapi/linux/mpls_iptunnel.h>
+
+#endif  /* _LINUX_MPLS_IPTUNNEL_H */
diff --git a/include/net/mpls_iptunnel.h b/include/net/mpls_iptunnel.h
new file mode 100644
index 0000000..4757997
--- /dev/null
+++ b/include/net/mpls_iptunnel.h
@@ -0,0 +1,29 @@
+/*
+ * Copyright (c) 2015 Cumulus Networks, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef _NET_MPLS_IPTUNNEL_H
+#define _NET_MPLS_IPTUNNEL_H 1
+
+#define MAX_NEW_LABELS 2
+
+struct mpls_iptunnel_encap {
+	u32	label[MAX_NEW_LABELS];
+	u32	labels;
+};
+
+static inline struct mpls_iptunnel_encap *mpls_lwtunnel_encap(struct lwtunnel_state *lwtstate)
+{
+	return (struct mpls_iptunnel_encap *)lwtstate->data;
+}
+
+#endif
diff --git a/include/uapi/linux/mpls_iptunnel.h b/include/uapi/linux/mpls_iptunnel.h
new file mode 100644
index 0000000..d80a049
--- /dev/null
+++ b/include/uapi/linux/mpls_iptunnel.h
@@ -0,0 +1,28 @@
+/*
+ *	mpls tunnel api
+ *
+ *	Authors:
+ *		Roopa Prabhu <roopa@cumulusnetworks.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_MPLS_IPTUNNEL_H
+#define _UAPI_LINUX_MPLS_IPTUNNEL_H
+
+/* MPLS tunnel attributes
+ * [RTA_ENCAP] = {
+ *     [MPLS_IPTUNNEL_DST]
+ * }
+ */
+enum {
+	MPLS_IPTUNNEL_UNSPEC,
+	MPLS_IPTUNNEL_DST,
+	__MPLS_IPTUNNEL_MAX,
+};
+#define MPLS_IPTUNNEL_MAX (__MPLS_IPTUNNEL_MAX - 1)
+
+#endif /* _UAPI_LINUX_MPLS_IPTUNNEL_H */
diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index 17bde79..5c467ef 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -24,7 +24,13 @@ config NET_MPLS_GSO
 
 config MPLS_ROUTING
 	tristate "MPLS: routing support"
-	help
+	---help---
 	 Add support for forwarding of mpls packets.
 
+config MPLS_IPTUNNEL
+	tristate "MPLS: IP over MPLS tunnel support"
+	depends on LWTUNNEL && MPLS_ROUTING
+	---help---
+	 mpls ip tunnel support.
+
 endif # MPLS
diff --git a/net/mpls/Makefile b/net/mpls/Makefile
index 65bbe68..9ca9236 100644
--- a/net/mpls/Makefile
+++ b/net/mpls/Makefile
@@ -3,5 +3,6 @@
 #
 obj-$(CONFIG_NET_MPLS_GSO) += mpls_gso.o
 obj-$(CONFIG_MPLS_ROUTING) += mpls_router.o
+obj-$(CONFIG_MPLS_IPTUNNEL) += mpls_iptunnel.o
 
 mpls_router-y := af_mpls.o
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
new file mode 100644
index 0000000..eea096f
--- /dev/null
+++ b/net/mpls/mpls_iptunnel.c
@@ -0,0 +1,233 @@
+/*
+ * mpls tunnels	An implementation mpls tunnels using the light weight tunnel
+ *		infrastructure
+ *
+ * Authors:	Roopa Prabhu, <roopa@cumulusnetworks.com>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ */
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/net.h>
+#include <linux/module.h>
+#include <linux/mpls.h>
+#include <linux/vmalloc.h>
+#include <net/ip.h>
+#include <net/dst.h>
+#include <net/lwtunnel.h>
+#include <net/netevent.h>
+#include <net/netns/generic.h>
+#include <net/ip6_fib.h>
+#include <net/route.h>
+#include <net/mpls_iptunnel.h>
+#include <linux/mpls_iptunnel.h>
+#include "internal.h"
+
+static const struct nla_policy mpls_iptunnel_policy[MPLS_IPTUNNEL_MAX + 1] = {
+	[MPLS_IPTUNNEL_DST]	= { .type = NLA_U32 },
+};
+
+static unsigned int mpls_encap_size(struct mpls_iptunnel_encap *en)
+{
+	/* The size of the layer 2.5 labels to be added for this route */
+	return en->labels * sizeof(struct mpls_shim_hdr);
+}
+
+int mpls_output(struct sock *sk, struct sk_buff *skb)
+{
+	struct mpls_iptunnel_encap *tun_encap_info;
+	struct mpls_shim_hdr *hdr;
+	struct net_device *out_dev;
+	unsigned int hh_len;
+	unsigned int new_header_size;
+	unsigned int mtu;
+	struct dst_entry *dst = skb_dst(skb);
+	struct rtable *rt = NULL;
+	struct rt6_info *rt6 = NULL;
+	struct lwtunnel_state *lwtstate = NULL;
+	int err = 0;
+	bool bos;
+	int i;
+	unsigned int ttl;
+
+	/* Obtain the ttl */
+	if (skb->protocol == htons(ETH_P_IP)) {
+		ttl = ip_hdr(skb)->ttl;
+		rt = (struct rtable *)dst;
+		lwtstate = rt->rt_lwtstate;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		ttl = ipv6_hdr(skb)->hop_limit;
+		rt6 = (struct rt6_info *)dst;
+		lwtstate = rt6->rt6i_lwtstate;
+	} else {
+		goto drop;
+	}
+
+	skb_orphan(skb);
+
+	/* Find the output device */
+	out_dev = rcu_dereference(dst->dev);
+	if (!mpls_output_possible(out_dev) ||
+	    !lwtstate || skb_warn_if_lro(skb))
+		goto drop;
+
+	skb_forward_csum(skb);
+
+	tun_encap_info = mpls_lwtunnel_encap(lwtstate);
+
+	/* Verify the destination can hold the packet */
+	new_header_size = mpls_encap_size(tun_encap_info);
+	mtu = mpls_dev_mtu(out_dev);
+	if (mpls_pkt_too_big(skb, mtu - new_header_size))
+		goto drop;
+
+	hh_len = LL_RESERVED_SPACE(out_dev);
+	if (!out_dev->header_ops)
+		hh_len = 0;
+
+	/* Ensure there is enough space for the headers in the skb */
+	if (skb_cow(skb, hh_len + new_header_size))
+		goto drop;
+
+	skb_push(skb, new_header_size);
+	skb_reset_network_header(skb);
+
+	skb->dev = out_dev;
+	skb->protocol = htons(ETH_P_MPLS_UC);
+
+	/* Push the new labels */
+	hdr = mpls_hdr(skb);
+	bos = true;
+	for (i = tun_encap_info->labels - 1; i >= 0; i--) {
+		hdr[i] = mpls_entry_encode(tun_encap_info->label[i],
+					   ttl, 0, bos);
+		bos = false;
+	}
+
+	if (rt)
+		err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
+				 skb);
+	else if (rt6)
+		err = neigh_xmit(NEIGH_ND_TABLE, out_dev, &rt6->rt6i_gateway,
+				 skb);
+	if (err)
+		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
+				    __func__, err);
+
+	return 0;
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
+			    struct lwtunnel_state **ts)
+{
+	struct mpls_iptunnel_encap *tun_encap_info;
+	struct nlattr *tb[MPLS_IPTUNNEL_MAX + 1];
+	struct lwtunnel_state *newts;
+	int tun_encap_info_len;
+	int ret;
+
+	ret = nla_parse_nested(tb, MPLS_IPTUNNEL_MAX, nla,
+			       mpls_iptunnel_policy);
+	if (ret < 0)
+		return ret;
+
+	if (!tb[MPLS_IPTUNNEL_DST])
+		return -EINVAL;
+
+	tun_encap_info_len = sizeof(*tun_encap_info);
+
+	newts = lwtunnel_state_alloc(tun_encap_info_len);
+	if (!newts)
+		return -ENOMEM;
+
+	newts->len = tun_encap_info_len;
+	tun_encap_info = mpls_lwtunnel_encap(newts);
+	ret = nla_get_labels(tb[MPLS_IPTUNNEL_DST], MAX_NEW_LABELS,
+			     &tun_encap_info->labels, tun_encap_info->label);
+	if (ret)
+		goto errout;
+	newts->type = LWTUNNEL_ENCAP_MPLS;
+	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT;
+
+	*ts = newts;
+
+	return 0;
+
+errout:
+	kfree(newts);
+	*ts = NULL;
+
+	return ret;
+}
+
+static int mpls_fill_encap_info(struct sk_buff *skb,
+				struct lwtunnel_state *lwtstate)
+{
+	struct mpls_iptunnel_encap *tun_encap_info;
+	
+	tun_encap_info = mpls_lwtunnel_encap(lwtstate);
+
+	if (nla_put_labels(skb, MPLS_IPTUNNEL_DST, tun_encap_info->labels,
+			   tun_encap_info->label))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int mpls_encap_nlsize(struct lwtunnel_state *lwtstate)
+{
+	struct mpls_iptunnel_encap *tun_encap_info;
+
+	tun_encap_info = mpls_lwtunnel_encap(lwtstate);
+
+	return nla_total_size(tun_encap_info->labels * 4);
+}
+
+static int mpls_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
+{
+	struct mpls_iptunnel_encap *a_hdr = mpls_lwtunnel_encap(a);
+	struct mpls_iptunnel_encap *b_hdr = mpls_lwtunnel_encap(b);
+	int l;
+
+	if (a_hdr->labels != b_hdr->labels)
+		return 1;
+
+	for (l = 0; l < MAX_NEW_LABELS; l++)
+		if (a_hdr->label[l] != b_hdr->label[l])
+			return 1;
+	return 0;
+}
+
+static const struct lwtunnel_encap_ops mpls_iptun_ops = {
+	.build_state = mpls_build_state,
+	.output = mpls_output,
+	.fill_encap = mpls_fill_encap_info,
+	.get_encap_size = mpls_encap_nlsize,
+	.cmp_encap = mpls_encap_cmp,
+};
+
+static int __init mpls_iptunnel_init(void)
+{
+	return lwtunnel_encap_add_ops(&mpls_iptun_ops, LWTUNNEL_ENCAP_MPLS);
+}
+module_init(mpls_iptunnel_init);
+
+static void __exit mpls_iptunnel_exit(void)
+{
+	lwtunnel_encap_del_ops(&mpls_iptun_ops, LWTUNNEL_ENCAP_MPLS);
+}
+module_exit(mpls_iptunnel_exit);
+
+MODULE_DESCRIPTION("MultiProtocol Label Switching IP Tunnels");
+MODULE_LICENSE("GPL v2");
-- 
2.4.3
