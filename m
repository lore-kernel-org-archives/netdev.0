From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 5/5] net: ILA iptables target
Date: Wed, 2 Dec 2015 14:13:28 -0800
Message-ID: <1449094408-2963234-6-git-send-email-tom@herbertland.com>
References: <1449094408-2963234-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55482 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756523AbbLBWNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 17:13:42 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tB2M9eoW015658
	for <netdev@vger.kernel.org>; Wed, 2 Dec 2015 14:13:41 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1yhu1xc3jm-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 14:13:41 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 f1647194994111e5bff124be0595f910-121fa230 for <netdev@vger.kernel.org>;	Wed,
 02 Dec 2015 14:13:40 -0800
In-Reply-To: <1449094408-2963234-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two target ILAIN and ILAOUT which hook into the ILA module.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/netfilter/Kconfig  | 12 ++++++++
 net/netfilter/Makefile |  1 +
 net/netfilter/xt_ILA.c | 82 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 95 insertions(+)
 create mode 100644 net/netfilter/xt_ILA.c

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 4692782..62ae50f 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -749,6 +749,18 @@ config NETFILTER_XT_TARGET_IDLETIMER
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_ILA
+	tristate "ILA target support"
+	depends on IP_NF_MANGLE || IP6_NF_MANGLE
+	depends on NETFILTER_ADVANCED
+	depends on IPV6_ILA
+	help
+	  This option adds an `ILA' target, which allow Identifier Locator
+	  Addressing (ILA) translations. The ILA tables are managed by the
+	  ILA module.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_LED
 	tristate '"LED" target support'
 	depends on LEDS_CLASS && LEDS_TRIGGERS
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7638c36..4fc16aa 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -122,6 +122,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) += xt_TCPOPTSTRIP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TEE) += xt_TEE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) += xt_TRACE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_ILA) += xt_ILA.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_ADDRTYPE) += xt_addrtype.o
diff --git a/net/netfilter/xt_ILA.c b/net/netfilter/xt_ILA.c
new file mode 100644
index 0000000..9b01e2e
--- /dev/null
+++ b/net/netfilter/xt_ILA.c
@@ -0,0 +1,82 @@
+/* x_tables module for Identifier Locator Addressing (ILA) translation
+ *
+ * (C) 2015 by Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <net/ila.h>
+
+#include <linux/netfilter/x_tables.h>
+
+MODULE_AUTHOR("Tom Herbert <tom@herbertland.com>");
+MODULE_DESCRIPTION("Xtables: ILA translation");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ip6t_ILA");
+MODULE_ALIAS("ip6t_ILAIN");
+MODULE_ALIAS("ip6t_ILAOUT");
+
+static unsigned int
+ila_tg_input(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	ila_xlat_incoming(skb);
+
+	return XT_CONTINUE;
+}
+
+static unsigned int
+ila_tg_output(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	ila_xlat_outgoing(skb);
+
+	return XT_CONTINUE;
+}
+
+static int ila_tg_check(const struct xt_tgchk_param *par)
+{
+	return 0;
+}
+
+static struct xt_target ila_tg_reg[] __read_mostly = {
+	{
+		.name		= "ILAIN",
+		.family		= NFPROTO_IPV6,
+		.checkentry	= ila_tg_check,
+		.target		= ila_tg_input,
+		.targetsize	= 0,
+		.table		= "mangle",
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "ILAOUT",
+		.family		= NFPROTO_IPV6,
+		.checkentry	= ila_tg_check,
+		.target		= ila_tg_output,
+		.targetsize	= 0,
+		.table		= "mangle",
+		.hooks		= (1 << NF_INET_POST_ROUTING) |
+				  (1 << NF_INET_LOCAL_OUT),
+		.me		= THIS_MODULE,
+	},
+};
+
+static int __init ila_tg_init(void)
+{
+	return xt_register_targets(ila_tg_reg, ARRAY_SIZE(ila_tg_reg));
+}
+
+static void __exit ila_tg_exit(void)
+{
+	xt_unregister_targets(ila_tg_reg, ARRAY_SIZE(ila_tg_reg));
+}
+
+module_init(ila_tg_init);
+module_exit(ila_tg_exit);
-- 
2.4.6
