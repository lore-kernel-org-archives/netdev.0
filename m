From: kaber@trash.net
Subject: [PATCH 13/26] netfilter: xtables: "set" match and "SET" target support
Date: Thu,  3 Feb 2011 00:11:51 +0100
Message-ID: <1296688324-7830-14-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The patch adds the combined module of the "SET" target and "set" match
to netfilter. Both the previous and the current revisions are supported.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_set.h |   55 ++++++
 net/netfilter/Kconfig            |   12 ++
 net/netfilter/Makefile           |    1 +
 net/netfilter/xt_set.c           |  359 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 427 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_set.h
 create mode 100644 net/netfilter/xt_set.c

diff --git a/include/linux/netfilter/xt_set.h b/include/linux/netfilter/xt_set.h
new file mode 100644
index 0000000..69b2bd1
--- /dev/null
+++ b/include/linux/netfilter/xt_set.h
@@ -0,0 +1,55 @@
+#ifndef _XT_SET_H
+#define _XT_SET_H
+
+#include <linux/netfilter/ipset/ip_set.h>
+
+/* Revision 0 interface: backward compatible with netfilter/iptables */
+
+/*
+ * Option flags for kernel operations (xt_set_info_v0)
+ */
+#define IPSET_SRC		0x01	/* Source match/add */
+#define IPSET_DST		0x02	/* Destination match/add */
+#define IPSET_MATCH_INV		0x04	/* Inverse matching */
+
+struct xt_set_info_v0 {
+	ip_set_id_t index;
+	union {
+		__u32 flags[IPSET_DIM_MAX + 1];
+		struct {
+			__u32 __flags[IPSET_DIM_MAX];
+			__u8 dim;
+			__u8 flags;
+		} compat;
+	} u;
+};
+
+/* match and target infos */
+struct xt_set_info_match_v0 {
+	struct xt_set_info_v0 match_set;
+};
+
+struct xt_set_info_target_v0 {
+	struct xt_set_info_v0 add_set;
+	struct xt_set_info_v0 del_set;
+};
+
+/* Revision 1: current interface to netfilter/iptables */
+
+struct xt_set_info {
+	ip_set_id_t index;
+	__u8 dim;
+	__u8 flags;
+};
+
+/* match and target infos */
+struct xt_set_info_match {
+	struct xt_set_info match_set;
+};
+
+struct xt_set_info_target {
+	struct xt_set_info add_set;
+	struct xt_set_info del_set;
+};
+
+#endif /*_XT_SET_H*/
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 351abf8..06fa9e4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -352,6 +352,18 @@ config NETFILTER_XT_CONNMARK
 	ctmark), similarly to the packet mark (nfmark). Using this
 	target and match, you can set and match on this mark.
 
+config NETFILTER_XT_SET
+	tristate 'set target and match support'
+	depends on IP_SET
+	depends on NETFILTER_ADVANCED
+	help
+	  This option adds the "SET" target and "set" match.
+
+	  Using this target and match, you can add/delete and match
+	  elements in the sets created by ipset(8).
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 # alphabetically ordered list of targets
 
 comment "Xtables targets"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 510b586..1148643 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 # combos
 obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
