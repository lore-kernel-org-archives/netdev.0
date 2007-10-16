From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH 2/2] Interface group match - netfilter part
Date: Tue, 16 Oct 2007 10:01:42 +0200
Message-ID: <11925217031728-git-send-email-panther@balabit.hu>
References: <1192521703479-git-send-email-panther@balabit.hu>
 <11925217031287-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <11925217031287-git-send-email-panther@balabit.hu>
Message-Id: <661f8f2fdb86cc70bdefd12403ecb0eaa7cfadd6.1192460168.git.panther@balabit.hu>
In-Reply-To: <1824b3d462b1d85aaf33941cf082c4e018d5bff7.1192460167.git.panther@balabit.hu>
References: <1824b3d462b1d85aaf33941cf082c4e018d5bff7.1192460167.git.panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 include/linux/netfilter/xt_ifgroup.h |   11 +++++
 net/netfilter/Kconfig                |   16 +++++++
 net/netfilter/Makefile               |    1 +
 net/netfilter/xt_ifgroup.c           |   78 ++++++++++++++++++++++++++++++++++
 4 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_ifgroup.h b/include/linux/netfilter/xt_ifgroup.h
new file mode 100644
index 0000000..a992d4c
--- /dev/null
+++ b/include/linux/netfilter/xt_ifgroup.h
@@ -0,0 +1,11 @@
+#ifndef _XT_IFGROUP_H
+#define _XT_IFGROUP_H
+
+struct xt_ifgroup_info {
+	u_int32_t group;
+	u_int32_t mask;
+	u_int8_t invert;
+};
+
+#endif /*_XT_IFGROUP_H*/
+
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 3599770..0864e19 100644
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
index 0c054bf..da9ab07 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -77,3 +77,4 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_TCPMSS) += xt_tcpmss.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_U32) += xt_u32.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMIT) += xt_hashlimit.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_IFGROUP) += xt_ifgroup.o
diff --git a/net/netfilter/xt_ifgroup.c b/net/netfilter/xt_ifgroup.c
new file mode 100644
index 0000000..766f668
--- /dev/null
+++ b/net/netfilter/xt_ifgroup.c
@@ -0,0 +1,78 @@
+/*
+ * An x_tables match module to match interface groups
+ *
+ * (C) 2006 Balazs Scheidler <bazsi@balabit.hu>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+
+#include <linux/netfilter/xt_ifgroup.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Balazs Scheidler <bazsi@balabit.hu>");
+MODULE_DESCRIPTION("IP tables match to match on interface group");
+MODULE_ALIAS("ipt_ifgroup");
+MODULE_ALIAS("ip6t_ifgroup");
+
+static int match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const struct xt_match *match,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	const struct xt_ifgroup_info *info = matchinfo;
+
+	return ((in->ifgroup & info->mask) == info->group) ^ info->invert;
+}
+
+static struct xt_match ifgroup_match = {
+	.name		= "ifgroup",
+	.match		= match,
+	.matchsize	= sizeof(struct xt_ifgroup_info),
+	.family		= AF_INET,
+	.me		= THIS_MODULE,
+};
+
+static struct xt_match ifgroup6_match = {
+	.name		= "ifgroup",
+	.match		= match,
+	.matchsize	= sizeof(struct xt_ifgroup_info),
+	.family		= AF_INET6,
+	.me		= THIS_MODULE,
+};
+
+static int __init xt_ifgroup_init(void)
+{
+	int ret;
+
+	ret = xt_register_match(&ifgroup_match);
+	if (ret)
+		return ret;
+
+	ret = xt_register_match(&ifgroup6_match);
+	if (ret)
+		xt_unregister_match(&ifgroup_match);
+
+	return ret;
+}
+
+static void __exit xt_ifgroup_fini(void)
+{
+	xt_unregister_match(&ifgroup_match);
+	xt_unregister_match(&ifgroup6_match);
+}
+
+module_init(xt_ifgroup_init);
+module_exit(xt_ifgroup_fini);
+
-- 
1.5.2.5

