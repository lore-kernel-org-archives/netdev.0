From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/17] netfilter: nf_tables: add ARP filtering support
Date: Mon, 14 Oct 2013 18:38:58 +0200
Message-ID: <1381768738-17739-18-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34825 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757310Ab3JNQj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:29 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch registers the ARP family and he filter chain type
for this family.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/nftables.h       |    1 +
 net/ipv4/netfilter/Kconfig         |    4 ++
 net/ipv4/netfilter/Makefile        |    1 +
 net/ipv4/netfilter/nf_tables_arp.c |  102 ++++++++++++++++++++++++++++++++++++
 4 files changed, 108 insertions(+)
 create mode 100644 net/ipv4/netfilter/nf_tables_arp.c

diff --git a/include/net/netns/nftables.h b/include/net/netns/nftables.h
index 08a4248..15d056d 100644
--- a/include/net/netns/nftables.h
+++ b/include/net/netns/nftables.h
@@ -10,6 +10,7 @@ struct netns_nftables {
 	struct list_head	commit_list;
 	struct nft_af_info	*ipv4;
 	struct nft_af_info	*ipv6;
+	struct nft_af_info	*arp;
 	struct nft_af_info	*bridge;
 	u8			gencursor;
 	u8			genctr;
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1f37ef6..40d5607 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -53,6 +53,10 @@ config NFT_CHAIN_NAT_IPV4
 	depends on NF_NAT_IPV4 && NFT_NAT
 	tristate "IPv4 nf_tables nat chain support"
 
+config NF_TABLES_ARP
+	depends on NF_TABLES
+	tristate "ARP nf_tables support"
+
 config IP_NF_IPTABLES
 	tristate "IP tables support (required for filtering/masq/NAT)"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 91e0bd7..19df72b 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_NF_TABLES_IPV4) += nf_tables_ipv4.o
 obj-$(CONFIG_NFT_REJECT_IPV4) += nft_reject_ipv4.o
 obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV4) += nft_chain_route_ipv4.o
 obj-$(CONFIG_NFT_CHAIN_NAT_IPV4) += nft_chain_nat_ipv4.o
+obj-$(CONFIG_NF_TABLES_ARP) += nf_tables_arp.o
 
 # generic IP tables 
 obj-$(CONFIG_IP_NF_IPTABLES) += ip_tables.o
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
new file mode 100644
index 0000000..3e67ef1
--- /dev/null
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -0,0 +1,102 @@
+/*
+ * Copyright (c) 2008-2010 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2013 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Development of this code funded by Astaro AG (http://www.astaro.com/)
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netfilter_arp.h>
+#include <net/netfilter/nf_tables.h>
+
+static struct nft_af_info nft_af_arp __read_mostly = {
+	.family		= NFPROTO_ARP,
+	.nhooks		= NF_ARP_NUMHOOKS,
+	.owner		= THIS_MODULE,
+};
+
+static int nf_tables_arp_init_net(struct net *net)
+{
+	net->nft.arp = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
+	if (net->nft.arp== NULL)
+		return -ENOMEM;
+
+	memcpy(net->nft.arp, &nft_af_arp, sizeof(nft_af_arp));
+
+	if (nft_register_afinfo(net, net->nft.arp) < 0)
+		goto err;
+
+	return 0;
+err:
+	kfree(net->nft.arp);
+	return -ENOMEM;
+}
+
+static void nf_tables_arp_exit_net(struct net *net)
+{
+	nft_unregister_afinfo(net->nft.arp);
+	kfree(net->nft.arp);
+}
+
+static struct pernet_operations nf_tables_arp_net_ops = {
+	.init   = nf_tables_arp_init_net,
+	.exit   = nf_tables_arp_exit_net,
+};
+
+static unsigned int
+nft_do_chain_arp(const struct nf_hook_ops *ops,
+		  struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sk_buff *))
+{
+	struct nft_pktinfo pkt;
+
+	nft_set_pktinfo(&pkt, ops, skb, in, out);
+
+	return nft_do_chain_pktinfo(&pkt, ops);
+}
+
+static struct nf_chain_type filter_arp = {
+	.family		= NFPROTO_ARP,
+	.name		= "filter",
+	.type		= NFT_CHAIN_T_DEFAULT,
+	.hook_mask	= (1 << NF_ARP_IN) |
+			  (1 << NF_ARP_OUT) |
+			  (1 << NF_ARP_FORWARD),
+	.fn		= {
+		[NF_ARP_IN]		= nft_do_chain_arp,
+		[NF_ARP_OUT]		= nft_do_chain_arp,
+		[NF_ARP_FORWARD]	= nft_do_chain_arp,
+	},
+};
+
+static int __init nf_tables_arp_init(void)
+{
+	int ret;
+
+	nft_register_chain_type(&filter_arp);
+	ret = register_pernet_subsys(&nf_tables_arp_net_ops);
+	if (ret < 0)
+		nft_unregister_chain_type(&filter_arp);
+
+	return ret;
+}
+
+static void __exit nf_tables_arp_exit(void)
+{
+	unregister_pernet_subsys(&nf_tables_arp_net_ops);
+	nft_unregister_chain_type(&filter_arp);
+}
+
+module_init(nf_tables_arp_init);
+module_exit(nf_tables_arp_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS_NFT_FAMILY(3); /* NFPROTO_ARP */
-- 
1.7.10.4
