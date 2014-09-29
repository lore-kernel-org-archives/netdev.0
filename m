From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/34] netfilter: bridge: move br_netfilter out of the core
Date: Mon, 29 Sep 2014 14:39:21 +0200
Message-ID: <1411994363-8451-33-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34406 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327AbaI2MjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:39:04 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper reported that br_netfilter always registers the hooks since
this is part of the bridge core. This harms performance for people that
don't need this.

This patch modularizes br_netfilter so it can be rmmod'ed, thus,
the hooks can be unregistered. I think the bridge netfilter should have
been a separated module since the beginning, Patrick agreed on that.

Note that this is breaking compatibility for users that expect that
bridge netfilter is going to be available after explicitly 'modprobe
bridge' or via automatic load through brctl.

However, the damage can be easily undone by modprobing br_netfilter.
The bridge core also spots a message to provide a clue to people that
didn't notice that this has been deprecated.

On top of that, the plan is that nftables will not rely on this software
layer, but integrate the connection tracking into the bridge layer to
enable stateful filtering and NAT, which is was bridge netfilter users
seem to require.

This patch still keeps the fake_dst_ops in the bridge core, since this
is required by when the bridge port is initialized. So we can safely
modprobe/rmmod br_netfilter anytime.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h       |    2 +-
 include/linux/skbuff.h                 |   12 ++--
 include/net/neighbour.h                |    2 +-
 include/net/netfilter/ipv4/nf_reject.h |    2 +-
 include/net/netfilter/ipv6/nf_reject.h |    2 +-
 net/Kconfig                            |    7 ++-
 net/bridge/Makefile                    |    5 +-
 net/bridge/br.c                        |   14 +++--
 net/bridge/br_device.c                 |    4 +-
 net/bridge/br_forward.c                |    2 +
 net/bridge/br_input.c                  |    1 +
 net/bridge/br_netfilter.c              |   88 ++++++-----------------------
 net/bridge/br_netlink.c                |    2 +-
 net/bridge/br_nf_core.c                |   96 ++++++++++++++++++++++++++++++++
 net/bridge/br_private.h                |   12 ++--
 net/bridge/br_sysfs_br.c               |    4 +-
 16 files changed, 151 insertions(+), 104 deletions(-)
 create mode 100644 net/bridge/br_nf_core.c

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index fe996d5..c755e49 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -15,7 +15,7 @@ enum nf_br_hook_priorities {
 	NF_BR_PRI_LAST = INT_MAX,
 };
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 
 #define BRNF_PKT_TYPE			0x01
 #define BRNF_BRIDGED_DNAT		0x02
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 07c9fdd..c4ff43f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -156,7 +156,7 @@ struct nf_conntrack {
 };
 #endif
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 struct nf_bridge_info {
 	atomic_t		use;
 	unsigned int		mask;
@@ -560,7 +560,7 @@ struct sk_buff {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct nf_conntrack	*nfct;
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	struct nf_bridge_info	*nf_bridge;
 #endif
 
@@ -2977,7 +2977,7 @@ static inline void nf_conntrack_get(struct nf_conntrack *nfct)
 		atomic_inc(&nfct->use);
 }
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
 {
 	if (nf_bridge && atomic_dec_and_test(&nf_bridge->use))
@@ -2995,7 +2995,7 @@ static inline void nf_reset(struct sk_buff *skb)
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(skb->nf_bridge);
 	skb->nf_bridge = NULL;
 #endif
@@ -3016,7 +3016,7 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 	nf_conntrack_get(src->nfct);
 	dst->nfctinfo = src->nfctinfo;
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	dst->nf_bridge  = src->nf_bridge;
 	nf_bridge_get(src->nf_bridge);
 #endif
@@ -3030,7 +3030,7 @@ static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	nf_conntrack_put(dst->nfct);
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	nf_bridge_put(dst->nf_bridge);
 #endif
 	__nf_copy(dst, src);
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 47f4254..f60558d 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -373,7 +373,7 @@ static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 	return 0;
 }
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 static inline int neigh_hh_bridge(struct hh_cache *hh, struct sk_buff *skb)
 {
 	unsigned int seq, hh_alen;
diff --git a/include/net/netfilter/ipv4/nf_reject.h b/include/net/netfilter/ipv4/nf_reject.h
index 931fbf8..f713b5a 100644
--- a/include/net/netfilter/ipv4/nf_reject.h
+++ b/include/net/netfilter/ipv4/nf_reject.h
@@ -98,7 +98,7 @@ static void nf_send_reset(struct sk_buff *oldskb, int hook)
 
 	nf_ct_attach(nskb, oldskb);
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	/* If we use ip_local_out for bridged traffic, the MAC source on
 	 * the RST will be ours, instead of the destination's.  This confuses
 	 * some routers/firewalls, and they drop the packet.  So we need to
diff --git a/include/net/netfilter/ipv6/nf_reject.h b/include/net/netfilter/ipv6/nf_reject.h
index 710d17e..7a10cfc 100644
--- a/include/net/netfilter/ipv6/nf_reject.h
+++ b/include/net/netfilter/ipv6/nf_reject.h
@@ -147,7 +147,7 @@ static void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 
 	nf_ct_attach(nskb, oldskb);
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	/* If we use ip6_local_out for bridged traffic, the MAC source on
 	 * the RST will be ours, instead of the destination's.  This confuses
 	 * some routers/firewalls, and they drop the packet.  So we need to
diff --git a/net/Kconfig b/net/Kconfig
index 4051fdf..dc5d700 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -176,10 +176,11 @@ config NETFILTER_ADVANCED
 	  If unsure, say Y.
 
 config BRIDGE_NETFILTER
-	bool "Bridged IP/ARP packets filtering"
-	depends on BRIDGE && NETFILTER && INET
+	tristate "Bridged IP/ARP packets filtering"
+	depends on (BRIDGE || BRIDGE=n)
+	depends on NETFILTER && INET
 	depends on NETFILTER_ADVANCED
-	default y
+	default m
 	---help---
 	  Enabling this option will let arptables resp. iptables see bridged
 	  ARP resp. IP traffic. If you want a bridging firewall, you probably
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 8590b94..5e3eac5 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -6,11 +6,12 @@ obj-$(CONFIG_BRIDGE) += bridge.o
 
 bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
 			br_ioctl.o br_stp.o br_stp_bpdu.o \
-			br_stp_if.o br_stp_timer.o br_netlink.o
+			br_stp_if.o br_stp_timer.o br_netlink.o \
+			br_nf_core.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
-bridge-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
+obj-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 1a755a1..44425af 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -161,7 +161,7 @@ static int __init br_init(void)
 	if (err)
 		goto err_out1;
 
-	err = br_netfilter_init();
+	err = br_nf_core_init();
 	if (err)
 		goto err_out2;
 
@@ -179,11 +179,16 @@ static int __init br_init(void)
 	br_fdb_test_addr_hook = br_fdb_test_addr;
 #endif
 
+	pr_info("bridge: automatic filtering via arp/ip/ip6tables has been "
+		"deprecated. Update your scripts to load br_netfilter if you "
+		"need this.\n");
+
 	return 0;
+
 err_out4:
 	unregister_netdevice_notifier(&br_device_notifier);
 err_out3:
-	br_netfilter_fini();
+	br_nf_core_fini();
 err_out2:
 	unregister_pernet_subsys(&br_net_ops);
 err_out1:
@@ -196,20 +201,17 @@ err_out:
 static void __exit br_deinit(void)
 {
 	stp_proto_unregister(&br_stp_proto);
-
 	br_netlink_fini();
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
-
 	unregister_pernet_subsys(&br_net_ops);
 
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
-	br_netfilter_fini();
+	br_nf_core_fini();
 #if IS_ENABLED(CONFIG_ATM_LANE)
 	br_fdb_test_addr_hook = NULL;
 #endif
-
 	br_fdb_fini();
 }
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 568cccd..659cac1 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -36,7 +36,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 vid = 0;
 
 	rcu_read_lock();
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
 		br_nf_pre_routing_finish_bridge_slow(skb);
 		rcu_read_unlock();
@@ -167,7 +167,7 @@ static int br_change_mtu(struct net_device *dev, int new_mtu)
 
 	dev->mtu = new_mtu;
 
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	/* remember the MTU in the rtable for PMTU */
 	dst_metric_set(&br->fake_rtable.dst, RTAX_MTU, new_mtu);
 #endif
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 056b67b..992ec49 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -49,6 +49,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(br_dev_queue_push_xmit);
 
 int br_forward_finish(struct sk_buff *skb)
 {
@@ -56,6 +57,7 @@ int br_forward_finish(struct sk_buff *skb)
 		       br_dev_queue_push_xmit);
 
 }
+EXPORT_SYMBOL_GPL(br_forward_finish);
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 366c436..6fd5522 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -140,6 +140,7 @@ drop:
 	kfree_skb(skb);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(br_handle_frame_finish);
 
 /* note: already called with rcu_read_lock */
 static int br_handle_local_finish(struct sk_buff *skb)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 61929a7..97e4393 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -111,66 +111,6 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
 	 brnf_filter_pppoe_tagged)
 
