From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv5 3/3] Netfilter Interface group match
Date: Fri, 26 Oct 2007 14:30:32 +0200
Message-ID: <11934018354079-git-send-email-panther@balabit.hu>
References: <11934018353825-git-send-email-panther@balabit.hu>
 <11934018354072-git-send-email-panther@balabit.hu>
 <11934018353320-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50187 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbXJZMaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 08:30:46 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id EA5CDC1197
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 14:30:44 +0200 (CEST)
In-Reply-To: <11934018353320-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interface group values can be checked on both input and output interfaces.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 include/linux/netfilter/xt_ifgroup.h |   18 +++++
 net/netfilter/Kconfig                |   16 +++++
 net/netfilter/Makefile               |    1 +
 net/netfilter/xt_ifgroup.c           |  120 ++++++++++++++++++++++++++++++++++
 4 files changed, 155 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_ifgroup.h b/include/linux/netfilter/xt_ifgroup.h
new file mode 100644
index 0000000..9ac75de
--- /dev/null
+++ b/include/linux/netfilter/xt_ifgroup.h
@@ -0,0 +1,18 @@
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
+
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index d7a600a..0e0cd4f 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -597,6 +597,22 @@ config NETFILTER_XT_MATCH_QUOTA
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_MATCH_IFGROUP
+	tristate '"ifgroup" interface group match support'
+	depends on NETFILTER_XTABLES
+	help
+	  Interface group matching allows you to match a packet by
+	  its incoming interface "group", settable using ip link set
+	  group
+
+	  Typical usage is to assign dynamic interfaces to a group
+	  when they come up using "ip link set group" and then match
+	  incoming packets with a rule like this:
+
+	    iptables -A INPUT -m ifgroup --if-group openvpn-rw1 -j LOG
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_REALM
 	tristate  '"realm" match support'
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 93c58f9..29718c1 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -78,3 +78,4 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_TCPMSS) += xt_tcpmss.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_U32) += xt_u32.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMIT) += xt_hashlimit.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_IFGROUP) += xt_ifgroup.o
diff --git a/net/netfilter/xt_ifgroup.c b/net/netfilter/xt_ifgroup.c
new file mode 100644
index 0000000..e0e1fbf
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
+	if (hook_mask & (1 << NF_IP_PRE_ROUTING | 1 << NF_IP_LOCAL_IN)
+	    && info->flags & XT_IFGROUP_MATCH_OUT) {
+		printk(KERN_ERR "xt_ifgroup: output device not valid in "
+				"PRE_ROUTING and INPUT\n");
+		return false;
+	}
+	if (hook_mask & (1 << NF_IP_POST_ROUTING | 1 << NF_IP_LOCAL_OUT)
+	    && info->flags & XT_IFGROUP_MATCH_IN) {
+		printk(KERN_ERR "xt_ifgroup: input device not valid in "
+				"POST_ROUTING and OUTPUT\n");
+		return false;
+	}
+	return true;
+}
+
+static struct xt_match xt_ifgroup_match[] __read_mostly  = {
+        {
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
+		                   ARRAY_SIZE(xt_ifgroup_match));
+}
+
+static void __exit xt_ifgroup_fini(void)
+{
+	xt_unregister_matches(xt_ifgroup_match,
+			      ARRAY_SIZE(xt_ifgroup_match));
+}
+
+module_init(xt_ifgroup_init);
+module_exit(xt_ifgroup_fini);
-- 
1.5.2.5

