From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 1/2] mpls: packet stats
Date: Fri, 5 Feb 2016 19:27:51 +0000
Message-ID: <1454700472-13543-2-git-send-email-rshearma@brocade.com>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:28679 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753233AbcBET2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 14:28:36 -0500
In-Reply-To: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having MPLS packet stats is useful for observing network operation and
for diagnosing network problems. In the absence of anything better,
use RFCs for MIBs defining MPLS stats for guidance on the semantics of
the stats to expose. RFC3813 details two per-interface packet stats
that should be provided (label lookup failures and fragmented packets)
and also provides interpretation of RFC2863 for other per-interface
stats (in/out ucast, mcast and bcast, in/out discards and errors and
in unknown protos).

Multicast, fragment and broadcast packet counters are printed, but not
stored to allow for future implementation of current standards or
future standards without user-space having to change.

All the introduced fields are 64-bit, even error ones, to ensure no
overflow with long uptimes. Per-CPU counters are used to avoid
cache-line contention on the commonly used fields. The other fields
have also been made per-CPU for code to avoid performance problems in
error conditions on the assumption that on some platforms the cost of
atomic operations could be more pexpensive than sending the packet
(which is what would be done in the success case). If that's not the
case, we could instead not use per-CPU counters for these fields.

The IPv6 proc code was used as an inspiration for the proc code
here, both in terms of the implementation as well as the location of
the per-device stats proc files: /proc/net/dev_snmp_mpls/<dev>.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/net/netns/mpls.h |   1 +
 net/mpls/Makefile        |   1 +
 net/mpls/af_mpls.c       | 135 ++++++++++++++++++++++++++++++++++++-----------
 net/mpls/internal.h      |  93 ++++++++++++++++++++++++++++++--
 net/mpls/mpls_iptunnel.c |  11 +++-
 net/mpls/proc.c          | 128 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 334 insertions(+), 35 deletions(-)
 create mode 100644 net/mpls/proc.c

diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
index d29203651c01..3062b0aa3a08 100644
--- a/include/net/netns/mpls.h
+++ b/include/net/netns/mpls.h
@@ -12,6 +12,7 @@ struct netns_mpls {
 	size_t platform_labels;
 	struct mpls_route __rcu * __rcu *platform_label;
 	struct ctl_table_header *ctl;
+	struct proc_dir_entry *proc_net_devsnmp;
 };
 
 #endif /* __NETNS_MPLS_H__ */
diff --git a/net/mpls/Makefile b/net/mpls/Makefile
index 9ca923625016..6fdd61b9eae3 100644
--- a/net/mpls/Makefile
+++ b/net/mpls/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_MPLS_ROUTING) += mpls_router.o
 obj-$(CONFIG_MPLS_IPTUNNEL) += mpls_iptunnel.o
 
 mpls_router-y := af_mpls.o
+mpls_router-$(CONFIG_PROC_FS) += proc.o
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index b18c5ed42d95..6b3c96e2b21f 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -8,6 +8,7 @@
 #include <linux/ipv6.h>
 #include <linux/mpls.h>
 #include <linux/vmalloc.h>
+#include <linux/percpu.h>
 #include <net/ip.h>
 #include <net/dst.h>
 #include <net/sock.h>
@@ -17,8 +18,8 @@
 #include <net/netns/generic.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
-#include <net/addrconf.h>
 #endif
+#include <net/addrconf.h>
 #include <net/nexthop.h>
 #include "internal.h"
 
@@ -48,11 +49,6 @@ static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
 	return rt;
 }
 
-static inline struct mpls_dev *mpls_dev_get(const struct net_device *dev)
-{
-	return rcu_dereference_rtnl(dev->mpls_ptr);
-}
-
 bool mpls_output_possible(const struct net_device *dev)
 {
 	return dev && (dev->flags & IFF_UP) && netif_carrier_ok(dev);
@@ -98,6 +94,29 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 }
 EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
