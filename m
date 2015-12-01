From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v2 5/5] net: ILA iptables target
Date: Tue, 1 Dec 2015 15:11:12 -0800
Message-ID: <1449011472-1459652-6-git-send-email-tom@herbertland.com>
References: <1449011472-1459652-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17015 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932409AbbLAXLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 18:11:40 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tB1NBe0m026476
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2015 15:11:40 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1yf8tgnk0p-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 15:11:40 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 dff72800988011e5b28124be0593f280-73ffc230 for <netdev@vger.kernel.org>;	Tue,
 01 Dec 2015 15:11:38 -0800
In-Reply-To: <1449011472-1459652-1-git-send-email-tom@herbertland.com>
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
