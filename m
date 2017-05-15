From: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>
Subject: [PATCH] ipmr: vrf: Find VIFs using the actual device
Date: Tue, 16 May 2017 10:14:44 +1200
Message-ID: <20170515221444.4913-1-Thomas.Winter@alliedtelesis.co.nz>
Cc: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>,
        David Ahern <dsa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:59216 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751504AbdEOWO5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 18:14:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb->dev that is passed into ip_mr_input is
the loX device for VRFs. When we lookup a vif
for this dev, none is found as we do not create
vifs for loopbacks. Instead lookup a vif for the
actual device that the packet was received on,
eg the vlan.

Signed-off-by: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>
cc: David Ahern <dsa@cumulusnetworks.com>
cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
cc: roopa <roopa@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 3a02d52ed50e..551de4d023a8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1980,6 +1980,20 @@ int ip_mr_input(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	int local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
 	struct mr_table *mrt;
+	struct net_device *dev;
+
+	/* skb->dev passed in is the loX master dev for vrfs.
+	 * As there are no vifs associated with loopback devices,
+	 * get the proper interface that does have a vif associated with it.
+	 */
+	dev = skb->dev;
+	if (netif_is_l3_master(skb->dev)) {
+		dev = dev_get_by_index_rcu(net, IPCB(skb)->iif);
+		if (!dev) {
+			kfree_skb(skb);
+			return -ENODEV;
+		}
+	}
 
 	/* Packet is looped back after forward, it should not be
 	 * forwarded second time, but still can be delivered locally.
@@ -2017,7 +2031,7 @@ int ip_mr_input(struct sk_buff *skb)
 	/* already under rcu_read_lock() */
 	cache = ipmr_cache_find(mrt, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
 	if (!cache) {
-		int vif = ipmr_find_vif(mrt, skb->dev);
+		int vif = ipmr_find_vif(mrt, dev);
 
 		if (vif >= 0)
 			cache = ipmr_cache_find_any(mrt, ip_hdr(skb)->daddr,
@@ -2037,7 +2051,7 @@ int ip_mr_input(struct sk_buff *skb)
 		}
 
 		read_lock(&mrt_lock);
-		vif = ipmr_find_vif(mrt, skb->dev);
+		vif = ipmr_find_vif(mrt, dev);
 		if (vif >= 0) {
 			int err2 = ipmr_cache_unresolved(mrt, vif, skb);
 			read_unlock(&mrt_lock);
-- 
2.11.0
