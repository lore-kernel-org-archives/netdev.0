From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next 5/6] net: ILA iptables target
Date: Wed, 3 Jun 2015 12:58:21 -0700
Message-ID: <1433361502-3478761-6-git-send-email-tom@herbertland.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <agartrell@fb.com>, <maheshb@google.com>,
	<tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:29531 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754785AbbFCT6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:58:52 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t53JuJq2031899
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2015 12:58:51 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ut795r7eu-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:58:51 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 f379c7fa0a2a11e5ba0e0002c992ebde-bf6bb6c0 for <netdev@vger.kernel.org>;	Wed,
 03 Jun 2015 12:58:49 -0700
In-Reply-To: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two target ILAIN and ILAOUT which hook into the ILA module.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/netfilter/Kconfig  | 11 +++++++
 net/netfilter/Makefile |  1 +
 net/netfilter/xt_ILA.c | 82 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 94 insertions(+)
 create mode 100644 net/netfilter/xt_ILA.c

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index fbc8d15..eaf7d68 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -748,6 +748,17 @@ config NETFILTER_XT_TARGET_IDLETIMER
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_ILA
+	tristate "ILA target support"
+	depends on IP_NF_MANGLE || IP6_NF_MANGLE
+	depends on NETFILTER_ADVANCED
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
index 70d026d..d99740a 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -124,6 +124,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) += xt_TCPOPTSTRIP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TEE) += xt_TEE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) += xt_TRACE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_ILA) += xt_ILA.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_ADDRTYPE) += xt_addrtype.o
diff --git a/net/netfilter/xt_ILA.c b/net/netfilter/xt_ILA.c
new file mode 100644
index 0000000..0d92c8f
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
+		.targetsize	= 32,
+		.table		= "mangle",
+		.hooks		= (1 << NF_INET_POST_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "ILAOUT",
+		.family		= NFPROTO_IPV6,
+		.checkentry	= ila_tg_check,
+		.target		= ila_tg_output,
+		.targetsize	= 32,
+		.table		= "mangle",
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
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
1.8.1
