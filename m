From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/15] netfilter: nf_tables: add nft_dup expression
Date: Wed, 19 Aug 2015 21:18:20 +0200
Message-ID: <1440011911-4359-5-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This new expression uses the nf_dup engine to clone packets to a given gateway.
Unlike xt_TEE, we use an index to indicate output interface which should be
fine at this stage.

Moreover, change to the preemtion-safe this_cpu_read(nf_skb_duplicated) from
nf_dup_ipv{4,6} to silence a lockdep splat.

Based on the original tee expression from Arturo Borrero Gonzalez, although
this patch has diverted quite a bit from this initial effort due to the
change to support maps.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nft_dup.h          |    9 +++
 include/uapi/linux/netfilter/nf_tables.h |   14 ++++
 net/ipv4/netfilter/Kconfig               |    6 ++
 net/ipv4/netfilter/Makefile              |    1 +
 net/ipv4/netfilter/nf_dup_ipv4.c         |    2 +-
 net/ipv4/netfilter/nft_dup_ipv4.c        |  110 ++++++++++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig               |    6 ++
 net/ipv6/netfilter/Makefile              |    1 +
 net/ipv6/netfilter/nf_dup_ipv6.c         |    2 +-
 net/ipv6/netfilter/nft_dup_ipv6.c        |  108 +++++++++++++++++++++++++++++
 10 files changed, 257 insertions(+), 2 deletions(-)
 create mode 100644 include/net/netfilter/nft_dup.h
 create mode 100644 net/ipv4/netfilter/nft_dup_ipv4.c
 create mode 100644 net/ipv6/netfilter/nft_dup_ipv6.c

