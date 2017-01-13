From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 2/2] mpls: Packet stats
Date: Fri, 13 Jan 2017 18:14:13 +0000
Message-ID: <1484331253-5908-3-git-send-email-rshearma@brocade.com>
References: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>, <ebiederm@xmission.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53892 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750789AbdAMSPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:15:20 -0500
In-Reply-To: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having MPLS packet stats is useful for observing network operation and
for diagnosing network problems. In the absence of anything better,
RFC2863 and RFC3813 are used for guidance for which stats to expose
and the semantics of them. In particular rx_noroutes maps to in
unknown protos in RFC2863. The stats are exposed to userspace via
AF_MPLS attributes embedded in the IFLA_STATS_AF_SPEC attribute of
RTM_GETSTATS messages.

All the introduced fields are 64-bit, even error ones, to ensure no
overflow with long uptimes. Per-CPU counters are used to avoid
cache-line contention on the commonly used fields. The other fields
have also been made per-CPU for code to avoid performance problems in
error conditions on the assumption that on some platforms the cost of
atomic operations could be more expensive than sending the packet
(which is what would be done in the success case). If that's not the
case, we could instead not use per-CPU counters for these fields.

Only unicast and non-fragment are exposed at the moment, but other
counters can be exposed in the future either by adding to the end of
struct mpls_link_stats or by additional netlink attributes in the
AF_MPLS IFLA_STATS_AF_SPEC nested attribute.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/uapi/linux/mpls.h |  30 ++++++++
 net/mpls/af_mpls.c        | 179 ++++++++++++++++++++++++++++++++++++++++------
 net/mpls/internal.h       |  58 ++++++++++++++-
 net/mpls/mpls_iptunnel.c  |  11 ++-
 4 files changed, 250 insertions(+), 28 deletions(-)

diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
index 24a6cb1aec86..77a19dfe3990 100644
--- a/include/uapi/linux/mpls.h
+++ b/include/uapi/linux/mpls.h
@@ -43,4 +43,34 @@ struct mpls_label {
 
 #define MPLS_LABEL_FIRST_UNRESERVED	16 /* RFC3032 */
 
+/* These are embedded into IFLA_STATS_AF_SPEC:
+ * [IFLA_STATS_AF_SPEC]
+ * -> [AF_MPLS]
+ *    -> [MPLS_STATS_xxx]
+ *
+ * Attributes:
+ * [MPLS_STATS_LINK] = {
+ *     struct mpls_link_stats
+ * }
+ */
+enum {
+	MPLS_STATS_UNSPEC, /* also used as 64bit pad attribute */
+	MPLS_STATS_LINK,
+	__MPLS_STATS_MAX,
+};
+
+#define MPLS_STATS_MAX (__MPLS_STATS_MAX - 1)
+
+struct mpls_link_stats {
+	__u64	rx_packets;		/* total packets received	*/
+	__u64	tx_packets;		/* total packets transmitted	*/
+	__u64	rx_bytes;		/* total bytes received		*/
+	__u64	tx_bytes;		/* total bytes transmitted	*/
+	__u64	rx_errors;		/* bad packets received		*/
+	__u64	tx_errors;		/* packet transmit problems	*/
+	__u64	rx_dropped;		/* packet dropped on receive	*/
+	__u64	tx_dropped;		/* packet dropped on transmit	*/
+	__u64	rx_noroute;		/* no route for packet dest	*/
+};
+
 #endif /* _UAPI_MPLS_H */
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 15fe97644ffe..fb20941cdda2 100644
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
+					   tx_packets,
+					   tx_bytes);
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
+	MPLS_INC_STATS_LEN(mdev, skb->len, rx_packets,
+			   rx_bytes);
+
+	if (!mdev->input_enabled) {
+		MPLS_INC_STATS(mdev, rx_dropped);
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
+		MPLS_INC_STATS(mdev, rx_noroute);
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
+	out_mdev = out_dev ? mpls_dev_get(out_dev) : NULL;
+	if (out_mdev)
+		MPLS_INC_STATS(out_mdev, tx_errors);
+	goto drop;
+err:
+	MPLS_INC_STATS(mdev, rx_errors);
 drop:
 	kfree_skb(skb);
 	return NET_RX_DROP;
@@ -853,6 +892,70 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 	return err;
 }
 
