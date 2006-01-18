From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Repost [PATCH 2 of 3] ipoib: move destructor to
	struct neigh_parms
Date: Wed, 18 Jan 2006 23:19:53 +0200
Message-ID: <20060118211953.GF31280@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Content-Disposition: inline
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Sorry about reposting: the message didnt seem to make it to netdev.

---

Move destructor from neigh_ops (which is shared between devices)
to neigh_parms which is not, so that multiple drivers can set
it safely.

Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>

Index: linux-2.6.15/drivers/infiniband/ulp/ipoib/ipoib_main.c
===================================================================
--- linux-2.6.15.orig/drivers/infiniband/ulp/ipoib/ipoib_main.c	2006-01-12 20:30:52.000000000 +0200
+++ linux-2.6.15/drivers/infiniband/ulp/ipoib/ipoib_main.c	2006-01-12 20:31:26.000000000 +0200
@@ -247,7 +247,6 @@ static void path_free(struct net_device 
 		if (neigh->ah)
 			ipoib_put_ah(neigh->ah);
 		*to_ipoib_neigh(neigh->neighbour) = NULL;
-		neigh->neighbour->ops->destructor = NULL;
 		kfree(neigh);
 	}
 
@@ -530,7 +529,6 @@ static void neigh_add_path(struct sk_buf
 err:
 	*to_ipoib_neigh(skb->dst->neighbour) = NULL;
 	list_del(&neigh->list);
-	neigh->neighbour->ops->destructor = NULL;
 	kfree(neigh);
 
 	++priv->stats.tx_dropped;
@@ -769,21 +767,9 @@ static void ipoib_neigh_destructor(struc
 		ipoib_put_ah(ah);
 }
 
-static int ipoib_neigh_setup(struct neighbour *neigh)
-{
-	/*
-	 * Is this kosher?  I can't find anybody in the kernel that
-	 * sets neigh->destructor, so we should be able to set it here
-	 * without trouble.
-	 */
-	neigh->ops->destructor = ipoib_neigh_destructor;
-
-	return 0;
-}
-
 static int ipoib_neigh_setup_dev(struct net_device *dev, struct neigh_parms *parms)
 {
-	parms->neigh_setup = ipoib_neigh_setup;
+	parms->neigh_destructor = ipoib_neigh_destructor;
 
 	return 0;
 }


-- 
MST
