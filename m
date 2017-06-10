From: Donald Sharp <sharpd@cumulusnetworks.com>
Subject: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in vrf's
Date: Sat, 10 Jun 2017 16:30:17 -0400
Message-ID: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
To: netdev@vger.kernel.org, dsahern@gmail.com,
        Thomas.Winter@alliedtelesis.co.nz, nikolay@cumulusnetworks.com,
        yotamg@mellanox.com, idosch@mellanox.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35391 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbdFJUa2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:30:28 -0400
Received: by mail-qk0-f175.google.com with SMTP id a199so15846614qkb.2
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 13:30:27 -0700 (PDT)
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

Fixes: e58e41596811 ("net: Enable support for VRF with ipv4 multicast")
Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
---
v2: Fixed title
v3: Addressed Review comments by Andrew Lunn and David Ahern

 net/ipv4/ipmr.c | 32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 551de4d..09368a1 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -101,8 +101,8 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id);
 static void ipmr_free_table(struct mr_table *mrt);
 
 static void ip_mr_forward(struct net *net, struct mr_table *mrt,
-			  struct sk_buff *skb, struct mfc_cache *cache,
-			  int local);
+			  struct net_device *dev, struct sk_buff *skb,
+			  struct mfc_cache *cache, int local);
 static int ipmr_cache_report(struct mr_table *mrt,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
@@ -988,7 +988,7 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 
 			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else {
-			ip_mr_forward(net, mrt, skb, c, 0);
+			ip_mr_forward(net, mrt, skb->dev, skb, c, 0);
 		}
 	}
 }
@@ -1073,7 +1073,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 
 /* Queue a packet for resolution. It gets locked cache entry! */
 static int ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi,
-				 struct sk_buff *skb)
+				 struct sk_buff *skb, struct net_device *dev)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct mfc_cache *c;
@@ -1130,6 +1130,10 @@ static int ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi,
 		kfree_skb(skb);
 		err = -ENOBUFS;
 	} else {
+		if (dev) {
+			skb->dev = dev;
+			skb->skb_iif = dev->ifindex;
+		}
 		skb_queue_tail(&c->mfc_un.unres.unresolved, skb);
 		err = 0;
 	}
@@ -1828,10 +1832,10 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 static void ip_mr_forward(struct net *net, struct mr_table *mrt,
-			  struct sk_buff *skb, struct mfc_cache *cache,
-			  int local)
+			  struct net_device *dev, struct sk_buff *skb,
+			  struct mfc_cache *cache, int local)
 {
-	int true_vifi = ipmr_find_vif(mrt, skb->dev);
+	int true_vifi = ipmr_find_vif(mrt, dev);
 	int psend = -1;
 	int vif, ct;
 
@@ -1853,13 +1857,7 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 	}
 
 	/* Wrong interface: drop packet and (maybe) send PIM assert. */
-	if (mrt->vif_table[vif].dev != skb->dev) {
-		struct net_device *mdev;
-
-		mdev = l3mdev_master_dev_rcu(mrt->vif_table[vif].dev);
-		if (mdev == skb->dev)
-			goto forward;
-
+	if (mrt->vif_table[vif].dev != dev) {
 		if (rt_is_output_route(skb_rtable(skb))) {
 			/* It is our own packet, looped back.
 			 * Very complicated situation...
@@ -2053,7 +2051,7 @@ int ip_mr_input(struct sk_buff *skb)
 		read_lock(&mrt_lock);
 		vif = ipmr_find_vif(mrt, dev);
 		if (vif >= 0) {
-			int err2 = ipmr_cache_unresolved(mrt, vif, skb);
+			int err2 = ipmr_cache_unresolved(mrt, vif, skb, dev);
 			read_unlock(&mrt_lock);
 
 			return err2;
@@ -2064,7 +2062,7 @@ int ip_mr_input(struct sk_buff *skb)
 	}
 
 	read_lock(&mrt_lock);
-	ip_mr_forward(net, mrt, skb, cache, local);
+	ip_mr_forward(net, mrt, dev, skb, cache, local);
 	read_unlock(&mrt_lock);
 
 	if (local)
@@ -2238,7 +2236,7 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 		iph->saddr = saddr;
 		iph->daddr = daddr;
 		iph->version = 0;
-		err = ipmr_cache_unresolved(mrt, vif, skb2);
+		err = ipmr_cache_unresolved(mrt, vif, skb2, dev);
 		read_unlock(&mrt_lock);
 		rcu_read_unlock();
 		return err;
-- 
2.9.4
