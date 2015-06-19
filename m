From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next RFC v2 3/3] mpls: support for ip tunnels
Date: Thu, 18 Jun 2015 21:49:15 -0700
Message-ID: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33667 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852AbbFSEtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 00:49:23 -0400
Received: by pdjn11 with SMTP id n11so82177638pdj.0
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 21:49:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Support ip mpls tunnels using the new lwt infrastructure.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/mpls_iptunnel.h      |    6 ++
 include/net/mpls_iptunnel.h        |   29 +++++
 include/uapi/linux/mpls_iptunnel.h |   26 +++++
 net/mpls/Kconfig                   |    5 +
 net/mpls/Makefile                  |    1 +
 net/mpls/af_mpls.c                 |    9 +-
 net/mpls/internal.h                |    3 +
 net/mpls/mpls_iptunnel.c           |  205 ++++++++++++++++++++++++++++++++++++
 8 files changed, 281 insertions(+), 3 deletions(-)
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
index 0000000..4234efc
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
+	u8	labels;
+};
+
+static inline struct mpls_iptunnel_encap *mpls_lwt_hdr(struct lwtunnel_state *lwtstate)
+{
+	return (struct mpls_iptunnel_encap *)lwtstate->tunnel.data;
+}
+
+#endif
diff --git a/include/uapi/linux/mpls_iptunnel.h b/include/uapi/linux/mpls_iptunnel.h
new file mode 100644
index 0000000..228e36a
--- /dev/null
+++ b/include/uapi/linux/mpls_iptunnel.h
@@ -0,0 +1,26 @@
+/*
+ *	mpls tunnel api
+ *
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
index 17bde79..3e87a6b 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -27,4 +27,9 @@ config MPLS_ROUTING
 	help
 	 Add support for forwarding of mpls packets.
 
+config MPLS_IPTUNNEL
+	tristate "MPLS: IP over MPLS tunnel support"
+	help
+	 Light weight tunnel handling for mpls tunnel packets
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
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 1f93a59..c6f17ab 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -58,10 +58,11 @@ static inline struct mpls_dev *mpls_dev_get(const struct net_device *dev)
 	return rcu_dereference_rtnl(dev->mpls_ptr);
 }
 
-static bool mpls_output_possible(const struct net_device *dev)
+bool mpls_output_possible(const struct net_device *dev)
 {
 	return dev && (dev->flags & IFF_UP) && netif_carrier_ok(dev);
 }
+EXPORT_SYMBOL(mpls_output_possible);
 
 static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
 {
@@ -69,13 +70,14 @@ static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
 	return rt->rt_labels * sizeof(struct mpls_shim_hdr);
 }
 
-static unsigned int mpls_dev_mtu(const struct net_device *dev)
+unsigned int mpls_dev_mtu(const struct net_device *dev)
 {
 	/* The amount of data the layer 2 frame can hold */
 	return dev->mtu;
 }
+EXPORT_SYMBOL(mpls_dev_mtu);
 
-static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
+bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 {
 	if (skb->len <= mtu)
 		return false;
@@ -85,6 +87,7 @@ static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 
 	return true;
 }
+EXPORT_SYMBOL(mpls_pkt_too_big);
 
 static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
 			struct mpls_entry_decoded dec)
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 8cabeb5..8e3af1e 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -52,5 +52,8 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 
 int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels, const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels, u32 label[]);
+bool mpls_output_possible(const struct net_device *dev);
+unsigned int mpls_dev_mtu(const struct net_device *dev);
+bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
 
 #endif /* MPLS_INTERNAL_H */
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
new file mode 100644
index 0000000..79a9969
--- /dev/null
+++ b/net/mpls/mpls_iptunnel.c
@@ -0,0 +1,205 @@
+/*
+ * mpls tunnels	An implementation mpls tunnels using the light weight tunnel
+ *		infrastructure
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
+#include <net/mpls_iptunnel.h>
+#include <linux/mpls_iptunnel.h>
+#include "internal.h"
+
+static const struct nla_policy mpls_iptunnel_policy[MPLS_IPTUNNEL_MAX+1] = {
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
+	struct mpls_entry_decoded dec;
+	struct net_device *out_dev;
+	unsigned int hh_len;
+	unsigned int new_header_size;
+	unsigned int mtu;
+	struct lwtunnel_state *lwtstate;
+	struct rtable *rt = skb_rtable(skb);
+	int err;
+	bool bos;
+	int i;
+
+	if (skb->pkt_type != PACKET_HOST)
+		goto drop;
+
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+		goto drop;
+
+	if (!rt)
+		goto drop;
+
+	/* Find the output device */
+	out_dev = rcu_dereference(skb_dst(skb)->dev);
+	if (!mpls_output_possible(out_dev))
+		goto drop;
+
+	if (skb_warn_if_lro(skb))
+		goto drop;
+	skb_forward_csum(skb);
+
+	lwtstate = rt->rt_lwtstate;
+	if (!lwtstate)
+		goto drop;
+
+	tun_encap_info = mpls_lwt_hdr(lwtstate);
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
+	skb->dev = out_dev;
+	skb->protocol = htons(ETH_P_MPLS_UC);
+
+	skb_push(skb, new_header_size);
+	skb_reset_network_header(skb);
+
+	/* Push the new labels */
+	hdr = mpls_hdr(skb);
+	bos = true;
+	for (i = tun_encap_info->labels - 1; i >= 0; i--) {
+		hdr[i] = mpls_entry_encode(tun_encap_info->label[i],
+					   dec.ttl, 0, bos);
+		bos = false;
+	}
+
+	err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
+			 skb);
+	if (err)
+		net_dbg_ratelimited("%s: packet transmission failed: "
+					"%d\n", __func__, err);
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
+	struct nlattr *tb[MPLS_IPTUNNEL_MAX+1];
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
+	newts->tunnel.len = tun_encap_info_len;
+	tun_encap_info = mpls_lwt_hdr(newts);
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
+	tun_encap_info = mpls_lwt_hdr(lwtstate);
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
+	struct mpls_iptunnel_encap *tun_encap_info = mpls_lwt_hdr(lwtstate);
+
+	return nla_total_size(tun_encap_info->labels * 4);
+}
+
+static const struct lwtunnel_encap_ops mpls_iptun_ops = {
+	.build_state = mpls_build_state,
+	.output = mpls_output,
+	.fill_encap = mpls_fill_encap_info,
+	.get_encap_size = mpls_encap_nlsize,
+};
+
+static int __init mpls_iptunnel_init(void)
+{
+	lwtunnel_encap_add_ops(&mpls_iptun_ops, LWTUNNEL_ENCAP_MPLS);
+
+	return 0;
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
1.7.10.4
