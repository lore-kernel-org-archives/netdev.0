From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/18] netfilter: add generic ARP packet logger
Date: Fri, 18 Jul 2014 13:01:03 +0200
Message-ID: <1405681272-4994-10-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46612 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761479AbaGRLBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 07:01:25 -0400
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the generic plain text packet loggger for ARP packets. It is
based on the ebt_log code. Nevertheless, the output has been modified
to make it consistent with the original xt_LOG output.

This is an example output:

IN=wlan0 OUT= ARP HTYPE=1 PTYPE=0x0800 OPCODE=2 MACSRC=00:ab:12:34:55:63 IPSRC=192.168.10.1 MACDST=80:09:12:70:4f:50 IPDST=192.168.10.150

This patch enables packet logging from ARP chains, eg.

  nft add rule arp filter input log prefix "input: "

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig      |    5 ++
 net/ipv4/netfilter/Makefile     |    1 +
 net/ipv4/netfilter/nf_log_arp.c |  149 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 155 insertions(+)
 create mode 100644 net/ipv4/netfilter/nf_log_arp.c

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 0c98029..12e6057 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -159,6 +159,11 @@ config IP_NF_TARGET_SYNPROXY
 
 	  To compile it as a module, choose M here. If unsure, say N.
 
+config NF_LOG_ARP
+	tristate "ARP packet logging"
+	default m if NETFILTER_ADVANCED=n
+	select NF_LOG_INET
+
 config NF_LOG_IPV4
 	tristate "IPv4 packet logging"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 730e0c1..245db9d 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_NF_NAT_IPV4) += nf_nat_ipv4.o
 obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 
 # logging
+obj-$(CONFIG_NF_LOG_ARP) += nf_log_arp.o
 obj-$(CONFIG_NF_LOG_IPV4) += nf_log_ipv4.o
 
 # NAT helpers (nf_conntrack)
diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
new file mode 100644
index 0000000..ccfc78d
--- /dev/null
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -0,0 +1,149 @@
+/*
+ * (C) 2014 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * Based on code from ebt_log from:
+ *
+ * Bart De Schuymer <bdschuym@pandora.be>
+ * Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+#include <linux/ip.h>
+#include <net/route.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter/xt_LOG.h>
+#include <net/netfilter/nf_log.h>
+
+static struct nf_loginfo default_loginfo = {
+	.type	= NF_LOG_TYPE_LOG,
+	.u = {
+		.log = {
+			.level	  = 5,
+			.logflags = NF_LOG_MASK,
+		},
+	},
+};
+
+struct arppayload {
+	unsigned char mac_src[ETH_ALEN];
+	unsigned char ip_src[4];
+	unsigned char mac_dst[ETH_ALEN];
+	unsigned char ip_dst[4];
+};
+
+static void dump_arp_packet(struct nf_log_buf *m,
+			    const struct nf_loginfo *info,
+			    const struct sk_buff *skb, unsigned int nhoff)
+{
+	const struct arphdr *ah;
+	struct arphdr _arph;
+	const struct arppayload *ap;
+	struct arppayload _arpp;
+
+	ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
+	if (ah == NULL) {
+		nf_log_buf_add(m, "TRUNCATED");
+		return;
+	}
+	nf_log_buf_add(m, "ARP HTYPE=%d PTYPE=0x%04x OPCODE=%d",
+		       ntohs(ah->ar_hrd), ntohs(ah->ar_pro), ntohs(ah->ar_op));
+
+	/* If it's for Ethernet and the lengths are OK, then log the ARP
+	 * payload.
+	 */
+	if (ah->ar_hrd != htons(1) ||
+	    ah->ar_hln != ETH_ALEN ||
+	    ah->ar_pln != sizeof(__be32))
+		return;
+
+	ap = skb_header_pointer(skb, sizeof(_arph), sizeof(_arpp), &_arpp);
+	if (ap == NULL) {
+		nf_log_buf_add(m, " INCOMPLETE [%Zu bytes]",
+			       skb->len - sizeof(_arph));
+		return;
+	}
+	nf_log_buf_add(m, " MACSRC=%pM IPSRC=%pI4 MACDST=%pM IPDST=%pI4",
+		       ap->mac_src, ap->ip_src, ap->mac_dst, ap->ip_dst);
+}
+
+void nf_log_arp_packet(struct net *net, u_int8_t pf,
+		      unsigned int hooknum, const struct sk_buff *skb,
+		      const struct net_device *in,
+		      const struct net_device *out,
+		      const struct nf_loginfo *loginfo,
+		      const char *prefix)
+{
+	struct nf_log_buf *m;
+
+	/* FIXME: Disabled from containers until syslog ns is supported */
+	if (!net_eq(net, &init_net))
+		return;
+
+	m = nf_log_buf_open();
+
+	if (!loginfo)
+		loginfo = &default_loginfo;
+
+	nf_log_dump_packet_common(m, pf, hooknum, skb, in, out, loginfo,
+				  prefix);
+	dump_arp_packet(m, loginfo, skb, 0);
+
+	nf_log_buf_close(m);
+}
+
+static struct nf_logger nf_arp_logger __read_mostly = {
+	.name		= "nf_log_arp",
+	.type		= NF_LOG_TYPE_LOG,
+	.logfn		= nf_log_arp_packet,
+	.me		= THIS_MODULE,
+};
+
+static int __net_init nf_log_arp_net_init(struct net *net)
+{
+	nf_log_set(net, NFPROTO_ARP, &nf_arp_logger);
+	return 0;
+}
+
+static void __net_exit nf_log_arp_net_exit(struct net *net)
+{
+	nf_log_unset(net, &nf_arp_logger);
+}
+
+static struct pernet_operations nf_log_arp_net_ops = {
+	.init = nf_log_arp_net_init,
+	.exit = nf_log_arp_net_exit,
+};
+
+static int __init nf_log_arp_init(void)
+{
+	int ret;
+
+	ret = register_pernet_subsys(&nf_log_arp_net_ops);
+	if (ret < 0)
+		return ret;
+
+	nf_log_register(NFPROTO_ARP, &nf_arp_logger);
+	return 0;
+}
+
+static void __exit nf_log_arp_exit(void)
+{
+	unregister_pernet_subsys(&nf_log_arp_net_ops);
+	nf_log_unregister(&nf_arp_logger);
+}
+
+module_init(nf_log_arp_init);
+module_exit(nf_log_arp_exit);
+
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_DESCRIPTION("Netfilter ARP packet logging");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NF_LOGGER(3, 0);
-- 
1.7.10.4
