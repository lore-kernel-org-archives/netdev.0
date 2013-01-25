From: pablo@netfilter.org
Subject: [PATCH 06/21] netfilter: x_tables: add xt_bpf match
Date: Fri, 25 Jan 2013 14:54:38 +0100
Message-ID: <1359122093-3404-7-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60274 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932348Ab3AYNzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 08:55:09 -0500
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support arbitrary linux socket filter (BPF) programs as x_tables
match rules. This allows for very expressive filters, and on
platforms with BPF JIT appears competitive with traditional
hardcoded iptables rules using the u32 match.

The size of the filter has been artificially limited to 64
instructions maximum to avoid bloating the size of each rule
using this new match.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_bpf.h |   17 ++++++++
 net/netfilter/Kconfig                 |    9 ++++
 net/netfilter/Makefile                |    1 +
 net/netfilter/xt_bpf.c                |   73 +++++++++++++++++++++++++++++++++
 4 files changed, 100 insertions(+)
 create mode 100644 include/uapi/linux/netfilter/xt_bpf.h
 create mode 100644 net/netfilter/xt_bpf.c

diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
new file mode 100644
index 0000000..5dda450
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_bpf.h
@@ -0,0 +1,17 @@
+#ifndef _XT_BPF_H
+#define _XT_BPF_H
+
+#include <linux/filter.h>
+#include <linux/types.h>
+
+#define XT_BPF_MAX_NUM_INSTR	64
+
+struct xt_bpf_info {
+	__u16 bpf_program_num_elem;
+	struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR];
+
+	/* only used in the kernel */
+	struct sk_filter *filter __attribute__((aligned(8)));
+};
+
+#endif /*_XT_BPF_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index bb48607..eb2c8eb 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -811,6 +811,15 @@ config NETFILTER_XT_MATCH_ADDRTYPE
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_MATCH_BPF
+	tristate '"bpf" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  BPF matching applies a linux socket filter to each packet and
+	  accepts those for which the filter returns non-zero.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_CLUSTER
 	tristate '"cluster" match support'
 	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index b3bbda6..a1abf87 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -99,6 +99,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_ADDRTYPE) += xt_addrtype.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_BPF) += xt_bpf.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
diff --git a/net/netfilter/xt_bpf.c b/net/netfilter/xt_bpf.c
new file mode 100644
index 0000000..12d4da8
--- /dev/null
+++ b/net/netfilter/xt_bpf.c
@@ -0,0 +1,73 @@
+/* Xtables module to match packets using a BPF filter.
+ * Copyright 2013 Google Inc.
+ * Written by Willem de Bruijn <willemb@google.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/filter.h>
+
+#include <linux/netfilter/xt_bpf.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_AUTHOR("Willem de Bruijn <willemb@google.com>");
+MODULE_DESCRIPTION("Xtables: BPF filter match");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_bpf");
+MODULE_ALIAS("ip6t_bpf");
+
+static int bpf_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_bpf_info *info = par->matchinfo;
+	struct sock_fprog program;
+
+	program.len = info->bpf_program_num_elem;
+	program.filter = (struct sock_filter __user *) info->bpf_program;
+	if (sk_unattached_filter_create(&info->filter, &program)) {
+		pr_info("bpf: check failed: parse error\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static bool bpf_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_bpf_info *info = par->matchinfo;
+
+	return SK_RUN_FILTER(info->filter, skb);
+}
+
+static void bpf_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	const struct xt_bpf_info *info = par->matchinfo;
+	sk_unattached_filter_destroy(info->filter);
+}
+
+static struct xt_match bpf_mt_reg __read_mostly = {
+	.name		= "bpf",
+	.revision	= 0,
+	.family		= NFPROTO_UNSPEC,
+	.checkentry	= bpf_mt_check,
+	.match		= bpf_mt,
+	.destroy	= bpf_mt_destroy,
+	.matchsize	= sizeof(struct xt_bpf_info),
+	.me		= THIS_MODULE,
+};
+
+static int __init bpf_mt_init(void)
+{
+	return xt_register_match(&bpf_mt_reg);
+}
+
+static void __exit bpf_mt_exit(void)
+{
+	xt_unregister_match(&bpf_mt_reg);
+}
+
+module_init(bpf_mt_init);
+module_exit(bpf_mt_exit);
-- 
1.7.10.4