diff --git a/include/net/netfilter/nft_dup.h b/include/net/netfilter/nft_dup.h
new file mode 100644
index 0000000..6b84cf6
--- /dev/null
+++ b/include/net/netfilter/nft_dup.h
@@ -0,0 +1,9 @@
+#ifndef _NFT_DUP_H_
+#define _NFT_DUP_H_
+
+struct nft_dup_inet {
+	enum nft_registers	sreg_addr:8;
+	enum nft_registers	sreg_dev:8;
+};
+
+#endif /* _NFT_DUP_H_ */
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index a99e6a9..2ef35f2 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -936,6 +936,20 @@ enum nft_redir_attributes {
 #define NFTA_REDIR_MAX		(__NFTA_REDIR_MAX - 1)
 
 /**
+ * enum nft_dup_attributes - nf_tables dup expression netlink attributes
+ *
+ * @NFTA_DUP_SREG_ADDR: source register of address (NLA_U32: nft_registers)
+ * @NFTA_DUP_SREG_DEV: source register of output interface (NLA_U32: nft_register)
+ */
+enum nft_dup_attributes {
+	NFTA_DUP_UNSPEC,
+	NFTA_DUP_SREG_ADDR,
+	NFTA_DUP_SREG_DEV,
+	__NFTA_DUP_MAX
+};
+#define NFTA_DUP_MAX		(__NFTA_DUP_MAX - 1)
+
+/**
  * enum nft_gen_attributes - nf_tables ruleset generation attributes
  *
  * @NFTA_GEN_ID: Ruleset generation ID (NLA_U32)
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 0142ea2..690d27d 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -58,6 +58,12 @@ config NFT_REJECT_IPV4
 	default NFT_REJECT
 	tristate
 
+config NFT_DUP_IPV4
+	tristate "IPv4 nf_tables packet duplication support"
+	select NF_DUP_IPV4
+	help
+	  This module enables IPv4 packet duplication support for nf_tables.
+
 endif # NF_TABLES_IPV4
 
 config NF_TABLES_ARP
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 9136ffc..87b073d 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -41,6 +41,7 @@ obj-$(CONFIG_NFT_CHAIN_NAT_IPV4) += nft_chain_nat_ipv4.o
 obj-$(CONFIG_NFT_REJECT_IPV4) += nft_reject_ipv4.o
 obj-$(CONFIG_NFT_MASQ_IPV4) += nft_masq_ipv4.o
 obj-$(CONFIG_NFT_REDIR_IPV4) += nft_redir_ipv4.o
+obj-$(CONFIG_NFT_DUP_IPV4) += nft_dup_ipv4.o
 obj-$(CONFIG_NF_TABLES_ARP) += nf_tables_arp.o
 
 # generic IP tables 
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index eff85ab..b5bb375 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -69,7 +69,7 @@ void nf_dup_ipv4(struct sk_buff *skb, unsigned int hooknum,
 {
 	struct iphdr *iph;
 
-	if (__this_cpu_read(nf_skb_duplicated))
+	if (this_cpu_read(nf_skb_duplicated))
 		return;
 	/*
 	 * Copy the skb, and route the copy. Will later return %XT_CONTINUE for
diff --git a/net/ipv4/netfilter/nft_dup_ipv4.c b/net/ipv4/netfilter/nft_dup_ipv4.c
new file mode 100644
index 0000000..25419fb
--- /dev/null
+++ b/net/ipv4/netfilter/nft_dup_ipv4.c
@@ -0,0 +1,110 @@
+/*
+ * Copyright (c) 2015 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/ipv4/nf_dup_ipv4.h>
+
+struct nft_dup_ipv4 {
+	enum nft_registers	sreg_addr:8;
+	enum nft_registers	sreg_dev:8;
+};
+
+static void nft_dup_ipv4_eval(const struct nft_expr *expr,
+			      struct nft_regs *regs,
+			      const struct nft_pktinfo *pkt)
+{
+	struct nft_dup_ipv4 *priv = nft_expr_priv(expr);
+	struct in_addr gw = {
+		.s_addr = regs->data[priv->sreg_addr],
+	};
+	int oif = regs->data[priv->sreg_dev];
+
+	nf_dup_ipv4(pkt->skb, pkt->ops->hooknum, &gw, oif);
+}
+
+static int nft_dup_ipv4_init(const struct nft_ctx *ctx,
+			     const struct nft_expr *expr,
+			     const struct nlattr * const tb[])
+{
+	struct nft_dup_ipv4 *priv = nft_expr_priv(expr);
+	int err;
+
+	if (tb[NFTA_DUP_SREG_ADDR] == NULL)
+		return -EINVAL;
+
+	priv->sreg_addr = nft_parse_register(tb[NFTA_DUP_SREG_ADDR]);
+	err = nft_validate_register_load(priv->sreg_addr, sizeof(struct in_addr));
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_DUP_SREG_DEV] != NULL) {
+		priv->sreg_dev = nft_parse_register(tb[NFTA_DUP_SREG_DEV]);
+		return nft_validate_register_load(priv->sreg_dev, sizeof(int));
+	}
+	return 0;
+}
+
+static int nft_dup_ipv4_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	struct nft_dup_ipv4 *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_DUP_SREG_ADDR, priv->sreg_addr) ||
+	    nft_dump_register(skb, NFTA_DUP_SREG_DEV, priv->sreg_dev))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_dup_ipv4_type;
+static const struct nft_expr_ops nft_dup_ipv4_ops = {
+	.type		= &nft_dup_ipv4_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_dup_ipv4)),
+	.eval		= nft_dup_ipv4_eval,
+	.init		= nft_dup_ipv4_init,
+	.dump		= nft_dup_ipv4_dump,
+};
+
+static const struct nla_policy nft_dup_ipv4_policy[NFTA_DUP_MAX + 1] = {
+	[NFTA_DUP_SREG_ADDR]	= { .type = NLA_U32 },
+	[NFTA_DUP_SREG_DEV]	= { .type = NLA_U32 },
+};
+
+static struct nft_expr_type nft_dup_ipv4_type __read_mostly = {
+	.family		= NFPROTO_IPV4,
+	.name		= "dup",
+	.ops		= &nft_dup_ipv4_ops,
+	.policy		= nft_dup_ipv4_policy,
+	.maxattr	= NFTA_DUP_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_dup_ipv4_module_init(void)
+{
+	return nft_register_expr(&nft_dup_ipv4_type);
+}
+
+static void __exit nft_dup_ipv4_module_exit(void)
+{
+	nft_unregister_expr(&nft_dup_ipv4_type);
+}
+
+module_init(nft_dup_ipv4_module_init);
+module_exit(nft_dup_ipv4_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_AF_EXPR(AF_INET, "dup");
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 298daf3..96833e4 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -47,6 +47,12 @@ config NFT_REJECT_IPV6
 	default NFT_REJECT
 	tristate
 
+config NFT_DUP_IPV6
+	tristate "IPv6 nf_tables packet duplication support"
+	select NF_DUP_IPV6
+	help
+	  This module enables IPv6 packet duplication support for nf_tables.
+
 endif # NF_TABLES_IPV6
 endif # NF_TABLES
 
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index dc6c732..b4f7d0b 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -39,6 +39,7 @@ obj-$(CONFIG_NFT_CHAIN_NAT_IPV6) += nft_chain_nat_ipv6.o
 obj-$(CONFIG_NFT_REJECT_IPV6) += nft_reject_ipv6.o
 obj-$(CONFIG_NFT_MASQ_IPV6) += nft_masq_ipv6.o
 obj-$(CONFIG_NFT_REDIR_IPV6) += nft_redir_ipv6.o
+obj-$(CONFIG_NFT_DUP_IPV6) += nft_dup_ipv6.o
 
 # matches
 obj-$(CONFIG_IP6_NF_MATCH_AH) += ip6t_ah.o
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index 399fdda..d8ab654 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -63,7 +63,7 @@ static bool nf_dup_ipv6_route(struct sk_buff *skb, const struct in6_addr *gw,
 void nf_dup_ipv6(struct sk_buff *skb, unsigned int hooknum,
 		 const struct in6_addr *gw, int oif)
 {
-	if (__this_cpu_read(nf_skb_duplicated))
+	if (this_cpu_read(nf_skb_duplicated))
 		return;
 	skb = pskb_copy(skb, GFP_ATOMIC);
 	if (skb == NULL)
diff --git a/net/ipv6/netfilter/nft_dup_ipv6.c b/net/ipv6/netfilter/nft_dup_ipv6.c
new file mode 100644
index 0000000..0eaa4f6
--- /dev/null
+++ b/net/ipv6/netfilter/nft_dup_ipv6.c
@@ -0,0 +1,108 @@
+/*
+ * Copyright (c) 2015 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables.h>
+#include <net/netfilter/ipv6/nf_dup_ipv6.h>
+
+struct nft_dup_ipv6 {
+	enum nft_registers	sreg_addr:8;
+	enum nft_registers	sreg_dev:8;
+};
+
+static void nft_dup_ipv6_eval(const struct nft_expr *expr,
+			      struct nft_regs *regs,
+			      const struct nft_pktinfo *pkt)
+{
+	struct nft_dup_ipv6 *priv = nft_expr_priv(expr);
+	struct in6_addr *gw = (struct in6_addr *)&regs->data[priv->sreg_addr];
+	int oif = regs->data[priv->sreg_dev];
+
+	nf_dup_ipv6(pkt->skb, pkt->ops->hooknum, gw, oif);
+}
+
+static int nft_dup_ipv6_init(const struct nft_ctx *ctx,
+			     const struct nft_expr *expr,
+			     const struct nlattr * const tb[])
+{
+	struct nft_dup_ipv6 *priv = nft_expr_priv(expr);
+	int err;
+
+	if (tb[NFTA_DUP_SREG_ADDR] == NULL)
+		return -EINVAL;
+
+	priv->sreg_addr = nft_parse_register(tb[NFTA_DUP_SREG_ADDR]);
+	err = nft_validate_register_load(priv->sreg_addr, sizeof(struct in6_addr));
+	if (err < 0)
+		return err;
+
+	if (tb[NFTA_DUP_SREG_DEV] != NULL) {
+		priv->sreg_dev = nft_parse_register(tb[NFTA_DUP_SREG_DEV]);
+		return nft_validate_register_load(priv->sreg_dev, sizeof(int));
+	}
+	return 0;
+}
+
+static int nft_dup_ipv6_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	struct nft_dup_ipv6 *priv = nft_expr_priv(expr);
+
+	if (nft_dump_register(skb, NFTA_DUP_SREG_ADDR, priv->sreg_addr) ||
+	    nft_dump_register(skb, NFTA_DUP_SREG_DEV, priv->sreg_dev))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static struct nft_expr_type nft_dup_ipv6_type;
+static const struct nft_expr_ops nft_dup_ipv6_ops = {
+	.type		= &nft_dup_ipv6_type,
+	.size		= NFT_EXPR_SIZE(sizeof(struct nft_dup_ipv6)),
+	.eval		= nft_dup_ipv6_eval,
+	.init		= nft_dup_ipv6_init,
+	.dump		= nft_dup_ipv6_dump,
+};
+
+static const struct nla_policy nft_dup_ipv6_policy[NFTA_DUP_MAX + 1] = {
+	[NFTA_DUP_SREG_ADDR]	= { .type = NLA_U32 },
+	[NFTA_DUP_SREG_DEV]	= { .type = NLA_U32 },
+};
+
+static struct nft_expr_type nft_dup_ipv6_type __read_mostly = {
+	.family		= NFPROTO_IPV6,
+	.name		= "dup",
+	.ops		= &nft_dup_ipv6_ops,
+	.policy		= nft_dup_ipv6_policy,
+	.maxattr	= NFTA_DUP_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_dup_ipv6_module_init(void)
+{
+	return nft_register_expr(&nft_dup_ipv6_type);
+}
+
+static void __exit nft_dup_ipv6_module_exit(void)
+{
+	nft_unregister_expr(&nft_dup_ipv6_type);
+}
+
+module_init(nft_dup_ipv6_module_init);
+module_exit(nft_dup_ipv6_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_AF_EXPR(AF_INET6, "dup");
-- 
1.7.10.4

