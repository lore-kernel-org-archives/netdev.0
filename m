From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 5/5] Netfilter Interface group match
Date: Thu, 29 Nov 2007 17:11:46 +0100
Message-ID: <11963527102332-git-send-email-panther@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu>
 <11963527103201-git-send-email-panther@balabit.hu>
 <1196352710402-git-send-email-panther@balabit.hu>
 <11963527101876-git-send-email-panther@balabit.hu>
 <11963527103391-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50910 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756460AbXK2QLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:11:55 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 1BD4FC1481
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 17:11:54 +0100 (CET)
In-Reply-To: <11963527103391-git-send-email-panther@balabit.hu>
In-Reply-To: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
References: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interface group values can be checked on both input and output interfaces.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---

 include/linux/netfilter/xt_ifgroup.h |   17 +++++
 net/netfilter/Kconfig                |   10 +++
 net/netfilter/Makefile               |    1 
 net/netfilter/xt_ifgroup.c           |  120 ++++++++++++++++++++++++++++++++++
 4 files changed, 148 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_ifgroup.h b/include/linux/netfilter/xt_ifgroup.h
new file mode 100644
index 0000000..3aa4d61
--- /dev/null
+++ b/include/linux/netfilter/xt_ifgroup.h
@@ -0,0 +1,17 @@
+#ifndef _XT_IFGROUP_H
+#define _XT_IFGROUP_H
+
+#define XT_IFGROUP_INVERT_IN	0x01
+#define XT_IFGROUP_INVERT_OUT	0x02
+#define XT_IFGROUP_MATCH_IN	0x04
+#define XT_IFGROUP_MATCH_OUT	0x08
+
+struct xt_ifgroup_info {
+	u_int32_t in_group;
+	u_int32_t in_mask;
+	u_int32_t out_group;
+	u_int32_t out_mask;
+	u_int8_t flags;
+};
+
+#endif /*_XT_IFGROUP_H*/
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 21a9fcc..07ee4a7 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -508,6 +508,16 @@ config NETFILTER_XT_MATCH_HELPER
 
 	  To compile it as a module, choose M here.  If unsure, say Y.
 
+config NETFILTER_XT_MATCH_IFGROUP
+	tristate '"ifgroup" interface group match support'
+	depends on NETFILTER_XTABLES
+	help
+	  Interface group matching allows you to match a packet by
+	  its incoming interface "group", settable using ip link set
+	  group
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_LENGTH
 	tristate '"length" match support'
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index ad0e36e..5107c86 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -61,6 +61,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_DSCP) += xt_dscp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_ESP) += xt_esp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMIT) += xt_hashlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HELPER) += xt_helper.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_IFGROUP) += xt_ifgroup.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
diff --git a/net/netfilter/xt_ifgroup.c b/net/netfilter/xt_ifgroup.c
new file mode 100644
index 0000000..712ee54
--- /dev/null
+++ b/net/netfilter/xt_ifgroup.c
@@ -0,0 +1,120 @@
+/*
+ * An x_tables match module to match interface groups
+ *
+ * (C) 2006,2007 Balazs Scheidler <bazsi@balabit.hu>,
+ *   Laszlo Attila Toth <panther@balabit.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter/xt_ifgroup.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Laszlo Attila Toth <panther@balabit.hu>");
+MODULE_DESCRIPTION("Xtables interface group matching module");
+MODULE_ALIAS("ipt_ifgroup");
+MODULE_ALIAS("ip6t_ifgroup");
+
+
+static inline bool
+ifgroup_match_in(const struct net_device *in,
+		 const struct xt_ifgroup_info *info)
+{
+	return ((in->ifgroup & info->in_mask) == info->in_group) ^
+		((info->flags & XT_IFGROUP_INVERT_IN) == XT_IFGROUP_INVERT_IN);
+}
+
+static inline bool
+ifgroup_match_out(const struct net_device *out,
+		 const struct xt_ifgroup_info *info)
+{
+	return ((out->ifgroup & info->out_mask) == info->out_group) ^
+		((info->flags & XT_IFGROUP_INVERT_OUT) == XT_IFGROUP_INVERT_OUT);
+}
+
+static bool
+ifgroup_match(const struct sk_buff *skb,
+	     const struct net_device *in,
+	     const struct net_device *out,
+	     const struct xt_match *match,
+	     const void *matchinfo,
+	     int offset,
+	     unsigned int protoff,
+	     bool *hotdrop)
+{
+	const struct xt_ifgroup_info *info = matchinfo;
+	
+	if (info->flags & XT_IFGROUP_MATCH_IN && !ifgroup_match_in(in, info))
+		return false;
+	if (info->flags & XT_IFGROUP_MATCH_OUT && !ifgroup_match_out(out, info))
+		return false;
+	
+	return true;
+}
+
+static bool ifgroup_checkentry(const char *tablename, const void *ip_void,
+			       const struct xt_match *match,
+			       void *matchinfo, unsigned int hook_mask)
+{
+	struct xt_ifgroup_info *info = matchinfo;
+
+	if (!(info->flags & (XT_IFGROUP_MATCH_IN|XT_IFGROUP_MATCH_OUT))) {
+		printk(KERN_ERR "xt_ifgroup: neither incoming nor "
+				"outgoing device selected\n");
+		return false;
+	}
+	if (hook_mask & (1 << NF_INET_PRE_ROUTING | 1 << NF_INET_LOCAL_IN)
+	    && info->flags & XT_IFGROUP_MATCH_OUT) {
+		printk(KERN_ERR "xt_ifgroup: output device not valid in "
+				"PRE_ROUTING and INPUT\n");
+		return false;
+	}
+	if (hook_mask & (1 << NF_INET_POST_ROUTING | 1 << NF_INET_LOCAL_OUT)
+	    && info->flags & XT_IFGROUP_MATCH_IN) {
+		printk(KERN_ERR "xt_ifgroup: input device not valid in "
+				"POST_ROUTING and OUTPUT\n");
+		return false;
+	}
+	return true;
+}
+
+static struct xt_match xt_ifgroup_match[] __read_mostly  = {
+	{
+		.name		= "ifgroup",
+		.match		= ifgroup_match,
+		.checkentry	= ifgroup_checkentry,
+		.matchsize	= sizeof(struct xt_ifgroup_info),
+		.family		= AF_INET,
+		.me		= THIS_MODULE,
+	
+	},
+	{
+		.name		= "ifgroup",
+		.match		= ifgroup_match,
+		.checkentry	= ifgroup_checkentry,
+		.matchsize	= sizeof(struct xt_ifgroup_info),
+		.family		= AF_INET6,
+		.me		= THIS_MODULE,
+	},
+};
+
+static int __init xt_ifgroup_init(void)
+{
+	return xt_register_matches(xt_ifgroup_match,
+			ARRAY_SIZE(xt_ifgroup_match));
+}
+
+static void __exit xt_ifgroup_fini(void)
+{
+	xt_unregister_matches(xt_ifgroup_match,
+			ARRAY_SIZE(xt_ifgroup_match));
+}
+
+module_init(xt_ifgroup_init);
+module_exit(xt_ifgroup_fini);
