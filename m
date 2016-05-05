From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 11/13] net: vrf: rcu protect changes to private data
Date: Wed,  4 May 2016 20:33:28 -0700
Message-ID: <1462419210-10463-12-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33013 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755980AbcEEDeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:23 -0400
Received: by mail-pf0-f173.google.com with SMTP id 206so32706577pfu.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:22 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem is that one cpu is processing packets which includes using
the cached route entries in the vrf device's private data and on another
cpu the device is getting deleted which releases the routes and sets
the pointers to NULL. Fix by rcu protecting the changes.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 202 ++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 142 insertions(+), 60 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index f4b44e23e6c2..fb2d0b2052ea 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -43,10 +43,10 @@
 #define DRV_VERSION	"1.0"
 
 struct net_vrf {
-	struct rtable           *rth;
-	struct rtable           *rth_local;
-	struct rt6_info		*rt6;
-	struct rt6_info		*rt6_local;
+	struct rtable __rcu	*rth;
+	struct rtable __rcu	*rth_local;
+	struct rt6_info	__rcu	*rt6;
+	struct rt6_info	__rcu	*rt6_local;
 	u32                     tb_id;
 };
 
@@ -104,8 +104,6 @@ static int vrf_local_xmit(struct sk_buff *skb, struct dst_entry *dst)
 	int len = skb->len;
 
 	skb_orphan(skb);
-
-	dst_hold(dst);
 	skb_dst_set(skb, dst);
 	skb_dst_force(skb);
 
@@ -149,11 +147,13 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 	struct dst_entry *dst;
 	struct dst_entry *dst_null = &net->ipv6.ip6_null_entry->dst;
 
