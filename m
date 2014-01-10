From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/23] netfilter: nf_tables: add "inet" table for IPv4/IPv6
Date: Fri, 10 Jan 2014 01:35:24 +0100
Message-ID: <1389314142-17969-6-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

This patch adds a new table family and a new filter chain that you can
use to attach IPv4 and IPv6 rules. This should help to simplify
rule-set maintainance in dual-stack setups.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_ipv4.h |    2 +
 include/net/netfilter/nf_tables_ipv6.h |    2 +
 include/net/netns/nftables.h           |    1 +
 include/uapi/linux/netfilter.h         |    1 +
 net/ipv4/netfilter/nf_tables_ipv4.c    |    3 +-
 net/ipv6/netfilter/nf_tables_ipv6.c    |    3 +-
 net/netfilter/Kconfig                  |    8 +++
 net/netfilter/Makefile                 |    1 +
 net/netfilter/nf_tables_inet.c         |   97 ++++++++++++++++++++++++++++++++
 9 files changed, 116 insertions(+), 2 deletions(-)
 create mode 100644 net/netfilter/nf_tables_inet.c

diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
index 1be1c2c..f7b3a66 100644
--- a/include/net/netfilter/nf_tables_ipv4.h
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -20,4 +20,6 @@ nft_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 	pkt->xt.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 }
 
+extern struct nft_af_info nft_af_ipv4;
+
 #endif
diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index 4a9b88a..3d8ae48 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -27,4 +27,6 @@ nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 	return 0;
 }
 
+extern struct nft_af_info nft_af_ipv6;
+
 #endif
