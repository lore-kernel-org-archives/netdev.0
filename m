From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 11/13] iptables tproxy table
Date: Mon, 05 Mar 2007 16:46:42 +0100
Message-ID: <20070305154642.3471.62058.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3081 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933550AbXCEPqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:46:44 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 0DD8B294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:43 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The iptables tproxy table registers a new hook on PRE_ROUTING and for
each incoming TCP/UDP packet performs as follows:

1. Does IPv4 fragment reassembly. We need this to be able to do TCP/UDP
   header processing.

2. Does a TCP/UDP socket hash lookup to decide whether or not the packet
   is sent to a non-local bound socket. If a matching socket is found
   and the socket has the IP_TRANSPARENT socket option enabled the skb is
   diverted locally and the socket reference is stored in the skb.

3. If no matching socket was found, the PREROUTING chain of the
   iptables tproxy table is consulted. Matching rules with the TPROXY
   target can do transparent redirection here. (In this case it is not
   necessary to have the IP_TRANSPARENT socket option enabled for the
   target socket, redirection takes place even for "regular"
   sockets. This way no modification of the application is necessary.)

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/linux/netfilter_ipv4.h           |    1 
 include/linux/netfilter_ipv4/ip_tproxy.h |   20 ++
 include/net/ip.h                         |    3 
 net/ipv4/netfilter/Kconfig               |   10 +
 net/ipv4/netfilter/Makefile              |    1 
 net/ipv4/netfilter/iptable_tproxy.c      |  267 ++++++++++++++++++++++++++++++
 6 files changed, 301 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index ceae87a..cc4d83b 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -58,6 +58,7 @@ enum nf_ip_hook_priorities {
 	NF_IP_PRI_SELINUX_FIRST = -225,
 	NF_IP_PRI_CONNTRACK = -200,
 	NF_IP_PRI_MANGLE = -150,
+	NF_IP_PRI_TPROXY = -125,
 	NF_IP_PRI_NAT_DST = -100,
 	NF_IP_PRI_FILTER = 0,
 	NF_IP_PRI_NAT_SRC = 100,
diff --git a/include/linux/netfilter_ipv4/ip_tproxy.h b/include/linux/netfilter_ipv4/ip_tproxy.h
new file mode 100644
index 0000000..ae890e3
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ip_tproxy.h
@@ -0,0 +1,20 @@
+#ifndef _IP_TPROXY_H
+#define _IP_TPROXY_H
+
+#include <linux/types.h>
+
+/* look up and get a reference to a matching socket */
+extern struct sock *
+ip_tproxy_get_sock(const u8 protocol,
+		   const __be32 saddr, const __be32 daddr,
+		   const __be16 sport, const __be16 dport,
+		   const struct net_device *in);
+
+/* divert skb to a given socket */
+extern int
+ip_tproxy_do_divert(struct sk_buff *skb,
+		    const struct sock *sk,
+		    const int require_freebind,
+		    const struct net_device *in);
+
+#endif
diff --git a/include/net/ip.h b/include/net/ip.h
index 8b71991..a589e6e 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -321,7 +321,8 @@ enum ip_defrag_users
 	IP_DEFRAG_CONNTRACK_OUT,
 	IP_DEFRAG_VS_IN,
 	IP_DEFRAG_VS_OUT,
-	IP_DEFRAG_VS_FWD
+	IP_DEFRAG_VS_FWD,
+	IP_DEFRAG_TP_IN,
 };
 
 struct sk_buff *ip_defrag(struct sk_buff *skb, u32 user);
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 601808c..17c3ec8 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -628,6 +628,16 @@ config IP_NF_RAW
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/modules.txt>.  If unsure, say `N'.
 
+# tproxy table
+config IP_NF_TPROXY
+	tristate "Transparent proxying"
+	depends on IP_NF_IPTABLES
+	help
+	  Transparent proxying. For more information see
+	  http://www.balabit.com/downloads/tproxy.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 # ARP tables
 config IP_NF_ARPTABLES
 	tristate "ARP tables support"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 6625ec6..21a29f4 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -81,6 +81,7 @@ obj-$(CONFIG_IP_NF_MANGLE) += iptable_mangle.o
 obj-$(CONFIG_IP_NF_NAT) += iptable_nat.o
 obj-$(CONFIG_NF_NAT) += iptable_nat.o
 obj-$(CONFIG_IP_NF_RAW) += iptable_raw.o
+obj-$(CONFIG_IP_NF_TPROXY) += iptable_tproxy.o
 
 # matches
 obj-$(CONFIG_IP_NF_MATCH_IPRANGE) += ipt_iprange.o
diff --git a/net/ipv4/netfilter/iptable_tproxy.c b/net/ipv4/netfilter/iptable_tproxy.c
new file mode 100644
index 0000000..a241f11
--- /dev/null
+++ b/net/ipv4/netfilter/iptable_tproxy.c
@@ -0,0 +1,267 @@
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
+#include <linux/inetdevice.h>
+#include <linux/in.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+#define TPROXY_VALID_HOOKS (1 << NF_IP_PRE_ROUTING)
+
+#if 1
+#define DEBUGP printk
+#else
+#define DEBUGP(f, args...)
+#endif
+
+static struct
+{
+	struct ipt_replace repl;
+	struct ipt_standard entries[1];
+	struct ipt_error term;
+} initial_table __initdata = {
+	.repl = {
+		.name = "tproxy",
+		.valid_hooks = TPROXY_VALID_HOOKS,
+		.num_entries = 2,
+		.size = sizeof(struct ipt_standard) + sizeof(struct ipt_error),
+		.hook_entry = {
+			[NF_IP_PRE_ROUTING] = 0 },
+		.underflow = {
+			[NF_IP_PRE_ROUTING] = 0 },
+	},
+	.entries = {
+		/* PRE_ROUTING */
+		{
+			.entry = {
+				.target_offset = sizeof(struct ipt_entry),
+				.next_offset = sizeof(struct ipt_standard),
+			},
+			.target = {
+				.target = {
+					.u = {
+						.target_size = IPT_ALIGN(sizeof(struct ipt_standard_target)),
+					},
+				},
+				.verdict = -NF_ACCEPT - 1,
+			},
+		},
+	},
+	/* ERROR */
+	.term = {
+		.entry = {
+			.target_offset = sizeof(struct ipt_entry),
+			.next_offset = sizeof(struct ipt_error),
+		},
+		.target = {
+			.target = {
+				.u = {
+					.user = {
+						.target_size = IPT_ALIGN(sizeof(struct ipt_error_target)),
+						.name = IPT_ERROR_TARGET,
+					},
+				},
+			},
+			.errorname = "ERROR",
+		},
+	}
+};
+
+static struct ipt_table tproxy_table = {
+	.name		= "tproxy",
+	.valid_hooks	= TPROXY_VALID_HOOKS,
+	.lock		= RW_LOCK_UNLOCKED,
+	.me		= THIS_MODULE,
+	.af		= AF_INET,
+};
+
+struct sock *
+ip_tproxy_get_sock(const u8 protocol,
+		   const __be32 saddr, const __be32 daddr,
+		   const __be16 sport, const __be16 dport,
+		   const struct net_device *in)
+{
+	struct sock *sk = NULL;
+
+	/* look up socket */
+	switch (protocol) {
+	case IPPROTO_TCP:
+		sk = __inet_lookup(&tcp_hashinfo,
+				   saddr, sport, daddr, dport,
+				   in->ifindex);
+		break;
+	case IPPROTO_UDP:
+		sk = udp4_lib_lookup(saddr, sport, daddr, dport,
+				     in->ifindex);
+		break;
+	default:
+		WARN_ON(1);
+	}
+
+	return sk;
+}
+EXPORT_SYMBOL_GPL(ip_tproxy_get_sock);
+
+int
+ip_tproxy_do_divert(struct sk_buff *skb, struct sock *sk,
+		    const int require_transparent,
+		    const struct net_device *in)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	struct in_device *indev;
+
+	if (unlikely(inet == NULL))
+		return -EINVAL;
+
+	if (!require_transparent || inet->transparent) {
+		indev = in_dev_get(in);
+		if (indev == NULL)
+			return -ENODEV;
+
+		skb->ip_tproxy = 1;
+
+		ip_divert_local(skb, indev, sk);
+		in_dev_put(indev);
+
+		DEBUGP(KERN_DEBUG "IP_TPROXY: diverted to socket %p\n", sk);
+	} else {
+		DEBUGP(KERN_DEBUG "IP_TPROXY: diversion to non-transparent socket %p failed\n", sk);
+		return -ENOENT;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip_tproxy_do_divert);
+
+static unsigned int
+ip_tproxy_prerouting(unsigned int hooknum,
+		     struct sk_buff **pskb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
+{
+	int verdict = NF_ACCEPT;
+	int diverted = -1;
+	struct sk_buff *skb = *pskb;
+	struct sock *sk = NULL;
+	const struct iphdr *iph;
+	struct udphdr *hp, _hdr;
+	u8 protocol;
+
+	/* reassemble fragments */
+	if (skb->nh.iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) {
+		skb = ip_defrag(skb, IP_DEFRAG_TP_IN);
+		if (skb == NULL)
+			return NF_STOLEN;
+
+		ip_send_check(skb->nh.iph);
+		*pskb = skb;
+	}
+
+	protocol = skb->nh.iph->protocol;
+	iph = skb->nh.iph;
+
+	/* TCP and UDP only */
+	if ((protocol != IPPROTO_TCP) && (protocol != IPPROTO_UDP))
+		return NF_ACCEPT;
+
+	if (unlikely(in == NULL))
+		return NF_ACCEPT;
+
+	if (unlikely(skb->ip_tproxy))
+		return NF_ACCEPT;
+
+	hp = skb_header_pointer(skb, iph->ihl * 4, sizeof(_hdr), &_hdr);
+	if (unlikely(hp == NULL)) {
+		DEBUGP(KERN_DEBUG "IP_TPROXY: ip_tproxy_fn(): "
+		       "failed to get protocol header\n");
+		return NF_DROP;
+	}
+
+	sk = ip_tproxy_get_sock(protocol,
+				iph->saddr, iph->daddr,
+				hp->source, hp->dest, in);
+	if (sk) {
+		diverted = ip_tproxy_do_divert(skb, sk, 1, in);
+
+		if ((sk->sk_protocol == IPPROTO_TCP) && (sk->sk_state == TCP_TIME_WAIT))
+			inet_twsk_put(inet_twsk(sk));
+		else
+			sock_put(sk);
+	}
+
+	if (diverted < 0) {
+		/* no socket or diversion failed: lookup table */
+		verdict = ipt_do_table(pskb, hooknum, in, out, &tproxy_table);
+	}
+
+	return verdict;
+}
+
+static struct nf_hook_ops ip_tproxy_pre_ops = {
+	.hook		= ip_tproxy_prerouting,
+	.owner		= THIS_MODULE,
+	.pf		= PF_INET,
+	.hooknum	= NF_IP_PRE_ROUTING,
+	.priority	= NF_IP_PRI_TPROXY
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	ret = ipt_register_table(&tproxy_table, &initial_table.repl);
+	if (ret < 0) {
+		printk("IP_TPROXY: can't register tproxy table.\n");
+		return ret;
+	}
+
+	ret = nf_register_hook(&ip_tproxy_pre_ops);
+	if (ret < 0) {
+		printk("IP_TPROXY: can't register prerouting hook.\n");
+		goto clean_table;
+	}
+
+	printk("IP_TPROXY: Transparent proxy support initialized, version 4.0.0\n"
+	       "IP_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.\n");
+
+	return ret;
+
+ clean_table:
+	ipt_unregister_table(&tproxy_table);
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	nf_unregister_hook(&ip_tproxy_pre_ops);
+	ipt_unregister_table(&tproxy_table);
+}
+
+module_init(init);
+module_exit(fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs <hidden@balabit.hu>");
+MODULE_DESCRIPTION("iptables transparent proxy table");

