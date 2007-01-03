From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 10/10] iptables tproxy match
Date: Wed, 03 Jan 2007 17:38:58 +0100
Message-ID: <20070103163858.14635.7249.stgit@nienna.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Implements an iptables module which matches packets which have the
tproxy flag set, that is, packets diverted in the tproxy table.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 net/netfilter/Kconfig     |    9 +++++
 net/netfilter/Makefile    |    1 +
 net/netfilter/xt_tproxy.c |   77 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 87 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 1b853c3..76c6f14 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -559,6 +559,15 @@ config NETFILTER_XT_MATCH_QUOTA
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_MATCH_TPROXY
+	tristate '"tproxy" match support'
+	depends on NETFILTER_XTABLES
+	help
+	  This option adds a `tproxy' match, which allows you to match
+	  packets which have been diverted to local sockets by TProxy.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_REALM
 	tristate  '"realm" match support'
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 5dc5574..4a83585 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -62,6 +62,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_MARK) +=
 obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_POLICY) += xt_policy.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) += xt_pkttype.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_TPROXY) += xt_tproxy.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_QUOTA) += xt_quota.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_REALM) += xt_realm.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_SCTP) += xt_sctp.o
diff --git a/net/netfilter/xt_tproxy.c b/net/netfilter/xt_tproxy.c
new file mode 100644
index 0000000..53f8bee
--- /dev/null
+++ b/net/netfilter/xt_tproxy.c
@@ -0,0 +1,77 @@
+/*
+ * Transparent proxy support for Linux/iptables
+ *
+ * Copyright (c) 2007 BalaBit IT Ltd.
+ * Author: Krisztian Kovacs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter/x_tables.h>
+
+static int
+match(const struct sk_buff *skb,
+      const struct net_device *in,
+      const struct net_device *out,
+      const struct xt_match *match,
+      const void *matchinfo,
+      int offset,
+      unsigned int protoff,
+      int *hotdrop)
+{
+	return skb->ip_tproxy;
+}
+
+static int
+check(const char *tablename,
+      const void *entry,
+      const struct xt_match *match,
+      void *matchinfo,
+      unsigned int hook_mask)
+{
+	return 1;
+}
+
+static struct xt_match tproxy_matches[] = {
+	{
+		.name		= "tproxy",
+		.match		= match,
+		.matchsize	= 0,
+		.checkentry	= check,
+		.family		= AF_INET,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "tproxy",
+		.match		= match,
+		.matchsize	= 0,
+		.checkentry	= check,
+		.family		= AF_INET6,
+		.me		= THIS_MODULE,
+	},
+};
+
+static int __init xt_tproxy_init(void)
+{
+	return xt_register_matches(tproxy_matches, ARRAY_SIZE(tproxy_matches));
+}
+
+static void __exit xt_tproxy_fini(void)
+{
+	xt_unregister_matches(tproxy_matches, ARRAY_SIZE(tproxy_matches));
+}
+
+module_init(xt_tproxy_init);
+module_exit(xt_tproxy_fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs <hidden@balabit.hu>");
+MODULE_DESCRIPTION("iptables tproxy match module");
+MODULE_ALIAS("ipt_tproxy");
+MODULE_ALIAS("ip6t_tproxy");
