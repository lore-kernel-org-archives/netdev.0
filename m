From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/4] net: Add IPv6 support to VRF device
Date: Wed,  7 Oct 2015 09:50:39 -0700
Message-ID: <1444236640-2410-4-git-send-email-dsa@cumulusnetworks.com>
References: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36187 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050AbbJGQuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:50:52 -0400
Received: by pablk4 with SMTP id lk4so26304783pab.3
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:50:51 -0700 (PDT)
In-Reply-To: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for IPv6 to VRF device driver. Implemenation parallels what
has been done for IPv4.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/Kconfig |   1 +
 drivers/net/vrf.c   | 254 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 254 insertions(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b9ebd0d18a52..c878a0bc2137 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -300,6 +300,7 @@ config NET_VRF
 	tristate "Virtual Routing and Forwarding (Lite)"
 	depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES
 	depends on NET_L3_MASTER_DEV
+	depends on IPV6
 	---help---
 	  This option enables the support for mapping interfaces into VRF's. The
 	  support enables VRF devices.
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 64499766e00f..289c94b0df35 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -30,6 +30,7 @@
 #include <net/arp.h>
 #include <net/ip.h>
 #include <net/ip_fib.h>
+#include <net/ip6_fib.h>
 #include <net/ip6_route.h>
 #include <net/rtnetlink.h>
 #include <net/route.h>
@@ -57,6 +58,7 @@ struct slave_queue {
 struct net_vrf {
 	struct slave_queue      queue;
 	struct rtable           *rth;
+	struct rt6_info		*rt6;
 	u32                     tb_id;
 };
 
@@ -104,12 +106,53 @@ static struct dst_ops vrf_dst_ops = {
 	.default_advmss	= vrf_default_advmss,
 };
 
+/* neighbor handling is done with actual device; do not want
+ * to flip skb->dev for ndisc packets. This really fails for
+ * multiple next protocols (e.g., NEXTHDR_HOP). But it is a
+ * start for IPv6 support.
+ */
+#if IS_ENABLED(CONFIG_IPV6)
+static bool check_ipv6_frame(const struct sk_buff *skb)
+{
+	const struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb->data;
+	size_t hlen = sizeof(*ipv6h);
+
+	if (skb->len < hlen)
+		return false;
+
+	if (ipv6h->nexthdr == NEXTHDR_ICMP) {
+		const struct icmp6hdr *icmph;
+
+		if (skb->len < hlen + sizeof(*icmph))
+			return false;
+
+		icmph = (struct icmp6hdr *)(skb->data + sizeof(*ipv6h));
+		switch (icmph->icmp6_type) {
+		case NDISC_ROUTER_SOLICITATION:
+		case NDISC_ROUTER_ADVERTISEMENT:
+		case NDISC_NEIGHBOUR_SOLICITATION:
+		case NDISC_NEIGHBOUR_ADVERTISEMENT:
+		case NDISC_REDIRECT:
+			return false;
+		}
+	}
+
+	return true;
+}
+#else
+static bool check_ipv6_frame(const struct sk_buff *skb)
+{
+	return false;
+}
+#endif
+
 static bool is_ip_rx_frame(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-	case htons(ETH_P_IPV6):
 		return true;
+	case htons(ETH_P_IPV6):
+		return check_ipv6_frame(skb);
 	}
 	return false;
 }
@@ -169,12 +212,52 @@ static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
 	return stats;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
+					   struct net_device *dev)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct net *net = dev_net(skb->dev);
+	struct flowi6 fl6 = {
+		/* needed to match OIF rule */
+		.flowi6_oif = dev->ifindex,
+		.flowi6_iif = LOOPBACK_IFINDEX,
+		.daddr = iph->daddr,
+		.saddr = iph->saddr,
+		.flowlabel = ip6_flowinfo(iph),
+		.flowi6_mark = skb->mark,
+		.flowi6_proto = iph->nexthdr,
+		.flowi6_flags = FLOWI_FLAG_L3MDEV_SRC | FLOWI_FLAG_SKIP_NH_OIF,
+	};
+	int ret = NET_XMIT_DROP;
+	struct dst_entry *dst;
+
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (dst == (struct dst_entry *)net->ipv6.ip6_null_entry)
+		goto err;
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+
+	ret = ip6_local_out(skb);
+	if (unlikely(net_xmit_eval(ret)))
+		dev->stats.tx_errors++;
+	else
+		ret = NET_XMIT_SUCCESS;
+
+	return ret;
+err:
+	vrf_tx_error(dev, skb);
+	return NET_XMIT_DROP;
+}
+#else
 static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 					   struct net_device *dev)
 {
 	vrf_tx_error(dev, skb);
 	return NET_XMIT_DROP;
 }
