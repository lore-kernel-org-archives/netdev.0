From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 13/13] iptables tproxy match
Date: Mon, 05 Mar 2007 16:47:02 +0100
Message-ID: <20070305154702.3471.25476.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:2883 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933550AbXCEPrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:47:05 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 05413294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:47:03 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
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
index 253fce3..b22346e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -603,6 +603,15 @@ config NETFILTER_XT_MATCH_QUOTA
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
index b2b5c75..83b2fd9 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -64,6 +64,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_MARK) += xt_mark.o
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

