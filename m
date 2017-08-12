From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 1/2] net: vrf: Drop local rtable and rt6_info
Date: Fri, 11 Aug 2017 17:11:14 -0700
Message-ID: <1502496675-13349-2-git-send-email-dsahern@gmail.com>
References: <1502496675-13349-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33208 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752072AbdHLALW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 20:11:22 -0400
Received: by mail-pf0-f194.google.com with SMTP id c65so4666412pfl.0
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 17:11:22 -0700 (PDT)
In-Reply-To: <1502496675-13349-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VRF cached rtable and rt6_info for local traffic are no longer
needed and actually prevent local traffic through enslaved devices.
Remove them.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/vrf.c | 122 ++++--------------------------------------------------
 1 file changed, 8 insertions(+), 114 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index abd2010c48ae..7e19051f3230 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -47,9 +47,7 @@ static unsigned int vrf_net_id;
 
 struct net_vrf {
 	struct rtable __rcu	*rth;
-	struct rtable __rcu	*rth_local;
 	struct rt6_info	__rcu	*rt6;
-	struct rt6_info	__rcu	*rt6_local;
 	u32                     tb_id;
 };
 
@@ -194,42 +192,10 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 
 	/* if dst.dev is loopback or the VRF device again this is locally
 	 * originated traffic destined to a local address. Short circuit
-	 * to Rx path using our local dst
+	 * to Rx path
 	 */
-	if (dst->dev == net->loopback_dev || dst->dev == dev) {
-		struct net_vrf *vrf = netdev_priv(dev);
-		struct rt6_info *rt6_local;
-
-		/* release looked up dst and use cached local dst */
-		dst_release(dst);
-
-		rcu_read_lock();
-
-		rt6_local = rcu_dereference(vrf->rt6_local);
-		if (unlikely(!rt6_local)) {
-			rcu_read_unlock();
-			goto err;
-		}
-
-		/* Ordering issue: cached local dst is created on newlink
-		 * before the IPv6 initialization. Using the local dst
-		 * requires rt6i_idev to be set so make sure it is.
-		 */
-		if (unlikely(!rt6_local->rt6i_idev)) {
-			rt6_local->rt6i_idev = in6_dev_get(dev);
-			if (!rt6_local->rt6i_idev) {
-				rcu_read_unlock();
-				goto err;
-			}
-		}
-
-		dst = &rt6_local->dst;
-		dst_hold(dst);
-
-		rcu_read_unlock();
-
-		return vrf_local_xmit(skb, dev, &rt6_local->dst);
-	}
+	if (dst->dev == dev)
+		return vrf_local_xmit(skb, dev, dst);
 
 	skb_dst_set(skb, dst);
 
@@ -296,30 +262,10 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 
 	/* if dst.dev is loopback or the VRF device again this is locally
 	 * originated traffic destined to a local address. Short circuit
-	 * to Rx path using our local dst
+	 * to Rx path
 	 */
-	if (rt->dst.dev == net->loopback_dev || rt->dst.dev == vrf_dev) {
-		struct net_vrf *vrf = netdev_priv(vrf_dev);
-		struct rtable *rth_local;
-		struct dst_entry *dst = NULL;
-
-		ip_rt_put(rt);
-
-		rcu_read_lock();
-
-		rth_local = rcu_dereference(vrf->rth_local);
-		if (likely(rth_local)) {
-			dst = &rth_local->dst;
-			dst_hold(dst);
-		}
-
-		rcu_read_unlock();
-
-		if (unlikely(!dst))
-			goto err;
-
-		return vrf_local_xmit(skb, vrf_dev, dst);
-	}
+	if (rt->dst.dev == vrf_dev)
+		return vrf_local_xmit(skb, vrf_dev, &rt->dst);
 
 	skb_dst_set(skb, &rt->dst);
 