+#endif
 
 static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
 			    struct net_device *vrf_dev)
@@ -269,6 +352,134 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static struct dst_entry *vrf_ip6_check(struct dst_entry *dst, u32 cookie)
+{
+	return dst;
+}
+
+static int vrf_ip6_local_out(struct sk_buff *skb)
+{
+	return ip6_local_out(skb);
+}
+
+static struct dst_ops vrf_dst_ops6 = {
+	.family		= AF_INET6,
+	.local_out	= vrf_ip6_local_out,
+	.check		= vrf_ip6_check,
+	.mtu		= vrf_v4_mtu,
+	.destroy	= vrf_dst_destroy,
+	.default_advmss	= vrf_default_advmss,
+};
+
+static int vrf_input6(struct sk_buff *skb)
+{
+	skb->dev->stats.rx_errors++;
+	kfree_skb(skb);
+	return 0;
+}
+
+/* modelled after ip6_finish_output2 */
+static int vrf_finish_output6(struct net *net, struct sock *sk,
+			      struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct net_device *dev = dst->dev;
+	struct neighbour *neigh;
+	struct in6_addr *nexthop;
+	int ret;
+
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+
+	rcu_read_lock_bh();
+	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
+	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
+	if (unlikely(!neigh))
+		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
+	if (!IS_ERR(neigh)) {
+		ret = dst_neigh_output(dst, neigh, skb);
+		rcu_read_unlock_bh();
+		return ret;
+	}
+	rcu_read_unlock_bh();
+
+	IP6_INC_STATS(dev_net(dst->dev),
+		      ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+/* modelled after ip6_output */
+static int vrf_output6(struct sock *sk, struct sk_buff *skb)
+{
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
+			    dev_net(skb_dst(skb)->dev), sk, skb,
+			    NULL, skb_dst(skb)->dev,
+			    vrf_finish_output6,
+			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
+}
+
+static void vrf_rt6_destroy(struct net_vrf *vrf)
+{
+	struct dst_entry *dst = (struct dst_entry *)vrf->rt6;
+
+	dst_destroy(dst);
+	vrf->rt6 = NULL;
+}
+
+static struct rt6_info *vrf_rt6_create(struct net_device *dev)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct rt6_info *rt6;
+	struct dst_entry *dst;
+	int cpu;
+
+	rt6 = dst_alloc(&vrf_dst_ops6, dev, 0,
+			DST_OBSOLETE_NONE,
+			(DST_HOST | DST_NOPOLICY | DST_NOXFRM));
+	if (!rt6)
+		goto out;
+
+	rt6->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_ATOMIC);
+	if (!rt6->rt6i_pcpu) {
+		dst_destroy((struct dst_entry *)rt6);
+		rt6 = NULL;
+		goto out;
+	}
+	for_each_possible_cpu(cpu) {
+		struct rt6_info **p = per_cpu_ptr(rt6->rt6i_pcpu, cpu);
+		*p =  NULL;
+	}
+
+	dst = &rt6->dst;
+	memset(dst + 1, 0, sizeof(*rt6) - sizeof(*dst));
+
+	INIT_LIST_HEAD(&rt6->rt6i_siblings);
+	INIT_LIST_HEAD(&rt6->rt6i_uncached);
+
+	rt6->dst.input	= vrf_input6;
+	rt6->dst.output	= vrf_output6;
+
+	rt6->rt6i_table = fib6_get_table(dev_net(dev), vrf->tb_id);
+
+	atomic_set(&rt6->dst.__refcnt, 2);
+
+out:
+	return rt6;
+}
+#else
+static void vrf_rt6_destroy(struct net_vrf *vrf)
+{
+	/* using ip6_null_entry if IPv6 is not enabled; nothing to destroy */
+}
+
+static struct rt6_info *vrf_rt6_create(struct net_device *dev)
+{
+	return net->ipv6.ip6_null_entry;
+}
+#endif
+
 /* modelled after ip_finish_output2 */
 static int vrf_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
