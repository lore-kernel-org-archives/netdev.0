From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/25] netfilter: nf_nat: generalize IPv6 masquerading support for nf_tables
Date: Wed, 10 Sep 2014 17:10:41 +0200
Message-ID: <1410361842-4656-25-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

Let's refactor the code so we can reach the masquerade functionality
from outside the xt context (ie. nftables).

The patch includes the addition of an atomic counter to the masquerade
notifier: the stuff to be done by the notifier is the same for xt and
nftables. Therefore, only one notification handler is needed.

This factorization only involves IPv6; a similar patch exists to
handle IPv4.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv6/nf_nat_masquerade.h |   10 ++
 net/ipv6/netfilter/Kconfig                     |    7 ++
 net/ipv6/netfilter/Makefile                    |    1 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c           |   76 +--------------
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c    |  120 ++++++++++++++++++++++++
 5 files changed, 143 insertions(+), 71 deletions(-)
 create mode 100644 include/net/netfilter/ipv6/nf_nat_masquerade.h
 create mode 100644 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c

diff --git a/include/net/netfilter/ipv6/nf_nat_masquerade.h b/include/net/netfilter/ipv6/nf_nat_masquerade.h
new file mode 100644
index 0000000..0a13396
--- /dev/null
+++ b/include/net/netfilter/ipv6/nf_nat_masquerade.h
@@ -0,0 +1,10 @@
+#ifndef _NF_NAT_MASQUERADE_IPV6_H_
+#define _NF_NAT_MASQUERADE_IPV6_H_
+
+unsigned int
+nf_nat_masquerade_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
+		       const struct net_device *out);
+void nf_nat_masquerade_ipv6_register_notifier(void);
+void nf_nat_masquerade_ipv6_unregister_notifier(void);
+
+#endif /* _NF_NAT_MASQUERADE_IPV6_H_ */
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index ac93df1..6c8cfec 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -246,8 +246,15 @@ config NF_NAT_IPV6
 
 if NF_NAT_IPV6
 
+config NF_NAT_MASQUERADE_IPV6
+	tristate "IPv6 masquerade support"
+	help
+	 This is the kernel functionality to provide NAT in the masquerade
+	 flavour (automatic source address selection) for IPv6.
+
 config IP6_NF_TARGET_MASQUERADE
 	tristate "MASQUERADE target support"
+	select NF_NAT_MASQUERADE_IPV6
 	help
 	  Masquerading is a special case of NAT: all outgoing connections are
 	  changed to seem to come from a particular interface's address, and
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index c0b2631..89a0bd7 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -18,6 +18,7 @@ obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o
 
 nf_nat_ipv6-y		:= nf_nat_l3proto_ipv6.o nf_nat_proto_icmpv6.o
 obj-$(CONFIG_NF_NAT_IPV6) += nf_nat_ipv6.o
+obj-$(CONFIG_NF_NAT_MASQUERADE_IPV6) += nf_nat_masquerade_ipv6.o
 
 # defrag
 nf_defrag_ipv6-y := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
index 3e4e92d..7f9f45d 100644
--- a/net/ipv6/netfilter/ip6t_MASQUERADE.c
+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
@@ -19,33 +19,12 @@
 #include <net/netfilter/nf_nat.h>
 #include <net/addrconf.h>
 #include <net/ipv6.h>
+#include <net/netfilter/ipv6/nf_nat_masquerade.h>
 
 static unsigned int
 masquerade_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	const struct nf_nat_range *range = par->targinfo;
-	enum ip_conntrack_info ctinfo;
-	struct in6_addr src;
-	struct nf_conn *ct;
-	struct nf_nat_range newrange;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
-			    ctinfo == IP_CT_RELATED_REPLY));
-
-	if (ipv6_dev_get_saddr(dev_net(par->out), par->out,
-			       &ipv6_hdr(skb)->daddr, 0, &src) < 0)
-		return NF_DROP;
-
-	nfct_nat(ct)->masq_index = par->out->ifindex;
-
-	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
-	newrange.min_addr.in6	= src;
-	newrange.max_addr.in6	= src;
-	newrange.min_proto	= range->min_proto;
-	newrange.max_proto	= range->max_proto;
-
-	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_SRC);
+	return nf_nat_masquerade_ipv6(skb, par->targinfo, par->out);
 }
 
 static int masquerade_tg6_checkentry(const struct xt_tgchk_param *par)
@@ -57,48 +36,6 @@ static int masquerade_tg6_checkentry(const struct xt_tgchk_param *par)
 	return 0;
 }
 
