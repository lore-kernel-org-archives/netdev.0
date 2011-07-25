From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 6/7] neigh: Add device constructor/destructor capability.
Date: Mon, 25 Jul 2011 03:01:38 -0700 (PDT)
Message-ID: <20110725.030138.969068104211274321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


If the neigh entry has device private state, it will need
constructor/destructor ops.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |    2 ++
 net/core/neighbour.c      |   15 ++++++++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a50f6d6..016bb4e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -943,6 +943,8 @@ struct net_device_ops {
 						    u32 features);
 	int			(*ndo_set_features)(struct net_device *dev,
 						    u32 features);
+	int			(*ndo_neigh_construct)(struct neighbour *n);
+	int			(*ndo_neigh_destroy)(struct neighbour *n);
 };
 
 /*
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 96ae4e4..ee5ce7e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -488,6 +488,14 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
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
@@ -691,6 +699,8 @@ static inline void neigh_parms_put(struct neigh_parms *parms)
  */
 void neigh_destroy(struct neighbour *neigh)
 {
+	struct net_device *dev = neigh->dev;
+
 	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
 
 	if (!neigh->dead) {
@@ -705,7 +715,10 @@ void neigh_destroy(struct neighbour *neigh)
 
 	skb_queue_purge(&neigh->arp_queue);
 
-	dev_put(neigh->dev);
+	if (dev->netdev_ops->ndo_neigh_destroy)
+		dev->netdev_ops->ndo_neigh_destroy(neigh);
+
+	dev_put(dev);
 	neigh_parms_put(neigh->parms);
 
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
-- 
1.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
