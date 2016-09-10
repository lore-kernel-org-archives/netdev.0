From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 05/11] net: vrf: Flip IPv6 output path from FIB lookup hook to out hook
Date: Sat, 10 Sep 2016 12:09:56 -0700
Message-ID: <1473534602-23602-6-git-send-email-dsa@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36756 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbcIJTLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:30 -0400
Received: by mail-pa0-f53.google.com with SMTP id id6so38553865pad.3
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:30 -0700 (PDT)
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flip the IPv6 output path to use the l3mdev tx out hook. The VRF dst
is not returned on the first FIB lookup. Instead, the dst on the
skb is switched at the beginning of the IPv6 output processing to
send the packet to the VRF driver on xmit.

Link scope addresses (linklocal and multicast) need special handling:
specifically the oif the flow struct can not be changed because we
want the lookup tied to the enslaved interface. ie., the source address
and the returned route MUST point to the interface scope passed in.
Convert the existing vrf_get_rt6_dst to handle only link scope addresses.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 124 ++++++++++++++++++++++++++++++++++-----------------
 include/net/l3mdev.h |   8 ++--
 net/ipv6/route.c     |  11 +++--
 net/l3mdev/l3mdev.c  |  15 +++----
 4 files changed, 100 insertions(+), 58 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 08540b96ec18..f5372edf6edc 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -137,6 +137,20 @@ static int vrf_local_xmit(struct sk_buff *skb, struct net_device *dev,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+static int vrf_ip6_local_out(struct net *net, struct sock *sk,
+			     struct sk_buff *skb)
+{
+	int err;
+
+	err = nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net,
+		      sk, skb, NULL, skb_dst(skb)->dev, dst_output);
+
+	if (likely(err == 1))
+		err = dst_output(net, sk, skb);
+
+	return err;
+}
+
 static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 					   struct net_device *dev)
 {
@@ -207,7 +221,7 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 	/* strip the ethernet header added for pass through VRF device */
 	__skb_pull(skb, skb_network_offset(skb));
 
-	ret = ip6_local_out(net, skb->sk, skb);
+	ret = vrf_ip6_local_out(net, skb->sk, skb);
 	if (unlikely(net_xmit_eval(ret)))
 		dev->stats.tx_errors++;
 	else
@@ -391,6 +405,43 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
 
+/* set dst on skb to send packet to us via dev_xmit path. Allows
+ * packet to go through device based features such as qdisc, netfilter
+ * hooks and packet sockets with skb->dev set to vrf device.
+ */
+static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
+				   struct sock *sk,
+				   struct sk_buff *skb)
+{
+	struct net_vrf *vrf = netdev_priv(vrf_dev);
+	struct dst_entry *dst = NULL;
+	struct rt6_info *rt6;
+
+	/* don't divert link scope packets */
+	if (rt6_need_strict(&ipv6_hdr(skb)->daddr))
+		return skb;
+
+	rcu_read_lock();
+
+	rt6 = rcu_dereference(vrf->rt6);
+	if (likely(rt6)) {
+		dst = &rt6->dst;
+		dst_hold(dst);
+	}
+
+	rcu_read_unlock();
+
+	if (unlikely(!dst)) {
+		vrf_tx_error(vrf_dev, skb);
+		return NULL;
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+
+	return skb;
+}
+
 /* holding rtnl */
 static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
@@ -477,6 +528,13 @@ static int vrf_rt6_create(struct net_device *dev)
 	return rc;
 }
 #else
+static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
+				   struct sock *sk,
+				   struct sk_buff *skb)
+{
+	return skb;
+}
+
 static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
 }
@@ -587,6 +645,8 @@ static struct sk_buff *vrf_l3_out(struct net_device *vrf_dev,
 	switch (proto) {
 	case AF_INET:
 		return vrf_ip_out(vrf_dev, sk, skb);
+	case AF_INET6:
+		return vrf_ip6_out(vrf_dev, sk, skb);
 	}
 
 	return skb;
@@ -1031,53 +1091,33 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
-					 struct flowi6 *fl6)
+/* send to link-local or multicast address via interface enslaved to
+ * VRF device. Force lookup to VRF table without changing flow struct
+ */
+static struct dst_entry *vrf_link_scope_lookup(const struct net_device *dev,
+					      struct flowi6 *fl6)
 {
-	bool need_strict = rt6_need_strict(&fl6->daddr);
-	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
+	int flags = RT6_LOOKUP_F_IFACE;
 	struct dst_entry *dst = NULL;
 	struct rt6_info *rt;
 
-	/* send to link-local or multicast address */
-	if (need_strict) {
-		int flags = RT6_LOOKUP_F_IFACE;
-
-		/* VRF device does not have a link-local address and
-		 * sending packets to link-local or mcast addresses over
-		 * a VRF device does not make sense
-		 */
-		if (fl6->flowi6_oif == dev->ifindex) {
-			struct dst_entry *dst = &net->ipv6.ip6_null_entry->dst;
-
-			dst_hold(dst);
-			return dst;
-		}
-
-		if (!ipv6_addr_any(&fl6->saddr))
-			flags |= RT6_LOOKUP_F_HAS_SADDR;
-
-		rt = vrf_ip6_route_lookup(net, dev, fl6, fl6->flowi6_oif, flags);
-		if (rt)
-			dst = &rt->dst;
-
-	} else if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
-
-		rcu_read_lock();
-
-		rt = rcu_dereference(vrf->rt6);
-		if (likely(rt)) {
-			dst = &rt->dst;
-			dst_hold(dst);
-		}
-
-		rcu_read_unlock();
+	/* VRF device does not have a link-local address and
+	 * sending packets to link-local or mcast addresses over
+	 * a VRF device does not make sense
+	 */
+	if (fl6->flowi6_oif == dev->ifindex) {
+		dst = &net->ipv6.ip6_null_entry->dst;
+		dst_hold(dst);
+		return dst;
 	}
 
-	/* make sure oif is set to VRF device for lookup */
-	if (!need_strict)
-		fl6->flowi6_oif = dev->ifindex;
+	if (!ipv6_addr_any(&fl6->saddr))
+		flags |= RT6_LOOKUP_F_HAS_SADDR;
+
+	rt = vrf_ip6_route_lookup(net, dev, fl6, fl6->flowi6_oif, flags);
+	if (rt)
+		dst = &rt->dst;
 
 	return dst;
 }
