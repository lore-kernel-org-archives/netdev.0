From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/7] neigh: Add device constructor/destructor capability.
Date: Wed, 30 Nov 2011 22:41:51 -0500 (EST)
Message-ID: <20111130.224151.1479303742039627135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab1LADlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:53 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13fplU027357
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:52 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If the neigh entry has device private state, it will need
constructor/destructor ops.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    2 ++
 net/core/neighbour.c      |   15 ++++++++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5462c2c..1c4ddb3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -974,6 +974,8 @@ struct net_device_ops {
 						    netdev_features_t features);
 	int			(*ndo_set_features)(struct net_device *dev,
 						    netdev_features_t features);
+	int			(*ndo_neigh_construct)(struct neighbour *n);
+	int			(*ndo_neigh_destroy)(struct neighbour *n);
 };
 
 /*
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ef750ff..cdf8dc3 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -489,6 +489,14 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 		goto out_neigh_release;
 	}
 
+	if (dev->netdev_ops->ndo_neigh_construct) {
+		error = dev->netdev_ops->ndo_neigh_construct(n);
+		if (error < 0) {
+			rc = ERR_PTR(error);
+			goto out_neigh_release;
+		}
+	}
+
 	/* Device specific setup. */
 	if (n->parms->neigh_setup &&
 	    (error = n->parms->neigh_setup(n)) < 0) {
@@ -692,6 +700,8 @@ static inline void neigh_parms_put(struct neigh_parms *parms)
  */
 void neigh_destroy(struct neighbour *neigh)
 {
+	struct net_device *dev = neigh->dev;
+
 	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
 
 	if (!neigh->dead) {
@@ -707,7 +717,10 @@ void neigh_destroy(struct neighbour *neigh)
 	skb_queue_purge(&neigh->arp_queue);
 	neigh->arp_queue_len_bytes = 0;
 
-	dev_put(neigh->dev);
+	if (dev->netdev_ops->ndo_neigh_destroy)
+		dev->netdev_ops->ndo_neigh_destroy(neigh);
+
+	dev_put(dev);
 	neigh_parms_put(neigh->parms);
 
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
-- 
1.7.6.4
