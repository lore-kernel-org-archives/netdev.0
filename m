From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 05/13] net: l3mdev: Add hook in ip and ipv6
Date: Wed,  4 May 2016 20:33:22 -0700
Message-ID: <1462419210-10463-6-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33458 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906AbcEEDeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:14 -0400
Received: by mail-pa0-f49.google.com with SMTP id xk12so31292858pac.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:13 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the VRF driver uses the rx_handler to switch the skb device
to the VRF device. Switching the dev prior to the ip / ipv6 layer
means the VRF driver has to duplicate IP/IPv6 processing which is just
overhead and makes features such as retaining the ingress device index
more complicated than necessary.

This patch moves the hook to the L3 layer just after the first NF_HOOK
for PRE_ROUTING. This location makes exposing the original ingress device
fairly trivial (next patch) and allows adding other NF_HOOKs to the VRF
driver in the future.

dev_queue_xmit_nit is exported so that the VRF driver can cycle the skb
with the switched device through the packet taps to maintain current
behavior (tcpdump can be used on either the vrf device or the enslaved
devices).

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c         | 186 ++++++++++++++++++++++------------------------
 include/linux/ipv6.h      |   2 +-
 include/linux/netdevice.h |   2 +
 include/net/l3mdev.h      |  43 +++++++++++
 include/net/tcp.h         |   2 +-
 net/core/dev.c            |   3 +-
 net/ipv4/ip_input.c       |   7 ++
 net/ipv6/ip6_input.c      |   7 ++
 8 files changed, 151 insertions(+), 101 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 3a04b8cac757..39bef1dc41fa 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -42,9 +42,6 @@
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
-#define vrf_master_get_rcu(dev) \
-	((struct net_device *)rcu_dereference(dev->rx_handler_data))
-
 struct net_vrf {
 	struct rtable           *rth;
 	struct rt6_info		*rt6;
@@ -60,90 +57,12 @@ struct pcpu_dstats {
 	struct u64_stats_sync	syncp;
 };
 
-/* neighbor handling is done with actual device; do not want
- * to flip skb->dev for those ndisc packets. This really fails
- * for multiple next protocols (e.g., NEXTHDR_HOP). But it is
- * a start.
- */
-#if IS_ENABLED(CONFIG_IPV6)
-static bool check_ipv6_frame(const struct sk_buff *skb)
-{
-	const struct ipv6hdr *ipv6h;
-	struct ipv6hdr _ipv6h;
-	bool rc = true;
-
-	ipv6h = skb_header_pointer(skb, 0, sizeof(_ipv6h), &_ipv6h);
-	if (!ipv6h)
-		goto out;
-
-	if (ipv6h->nexthdr == NEXTHDR_ICMP) {
-		const struct icmp6hdr *icmph;
-		struct icmp6hdr _icmph;
-
-		icmph = skb_header_pointer(skb, sizeof(_ipv6h),
-					   sizeof(_icmph), &_icmph);
-		if (!icmph)
-			goto out;
-
-		switch (icmph->icmp6_type) {
-		case NDISC_ROUTER_SOLICITATION:
-		case NDISC_ROUTER_ADVERTISEMENT:
-		case NDISC_NEIGHBOUR_SOLICITATION:
-		case NDISC_NEIGHBOUR_ADVERTISEMENT:
-		case NDISC_REDIRECT:
-			rc = false;
-			break;
-		}
-	}
-
-out:
-	return rc;
-}
-#else
-static bool check_ipv6_frame(const struct sk_buff *skb)
-{
-	return false;
-}
-#endif
-
-static bool is_ip_rx_frame(struct sk_buff *skb)
-{
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-		return true;
-	case htons(ETH_P_IPV6):
-		return check_ipv6_frame(skb);
-	}
-	return false;
-}
-
 static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
 {
 	vrf_dev->stats.tx_errors++;
 	kfree_skb(skb);
 }
 