diff --git a/include/net/netns/nftables.h b/include/net/netns/nftables.h
index 15d056d..26a394c 100644
--- a/include/net/netns/nftables.h
+++ b/include/net/netns/nftables.h
@@ -10,6 +10,7 @@ struct netns_nftables {
 	struct list_head	commit_list;
 	struct nft_af_info	*ipv4;
 	struct nft_af_info	*ipv6;
+	struct nft_af_info	*inet;
 	struct nft_af_info	*arp;
 	struct nft_af_info	*bridge;
 	u8			gencursor;
diff --git a/include/uapi/linux/netfilter.h b/include/uapi/linux/netfilter.h
index f7dc0eb..ef1b1f8 100644
--- a/include/uapi/linux/netfilter.h
+++ b/include/uapi/linux/netfilter.h
@@ -53,6 +53,7 @@ enum nf_inet_hooks {
 
 enum {
 	NFPROTO_UNSPEC =  0,
+	NFPROTO_INET   =  1,
 	NFPROTO_IPV4   =  2,
 	NFPROTO_ARP    =  3,
 	NFPROTO_BRIDGE =  7,
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 177c3bc..da927dc 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -48,7 +48,7 @@ static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 	return nft_do_chain_ipv4(ops, skb, in, out, okfn);
 }
 
-static struct nft_af_info nft_af_ipv4 __read_mostly = {
+struct nft_af_info nft_af_ipv4 __read_mostly = {
 	.family		= NFPROTO_IPV4,
 	.nhooks		= NF_INET_NUMHOOKS,
 	.owner		= THIS_MODULE,
@@ -61,6 +61,7 @@ static struct nft_af_info nft_af_ipv4 __read_mostly = {
 		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv4,
 	},
 };
+EXPORT_SYMBOL_GPL(nft_af_ipv4);
 
 static int nf_tables_ipv4_init_net(struct net *net)
 {
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 642280e..025e7f4 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -47,7 +47,7 @@ static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 	return nft_do_chain_ipv6(ops, skb, in, out, okfn);
 }
 
-static struct nft_af_info nft_af_ipv6 __read_mostly = {
+struct nft_af_info nft_af_ipv6 __read_mostly = {
 	.family		= NFPROTO_IPV6,
 	.nhooks		= NF_INET_NUMHOOKS,
 	.owner		= THIS_MODULE,
@@ -60,6 +60,7 @@ static struct nft_af_info nft_af_ipv6 __read_mostly = {
 		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv6,
 	},
 };
+EXPORT_SYMBOL_GPL(nft_af_ipv6);
 
 static int nf_tables_ipv6_init_net(struct net *net)
 {
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c3b3b26..37d2092 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -428,6 +428,14 @@ config NF_TABLES
 
 	  To compile it as a module, choose M here.
 
+config NF_TABLES_INET
+	depends on NF_TABLES
+	select NF_TABLES_IPV4
+	select NF_TABLES_IPV6
+	tristate "Netfilter nf_tables mixed IPv4/IPv6 tables support"
+	help
+	  This option enables support for a mixed IPv4/IPv6 "inet" table.
+
 config NFT_EXTHDR
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables IPv6 exthdr module"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 78b4e1c..74c0661 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -70,6 +70,7 @@ nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o
 nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
 
 obj-$(CONFIG_NF_TABLES)		+= nf_tables.o
+obj-$(CONFIG_NF_TABLES_INET)	+= nf_tables_inet.o
 obj-$(CONFIG_NFT_COMPAT)	+= nft_compat.o
 obj-$(CONFIG_NFT_EXTHDR)	+= nft_exthdr.o
 obj-$(CONFIG_NFT_META)		+= nft_meta.o
diff --git a/net/netfilter/nf_tables_inet.c b/net/netfilter/nf_tables_inet.c
new file mode 100644
index 0000000..ac0edcb
--- /dev/null
+++ b/net/netfilter/nf_tables_inet.c
@@ -0,0 +1,97 @@
+/*
+ * Copyright (c) 2012-2014 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/ip.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_ipv4.h>
+#include <net/netfilter/nf_tables_ipv6.h>
+#include <net/ip.h>
+
+static void nft_inet_hook_ops_init(struct nf_hook_ops *ops, unsigned int n)
+{
+	struct nft_af_info *afi;
+
+	if (n == 1)
+		afi = &nft_af_ipv4;
+	else
+		afi = &nft_af_ipv6;
+
+	ops->pf = afi->family;
+	if (afi->hooks[ops->hooknum])
+		ops->hook = afi->hooks[ops->hooknum];
+}
+
+static struct nft_af_info nft_af_inet __read_mostly = {
+	.family		= NFPROTO_INET,
+	.nhooks		= NF_INET_NUMHOOKS,
+	.owner		= THIS_MODULE,
+	.nops		= 2,
+	.hook_ops_init	= nft_inet_hook_ops_init,
+};
+
+static int __net_init nf_tables_inet_init_net(struct net *net)
+{
+	net->nft.inet = kmalloc(sizeof(struct nft_af_info), GFP_KERNEL);
+	if (net->nft.inet == NULL)
+		return -ENOMEM;
+	memcpy(net->nft.inet, &nft_af_inet, sizeof(nft_af_inet));
+
+	if (nft_register_afinfo(net, net->nft.inet) < 0)
+		goto err;
+
+	return 0;
+
+err:
+	kfree(net->nft.inet);
+	return -ENOMEM;
+}
+
+static void __net_exit nf_tables_inet_exit_net(struct net *net)
+{
+	nft_unregister_afinfo(net->nft.inet);
+	kfree(net->nft.inet);
+}
+
+static struct pernet_operations nf_tables_inet_net_ops = {
+	.init	= nf_tables_inet_init_net,
+	.exit	= nf_tables_inet_exit_net,
+};
+
+static struct nf_chain_type filter_inet = {
+	.family		= NFPROTO_INET,
+	.name		= "filter",
+	.type		= NFT_CHAIN_T_DEFAULT,
+	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_FORWARD) |
+			  (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING),
+};
+
+static int __init nf_tables_inet_init(void)
+{
+	nft_register_chain_type(&filter_inet);
+	return register_pernet_subsys(&nf_tables_inet_net_ops);
+}
+
+static void __exit nf_tables_inet_exit(void)
+{
+	unregister_pernet_subsys(&nf_tables_inet_net_ops);
+	nft_unregister_chain_type(&filter_inet);
+}
+
+module_init(nf_tables_inet_init);
+module_exit(nf_tables_inet_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
+MODULE_ALIAS_NFT_FAMILY(1);
-- 
1.7.10.4