-static void fake_update_pmtu(struct dst_entry *dst, struct sock *sk,
-			     struct sk_buff *skb, u32 mtu)
-{
-}
-
-static void fake_redirect(struct dst_entry *dst, struct sock *sk,
-			  struct sk_buff *skb)
-{
-}
-
-static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long old)
-{
-	return NULL;
-}
-
-static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst,
-					   struct sk_buff *skb,
-					   const void *daddr)
-{
-	return NULL;
-}
-
-static unsigned int fake_mtu(const struct dst_entry *dst)
-{
-	return dst->dev->mtu;
-}
-
-static struct dst_ops fake_dst_ops = {
-	.family =		AF_INET,
-	.protocol =		cpu_to_be16(ETH_P_IP),
-	.update_pmtu =		fake_update_pmtu,
-	.redirect =		fake_redirect,
-	.cow_metrics =		fake_cow_metrics,
-	.neigh_lookup =		fake_neigh_lookup,
-	.mtu =			fake_mtu,
-};
-
-/*
- * Initialize bogus route table used to keep netfilter happy.
- * Currently, we fill in the PMTU entry because netfilter
- * refragmentation needs it, and the rt_flags entry because
- * ipt_REJECT needs it.  Future netfilter modules might
- * require us to fill additional fields.
- */
-static const u32 br_dst_default_metrics[RTAX_MAX] = {
-	[RTAX_MTU - 1] = 1500,
-};
-
-void br_netfilter_rtable_init(struct net_bridge *br)
-{
-	struct rtable *rt = &br->fake_rtable;
-
-	atomic_set(&rt->dst.__refcnt, 1);
-	rt->dst.dev = br->dev;
-	rt->dst.path = &rt->dst;
-	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
-	rt->dst.flags	= DST_NOXFRM | DST_FAKE_RTABLE;
-	rt->dst.ops = &fake_dst_ops;
-}
-
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
@@ -1031,38 +971,42 @@ static struct ctl_table brnf_table[] = {
 };
 #endif
 
