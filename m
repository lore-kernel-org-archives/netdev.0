From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH RESEND] net: Move destructor from
	neigh->ops to neigh_params
Date: Wed, 01 Feb 2006 17:28:10 -0800
Message-ID: <adabqxq1rdh.fsf@cisco.com>
References: <adazmlmmy7v.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: davem@davemloft.net
In-Reply-To: <adazmlmmy7v.fsf@cisco.com> (Roland Dreier's message of "Mon,
	23 Jan 2006 13:27:32 -0800")
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

Sorry to distract everyone from the VJ channel discussion, but on the
other hand it looks like Dave is back... I'm resending this because
I'd really like to get this problem fixed but I want to make sure
we're doing it the right way.  So either an ACK or a NAK with guidance
would be great...


This is a resend of a patch written by Michael S. Tsirkin
<mst@mellanox.co.il>.  I'd like to get an ACK or NAK of it from Dave
and other networking people, so that we can either merge it upstream
or try a different approach.  There definitely is a problem with
neighbour destructors that IP-over-IB is running into.

It would be good to know what the design was behind putting the
destructor method in neigh->ops in the first place.

Dave, if you want to merge this directly, that's fine.  Or I'm fine
with merging this through the IB tree if you'd prefer (if you want me
to do that, let me know if you think it's 2.6.16 material).

Thanks,
  Roland



struct neigh_ops currently has a destructor field, which no in-kernel
drivers outside of infiniband use.  The infiniband/ulp/ipoib in-tree
driver stashes some info in the neighbour structure (the results of
the second-stage lookup from ARP results to real link-level path), and
it uses neigh->ops->destructor to get a callback so it can clean up
this extra info when a neighbour is freed.  We've run into problems
with this: since the destructor is in an ops field that is shared
between neighbours that may belong to different net devices, there's
no way to set/clear it safely.

The following patch moves this field to neigh_parms where it can be
safely set, together with its twin neigh_setup.  Two additional
patches in the patch series update ipoib to use this new interface.

Signed-off-by: Michael S. Tsirkin <mst@mellanox.co.il>
Signed-off-by: Roland Dreier <rolandd@cisco.com>

---

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 6fa9ae1..b0666d6 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
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
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e68700f..3489e23 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -586,8 +586,8 @@ void neigh_destroy(struct neighbour *nei
 			kfree(hh);
 	}
 
-	if (neigh->ops && neigh->ops->destructor)
-		(neigh->ops->destructor)(neigh);
+	if (neigh->parms->neigh_destructor)
+		(neigh->parms->neigh_destructor)(neigh);
 
 	skb_queue_purge(&neigh->arp_queue);
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index fd3f5c8..9588124 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
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
