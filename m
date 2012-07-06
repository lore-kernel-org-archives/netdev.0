From: David Miller <davem@davemloft.net>
Subject: Re: net-next warning at kernel/softirq.c:159 local_bh_enable
Date: Thu, 05 Jul 2012 21:08:32 -0700 (PDT)
Message-ID: <20120705.210832.1951884287116053841.davem@davemloft.net>
References: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763Ab2GFEIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 00:08:35 -0400
In-Reply-To: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Fri, 6 Jul 2012 06:20:58 +0300

> Shlomo saw too the ipv6 dst crash that was reported over
> the list and also this warning when he rebased to net-next yesterday

Here is what I commited to fix this:

====================
[PATCH] ipoib: Need to do dst_neigh_lookup_skb() outside of priv->lock.

Otherwise local_bh_enable() complains.

Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index fbb95ee..7cecb16 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -658,9 +658,15 @@ static int ipoib_mcast_leave(struct net_device *dev, struct ipoib_mcast *mcast)
 void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct dst_entry *dst = skb_dst(skb);
 	struct ipoib_mcast *mcast;
+	struct neighbour *n;
 	unsigned long flags;
 
+	n = NULL;
+	if (dst)
+		n = dst_neigh_lookup_skb(dst, skb);
+
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (!test_bit(IPOIB_FLAG_OPER_UP, &priv->flags)		||
@@ -715,12 +721,6 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 
 out:
 	if (mcast && mcast->ah) {
-		struct dst_entry *dst = skb_dst(skb);
-		struct neighbour *n = NULL;
-
-		rcu_read_lock();
-		if (dst)
-			n = dst_neigh_lookup_skb(dst, skb);
 		if (n) {
 			if (!*to_ipoib_neigh(n)) {
 				struct ipoib_neigh *neigh;
@@ -735,13 +735,14 @@ out:
 			}
 			neigh_release(n);
 		}
-		rcu_read_unlock();
 		spin_unlock_irqrestore(&priv->lock, flags);
 		ipoib_send(dev, skb, mcast->ah, IB_MULTICAST_QPN);
 		return;
 	}
 
 unlock:
+	if (n)
+		neigh_release(n);
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
-- 
1.7.10.4
