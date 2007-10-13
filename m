From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 10/14] iptables socket match
Date: Sat, 13 Oct 2007 19:34:07 +0200
Message-ID: <20071013173407.22517.29921.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:58852 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699AbXJMRi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 13:38:56 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV009ZO21XZM20@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:32:21 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add iptables 'socket' match, which matches packets for which a TCP/UDP
socket lookup succeeds.

Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 net/netfilter/Kconfig     |   14 ++++++
 net/netfilter/Makefile    |    1 
 net/netfilter/xt_socket.c |   99 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 5bb4afb..47976b5 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -635,6 +635,20 @@ config NETFILTER_XT_MATCH_SCTP
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config NETFILTER_XT_MATCH_SOCKET
+	tristate '"socket" match support (EXPERIMENTAL)'
+	depends on EXPERIMENTAL
+	depends on NETFILTER_TPROXY
+	depends on NETFILTER_XTABLES
+	select NF_DEFRAG_IPV4
+	help
+	  This option adds a `socket' match, which can be used to match
+	  packets for which a TCP or UDP socket lookup finds a valid socket.
+	  It can be used in combination with the MARK target and policy
+	  routing to implement full featured non-locally bound sockets.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_STATE
 	tristate '"state" match support'
 	depends on NETFILTER_XTABLES
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 5066297..2303ef3 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -73,6 +73,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) += xt_pkttype.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_QUOTA) += xt_quota.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_REALM) += xt_realm.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_SCTP) += xt_sctp.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_SOCKET) += xt_socket.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_STATE) += xt_state.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_STATISTIC) += xt_statistic.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_STRING) += xt_string.o
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
new file mode 100644
index 0000000..f2e0846
--- /dev/null
+++ b/net/netfilter/xt_socket.c
@@ -0,0 +1,99 @@
+/*
+ * Transparent proxy support for Linux/iptables
+ *
+ * Copyright (C) 2007 BalaBit IT Ltd.
+ * Author: Krisztian Kovacs
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/netfilter/nf_tproxy_core.h>
+#include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+
+static bool
+xt_socket_match(const struct sk_buff *skb,
+	     const struct net_device *in,
+	     const struct net_device *out,
+	     const struct xt_match *match,
+	     const void *matchinfo,
+	     int offset,
+	     unsigned int protoff,
+	     bool *hotdrop)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct udphdr _hdr, *hp;
+	struct sock *sk;
+
+	hp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_hdr), &_hdr);
+	if (hp == NULL)
+		return false;
+
+	sk = nf_tproxy_get_sock_v4(iph->protocol,
+				   iph->saddr, iph->daddr,
+				   hp->source, hp->dest, in, false);
+	if (sk != NULL)
+		nf_tproxy_put_sock(sk);
+
+	pr_debug("socket match: proto %u %08x:%u -> %08x:%u sock %p\n",
+		 iph->protocol, ntohl(iph->saddr), ntohs(hp->source),
+		 ntohl(iph->daddr), ntohs(hp->dest), sk);
+
+	return (sk != NULL);
+}
+
+static bool
+xt_socket_checkentry(const char *tablename,
+		     const void *entry,
+		     const struct xt_match *match,
+		     void *matchinfo,
+		     unsigned int hook_mask)
+{
+	const struct ipt_ip *i = entry;
+
+	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP)
+	    && !(i->invflags & IPT_INV_PROTO))
+		return true;
+
+	pr_info("xt_socket: Can be used only in combination with "
+		"either -p tcp or -p udp\n");
+	return false;
+}
+
+static struct xt_match xt_socket_reg __read_mostly = {
+	.name		= "socket",
+	.family		= AF_INET,
+	.match		= xt_socket_match,
+	.checkentry	= xt_socket_checkentry,
+	.hooks		= (1 << NF_IP_PRE_ROUTING),
+	.me		= THIS_MODULE,
+};
+
+static int __init xt_socket_init(void)
+{
+	nf_defrag_ipv4_enable();
+	return xt_register_match(&xt_socket_reg);
+}
+
+static void __exit xt_socket_fini(void)
+{
+	xt_unregister_match(&xt_socket_reg);
+}
+
+module_init(xt_socket_init);
+module_exit(xt_socket_fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs");
+MODULE_DESCRIPTION("x_tables socket match module");
+MODULE_ALIAS("ipt_socket");

