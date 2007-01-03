From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 08/10] iptables tproxy table
Date: Wed, 03 Jan 2007 17:37:58 +0100
Message-ID: <20070103163758.14635.51608.stgit@nienna.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

The iptables tproxy table registers a new hook on PRE_ROUTING and for
each incoming TCP/UDP packet performs as follows:

1. Does a TCP/UDP socket hash lookup to decide whether or not the packet
   is sent to a non-local bound socket. If a matching socket is found
   and the socket has the IP_FREEBIND socket option enabled the skb is
   diverted locally and the socket reference is stored in the skb.

2. If no matching socket was found, the PREROUTING chain of the
   iptables tproxy table is consulted. Matching rules with the TPROXY
   target can do transparent redirection here. (In this case it is not
   necessary to have the IP_FREEBIND socket option enabled for the
   target socket, redirection takes place even for "regular"
   sockets. This way no modification of the application is necessary.)

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/linux/netfilter_ipv4/ip_tproxy.h |   20 ++
 net/ipv4/netfilter/Kconfig               |   10 +
 net/ipv4/netfilter/Makefile              |    1 
 net/ipv4/netfilter/iptable_tproxy.c      |  253 ++++++++++++++++++++++++++++++
 4 files changed, 284 insertions(+), 0 deletions(-)

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
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index f6026d4..312b0ef 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -652,6 +652,16 @@ config IP_NF_RAW
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
index 15e741a..aa57ce4 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -71,6 +71,7 @@ obj-$(CONFIG_IP_NF_MANGLE) += iptable_ma
 obj-$(CONFIG_IP_NF_NAT) += iptable_nat.o
 obj-$(CONFIG_NF_NAT) += iptable_nat.o
 obj-$(CONFIG_IP_NF_RAW) += iptable_raw.o
+obj-$(CONFIG_IP_NF_TPROXY) += iptable_tproxy.o
 
 # matches
 obj-$(CONFIG_IP_NF_MATCH_IPRANGE) += ipt_iprange.o
diff --git a/net/ipv4/netfilter/iptable_tproxy.c b/net/ipv4/netfilter/iptable_tproxy.c
new file mode 100644
index 0000000..6049c83
--- /dev/null
+++ b/net/ipv4/netfilter/iptable_tproxy.c
@@ -0,0 +1,253 @@
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
+#include <linux/sysctl.h>
+#include <linux/vmalloc.h>
+#include <linux/net.h>
+#include <linux/slab.h>
+#include <linux/if.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/time.h>
+#include <linux/in.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <asm/uaccess.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+#define TPROXY_VALID_HOOKS (1 << NF_IP_PRE_ROUTING)
+
+#if 0
+#define DEBUGP printk
+#else
+#define DEBUGP(f, args...)
+#endif
+
+static struct
+{
+	struct ipt_replace repl;
+	struct ipt_standard entries[2];
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
+				   saddr, sport, daddr, sport,
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
+		    const int require_freebind,
+		    const struct net_device *in)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	struct in_device *indev;
+
+	if (unlikely(inet == NULL))
+		return -EINVAL;
+
+	if (!require_freebind || inet->freebind) {
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
+	struct sk_buff *skb = *pskb;
+	u8 protocol = skb->nh.iph->protocol;
+	struct sock *sk = NULL;
+	const struct iphdr *iph = (*pskb)->nh.iph;
+	struct udphdr _hdr, *hp;
+
+	/* TCP and UDP only */
+	if ((protocol != IPPROTO_TCP) && (protocol != IPPROTO_UDP))
+		return NF_ACCEPT;
+
+	if (in == NULL)
+		return NF_ACCEPT;
+
+	if ((skb->dst != NULL) || (skb->ip_tproxy == 1))
+		return NF_ACCEPT;
+
+	hp = skb_header_pointer(skb, skb->nh.iph->ihl * 4, sizeof(_hdr), &_hdr);
+	if (hp == NULL) {
+		DEBUGP(KERN_DEBUG "IP_TPROXY: ip_tproxy_fn(): "
+		       "failed to get protocol header\n");
+		return NF_DROP;
+	}
+
+	sk = ip_tproxy_get_sock(iph->protocol,
+				iph->saddr, iph->daddr,
+				hp->source, hp->dest, in);
+	if (sk) {
+		if (ip_tproxy_do_divert(skb, sk, 1, in) < 0) {
+			DEBUGP(KERN_DEBUG "IP_TPROXY: divert failed, dropping packet\n");
+			verdict = NF_DROP;
+		}
+		sock_put(sk);
+	} else {
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
+	.priority	= -130
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
