From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: dst_ifdown breaks infiniband?
Date: Tue, 20 Mar 2007 02:20:43 +0300
Message-ID: <20070319232043.GA23359@ms2.inr.ac.ru>
References: <20070318155532.GG7958@mellanox.co.il> <20070318191238.GA20518@ms2.inr.ac.ru> <20070318195355.GB11078@mellanox.co.il> <20070318201826.GB27004@ms2.inr.ac.ru> <20070319093632.GB8386@mellanox.co.il> <20070319120534.GA28187@ms2.inr.ac.ru> <20070319121248.GD18497@mellanox.co.il> <20070319125919.GA4239@ms2.inr.ac.ru> <20070319151336.GA24225@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	Roland Dreier <rolandd@cisco.com>,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:49995 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1030725AbXCSXU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 19:20:56 -0400
Content-Disposition: inline
In-Reply-To: <20070319151336.GA24225@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> This might work. Could you post a patch to better show what you mean to do?

Here it is.

->neigh_destructor() is killed (not used), replaced with ->neigh_cleanup(),
which is called when neighbor entry goes to dead state. At this point
everything is still valid: neigh->dev, neigh->parms etc.

The device should guarantee that dead neighbor entries (neigh->dead != 0)
do not get private part initialized, otherwise nobody will cleanup it.

I think this is enough for ipoib which is the only user of this thing.
Initialization private part of neighbor entries happens in ipib
start_xmit routine, which is not reached when device is down.
But it would be better to add explicit test for neigh->dead
in any case.


diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index f9dbc6f..2b5c297 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -814,7 +814,7 @@ static void ipoib_set_mcast_list(struct 
 	queue_work(ipoib_workqueue, &priv->restart_task);
 }
 
-static void ipoib_neigh_destructor(struct neighbour *n)
+static void ipoib_neigh_cleanup(struct neighbour *n)
 {
 	struct ipoib_neigh *neigh;
 	struct ipoib_dev_priv *priv = netdev_priv(n->dev);
@@ -822,7 +822,7 @@ static void ipoib_neigh_destructor(struc
 	struct ipoib_ah *ah = NULL;
 
 	ipoib_dbg(priv,
-		  "neigh_destructor for %06x " IPOIB_GID_FMT "\n",
+		  "neigh_cleanup for %06x " IPOIB_GID_FMT "\n",
 		  IPOIB_QPN(n->ha),
 		  IPOIB_GID_RAW_ARG(n->ha + 4));
 
@@ -874,7 +874,7 @@ void ipoib_neigh_free(struct net_device 
 
 static int ipoib_neigh_setup_dev(struct net_device *dev, struct neigh_parms *parms)
 {
-	parms->neigh_destructor = ipoib_neigh_destructor;
+	parms->neigh_cleanup = ipoib_neigh_cleanup;
 
 	return 0;
 }
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 3725b93..ad7fe11 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -36,7 +36,7 @@ struct neigh_parms
 	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
-	void	(*neigh_destructor)(struct neighbour *);
+	void	(*neigh_cleanup)(struct neighbour *);
 	struct neigh_table *tbl;
 
 	void	*sysctl_table;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index ebb5d0c..8c38258 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -261,14 +261,6 @@ static void clip_pop(struct atm_vcc *vcc
 	spin_unlock_irqrestore(&PRIV(dev)->xoff_lock, flags);
 }
 
-static void clip_neigh_destroy(struct neighbour *neigh)
-{
-	DPRINTK("clip_neigh_destroy (neigh %p)\n", neigh);
-	if (NEIGH2ENTRY(neigh)->vccs)
-		printk(KERN_CRIT "clip_neigh_destroy: vccs != NULL !!!\n");
-	NEIGH2ENTRY(neigh)->vccs = (void *) NEIGHBOR_DEAD;
-}
-
 static void clip_neigh_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
 	DPRINTK("clip_neigh_solicit (neigh %p, skb %p)\n", neigh, skb);
@@ -342,7 +334,6 @@ static struct neigh_table clip_tbl = {
 	/* parameters are copied from ARP ... */
 	.parms = {
 		.tbl 			= &clip_tbl,
-		.neigh_destructor	= clip_neigh_destroy,
 		.base_reachable_time 	= 30 * HZ,
 		.retrans_time 		= 1 * HZ,
 		.gc_staletime 		= 60 * HZ,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3183142..cfc6001 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -140,6 +140,8 @@ static int neigh_forced_gc(struct neigh_
 				n->dead = 1;
 				shrunk	= 1;
 				write_unlock(&n->lock);
+				if (n->parms->neigh_cleanup)
+					n->parms->neigh_cleanup(n);
 				neigh_release(n);
 				continue;
 			}
@@ -211,6 +213,8 @@ static void neigh_flush_dev(struct neigh
 				NEIGH_PRINTK2("neigh %p is stray.\n", n);
 			}
 			write_unlock(&n->lock);
+			if (n->parms->neigh_cleanup)
+				n->parms->neigh_cleanup(n);
 			neigh_release(n);
 		}
 	}
@@ -582,9 +586,6 @@ void neigh_destroy(struct neighbour *nei
 			kfree(hh);
 	}
 
-	if (neigh->parms->neigh_destructor)
-		(neigh->parms->neigh_destructor)(neigh);
-
 	skb_queue_purge(&neigh->arp_queue);
 
 	dev_put(neigh->dev);
@@ -675,6 +676,8 @@ static void neigh_periodic_timer(unsigne
 			*np = n->next;
 			n->dead = 1;
 			write_unlock(&n->lock);
+			if (n->parms->neigh_cleanup)
+				n->parms->neigh_cleanup(n);
 			neigh_release(n);
 			continue;
 		}
@@ -2088,8 +2091,11 @@ void __neigh_for_each_release(struct nei
 			} else
 				np = &n->next;
 			write_unlock(&n->lock);
-			if (release)
+			if (release) {
+				if (n->parms->neigh_cleanup)
+					n->parms->neigh_cleanup(n);
 				neigh_release(n);
+			}
 		}
 	}
 }