-int __init br_netfilter_init(void)
+static int __init br_netfilter_init(void)
 {
 	int ret;
 
-	ret = dst_entries_init(&fake_dst_ops);
+	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 	if (ret < 0)
 		return ret;
 
-	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
-	if (ret < 0) {
-		dst_entries_destroy(&fake_dst_ops);
-		return ret;
-	}
 #ifdef CONFIG_SYSCTL
 	brnf_sysctl_header = register_net_sysctl(&init_net, "net/bridge", brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
-		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
-		dst_entries_destroy(&fake_dst_ops);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto err1;
 	}
 #endif
 	printk(KERN_NOTICE "Bridge firewalling registered\n");
 	return 0;
+err1:
+	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	return ret;
 }
 
-void br_netfilter_fini(void)
+static void __exit br_netfilter_fini(void)
 {
 	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
-	dst_entries_destroy(&fake_dst_ops);
 }
+
+module_init(br_netfilter_init);
+module_exit(br_netfilter_fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Lennert Buytenhek <buytenh@gnu.org>");
+MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
+MODULE_DESCRIPTION("Linux ethernet netfilter firewall bridge");
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 90a91e1..0fa66b8 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -602,7 +602,7 @@ out_af:
 	return err;
 }
 
-void __exit br_netlink_fini(void)
+void br_netlink_fini(void)
 {
 	br_mdb_uninit();
 	rtnl_af_unregister(&br_af_ops);
diff --git a/net/bridge/br_nf_core.c b/net/bridge/br_nf_core.c
new file mode 100644
index 0000000..387cb3b
--- /dev/null
+++ b/net/bridge/br_nf_core.c
@@ -0,0 +1,96 @@
+/*
+ *	Handle firewalling core
+ *	Linux ethernet bridge
+ *
+ *	Authors:
+ *	Lennert Buytenhek		<buytenh@gnu.org>
+ *	Bart De Schuymer		<bdschuym@pandora.be>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	Lennert dedicates this file to Kerstin Wurdinger.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/in_route.h>
+#include <linux/inetdevice.h>
+#include <net/route.h>
+
+#include "br_private.h"
+#ifdef CONFIG_SYSCTL
+#include <linux/sysctl.h>
+#endif
+
+static void fake_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			     struct sk_buff *skb, u32 mtu)
+{
+}
+
+static void fake_redirect(struct dst_entry *dst, struct sock *sk,
+			  struct sk_buff *skb)
+{
+}
+
+static u32 *fake_cow_metrics(struct dst_entry *dst, unsigned long old)
+{
+	return NULL;
+}
+
+static struct neighbour *fake_neigh_lookup(const struct dst_entry *dst,
+					   struct sk_buff *skb,
+					   const void *daddr)
+{
+	return NULL;
+}
+
+static unsigned int fake_mtu(const struct dst_entry *dst)
+{
+	return dst->dev->mtu;
+}
+
+static struct dst_ops fake_dst_ops = {
+	.family		= AF_INET,
+	.protocol	= cpu_to_be16(ETH_P_IP),
+	.update_pmtu	= fake_update_pmtu,
+	.redirect	= fake_redirect,
+	.cow_metrics	= fake_cow_metrics,
+	.neigh_lookup	= fake_neigh_lookup,
+	.mtu		= fake_mtu,
+};
+
+/*
+ * Initialize bogus route table used to keep netfilter happy.
+ * Currently, we fill in the PMTU entry because netfilter
+ * refragmentation needs it, and the rt_flags entry because
+ * ipt_REJECT needs it.  Future netfilter modules might
+ * require us to fill additional fields.
+ */
+static const u32 br_dst_default_metrics[RTAX_MAX] = {
+	[RTAX_MTU - 1] = 1500,
+};
+
+void br_netfilter_rtable_init(struct net_bridge *br)
+{
+	struct rtable *rt = &br->fake_rtable;
+
+	atomic_set(&rt->dst.__refcnt, 1);
+	rt->dst.dev = br->dev;
+	rt->dst.path = &rt->dst;
+	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
+	rt->dst.flags	= DST_NOXFRM | DST_FAKE_RTABLE;
+	rt->dst.ops = &fake_dst_ops;
+}
+
+int __init br_nf_core_init(void)
+{
+	return dst_entries_init(&fake_dst_ops);
+}
+
+void br_nf_core_fini(void)
+{
+	dst_entries_destroy(&fake_dst_ops);
+}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 62a7fa2..d304d75 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -221,7 +221,7 @@ struct net_bridge
 	struct pcpu_sw_netstats		__percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	struct rtable 			fake_rtable;
 	bool				nf_call_iptables;
 	bool				nf_call_ip6tables;
@@ -751,13 +751,13 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 #endif
 
 /* br_netfilter.c */
-#ifdef CONFIG_BRIDGE_NETFILTER
-int br_netfilter_init(void);
-void br_netfilter_fini(void);
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+int br_nf_core_init(void);
+void br_nf_core_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
 #else
-#define br_netfilter_init()	(0)
-#define br_netfilter_fini()	do { } while (0)
+static inline int br_nf_core_init(void) { return 0; }
+static inline void br_nf_core_fini(void) {}
 #define br_netfilter_rtable_init(x)
 #endif
 
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c9e2572..cb431c6 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -629,7 +629,7 @@ static ssize_t multicast_startup_query_interval_store(
 }
 static DEVICE_ATTR_RW(multicast_startup_query_interval);
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 static ssize_t nf_call_iptables_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
@@ -763,7 +763,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_query_response_interval.attr,
 	&dev_attr_multicast_startup_query_interval.attr,
 #endif
-#ifdef CONFIG_BRIDGE_NETFILTER
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	&dev_attr_nf_call_iptables.attr,
 	&dev_attr_nf_call_ip6tables.attr,
 	&dev_attr_nf_call_arptables.attr,
-- 
1.7.10.4
