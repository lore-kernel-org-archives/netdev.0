From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 10/12] net: l3mdev: Remove l3mdev_get_rt6_dst
Date: Tue, 30 Aug 2016 10:34:15 -0700
Message-ID: <1472578457-26722-11-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33549 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932947AbcH3Ren (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:43 -0400
Received: by mail-pa0-f43.google.com with SMTP id cy9so9571688pac.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:33 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 92 +++-------------------------------------------------
 include/net/l3mdev.h | 14 --------
 net/l3mdev/l3mdev.c  | 32 ------------------
 3 files changed, 4 insertions(+), 134 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 08103bc7f1f5..23801647c113 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -48,7 +48,6 @@ static bool add_fib_rules = true;
 
 struct net_vrf {
 	struct rtable __rcu	*rth_local;
-	struct rt6_info	__rcu	*rt6;
 	struct rt6_info	__rcu	*rt6_local;
 	u32                     tb_id;
 };
@@ -289,25 +288,11 @@ static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
 /* holding rtnl */
 static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
-	struct rt6_info *rt6 = rtnl_dereference(vrf->rt6);
 	struct rt6_info *rt6_local = rtnl_dereference(vrf->rt6_local);
 	struct net *net = dev_net(dev);
 	struct dst_entry *dst;
 
-	RCU_INIT_POINTER(vrf->rt6, NULL);
-	RCU_INIT_POINTER(vrf->rt6_local, NULL);
-	synchronize_rcu();
-
-	/* move dev in dst's to loopback so this VRF device can be deleted
-	 * - based on dst_ifdown
-	 */
-	if (rt6) {
-		dst = &rt6->dst;
-		dev_put(dst->dev);
-		dst->dev = net->loopback_dev;
-		dev_hold(dst->dev);
-		dst_release(dst);
-	}
+	rcu_assign_pointer(vrf->rt6_local, NULL);
 
 	if (rt6_local) {
 		if (rt6_local->rt6i_idev)
@@ -327,7 +312,7 @@ static int vrf_rt6_create(struct net_device *dev)
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct fib6_table *rt6i_table;
-	struct rt6_info *rt6, *rt6_local;
+	struct rt6_info *rt6_local;
 	int rc = -ENOMEM;
 
 	/* IPv6 can be CONFIG enabled and then disabled runtime */
@@ -338,24 +323,12 @@ static int vrf_rt6_create(struct net_device *dev)
 	if (!rt6i_table)
 		goto out;
 
-	/* create a dst for routing packets out a VRF device */
-	rt6 = ip6_dst_alloc(net, dev, flags);
-	if (!rt6)
-		goto out;
-
-	dst_hold(&rt6->dst);
-
-	rt6->rt6i_table = rt6i_table;
-	rt6->dst.output	= vrf_output6;
-
 	/* create a dst for local routing - packets sent locally
 	 * to local address via the VRF device as a loopback
 	 */
 	rt6_local = ip6_dst_alloc(net, dev, flags);
-	if (!rt6_local) {
-		dst_release(&rt6->dst);
+	if (!rt6_local)
 		goto out;
-	}
 
 	dst_hold(&rt6_local->dst);
 
@@ -364,7 +337,6 @@ static int vrf_rt6_create(struct net_device *dev)
 	rt6_local->rt6i_table = rt6i_table;
 	rt6_local->dst.input  = ip6_input;
 
-	rcu_assign_pointer(vrf->rt6, rt6);
 	rcu_assign_pointer(vrf->rt6_local, rt6_local);
 
 	rc = 0;
@@ -693,7 +665,7 @@ static struct rt6_info *vrf_ip6_route_lookup(struct net *net,
 	rcu_read_lock();
 
 	/* fib6_table does not have a refcnt and can not be freed */
-	rt6 = rcu_dereference(vrf->rt6);
+	rt6 = rcu_dereference(vrf->rt6_local);
 	if (likely(rt6))
 		table = rt6->rt6i_table;
 
@@ -816,66 +788,10 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 	return skb;
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
-static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
-					 struct flowi6 *fl6)
-{
-	bool need_strict = rt6_need_strict(&fl6->daddr);
-	struct net_vrf *vrf = netdev_priv(dev);
-	struct net *net = dev_net(dev);
-	struct dst_entry *dst = NULL;
-	struct rt6_info *rt;
-
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
-	}
-
-	/* make sure oif is set to VRF device for lookup */
-	if (!need_strict)
-		fl6->flowi6_oif = dev->ifindex;
-
-	return dst;
-}
-#endif
-
 static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
 	.l3mdev_l3_out		= vrf_l3_out,
-#if IS_ENABLED(CONFIG_IPV6)
-	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
-#endif
 };
 
 static void vrf_get_drvinfo(struct net_device *dev,
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 44ceec61de63..3c1d71474f55 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -22,8 +22,6 @@
  * @l3mdev_l3_rcv:    Hook in L3 receive path
  *
  * @l3mdev_l3_out:    Hook in L3 output path
- *
- * @l3mdev_get_rt6_dst: Get cached IPv6 rt6_info (dst_entry) for device
  */
 
 struct l3mdev_ops {
@@ -33,10 +31,6 @@ struct l3mdev_ops {
 	struct sk_buff * (*l3mdev_l3_out)(struct net_device *dev,
 					  struct sock *sk, struct sk_buff *skb,
 					  u16 proto);
-
-	/* IPv6 ops */
-	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
-						 struct flowi6 *fl6);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -153,8 +147,6 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return rc;
 }
 
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6);
-
 static inline
 struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
 {
@@ -260,12 +252,6 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 }
 
 static inline
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6)
-{
-	return NULL;
-}
-
-static inline
 struct sk_buff *l3mdev_ip_rcv(struct sk_buff *skb)
 {
 	return skb;
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 998e4dc2e6f9..2ba2a650bae9 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -100,38 +100,6 @@ u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
 EXPORT_SYMBOL_GPL(l3mdev_fib_table_by_index);
 
 /**
- *	l3mdev_get_rt6_dst - IPv6 route lookup based on flow. Returns
- *			     cached route for L3 master device if relevant
- *			     to flow
- *	@net: network namespace for device index lookup
- *	@fl6: IPv6 flow struct for lookup
- */
-
-struct dst_entry *l3mdev_get_rt6_dst(struct net *net,
-				     struct flowi6 *fl6)
-{
-	struct dst_entry *dst = NULL;
-	struct net_device *dev;
-
-	if (fl6->flowi6_oif) {
-		rcu_read_lock();
-
-		dev = dev_get_by_index_rcu(net, fl6->flowi6_oif);
-		if (dev && netif_is_l3_slave(dev))
-			dev = netdev_master_upper_dev_get_rcu(dev);
-
-		if (dev && netif_is_l3_master(dev) &&
-		    dev->l3mdev_ops->l3mdev_get_rt6_dst)
-			dst = dev->l3mdev_ops->l3mdev_get_rt6_dst(dev, fl6);
-
-		rcu_read_unlock();
-	}
-
-	return dst;
-}
-EXPORT_SYMBOL_GPL(l3mdev_get_rt6_dst);
-
-/**
  *	l3mdev_fib_rule_match - Determine if flowi references an
  *				L3 master device
  *	@net: network namespace for device index lookup
-- 
2.1.4
