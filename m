From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: nf_tables: add netdev table to filter from ingress
Date: Fri, 29 May 2015 01:44:55 +0200
Message-ID: <1432856695-23831-5-git-send-email-pablo@netfilter.org>
References: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40659 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932432AbbE1XkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 19:40:02 -0400
In-Reply-To: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows us to create netdev tables that contain ingress chains. Use
skb_header_pointer() as we may see shared sk_buffs at this stage.

This change provides access to the existing nf_tables features from the ingress
hook.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/nftables.h     |    1 +
 net/netfilter/Kconfig            |    5 ++
 net/netfilter/Makefile           |    1 +
 net/netfilter/nf_tables_netdev.c |  183 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 190 insertions(+)
 create mode 100644 net/netfilter/nf_tables_netdev.c

diff --git a/include/net/netns/nftables.h b/include/net/netns/nftables.h
index eee608b..c807811 100644
--- a/include/net/netns/nftables.h
+++ b/include/net/netns/nftables.h
@@ -13,6 +13,7 @@ struct netns_nftables {
 	struct nft_af_info	*inet;
 	struct nft_af_info	*arp;
 	struct nft_af_info	*bridge;
+	struct nft_af_info	*netdev;
 	unsigned int		base_seq;
 	u8			gencursor;
 };
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 9a89e7c..bd5aaeb 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -456,6 +456,11 @@ config NF_TABLES_INET
 	help
 	  This option enables support for a mixed IPv4/IPv6 "inet" table.
 
+config NF_TABLES_NETDEV
+	tristate "Netfilter nf_tables netdev tables support"
+	help
+	  This option enables support for the "netdev" table.
+
 config NFT_EXTHDR
 	tristate "Netfilter nf_tables IPv6 exthdr module"
 	help
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index a87d8b8..70d026d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -75,6 +75,7 @@ nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
 
 obj-$(CONFIG_NF_TABLES)		+= nf_tables.o
 obj-$(CONFIG_NF_TABLES_INET)	+= nf_tables_inet.o
