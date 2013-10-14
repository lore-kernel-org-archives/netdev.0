From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/17] netfilter: nf_tables: convert built-in tables/chains to chain types
Date: Mon, 14 Oct 2013 18:38:49 +0200
Message-ID: <1381768738-17739-9-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts built-in tables/chains to chain types that
allows you to deploy customized table and chain configurations from
userspace.

After this patch, you have to specify the chain type when
creating a new chain:

 add chain ip filter output { type filter hook input priority 0; }
                              ^^^^ ------

The existing chain types after this patch are: filter, route and
nat. Note that tables are just containers of chains with no specific
semantics, which is a significant change with regards to iptables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h                  |   31 ++-
 include/uapi/linux/netfilter/nf_tables.h           |    2 +
 net/ipv4/netfilter/Kconfig                         |    8 +-
 net/ipv4/netfilter/Makefile                        |    4 +-
 net/ipv4/netfilter/nf_tables_ipv4.c                |   21 +++
 .../{nf_table_nat_ipv4.c => nft_chain_nat_ipv4.c}  |  116 +++---------
 ...f_table_route_ipv4.c => nft_chain_route_ipv4.c} |   43 ++---
 net/ipv6/netfilter/Kconfig                         |    4 +-
 net/ipv6/netfilter/Makefile                        |    2 +-
 net/ipv6/netfilter/nf_tables_ipv6.c                |   22 ++-
 ...f_table_route_ipv6.c => nft_chain_route_ipv6.c} |   45 ++---
 net/netfilter/nf_tables_api.c                      |  197 +++++++++-----------
 12 files changed, 221 insertions(+), 274 deletions(-)
 rename net/ipv4/netfilter/{nf_table_nat_ipv4.c => nft_chain_nat_ipv4.c} (76%)
 rename net/ipv4/netfilter/{nf_table_route_ipv4.c => nft_chain_route_ipv4.c} (61%)
 rename net/ipv6/netfilter/{nf_table_route_ipv6.c => nft_chain_route_ipv6.c} (65%)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 66d0359..8403f7f5 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -336,7 +336,6 @@ static inline struct nft_expr *nft_expr_last(const struct nft_rule *rule)
 
 enum nft_chain_flags {
 	NFT_BASE_CHAIN			= 0x1,
-	NFT_CHAIN_BUILTIN		= 0x2,
 };
 
 /**
@@ -362,14 +361,23 @@ struct nft_chain {
 	char				name[NFT_CHAIN_MAXNAMELEN];
 };
 
+enum nft_chain_type {
+	NFT_CHAIN_T_DEFAULT = 0,
+	NFT_CHAIN_T_ROUTE,
+	NFT_CHAIN_T_NAT,
+	NFT_CHAIN_T_MAX
+};
+
 /**
  *	struct nft_base_chain - nf_tables base chain
  *
  *	@ops: netfilter hook ops
+ *	@type: chain type
  *	@chain: the chain
  */
 struct nft_base_chain {
 	struct nf_hook_ops		ops;
+	enum nft_chain_type		type;
 	struct nft_chain		chain;
 };
 
@@ -384,10 +392,6 @@ extern unsigned int nft_do_chain(const struct nf_hook_ops *ops,
 				 const struct net_device *out,
 				 int (*okfn)(struct sk_buff *));
 
