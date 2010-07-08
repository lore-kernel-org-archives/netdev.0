From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] netfilter: add CHECKSUM target
Date: Fri, 9 Jul 2010 01:29:13 +0300
Message-ID: <20100708222913.GA4475__36795.1585598805$1278628559$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pek
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755665Ab0GHWfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jul 2010 18:35:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a `CHECKSUM' target, which can be used in the iptables mangle
table.

You can use this target to compute and fill in the checksum in
an IP packet that lacks a checksum.  This is particularly useful,
if you need to work around old applications such as dhcp clients,
that do not work well with checksum offloads, but don't want to
disable checksum offload in your device.

The problem happens in the field with virtualized applications.
For reference, see Red Hat bz 605555, as well as
http://www.spinics.net/lists/kvm/msg37660.html

Typical expected use (helps old dhclient binary running in a VM):
iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM
--checksum-fill

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Lightly tested. Please review for 2.6.36. Thanks!

 include/linux/netfilter_ipv4/ipt_CHECKSUM.h |   18 +++++++
 net/ipv4/netfilter/Kconfig                  |   16 ++++++
 net/ipv4/netfilter/Makefile                 |    1 +
 net/ipv4/netfilter/ipt_CHECKSUM.c           |   72 +++++++++++++++++++++++++++
 4 files changed, 107 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter_ipv4/ipt_CHECKSUM.h
 create mode 100644 net/ipv4/netfilter/ipt_CHECKSUM.c

diff --git a/include/linux/netfilter_ipv4/ipt_CHECKSUM.h b/include/linux/netfilter_ipv4/ipt_CHECKSUM.h
new file mode 100644
index 0000000..0b0f660
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_CHECKSUM.h
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
+#define IPT_CHECKSUM_OP_FILL	0x01	/* fill in checksum in IPv4 header */
+
+struct ipt_CHECKSUM_info {
+	u_int8_t operation;	/* bitset of operations */
+};
+
+#endif /* _IPT_CHECKSUM_TARGET_H */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1833bdb..2fb979b 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -322,6 +322,22 @@ config IP_NF_TARGET_ECN
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_TARGET_CHECKSUM
+	tristate "CHECKSUM target support"
+	depends on IP_NF_MANGLE
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This option adds a `CHECKSUM' target, which can be used in the iptables mangle
+	  table.  
+
+	  You can use this target to compute and fill in the checksum in
+	  an IP packet that lacks a checksum.  This is particularly useful,
+	  if you need to work around old applications such as dhcp clients,
+	  that do not work well with checksum offloads, but don't want to disable
+	  checksum offload in your device.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config IP_NF_TARGET_TTL
 	tristate '"TTL" target support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 4811159..d7047bb 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_IP_NF_MATCH_ECN) += ipt_ecn.o
 # targets
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
 obj-$(CONFIG_IP_NF_TARGET_ECN) += ipt_ECN.o
+obj-$(CONFIG_IP_NF_TARGET_CHECKSUM) += ipt_CHECKSUM.o
 obj-$(CONFIG_IP_NF_TARGET_LOG) += ipt_LOG.o
 obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) += ipt_MASQUERADE.o
 obj-$(CONFIG_IP_NF_TARGET_NETMAP) += ipt_NETMAP.o
diff --git a/net/ipv4/netfilter/ipt_CHECKSUM.c b/net/ipv4/netfilter/ipt_CHECKSUM.c
new file mode 100644
index 0000000..b8346a1
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_CHECKSUM.c
@@ -0,0 +1,72 @@
+/* iptables module for the IPv4 CHECKSUM
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
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_CHECKSUM.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Michael S. Tsirkin <mst@redhat.com>");
+MODULE_DESCRIPTION("Xtables: checksum modification");
+
+static unsigned int
+checksum_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		skb_checksum_help(skb);
+	}
+
+	return XT_CONTINUE;
+}
+
+static int checksum_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct ipt_CHECKSUM_info *einfo = par->targinfo;
+
+	if (einfo->operation & ~IPT_CHECKSUM_OP_FILL) {
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
+	.family		= NFPROTO_IPV4,
+	.target		= checksum_tg,
+	.targetsize	= sizeof(struct ipt_CHECKSUM_info),
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
