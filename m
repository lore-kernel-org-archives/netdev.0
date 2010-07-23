From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iptables] extension: add xt_cpu match
Date: Fri, 23 Jul 2010 15:43:41 +0200
Message-ID: <1279892621.2481.53.camel@edumazet-laptop>
References: <1279807385.2467.67.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>
	 <1279811939.2467.79.camel@edumazet-laptop>  <4C497644.7050201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43618 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab0GWNnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 09:43:45 -0400
In-Reply-To: <4C497644.7050201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick,

Here is iptables extension for xt_cpu match.

I put same changelog than kernel one, tell me if its ok or not ;)

Thanks

[PATCH iptables] extension: add xt_cpu match

Kernel 2.6.36 supports xt_cpu match

In some situations a CPU match permits a better spreading of
connections, or select targets only for a given cpu.

With Remote Packet Steering or multiqueue NIC and appropriate IRQ
affinities, we can distribute trafic on available cpus, per session.
(all RX packets for a given flow are handled by a given cpu)

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
 extensions/libxt_cpu.c           |   98 +++++++++++++++++++++++++++++
 extensions/libxt_cpu.man         |   16 ++++
 include/linux/netfilter/xt_cpu.h |   11 +++
 3 files changed, 125 insertions(+)

diff --git a/extensions/libxt_cpu.c b/extensions/libxt_cpu.c
index e69de29..869998d 100644
--- a/extensions/libxt_cpu.c
+++ b/extensions/libxt_cpu.c
@@ -0,0 +1,98 @@
+/* Shared library add-on to iptables to add CPU match support. */
+#include <stdio.h>
+#include <netdb.h>
+#include <string.h>
+#include <stdlib.h>
+#include <getopt.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_cpu.h>
+
+static void cpu_help(void)
+{
+	printf(
+"cpu match options:\n"
+"[!] --cpu number   Match CPU number\n");
+}
+
+static const struct option cpu_opts[] = {
+	{ "cpu", 1, NULL, '1' },
+	{ .name = NULL }
+};
+
+static void
+parse_cpu(const char *s, struct xt_cpu_info *info)
+{
+	unsigned int cpu;
+	char *end;
+
+	if (!xtables_strtoui(s, &end, &cpu, 0, UINT32_MAX))
+		xtables_param_act(XTF_BAD_VALUE, "cpu", "--cpu", s);
+
+	if (*end != '\0')
+		xtables_param_act(XTF_BAD_VALUE, "cpu", "--cpu", s);
+
+	info->cpu = cpu;
+}
+
+static int
+cpu_parse(int c, char **argv, int invert, unsigned int *flags,
+          const void *entry, struct xt_entry_match **match)
+{
+	struct xt_cpu_info *cpuinfo = (struct xt_cpu_info *)(*match)->data;
+
+	switch (c) {
+	case '1':
+		xtables_check_inverse(optarg, &invert, &optind, 0, argv);
+		parse_cpu(optarg, cpuinfo);
+		if (invert)
+			cpuinfo->invert = 1;
+		*flags = 1;
+		break;
+
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
+static void cpu_check(unsigned int flags)
+{
+	if (!flags)
+		xtables_error(PARAMETER_PROBLEM,
+			      "You must specify `--cpu'");
+}
+
+static void
+cpu_print(const void *ip, const struct xt_entry_match *match, int numeric)
+{
+	const struct xt_cpu_info *info = (void *)match->data;
+
+	printf("cpu %s%u ", info->invert ? "! ":"", info->cpu);
+}
+
+static void cpu_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_cpu_info *info = (void *)match->data;
+
+	printf("%s--cpu %u ", info->invert ? "! ":"", info->cpu);
+}
+
+static struct xtables_match cpu_match = {
+	.family		= NFPROTO_UNSPEC,
+ 	.name		= "cpu",
+	.version	= XTABLES_VERSION,
+	.size		= XT_ALIGN(sizeof(struct xt_cpu_info)),
+	.userspacesize	= XT_ALIGN(sizeof(struct xt_cpu_info)),
+	.help		= cpu_help,
+	.parse		= cpu_parse,
+	.final_check	= cpu_check,
+	.print		= cpu_print,
+	.save		= cpu_save,
+	.extra_opts	= cpu_opts,
+};
+
+void _init(void)
+{
+	xtables_register_match(&cpu_match);
+}
diff --git a/extensions/libxt_cpu.man b/extensions/libxt_cpu.man
index e69de29..f42ac7a 100644
--- a/extensions/libxt_cpu.man
+++ b/extensions/libxt_cpu.man
@@ -0,0 +1,16 @@
+.TP
+[\fB!\fP] \fB\-\-cpu\fP \fInumber\fP
+
+Match cpu handling this packet. cpus are numbered from 0 to NR_CPUS-1
+Can be used in combination with RPS (Remote Packet Steering) or
+multiqueue NICS to spread network traffic on different queues.
+.PP
+Example:
+.PP
+iptables \-t nat \-A PREROUTING \-p tcp \-\-dport 80 \-m cpu \-\-cpu 0 
+        \-j REDIRECT \-\-to\-port 8080
+.PP
+iptables \-t nat \-A PREROUTING \-p tcp \-\-dport 80 \-m cpu \-\-cpu 1 
+        \-j REDIRECT \-\-to\-port 8081
+.PP
+Available since linux 2.6.36
diff --git a/include/linux/netfilter/xt_cpu.h b/include/linux/netfilter/xt_cpu.h
index e69de29..93c7f11 100644
--- a/include/linux/netfilter/xt_cpu.h
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


