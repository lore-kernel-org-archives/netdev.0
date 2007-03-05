From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 12/13] iptables TPROXY target
Date: Mon, 05 Mar 2007 16:46:52 +0100
Message-ID: <20070305154652.3471.13312.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:2765 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933538AbXCEPqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:46:54 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 21448294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:53 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TPROXY target implements redirection of non-local TCP/UDP traffic
to local sockets. It is simply a wrapper around functionality exported
from iptable_tproxy.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/linux/netfilter_ipv4/ipt_TPROXY.h |    9 +++
 net/ipv4/netfilter/Kconfig                |   11 +++
 net/ipv4/netfilter/Makefile               |    1 
 net/ipv4/netfilter/ipt_TPROXY.c           |   92 +++++++++++++++++++++++++++++
 4 files changed, 113 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ipt_TPROXY.h b/include/linux/netfilter_ipv4/ipt_TPROXY.h
new file mode 100644
index 0000000..d05c956
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_TPROXY.h
@@ -0,0 +1,9 @@
+#ifndef _IPT_TPROXY_H_target
+#define _IPT_TPROXY_H_target
+
+struct ipt_tproxy_target_info {
+	u_int16_t lport;
+	u_int32_t laddr;
+};
+
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 17c3ec8..ecd8da5 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -638,6 +638,17 @@ config IP_NF_TPROXY
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config IP_NF_TARGET_TPROXY
+	tristate "TPROXY target support"
+	depends on IP_NF_TPROXY
+	help
+	  This option adds a `TPROXY' target, which is somewhat similar to
+	  REDIRECT.  It can only be used in the tproxy table and is useful
+	  to redirect traffic to a transparent proxy.  It does _not_ depend
+	  on Netfilter connection tracking.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 # ARP tables
 config IP_NF_ARPTABLES
 	tristate "ARP tables support"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 21a29f4..a50a64e 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -106,6 +106,7 @@ obj-$(CONFIG_IP_NF_TARGET_LOG) += ipt_LOG.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_ULOG.o
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
 obj-$(CONFIG_IP_NF_TARGET_TTL) += ipt_TTL.o
+obj-$(CONFIG_IP_NF_TARGET_TPROXY) += ipt_TPROXY.o
 
 # generic ARP tables
 obj-$(CONFIG_IP_NF_ARPTABLES) += arp_tables.o
diff --git a/net/ipv4/netfilter/ipt_TPROXY.c b/net/ipv4/netfilter/ipt_TPROXY.c
new file mode 100644
index 0000000..89a08b1
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_TPROXY.c
@@ -0,0 +1,92 @@
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
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ip_tproxy.h>
+#include <linux/netfilter_ipv4/ipt_TPROXY.h>
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const struct xt_target *target,
+       const void *targinfo)
+{
+	const struct iphdr *iph = (*pskb)->nh.iph;
+	const struct ipt_tproxy_target_info *tgi =
+		(const struct ipt_tproxy_target_info *) targinfo;
+	unsigned int verdict = NF_ACCEPT;
+	struct sk_buff *skb = *pskb;
+	struct udphdr _hdr, *hp;
+	struct sock *sk;
+	__be32 daddr;
+	__be16 dport;
+
+	/* TCP/UDP only */
+	if ((iph->protocol != IPPROTO_TCP) &&
+	    (iph->protocol != IPPROTO_UDP))
+		return NF_ACCEPT;
+
+	hp = skb_header_pointer(*pskb, iph->ihl * 4, sizeof(_hdr), &_hdr);
+	if (hp == NULL)
+		return NF_DROP;
+
+	daddr = tgi->laddr ? : iph->daddr;
+	dport = tgi->lport ? : hp->dest;
+	sk = ip_tproxy_get_sock(iph->protocol,
+				iph->saddr, daddr,
+				hp->source, dport, in);
+	if (sk != NULL) {
+		if (ip_tproxy_do_divert(skb, sk, 0, in) < 0)
+			verdict = NF_DROP;
+
+		if ((iph->protocol == IPPROTO_TCP) && (sk->sk_state == TCP_TIME_WAIT))
+			inet_twsk_put(inet_twsk(sk));
+		else
+			sock_put(sk);
+	}
+
+	return verdict;
+}
+
+static struct xt_target ipt_tproxy_reg = {
+	.name		= "TPROXY",
+	.family		= AF_INET,
+	.target		= target,
+	.targetsize	= sizeof(struct ipt_tproxy_target_info),
+	.table		= "tproxy",
+	.me		= THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	return xt_register_target(&ipt_tproxy_reg);
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_target(&ipt_tproxy_reg);
+}
+
+module_init(init);
+module_exit(fini);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs <hidden@balabit.hu>");
+MODULE_DESCRIPTION("Netfilter transparent proxy TPROXY target module.");