@@ -491,6 +702,7 @@ static void vrf_dev_uninit(struct net_device *dev)
 	struct slave *slave, *next;
 
 	vrf_rtable_destroy(vrf);
+	vrf_rt6_destroy(vrf);
 
 	list_for_each_entry_safe(slave, next, head, list)
 		vrf_del_slave(dev, slave->dev);
@@ -514,10 +726,16 @@ static int vrf_dev_init(struct net_device *dev)
 	if (!vrf->rth)
 		goto out_stats;
 
+	vrf->rt6 = vrf_rt6_create(dev);
+	if (!vrf->rt6)
+		goto out_rth;
+
 	dev->flags = IFF_MASTER | IFF_NOARP;
 
 	return 0;
 
+out_rth:
+	vrf_rtable_destroy(vrf);
 out_stats:
 	free_percpu(dev->dstats);
 	dev->dstats = NULL;
@@ -587,10 +805,30 @@ static void vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 	fl4->flowi4_scope = scope;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
+					 const struct flowi6 *fl6)
+{
+	struct rt6_info *rt = NULL;
+
+	if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
+		struct net_vrf *vrf = netdev_priv(dev);
+
+		rt = vrf->rt6;
+		atomic_inc(&rt->dst.__refcnt);
+	}
+
+	return (struct dst_entry *)rt;
+}
+#endif
+
 static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
 	.l3mdev_get_rtable	= vrf_get_rtable,
 	.l3mdev_get_saddr	= vrf_get_saddr,
+#if IS_ENABLED(CONFIG_IPV6)
+	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
+#endif
 };
 
 static void vrf_get_drvinfo(struct net_device *dev,
@@ -732,6 +970,17 @@ static int __init vrf_init_module(void)
 	if (!vrf_dst_ops.kmem_cachep)
 		return -ENOMEM;
 
+	vrf_dst_ops6.kmem_cachep = kmem_cache_create("vrf_ip6_dst_cache",
+						     sizeof(struct rt6_info),
+						     0,
+						     SLAB_HWCACHE_ALIGN,
+						     NULL);
+
+	if (!vrf_dst_ops6.kmem_cachep) {
+		rc = -ENOMEM;
+		goto error2;
+	}
+
 	register_netdevice_notifier(&vrf_notifier_block);
 
 	rc = rtnl_link_register(&vrf_link_ops);
@@ -742,6 +991,8 @@ static int __init vrf_init_module(void)
 
 error:
 	unregister_netdevice_notifier(&vrf_notifier_block);
+	kmem_cache_destroy(vrf_dst_ops6.kmem_cachep);
+error2:
 	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
 	return rc;
 }
@@ -751,6 +1002,7 @@ static void __exit vrf_cleanup_module(void)
 	rtnl_link_unregister(&vrf_link_ops);
 	unregister_netdevice_notifier(&vrf_notifier_block);
 	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
+	kmem_cache_destroy(vrf_dst_ops6.kmem_cachep);
 }
 
 module_init(vrf_init_module);
-- 
1.9.1