-/* note: already called with rcu_read_lock */
-static rx_handler_result_t vrf_handle_frame(struct sk_buff **pskb)
-{
-	struct sk_buff *skb = *pskb;
-
-	if (is_ip_rx_frame(skb)) {
-		struct net_device *dev = vrf_master_get_rcu(skb->dev);
-		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
-
-		u64_stats_update_begin(&dstats->syncp);
-		dstats->rx_pkts++;
-		dstats->rx_bytes += skb->len;
-		u64_stats_update_end(&dstats->syncp);
-
-		skb->dev = dev;
-
-		return RX_HANDLER_ANOTHER;
-	}
-	return RX_HANDLER_PASS;
-}
-
 static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
 						 struct rtnl_link_stats64 *stats)
 {
@@ -504,28 +423,14 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
 	int ret;
 
-	/* register the packet handler for slave ports */
-	ret = netdev_rx_handler_register(port_dev, vrf_handle_frame, dev);
-	if (ret) {
-		netdev_err(port_dev,
-			   "Device %s failed to register rx_handler\n",
-			   port_dev->name);
-		goto out_fail;
-	}
-
 	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
 	if (ret < 0)
-		goto out_unregister;
+		return ret;
 
 	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
 	cycle_netdev(port_dev);
 
 	return 0;
-
-out_unregister:
-	netdev_rx_handler_unregister(port_dev);
-out_fail:
-	return ret;
 }
 
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
@@ -542,8 +447,6 @@ static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 	netdev_upper_dev_unlink(port_dev, dev);
 	port_dev->priv_flags &= ~IFF_L3MDEV_SLAVE;
 
-	netdev_rx_handler_unregister(port_dev);
-
 	cycle_netdev(port_dev);
 
 	return 0;
