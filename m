From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 11/14] iptables TPROXY target
Date: Sat, 13 Oct 2007 19:34:38 +0200
Message-ID: <20071013173438.22517.36232.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:58852 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755778AbXJMRi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 13:38:57 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV00DZ722R9X10@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:32:51 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TPROXY target implements redirection of non-local TCP/UDP traffic to local
sockets. Additionally, it's possible to manipulate the packet mark if and only
if a socket has been found. (We need this because we cannot use multiple
targets in the same iptables rule.)

Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/linux/netfilter/xt_TPROXY.h |   14 ++++
 net/netfilter/Kconfig               |   14 ++++
 net/netfilter/Makefile              |    1 
 net/netfilter/xt_TPROXY.c           |  113 +++++++++++++++++++++++++++++++++++
 4 files changed, 142 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/xt_TPROXY.h b/include/linux/netfilter/xt_TPROXY.h
new file mode 100644
index 0000000..152e8f9
--- /dev/null
+++ b/include/linux/netfilter/xt_TPROXY.h
@@ -0,0 +1,14 @@
+#ifndef _XT_TPROXY_H_target
+#define _XT_TPROXY_H_target
+
+/* TPROXY target is capable of marking the packet to perform
+ * redirection. We can get rid of that whenever we get support for
+ * mutliple targets in the same rule. */
+struct xt_tproxy_target_info {
+	u_int32_t mark_mask;
+	u_int32_t mark_value;
+	__be32 laddr;
+	__be16 lport;
+};
+
+#endif /* _XT_TPROXY_H_target */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 47976b5..c80f08a 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -366,6 +366,20 @@ config NETFILTER_XT_TARGET_NOTRACK
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_TARGET_TPROXY
+	tristate '"TPROXY" target support (EXPERIMENTAL)'
+	depends on EXPERIMENTAL
+	depends on NETFILTER_TPROXY
+	depends on NETFILTER_XTABLES
+	select NF_DEFRAG_IPV4
+	help
+	  This option adds a `TPROXY' target, which is somewhat similar to
+	  REDIRECT.  It can only be used in the mangle table and is useful
+	  to redirect traffic to a transparent proxy.  It does _not_ depend
+	  on Netfilter connection tracking and NAT, unlike REDIRECT.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_TRACE
 	tristate  '"TRACE" target support'
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 2303ef3..4af92fe 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) += xt_TRACE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_TPROXY) += xt_TPROXY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPMSS) += xt_TCPMSS.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
new file mode 100644
index 0000000..9222a8f
--- /dev/null
+++ b/net/netfilter/xt_TPROXY.c
@@ -0,0 +1,113 @@
+/*
+ * Transparent proxy support for Linux/iptables
+ *
+ * Copyright (c) 2006-2007 BalaBit IT Ltd.
+ * Author: Balazs Scheidler, Krisztian Kovacs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/checksum.h>
+#include <net/udp.h>
+#include <net/inet_sock.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter/xt_TPROXY.h>
+
+#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#include <net/netfilter/nf_tproxy_core.h>
+
+static unsigned int
+xt_tproxy_target(struct sk_buff **pskb,
+		 const struct net_device *in,
+		 const struct net_device *out,
+		 unsigned int hooknum,
+		 const struct xt_target *target,
+		 const void *targinfo)
+{
+	const struct iphdr *iph = ip_hdr(*pskb);
+	const struct xt_tproxy_target_info *tgi = targinfo;
+	struct sk_buff *skb = *pskb;
+	struct udphdr _hdr, *hp;
+	struct sock *sk;
+
+	hp = skb_header_pointer(*pskb, ip_hdrlen(skb), sizeof(_hdr), &_hdr);
+	if (hp == NULL)
+		return NF_DROP;
+
+	sk = nf_tproxy_get_sock_v4(iph->protocol,
+				   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
+				   hp->source, tgi->lport ? tgi->lport : hp->dest,
+				   in, true);
+
+	/* NOTE: assign_sock consumes our sk reference */
+	if (sk && nf_tproxy_assign_sock(skb, sk)) {
+		/* This should be in a separate target, but we don't do multiple
+		   targets on the same rule yet */
+		skb->mark = (skb->mark & ~tgi->mark_mask) ^ tgi->mark_value;
+
+		pr_debug("redirecting: proto %u %08x:%u -> %08x:%u, mark: %x\n",
+			 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
+			 ntohl(tgi->laddr), ntohs(tgi->lport), skb->mark);
+		return NF_ACCEPT;
+	}
+
+	pr_debug("no socket, dropping: proto %u %08x:%u -> %08x:%u, mark: %x\n",
+		 iph->protocol, ntohl(iph->daddr), ntohs(hp->dest),
+		 ntohl(tgi->laddr), ntohs(tgi->lport), skb->mark);
+	return NF_DROP;
+}
+
+static bool
+xt_tproxy_checkentry(const char *tablename,
+		     const void *entry,
+		     const struct xt_target *target,
+		     void *targetinfo,
+		     unsigned int hook_mask)
+{
+	const struct ipt_ip *i = entry;
+
+	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP)
+	    && !(i->invflags & IPT_INV_PROTO))
+		return true;
+
+	pr_info("xt_TPROXY: Can be used only in combination with "
+		"either -p tcp or -p udp\n");
+	return false;
+}
+
+static struct xt_target xt_tproxy_reg __read_mostly = {
+	.name		= "TPROXY",
+	.family		= AF_INET,
+	.table		= "mangle",
+	.target		= xt_tproxy_target,
+	.targetsize	= sizeof(struct xt_tproxy_target_info),
+	.checkentry	= xt_tproxy_checkentry,
+	.hooks		= 1 << NF_IP_PRE_ROUTING,
+	.me		= THIS_MODULE,
+};
+
+static int __init xt_tproxy_init(void)
+{
+	nf_defrag_ipv4_enable();
+	return xt_register_target(&xt_tproxy_reg);
+}
+
+static void __exit xt_tproxy_fini(void)
+{
+	xt_unregister_target(&xt_tproxy_reg);
+}
+
+module_init(xt_tproxy_init);
+module_exit(xt_tproxy_fini);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs");
+MODULE_DESCRIPTION("Netfilter transparent proxy (TPROXY) target module.");
+MODULE_ALIAS("ipt_TPROXY");

