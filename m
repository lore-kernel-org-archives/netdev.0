From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 09/10] iptables TPROXY target
Date: Wed, 03 Jan 2007 17:38:28 +0100
Message-ID: <20070103163828.14635.74153.stgit@nienna.balabit>
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

The TPROXY target implements redirection of non-local TCP/UDP traffic
to local sockets. It is simply a wrapper around functionality exported
from iptable_tproxy.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/linux/netfilter_ipv4/ipt_TPROXY.h |    9 +++
 net/ipv4/netfilter/Kconfig                |   11 +++
 net/ipv4/netfilter/Makefile               |    1 
 net/ipv4/netfilter/ipt_TPROXY.c           |  103 +++++++++++++++++++++++++++++
 4 files changed, 124 insertions(+), 0 deletions(-)

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
index 312b0ef..7f76ab6 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -662,6 +662,17 @@ config IP_NF_TPROXY
 
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
index aa57ce4..851da93 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -97,6 +97,7 @@ obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_U
 obj-$(CONFIG_IP_NF_TARGET_TCPMSS) += ipt_TCPMSS.o
 obj-$(CONFIG_IP_NF_TARGET_CLUSTERIP) += ipt_CLUSTERIP.o
 obj-$(CONFIG_IP_NF_TARGET_TTL) += ipt_TTL.o
+obj-$(CONFIG_IP_NF_TARGET_TPROXY) += ipt_TPROXY.o
 
 # generic ARP tables
 obj-$(CONFIG_IP_NF_ARPTABLES) += arp_tables.o
diff --git a/net/ipv4/netfilter/ipt_TPROXY.c b/net/ipv4/netfilter/ipt_TPROXY.c
new file mode 100644
index 0000000..6f64717
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_TPROXY.c
@@ -0,0 +1,103 @@
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
+	unsigned int verdict = NF_ACCEPT;
+	struct sk_buff *skb = *pskb;
+	struct udphdr _hdr, *hp;
+	struct sock *sk;
+
+	/* TCP/UDP only */
+	if ((iph->protocol != IPPROTO_TCP) &&
+	    (iph->protocol != IPPROTO_UDP))
+		return NF_ACCEPT;
+
+	if (in == NULL)
+		return NF_ACCEPT;
+
+	if ((skb->dst != NULL) || (skb->ip_tproxy == 1))
+		return NF_ACCEPT;
+
+	hp = skb_header_pointer(*pskb, iph->ihl * 4, sizeof(_hdr), &_hdr);
+	if (hp == NULL)
+		return NF_DROP;
+
+	sk = ip_tproxy_get_sock(iph->protocol,
+				iph->saddr, iph->daddr,
+				hp->source, hp->dest, in);
+	if (sk != NULL) {
+		if (ip_tproxy_do_divert(skb, sk, 0, in) < 0)
+			verdict = NF_DROP;
+		sock_put(sk);
+	}
+
+	return verdict;
+}
+
+static int
+checkentry(const char *tablename,
+	   const void *e,
+	   const struct xt_target *target,
+           void *targinfo,
+           unsigned int hook_mask)
+{
+	/* checks are now done by the x_tables core based on
+	 * information specified in the ipt_target structure */
+	return 1;
+}
+
+static struct ipt_target ipt_tproxy_reg = {
+	.name		= "TPROXY",
+	.target		= target,
+	.targetsize	= sizeof(struct ipt_tproxy_target_info),
+	.table		= "tproxy",
+	.checkentry	= checkentry,
+	.me		= THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	if (ipt_register_target(&ipt_tproxy_reg))
+		return -EINVAL;
+
+	return 0;
+}
+
+static void __exit fini(void)
+{
+	ipt_unregister_target(&ipt_tproxy_reg);
+}
+
+module_init(init);
+module_exit(fini);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Krisztian Kovacs <hidden@balabit.hu>");
+MODULE_DESCRIPTION("Netfilter transparent proxy TPROXY target module.");