@@ -668,6 +571,92 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+/* neighbor handling is done with actual device; do not want
+ * to flip skb->dev for those ndisc packets. This really fails
+ * for multiple next protocols (e.g., NEXTHDR_HOP). But it is
+ * a start.
+ */
+static bool ipv6_ndisc_frame(const struct sk_buff *skb)
+{
+	const struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb->data;
+	size_t hlen = sizeof(*ipv6h);
+	bool rc = false;
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
+			rc = true;
+			break;
+		}
+	}
+
+out:
+	return rc;
+}
+
+static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
+				   struct sk_buff *skb)
+{
+	/* if packet is NDISC keep the ingress interface */
+	if (!ipv6_ndisc_frame(skb)) {
+		skb->dev = vrf_dev;
+		skb->skb_iif = vrf_dev->ifindex;
+
+		skb_push(skb, skb->mac_len);
+		dev_queue_xmit_nit(skb, vrf_dev);
+		skb_pull(skb, skb->mac_len);
+	}
+
+	return skb;
+}
+
+#else
+static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
+				   struct sk_buff *skb)
+{
+	return skb;
+}
+#endif
+
+static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
+				  struct sk_buff *skb)
+{
+	skb->dev = vrf_dev;
+	skb->skb_iif = vrf_dev->ifindex;
+
+	skb_push(skb, skb->mac_len);
+	dev_queue_xmit_nit(skb, vrf_dev);
+	skb_pull(skb, skb->mac_len);
+
+	return skb;
+}
+
+/* called with rcu lock held */
+static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
+				  struct sk_buff *skb,
+				  u16 proto)
+{
+	switch (proto) {
+	case AF_INET:
+		return vrf_ip_rcv(vrf_dev, skb);
+	case AF_INET6:
+		return vrf_ip6_rcv(vrf_dev, skb);
+	}
+
+	return skb;
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 					 const struct flowi6 *fl6)
 {
@@ -688,6 +677,7 @@ static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
 	.l3mdev_get_rtable	= vrf_get_rtable,
 	.l3mdev_get_saddr	= vrf_get_saddr,
+	.l3mdev_l3_rcv		= vrf_l3_rcv,
 #if IS_ENABLED(CONFIG_IPV6)
 	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
 #endif
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 58d6e158755f..2c460121498b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -125,7 +125,7 @@ struct inet6_skb_parm {
 
 static inline int inet6_iif(const struct sk_buff *skb)
 {
-	return IP6CB(skb)->iif;
+	return skb->skb_iif > 1 ? skb->skb_iif : IP6CB(skb)->iif;
 }
 
 struct tcp6_request_sock {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bcf012637d10..3dce605d5273 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3266,6 +3266,8 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 bool is_skb_forwardable(const struct net_device *dev,
 			const struct sk_buff *skb);
 
+void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
+
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 78872bd1dc2c..46ac4c69c155 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -25,6 +25,8 @@
 
 struct l3mdev_ops {
 	u32		(*l3mdev_fib_table)(const struct net_device *dev);
+	struct sk_buff * (*l3mdev_l3_rcv)(struct net_device *dev,
+					  struct sk_buff *skb, u16 proto);
 
 	/* IPv4 ops */
 	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
@@ -134,6 +136,35 @@ int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6);
 
+static inline
+struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
+{
+	struct net_device *master = NULL;
+
+	if (netif_is_l3_slave(skb->dev))
+		master = netdev_master_upper_dev_get_rcu(skb->dev);
+
+	else if (netif_is_l3_master(skb->dev))
+		master = skb->dev;
+
+	if (master && master->l3mdev_ops->l3mdev_l3_rcv)
+		skb = master->l3mdev_ops->l3mdev_l3_rcv(master, skb, proto);
+
+	return skb;
+}
+
+static inline
+struct sk_buff *l3mdev_ip_rcv(struct sk_buff *skb)
+{
+	return l3mdev_l3_rcv(skb, AF_INET);
+}
+
+static inline
+struct sk_buff *l3mdev_ip6_rcv(struct sk_buff *skb)
+{
+	return l3mdev_l3_rcv(skb, AF_INET6);
+}
+
 #else
 
 static inline int l3mdev_master_ifindex_rcu(const struct net_device *dev)
@@ -194,6 +225,18 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6)
 {
 	return NULL;
 }
+
+static inline
+struct sk_buff *l3mdev_ip_rcv(struct sk_buff *skb)
+{
+	return skb;
+}
+
+static inline
+struct sk_buff *l3mdev_ip6_rcv(struct sk_buff *skb)
+{
+	return skb;
+}
 #endif
 
 #endif /* _NET_L3MDEV_H_ */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 24ec80483805..bf08eb370c96 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -781,7 +781,7 @@ struct tcp_skb_cb {
  */
 static inline int tcp_v6_iif(const struct sk_buff *skb)
 {
-	return TCP_SKB_CB(skb)->header.h6.iif;
+	return skb->skb_iif > 1 ? skb->skb_iif : TCP_SKB_CB(skb)->header.h6.iif;
 }
 #endif
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 673d1f118bfb..845acb9f75d2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1850,7 +1850,7 @@ static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_buff *skb)
  *	taps currently in use.
  */
 
-static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
+void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct packet_type *ptype;
 	struct sk_buff *skb2 = NULL;
@@ -1907,6 +1907,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
 	rcu_read_unlock();
 }
+EXPORT_SYMBOL_GPL(dev_queue_xmit_nit);
 
 /**
  * netif_setup_tc - Handle tc mappings on real_num_tx_queues change
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 751c0658e194..37375eedeef9 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -313,6 +313,13 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
+	/* if ingress device is enslaved to an L3 master device pass the
+	 * skb to its handler for processing
+	 */
+	skb = l3mdev_ip_rcv(skb);
+	if (!skb)
+		return NET_RX_SUCCESS;
+
 	if (net->ipv4.sysctl_ip_early_demux &&
 	    !skb_dst(skb) &&
 	    !skb->sk &&
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 6ed56012005d..f185cbcda114 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -49,6 +49,13 @@
 
 int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
+	/* if ingress device is enslaved to an L3 master device pass the
+	 * skb to its handler for processing
+	 */
+	skb = l3mdev_ip6_rcv(skb);
+	if (!skb)
+		return NET_RX_SUCCESS;
+
 	if (net->ipv4.sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
 		const struct inet6_protocol *ipprot;
 
-- 
2.1.4