@@ -1130,7 +1170,7 @@ static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
 	.l3mdev_l3_out		= vrf_l3_out,
 #if IS_ENABLED(CONFIG_IPV6)
-	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
+	.l3mdev_link_scope_lookup = vrf_link_scope_lookup,
 	.l3mdev_get_saddr6	= vrf_get_saddr6,
 #endif
 };
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 3ee110518584..51aab20a4d0a 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -27,7 +27,7 @@
  *
  * @l3mdev_get_saddr: Get source address for a flow
  *
- * @l3mdev_get_rt6_dst: Get cached IPv6 rt6_info (dst_entry) for device
+ * @l3mdev_link_scope_lookup: IPv6 lookup for linklocal and mcast destinations
  */
 
 struct l3mdev_ops {
@@ -45,7 +45,7 @@ struct l3mdev_ops {
 					    struct flowi4 *fl4);
 
 	/* IPv6 ops */
-	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
+	struct dst_entry * (*l3mdev_link_scope_lookup)(const struct net_device *dev,
 						 struct flowi6 *fl6);
 	int		   (*l3mdev_get_saddr6)(struct net_device *dev,
 						const struct sock *sk,
@@ -177,7 +177,7 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 
 int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6);
+struct dst_entry *l3mdev_link_scope_lookup(struct net *net, struct flowi6 *fl6);
 int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
 		      struct flowi6 *fl6);
 
@@ -299,7 +299,7 @@ static inline int l3mdev_get_saddr(struct net *net, int ifindex,
 }
 
 static inline
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6)
+struct dst_entry *l3mdev_link_scope_lookup(struct net *net, struct flowi6 *fl6)
 {
 	return NULL;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2c681113c055..87e0a01ce744 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1188,12 +1188,15 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
 struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
 					 struct flowi6 *fl6, int flags)
 {
-	struct dst_entry *dst;
 	bool any_src;
 
-	dst = l3mdev_get_rt6_dst(net, fl6);
-	if (dst)
-		return dst;
+	if (rt6_need_strict(&fl6->daddr)) {
+		struct dst_entry *dst;
+
+		dst = l3mdev_link_scope_lookup(net, fl6);
+		if (dst)
+			return dst;
+	}
 
 	fl6->flowi6_iif = LOOPBACK_IFINDEX;
 
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 43610e5acc4e..ac9d928d0a9e 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -100,15 +100,14 @@ u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
 EXPORT_SYMBOL_GPL(l3mdev_fib_table_by_index);
 
 /**
- *	l3mdev_get_rt6_dst - IPv6 route lookup based on flow. Returns
- *			     cached route for L3 master device if relevant
- *			     to flow
+ *	l3mdev_link_scope_lookup - IPv6 route lookup based on flow for link
+ *			     local and multicast addresses
  *	@net: network namespace for device index lookup
  *	@fl6: IPv6 flow struct for lookup
  */
 
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
-				     struct flowi6 *fl6)
+struct dst_entry *l3mdev_link_scope_lookup(struct net *net,
+					   struct flowi6 *fl6)
 {
 	struct dst_entry *dst = NULL;
 	struct net_device *dev;
@@ -121,15 +120,15 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
 			dev = netdev_master_upper_dev_get_rcu(dev);
 
 		if (dev && netif_is_l3_master(dev) &&
-		    dev->l3mdev_ops->l3mdev_get_rt6_dst)
-			dst = dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6);
+		    dev->l3mdev_ops->l3mdev_link_scope_lookup)
+			dst = dev->l3mdev_ops->l3mdev_link_scope_lookup(dev, fl6);
 
 		rcu_read_unlock();
 	}
 
 	return dst;
 }
-EXPORT_SYMBOL_GPL(l3mdev_get_rt6_dst);
+EXPORT_SYMBOL_GPL(l3mdev_link_scope_lookup);
 
 /**
  *	l3mdev_get_saddr - get source address for a flow based on an interface
-- 
2.1.4
