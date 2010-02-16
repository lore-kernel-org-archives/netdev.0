From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 30/62: xtables: add CT target
Date: Tue, 16 Feb 2010 15:56:00 +0100 (MET)
Message-ID: <20100216145558.2796.21343.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932495Ab0BPO4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:01 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 84f3bb9ae9db90f7fb15d98b55279a58ab1b2363
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 3 17:17:06 2010 +0100

    netfilter: xtables: add CT target
    
    Add a new target for the raw table, which can be used to specify conntrack
    parameters for specific connections, f.i. the conntrack helper.
    
    The target attaches a "template" connection tracking entry to the skb, which
    is used by the conntrack core when initializing a new conntrack.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 2aea503..a5a63e4 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -6,6 +6,7 @@ header-y += nfnetlink_queue.h
 header-y += xt_CLASSIFY.h
 header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
+header-y += xt_CT.h
 header-y += xt_DSCP.h
 header-y += xt_LED.h
 header-y += xt_MARK.h
diff --git a/include/linux/netfilter/xt_CT.h b/include/linux/netfilter/xt_CT.h
new file mode 100644
index 0000000..7fd0eff
--- /dev/null
+++ b/include/linux/netfilter/xt_CT.h
@@ -0,0 +1,17 @@
+#ifndef _XT_CT_H
+#define _XT_CT_H
+
+#define XT_CT_NOTRACK	0x1
+
+struct xt_ct_target_info {
+	u_int16_t	flags;
+	u_int16_t	__unused;
+	u_int32_t	ct_events;
+	u_int32_t	exp_events;
+	char		helper[16];
+
+	/* Used internally by the kernel */
+	struct nf_conn	*ct __attribute__((aligned(8)));
+};
+
+#endif /* _XT_CT_H */
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index e17aaa3..32c305d 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -42,6 +42,9 @@ struct nf_conntrack_helper {
 extern struct nf_conntrack_helper *
 __nf_conntrack_helper_find(const char *name, u16 l3num, u8 protonum);
 
+extern struct nf_conntrack_helper *
+nf_conntrack_helper_try_module_get(const char *name, u16 l3num, u8 protonum);
+
 extern int nf_conntrack_helper_register(struct nf_conntrack_helper *);
 extern void nf_conntrack_helper_unregister(struct nf_conntrack_helper *);
 
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 634d14a..4469d45 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -341,6 +341,18 @@ config NETFILTER_XT_TARGET_CONNSECMARK
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_CT
+	tristate '"CT" target support'
+	depends on NF_CONNTRACK
+	depends on IP_NF_RAW || IP6_NF_RAW
+	depends on NETFILTER_ADVANCED
+	help
+	  This options adds a `CT' target, which allows to specify initial
+	  connection tracking parameters like events to be delivered and
+	  the helper to be used.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_DSCP
 	tristate '"DSCP" and "TOS" target support'
 	depends on IP_NF_MANGLE || IP6_NF_MANGLE
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 49f62ee..f873644 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -44,6 +44,7 @@ obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMARK) += xt_CONNMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 8144b0d..a74a576 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -83,6 +83,25 @@ __nf_conntrack_helper_find(const char *name, u16 l3num, u8 protonum)
 }
 EXPORT_SYMBOL_GPL(__nf_conntrack_helper_find);
 
+struct nf_conntrack_helper *
+nf_conntrack_helper_try_module_get(const char *name, u16 l3num, u8 protonum)
+{
+	struct nf_conntrack_helper *h;
+
+	h = __nf_conntrack_helper_find(name, l3num, protonum);
+#ifdef CONFIG_MODULES
+	if (h == NULL) {
+		if (request_module("nfct-helper-%s", name) == 0)
+			h = __nf_conntrack_helper_find(name, l3num, protonum);
+	}
+#endif
+	if (h != NULL && !try_module_get(h->me))
+		h = NULL;
+
+	return h;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_helper_try_module_get);
+
 struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp)
 {
 	struct nf_conn_help *help;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
new file mode 100644
index 0000000..8183a05
--- /dev/null
+++ b/net/netfilter/xt_CT.c
@@ -0,0 +1,158 @@
+/*
+ * Copyright (c) 2010 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/selinux.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_CT.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_ecache.h>
+
+static unsigned int xt_ct_target(struct sk_buff *skb,
+				 const struct xt_target_param *par)
+{
+	const struct xt_ct_target_info *info = par->targinfo;
+	struct nf_conn *ct = info->ct;
+
+	/* Previously seen (loopback)? Ignore. */
+	if (skb->nfct != NULL)
+		return XT_CONTINUE;
+
+	atomic_inc(&ct->ct_general.use);
+	skb->nfct = &ct->ct_general;
+	skb->nfctinfo = IP_CT_NEW;
+
+	return XT_CONTINUE;
+}
+
+static u8 xt_ct_find_proto(const struct xt_tgchk_param *par)
+{
+	if (par->family == AF_INET) {
+		const struct ipt_entry *e = par->entryinfo;
+
+		if (e->ip.invflags & IPT_INV_PROTO)
+			return 0;
+		return e->ip.proto;
+	} else if (par->family == AF_INET6) {
+		const struct ip6t_entry *e = par->entryinfo;
+
+		if (e->ipv6.invflags & IP6T_INV_PROTO)
+			return 0;
+		return e->ipv6.proto;
+	} else
+		return 0;
+}
+
+static bool xt_ct_tg_check(const struct xt_tgchk_param *par)
+{
+	struct xt_ct_target_info *info = par->targinfo;
+	struct nf_conntrack_tuple t;
+	struct nf_conn_help *help;
+	struct nf_conn *ct;
+	u8 proto;
+
+	if (info->flags & ~XT_CT_NOTRACK)
+		return false;
+
+	if (info->flags & XT_CT_NOTRACK) {
+		ct = &nf_conntrack_untracked;
+		atomic_inc(&ct->ct_general.use);
+		goto out;
+	}
+
+	if (nf_ct_l3proto_try_module_get(par->family) < 0)
+		goto err1;
+
+	memset(&t, 0, sizeof(t));
+	ct = nf_conntrack_alloc(par->net, &t, &t, GFP_KERNEL);
+	if (IS_ERR(ct))
+		goto err2;
+
+	if ((info->ct_events || info->exp_events) &&
+	    !nf_ct_ecache_ext_add(ct, info->ct_events, info->exp_events,
+				  GFP_KERNEL))
+		goto err3;
+
+	if (info->helper[0]) {
+		proto = xt_ct_find_proto(par);
+		if (!proto)
+			goto err3;
+
+		help = nf_ct_helper_ext_add(ct, GFP_KERNEL);
+		if (help == NULL)
+			goto err3;
+
+		help->helper = nf_conntrack_helper_try_module_get(info->helper,
+								  par->family,
+								  proto);
+		if (help->helper == NULL)
+			goto err3;
+	}
+
+	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
+	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
+out:
+	info->ct = ct;
+	return true;
+
+err3:
+	nf_conntrack_free(ct);
+err2:
+	nf_ct_l3proto_module_put(par->family);
+err1:
+	return false;
+}
+
+static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	struct xt_ct_target_info *info = par->targinfo;
+	struct nf_conn *ct = info->ct;
+	struct nf_conn_help *help;
+
+	if (ct != &nf_conntrack_untracked) {
+		help = nfct_help(ct);
+		if (help)
+			module_put(help->helper->me);
+
+		nf_ct_l3proto_module_put(par->family);
+	}
+	nf_ct_put(info->ct);
+}
+
+static struct xt_target xt_ct_tg __read_mostly = {
+	.name		= "CT",
+	.family		= NFPROTO_UNSPEC,
+	.targetsize	= XT_ALIGN(sizeof(struct xt_ct_target_info)),
+	.checkentry	= xt_ct_tg_check,
+	.destroy	= xt_ct_tg_destroy,
+	.target		= xt_ct_target,
+	.table		= "raw",
+	.me		= THIS_MODULE,
+};
+
+static int __init xt_ct_tg_init(void)
+{
+	return xt_register_target(&xt_ct_tg);
+}
+
+static void __exit xt_ct_tg_exit(void)
+{
+	xt_unregister_target(&xt_ct_tg);
+}
+
+module_init(xt_ct_tg_init);
+module_exit(xt_ct_tg_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Xtables: connection tracking target");
+MODULE_ALIAS("ipt_CT");
+MODULE_ALIAS("ip6t_CT");
