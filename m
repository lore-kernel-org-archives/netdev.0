From: pablo@netfilter.org
Subject: [PATCH 02/19] netfilter: add ipv4 reverse path filter match
Date: Sun, 25 Dec 2011 02:57:18 +0100
Message-ID: <1324778255-2830-3-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55985 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757975Ab1LYB54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:57:56 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This tries to do the same thing as fib_validate_source(), but differs
in several aspects.

The most important difference is that the reverse path filter built into
fib_validate_source uses the oif as iif when performing the reverse
lookup.  We do not do this, as the oif is not yet known by the time the
PREROUTING hook is invoked.

We can't wait until FORWARD chain because by the time FORWARD is invoked
ipv4 forward path may have already sent icmp messages is response
to to-be-discarded-via-rpfilter packets.

To avoid the such an additional lookup in PREROUTING, Patrick McHardy
suggested to attach the path information directly in the match
(i.e., just do what the standard ipv4 path does a bit earlier in PREROUTING).

This works, but it also has a few caveats. Most importantly, when using
marks in PREROUTING to re-route traffic based on the nfmark, -m rpfilter
would have to be used after the nfmark has been set; otherwise the nfmark
would have no effect (because the route is already attached).

Another problem would be interaction with -j TPROXY, as this target sets an
nfmark and uses ACCEPT instead of continue, i.e. such a version of
-m rpfilter cannot be used for the initial to-be-intercepted packets.

In case in turns out that the oif is required, we can add Patricks
suggestion with a new match option (e.g. --rpf-use-oif) to keep ruleset
compatibility.

Another difference to current builtin ipv4 rpfilter is that packets subject to ipsec
transformation are not automatically excluded. If you want this, simply
combine -m rpfilter with the policy match.

Packets arriving on loopback interfaces always match.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_rpfilter.h |   23 ++++++
 net/ipv4/netfilter/Kconfig            |   10 +++
 net/ipv4/netfilter/Makefile           |    1 +
 net/ipv4/netfilter/ipt_rpfilter.c     |  141 +++++++++++++++++++++++++++++++++
 4 files changed, 175 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_rpfilter.h
 create mode 100644 net/ipv4/netfilter/ipt_rpfilter.c

diff --git a/include/linux/netfilter/xt_rpfilter.h b/include/linux/netfilter/xt_rpfilter.h
new file mode 100644
index 0000000..8358d4f
--- /dev/null
+++ b/include/linux/netfilter/xt_rpfilter.h
@@ -0,0 +1,23 @@
+#ifndef _XT_RPATH_H
+#define _XT_RPATH_H
+
+#include <linux/types.h>
+
+enum {
+	XT_RPFILTER_LOOSE = 1 << 0,
+	XT_RPFILTER_VALID_MARK = 1 << 1,
+	XT_RPFILTER_ACCEPT_LOCAL = 1 << 2,
+	XT_RPFILTER_INVERT = 1 << 3,
+#ifdef __KERNEL__
+	XT_RPFILTER_OPTION_MASK = XT_RPFILTER_LOOSE |
+				  XT_RPFILTER_VALID_MARK |
+				  XT_RPFILTER_ACCEPT_LOCAL |
+				  XT_RPFILTER_INVERT,
+#endif
+};
+
+struct xt_rpfilter_info {
+	__u8 flags;
+};
+
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index f19f218..7e1f5cd 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -82,6 +82,16 @@ config IP_NF_MATCH_ECN
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_MATCH_RPFILTER
+	tristate '"rpfilter" reverse path filter match support'
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This option allows you to match packets whose replies would
+	  go out via the interface the packet came in.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+	  The module will be called ipt_rpfilter.
+
 config IP_NF_MATCH_TTL
 	tristate '"ttl" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index dca2082..123dd88 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_IP_NF_SECURITY) += iptable_security.o
 # matches
 obj-$(CONFIG_IP_NF_MATCH_AH) += ipt_ah.o
 obj-$(CONFIG_IP_NF_MATCH_ECN) += ipt_ecn.o
