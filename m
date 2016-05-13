From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: protect changes to private data with rcu
Date: Fri, 13 May 2016 12:23:45 -0700
Message-ID: <1463167425-20416-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34450 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbcEMTXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 15:23:51 -0400
Received: by mail-pa0-f46.google.com with SMTP id qo8so794006pab.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 12:23:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One cpu can be processing packets which includes using the cached route
entries in the vrf device's private data and on another cpu the device
gets deleted which releases the routes and sets the pointers in net_vrf
to NULL. This results in datapath dereferencing a NULL pointer.

Fix by protecting access to dst's with rcu.

Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
Fixes: 35402e313663 ("net: Add IPv6 support to VRF device")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Dave: I can handle the backports to stable branches if you prefer.

 drivers/net/vrf.c | 70 +++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 47 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 0ea29345eb2e..dff08842f26d 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -43,8 +43,8 @@
 #define DRV_VERSION	"1.0"
 
 struct net_vrf {
-	struct rtable           *rth;
-	struct rt6_info		*rt6;
+	struct rtable __rcu	*rth;
+	struct rt6_info	__rcu	*rt6;
 	u32                     tb_id;
 };
 
@@ -273,10 +273,15 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
 
+/* holding rtnl */
 static void vrf_rt6_release(struct net_vrf *vrf)
 {
-	dst_release(&vrf->rt6->dst);
-	vrf->rt6 = NULL;
+	struct rt6_info *rt6 = rtnl_dereference(vrf->rt6);
+
+	rcu_assign_pointer(vrf->rt6, NULL);
+
+	if (rt6)
+		dst_release(&rt6->dst);
 }
 
 static int vrf_rt6_create(struct net_device *dev)
@@ -300,7 +305,8 @@ static int vrf_rt6_create(struct net_device *dev)
 
 	rt6->rt6i_table = rt6i_table;
 	rt6->dst.output	= vrf_output6;
-	vrf->rt6 = rt6;
+	rcu_assign_pointer(vrf->rt6, rt6);
+
 	rc = 0;
 out:
 	return rc;
@@ -374,29 +380,35 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
+/* holding rtnl */
 static void vrf_rtable_release(struct net_vrf *vrf)
 {
-	struct dst_entry *dst = (struct dst_entry *)vrf->rth;
+	struct rtable *rth = rtnl_dereference(vrf->rth);
+
+	rcu_assign_pointer(vrf->rth, NULL);
 
-	dst_release(dst);
-	vrf->rth = NULL;
+	if (rth)
+		dst_release(&rth->dst);
 }
 
-static struct rtable *vrf_rtable_create(struct net_device *dev)
+static int vrf_rtable_create(struct net_device *dev)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct rtable *rth;
 
 	if (!fib_new_table(dev_net(dev), vrf->tb_id))
-		return NULL;
+		return -ENOMEM;
 
 	rth = rt_dst_alloc(dev, 0, RTN_UNICAST, 1, 1, 0);
-	if (rth) {
-		rth->dst.output	= vrf_output;
-		rth->rt_table_id = vrf->tb_id;
-	}
+	if (!rth)
+		return -ENOMEM;
 
-	return rth;
+	rth->dst.output	= vrf_output;
+	rth->rt_table_id = vrf->tb_id;
+
+	rcu_assign_pointer(vrf->rth, rth);
+
+	return 0;
 }
 
 /**************************** device handling ********************/
@@ -484,8 +496,7 @@ static int vrf_dev_init(struct net_device *dev)
 		goto out_nomem;
 
 	/* create the default dst which points back to us */
-	vrf->rth = vrf_rtable_create(dev);
-	if (!vrf->rth)
+	if (vrf_rtable_create(dev) != 0)
 		goto out_stats;
 
 	if (vrf_rt6_create(dev) != 0)
@@ -528,8 +539,13 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 	if (!(fl4->flowi4_flags & FLOWI_FLAG_L3MDEV_SRC)) {
 		struct net_vrf *vrf = netdev_priv(dev);
 
-		rth = vrf->rth;
-		dst_hold(&rth->dst);
+		rcu_read_lock();
+
+		rth = rcu_dereference(vrf->rth);
+		if (likely(rth))
+			dst_hold(&rth->dst);
+
+		rcu_read_unlock();
 	}
 
 	return rth;
@@ -665,16 +681,24 @@ static struct sk_buff *vrf_l3_rcv(struct net_device *vrf_dev,
 static struct dst_entry *vrf_get_rt6_dst(const struct net_device *dev,
 					 const struct flowi6 *fl6)
 {
-	struct rt6_info *rt = NULL;
+	struct dst_entry *dst = NULL;
 
 	if (!(fl6->flowi6_flags & FLOWI_FLAG_L3MDEV_SRC)) {
 		struct net_vrf *vrf = netdev_priv(dev);
+		struct rt6_info *rt;
+
+		rcu_read_lock();
+
+		rt = rcu_dereference(vrf->rt6);
+		if (likely(rt)) {
+			dst = &rt->dst;
+			dst_hold(dst);
+		}
 
-		rt = vrf->rt6;
-		dst_hold(&rt->dst);
+		rcu_read_unlock();
 	}
 
-	return (struct dst_entry *)rt;
+	return dst;
 }
 #endif
 
-- 
2.1.4