+void mpls_stats_inc_outucastpkts(struct net_device *dev,
+				 const struct sk_buff *skb)
+{
+	struct mpls_dev *mdev;
+	struct inet6_dev *in6dev;
+
+	if (skb->protocol == htons(ETH_P_MPLS_UC)) {
+		mdev = mpls_dev_get(dev);
+		if (mdev)
+			MPLS_INC_STATS_LEN(mdev, skb->len,
+					   MPLS_IFSTATS_MIB_OUTUCASTPKTS,
+					   MPLS_IFSTATS_MIB_OUTOCTETS);
+	} else if (skb->protocol == htons(ETH_P_IP)) {
+		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		in6dev = __in6_dev_get(dev);
+		if (in6dev)
+			IP6_UPD_PO_STATS(dev_net(dev), in6dev,
+					 IPSTATS_MIB_OUT, skb->len);
+	}
+}
+EXPORT_SYMBOL_GPL(mpls_stats_inc_outucastpkts);
+
 static u32 mpls_multipath_hash(struct mpls_route *rt,
 			       struct sk_buff *skb, bool bos)
 {
@@ -253,6 +272,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	struct mpls_nh *nh;
 	struct mpls_entry_decoded dec;
 	struct net_device *out_dev;
+	struct mpls_dev *out_mdev;
 	struct mpls_dev *mdev;
 	unsigned int hh_len;
 	unsigned int new_header_size;
@@ -262,17 +282,25 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	/* Careful this entire function runs inside of an rcu critical section */
 
 	mdev = mpls_dev_get(dev);
-	if (!mdev || !mdev->input_enabled)
+	if (!mdev)
 		goto drop;
 
-	if (skb->pkt_type != PACKET_HOST)
+	MPLS_INC_STATS_LEN(mdev, skb->len, MPLS_IFSTATS_MIB_INUCASTPKTS,
+			   MPLS_IFSTATS_MIB_INOCTETS);
+
+	if (!mdev->input_enabled) {
+		MPLS_INC_STATS(mdev, MPLS_IFSTATS_MIB_INDISCARDS);
 		goto drop;
+	}
+
+	if (skb->pkt_type != PACKET_HOST)
+		goto err;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
-		goto drop;
+		goto err;
 
 	if (!pskb_may_pull(skb, sizeof(*hdr)))
-		goto drop;
+		goto err;
 
 	/* Read and decode the label */
 	hdr = mpls_hdr(skb);
@@ -285,33 +313,35 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	skb_orphan(skb);
 
 	rt = mpls_route_input_rcu(net, dec.label);
-	if (!rt)
+	if (!rt) {
+		MPLS_INC_STATS(mdev, MPLS_LSR_MIB_INLABELLOOKUPFAILURES);
 		goto drop;
+	}
 
 	nh = mpls_select_multipath(rt, skb, dec.bos);
 	if (!nh)
-		goto drop;
-
-	/* Find the output device */
-	out_dev = rcu_dereference(nh->nh_dev);
-	if (!mpls_output_possible(out_dev))
-		goto drop;
+		goto err;
 
 	if (skb_warn_if_lro(skb))
-		goto drop;
+		goto err;
 
 	skb_forward_csum(skb);
 
 	/* Verify ttl is valid */
 	if (dec.ttl <= 1)
-		goto drop;
+		goto err;
 	dec.ttl -= 1;
 
+	/* Find the output device */
+	out_dev = rcu_dereference(nh->nh_dev);
+	if (!mpls_output_possible(out_dev))
+		goto tx_err;
+
 	/* Verify the destination can hold the packet */
 	new_header_size = mpls_nh_header_size(nh);
 	mtu = mpls_dev_mtu(out_dev);
 	if (mpls_pkt_too_big(skb, mtu - new_header_size))
-		goto drop;
+		goto tx_err;
 
 	hh_len = LL_RESERVED_SPACE(out_dev);
 	if (!out_dev->header_ops)
@@ -319,7 +349,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 
 	/* Ensure there is enough space for the headers in the skb */
 	if (skb_cow(skb, hh_len + new_header_size))
-		goto drop;
+		goto tx_err;
 
 	skb->dev = out_dev;
 	skb->protocol = htons(ETH_P_MPLS_UC);
@@ -327,7 +357,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	if (unlikely(!new_header_size && dec.bos)) {
 		/* Penultimate hop popping */
 		if (!mpls_egress(rt, skb, dec))
-			goto drop;
+			goto err;
 	} else {
 		bool bos;
 		int i;
@@ -343,6 +373,8 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
+	mpls_stats_inc_outucastpkts(out_dev, skb);
+
 	/* If via wasn't specified then send out using device address */
 	if (nh->nh_via_table == MPLS_NEIGH_TABLE_UNSPEC)
 		err = neigh_xmit(NEIGH_LINK_TABLE, out_dev,
@@ -355,6 +387,13 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 				    __func__, err);
 	return 0;
 
+tx_err:
+	out_mdev = mpls_dev_get(out_dev);
+	if (out_mdev)
+		MPLS_INC_STATS(out_mdev, MPLS_IFSTATS_MIB_OUTERRORS);
+	goto drop;
+err:
+	MPLS_INC_STATS(mdev, MPLS_IFSTATS_MIB_INERRORS);
 drop:
 	kfree_skb(skb);
 	return NET_RX_DROP;
@@ -864,8 +903,7 @@ static const struct ctl_table mpls_dev_table[] = {
 	{ }
 };
 
-static int mpls_dev_sysctl_register(struct net_device *dev,
-				    struct mpls_dev *mdev)
+static int mpls_dev_sysctl_register(struct mpls_dev *mdev)
 {
 	char path[sizeof("net/mpls/conf/") + IFNAMSIZ];
 	struct ctl_table *table;
@@ -881,9 +919,9 @@ static int mpls_dev_sysctl_register(struct net_device *dev,
 	for (i = 0; i < ARRAY_SIZE(mpls_dev_table); i++)
 		table[i].data = (char *)mdev + (uintptr_t)table[i].data;
 
-	snprintf(path, sizeof(path), "net/mpls/conf/%s", dev->name);
+	snprintf(path, sizeof(path), "net/mpls/conf/%s", mdev->dev->name);
 
-	mdev->sysctl = register_net_sysctl(dev_net(dev), path, table);
+	mdev->sysctl = register_net_sysctl(dev_net(mdev->dev), path, table);
 	if (!mdev->sysctl)
 		goto free;
 
@@ -908,6 +946,7 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 {
 	struct mpls_dev *mdev;
 	int err = -ENOMEM;
+	int i;
 
 	ASSERT_RTNL();
 
@@ -915,19 +954,47 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 	if (!mdev)
 		return ERR_PTR(err);
 
-	err = mpls_dev_sysctl_register(dev, mdev);
+	mdev->stats = alloc_percpu(struct mpls_stats);
+	if (!mdev->stats)
+		goto free;
+
+	for_each_possible_cpu(i) {
+		struct mpls_stats *mpls_stats;
+
+		mpls_stats = per_cpu_ptr(mdev->stats, i);
+		u64_stats_init(&mpls_stats->syncp);
+	}
+
+	mdev->dev = dev;
+
+	err = mpls_dev_sysctl_register(mdev);
 	if (err)
 		goto free;
 
+	err = mpls_snmp_register_dev(mdev);
+	if (err)
+		goto sysctl_unreg;
+
 	rcu_assign_pointer(dev->mpls_ptr, mdev);
 
 	return mdev;
 
+sysctl_unreg:
+	mpls_dev_sysctl_unregister(mdev);
 free:
+	free_percpu(mdev->stats);
 	kfree(mdev);
 	return ERR_PTR(err);
 }
 
+static void mpls_dev_destroy_rcu(struct rcu_head *head)
+{
+	struct mpls_dev *mdev = container_of(head, struct mpls_dev, rcu);
+
+	free_percpu(mdev->stats);
+	kfree(mdev);
+}
+
 static void mpls_ifdown(struct net_device *dev, int event)
 {
 	struct mpls_route __rcu **platform_label;
@@ -1043,8 +1110,9 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 		mdev = mpls_dev_get(dev);
 		if (mdev) {
 			mpls_dev_sysctl_unregister(mdev);
+			mpls_snmp_unregister_dev(mdev);
 			RCU_INIT_POINTER(dev->mpls_ptr, NULL);
-			kfree_rcu(mdev, rcu);
+			call_rcu(&mdev->rcu, mpls_dev_destroy_rcu);
 		}
 		break;
 	case NETDEV_CHANGENAME:
@@ -1053,7 +1121,12 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 			int err;
 
 			mpls_dev_sysctl_unregister(mdev);
-			err = mpls_dev_sysctl_register(dev, mdev);
+			err = mpls_dev_sysctl_register(mdev);
+			if (err)
+				return notifier_from_errno(err);
+
+			mpls_snmp_unregister_dev(mdev);
+			err = mpls_snmp_register_dev(mdev);
 			if (err)
 				return notifier_from_errno(err);
 		}
@@ -1664,7 +1737,7 @@ static int mpls_net_init(struct net *net)
 		return -ENOMEM;
 	}
 
-	return 0;
+	return mpls_proc_init_net(net);
 }
 
 static void mpls_net_exit(struct net *net)
@@ -1674,6 +1747,8 @@ static void mpls_net_exit(struct net *net)
 	struct ctl_table *table;
 	unsigned int index;
 
+	mpls_proc_exit_net(net);
+
 	table = net->mpls.ctl->ctl_table_arg;
 	unregister_net_sysctl_table(net->mpls.ctl);
 	kfree(table);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 732a5c17e986..b39770ff2307 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -1,6 +1,34 @@
 #ifndef MPLS_INTERNAL_H
 #define MPLS_INTERNAL_H
 
+enum {
+	/* RFC2863 ifEntry/ifXEntry commonly used fields */
+
+	MPLS_IFSTATS_MIB_INOCTETS,		/* ifInOctets */
+	MPLS_IFSTATS_MIB_INUCASTPKTS,		/* ifInUcastPkts */
+	MPLS_IFSTATS_MIB_OUTOCTETS,		/* ifOutOctets */
+	MPLS_IFSTATS_MIB_OUTUCASTPKTS,		/* ifOutUcastPkts */
+
+	/* RFC2863 ifEntry/ifXEntry other fields */
+
+	MPLS_IFSTATS_MIB_INDISCARDS,		/* ifInDiscards */
+	MPLS_IFSTATS_MIB_INERRORS,		/* ifInErrors */
+	MPLS_IFSTATS_MIB_OUTDISCARDS,		/* ifOutDiscards */
+	MPLS_IFSTATS_MIB_OUTERRORS,		/* ifOutErrors */
+	/* ifHCInMulticastPkts, ifHCOutMulticastPkts,
+	 * ifHCOutBroadcastPkts and ifHCInBroadcastPkts not stored
+	 */
+
+	/* RFC3813 mplsInterfacePerfEntry fields */
+
+	/* mplsInterfacePerfInLabelLookupFailures and RFC2863
+	 * ifUnknownProtos
+	 */
+	MPLS_LSR_MIB_INLABELLOOKUPFAILURES,
+	/* mplsInterfacePerfOutFragmentedPkts not stored */
+	MPLS_MIB_MAX
+};
+
 struct mpls_shim_hdr {
 	__be32 label_stack_entry;
 };
@@ -12,13 +40,60 @@ struct mpls_entry_decoded {
 	u8 bos;
 };
 
+struct mpls_stats {
+	u64			mib[MPLS_MIB_MAX];
+	struct u64_stats_sync	syncp;
+};
+
 struct mpls_dev {
-	int			input_enabled;
+	struct net_device		*dev;
+	int				input_enabled;
+
+	struct mpls_stats __percpu	*stats;
 
-	struct ctl_table_header *sysctl;
-	struct rcu_head		rcu;
+	struct ctl_table_header		*sysctl;
+	struct proc_dir_entry		*proc_dir_entry_snmp;
+	struct rcu_head			rcu;
 };
 
+#if BITS_PER_LONG == 32
+
+#define MPLS_INC_STATS_LEN(mdev, len, pkts_field, bytes_field)		\
+	do {								\
+		__typeof__(*(mdev)->stats) *ptr =			\
+			raw_cpu_ptr((mdev)->stats);			\
+		local_bh_disable();					\
+		u64_stats_update_begin(&ptr->syncp);			\
+		ptr->mib[pkts_field]++;					\
+		ptr->mib[bytes_field] += (len);				\
+		u64_stats_update_end(&ptr->syncp);			\
+		local_bh_enable();					\
+	} while (0)
+
+#define MPLS_INC_STATS(mdev, field)					\
+	do {								\
+		__typeof__(*(mdev)->stats) *ptr =			\
+			raw_cpu_ptr((mdev)->stats);			\
+		local_bh_disable();					\
+		u64_stats_update_begin(&ptr->syncp);			\
+		ptr->mib[field]++;					\
+		u64_stats_update_end(&ptr->syncp);			\
+		local_bh_enable();					\
+	} while (0)
+
+#else
+
+#define MPLS_INC_STATS_LEN(mdev, len, pkts_field, bytes_field)		\
+	do {								\
+		this_cpu_inc(mdev->stats->mib[pkts_field]);		\
+		this_cpu_add(mdev->stats->mib[bytes_field], (len));	\
+	} while (0)
+
+#define MPLS_INC_STATS(mdev, field)			\
+	this_cpu_inc(mdev->stats->mib[field])
+
+#endif
+
 struct sk_buff;
 
 #define LABEL_NOT_SPECIFIED (1 << 20)
@@ -122,6 +197,11 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 	return result;
 }
 
+static inline struct mpls_dev *mpls_dev_get(const struct net_device *dev)
+{
+	return rcu_dereference_rtnl(dev->mpls_ptr);
+}
+
 int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u32 max_labels, u8 *labels,
@@ -131,5 +211,12 @@ int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
+void mpls_stats_inc_outucastpkts(struct net_device *dev,
+				 const struct sk_buff *skb);
+
+int mpls_snmp_register_dev(struct mpls_dev *idev);
+int mpls_snmp_unregister_dev(struct mpls_dev *idev);
+int mpls_proc_init_net(struct net *net);
+void mpls_proc_exit_net(struct net *net);
 
 #endif /* MPLS_INTERNAL_H */
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index fb31aa87de81..94d8837d42f6 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -48,11 +48,15 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = NULL;
 	struct rt6_info *rt6 = NULL;
+	struct mpls_dev *out_mdev;
 	int err = 0;
 	bool bos;
 	int i;
 	unsigned int ttl;
 
+	/* Find the output device */
+	out_dev = dst->dev;
+
 	/* Obtain the ttl */
 	if (dst->ops->family == AF_INET) {
 		ttl = ip_hdr(skb)->ttl;
@@ -66,8 +70,6 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	skb_orphan(skb);
 
-	/* Find the output device */
-	out_dev = dst->dev;
 	if (!mpls_output_possible(out_dev) ||
 	    !dst->lwtstate || skb_warn_if_lro(skb))
 		goto drop;
@@ -105,6 +107,8 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 		bos = false;
 	}
 
+	mpls_stats_inc_outucastpkts(out_dev, skb);
+
 	if (rt)
 		err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
 				 skb);