+	skb_dst_drop(skb);
+
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == dst_null)
+	if (dst == dst_null) {
+		dst_release(dst);
 		goto err;
-
-	skb_dst_drop(skb);
+	}
 
 	/* if dst.dev is loopback or the VRF device again this is locally
 	 * originated traffic destined to a local address. Short circuit
@@ -161,22 +161,37 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 	 */
 	if (dst->dev == net->loopback_dev || dst->dev == dev) {
 		struct net_vrf *vrf = netdev_priv(dev);
-		struct rt6_info *rt6_local = vrf->rt6_local;
+		struct rt6_info *rt6_local;
 
 		/* release looked up dst and use cached local dst */
 		dst_release(dst);
 
+		rcu_read_lock();
+
+		rt6_local = rcu_dereference(vrf->rt6_local);
+		if (unlikely(!rt6_local)) {
+			rcu_read_unlock();
+			goto err;
+		}
+
 		/* Ordering issue: cached local dst is created on newlink
 		 * before the IPv6 initialization. Using the local dst
 		 * requires rt6i_idev to be set so make sure it is.
 		 */
-		if (!rt6_local->rt6i_idev) {
+		if (unlikely(!rt6_local->rt6i_idev)) {
 			rt6_local->rt6i_idev = in6_dev_get(dev);
-			if (!rt6_local->rt6i_idev)
+			if (!rt6_local->rt6i_idev) {
+				rcu_read_unlock();
 				goto err;
+			}
 		}
 
-		return vrf_local_xmit(skb, &rt6_local->dst);
+		dst = &rt6_local->dst;
+		dst_hold(dst);
+
+		rcu_read_unlock();
+
+		return vrf_local_xmit(skb, dst);
 	}
 
 	/* strip the ethernet header added for pass through VRF device */
@@ -238,9 +253,25 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 	 */
 	if (rt->dst.dev == net->loopback_dev || rt->dst.dev == vrf_dev) {
 		struct net_vrf *vrf = netdev_priv(vrf_dev);
+		struct rtable *rth_local;
+		struct dst_entry *dst = NULL;
 
 		ip_rt_put(rt);
-		return vrf_local_xmit(skb, &vrf->rth_local->dst);
+
+		rcu_read_lock();
+
+		rth_local = rcu_dereference(vrf->rth_local);
+		if (likely(rth_local)) {
+			dst = &rth_local->dst;
+			dst_hold(dst);
+		}
+
+		rcu_read_unlock();
+
+		if (unlikely(!dst))
+			goto err;
+
+		return vrf_local_xmit(skb, dst);
 	}
 
 	skb_dst_set(skb, &rt->dst);
@@ -338,20 +369,28 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
 
+/* holding rtnl */
 static void vrf_rt6_release(struct net_vrf *vrf)
 {
-	struct rt6_info *rt6;
+	struct rt6_info *rt6, *rt6_local;
+
+	rt6       = rtnl_dereference(vrf->rt6);
+	rt6_local = rtnl_dereference(vrf->rt6_local);
 
-	rt6 = vrf->rt6;
-	dst_release(&rt6->dst);
-	vrf->rt6 = NULL;
+	RCU_INIT_POINTER(vrf->rt6,       NULL);
+	RCU_INIT_POINTER(vrf->rt6_local, NULL);
 
-	rt6 = vrf->rt6_local;
-	if (rt6->rt6i_idev)
-		in6_dev_put(rt6->rt6i_idev);
+	synchronize_rcu();
 
-	dst_release(&rt6->dst);
-	vrf->rt6_local = NULL;
+	if (rt6)
+		dst_release(&rt6->dst);
+
+	if (rt6_local) {
+		if (rt6_local->rt6i_idev)
+			in6_dev_put(rt6_local->rt6i_idev);
+
+		dst_release(&rt6_local->dst);
+	}
 }
 
 static int vrf_rt6_create(struct net_device *dev)
@@ -360,7 +399,7 @@ static int vrf_rt6_create(struct net_device *dev)
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct fib6_table *rt6i_table;
-	struct rt6_info *rt6;
+	struct rt6_info *rt6, *rt6_local;
 	int rc = -ENOMEM;
 
 	rt6i_table = fib6_new_table(net, vrf->tb_id);
@@ -375,25 +414,26 @@ static int vrf_rt6_create(struct net_device *dev)
 	dst_hold(&rt6->dst);
 	rt6->rt6i_table = rt6i_table;
 	rt6->dst.output = vrf_output6;
-	vrf->rt6 = rt6;
 
 	/* create a dst for local routing - packets sent locally
 	 * to local address via the VRF device as a loopback
 	 */
-	rt6 = ip6_dst_alloc(net, dev, flags);
-	if (!rt6) {
-		dst_release(&vrf->rt6->dst);
+	rt6_local = ip6_dst_alloc(net, dev, flags);
+	if (!rt6_local) {
+		dst_release(&rt6->dst);
 		goto out;
 	}
 
-	dst_hold(&rt6->dst);
+	dst_hold(&rt6_local->dst);
 
-	rt6->dst.flags |= DST_HOST;
-	rt6->rt6i_idev = in6_dev_get(dev);
-	rt6->rt6i_flags = RTF_UP | RTF_NONEXTHOP | RTF_LOCAL;
-	rt6->rt6i_table = rt6i_table;
-	rt6->dst.input = ip6_input;
-	vrf->rt6_local = rt6;
+	rt6_local->dst.flags |= DST_HOST;
+	rt6_local->rt6i_idev = in6_dev_get(dev);
+	rt6_local->rt6i_flags = RTF_UP | RTF_NONEXTHOP | RTF_LOCAL;
+	rt6_local->rt6i_table = rt6i_table;
+	rt6_local->dst.input = ip6_input;
+
+	rcu_assign_pointer(vrf->rt6, rt6);
+	rcu_assign_pointer(vrf->rt6_local, rt6_local);
 
 	rc = 0;
 out:
@@ -468,19 +508,30 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
+/* holding rtnl */
 static void vrf_rtable_release(struct net_vrf *vrf)
 {
-	dst_release(&vrf->rth->dst);
-	dst_release(&vrf->rth_local->dst);
+	struct rtable *rth, *rth_local;
+
+	rth       = rtnl_dereference(vrf->rth);
+	rth_local = rtnl_dereference(vrf->rth_local);
+
+	RCU_INIT_POINTER(vrf->rth,       NULL);
+	RCU_INIT_POINTER(vrf->rth_local, NULL);
 
-	vrf->rth = NULL;
-	vrf->rth_local = NULL;
+	synchronize_rcu();
+
+	if (rth)
+		dst_release(&rth->dst);
+
+	if (rth_local)
+		dst_release(&rth_local->dst);
 }
 
 static int vrf_rtable_create(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct rtable *rth;
+	struct rtable *rth, *rth_local;
 
 	if (!fib_new_table(dev_net(dev), vrf->tb_id))
 		return -ENOMEM;
@@ -488,25 +539,26 @@ static int vrf_rtable_create(struct net_device *dev)
 	/* create a dst for local ingress routing - packets sent locally
 	 * to local address via the VRF device as a loopback
 	 */
-	rth = rt_dst_alloc(dev, RTCF_LOCAL, RTN_LOCAL, 1, 1, 0);
-	if (!rth)
+	rth_local = rt_dst_alloc(dev, RTCF_LOCAL, RTN_LOCAL, 1, 1, 0);
+	if (!rth_local)
 		return -ENOMEM;
 
-	rth->dst.dev = dev;
-	rth->rt_table_id = vrf->tb_id;
-	vrf->rth_local = rth;
+	rth_local->dst.dev = dev;
+	rth_local->rt_table_id = vrf->tb_id;
 
 	/* create a dst for routing packets out through a VRF device */
 	rth = rt_dst_alloc(dev, 0, RTN_UNICAST, 1, 1, 0);
 	if (!rth) {
-		dst_release(&vrf->rth_local->dst);
+		dst_release(&rth_local->dst);
 		return -ENOMEM;
 	}
 
 	rth->dst.output = vrf_output;
 	rth->dst.dev = dev;
 	rth->rt_table_id = vrf->tb_id;
-	vrf->rth = rth;
+
+	rcu_assign_pointer(vrf->rth, rth);
+	rcu_assign_pointer(vrf->rth_local, rth_local);
 
 	return 0;
 }
@@ -639,8 +691,13 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 	if (!(fl4->flowi4_flags & FLOWI_FLAG_L3MDEV_SRC)) {
 		struct net_vrf *vrf = netdev_priv(dev);
 
-		rth = vrf->rth;
-		dst_hold(&rth->dst);
+		rcu_read_lock();
+
+		rth = rcu_dereference(vrf->rth);
+		if (rth)
+			dst_hold(&rth->dst);
+
+		rcu_read_unlock();
 	}
 
 	return rth;
@@ -731,10 +788,18 @@ static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
 	};
 	struct net_vrf *vrf = netdev_priv(vrf_dev);
 	struct net *net = dev_net(vrf_dev);
-	struct fib6_table *table;
+	struct fib6_table *table = NULL;
 	struct rt6_info *rt6;
 
-	table = vrf->rt6->rt6i_table;
+	rcu_read_lock();
+
+	/* fib6_table does not have a refcnt and can not be freed */
+	rt6 = rcu_dereference(vrf->rt6);
+	if (likely(rt6))
+		table = rt6->rt6i_table;
+
+	rcu_read_unlock();
+
 	if (!table)
 		return;
 
@@ -821,11 +886,12 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 {
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
-	struct rt6_info *rt = NULL;
+	struct dst_entry *dst = NULL;
+	struct rt6_info *rt6;
 
 	/* send to link-local or multicast address */
 	if (rt6_need_strict(&fl6->daddr)) {
-		struct fib6_table *table;
+		struct fib6_table *table = NULL;
 
 		/* VRF device does not have a link-local address and
 		 * sending packets to link-local or mcast addresses over
@@ -838,7 +904,15 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 			return dst;
 		}
 
-		table = vrf->rt6->rt6i_table;
+		rcu_read_lock();
+
+		/* fib6_table does not have a refcnt and can not be freed */
+		rt6 = rcu_dereference(vrf->rt6);
+		if (likely(rt6))
+			table = rt6->rt6i_table;
+
+		rcu_read_unlock();
+
 		if (!table)
 			return NULL;
 
@@ -846,15 +920,23 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 		if (!ipv6_addr_any(&fl6->saddr))
 			flags |= RT6_LOOKUP_F_HAS_SADDR;
 
-		rt = ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
-	} else {
-		if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
-			rt = vrf->rt6;
-			dst_hold(&rt->dst);
+		rt6 = ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
+		if (rt6)
+			dst = &rt6->dst;
+
+	} else if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
+		rcu_read_lock();
+
+		rt6 = rcu_dereference(vrf->rt6);
+		if (likely(rt6)) {
+			dst = &rt6->dst;
+			dst_hold(dst);
 		}
+
+		rcu_read_unlock();
 	}
 
-	return &rt->dst;
+	return dst;
 }
 #endif
 
-- 
2.1.4
