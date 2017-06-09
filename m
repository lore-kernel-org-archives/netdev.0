From: Donald Sharp <sharpd@cumulusnetworks.com>
Subject: [PATCH] Fix some mroute forwarding issues in vrf's
Date: Fri,  9 Jun 2017 10:10:47 -0400
Message-ID: <20170609141047.23499-1-sharpd@cumulusnetworks.com>
To: netdev@vger.kernel.org, dsahern@gmail.com,
        Thomas.Winter@alliedtelesis.co.nz, nikolay@cumulusnetworks.com,
        yotamg@mellanox.com, idosch@mellanox.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34709 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbdFIOLA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 10:11:00 -0400
Received: by mail-pg0-f53.google.com with SMTP id v18so27018117pgb.1
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 07:11:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes two issues:

1) When forwarding on *,G mroutes that are in a vrf, the
kernel was dropping information about the actual incoming
interface when calling ip_mr_forward from ip_mr_input.
This caused ip_mr_forward to send the multicast packet
back out the incoming interface.  Fix this by
modifying ip_mr_forward to be handed the correctly
resolved dev.

2) When a unresolved cache entry is created we store
the incoming skb on the unresolved cache entry and
upon mroute resolution from the user space daemon,
we attempt to forward the packet.  Again we were
not resolving to the correct incoming device for
a vrf scenario, before calling ip_mr_forward.
Fix this by resolving to the correct interface
and calling ip_mr_forward with the result.

Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 551de4d..559009e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -101,8 +101,8 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id);
 static void ipmr_free_table(struct mr_table *mrt);
 
 static void ip_mr_forward(struct net *net, struct mr_table *mrt,
-			  struct sk_buff *skb, struct mfc_cache *cache,
-			  int local);
+			  struct net_device *dev, struct sk_buff *skb,
+                          struct mfc_cache *cache, int local);
 static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
@@ -988,7 +988,16 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 
 			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else {
-			ip_mr_forward(net, mrt, skb, c, 0);
+                        struct net_device *dev = skb->dev;
+
+                        if (netif_is_l3_master(dev)) {
+                                dev = __dev_get_by_index(net, IPCB(skb)->iif);
+                                if (!dev) {
+                                        kfree_skb(skb);
+                                        continue;
+                                }
+                        }
+                        ip_mr_forward(net, mrt, dev, skb, c, 0);
 		}
 	}
 }
@@ -1828,10 +1837,10 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 static void ip_mr_forward(struct net *net, struct mr_table *mrt,
-			  struct sk_buff *skb, struct mfc_cache *cache,
-			  int local)
+			  struct net_device *dev, struct sk_buff *skb,
+                          struct mfc_cache *cache, int local)
 {
-	int true_vifi = ipmr_find_vif(mrt, skb->dev);
+	int true_vifi = ipmr_find_vif(mrt, dev);
 	int psend = -1;
 	int vif, ct;
 
@@ -1853,11 +1862,11 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 	}
 
 	/* Wrong interface: drop packet and (maybe) send PIM assert. */
-	if (mrt->vif_table[vif].dev != skb->dev) {
+	if (mrt->vif_table[vif].dev != dev) {
 		struct net_device *mdev;
 
 		mdev = l3mdev_master_dev_rcu(mrt->vif_table[vif].dev);
-		if (mdev == skb->dev)
+		if (mdev == dev)
 			goto forward;
 
 		if (rt_is_output_route(skb_rtable(skb))) {
@@ -2064,7 +2073,7 @@ int ip_mr_input(struct sk_buff *skb)
 	}
 
 	read_lock(&mrt_lock);
-	ip_mr_forward(net, mrt, skb, cache, local);
+	ip_mr_forward(net, mrt, dev, skb, cache, local);
 	read_unlock(&mrt_lock);
 
 	if (local)
-- 
2.9.4
