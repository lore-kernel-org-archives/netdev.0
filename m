From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 1/2] netfilter: add xt_priority xtables match
Date: Wed,  5 Dec 2012 14:22:18 -0500
Message-ID: <1354735339-13402-2-git-send-email-willemb@google.com>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	edumazet@google.com, davem@davemloft.net, kaber@trash.net,
	pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:49213 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875Ab2LETWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 14:22:33 -0500
Received: by mail-yh0-f74.google.com with SMTP id 10so548331yhl.1
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 11:22:33 -0800 (PST)
In-Reply-To: <1354735339-13402-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an iptables match based on the skb->priority field. This field
can be set by socket option SO_PRIORITY, among others.

The match supports range based matching on packet priority, with
optional inversion. Before matching, a mask can be applied to the
priority field to handle the case where different regions of the
bitfield are reserved for unrelated uses.
---
 include/linux/netfilter/xt_priority.h |   13 ++++++++
 net/netfilter/Kconfig                 |    9 ++++++
 net/netfilter/Makefile                |    1 +
 net/netfilter/xt_priority.c           |   51 +++++++++++++++++++++++++++++++++
 4 files changed, 74 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_priority.h
 create mode 100644 net/netfilter/xt_priority.c

diff --git a/include/linux/netfilter/xt_priority.h b/include/linux/netfilter/xt_priority.h
new file mode 100644
index 0000000..da9a288
--- /dev/null
+++ b/include/linux/netfilter/xt_priority.h
@@ -0,0 +1,13 @@
+#ifndef _XT_PRIORITY_H
+#define _XT_PRIORITY_H
+
+#include <linux/types.h>
+
+struct xt_priority_info {
+	__u32 min;
+	__u32 max;
+	__u32 mask;
+	__u8  invert;
+};
+
+#endif /*_XT_PRIORITY_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index fefa514..c9739c6 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1093,6 +1093,15 @@ config NETFILTER_XT_MATCH_PKTTYPE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_MATCH_PRIORITY
+	tristate '"priority" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  This option adds a match based on the value of the sk_buff
+	  priority field.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_QUOTA
 	tristate '"quota" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 3259697..8e5602f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -124,6 +124,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) += xt_pkttype.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_POLICY) += xt_policy.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_PRIORITY) += xt_priority.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_QUOTA) += xt_quota.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_RATEEST) += xt_rateest.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_REALM) += xt_realm.o
diff --git a/net/netfilter/xt_priority.c b/net/netfilter/xt_priority.c
new file mode 100644
index 0000000..4982eee
--- /dev/null
+++ b/net/netfilter/xt_priority.c
@@ -0,0 +1,51 @@
+/* Xtables module to match packets based on their sk_buff priority field.
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
+
+#include <linux/netfilter/xt_priority.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_AUTHOR("Willem de Bruijn <willemb@google.com>");
+MODULE_DESCRIPTION("Xtables: priority filter match");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_priority");
+MODULE_ALIAS("ip6t_priority");
+
+static bool priority_mt(const struct sk_buff *skb,
+			struct xt_action_param *par)
+{
+	const struct xt_priority_info *info = par->matchinfo;
+
+	__u32 priority = skb->priority & info->mask;
+	return (priority >= info->min && priority <= info->max) ^ info->invert;
+}
+
+static struct xt_match priority_mt_reg __read_mostly = {
+	.name		= "priority",
+	.revision	= 0,
+	.family		= NFPROTO_UNSPEC,
+	.match		= priority_mt,
+	.matchsize	= sizeof(struct xt_priority_info),
+	.me		= THIS_MODULE,
+};
+
+static int __init priority_mt_init(void)
+{
+	return xt_register_match(&priority_mt_reg);
+}
+
+static void __exit priority_mt_exit(void)
+{
+	xt_unregister_match(&priority_mt_reg);
+}
+
+module_init(priority_mt_init);
+module_exit(priority_mt_exit);
-- 
1.7.7.3