-static int device_cmp(struct nf_conn *ct, void *ifindex)
-{
-	const struct nf_conn_nat *nat = nfct_nat(ct);
-
-	if (!nat)
-		return 0;
-	if (nf_ct_l3num(ct) != NFPROTO_IPV6)
-		return 0;
-	return nat->masq_index == (int)(long)ifindex;
-}
-
-static int masq_device_event(struct notifier_block *this,
-			     unsigned long event, void *ptr)
-{
-	const struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct net *net = dev_net(dev);
-
-	if (event == NETDEV_DOWN)
-		nf_ct_iterate_cleanup(net, device_cmp,
-				      (void *)(long)dev->ifindex, 0, 0);
-
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block masq_dev_notifier = {
-	.notifier_call	= masq_device_event,
-};
-
-static int masq_inet_event(struct notifier_block *this,
-			   unsigned long event, void *ptr)
-{
-	struct inet6_ifaddr *ifa = ptr;
-	struct netdev_notifier_info info;
-
-	netdev_notifier_info_init(&info, ifa->idev->dev);
-	return masq_device_event(this, event, &info);
-}
-
-static struct notifier_block masq_inet_notifier = {
-	.notifier_call	= masq_inet_event,
-};
-
 static struct xt_target masquerade_tg6_reg __read_mostly = {
 	.name		= "MASQUERADE",
 	.family		= NFPROTO_IPV6,
@@ -115,17 +52,14 @@ static int __init masquerade_tg6_init(void)
 	int err;
 
 	err = xt_register_target(&masquerade_tg6_reg);
-	if (err == 0) {
-		register_netdevice_notifier(&masq_dev_notifier);
-		register_inet6addr_notifier(&masq_inet_notifier);
-	}
+	if (err == 0)
+		nf_nat_masquerade_ipv6_register_notifier();
 
 	return err;
 }
 static void __exit masquerade_tg6_exit(void)
 {
-	unregister_inet6addr_notifier(&masq_inet_notifier);
-	unregister_netdevice_notifier(&masq_dev_notifier);
+	nf_nat_masquerade_ipv6_unregister_notifier();
 	xt_unregister_target(&masquerade_tg6_reg);
 }
 
diff --git a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
new file mode 100644
index 0000000..7745609
--- /dev/null
+++ b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
@@ -0,0 +1,120 @@
+/*
+ * Copyright (c) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Based on Rusty Russell's IPv6 MASQUERADE target. Development of IPv6
+ * NAT funded by Astaro.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/atomic.h>
+#include <linux/netdevice.h>
+#include <linux/ipv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
+#include <net/netfilter/nf_nat.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
+#include <net/netfilter/ipv6/nf_nat_masquerade.h>
+
+unsigned int
+nf_nat_masquerade_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
+		       const struct net_device *out)
+{
+	enum ip_conntrack_info ctinfo;
+	struct in6_addr src;
+	struct nf_conn *ct;
+	struct nf_nat_range newrange;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
+			    ctinfo == IP_CT_RELATED_REPLY));
+
+	if (ipv6_dev_get_saddr(dev_net(out), out,
+			       &ipv6_hdr(skb)->daddr, 0, &src) < 0)
+		return NF_DROP;
+
+	nfct_nat(ct)->masq_index = out->ifindex;
+
+	newrange.flags		= range->flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.in6	= src;
+	newrange.max_addr.in6	= src;
+	newrange.min_proto	= range->min_proto;
+	newrange.max_proto	= range->max_proto;
+
+	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_SRC);
+}
+EXPORT_SYMBOL_GPL(nf_nat_masquerade_ipv6);
+
+static int device_cmp(struct nf_conn *ct, void *ifindex)
+{
+	const struct nf_conn_nat *nat = nfct_nat(ct);
+
+	if (!nat)
+		return 0;
+	if (nf_ct_l3num(ct) != NFPROTO_IPV6)
+		return 0;
+	return nat->masq_index == (int)(long)ifindex;
+}
+
+static int masq_device_event(struct notifier_block *this,
+			     unsigned long event, void *ptr)
+{
+	const struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct net *net = dev_net(dev);
+
+	if (event == NETDEV_DOWN)
+		nf_ct_iterate_cleanup(net, device_cmp,
+				      (void *)(long)dev->ifindex, 0, 0);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block masq_dev_notifier = {
+	.notifier_call	= masq_device_event,
+};
+
+static int masq_inet_event(struct notifier_block *this,
+			   unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *ifa = ptr;
+	struct netdev_notifier_info info;
+
+	netdev_notifier_info_init(&info, ifa->idev->dev);
+	return masq_device_event(this, event, &info);
+}
+
+static struct notifier_block masq_inet_notifier = {
+	.notifier_call	= masq_inet_event,
+};
+
+static atomic_t masquerade_notifier_refcount = ATOMIC_INIT(0);
+
+void nf_nat_masquerade_ipv6_register_notifier(void)
+{
+	/* check if the notifier is already set */
+	if (atomic_inc_return(&masquerade_notifier_refcount) > 1)
+		return;
+
+	register_netdevice_notifier(&masq_dev_notifier);
+	register_inet6addr_notifier(&masq_inet_notifier);
+}
+EXPORT_SYMBOL_GPL(nf_nat_masquerade_ipv6_register_notifier);
+
+void nf_nat_masquerade_ipv6_unregister_notifier(void)
+{
+	/* check if the notifier still has clients */
+	if (atomic_dec_return(&masquerade_notifier_refcount) > 0)
+		return;
+
+	unregister_inet6addr_notifier(&masq_inet_notifier);
+	unregister_netdevice_notifier(&masq_dev_notifier);
+}
+EXPORT_SYMBOL_GPL(nf_nat_masquerade_ipv6_unregister_notifier);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-- 
1.7.10.4