+obj-$(CONFIG_NF_TABLES_NETDEV)	+= nf_tables_netdev.o
 obj-$(CONFIG_NFT_COMPAT)	+= nft_compat.o
 obj-$(CONFIG_NFT_EXTHDR)	+= nft_exthdr.o
 obj-$(CONFIG_NFT_META)		+= nft_meta.o
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
new file mode 100644
index 0000000..04cb170
--- /dev/null
+++ b/net/netfilter/nf_tables_netdev.c
@@ -0,0 +1,183 @@
+/*
+ * Copyright (c) 2015 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <net/netfilter/nf_tables.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <net/netfilter/nf_tables_ipv4.h>
+#include <net/netfilter/nf_tables_ipv6.h>
+
+static inline void
+nft_netdev_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
+			    const struct nf_hook_ops *ops, struct sk_buff *skb,
+			    const struct nf_hook_state *state)
+{
+	struct iphdr *iph, _iph;
+	u32 len, thoff;
+
+	nft_set_pktinfo(pkt, ops, skb, state);
+
+	iph = skb_header_pointer(skb, skb_network_offset(skb), sizeof(*iph),
+				 &_iph);
+	if (!iph)
+		return;
+
+	iph = ip_hdr(skb);
+	if (iph->ihl < 5 || iph->version != 4)
+		return;
+
+	len = ntohs(iph->tot_len);
+	thoff = iph->ihl * 4;
+	if (skb->len < len)
+		return;
+	else if (len < thoff)
+		return;
+
+	pkt->tprot = iph->protocol;
+	pkt->xt.thoff = thoff;
+	pkt->xt.fragoff = ntohs(iph->frag_off) & IP_OFFSET;
+}
+
+static inline void
+__nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
+			      const struct nf_hook_ops *ops,
+			      struct sk_buff *skb,
+			      const struct nf_hook_state *state)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6hdr *ip6h, _ip6h;
+	unsigned int thoff = 0;
+	unsigned short frag_off;
+	int protohdr;
+	u32 pkt_len;
+
+	ip6h = skb_header_pointer(skb, skb_network_offset(skb), sizeof(*ip6h),
+				  &_ip6h);
+	if (!ip6h)
+		return;
+
+	if (ip6h->version != 6)
+		return;
+
+	pkt_len = ntohs(ip6h->payload_len);
+	if (pkt_len + sizeof(*ip6h) > skb->len)
+		return;
+
+	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
+	if (protohdr < 0)
+                return;
+
+	pkt->tprot = protohdr;
+	pkt->xt.thoff = thoff;
+	pkt->xt.fragoff = frag_off;
+#endif
+}
+
+static inline void nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
+					       const struct nf_hook_ops *ops,
+					       struct sk_buff *skb,
+					       const struct nf_hook_state *state)
+{
+	nft_set_pktinfo(pkt, ops, skb, state);
+	__nft_netdev_set_pktinfo_ipv6(pkt, ops, skb, state);
+}
+
+static unsigned int
+nft_do_chain_netdev(const struct nf_hook_ops *ops, struct sk_buff *skb,
+		    const struct nf_hook_state *state)
+{
+	struct nft_pktinfo pkt;
+
+	switch (eth_hdr(skb)->h_proto) {
+	case htons(ETH_P_IP):
+		nft_netdev_set_pktinfo_ipv4(&pkt, ops, skb, state);
+		break;
+	case htons(ETH_P_IPV6):
+		nft_netdev_set_pktinfo_ipv6(&pkt, ops, skb, state);
+		break;
+	default:
+		nft_set_pktinfo(&pkt, ops, skb, state);
+		break;
+	}
+
+	return nft_do_chain(&pkt, ops);
+}
+
+static struct nft_af_info nft_af_netdev __read_mostly = {
+	.family		= NFPROTO_NETDEV,
+	.nhooks		= NF_NETDEV_NUMHOOKS,
+	.owner		= THIS_MODULE,
+	.flags		= NFT_AF_NEEDS_DEV,
+	.nops		= 1,
+	.hooks		= {
+		[NF_NETDEV_INGRESS]	= nft_do_chain_netdev,
+	},
+};
+
+static int nf_tables_netdev_init_net(struct net *net)
+{
+	net->nft.netdev = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
+	if (net->nft.netdev == NULL)
+		return -ENOMEM;
+
+	memcpy(net->nft.netdev, &nft_af_netdev, sizeof(nft_af_netdev));
+
+	if (nft_register_afinfo(net, net->nft.netdev) < 0)
+		goto err;
+
+	return 0;
+err:
+	kfree(net->nft.netdev);
+	return -ENOMEM;
+}
+
+static void nf_tables_netdev_exit_net(struct net *net)
+{
+	nft_unregister_afinfo(net->nft.netdev);
+	kfree(net->nft.netdev);
+}
+
+static struct pernet_operations nf_tables_netdev_net_ops = {
+	.init	= nf_tables_netdev_init_net,
+	.exit	= nf_tables_netdev_exit_net,
+};
+
+static const struct nf_chain_type nft_filter_chain_netdev = {
+	.name		= "filter",
+	.type		= NFT_CHAIN_T_DEFAULT,
+	.family		= NFPROTO_NETDEV,
+	.owner		= THIS_MODULE,
+	.hook_mask	= (1 << NF_NETDEV_INGRESS),
+};
+
+static int __init nf_tables_netdev_init(void)
+{
+	int ret;
+
+	nft_register_chain_type(&nft_filter_chain_netdev);
+	ret = register_pernet_subsys(&nf_tables_netdev_net_ops);
+	if (ret < 0)
+		nft_unregister_chain_type(&nft_filter_chain_netdev);
+
+	return ret;
+}
+
+static void __exit nf_tables_netdev_exit(void)
+{
+	unregister_pernet_subsys(&nf_tables_netdev_net_ops);
+	nft_unregister_chain_type(&nft_filter_chain_netdev);
+}
+
+module_init(nf_tables_netdev_init);
+module_exit(nf_tables_netdev_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_FAMILY(5); /* NFPROTO_NETDEV */
-- 
1.7.10.4