+static void mpls_get_stats(struct mpls_dev *mdev,
+			   struct mpls_link_stats *stats)
+{
+	struct mpls_pcpu_stats *p;
+	int i;
+
+	memset(stats, 0, sizeof(*stats));
+
+	for_each_possible_cpu(i) {
+		struct mpls_link_stats local;
+		unsigned int start;
+
+		p = per_cpu_ptr(mdev->stats, i);
+		do {
+			start = u64_stats_fetch_begin(&p->syncp);
+			local = p->stats;
+		} while (u64_stats_fetch_retry(&p->syncp, start));
+
+		stats->rx_packets	+= local.rx_packets;
+		stats->rx_bytes		+= local.rx_bytes;
+		stats->tx_packets	+= local.tx_packets;
+		stats->tx_bytes		+= local.tx_bytes;
+		stats->rx_errors	+= local.rx_errors;
+		stats->tx_errors	+= local.tx_errors;
+		stats->rx_dropped	+= local.rx_dropped;
+		stats->tx_dropped	+= local.tx_dropped;
+		stats->rx_noroute	+= local.rx_noroute;
+	}
+}
+
+static int mpls_fill_stats_af(struct sk_buff *skb,
+			      const struct net_device *dev)
+{
+	struct mpls_link_stats *stats;
+	struct mpls_dev *mdev;
+	struct nlattr *nla;
+
+	mdev = mpls_dev_get(dev);
+	if (!mdev)
+		return -ENODATA;
+
+	nla = nla_reserve_64bit(skb, MPLS_STATS_LINK,
+				sizeof(struct mpls_link_stats),
+				MPLS_STATS_UNSPEC);
+	if (!nla)
+		return -EMSGSIZE;
+
+	stats = nla_data(nla);
+	mpls_get_stats(mdev, stats);
+
+	return 0;
+}
+
+static size_t mpls_get_stats_af_size(const struct net_device *dev)
+{
+	struct mpls_dev *mdev;
+
+	mdev = mpls_dev_get(dev);
+	if (!mdev)
+		return 0;
+
+	return nla_total_size_64bit(sizeof(struct mpls_link_stats));
+}
+
 #define MPLS_PERDEV_SYSCTL_OFFSET(field)	\
 	(&((struct mpls_dev *)0)->field)
 
@@ -911,6 +1014,7 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 {
 	struct mpls_dev *mdev;
 	int err = -ENOMEM;
+	int i;
 
 	ASSERT_RTNL();
 
@@ -918,6 +1022,17 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 	if (!mdev)
 		return ERR_PTR(err);
 
+	mdev->stats = alloc_percpu(struct mpls_pcpu_stats);
+	if (!mdev->stats)
+		goto free;
+
+	for_each_possible_cpu(i) {
+		struct mpls_pcpu_stats *mpls_stats;
+
+		mpls_stats = per_cpu_ptr(mdev->stats, i);
+		u64_stats_init(&mpls_stats->syncp);
+	}
+
 	err = mpls_dev_sysctl_register(dev, mdev);
 	if (err)
 		goto free;
@@ -927,10 +1042,19 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 	return mdev;
 
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
@@ -1045,7 +1169,7 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 		if (mdev) {
 			mpls_dev_sysctl_unregister(mdev);
 			RCU_INIT_POINTER(dev->mpls_ptr, NULL);
-			kfree_rcu(mdev, rcu);
+			call_rcu(&mdev->rcu, mpls_dev_destroy_rcu);
 		}
 		break;
 	case NETDEV_CHANGENAME:
@@ -1706,6 +1830,12 @@ static struct pernet_operations mpls_net_ops = {
 	.exit = mpls_net_exit,
 };
 
+static struct rtnl_af_ops mpls_af_ops __read_mostly = {
+	.family		   = AF_MPLS,
+	.fill_stats_af	   = mpls_fill_stats_af,
+	.get_stats_af_size = mpls_get_stats_af_size,
+};
+
 static int __init mpls_init(void)
 {
 	int err;
@@ -1722,6 +1852,8 @@ static int __init mpls_init(void)
 
 	dev_add_pack(&mpls_packet_type);
 
+	rtnl_af_register(&mpls_af_ops);
+
 	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, NULL);
 	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, NULL);
 	rtnl_register(PF_MPLS, RTM_GETROUTE, NULL, mpls_dump_routes, NULL);
