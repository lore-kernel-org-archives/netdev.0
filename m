From: kaber@trash.net
Subject: [PATCH 14/28] netfilter: add xt_cpu match
Date: Mon,  2 Aug 2010 21:57:31 +0200
Message-ID: <1280779065-9333-15-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35367 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840Ab0HBT6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:58:00 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

In some situations a CPU match permits a better spreading of
connections, or select targets only for a given cpu.

With Remote Packet Steering or multiqueue NIC and appropriate IRQ
affinities, we can distribute trafic on available cpus, per session.
(all RX packets for a given flow is handled by a given cpu)

Some legacy applications being not SMP friendly, one way to scale a
server is to run multiple copies of them.

Instead of randomly choosing an instance, we can use the cpu number as a
key so that softirq handler for a whole instance is running on a single
cpu, maximizing cache effects in TCP/UDP stacks.

Using NAT for example, a four ways machine might run four copies of
server application, using a separate listening port for each instance,
but still presenting an unique external port :

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 0 \
        -j REDIRECT --to-port 8080

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 1 \
        -j REDIRECT --to-port 8081

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 2 \
        -j REDIRECT --to-port 8082

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 3 \
        -j REDIRECT --to-port 8083

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/Kbuild   |    3 +-
 include/linux/netfilter/xt_cpu.h |   11 ++++++
 net/netfilter/Kconfig            |    9 +++++
 net/netfilter/Makefile           |    1 +
 net/netfilter/xt_cpu.c           |   63 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 86 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/netfilter/xt_cpu.h
 create mode 100644 net/netfilter/xt_cpu.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 0cb62c8..edeeabd 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -20,12 +20,13 @@ header-y += xt_TCPMSS.h
 header-y += xt_TCPOPTSTRIP.h
 header-y += xt_TEE.h
 header-y += xt_TPROXY.h
+header-y += xt_cluster.h
 header-y += xt_comment.h
 header-y += xt_connbytes.h
 header-y += xt_connlimit.h
 header-y += xt_connmark.h
 header-y += xt_conntrack.h
-header-y += xt_cluster.h
+header-y += xt_cpu.h
 header-y += xt_dccp.h
 header-y += xt_dscp.h
 header-y += xt_esp.h
diff --git a/include/linux/netfilter/xt_cpu.h b/include/linux/netfilter/xt_cpu.h
new file mode 100644
index 0000000..93c7f11
--- /dev/null
+++ b/include/linux/netfilter/xt_cpu.h
@@ -0,0 +1,11 @@
+#ifndef _XT_CPU_H
+#define _XT_CPU_H
+
+#include <linux/types.h>
+
+struct xt_cpu_info {
+	__u32	cpu;
+	__u32	invert;
+};
+
+#endif /*_XT_CPU_H*/
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 551b584..4328825 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -663,6 +663,15 @@ config NETFILTER_XT_MATCH_CONNTRACK
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_MATCH_CPU
+	tristate '"cpu" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  CPU matching allows you to match packets based on the CPU
+	  currently handling the packet.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_DCCP
 	tristate '"dccp" protocol match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 4366c79..441050f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -70,6 +70,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLIMIT) += xt_connlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNTRACK) += xt_conntrack.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CPU) += xt_cpu.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_DCCP) += xt_dccp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_DSCP) += xt_dscp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_ESP) += xt_esp.o
diff --git a/net/netfilter/xt_cpu.c b/net/netfilter/xt_cpu.c
new file mode 100644
index 0000000..b39db8a
--- /dev/null
+++ b/net/netfilter/xt_cpu.c
@@ -0,0 +1,63 @@
+/* Kernel module to match running CPU */
+
+/*
+ * Might be used to distribute connections on several daemons, if
+ * RPS (Remote Packet Steering) is enabled or NIC is multiqueue capable,
+ * each RX queue IRQ affined to one CPU (1:1 mapping)
+ *
+ */
+
+/* (C) 2010 Eric Dumazet
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/xt_cpu.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Eric Dumazet <eric.dumazet@gmail.com>");
+MODULE_DESCRIPTION("Xtables: CPU match");
+
+static int cpu_mt_check(const struct xt_mtchk_param *par)
+{
+	const struct xt_cpu_info *info = par->matchinfo;
+
+	if (info->invert & ~1)
+		return -EINVAL;
+	return 0;
+}
+
+static bool cpu_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_cpu_info *info = par->matchinfo;
+
+	return (info->cpu == smp_processor_id()) ^ info->invert;
+}
+
+static struct xt_match cpu_mt_reg __read_mostly = {
+	.name       = "cpu",
+	.revision   = 0,
+	.family     = NFPROTO_UNSPEC,
+	.checkentry = cpu_mt_check,
+	.match      = cpu_mt,
+	.matchsize  = sizeof(struct xt_cpu_info),
+	.me         = THIS_MODULE,
+};
+
+static int __init cpu_mt_init(void)
+{
+	return xt_register_match(&cpu_mt_reg);
+}
+
+static void __exit cpu_mt_exit(void)
+{
+	xt_unregister_match(&cpu_mt_reg);
+}
+
+module_init(cpu_mt_init);
+module_exit(cpu_mt_exit);
-- 
1.7.1

