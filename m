From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: vrf: Handle ipv6 multicast and link-local addresses
Date: Mon, 13 Jun 2016 13:44:19 -0700
Message-ID: <1465850659-27830-4-git-send-email-dsa@cumulusnetworks.com>
References: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33907 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422685AbcFMUo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:44:28 -0400
Received: by mail-pf0-f182.google.com with SMTP id 62so49556448pfd.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 13:44:28 -0700 (PDT)
In-Reply-To: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 multicast and link-local addresses require special handling by the
VRF driver:
1. Rather than using the VRF device index and full FIB lookups,
   packets to/from these addresses should use direct FIB lookups based on
   the VRF device table.

2. fail sends/receives on a VRF device to/from a multicast address
   (e.g, make ping6 ff02::1%<vrf> fail)

3. move the setting of the flow oif to the first dst lookup and revert
   the change in icmpv6_echo_reply made in ca254490c8dfd ("net: Add VRF
   support to IPv6 stack"). Linklocal/mcast addresses require use of the
   skb->dev.

With this change connections into and out of a VRF enslaved device work
for multicast and link-local addresses work (icmp, tcp, and udp)
e.g.,

1. packets into VM with VRF config:
    ping6 -c3 fe80::e0:f9ff:fe1c:b974%br1
    ping6 -c3 ff02::1%br1

    ssh -6 fe80::e0:f9ff:fe1c:b974%br1

2. packets going out a VRF enslaved device:
    ping6 -c3 fe80::18f8:83ff:fe4b:7a2e%eth1
    ping6 -c3 ff02::1%eth1
    ssh -6 root@fe80::18f8:83ff:fe4b:7a2e%eth1

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c       | 98 ++++++++++++++++++++++++++++++++++++++++++++++---
 include/net/ip6_route.h |  2 +
 net/ipv6/icmp.c         |  2 +-
 net/ipv6/route.c        |  5 ++-
 4 files changed, 99 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index d2ce76c9dc64..0b5b3c258c2b 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -785,9 +785,63 @@ static bool ipv6_ndisc_frame(const struct sk_buff *skb)
 	return rc;
 }
 
+static struct rt6_info *vrf_ip6_route_lookup(struct net *net,
+					     const struct net_device *dev,
+					     struct flowi6 *fl6,
+					     int ifindex,
+					     int flags)
+{
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct fib6_table *table = NULL;
+	struct rt6_info *rt6;
+
+	rcu_read_lock();
+
+	/* fib6_table does not have a refcnt and can not be freed */
+	rt6 = rcu_dereference(vrf->rt6);
+	if (likely(rt6))
+		table = rt6->rt6i_table;
+
+	rcu_read_unlock();
+
+	if (!table)
+		return NULL;
+
+	return ip6_pol_route(net, table, ifindex, fl6, flags);
+}
+
+static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
+			      int ifindex)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct flowi6 fl6 = {
+		.daddr          = iph->daddr,
+		.saddr          = iph->saddr,
+		.flowlabel      = ip6_flowinfo(iph),
+		.flowi6_mark    = skb->mark,
+		.flowi6_proto   = iph->nexthdr,
+		.flowi6_iif     = ifindex,
+	};
+	struct net *net = dev_net(vrf_dev);
+	struct rt6_info *rt6;
+
+	rt6 = vrf_ip6_route_lookup(net, vrf_dev, &fl6, ifindex,
+				   RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_IFACE);
+	if (unlikely(!rt6))
+		return;
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
+	int orig_iif = skb->skb_iif;
+	bool need_strict;
+
 	/* loopback traffic; do not push through packet taps again.
 	 * Reset pkt_type for upper layers to process skb
 	 */
@@ -798,8 +852,11 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 		goto out;
 	}
 
-	/* if packet is NDISC keep the ingress interface */
-	if (!ipv6_ndisc_frame(skb)) {
+	/* if packet is NDISC or addressed to multicast or link-local
+	 * then keep the ingress interface
+	 */
+	need_strict = rt6_need_strict(&ipv6_hdr(skb)->daddr);
+	if (!ipv6_ndisc_frame(skb) && !need_strict) {
 		skb->dev = vrf_dev;
 		skb->skb_iif = vrf_dev->ifindex;
 
@@ -810,6 +867,9 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 		IP6CB(skb)->flags |= IP6SKB_L3SLAVE;
 	}
 
+	if (need_strict)
+		vrf_ip6_input_dst(skb, vrf_dev, orig_iif);
+
 out:
 	return skb;
 }
@@ -863,11 +923,35 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 					 struct flowi6 *fl6)
 {
+	bool need_strict = rt6_need_strict(&fl6->daddr);
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct net *net = dev_net(dev);
 	struct dst_entry *dst = NULL;
+	struct rt6_info *rt;
 
-	if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
-		struct net_vrf *vrf = netdev_priv(dev);
-		struct rt6_info *rt;
+	/* send to link-local or multicast address */
+	if (need_strict) {
+		int flags = RT6_LOOKUP_F_IFACE;
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
+		if (!ipv6_addr_any(&fl6->saddr))
+			flags |= RT6_LOOKUP_F_HAS_SADDR;
+
+		rt = vrf_ip6_route_lookup(net, dev, fl6, fl6->flowi6_oif, flags);
+		if (rt)
+			dst = &rt->dst;
+
+	} else if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
 
 		rcu_read_lock();
 
@@ -880,6 +964,10 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 		rcu_read_unlock();
 	}
 
+	/* make sure oif is set to VRF device for lookup */
+	if (!need_strict)
+		fl6->flowi6_oif = dev->ifindex;
+
 	return dst;
 }
 #endif
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 54c779416eec..f55bf3d294aa 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -76,6 +76,8 @@ static inline struct dst_entry *ip6_route_output(struct net *net,
 
 struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags);
+struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
+			       int ifindex, struct flowi6 *fl6, int flags);
 
 int ip6_route_init(void);
 void ip6_route_cleanup(void);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 40454bfb534e..e32a72fb9982 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -587,7 +587,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	fl6.daddr = ipv6_hdr(skb)->saddr;
 	if (saddr)
 		fl6.saddr = *saddr;
-	fl6.flowi6_oif = l3mdev_fib_oif(skb->dev);
+	fl6.flowi6_oif = skb->dev->ifindex;
 	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	fl6.flowi6_mark = mark;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c6ae6f9b5fe3..d51a1a48b839 100644
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
-- 
2.1.4
