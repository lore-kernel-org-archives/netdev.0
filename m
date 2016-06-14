From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Switch dst dev to loopback on device delete
Date: Tue, 14 Jun 2016 11:37:21 -0700
Message-ID: <1465929441-19163-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36219 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319AbcFNSh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 14:37:28 -0400
Received: by mail-pf0-f170.google.com with SMTP id t190so59855739pfb.3
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 11:37:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attempting to delete a VRF device with a socket bound to it can stall:

  unregister_netdevice: waiting for red to become free. Usage count = 1

The unregister is waiting for the dst to be released and with it
references to the vrf device. Similar to dst_ifdown switch the dst
dev to loopback on delete for all of the dst's for the vrf device
and release the references to the vrf device.

Fixes: 193125dbd8eb2 ("net: Introduce VRF device driver")
Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 55 ++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 42 insertions(+), 13 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index e3fc6d32a289..32173aa9208e 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -378,23 +378,37 @@ static int vrf_output6(struct net *net, struct sock *sk, struct sk_buff *skb)
 }
 
 /* holding rtnl */
-static void vrf_rt6_release(struct net_vrf *vrf)
+static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
 	struct rt6_info *rt6 = rtnl_dereference(vrf->rt6);
 	struct rt6_info *rt6_local = rtnl_dereference(vrf->rt6_local);
+	struct net *net = dev_net(dev);
+	struct dst_entry *dst;
 
 	RCU_INIT_POINTER(vrf->rt6, NULL);
 	RCU_INIT_POINTER(vrf->rt6_local, NULL);
 	synchronize_rcu();
 
-	if (rt6)
-		dst_release(&rt6->dst);
+	/* move dev in dst's to loopback so this VRF device can be deleted
+	 * - based on dst_ifdown
+	 */
+	if (rt6) {
+		dst = &rt6->dst;
+		dev_put(dst->dev);
+		dst->dev = net->loopback_dev;
+		dev_hold(dst->dev);
+		dst_release(dst);
+	}
 
 	if (rt6_local) {
 		if (rt6_local->rt6i_idev)
 			in6_dev_put(rt6_local->rt6i_idev);
 
-		dst_release(&rt6_local->dst);
+		dst = &rt6_local->dst;
+		dev_put(dst->dev);
+		dst->dev = net->loopback_dev;
+		dev_hold(dst->dev);
+		dst_release(dst);
 	}
 }
 
@@ -449,7 +463,7 @@ static int vrf_rt6_create(struct net_device *dev)
 	return rc;
 }
 #else
-static void vrf_rt6_release(struct net_vrf *vrf)
+static void vrf_rt6_release(struct net_device *dev, struct net_vrf *vrf)
 {
 }
 
@@ -518,20 +532,35 @@ static int vrf_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 }
 
 /* holding rtnl */
-static void vrf_rtable_release(struct net_vrf *vrf)
+static void vrf_rtable_release(struct net_device *dev, struct net_vrf *vrf)
 {
 	struct rtable *rth = rtnl_dereference(vrf->rth);
 	struct rtable *rth_local = rtnl_dereference(vrf->rth_local);
+	struct net *net = dev_net(dev);
+	struct dst_entry *dst;
 
 	RCU_INIT_POINTER(vrf->rth, NULL);
 	RCU_INIT_POINTER(vrf->rth_local, NULL);
 	synchronize_rcu();
 
-	if (rth)
-		dst_release(&rth->dst);
+	/* move dev in dst's to loopback so this VRF device can be deleted
+	 * - based on dst_ifdown
+	 */
+	if (rth) {
+		dst = &rth->dst;
+		dev_put(dst->dev);
+		dst->dev = net->loopback_dev;
+		dev_hold(dst->dev);
+		dst_release(dst);
+	}
 
-	if (rth_local)
-		dst_release(&rth_local->dst);
+	if (rth_local) {
+		dst = &rth_local->dst;
+		dev_put(dst->dev);
+		dst->dev = net->loopback_dev;
+		dev_hold(dst->dev);
+		dst_release(dst);
+	}
 }
 
 static int vrf_rtable_create(struct net_device *dev)
@@ -633,8 +662,8 @@ static void vrf_dev_uninit(struct net_device *dev)
 	struct net_device *port_dev;
 	struct list_head *iter;
 
-	vrf_rtable_release(vrf);
-	vrf_rt6_release(vrf);
+	vrf_rtable_release(dev, vrf);
+	vrf_rt6_release(dev, vrf);
 
 	netdev_for_each_lower_dev(dev, port_dev, iter)
 		vrf_del_slave(dev, port_dev);
@@ -669,7 +698,7 @@ static int vrf_dev_init(struct net_device *dev)
 	return 0;
 
 out_rth:
-	vrf_rtable_release(vrf);
+	vrf_rtable_release(dev, vrf);
 out_stats:
 	free_percpu(dev->dstats);
 	dev->dstats = NULL;
-- 
2.1.4