+obj-$(CONFIG_NETFILTER_XT_SET) += xt_set.o
 
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_AUDIT) += xt_AUDIT.o
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
new file mode 100644
index 0000000..061d48c
--- /dev/null
+++ b/net/netfilter/xt_set.c
@@ -0,0 +1,359 @@
+/* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
+ *                         Patrick Schaaf <bof@bof.de>
+ *                         Martin Josefsson <gandalf@wlug.westbo.se>
+ * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/* Kernel module which implements the set match and SET target
+ * for netfilter/iptables. */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/version.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_set.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
+MODULE_DESCRIPTION("Xtables: IP set match and target module");
+MODULE_ALIAS("xt_SET");
+MODULE_ALIAS("ipt_set");
+MODULE_ALIAS("ip6t_set");
+MODULE_ALIAS("ipt_SET");
+MODULE_ALIAS("ip6t_SET");
+
+static inline int
+match_set(ip_set_id_t index, const struct sk_buff *skb,
+	  u8 pf, u8 dim, u8 flags, int inv)
+{
+	if (ip_set_test(index, skb, pf, dim, flags))
+		inv = !inv;
+	return inv;
+}
+
+/* Revision 0 interface: backward compatible with netfilter/iptables */
+
+static bool
+set_match_v0(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_set_info_match_v0 *info = par->matchinfo;
+
+	return match_set(info->match_set.index, skb, par->family,
+			 info->match_set.u.compat.dim,
+			 info->match_set.u.compat.flags,
+			 info->match_set.u.compat.flags & IPSET_INV_MATCH);
+}
+
+static void
+compat_flags(struct xt_set_info_v0 *info)
+{
+	u_int8_t i;
+
+	/* Fill out compatibility data according to enum ip_set_kopt */
+	info->u.compat.dim = IPSET_DIM_ZERO;
+	if (info->u.flags[0] & IPSET_MATCH_INV)
+		info->u.compat.flags |= IPSET_INV_MATCH;
+	for (i = 0; i < IPSET_DIM_MAX-1 && info->u.flags[i]; i++) {
+		info->u.compat.dim++;
+		if (info->u.flags[i] & IPSET_SRC)
+			info->u.compat.flags |= (1<<info->u.compat.dim);
+	}
+}
+
+static int
+set_match_v0_checkentry(const struct xt_mtchk_param *par)
+{
+	struct xt_set_info_match_v0 *info = par->matchinfo;
+	ip_set_id_t index;
+
+	index = ip_set_nfnl_get_byindex(info->match_set.index);
+
+	if (index == IPSET_INVALID_ID) {
+		pr_warning("Cannot find set indentified by id %u to match\n",
+			   info->match_set.index);
+		return -ENOENT;
+	}
+	if (info->match_set.u.flags[IPSET_DIM_MAX-1] != 0) {
+		pr_warning("Protocol error: set match dimension "
+			   "is over the limit!\n");
+		return -ERANGE;
+	}
+
+	/* Fill out compatibility data */
+	compat_flags(&info->match_set);
+
+	return 0;
+}
+
+static void
+set_match_v0_destroy(const struct xt_mtdtor_param *par)
+{
+	struct xt_set_info_match_v0 *info = par->matchinfo;
+
+	ip_set_nfnl_put(info->match_set.index);
+}
+
+static unsigned int
+set_target_v0(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_set_info_target_v0 *info = par->targinfo;
+
+	if (info->add_set.index != IPSET_INVALID_ID)
+		ip_set_add(info->add_set.index, skb, par->family,
+			   info->add_set.u.compat.dim,
+			   info->add_set.u.compat.flags);
+	if (info->del_set.index != IPSET_INVALID_ID)
+		ip_set_del(info->del_set.index, skb, par->family,
+			   info->del_set.u.compat.dim,
+			   info->del_set.u.compat.flags);
+
+	return XT_CONTINUE;
+}
+
+static int
+set_target_v0_checkentry(const struct xt_tgchk_param *par)
+{
+	struct xt_set_info_target_v0 *info = par->targinfo;
+	ip_set_id_t index;
+
+	if (info->add_set.index != IPSET_INVALID_ID) {
+		index = ip_set_nfnl_get_byindex(info->add_set.index);
+		if (index == IPSET_INVALID_ID) {
+			pr_warning("Cannot find add_set index %u as target\n",
+				   info->add_set.index);
+			return -ENOENT;
+		}
+	}
+
+	if (info->del_set.index != IPSET_INVALID_ID) {
+		index = ip_set_nfnl_get_byindex(info->del_set.index);
+		if (index == IPSET_INVALID_ID) {
+			pr_warning("Cannot find del_set index %u as target\n",
+				   info->del_set.index);
+			return -ENOENT;
+		}
+	}
+	if (info->add_set.u.flags[IPSET_DIM_MAX-1] != 0 ||
+	    info->del_set.u.flags[IPSET_DIM_MAX-1] != 0) {
+		pr_warning("Protocol error: SET target dimension "
+			   "is over the limit!\n");
+		return -ERANGE;
+	}
+
+	/* Fill out compatibility data */
+	compat_flags(&info->add_set);
+	compat_flags(&info->del_set);
+
+	return 0;
+}
+
+static void
+set_target_v0_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct xt_set_info_target_v0 *info = par->targinfo;
+
+	if (info->add_set.index != IPSET_INVALID_ID)
+		ip_set_nfnl_put(info->add_set.index);
+	if (info->del_set.index != IPSET_INVALID_ID)
+		ip_set_nfnl_put(info->del_set.index);
+}
+
+/* Revision 1: current interface to netfilter/iptables */
+
+static bool
+set_match(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_set_info_match *info = par->matchinfo;
+
+	return match_set(info->match_set.index, skb, par->family,
+			 info->match_set.dim,
+			 info->match_set.flags,
+			 info->match_set.flags & IPSET_INV_MATCH);
+}
+
+static int
+set_match_checkentry(const struct xt_mtchk_param *par)
+{
+	struct xt_set_info_match *info = par->matchinfo;
+	ip_set_id_t index;
+
+	index = ip_set_nfnl_get_byindex(info->match_set.index);
+
+	if (index == IPSET_INVALID_ID) {
+		pr_warning("Cannot find set indentified by id %u to match\n",
+			   info->match_set.index);
+		return -ENOENT;
+	}
+	if (info->match_set.dim > IPSET_DIM_MAX) {
+		pr_warning("Protocol error: set match dimension "
+			   "is over the limit!\n");
+		return -ERANGE;
+	}
+
+	return 0;
+}
+
+static void
+set_match_destroy(const struct xt_mtdtor_param *par)
+{
+	struct xt_set_info_match *info = par->matchinfo;
+
+	ip_set_nfnl_put(info->match_set.index);
+}
+
+static unsigned int
+set_target(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_set_info_target *info = par->targinfo;
+
+	if (info->add_set.index != IPSET_INVALID_ID)
+		ip_set_add(info->add_set.index,
+			   skb, par->family,
+			   info->add_set.dim,
+			   info->add_set.flags);
+	if (info->del_set.index != IPSET_INVALID_ID)
+		ip_set_del(info->del_set.index,
+			   skb, par->family,
+			   info->add_set.dim,
+			   info->del_set.flags);
+
+	return XT_CONTINUE;
+}
+
+static int
+set_target_checkentry(const struct xt_tgchk_param *par)
+{
+	const struct xt_set_info_target *info = par->targinfo;
+	ip_set_id_t index;
+
+	if (info->add_set.index != IPSET_INVALID_ID) {
+		index = ip_set_nfnl_get_byindex(info->add_set.index);
+		if (index == IPSET_INVALID_ID) {
+			pr_warning("Cannot find add_set index %u as target\n",
+				   info->add_set.index);
+			return -ENOENT;
+		}
+	}
+
+	if (info->del_set.index != IPSET_INVALID_ID) {
+		index = ip_set_nfnl_get_byindex(info->del_set.index);
+		if (index == IPSET_INVALID_ID) {
+			pr_warning("Cannot find del_set index %u as target\n",
+				   info->del_set.index);
+			return -ENOENT;
+		}
+	}
+	if (info->add_set.dim > IPSET_DIM_MAX ||
+	    info->del_set.flags > IPSET_DIM_MAX) {
+		pr_warning("Protocol error: SET target dimension "
+			   "is over the limit!\n");
+		return -ERANGE;
+	}
+
+	return 0;
+}
+
+static void
+set_target_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct xt_set_info_target *info = par->targinfo;
+
+	if (info->add_set.index != IPSET_INVALID_ID)
+		ip_set_nfnl_put(info->add_set.index);
+	if (info->del_set.index != IPSET_INVALID_ID)
+		ip_set_nfnl_put(info->del_set.index);
+}
+
+static struct xt_match set_matches[] __read_mostly = {
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV4,
+		.revision	= 0,
+		.match		= set_match_v0,
+		.matchsize	= sizeof(struct xt_set_info_match_v0),
+		.checkentry	= set_match_v0_checkentry,
+		.destroy	= set_match_v0_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV4,
+		.revision	= 1,
+		.match		= set_match,
+		.matchsize	= sizeof(struct xt_set_info_match),
+		.checkentry	= set_match_checkentry,
+		.destroy	= set_match_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV6,
+		.revision	= 1,
+		.match		= set_match,
+		.matchsize	= sizeof(struct xt_set_info_match),
+		.checkentry	= set_match_checkentry,
+		.destroy	= set_match_destroy,
+		.me		= THIS_MODULE
+	},
+};
+
+static struct xt_target set_targets[] __read_mostly = {
+	{
+		.name		= "SET",
+		.revision	= 0,
+		.family		= NFPROTO_IPV4,
+		.target		= set_target_v0,
+		.targetsize	= sizeof(struct xt_set_info_target_v0),
+		.checkentry	= set_target_v0_checkentry,
+		.destroy	= set_target_v0_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "SET",
+		.revision	= 1,
+		.family		= NFPROTO_IPV4,
+		.target		= set_target,
+		.targetsize	= sizeof(struct xt_set_info_target),
+		.checkentry	= set_target_checkentry,
+		.destroy	= set_target_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "SET",
+		.revision	= 1,
+		.family		= NFPROTO_IPV6,
+		.target		= set_target,
+		.targetsize	= sizeof(struct xt_set_info_target),
+		.checkentry	= set_target_checkentry,
+		.destroy	= set_target_destroy,
+		.me		= THIS_MODULE
+	},
+};
+
+static int __init xt_set_init(void)
+{
+	int ret = xt_register_matches(set_matches, ARRAY_SIZE(set_matches));
+
+	if (!ret) {
+		ret = xt_register_targets(set_targets,
+					  ARRAY_SIZE(set_targets));
+		if (ret)
+			xt_unregister_matches(set_matches,
+					      ARRAY_SIZE(set_matches));
+	}
+	return ret;
+}
+
+static void __exit xt_set_fini(void)
+{
+	xt_unregister_matches(set_matches, ARRAY_SIZE(set_matches));
+	xt_unregister_targets(set_targets, ARRAY_SIZE(set_targets));
+}
+
+module_init(xt_set_init);
+module_exit(xt_set_fini);
-- 
1.7.2.3

