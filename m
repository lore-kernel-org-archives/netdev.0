From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 09/12] net: l3mdev: Remove l3mdev_get_rtable
Date: Tue, 30 Aug 2016 10:34:14 -0700
Message-ID: <1472578457-26722-10-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33547 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932947AbcH3Rec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:32 -0400
Received: by mail-pa0-f47.google.com with SMTP id cy9so9571626pac.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:32 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c    | 47 ++---------------------------------------------
 include/net/l3mdev.h | 21 ---------------------
 2 files changed, 2 insertions(+), 66 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index cc18319b4b0d..08103bc7f1f5 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -47,7 +47,6 @@
 static bool add_fib_rules = true;
 
 struct net_vrf {
-	struct rtable __rcu	*rth;
 	struct rtable __rcu	*rth_local;
 	struct rt6_info	__rcu	*rt6;
 	struct rt6_info	__rcu	*rt6_local;
@@ -460,26 +459,16 @@ static struct sk_buff *vrf_l3_out(struct net_device *vrf_dev,
 /* holding rtnl */
 static void vrf_rtable_release(struct net_device *dev, struct net_vrf *vrf)
 {
-	struct rtable *rth = rtnl_dereference(vrf->rth);
 	struct rtable *rth_local = rtnl_dereference(vrf->rth_local);
 	struct net *net = dev_net(dev);
 	struct dst_entry *dst;
 
-	RCU_INIT_POINTER(vrf->rth, NULL);
 	RCU_INIT_POINTER(vrf->rth_local, NULL);
 	synchronize_rcu();
 
 	/* move dev in dst's to loopback so this VRF device can be deleted
 	 * - based on dst_ifdown
 	 */
-	if (rth) {
-		dst = &rth->dst;
-		dev_put(dst->dev);
-		dst->dev = net->loopback_dev;
-		dev_hold(dst->dev);
-		dst_release(dst);
-	}
-
 	if (rth_local) {
 		dst = &rth_local->dst;
 		dev_put(dst->dev);
@@ -492,31 +481,20 @@ static void vrf_rtable_release(struct net_device *dev, struct net_vrf *vrf)
 static int vrf_rtable_create(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct rtable *rth, *rth_local;
+	struct rtable *rth_local;
 
 	if (!fib_new_table(dev_net(dev), vrf->tb_id))
 		return -ENOMEM;
 
-	/* create a dst for routing packets out through a VRF device */
-	rth = rt_dst_alloc(dev, 0, RTN_UNICAST, 1, 1, 0);
-	if (!rth)
-		return -ENOMEM;
-
 	/* create a dst for local ingress routing - packets sent locally
 	 * to local address via the VRF device as a loopback
 	 */
 	rth_local = rt_dst_alloc(dev, RTCF_LOCAL, RTN_LOCAL, 1, 1, 0);
-	if (!rth_local) {
-		dst_release(&rth->dst);
+	if (!rth_local)
 		return -ENOMEM;
-	}
-
-	rth->dst.output	= vrf_output;
-	rth->rt_table_id = vrf->tb_id;
 
 	rth_local->rt_table_id = vrf->tb_id;
 
-	rcu_assign_pointer(vrf->rth, rth);
 	rcu_assign_pointer(vrf->rth_local, rth_local);
 
 	return 0;
@@ -648,26 +626,6 @@ static u32 vrf_fib_table(const struct net_device *dev)
 	return vrf->tb_id;
 }
 
-static struct rtable *vrf_get_rtable(const struct net_device *dev,
-				     const struct flowi4 *fl4)
-{
-	struct rtable *rth = NULL;
-
-	if (!(fl4->flowi4_flags & FLOWI_FLAG_L3MDEV_SRC)) {
-		struct net_vrf *vrf = netdev_priv(dev);
-
-		rcu_read_lock();
-
-		rth = rcu_dereference(vrf->rth);
-		if (likely(rth))
-			dst_hold(&rth->dst);
-
-		rcu_read_unlock();
-	}
-
-	return rth;
-}
-
 static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return 0;
@@ -913,7 +871,6 @@ static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 
 static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_fib_table	= vrf_fib_table,
-	.l3mdev_get_rtable	= vrf_get_rtable,
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
 	.l3mdev_l3_out		= vrf_l3_out,
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 391c46130ef6..44ceec61de63 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -23,8 +23,6 @@
  *
  * @l3mdev_l3_out:    Hook in L3 output path
  *
- * @l3mdev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
- *
  * @l3mdev_get_rt6_dst: Get cached IPv6 rt6_info (dst_entry) for device
  */
 
@@ -36,10 +34,6 @@ struct l3mdev_ops {
 					  struct sock *sk, struct sk_buff *skb,
 					  u16 proto);
 
-	/* IPv4 ops */
-	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
-					     const struct flowi4 *fl4);
-
 	/* IPv6 ops */
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
 						 struct flowi6 *fl6);
@@ -140,15 +134,6 @@ static inline u32 l3mdev_fib_table(const struct net_device *dev)
 	return tb_id;
 }
 
-static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
-					       const struct flowi4 *fl4)
-{
-	if (netif_is_l3_master(dev) && dev->l3mdev_ops->l3mdev_get_rtable)
-		return dev->l3mdev_ops->l3mdev_get_rtable(dev, fl4);
-
-	return NULL;
-}
-
 static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
 	struct net_device *dev;
@@ -269,12 +254,6 @@ static inline u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
 	return 0;
 }
 
-static inline struct rtable *l3mdev_get_rtable(const struct net_device *dev,
-					       const struct flowi4 *fl4)
-{
-	return NULL;
-}
-
 static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 {
 	return false;
-- 
2.1.4