@@ -118,6 +122,9 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	return 0;
 
 drop:
+	out_mdev = mpls_dev_get(out_dev);
+	if (out_mdev)
+		MPLS_INC_STATS(out_mdev, MPLS_IFSTATS_MIB_OUTERRORS);
 	kfree_skb(skb);
 	return -EINVAL;
 }
diff --git a/net/mpls/proc.c b/net/mpls/proc.c
new file mode 100644
index 000000000000..f18f81ffad33
--- /dev/null
+++ b/net/mpls/proc.c
@@ -0,0 +1,128 @@
+/*
+ * Based on net/ipv6/proc.c.
+ */
+#include <linux/socket.h>
+#include <linux/net.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/stddef.h>
+#include <linux/export.h>
+#include <linux/mpls.h>
+#include <linux/netdevice.h>
+#include <net/net_namespace.h>
+#include <net/snmp.h>
+#include <net/ip.h>
+#include "internal.h"
+
+static const struct snmp_mib mpls_snmp_list[] = {
+	/* RFC 2863 ifEntry (interpreted by RFC 3813) commonly used fields */
+	SNMP_MIB_ITEM("ifInOctets", MPLS_IFSTATS_MIB_INOCTETS),
+	SNMP_MIB_ITEM("ifInUcastPkts", MPLS_IFSTATS_MIB_INUCASTPKTS),
+	SNMP_MIB_ITEM("ifOutOctets", MPLS_IFSTATS_MIB_OUTOCTETS),
+	SNMP_MIB_ITEM("ifOutUcastPkts", MPLS_IFSTATS_MIB_OUTUCASTPKTS),
+
+	/* RFC2863 ifEntry/ifXEntry other fields */
+	SNMP_MIB_ITEM("ifInDiscards", MPLS_IFSTATS_MIB_INDISCARDS),
+	SNMP_MIB_ITEM("ifInErrors", MPLS_IFSTATS_MIB_INERRORS),
+	SNMP_MIB_ITEM("ifInUnknownProtos", MPLS_LSR_MIB_INLABELLOOKUPFAILURES),
+	SNMP_MIB_ITEM("ifOutDiscards", MPLS_IFSTATS_MIB_OUTDISCARDS),
+	SNMP_MIB_ITEM("ifOutErrors", MPLS_IFSTATS_MIB_OUTERRORS),
+
+	/* RFC3813 mplsInterfacePerfEntry fields */
+	SNMP_MIB_ITEM("mplsInterfacePerfInLabelLookupFailures",
+		      MPLS_LSR_MIB_INLABELLOOKUPFAILURES),
+	SNMP_MIB_SENTINEL
+};
+
+static void
+mpls_snmp_seq_show_item64(struct seq_file *seq, void __percpu *mib,
+			  const struct snmp_mib *itemlist, size_t syncpoff)
+{
+	int i;
+
+	for (i = 0; itemlist[i].name; i++)
+		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name,
+			   snmp_fold_field64(mib, itemlist[i].entry, syncpoff));
+}
+
+static int mpls_snmp_dev_seq_show(struct seq_file *seq, void *v)
+{
+	struct mpls_dev *mdev = (struct mpls_dev *)seq->private;
+
+	seq_printf(seq, "%-32s\t%u\n", "ifIndex", mdev->dev->ifindex);
+	mpls_snmp_seq_show_item64(seq, mdev->stats,
+				  mpls_snmp_list,
+				  offsetof(struct mpls_stats, syncp));
+	/* Fragmentation, multicast and broadcast not supported by
+	 * MPLS now, but in case they ever are supported in the future
+	 * provide ease of change for userspace by printing zero values
+	 */
+	seq_printf(seq, "%-32s\t0\n", "mplsInterfacePerfOutFragmentedPkts");
+	seq_printf(seq, "%-32s\t0\n", "ifHCInMulticastPkts");
+	seq_printf(seq, "%-32s\t0\n", "ifHCOutMulticastPkts");
+	seq_printf(seq, "%-32s\t0\n", "ifHCInBroadcastPkts");
+	seq_printf(seq, "%-32s\t0\n", "ifHCOutBroadcastPkts");
+
+	return 0;
+}
+
+static int mpls_snmp_dev_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mpls_snmp_dev_seq_show, PDE_DATA(inode));
+}
+
+static const struct file_operations mpls_snmp_dev_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = mpls_snmp_dev_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release,
+};
+
+int mpls_snmp_register_dev(struct mpls_dev *mdev)
+{
+	struct proc_dir_entry *p;
+	struct net *net;
+
+	if (!mdev || !mdev->dev)
+		return -EINVAL;
+
+	net = dev_net(mdev->dev);
+	if (!net->mpls.proc_net_devsnmp)
+		return -ENOENT;
+
+	p = proc_create_data(mdev->dev->name, S_IRUGO,
+			     net->mpls.proc_net_devsnmp,
+			     &mpls_snmp_dev_seq_fops, mdev);
+	if (!p)
+		return -ENOMEM;
+
+	mdev->proc_dir_entry_snmp = p;
+	return 0;
+}
+
+int mpls_snmp_unregister_dev(struct mpls_dev *mdev)
+{
+	struct net *net = dev_net(mdev->dev);
+
+	if (!net->mpls.proc_net_devsnmp)
+		return -ENOENT;
+	if (!mdev->proc_dir_entry_snmp)
+		return -EINVAL;
+	proc_remove(mdev->proc_dir_entry_snmp);
+	mdev->proc_dir_entry_snmp = NULL;
+	return 0;
+}
+
+int mpls_proc_init_net(struct net *net)
+{
+	net->mpls.proc_net_devsnmp = proc_mkdir("dev_snmp_mpls", net->proc_net);
+	if (!net->mpls.proc_net_devsnmp)
+		return -ENOMEM;
+	return 0;
+}
+
+void mpls_proc_exit_net(struct net *net)
+{
+	remove_proc_entry("dev_snmp_mpls", net->proc_net);
+}
-- 
2.1.4
