From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH nf-next-2.6] netfilter: add xt_cpu match
Date: Thu, 22 Jul 2010 16:03:05 +0200
Message-ID: <1279807385.2467.67.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34174 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759345Ab0GVODK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 10:03:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This match is a bit strange, being packet content agnostic...

Still, in some situations a CPU match permits a better spreading of
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
---
 include/linux/netfilter/Kbuild   |    1 
 include/linux/netfilter/xt_cpu.h |    8 +++
 net/netfilter/Kconfig            |    9 ++++
 net/netfilter/Makefile           |    1 
 net/netfilter/xt_cpu.c           |   65 +++++++++++++++++++++++++++++
 5 files changed, 84 insertions(+)

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index bb103f4..5c39a56 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -34,6 +34,7 @@ header-y += xt_helper.h
 header-y += xt_length.h
 header-y += xt_limit.h
 header-y += xt_mac.h
+header-y += xt_cpu.h
 header-y += xt_mark.h
 header-y += xt_multiport.h
 header-y += xt_osf.h
diff --git a/include/linux/netfilter/xt_cpu.h b/include/linux/netfilter/xt_cpu.h
index e69de29..fdf4202 100644
--- a/include/linux/netfilter/xt_cpu.h
+++ b/include/linux/netfilter/xt_cpu.h
@@ -0,0 +1,8 @@
+#ifndef _XT_CPU_H
+#define _XT_CPU_H
+
+struct xt_cpu_info {
+	unsigned int	cpu;
+	int		invert;
+};
+#endif /*_XT_MAC_H*/
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index aa2f106..85b07bd 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -754,6 +754,15 @@ config NETFILTER_XT_MATCH_MAC
 
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
 config NETFILTER_XT_MATCH_MARK
 	tristate '"mark" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index e28420a..0fe7efd 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -79,6 +79,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) += xt_iprange.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CPU) += xt_cpu.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o
diff --git a/net/netfilter/xt_cpu.c b/net/netfilter/xt_cpu.c
index e69de29..23d5a76 100644
--- a/net/netfilter/xt_cpu.c
+++ b/net/netfilter/xt_cpu.c
@@ -0,0 +1,65 @@
+/* Kernel module to match running CPU */
+
+/*
+ * Might be used to distribute connections on several daemons, if
+ * RPS (Remote Packet Steering) is enabled or NIC is multiqueue capable,
+ * each RX queue IRQ affined to one CPU (1:1 mapping)
+ *
+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 0 -j REDIRECT --to-port 8080
+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 1 -j REDIRECT --to-port 8081
+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 2 -j REDIRECT --to-port 8082
+ * iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 3 -j REDIRECT --to-port 8083
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
+/*
+ * Yes, packet content is not interesting for us, we only take care
+ * of cpu handling this packet
+ */
+static bool cpu_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_cpu_info *info = par->matchinfo;
+	bool ret;
+
+	ret = info->cpu == smp_processor_id();
+	ret ^= info->invert;
+	return ret;
+}
+
+static struct xt_match cpu_mt_reg __read_mostly = {
+	.name      = "cpu",
+	.revision  = 0,
+	.family    = NFPROTO_UNSPEC,
+	.match     = cpu_mt,
+	.matchsize = sizeof(struct xt_cpu_info),
+	.me        = THIS_MODULE,
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


