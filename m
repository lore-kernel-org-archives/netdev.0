From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Repost [PATCH 1 of 3] move destructor to struct
	neigh_parms
Date: Wed, 18 Jan 2006 23:19:26 +0200
Message-ID: <20060118211926.GE31280@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <openib-general-bounces@openib.org>
To: openib-general@openib.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
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

Hi!
struct neigh_ops currently has a destructor field, unused by in-kernel
drivers outside the infiniband subtree.
infiniband ipoib in-tree driver currently uses this field, and we've
run into problems: since the destructor is shared between neighbours
that belong to different net devices, there's no way to set/clear it
safely.

It would be good to know what the design was
behind putting the destructor method there in the first place.

The following patch moves this field to neigh_parms where it can
be safely set, together with its twin neigh_setup.
Two additional patches in the patch series
update ipoib to use this new interface.

Please Cc me on replies, I'm not on the list.

---

Move destructor from neigh_ops (which is shared between devices)
to neigh_parms which is not, so that multiple drivers can set
it safely.

Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>

Index: linux-2.6.15/net/core/neighbour.c
===================================================================
--- linux-2.6.15.orig/net/core/neighbour.c	2006-01-12 11:58:15.000000000 +0200
+++ linux-2.6.15/net/core/neighbour.c	2006-01-12 20:10:00.000000000 +0200
@@ -586,8 +586,8 @@ void neigh_destroy(struct neighbour *nei
 			kfree(hh);
 	}
 
-	if (neigh->ops && neigh->ops->destructor)
-		(neigh->ops->destructor)(neigh);
+	if (neigh->parms->neigh_destructor)
+		(neigh->parms->neigh_destructor)(neigh);
 
 	skb_queue_purge(&neigh->arp_queue);
 
Index: linux-2.6.15/include/net/neighbour.h
===================================================================
--- linux-2.6.15.orig/include/net/neighbour.h	2006-01-03 05:21:10.000000000 +0200
+++ linux-2.6.15/include/net/neighbour.h	2006-01-12 20:09:27.000000000 +0200
@@ -68,6 +68,7 @@ struct neigh_parms
 	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
+	void	(*neigh_destructor)(struct neighbour *);
 	struct neigh_table *tbl;
 
 	void	*sysctl_table;
@@ -145,7 +146,6 @@ struct neighbour
 struct neigh_ops
 {
 	int			family;
-	void			(*destructor)(struct neighbour *);
 	void			(*solicit)(struct neighbour *, struct sk_buff*);
 	void			(*error_report)(struct neighbour *, struct sk_buff*);
 	int			(*output)(struct sk_buff*);

-- 
MST
