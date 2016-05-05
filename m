From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 10/13] net: vrf: Handle ipv6 multicast and link-local addresses
Date: Wed,  4 May 2016 20:33:27 -0700
Message-ID: <1462419210-10463-11-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36824 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906AbcEEDeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:21 -0400
Received: by mail-pa0-f50.google.com with SMTP id bt5so30790210pac.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:20 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 multicast and link-local addresses require special handling by the
VRF driver. Rather than using the VRF device index and a full FIB lookups
packets to/from these addresses should use direct FIB lookups.

Multicast routes do not make sense for L3 master devices. So, do not
add mcast routes for that device and fail attempts to send packets
to ipv6 mast addresses on the device.

With this change connections into and out of a VRF enslaved device work:

1. packets into VM with VRF config:
    ping6 -c3 fe80::e0:f9ff:fe1c:b974%br1
    ping6 -c3 ff02::1%br1

    ssh -6 fe80::e0:f9ff:fe1c:b974%br1

2. packets going out a VRF enslaved ddevice:
    ping6 -c3 fe80::18f8:83ff:fe4b:7a2e%eth1
    ping6 -c3 ff02::1%eth1
    ssh -6 root@fe80::18f8:83ff:fe4b:7a2e%eth1

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c       | 78 ++++++++++++++++++++++++++++++++++++++++++++-----
 include/net/ip6_route.h |  3 ++
 include/net/l3mdev.h    |  6 ++--
 net/ipv6/addrconf.c     |  2 +-
 net/ipv6/icmp.c         |  2 +-
 net/ipv6/route.c        |  5 ++--
 net/l3mdev/l3mdev.c     |  2 +-
 7 files changed, 83 insertions(+), 15 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 1389cd6008f7..f4b44e23e6c2 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -717,11 +717,46 @@ static bool ipv6_ndisc_frame(const struct sk_buff *skb)
 	return rc;
 }
 
+static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
+			      int ifindex)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct flowi6 fl6 = {
+		.daddr		= iph->daddr,
+		.saddr		= iph->saddr,
+		.flowlabel	= ip6_flowinfo(iph),
+		.flowi6_mark	= skb->mark,
+		.flowi6_proto	= iph->nexthdr,
+		.flowi6_iif	= ifindex,
+	};
+	struct net_vrf *vrf = netdev_priv(vrf_dev);
+	struct net *net = dev_net(vrf_dev);
+	struct fib6_table *table;
+	struct rt6_info *rt6;
+
+	table = vrf->rt6->rt6i_table;
+	if (!table)
+		return;
+
+	rt6 = ip6_pol_route(net, table, ifindex, &fl6,
+			    RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_IFACE);
+
+	if (unlikely(&rt6->dst == &net->ipv6.ip6_null_entry->dst))
+		return;
+
+	skb_dst_set(skb, &rt6->dst);
+}
+
 static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 				   struct sk_buff *skb)
 {
-	/* if packet is NDISC keep the ingress interface */
-	if (!ipv6_ndisc_frame(skb)) {
+	int orig_iif = skb->skb_iif;
+	bool need_strict = rt6_need_strict(&ipv6_hdr(skb)->daddr);
+
+	/* if packet is NDISC or addressed to multicast or link-local
+	 * then keep the ingress interface
+	 */
+	if (!ipv6_ndisc_frame(skb) && !need_strict) {
 		skb->dev = vrf_dev;
 		skb->skb_iif = vrf_dev->ifindex;
 
@@ -730,6 +765,9 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 		skb_pull(skb, skb->mac_len);
 	}
 
+	if (need_strict)
+		vrf_ip6_input_dst(skb, vrf_dev, orig_iif);
+
 	return skb;
 }
 
@@ -779,15 +817,41 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
-					 const struct flowi6 *fl6, int flags)
+					 struct flowi6 *fl6, int flags)
 {
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct net *net = dev_net(dev);
 	struct rt6_info *rt = NULL;
 
-	if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
-		struct net_vrf *vrf = netdev_priv(dev);
+	/* send to link-local or multicast address */
+	if (rt6_need_strict(&fl6->daddr)) {
+		struct fib6_table *table;
+
+		/* VRF device does not have a link-local address and
+		 * sending packets to link-local or mcast addresses over
+		 * a VRF device does not make sense
+		 */
+		if (fl6->flowi6_oif == dev->ifindex) {
+			struct dst_entry *dst = &net->ipv6.ip6_null_entry->dst;
+
+			dst_hold(dst);
+			return dst;
+		}
+
+		table = vrf->rt6->rt6i_table;
+		if (!table)
+			return NULL;
 
-		rt = vrf->rt6;
-		dst_hold(&rt->dst);
+		flags |= RT6_LOOKUP_F_IFACE;
+		if (!ipv6_addr_any(&fl6->saddr))
+			flags |= RT6_LOOKUP_F_HAS_SADDR;
+
+		rt = ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
+	} else {
+		if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
+			rt = vrf->rt6;
+			dst_hold(&rt->dst);
+		}
 	}
 
 	return &rt->dst;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 54c779416eec..f73a65e97597 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -77,6 +77,9 @@ static inline struct dst_entry *ip6_route_output(struct net *net,
 struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags);
 
+struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
+			       int oif, struct flowi6 *fl6, int flags);
+
 int ip6_route_init(void);
 void ip6_route_cleanup(void);
 
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 0b38f58b6798..d575185600a5 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -36,7 +36,7 @@ struct l3mdev_ops {
 
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
-						 const struct flowi6 *fl6,
+						 struct flowi6 *fl6,
 						 int flags);
 };
 
@@ -135,7 +135,7 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 
 int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6,
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6,
 				     int flags);
 
 static inline
@@ -223,7 +223,7 @@ static inline int l3mdev_get_saddr(struct net *net, int ifindex,
 }
 
 static inline
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, const struct flowi6 *fl6,
+struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6,
 				     int flags)
 {
 	return NULL;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47f837a58e0a..b12553905e42 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2254,7 +2254,7 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 		return ERR_PTR(-EACCES);
 
 	/* Add default multicast route */
-	if (!(dev->flags & IFF_LOOPBACK))
+	if (!(dev->flags & IFF_LOOPBACK) && !netif_is_l3_master(dev))
 		addrconf_add_mroute(dev);
 
 	return idev;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4527285fcaa2..a69a7e553adb 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -585,7 +585,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	fl6.daddr = ipv6_hdr(skb)->saddr;
 	if (saddr)
 		fl6.saddr = *saddr;
-	fl6.flowi6_oif = l3mdev_fib_oif(skb->dev);
+	fl6.flowi6_oif = skb->dev->ifindex;
 	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	fl6.flowi6_mark = mark;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c585323503f1..a87e66d2284f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1042,8 +1042,8 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 	return pcpu_rt;
 }
 
-static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
-				      struct flowi6 *fl6, int flags)
+struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
+			       int oif, struct flowi6 *fl6, int flags)
 {
 	struct fib6_node *fn, *saved_fn;
 	struct rt6_info *rt;
@@ -1139,6 +1139,7 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 
 	}
 }
+EXPORT_SYMBOL_GPL(ip6_pol_route);
 
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
 					    struct flowi6 *fl6, int flags)
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index fbf16c487d8b..dceac272b8c4 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -107,7 +107,7 @@ EXPORT_SYMBOL_GPL(l3mdev_fib_table_by_index);
  */
 
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
-				     const struct flowi6 *fl6,
+				     struct flowi6 *fl6,
 				     int flags)
 {
 	struct dst_entry *dst = NULL;
-- 
2.1.4
