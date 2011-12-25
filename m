From: pablo@netfilter.org
Subject: [PATCH 19/19] netfilter: xtables: add nfacct match to support extended accounting
Date: Sun, 25 Dec 2011 02:57:35 +0100
Message-ID: <1324778255-2830-20-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56039 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758055Ab1LYB6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:58:19 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the match that allows to perform extended
accounting. It requires the new nfnetlink_acct infrastructure.

 # iptables -I INPUT -p tcp --sport 80 -m nfacct --nfacct-name http-traffic
 # iptables -I OUTPUT -p tcp --dport 80 -m nfacct --nfacct-name http-traffic

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/Kbuild      |    1 +
 include/linux/netfilter/xt_nfacct.h |   13 ++++++
 net/netfilter/Kconfig               |   10 +++++
 net/netfilter/Makefile              |    1 +
 net/netfilter/xt_nfacct.c           |   76 +++++++++++++++++++++++++++++++++++
 5 files changed, 101 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_nfacct.h
 create mode 100644 net/netfilter/xt_nfacct.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 6785246..e630a2e 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -23,6 +23,7 @@ header-y += xt_DSCP.h
 header-y += xt_IDLETIMER.h
 header-y += xt_LED.h
 header-y += xt_MARK.h
+header-y += xt_nfacct.h
 header-y += xt_NFLOG.h
 header-y += xt_NFQUEUE.h
 header-y += xt_RATEEST.h
diff --git a/include/linux/netfilter/xt_nfacct.h b/include/linux/netfilter/xt_nfacct.h
new file mode 100644
index 0000000..3e19c8a
--- /dev/null
+++ b/include/linux/netfilter/xt_nfacct.h
@@ -0,0 +1,13 @@
+#ifndef _XT_NFACCT_MATCH_H
+#define _XT_NFACCT_MATCH_H
+
+#include <linux/netfilter/nfnetlink_acct.h>
+
+struct nf_acct;
+
+struct xt_nfacct_match_info {
+	char		name[NFACCT_NAME_MAX];
+	struct nf_acct	*nfacct;
+};
+
+#endif /* _XT_NFACCT_MATCH_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 77326ac..bac93ba 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -887,6 +887,16 @@ config NETFILTER_XT_MATCH_MULTIPORT
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_MATCH_NFACCT
+	tristate '"nfacct" match support'
+	default m if NETFILTER_ADVANCED=n
+	select NETFILTER_NETLINK_ACCT
+	help
+	  This option allows you to use the extended accounting through
+	  nfnetlink_acct.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_OSF
 	tristate '"osf" Passive OS fingerprint match'
 	depends on NETFILTER_ADVANCED && NETFILTER_NETLINK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 4da1c87..b2eee4d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -91,6 +91,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_NFACCT) += xt_nfacct.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
diff --git a/net/netfilter/xt_nfacct.c b/net/netfilter/xt_nfacct.c
new file mode 100644
index 0000000..b3be0ef
--- /dev/null
+++ b/net/netfilter/xt_nfacct.c
@@ -0,0 +1,76 @@
+/*
+ * (C) 2011 Pablo Neira Ayuso <pablo@netfilter.org>
+ * (C) 2011 Intra2net AG <http://www.intra2net.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 (or any
+ * later at your option) as published by the Free Software Foundation.
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/nfnetlink_acct.h>
+#include <linux/netfilter/xt_nfacct.h>
+
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_DESCRIPTION("Xtables: match for the extended accounting infrastructure");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_nfacct");
+MODULE_ALIAS("ip6t_nfacct");
+
+static bool nfacct_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_nfacct_match_info *info = par->targinfo;
+
+	nfnl_acct_update(skb, info->nfacct);
+
+	return true;
+}
+
+static int
+nfacct_mt_checkentry(const struct xt_mtchk_param *par)
+{
+	struct xt_nfacct_match_info *info = par->matchinfo;
+	struct nf_acct *nfacct;
+
+	nfacct = nfnl_acct_find_get(info->name);
+	if (nfacct == NULL) {
+		pr_info("xt_nfacct: accounting object with name `%s' "
+			"does not exists\n", info->name);
+		return -ENOENT;
+	}
+	info->nfacct = nfacct;
+	return 0;
+}
+
+static void
+nfacct_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	const struct xt_nfacct_match_info *info = par->matchinfo;
+
+	nfnl_acct_put(info->nfacct);
+}
+
+static struct xt_match nfacct_mt_reg __read_mostly = {
+	.name       = "nfacct",
+	.family     = NFPROTO_UNSPEC,
+	.checkentry = nfacct_mt_checkentry,
+	.match      = nfacct_mt,
+	.destroy    = nfacct_mt_destroy,
+	.matchsize  = sizeof(struct xt_nfacct_match_info),
+	.me         = THIS_MODULE,
+};
+
+static int __init nfacct_mt_init(void)
+{
+	return xt_register_match(&nfacct_mt_reg);
+}
+
+static void __exit nfacct_mt_exit(void)
+{
+	xt_unregister_match(&nfacct_mt_reg);
+}
+
+module_init(nfacct_mt_init);
+module_exit(nfacct_mt_exit);
-- 
1.7.2.5