-enum nft_table_flags {
-	NFT_TABLE_BUILTIN		= 0x1,
-};
-
 /**
  *	struct nft_table - nf_tables table
  *
@@ -431,8 +435,17 @@ struct nft_af_info {
 extern int nft_register_afinfo(struct nft_af_info *);
 extern void nft_unregister_afinfo(struct nft_af_info *);
 
-extern int nft_register_table(struct nft_table *, int family);
-extern void nft_unregister_table(struct nft_table *, int family);
+struct nf_chain_type {
+	unsigned int		hook_mask;
+	const char		*name;
+	enum nft_chain_type	type;
+	nf_hookfn		*fn[NF_MAX_HOOKS];
+	struct module		*me;
+	int			family;
+};
+
+extern int nft_register_chain_type(struct nf_chain_type *);
+extern void nft_unregister_chain_type(struct nf_chain_type *);
 
 extern int nft_register_expr(struct nft_expr_type *);
 extern void nft_unregister_expr(struct nft_expr_type *);
@@ -440,8 +453,8 @@ extern void nft_unregister_expr(struct nft_expr_type *);
 #define MODULE_ALIAS_NFT_FAMILY(family)	\
 	MODULE_ALIAS("nft-afinfo-" __stringify(family))
 
-#define MODULE_ALIAS_NFT_TABLE(family, name) \
-	MODULE_ALIAS("nft-table-" __stringify(family) "-" name)
+#define MODULE_ALIAS_NFT_CHAIN(family, name) \
+	MODULE_ALIAS("nft-chain-" __stringify(family) "-" name)
 
 #define MODULE_ALIAS_NFT_EXPR(name) \
 	MODULE_ALIAS("nft-expr-" name)
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 9e92401..779cf95 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -115,6 +115,7 @@ enum nft_table_attributes {
  * @NFTA_CHAIN_HANDLE: numeric handle of the chain (NLA_U64)
  * @NFTA_CHAIN_NAME: name of the chain (NLA_STRING)
  * @NFTA_CHAIN_HOOK: hook specification for basechains (NLA_NESTED: nft_hook_attributes)
+ * @NFTA_CHAIN_TYPE: type name of the string (NLA_NUL_STRING)
  */
 enum nft_chain_attributes {
 	NFTA_CHAIN_UNSPEC,
@@ -122,6 +123,7 @@ enum nft_chain_attributes {
 	NFTA_CHAIN_HANDLE,
 	NFTA_CHAIN_NAME,
 	NFTA_CHAIN_HOOK,
+	NFTA_CHAIN_TYPE,
 	__NFTA_CHAIN_MAX
 };
 #define NFTA_CHAIN_MAX		(__NFTA_CHAIN_MAX - 1)
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index eb1d56e..ae65fe9 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -44,13 +44,13 @@ config NFT_REJECT_IPV4
 	depends on NF_TABLES_IPV4
 	tristate "nf_tables IPv4 reject support"
 
-config NF_TABLE_ROUTE_IPV4
+config NFT_CHAIN_ROUTE_IPV4
 	depends on NF_TABLES_IPV4
-	tristate "IPv4 nf_tables route table support"
+	tristate "IPv4 nf_tables route chain support"
 
-config NF_TABLE_NAT_IPV4
+config NFT_CHAIN_NAT_IPV4
 	depends on NF_TABLES_IPV4
-	tristate "IPv4 nf_tables nat table support"
+	tristate "IPv4 nf_tables nat chain support"
 
 config IP_NF_IPTABLES
 	tristate "IP tables support (required for filtering/masq/NAT)"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index b2f01cd..91e0bd7 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -29,8 +29,8 @@ obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
 
 obj-$(CONFIG_NF_TABLES_IPV4) += nf_tables_ipv4.o
 obj-$(CONFIG_NFT_REJECT_IPV4) += nft_reject_ipv4.o
-obj-$(CONFIG_NF_TABLE_ROUTE_IPV4) += nf_table_route_ipv4.o
-obj-$(CONFIG_NF_TABLE_NAT_IPV4) += nf_table_nat_ipv4.o
+obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV4) += nft_chain_route_ipv4.o
+obj-$(CONFIG_NFT_CHAIN_NAT_IPV4) += nft_chain_nat_ipv4.o
 
 # generic IP tables 
 obj-$(CONFIG_IP_NF_IPTABLES) += ip_tables.o
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 63d0a3b..23525c4 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012-2013 Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -41,14 +42,34 @@ static struct nft_af_info nft_af_ipv4 __read_mostly = {
 	},
 };
 
+static struct nf_chain_type filter_ipv4 = {
+	.family		= NFPROTO_IPV4,
+	.name		= "filter",
+	.type		= NFT_CHAIN_T_DEFAULT,
+	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_FORWARD) |
+			  (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING),
+	.fn		= {
+		[NF_INET_LOCAL_IN]	= nft_do_chain,
+		[NF_INET_LOCAL_OUT]	= nft_do_chain,
+		[NF_INET_FORWARD]	= nft_do_chain,
+		[NF_INET_PRE_ROUTING]	= nft_do_chain,
+		[NF_INET_POST_ROUTING]	= nft_do_chain,
+	},
+};
+
 static int __init nf_tables_ipv4_init(void)
 {
+	nft_register_chain_type(&filter_ipv4);
 	return nft_register_afinfo(&nft_af_ipv4);
 }
 
 static void __exit nf_tables_ipv4_exit(void)
 {
 	nft_unregister_afinfo(&nft_af_ipv4);
+	nft_unregister_chain_type(&filter_ipv4);
 }
 
 module_init(nf_tables_ipv4_init);
