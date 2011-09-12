From: Florian Westphal <fw@strlen.de>
Subject: [RFC PATCH 3/5] netfilter: add ipv4 reverse path filter match
Date: Mon, 12 Sep 2011 21:42:30 +0200
Message-ID: <1315856552-1422-4-git-send-email-fw@strlen.de>
References: <1315856552-1422-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:58598 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754072Ab1ILToy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 15:44:54 -0400
In-Reply-To: <1315856552-1422-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tries to mimic behaviour of fib_validate_source.

As fib_validate_source uses the oif as iif when performing reverse
lookup, we would need one additional fib lookup to get oif.

We can't wait until FORWARD chain because by the time FORWARD is invoked
ipv4 forward path may have already sent icmp messages is response
to to-be-discarded-via-rpfilter packets.

To avoid the additional lookup in PREROUTING, Patrick McHardy suggested
to attach the path information directly in the match.

This has a few caveats. Most importantly, when using marks in PREROUTING to
re-route traffic based on the nfmark, -m rpfilter has to be used after the
nfmark has been set; otherwise the nfmark will have no effect (because
the route is already attached to the skb).

Another problem is interaction with -j TPROXY, as this
target sets an nfmark and uses ACCEPT instead of CONTINUE, i.e.
-m rpfilter cannot be used for the initial to-be-intercepted packets.

Also, no result caching so far.

Unlike the current builtin ipv4 rpfilter, packets subject to ipsec
transformation are not automatically excluded; if you want this
combine with policy match.

Packets arriving on loopback interfaces always match.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter/xt_rpfilter.h |   21 ++++
 net/ipv4/netfilter/Kconfig            |   10 ++
 net/ipv4/netfilter/Makefile           |    1 +
 net/ipv4/netfilter/ipt_rpfilter.c     |  165 +++++++++++++++++++++++++++++++++
 4 files changed, 197 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_rpfilter.h
 create mode 100644 net/ipv4/netfilter/ipt_rpfilter.c

diff --git a/include/linux/netfilter/xt_rpfilter.h b/include/linux/netfilter/xt_rpfilter.h
new file mode 100644
index 0000000..8d2d3f8
--- /dev/null
+++ b/include/linux/netfilter/xt_rpfilter.h
@@ -0,0 +1,21 @@
+#ifndef _XT_RPATH_H
+#define _XT_RPATH_H
+
+#include <linux/types.h>
+
+enum {
+	XT_RPFILTER_LOOSE = 1 << 0,
+	XT_RPFILTER_VALID_MARK = 1 << 1,
+	XT_RPFILTER_ACCEPT_LOCAL = 1 << 2,
+#ifdef __KERNEL__
+	XT_RPFILTER_OPTION_MASK = XT_RPFILTER_LOOSE |
+				  XT_RPFILTER_VALID_MARK |
+				  XT_RPFILTER_ACCEPT_LOCAL,
+#endif
+};
+
+struct xt_rpfilter_info {
+	__u8 flags;
+};
+
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1dfc18a..ef8c1ab 100644
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
index 0000000..14b5ff5
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -0,0 +1,165 @@
+/*
+ *  Copyright (c) 2011 Florian Westphal <fw@strlen.de>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License version 2 as
+ *  published by the Free Software Foundation.
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
+	struct rtable *rt;
+	int err;
+
+	if (par->in->flags & IFF_LOOPBACK)
+		return true;
+
+	iph = ip_hdr(skb);
+	if (!skb_dst(skb)) {
+		/*
+		 * This match will set skb dst, if it is unset.
+		 * Otherwise, the ipv4 stack would need to perform the same
+		 * lookup again.
+		 */
+		struct sk_buff *pskb;
+		pskb = (struct sk_buff *)skb;
+		err = ip_route_input_noref(pskb, iph->daddr, iph->saddr,
+					iph->tos, skb->dev);
+
+		if (unlikely(err)) {
+			ip_rcv_inc_route_err_stats(dev_net(skb->dev), err);
+			par->hotdrop = true;
+			return false;
+		}
+	}
+
+	info = par->matchinfo;
+	if (ipv4_is_multicast(iph->daddr)) {
+		if (ipv4_is_zeronet(iph->saddr))
+			return ipv4_is_local_multicast(iph->daddr);
+		flow.flowi4_iif = 0;
+		goto validate;
+	}
+
+	rt = skb_rtable(skb);
+	switch (rt->rt_type) {
+	case RTN_BROADCAST:
+		if (ipv4_is_zeronet(iph->saddr))
+			return true;
+		flow.flowi4_iif = 0;
+		break;
+	case RTN_LOCAL:
+		flow.flowi4_iif = dev_net(par->in)->loopback_dev->ifindex;
+		break;
+	default:
+		flow.flowi4_iif = rt->rt_oif;
+		break;
+	}
+
+ validate:
+	flow.daddr = iph->saddr;
+	flow.saddr = rpfilter_get_saddr(iph->daddr);
+	flow.flowi4_oif = 0;
+	flow.flowi4_mark = info->flags & XT_RPFILTER_VALID_MARK ? skb->mark : 0;
+	flow.flowi4_tos = RT_TOS(iph->tos);
+	flow.flowi4_scope = RT_SCOPE_UNIVERSE;
+
+	return rpfilter_lookup_reverse(&flow, par->in, info->flags);
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
1.7.3.4
