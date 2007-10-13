From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 09/14] iptables tproxy core
Date: Sat, 13 Oct 2007 19:33:37 +0200
Message-ID: <20071013173337.22517.8230.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:45511 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761780AbXJMSjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 14:39:54 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV009JA212Z830@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:31:50 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The iptables tproxy core is a module that contains the common routines used by
various tproxy related modules (TPROXY target and socket match)

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/netfilter/nf_tproxy_core.h |   32 +++++++++++
 net/netfilter/Kconfig                  |   13 ++++
 net/netfilter/Makefile                 |    3 +
 net/netfilter/nf_tproxy_core.c         |   96 ++++++++++++++++++++++++++++++++
 4 files changed, 144 insertions(+), 0 deletions(-)

diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
new file mode 100644
index 0000000..2fac3ad
--- /dev/null
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -0,0 +1,32 @@
+#ifndef _NF_TPROXY_CORE_H
+#define _NF_TPROXY_CORE_H
+
+#include <linux/types.h>
+#include <linux/in.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/tcp.h>
+
+/* look up and get a reference to a matching socket */
+extern struct sock *
+nf_tproxy_get_sock_v4(const u8 protocol,
+		      const __be32 saddr, const __be32 daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in, bool listening);
+
+static inline void
+nf_tproxy_put_sock(struct sock *sk)
+{
+	/* TIME_WAIT inet sockets have to be handled differently */
+	if ((sk->sk_protocol == IPPROTO_TCP) && (sk->sk_state == TCP_TIME_WAIT))
+		inet_twsk_put(inet_twsk(sk));
+	else
+		sock_put(sk);
+}
+
+/* assign a socket to the skb -- consumes sk */
+int
+nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk);
+
+#endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index d7a600a..5bb4afb 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -257,6 +257,19 @@ config NF_CT_NETLINK
 	help
 	  This option enables support for a netlink-based userspace interface
 
+# transparent proxy support
+config NETFILTER_TPROXY
+	tristate "Transparent proxying support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && IP_NF_MANGLE
+	help
+	  This option enables transparent proxying support, that is,
+	  support for handling non-locally bound IPv4 TCP and UDP sockets.
+	  For it to work you will have to configure certain iptables rules
+	  and use policy routing. For more information on how to set it up
+	  see Documentation/networking/tproxy.txt.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XTABLES
 	tristate "Netfilter Xtables support (required for ip_tables)"
 	help
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 93c58f9..5066297 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -34,6 +34,9 @@ obj-$(CONFIG_NF_CONNTRACK_SANE) += nf_conntrack_sane.o
 obj-$(CONFIG_NF_CONNTRACK_SIP) += nf_conntrack_sip.o
 obj-$(CONFIG_NF_CONNTRACK_TFTP) += nf_conntrack_tftp.o
 
+# transparent proxy support
+obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
+
 # generic X tables 
 obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
new file mode 100644
index 0000000..1a25c61
--- /dev/null
+++ b/net/netfilter/nf_tproxy_core.c
@@ -0,0 +1,96 @@
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
+#include <linux/version.h>
+#include <linux/module.h>
+
+#include <linux/net.h>
+#include <linux/if.h>
+#include <linux/netdevice.h>
+#include <net/udp.h>
+#include <net/netfilter/nf_tproxy_core.h>
+
+struct sock *
+nf_tproxy_get_sock_v4(const u8 protocol,
+		      const __be32 saddr, const __be32 daddr,
+		      const __be16 sport, const __be16 dport,
+		      const struct net_device *in, bool listening_only)
+{
+	struct sock *sk;
+
+	/* look up socket */
+	switch (protocol) {
+	case IPPROTO_TCP:
+		if (listening_only)
+			sk = __inet_lookup_listener(&tcp_hashinfo,
+						    daddr, ntohs(dport),
+						    in->ifindex);
+		else
+			sk = __inet_lookup(&tcp_hashinfo,
+					   saddr, sport, daddr, dport,
+					   in->ifindex);
+		break;
+	case IPPROTO_UDP:
+		sk = udp4_lib_lookup(saddr, sport, daddr, dport,
+				     in->ifindex);
+		break;
+	default:
+		WARN_ON(1);
+		sk = NULL;
+	}
+
+	pr_debug("tproxy socket lookup: proto %u %08x:%u -> %08x:%u sock %p\n",
+		 protocol, ntohl(saddr), ntohs(sport), ntohl(daddr), ntohs(dport), sk);
+
+	return sk;
+}
+EXPORT_SYMBOL_GPL(nf_tproxy_get_sock_v4);
+
+static void
+nf_tproxy_destructor(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	skb->sk = NULL;
+	skb->destructor = NULL;
+
+	if (sk)
+		nf_tproxy_put_sock(sk);
+}
+
+/* consumes sk */
+int
+nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
+{
+	if (inet_sk(sk)->transparent) {
+		skb->sk = sk;
+		skb->destructor = nf_tproxy_destructor;
+		return 1;
+	} else
+		nf_tproxy_put_sock(sk);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nf_tproxy_assign_sock);
+
+static int __init nf_tproxy_init(void)
+{
+	pr_info("NF_TPROXY: Transparent proxy support initialized, version 4.1.0\n");
+	pr_info("NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.\n");
+	return 0;
+}
+
+module_init(nf_tproxy_init);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs");
+MODULE_DESCRIPTION("Transparent proxy support core routines");