diff --git a/net/ipv4/netfilter/nf_table_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
similarity index 76%
rename from net/ipv4/netfilter/nf_table_nat_ipv4.c
rename to net/ipv4/netfilter/nft_chain_nat_ipv4.c
index 2ecce39..cd28630 100644
--- a/net/ipv4/netfilter/nf_table_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (c) 2008-2009 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012 Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -167,7 +168,7 @@ static struct nft_expr_type nft_nat_type __read_mostly = {
 };
 
 /*
- * NAT table
+ * NAT chains
  */
 
 static unsigned int nf_nat_fn(const struct nf_hook_ops *ops,
@@ -301,115 +302,52 @@ static unsigned int nf_nat_output(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static struct nft_base_chain nf_chain_nat_prerouting __read_mostly = {
-	.chain	= {
-		.name		= "PREROUTING",
-		.rules		= LIST_HEAD_INIT(nf_chain_nat_prerouting.chain.rules),
-		.flags		= NFT_BASE_CHAIN | NFT_CHAIN_BUILTIN,
-	},
-	.ops	= {
-		.hook		= nf_nat_prerouting,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_PRE_ROUTING,
-		.priority	= NF_IP_PRI_NAT_DST,
-		.priv		= &nf_chain_nat_prerouting.chain,
-	},
-};
-
-static struct nft_base_chain nf_chain_nat_postrouting __read_mostly = {
-	.chain	= {
-		.name		= "POSTROUTING",
-		.rules		= LIST_HEAD_INIT(nf_chain_nat_postrouting.chain.rules),
-		.flags		= NFT_BASE_CHAIN | NFT_CHAIN_BUILTIN,
-	},
-	.ops	= {
-		.hook		= nf_nat_postrouting,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_POST_ROUTING,
-		.priority	= NF_IP_PRI_NAT_SRC,
-		.priv		= &nf_chain_nat_postrouting.chain,
-	},
-};
-
-static struct nft_base_chain nf_chain_nat_output __read_mostly = {
-	.chain	= {
-		.name		= "OUTPUT",
-		.rules		= LIST_HEAD_INIT(nf_chain_nat_output.chain.rules),
-		.flags		= NFT_BASE_CHAIN | NFT_CHAIN_BUILTIN,
-	},
-	.ops	= {
-		.hook		= nf_nat_output,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP_PRI_NAT_DST,
-		.priv		= &nf_chain_nat_output.chain,
-	},
-};
-
-static struct nft_base_chain nf_chain_nat_input __read_mostly = {
-	.chain	= {
-		.name		= "INPUT",
-		.rules		= LIST_HEAD_INIT(nf_chain_nat_input.chain.rules),
-		.flags		= NFT_BASE_CHAIN | NFT_CHAIN_BUILTIN,
-	},
-	.ops	= {
-		.hook		= nf_nat_fn,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP_PRI_NAT_SRC,
-		.priv		= &nf_chain_nat_input.chain,
+struct nf_chain_type nft_chain_nat_ipv4 = {
+	.family		= NFPROTO_IPV4,
+	.name		= "nat",
+	.type		= NFT_CHAIN_T_NAT,
+	.hook_mask	= (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_LOCAL_IN),
+	.fn		= {
+		[NF_INET_PRE_ROUTING]	= nf_nat_prerouting,
+		[NF_INET_POST_ROUTING]	= nf_nat_postrouting,
+		[NF_INET_LOCAL_OUT]	= nf_nat_output,
+		[NF_INET_LOCAL_IN]	= nf_nat_fn,
 	},
+	.me		= THIS_MODULE,
 };
 
-
-static struct nft_table nf_table_nat_ipv4 __read_mostly = {
-	.name	= "nat",
-	.chains	= LIST_HEAD_INIT(nf_table_nat_ipv4.chains),
-};
-
-static int __init nf_table_nat_init(void)
+static int __init nft_chain_nat_init(void)
 {
 	int err;
 
-	list_add_tail(&nf_chain_nat_prerouting.chain.list,
-		      &nf_table_nat_ipv4.chains);
-	list_add_tail(&nf_chain_nat_postrouting.chain.list,
-		      &nf_table_nat_ipv4.chains);
-	list_add_tail(&nf_chain_nat_output.chain.list,
-		      &nf_table_nat_ipv4.chains);
-	list_add_tail(&nf_chain_nat_input.chain.list,
-		      &nf_table_nat_ipv4.chains);
-
-	err = nft_register_table(&nf_table_nat_ipv4, NFPROTO_IPV4);
+	err = nft_register_chain_type(&nft_chain_nat_ipv4);
 	if (err < 0)
-		goto err1;
+		return err;
 
 	err = nft_register_expr(&nft_nat_type);
 	if (err < 0)
-		goto err2;
+		goto err;
 
 	return 0;
 
-err2:
-	nft_unregister_table(&nf_table_nat_ipv4, NFPROTO_IPV4);
-err1:
+err:
+	nft_unregister_chain_type(&nft_chain_nat_ipv4);
 	return err;
 }
 
-static void __exit nf_table_nat_exit(void)
+static void __exit nft_chain_nat_exit(void)
 {
 	nft_unregister_expr(&nft_nat_type);
-	nft_unregister_table(&nf_table_nat_ipv4, AF_INET);
+	nft_unregister_chain_type(&nft_chain_nat_ipv4);
 }
 
-module_init(nf_table_nat_init);
-module_exit(nf_table_nat_exit);
+module_init(nft_chain_nat_init);
+module_exit(nft_chain_nat_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_ALIAS_NFT_TABLE(AF_INET, "nat");
+MODULE_ALIAS_NFT_CHAIN(AF_INET, "nat");
 MODULE_ALIAS_NFT_EXPR("nat");
diff --git a/net/ipv4/netfilter/nf_table_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
similarity index 61%
rename from net/ipv4/netfilter/nf_table_route_ipv4.c
rename to net/ipv4/netfilter/nft_chain_route_ipv4.c
index 4f257a1..6b84e09 100644
--- a/net/ipv4/netfilter/nf_table_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012 Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -56,42 +57,30 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static struct nft_base_chain nf_chain_route_output __read_mostly = {
-	.chain	= {
-		.name		= "OUTPUT",
-		.rules		= LIST_HEAD_INIT(nf_chain_route_output.chain.rules),
-		.flags		= NFT_BASE_CHAIN | NFT_CHAIN_BUILTIN,
+static struct nf_chain_type nft_chain_route_ipv4 = {
+	.family		= NFPROTO_IPV4,
+	.name		= "route",
+	.type		= NFT_CHAIN_T_ROUTE,
+	.hook_mask	= (1 << NF_INET_LOCAL_OUT),
+	.fn		= {
+		[NF_INET_LOCAL_OUT]	= nf_route_table_hook,
 	},
-	.ops	= {
-		.hook		= nf_route_table_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP_PRI_MANGLE,
-		.priv		= &nf_chain_route_output.chain,
-	},
-};
-
-static struct nft_table nf_table_route_ipv4 __read_mostly = {
-	.name	= "route",
-	.chains	= LIST_HEAD_INIT(nf_table_route_ipv4.chains),
+	.me		= THIS_MODULE,
 };
 
-static int __init nf_table_route_init(void)
+static int __init nft_chain_route_init(void)
 {
-	list_add_tail(&nf_chain_route_output.chain.list,
-		      &nf_table_route_ipv4.chains);
-	return nft_register_table(&nf_table_route_ipv4, NFPROTO_IPV4);
+	return nft_register_chain_type(&nft_chain_route_ipv4);
 }
 
-static void __exit nf_table_route_exit(void)
+static void __exit nft_chain_route_exit(void)
 {
-	nft_unregister_table(&nf_table_route_ipv4, NFPROTO_IPV4);
+	nft_unregister_chain_type(&nft_chain_route_ipv4);
 }
 
-module_init(nf_table_route_init);
-module_exit(nf_table_route_exit);
+module_init(nft_chain_route_init);
+module_exit(nft_chain_route_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_ALIAS_NFT_TABLE(AF_INET, "route");
+MODULE_ALIAS_NFT_CHAIN(AF_INET, "route");
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 5677e38..2383306 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -29,9 +29,9 @@ config NF_TABLES_IPV6
 	depends on NF_TABLES
 	tristate "IPv6 nf_tables support"
 
-config NF_TABLE_ROUTE_IPV6
+config NFT_CHAIN_ROUTE_IPV6
 	depends on NF_TABLES_IPV6
-	tristate "IPv6 nf_tables route table support"
+	tristate "IPv6 nf_tables route chain support"
 
 config IP6_NF_IPTABLES
 	tristate "IP6 tables support (required for filtering)"
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 956af44..be4913a 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -25,7 +25,7 @@ obj-$(CONFIG_NF_DEFRAG_IPV6) += nf_defrag_ipv6.o
 
 # nf_tables
 obj-$(CONFIG_NF_TABLES_IPV6) += nf_tables_ipv6.o
-obj-$(CONFIG_NF_TABLE_ROUTE_IPV6) += nf_table_route_ipv6.o
+obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV6) += nft_chain_route_ipv6.o
 
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index e0717ce..3631d62 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012-2013 Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -39,14 +40,33 @@ static struct nft_af_info nft_af_ipv6 __read_mostly = {
 	},
 };
 
+static struct nf_chain_type filter_ipv6 = {
+	.family		= NFPROTO_IPV6,
+	.name		= "filter",
+	.type		= NFT_CHAIN_T_DEFAULT,
+	.hook_mask	= (1 << NF_INET_LOCAL_IN) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_FORWARD) |
+			  (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING),
+	.fn		= {
+		[NF_INET_LOCAL_IN]	= nft_do_chain,
+		[NF_INET_LOCAL_OUT]	= nft_do_chain,
+		[NF_INET_FORWARD]	= nft_do_chain,
+		[NF_INET_PRE_ROUTING]	= nft_do_chain,
+		[NF_INET_POST_ROUTING]	= nft_do_chain,
+	},
+};
+
 static int __init nf_tables_ipv6_init(void)
 {
+	nft_register_chain_type(&filter_ipv6);
 	return nft_register_afinfo(&nft_af_ipv6);
 }
-
 static void __exit nf_tables_ipv6_exit(void)
 {
 	nft_unregister_afinfo(&nft_af_ipv6);
+	nft_unregister_chain_type(&filter_ipv6);
 }
 
 module_init(nf_tables_ipv6_init);
diff --git a/net/ipv6/netfilter/nf_table_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
similarity index 65%
rename from net/ipv6/netfilter/nf_table_route_ipv6.c
rename to net/ipv6/netfilter/nft_chain_route_ipv6.c
index 48ac65c..4cdc992 100644
--- a/net/ipv6/netfilter/nf_table_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2012 Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -52,42 +53,30 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static struct nft_base_chain nf_chain_route_output __read_mostly = {
-	.chain	= {
-		.name		= "OUTPUT",
-		.rules		= LIST_HEAD_INIT(nf_chain_route_output.chain.rules),
-		.flags		= NFT_BASE_CHAIN | NFT_CHAIN_BUILTIN,
-	},
-	.ops	= {
-		.hook		= nf_route_table_hook,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_OUT,
-		.priority	= NF_IP6_PRI_MANGLE,
-		.priv		= &nf_chain_route_output.chain,
-	},
+static struct nf_chain_type nft_chain_route_ipv6 = {
+	.family		= NFPROTO_IPV6,
+	.name		= "route",
+	.type		= NFT_CHAIN_T_ROUTE,
+	.hook_mask	= (1 << NF_INET_LOCAL_OUT),
+	.fn		= {
+                [NF_INET_LOCAL_OUT]	= nf_route_table_hook,
+        },
+        .me		= THIS_MODULE,
 };
 
-static struct nft_table nf_table_route_ipv6 __read_mostly = {
-	.name	= "route",
-	.chains	= LIST_HEAD_INIT(nf_table_route_ipv6.chains),
-};
-
-static int __init nf_table_route_init(void)
+static int __init nft_chain_route_init(void)
 {
-	list_add_tail(&nf_chain_route_output.chain.list,
-		      &nf_table_route_ipv6.chains);
-	return nft_register_table(&nf_table_route_ipv6, NFPROTO_IPV6);
+	return nft_register_chain_type(&nft_chain_route_ipv6);
 }
 
-static void __exit nf_table_route_exit(void)
+static void __exit nft_chain_route_exit(void)
 {
-	nft_unregister_table(&nf_table_route_ipv6, NFPROTO_IPV6);
+	nft_unregister_chain_type(&nft_chain_route_ipv6);
 }
 
-module_init(nf_table_route_init);
-module_exit(nf_table_route_exit);
+module_init(nft_chain_route_init);
+module_exit(nft_chain_route_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_ALIAS_NFT_TABLE(AF_INET6, "route");
+MODULE_ALIAS_NFT_CHAIN(AF_INET6, "route");
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 6dac9a3..9c2d8d5 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -104,8 +104,7 @@ static struct nft_table *nft_table_lookup(const struct nft_af_info *afi,
 }
 
 static struct nft_table *nf_tables_table_lookup(const struct nft_af_info *afi,
-						const struct nlattr *nla,
-						bool autoload)
+						const struct nlattr *nla)
 {
 	struct nft_table *table;
 
@@ -116,16 +115,6 @@ static struct nft_table *nf_tables_table_lookup(const struct nft_af_info *afi,
 	if (table != NULL)
 		return table;
 
-#ifdef CONFIG_MODULES
-	if (autoload) {
-		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
-		request_module("nft-table-%u-%*.s", afi->family,
-			       nla_len(nla)-1, (const char *)nla_data(nla));
-		nfnl_lock(NFNL_SUBSYS_NFTABLES);
-		if (nft_table_lookup(afi, nla))
-			return ERR_PTR(-EAGAIN);
-	}
-#endif
 	return ERR_PTR(-ENOENT);
 }
 
@@ -134,6 +123,39 @@ static inline u64 nf_tables_alloc_handle(struct nft_table *table)
 	return ++table->hgenerator;
 }
 
+static struct nf_chain_type *chain_type[AF_MAX][NFT_CHAIN_T_MAX];
+
+static int __nf_tables_chain_type_lookup(int family, const struct nlattr *nla)
+{
+	int i;
+
+	for (i=0; i<NFT_CHAIN_T_MAX; i++) {
+		if (chain_type[family][i] != NULL &&
+		    !nla_strcmp(nla, chain_type[family][i]->name))
+			return i;
+	}
+	return -1;
+}
+
+static int nf_tables_chain_type_lookup(const struct nft_af_info *afi,
+				       const struct nlattr *nla,
+				       bool autoload)
+{
+	int type;
+
+	type = __nf_tables_chain_type_lookup(afi->family, nla);
+#ifdef CONFIG_MODULES
+	if (type < 0 && autoload) {
+		nfnl_unlock(NFNL_SUBSYS_NFTABLES);
+		request_module("nft-chain-%u-%*.s", afi->family,
+			       nla_len(nla)-1, (const char *)nla_data(nla));
+		nfnl_lock(NFNL_SUBSYS_NFTABLES);
+		type = __nf_tables_chain_type_lookup(afi->family, nla);
+	}
+#endif
+	return type;
+}
+
 static const struct nla_policy nft_table_policy[NFTA_TABLE_MAX + 1] = {
 	[NFTA_TABLE_NAME]	= { .type = NLA_STRING },
 };
@@ -258,7 +280,7 @@ static int nf_tables_gettable(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_TABLE_NAME], false);
+	table = nf_tables_table_lookup(afi, nla[NFTA_TABLE_NAME]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -294,7 +316,7 @@ static int nf_tables_newtable(struct sock *nlsk, struct sk_buff *skb,
 		return PTR_ERR(afi);
 
 	name = nla[NFTA_TABLE_NAME];
-	table = nf_tables_table_lookup(afi, name, false);
+	table = nf_tables_table_lookup(afi, name);
 	if (IS_ERR(table)) {
 		if (PTR_ERR(table) != -ENOENT)
 			return PTR_ERR(table);
@@ -335,13 +357,10 @@ static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_TABLE_NAME], false);
+	table = nf_tables_table_lookup(afi, nla[NFTA_TABLE_NAME]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
-	if (table->flags & NFT_TABLE_BUILTIN)
-		return -EOPNOTSUPP;
-
 	if (table->use)
 		return -EBUSY;
 
@@ -351,99 +370,34 @@ static int nf_tables_deltable(struct sock *nlsk, struct sk_buff *skb,
 	return 0;
 }
 
-static struct nft_table *__nf_tables_table_lookup(const struct nft_af_info *afi,
-						  const char *name)
+int nft_register_chain_type(struct nf_chain_type *ctype)
 {
-	struct nft_table *table;
-
-	list_for_each_entry(table, &afi->tables, list) {
-		if (!strcmp(name, table->name))
-			return table;
-	}
-
-	return ERR_PTR(-ENOENT);
-}
-
-static int nf_tables_chain_notify(const struct sk_buff *oskb,
-				  const struct nlmsghdr *nlh,
-				  const struct nft_table *table,
-				  const struct nft_chain *chain,
-				  int event, int family);
-
-/**
- *	nft_register_table - register a built-in table
- *
- *	@table: the table to register
- *	@family: protocol family to register table with
- *
- *	Register a built-in table for use with nf_tables. Returns zero on
- *	success or a negative errno code otherwise.
- */
-int nft_register_table(struct nft_table *table, int family)
-{
-	struct nft_af_info *afi;
-	struct nft_table *t;
-	struct nft_chain *chain;
-	int err;
+	int err = 0;
 
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-again:
-	afi = nf_tables_afinfo_lookup(family, true);
-	if (IS_ERR(afi)) {
-		err = PTR_ERR(afi);
-		if (err == -EAGAIN)
-			goto again;
-		goto err;
-	}
-
-	t = __nf_tables_table_lookup(afi, table->name);
-	if (IS_ERR(t)) {
-		err = PTR_ERR(t);
-		if (err != -ENOENT)
-			goto err;
-		t = NULL;
+	if (chain_type[ctype->family][ctype->type] != NULL) {
+		err = -EBUSY;
+		goto out;
 	}
 
-	if (t != NULL) {
-		err = -EEXIST;
-		goto err;
-	}
+	if (!try_module_get(ctype->me))
+		goto out;
 
-	table->flags |= NFT_TABLE_BUILTIN;
-	INIT_LIST_HEAD(&table->sets);
-	list_add_tail(&table->list, &afi->tables);
-	nf_tables_table_notify(NULL, NULL, table, NFT_MSG_NEWTABLE, family);
-	list_for_each_entry(chain, &table->chains, list)
-		nf_tables_chain_notify(NULL, NULL, table, chain,
-				       NFT_MSG_NEWCHAIN, family);
-	err = 0;
-err:
+	chain_type[ctype->family][ctype->type] = ctype;
+out:
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 	return err;
 }
-EXPORT_SYMBOL_GPL(nft_register_table);
+EXPORT_SYMBOL_GPL(nft_register_chain_type);
 
-/**
- *	nft_unregister_table - unregister a built-in table
- *
- *	@table: the table to unregister
- *	@family: protocol family to unregister table with
- *
- *	Unregister a built-in table for use with nf_tables.
- */
-void nft_unregister_table(struct nft_table *table, int family)
+void nft_unregister_chain_type(struct nf_chain_type *ctype)
 {
-	struct nft_chain *chain;
-
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
-	list_del(&table->list);
-	list_for_each_entry(chain, &table->chains, list)
-		nf_tables_chain_notify(NULL, NULL, table, chain,
-				       NFT_MSG_DELCHAIN, family);
-	nf_tables_table_notify(NULL, NULL, table, NFT_MSG_DELTABLE, family);
+	chain_type[ctype->family][ctype->type] = NULL;
+	module_put(ctype->me);
 	nfnl_unlock(NFNL_SUBSYS_NFTABLES);
 }
-EXPORT_SYMBOL_GPL(nft_unregister_table);
+EXPORT_SYMBOL_GPL(nft_unregister_chain_type);
 
 /*
  * Chains
@@ -484,6 +438,7 @@ static const struct nla_policy nft_chain_policy[NFTA_CHAIN_MAX + 1] = {
 	[NFTA_CHAIN_NAME]	= { .type = NLA_STRING,
 				    .len = NFT_CHAIN_MAXNAMELEN - 1 },
 	[NFTA_CHAIN_HOOK]	= { .type = NLA_NESTED },
+	[NFTA_CHAIN_TYPE]	= { .type = NLA_NUL_STRING },
 };
 
 static const struct nla_policy nft_hook_policy[NFTA_HOOK_MAX + 1] = {
@@ -526,6 +481,10 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, u32 portid, u32 seq,
 		if (nla_put_be32(skb, NFTA_HOOK_PRIORITY, htonl(ops->priority)))
 			goto nla_put_failure;
 		nla_nest_end(skb, nest);
+
+		if (nla_put_string(skb, NFTA_CHAIN_TYPE,
+			chain_type[ops->pf][nft_base_chain(chain)->type]->name))
+				goto nla_put_failure;
 	}
 
 	return nlmsg_end(skb, nlh);
@@ -633,7 +592,7 @@ static int nf_tables_getchain(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_CHAIN_TABLE], false);
+	table = nf_tables_table_lookup(afi, nla[NFTA_CHAIN_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -680,7 +639,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_CHAIN_TABLE], create);
+	table = nf_tables_table_lookup(afi, nla[NFTA_CHAIN_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -722,6 +681,17 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 	if (nla[NFTA_CHAIN_HOOK]) {
 		struct nf_hook_ops *ops;
+		nf_hookfn *hookfn;
+		u32 hooknum;
+		int type = NFT_CHAIN_T_DEFAULT;
+
+		if (nla[NFTA_CHAIN_TYPE]) {
+			type = nf_tables_chain_type_lookup(afi,
+							   nla[NFTA_CHAIN_TYPE],
+							   create);
+			if (type < 0)
+				return -ENOENT;
+		}
 
 		err = nla_parse_nested(ha, NFTA_HOOK_MAX, nla[NFTA_CHAIN_HOOK],
 				       nft_hook_policy);
@@ -730,12 +700,20 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		if (ha[NFTA_HOOK_HOOKNUM] == NULL ||
 		    ha[NFTA_HOOK_PRIORITY] == NULL)
 			return -EINVAL;
-		if (ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM])) >= afi->nhooks)
+
+		hooknum = ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM]));
+		if (hooknum >= afi->nhooks)
 			return -EINVAL;
 
+		hookfn = chain_type[family][type]->fn[hooknum];
+		if (hookfn == NULL)
+			return -EOPNOTSUPP;
+
 		basechain = kzalloc(sizeof(*basechain), GFP_KERNEL);
 		if (basechain == NULL)
 			return -ENOMEM;
+
+		basechain->type = type;
 		chain = &basechain->chain;
 
 		ops = &basechain->ops;
@@ -744,7 +722,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		ops->hooknum	= ntohl(nla_get_be32(ha[NFTA_HOOK_HOOKNUM]));
 		ops->priority	= ntohl(nla_get_be32(ha[NFTA_HOOK_PRIORITY]));
 		ops->priv	= chain;
-		ops->hook	= nft_do_chain;
+		ops->hook       = hookfn;
 		if (afi->hooks[ops->hooknum])
 			ops->hook = afi->hooks[ops->hooknum];
 
@@ -793,7 +771,7 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_CHAIN_TABLE], false);
+	table = nf_tables_table_lookup(afi, nla[NFTA_CHAIN_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -801,9 +779,6 @@ static int nf_tables_delchain(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(chain))
 		return PTR_ERR(chain);
 
-	if (chain->flags & NFT_CHAIN_BUILTIN)
-		return -EOPNOTSUPP;
-
 	if (!list_empty(&chain->rules))
 		return -EBUSY;
 
@@ -1190,7 +1165,7 @@ static int nf_tables_getrule(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_RULE_TABLE], false);
+	table = nf_tables_table_lookup(afi, nla[NFTA_RULE_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -1268,7 +1243,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_RULE_TABLE], create);
+	table = nf_tables_table_lookup(afi, nla[NFTA_RULE_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -1374,7 +1349,7 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_RULE_TABLE], false);
+	table = nf_tables_table_lookup(afi, nla[NFTA_RULE_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -1490,7 +1465,7 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx,
 		return PTR_ERR(afi);
 
 	if (nla[NFTA_SET_TABLE] != NULL) {
-		table = nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE], false);
+		table = nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE]);
 		if (IS_ERR(table))
 			return PTR_ERR(table);
 	}
@@ -1820,7 +1795,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE], create);
+	table = nf_tables_table_lookup(afi, nla[NFTA_SET_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
@@ -2008,7 +1983,7 @@ static int nft_ctx_init_from_elemattr(struct nft_ctx *ctx,
 	if (IS_ERR(afi))
 		return PTR_ERR(afi);
 
-	table = nf_tables_table_lookup(afi, nla[NFTA_SET_ELEM_LIST_TABLE], false);
+	table = nf_tables_table_lookup(afi, nla[NFTA_SET_ELEM_LIST_TABLE]);
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
-- 
1.7.10.4

