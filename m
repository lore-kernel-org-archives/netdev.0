From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 3/4] net: VRF device: Initial IPv6 support
Date: Mon, 21 Sep 2015 16:32:57 -0700
Message-ID: <1442878378-13322-4-git-send-email-dsa@cumulusnetworks.com>
References: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33997 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536AbbIUXdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:33:18 -0400
Received: by padhy16 with SMTP id hy16so129617217pad.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 16:33:17 -0700 (PDT)
In-Reply-To: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Start point for IPv6 support by the VRF device.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 226 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 225 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 9e3afe011396..ea08a280ae2e 100644
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
@@ -54,6 +55,7 @@ struct slave_queue {
 struct net_vrf {
 	struct slave_queue      queue;
 	struct rtable           *rth;
+	struct rt6_info		*rt6;
 	u32                     tb_id;
 };
 
@@ -101,12 +103,49 @@ static struct dst_ops vrf_dst_ops = {
 	.default_advmss	= vrf_default_advmss,
 };
 
+/* neighbor handling is done with actual device; do not want
+ * to flip skb->dev for those ndisc packets. This really fails
+ * for multiple next protocols (e.g., NEXTHDR_HOP). But it is
+ * a start.
+ */
+static bool check_ipv6_frame(const struct sk_buff *skb)
+{
+	const struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb->data;
+	size_t hlen = sizeof(*ipv6h);
+	bool rc = true;
+
+	if (skb->len < hlen)
+		return false;
+
+	if (ipv6h->nexthdr == NEXTHDR_ICMP) {
+		const struct icmp6hdr *icmph;
+
+		if (skb->len < hlen + sizeof(*icmph))
+			goto out;
+
+		icmph = (struct icmp6hdr *)(skb->data + sizeof(*ipv6h));
+		switch (icmph->icmp6_type) {
+		case NDISC_ROUTER_SOLICITATION:
+		case NDISC_ROUTER_ADVERTISEMENT:
+		case NDISC_NEIGHBOUR_SOLICITATION:
+		case NDISC_NEIGHBOUR_ADVERTISEMENT:
+		case NDISC_REDIRECT:
+			rc = false;
+			break;
+		}
+	}
+
+out:
+	return rc;
+}
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
@@ -169,6 +208,37 @@ static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
 static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 					   struct net_device *dev)
 {
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
+		.flowi6_flags = FLOWI_FLAG_L3MDEV_SRC,
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
 	vrf_tx_error(dev, skb);
 	return NET_XMIT_DROP;
 }
@@ -265,6 +335,122 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
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
+	pr_err("vrf_input6: WTF!?!?\n");
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
+
 /* modelled after ip_finish_output2 */
 static int vrf_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
@@ -487,6 +673,7 @@ static void vrf_dev_uninit(struct net_device *dev)
 	struct slave *slave, *next;
 
 	vrf_rtable_destroy(vrf);
+	vrf_rt6_destroy(vrf);
 
 	list_for_each_entry_safe(slave, next, head, list)
 		vrf_del_slave(dev, slave->dev);
@@ -510,10 +697,17 @@ static int vrf_dev_init(struct net_device *dev)
 	if (!vrf->rth)
 		goto out_stats;
 
+	vrf->rt6 = vrf_rt6_create(dev);
+	if (!vrf->rt6)
+		goto out_rth;
+
+	/* can not use IFF_LOOPBACK; it has special meaning in the stack */
 	dev->flags = IFF_MASTER | IFF_NOARP;
 
 	return 0;
 
+out_rth:
+	vrf_rtable_destroy(vrf);
 out_stats:
 	free_percpu(dev->dstats);
 	dev->dstats = NULL;
@@ -552,9 +746,25 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 	return rth;
 }
 
+static struct dst_entry *vrf_rt6_dst(const struct net_device *dev,
+				     const struct flowi6 *fl6)
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
+
 static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
 	.l3mdev_get_rtable	= vrf_get_rtable,
+	.l3mdev_rt6_dst		= vrf_rt6_dst,
 };
 
 static void vrf_get_drvinfo(struct net_device *dev,
@@ -696,6 +906,17 @@ static int __init vrf_init_module(void)
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
@@ -706,6 +927,8 @@ static int __init vrf_init_module(void)
 
 error:
 	unregister_netdevice_notifier(&vrf_notifier_block);
+	kmem_cache_destroy(vrf_dst_ops6.kmem_cachep);
+error2:
 	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
 	return rc;
 }
@@ -715,6 +938,7 @@ static void __exit vrf_cleanup_module(void)
 	rtnl_link_unregister(&vrf_link_ops);
 	unregister_netdevice_notifier(&vrf_notifier_block);
 	kmem_cache_destroy(vrf_dst_ops.kmem_cachep);
+	kmem_cache_destroy(vrf_dst_ops6.kmem_cachep);
 }
 
 module_init(vrf_init_module);
-- 
1.9.1
