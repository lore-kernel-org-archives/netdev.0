From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 2/2] netfilter: add xt_bpf xtables match
Date: Wed,  5 Dec 2012 14:22:19 -0500
Message-ID: <1354735339-13402-3-git-send-email-willemb@google.com>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	edumazet@google.com, davem@davemloft.net, kaber@trash.net,
	pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:51706 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767Ab2LETWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 14:22:37 -0500
Received: by mail-vc0-f202.google.com with SMTP id m8so571267vcd.1
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 11:22:35 -0800 (PST)
In-Reply-To: <1354735339-13402-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new match that executes sk_run_filter on every packet. BPF filters
can access skbuff fields that are out of scope for existing iptables
rules, allow more expressive logic, and on platforms with JIT support
can even be faster.

I have a corresponding iptables patch that takes `tcpdump -ddd`
output, as used in the examples below. The two parts communicate
using a variable length structure. This is similar to ebt_among,
but new for iptables.

Verified functionality by inserting an ip source filter on chain
INPUT and an ip dest filter on chain OUTPUT and noting that ping
failed while a rule was active:

iptables -v -A INPUT -m bpf --bytecode '4,32 0 0 12,21 0 1 $SADDR,6 0 0 96,6 0 0 0,' -j DROP
iptables -v -A OUTPUT -m bpf --bytecode '4,32 0 0 16,21 0 1 $DADDR,6 0 0 96,6 0 0 0,' -j DROP

Evaluated throughput by running netperf TCP_STREAM over loopback on
x86_64. I expected the BPF filter to outperform hardcoded iptables
filters when replacing multiple matches with a single bpf match, but
even a single comparison to u32 appears to do better. Relative to the
benchmark with no filter applied, rate with 100 BPF filters dropped
to 81%. With 100 U32 filters it dropped to 55%. The difference sounds
excessive to me, but was consistent on my hardware. Commands used:

for i in `seq 100`; do iptables -A OUTPUT -m bpf --bytecode '4,48 0 0 9,21 0 1 20,6 0 0 96,6 0 0 0,' -j DROP; done
for i in `seq 3`; do netperf -t TCP_STREAM -I 99 -H localhost; done

iptables -F OUTPUT

for i in `seq 100`; do iptables -A OUTPUT -m u32 --u32 '6&0xFF=0x20' -j DROP; done
for i in `seq 3`; do netperf -t TCP_STREAM -I 99 -H localhost; done

FYI: perf top

[bpf]
    33.94%  [kernel]          [k] copy_user_generic_string
     8.92%  [kernel]          [k] sk_run_filter
     7.77%  [ip_tables]       [k] ipt_do_table

[u32]
    22.63%  [kernel]          [k] copy_user_generic_string
    14.46%  [kernel]          [k] memcpy
     9.19%  [ip_tables]       [k] ipt_do_table
     8.47%  [xt_u32]          [k] u32_mt
     5.32%  [kernel]          [k] skb_copy_bits

The big difference appears to be in memory copying. I have not
looked into u32, so cannot explain this right now. More interestingly,
at higher rate, sk_run_filter appears to use as many cycles as u32_mt
(both traces have roughly the same number of events).

One caveat: to work independent of device link layer, the filter
expects DLT_RAW style BPF programs, i.e., those that expect the
packet to start at the IP layer.
---
 include/linux/netfilter/xt_bpf.h |   17 +++++++
 net/netfilter/Kconfig            |    9 ++++
 net/netfilter/Makefile           |    1 +
 net/netfilter/x_tables.c         |    5 +-
 net/netfilter/xt_bpf.c           |   88 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 118 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/netfilter/xt_bpf.h
 create mode 100644 net/netfilter/xt_bpf.c

diff --git a/include/linux/netfilter/xt_bpf.h b/include/linux/netfilter/xt_bpf.h
new file mode 100644
index 0000000..23502c0
--- /dev/null
+++ b/include/linux/netfilter/xt_bpf.h
@@ -0,0 +1,17 @@
+#ifndef _XT_BPF_H
+#define _XT_BPF_H
+
+#include <linux/filter.h>
+#include <linux/types.h>
+
+struct xt_bpf_info {
+	__u16 bpf_program_num_elem;
+
+	/* only used in kernel */
+	struct sk_filter *filter __attribute__((aligned(8)));
+
+	/* variable size, based on program_num_elem */
+	struct sock_filter bpf_program[0];
+};
+
+#endif /*_XT_BPF_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c9739c6..c7cc0b8 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -798,6 +798,15 @@ config NETFILTER_XT_MATCH_ADDRTYPE
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_MATCH_BPF
+	tristate '"bpf" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  BPF matching applies a linux socket filter to each packet and
+          accepts those for which the filter returns non-zero.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_CLUSTER
 	tristate '"cluster" match support'
 	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 8e5602f..9f12eeb 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -98,6 +98,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_ADDRTYPE) += xt_addrtype.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_BPF) += xt_bpf.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8d987c3..26306be 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -379,8 +379,9 @@ int xt_check_match(struct xt_mtchk_param *par,
 	if (XT_ALIGN(par->match->matchsize) != size &&
 	    par->match->matchsize != -1) {
 		/*
-		 * ebt_among is exempt from centralized matchsize checking
-		 * because it uses a dynamic-size data set.
+		 * matches of variable size length, such as ebt_among,
+		 * are exempt from centralized matchsize checking. They
+		 * skip the test by setting xt_match.matchsize to -1.
 		 */
 		pr_err("%s_tables: %s.%u match: invalid size "
 		       "%u (kernel) != (user) %u\n",
diff --git a/net/netfilter/xt_bpf.c b/net/netfilter/xt_bpf.c
new file mode 100644
index 0000000..07077c5
--- /dev/null
+++ b/net/netfilter/xt_bpf.c
@@ -0,0 +1,88 @@
+/* Xtables module to match packets using a BPF filter.
+ * Copyright 2012 Google Inc.
+ * Written by Willem de Bruijn <willemb@google.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ipv6.h>
+#include <linux/filter.h>
+#include <net/ip.h>
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
+	const struct xt_entry_match *match;
+	struct sock_fprog program;
+	int expected_len;
+
+	match = container_of(par->matchinfo, const struct xt_entry_match, data);
+	expected_len = sizeof(struct xt_entry_match) +
+		       sizeof(struct xt_bpf_info) +
+		       (sizeof(struct sock_filter) *
+			info->bpf_program_num_elem);
+
+	if (match->u.match_size != expected_len) {
+		pr_info("bpf: check failed: incorrect length\n");
+		return -EINVAL;
+	}
+
+	program.len = info->bpf_program_num_elem;
+	program.filter = info->bpf_program;
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
+	.matchsize	= -1, /* skip xt_check_match because of dynamic len */
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
1.7.7.3