+obj-$(CONFIG_IP_NF_MATCH_RPFILTER) += ipt_rpfilter.o
 
 # targets
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
new file mode 100644
index 0000000..31371be
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -0,0 +1,141 @@
+/*
+ * Copyright (c) 2011 Florian Westphal <fw@strlen.de>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * based on fib_frontend.c; Author: Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/ip.h>
+#include <net/ip.h>
+#include <net/ip_fib.h>
+#include <net/route.h>
+
+#include <linux/netfilter/xt_rpfilter.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Florian Westphal <fw@strlen.de>");
+MODULE_DESCRIPTION("iptables: ipv4 reverse path filter match");
+
+/* don't try to find route from mcast/bcast/zeronet */
+static __be32 rpfilter_get_saddr(__be32 addr)
+{
+	if (ipv4_is_multicast(addr) || ipv4_is_lbcast(addr) ||
+	    ipv4_is_zeronet(addr))
+		return 0;
+	return addr;
+}
+
+static bool rpfilter_lookup_reverse(struct flowi4 *fl4,
+				const struct net_device *dev, u8 flags)
+{
+	struct fib_result res;
+	bool dev_match;
+	struct net *net = dev_net(dev);
+	int ret __maybe_unused;
+
+	if (fib_lookup(net, fl4, &res))
+		return false;
+
+	if (res.type != RTN_UNICAST) {
+		if (res.type != RTN_LOCAL || !(flags & XT_RPFILTER_ACCEPT_LOCAL))
+			return false;
+	}
+	dev_match = false;
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	for (ret = 0; ret < res.fi->fib_nhs; ret++) {
+		struct fib_nh *nh = &res.fi->fib_nh[ret];
+
+		if (nh->nh_dev == dev) {
+			dev_match = true;
+			break;
+		}
+	}
+#else
+	if (FIB_RES_DEV(res) == dev)
+		dev_match = true;
+#endif
+	if (dev_match || flags & XT_RPFILTER_LOOSE)
+		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;
+	return dev_match;
+}
+
+static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_rpfilter_info *info;
+	const struct iphdr *iph;
+	struct flowi4 flow;
+	bool invert;
+
+	info = par->matchinfo;
+	invert = info->flags & XT_RPFILTER_INVERT;
+
+	if (par->in->flags & IFF_LOOPBACK)
+		return true ^ invert;
+
+	iph = ip_hdr(skb);
+	if (ipv4_is_multicast(iph->daddr)) {
+		if (ipv4_is_zeronet(iph->saddr))
+			return ipv4_is_local_multicast(iph->daddr) ^ invert;
+		flow.flowi4_iif = 0;
+	} else {
+		flow.flowi4_iif = dev_net(par->in)->loopback_dev->ifindex;
+	}
+
+	flow.daddr = iph->saddr;
+	flow.saddr = rpfilter_get_saddr(iph->daddr);
+	flow.flowi4_oif = 0;
+	flow.flowi4_mark = info->flags & XT_RPFILTER_VALID_MARK ? skb->mark : 0;
+	flow.flowi4_tos = RT_TOS(iph->tos);
+	flow.flowi4_scope = RT_SCOPE_UNIVERSE;
+
+	return rpfilter_lookup_reverse(&flow, par->in, info->flags) ^ invert;
+}
+
+static int rpfilter_check(const struct xt_mtchk_param *par)
+{
+	const struct xt_rpfilter_info *info = par->matchinfo;
+	unsigned int options = ~XT_RPFILTER_OPTION_MASK;
+	if (info->flags & options) {
+		pr_info("unknown options encountered");
+		return -EINVAL;
+	}
+
+	if (strcmp(par->table, "mangle") != 0 &&
+	    strcmp(par->table, "raw") != 0) {
+		pr_info("match only valid in the \'raw\' "
+			"or \'mangle\' tables, not \'%s\'.\n", par->table);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static struct xt_match rpfilter_mt_reg __read_mostly = {
+	.name		= "rpfilter",
+	.family		= NFPROTO_IPV4,
+	.checkentry	= rpfilter_check,
+	.match		= rpfilter_mt,
+	.matchsize	= sizeof(struct xt_rpfilter_info),
+	.hooks		= (1 << NF_INET_PRE_ROUTING),
+	.me		= THIS_MODULE
+};
+
+static int __init rpfilter_mt_init(void)
+{
+	return xt_register_match(&rpfilter_mt_reg);
+}
+
+static void __exit rpfilter_mt_exit(void)
+{
+	xt_unregister_match(&rpfilter_mt_reg);
+}
+
+module_init(rpfilter_mt_init);
+module_exit(rpfilter_mt_exit);
-- 
1.7.2.5