@@ -528,12 +474,10 @@ static struct sk_buff *vrf_ip6_out(struct net_device *vrf_dev,
 static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
 	struct rt6_info *rt6 = rtnl_dereference(vrf->rt6);
-	struct rt6_info *rt6_local = rtnl_dereference(vrf->rt6_local);
 	struct net *net = dev_net(dev);
 	struct dst_entry *dst;
 
 	RCU_INIT_POINTER(vrf->rt6, NULL);
-	RCU_INIT_POINTER(vrf->rt6_local, NULL);
 	synchronize_rcu();
 
 	/* move dev in dst's to loopback so this VRF device can be deleted
@@ -546,19 +490,6 @@ static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 		dev_hold(dst->dev);
 		dst_release(dst);
 	}
-
-	if (rt6_local) {
-		if (rt6_local->rt6i_idev) {
-			in6_dev_put(rt6_local->rt6i_idev);
-			rt6_local->rt6i_idev = NULL;
-		}
-
-		dst = &rt6_local->dst;
-		dev_put(dst->dev);
-		dst->dev = net->loopback_dev;
-		dev_hold(dst->dev);
-		dst_release(dst);
-	}
 }
 
 static int vrf_rt6_create(struct net_device *dev)
@@ -567,7 +498,7 @@ static int vrf_rt6_create(struct net_device *dev)
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct fib6_table *rt6i_table;
-	struct rt6_info *rt6, *rt6_local;
+	struct rt6_info *rt6;
 	int rc = -ENOMEM;
 
 	/* IPv6 can be CONFIG enabled and then disabled runtime */
@@ -586,22 +517,7 @@ static int vrf_rt6_create(struct net_device *dev)
 	rt6->rt6i_table = rt6i_table;
 	rt6->dst.output	= vrf_output6;
 
-	/* create a dst for local routing - packets sent locally
-	 * to local address via the VRF device as a loopback
-	 */
-	rt6_local = ip6_dst_alloc(net, dev, flags);
-	if (!rt6_local) {
-		dst_release(&rt6->dst);
-		goto out;
-	}
-
-	rt6_local->rt6i_idev  = in6_dev_get(dev);
-	rt6_local->rt6i_flags = RTF_UP | RTF_NONEXTHOP | RTF_LOCAL;
-	rt6_local->rt6i_table = rt6i_table;
-	rt6_local->dst.input  = ip6_input;
-
 	rcu_assign_pointer(vrf->rt6, rt6);
-	rcu_assign_pointer(vrf->rt6_local, rt6_local);
 
 	rc = 0;
 out:
@@ -788,12 +704,10 @@ static struct sk_buff *vrf_l3_out(struct net_device *vrf_dev,
 static void vrf_rtable_release(struct net_device *dev, struct net_vrf *vrf)
 {
 	struct rtable *rth = rtnl_dereference(vrf->rth);
-	struct rtable *rth_local = rtnl_dereference(vrf->rth_local);
 	struct net *net = dev_net(dev);
 	struct dst_entry *dst;
 
 	RCU_INIT_POINTER(vrf->rth, NULL);
-	RCU_INIT_POINTER(vrf->rth_local, NULL);
 	synchronize_rcu();
 
 	/* move dev in dst's to loopback so this VRF device can be deleted
@@ -806,20 +720,12 @@ static void vrf_rtable_release(struct net_device *dev, struct net_vrf *vrf)
 		dev_hold(dst->dev);
 		dst_release(dst);
 	}
-
-	if (rth_local) {
-		dst = &rth_local->dst;
-		dev_put(dst->dev);
-		dst->dev = net->loopback_dev;
-		dev_hold(dst->dev);
-		dst_release(dst);
-	}
 }
 
 static int vrf_rtable_create(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct rtable *rth, *rth_local;
+	struct rtable *rth;
 
 	if (!fib_new_table(dev_net(dev), vrf->tb_id))
 		return -ENOMEM;
@@ -829,22 +735,10 @@ static int vrf_rtable_create(struct net_device *dev)
 	if (!rth)
 		return -ENOMEM;
 
-	/* create a dst for local ingress routing - packets sent locally
-	 * to local address via the VRF device as a loopback
-	 */
-	rth_local = rt_dst_alloc(dev, RTCF_LOCAL, RTN_LOCAL, 1, 1, 0);
-	if (!rth_local) {
-		dst_release(&rth->dst);
-		return -ENOMEM;
-	}
-
 	rth->dst.output	= vrf_output;
 	rth->rt_table_id = vrf->tb_id;
 
-	rth_local->rt_table_id = vrf->tb_id;
-
 	rcu_assign_pointer(vrf->rth, rth);
-	rcu_assign_pointer(vrf->rth_local, rth_local);
 
 	return 0;
 }
-- 
2.1.4
