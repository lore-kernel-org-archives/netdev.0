From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/19] ipoib: Convert over to dev_lookup_neigh_skb().
Date: Tue, 03 Jul 2012 02:46:21 -0700 (PDT)
Message-ID: <20120703.024621.984205798135187428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932420Ab2GCJqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:22 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C7D0F58411D
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |    4 +++-
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   22 +++++++++++++---------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 3974c29..bbee4b2 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -715,7 +715,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	rcu_read_lock();
 	if (likely(skb_dst(skb))) {
-		n = dst_get_neighbour_noref(skb_dst(skb));
+		n = dst_neigh_lookup_skb(skb_dst(skb), skb);
 		if (!n) {
 			++dev->stats.tx_dropped;
 			dev_kfree_skb_any(skb);
@@ -797,6 +797,8 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 unlock:
+	if (n)
+		neigh_release(n);
 	rcu_read_unlock();
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 20ebc6f..fbb95ee 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -720,16 +720,20 @@ out:
 
 		rcu_read_lock();
 		if (dst)
-			n = dst_get_neighbour_noref(dst);
-		if (n && !*to_ipoib_neigh(n)) {
-			struct ipoib_neigh *neigh = ipoib_neigh_alloc(n,
-								      skb->dev);
-
-			if (neigh) {
-				kref_get(&mcast->ah->ref);
-				neigh->ah	= mcast->ah;
-				list_add_tail(&neigh->list, &mcast->neigh_list);
+			n = dst_neigh_lookup_skb(dst, skb);
+		if (n) {
+			if (!*to_ipoib_neigh(n)) {
+				struct ipoib_neigh *neigh;
+
+				neigh = ipoib_neigh_alloc(n, skb->dev);
+				if (neigh) {
+					kref_get(&mcast->ah->ref);
+					neigh->ah	= mcast->ah;
+					list_add_tail(&neigh->list,
+						      &mcast->neigh_list);
+				}
 			}
+			neigh_release(n);
 		}
 		rcu_read_unlock();
 		spin_unlock_irqrestore(&priv->lock, flags);
-- 
1.7.10