@@ -1738,6 +1870,7 @@ module_init(mpls_init);
 static void __exit mpls_exit(void)
 {
 	rtnl_unregister_all(PF_MPLS);
+	rtnl_af_unregister(&mpls_af_ops);
 	dev_remove_pack(&mpls_packet_type);
 	unregister_netdevice_notifier(&mpls_dev_notifier);
 	unregister_pernet_subsys(&mpls_net_ops);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index bdfef6c3271a..d97243034605 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -9,13 +9,58 @@ struct mpls_entry_decoded {
 	u8 bos;
 };
 
+struct mpls_pcpu_stats {
+	struct mpls_link_stats	stats;
+	struct u64_stats_sync	syncp;
+};
+
 struct mpls_dev {
-	int			input_enabled;
+	int				input_enabled;
 
-	struct ctl_table_header *sysctl;
-	struct rcu_head		rcu;
+	struct mpls_pcpu_stats __percpu	*stats;
+
+	struct ctl_table_header		*sysctl;
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
+		ptr->stats.pkts_field++;				\
+		ptr->stats.bytes_field += (len);			\
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
+		ptr->stats.field++;					\
+		u64_stats_update_end(&ptr->syncp);			\
+		local_bh_enable();					\
+	} while (0)
+
+#else
+
+#define MPLS_INC_STATS_LEN(mdev, len, pkts_field, bytes_field)		\
+	do {								\
+		this_cpu_inc((mdev)->stats->stats.pkts_field);		\
+		this_cpu_add((mdev)->stats->stats.bytes_field, (len));	\
+	} while (0)
+
+#define MPLS_INC_STATS(mdev, field)			\
+	this_cpu_inc((mdev)->stats->stats.field)
+
+#endif
+
 struct sk_buff;
 
 #define LABEL_NOT_SPECIFIED (1 << 20)
@@ -114,6 +159,11 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
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
@@ -123,5 +173,7 @@ int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
+void mpls_stats_inc_outucastpkts(struct net_device *dev,
+				 const struct sk_buff *skb);
 
 #endif /* MPLS_INTERNAL_H */
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 2f7ccd934416..02531284bc49 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -48,11 +48,15 @@ static int mpls_xmit(struct sk_buff *skb)
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
@@ -66,8 +70,6 @@ static int mpls_xmit(struct sk_buff *skb)
 
 	skb_orphan(skb);
 
-	/* Find the output device */
-	out_dev = dst->dev;
 	if (!mpls_output_possible(out_dev) ||
 	    !dst->lwtstate || skb_warn_if_lro(skb))
 		goto drop;
@@ -109,6 +111,8 @@ static int mpls_xmit(struct sk_buff *skb)
 		bos = false;
 	}
 
+	mpls_stats_inc_outucastpkts(out_dev, skb);
+
 	if (rt)
 		err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
 				 skb);
@@ -122,6 +126,9 @@ static int mpls_xmit(struct sk_buff *skb)
 	return LWTUNNEL_XMIT_DONE;
 
 drop:
+	out_mdev = out_dev ? mpls_dev_get(out_dev) : NULL;
+	if (out_mdev)
+		MPLS_INC_STATS(out_mdev, tx_errors);
 	kfree_skb(skb);
 	return -EINVAL;
 }
-- 
2.1.4
