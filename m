From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2] netfilter: add CHECKSUM target
Date: Sun, 11 Jul 2010 18:06:23 +0300
Message-ID: <20100711150623.GA7420__25715.3698629283$1278861159$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Randy Dunlap <randy.dunlap@ora
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451Ab0GKPLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 11:11:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a `CHECKSUM' target, which can be used in the iptables mangle
table.

You can use this target to compute and fill in the checksum in
a packet that lacks a checksum.  This is particularly useful,
if you need to work around old applications such as dhcp clients,
that do not work well with checksum offloads, but don't want to
disable checksum offload in your device.

The problem happens in the field with virtualized applications.
For reference, see Red Hat bz 605555, as well as
http://www.spinics.net/lists/kvm/msg37660.html

Typical expected use (helps old dhclient binary running in a VM):
iptables -A POSTROUTING -t mangle -p udp --dport bootpc \
	-j CHECKSUM --checksum-fill

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Changes from v1:
	moved from ipt to xt
	get rid of any ipv4 dependencies
	coding style tweaks

 include/linux/netfilter/xt_CHECKSUM.h |   18 ++++++++
 net/netfilter/Kconfig                 |   17 +++++++-
 net/netfilter/Makefile                |    1 +
 net/netfilter/xt_CHECKSUM.c           |   72 +++++++++++++++++++++++++++++++++
 4 files changed, 107 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/netfilter/xt_CHECKSUM.h
 create mode 100644 net/netfilter/xt_CHECKSUM.c

diff --git a/include/linux/netfilter/xt_CHECKSUM.h b/include/linux/netfilter/xt_CHECKSUM.h
new file mode 100644
index 0000000..56afe57
--- /dev/null
+++ b/include/linux/netfilter/xt_CHECKSUM.h
@@ -0,0 +1,18 @@
+/* Header file for iptables ipt_CHECKSUM target
+ *
+ * (C) 2002 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2010 Red Hat Inc
+ * Author: Michael S. Tsirkin <mst@redhat.com>
+ *
+ * This software is distributed under GNU GPL v2, 1991
+*/
+#ifndef _IPT_CHECKSUM_TARGET_H
+#define _IPT_CHECKSUM_TARGET_H
+
+#define XT_CHECKSUM_OP_FILL	0x01	/* fill in checksum in IP header */
+
+struct xt_CHECKSUM_info {
+	u_int8_t operation;	/* bitset of operations */
+};
+
+#endif /* _IPT_CHECKSUM_TARGET_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8593a77..1cf4852 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -294,7 +294,7 @@ endif # NF_CONNTRACK
 config NETFILTER_TPROXY
 	tristate "Transparent proxying support (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	depends on IP_NF_MANGLE
+	depends on IP_NF_MANGLE || IP6_NF_MANGLE
 	depends on NETFILTER_ADVANCED
 	help
 	  This option enables transparent proxying support, that is,
@@ -347,6 +347,21 @@ config NETFILTER_XT_CONNMARK
 
 comment "Xtables targets"
 
+config NETFILTER_XT_TARGET_CHECKSUM
+	tristate "CHECKSUM target support"
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This option adds a `CHECKSUM' target, which can be used in the iptables mangle
+	  table.  
+
+	  You can use this target to compute and fill in the checksum in
+	  a packet that lacks a checksum.  This is particularly useful,
+	  if you need to work around old applications such as dhcp clients,
+	  that do not work well with checksum offloads, but don't want to disable
+	  checksum offload in your device.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_CLASSIFY
 	tristate '"CLASSIFY" target support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 14e3a8f..8eb541d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
 
 # targets
+obj-$(CONFIG_NETFILTER_XT_TARGET_CHECKSUM) += xt_CHECKSUM.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
diff --git a/net/netfilter/xt_CHECKSUM.c b/net/netfilter/xt_CHECKSUM.c
new file mode 100644
index 0000000..0fee1a7
--- /dev/null
+++ b/net/netfilter/xt_CHECKSUM.c
@@ -0,0 +1,72 @@
+/* iptables module for the packet checksum mangling
+ *
+ * (C) 2002 by Harald Welte <laforge@netfilter.org>
+ * (C) 2010 Red Hat, Inc.
+ *
+ * Author: Michael S. Tsirkin <mst@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+*/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/in.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_CHECKSUM.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Michael S. Tsirkin <mst@redhat.com>");
+MODULE_DESCRIPTION("Xtables: checksum modification");
+MODULE_ALIAS("ipt_CHECKSUM");
+MODULE_ALIAS("ip6t_CHECKSUM");
+
+static unsigned int
+checksum_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		skb_checksum_help(skb);
+
+	return XT_CONTINUE;
+}
+
+static int checksum_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_CHECKSUM_info *einfo = par->targinfo;
+
+	if (einfo->operation & ~XT_CHECKSUM_OP_FILL) {
+		pr_info("unsupported CHECKSUM operation %x\n", einfo->operation);
+		return -EINVAL;
+	}
+	if (!einfo->operation) {
+		pr_info("no CHECKSUM operation enabled\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static struct xt_target checksum_tg_reg __read_mostly = {
+	.name		= "CHECKSUM",
+	.family		= NFPROTO_UNSPEC,
+	.target		= checksum_tg,
+	.targetsize	= sizeof(struct xt_CHECKSUM_info),
+	.table		= "mangle",
+	.checkentry	= checksum_tg_check,
+	.me		= THIS_MODULE,
+};
+
+static int __init checksum_tg_init(void)
+{
+	return xt_register_target(&checksum_tg_reg);
+}
+
+static void __exit checksum_tg_exit(void)
+{
+	xt_unregister_target(&checksum_tg_reg);
+}
+
+module_init(checksum_tg_init);
+module_exit(checksum_tg_exit);
-- 
1.7.2.rc0.14.g41c1c
