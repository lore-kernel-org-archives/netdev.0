From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/8] netpoll: Add locking for netpoll_setup/cleanup
Date: Fri, 11 Jun 2010 12:12:46 +1000
Message-ID: <E1OMtji-0006Ok-09@gondolin.me.apana.org.au>
References: <20100611021142.GA24490@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38014 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755130Ab0FKCMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 22:12:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll: Add locking for netpoll_setup/cleanup

As it stands, netpoll_setup and netpoll_cleanup have no locking
protection whatsoever.  So chaos ensures if two entities try to
perform them on the same device.

This patch adds RTNL to the equation.  The code has be rearranged
so that bits that do not need RTNL protection are now moved to
the top of netpoll_setup.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/netpoll.c |  151 ++++++++++++++++++++++++++---------------------------
 1 file changed, 76 insertions(+), 75 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 4b7623d..9dcd767 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -729,7 +729,6 @@ int netpoll_setup(struct netpoll *np)
 	struct net_device *ndev = NULL;
 	struct in_device *in_dev;
 	struct netpoll_info *npinfo;
-	struct netpoll *npe, *tmp;
 	unsigned long flags;
 	int err;
 
@@ -741,38 +740,6 @@ int netpoll_setup(struct netpoll *np)
 		return -ENODEV;
 	}
 
-	np->dev = ndev;
-	if (!ndev->npinfo) {
-		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
-		if (!npinfo) {
-			err = -ENOMEM;
-			goto put;
-		}
-
-		npinfo->rx_flags = 0;
-		INIT_LIST_HEAD(&npinfo->rx_np);
-
-		spin_lock_init(&npinfo->rx_lock);
-		skb_queue_head_init(&npinfo->arp_tx);
-		skb_queue_head_init(&npinfo->txq);
-		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
-
-		atomic_set(&npinfo->refcnt, 1);
-	} else {
-		npinfo = ndev->npinfo;
-		atomic_inc(&npinfo->refcnt);
-	}
-
-	npinfo->netpoll = np;
-
-	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
-	    !ndev->netdev_ops->ndo_poll_controller) {
-		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
-		       np->name, np->dev_name);
-		err = -ENOTSUPP;
-		goto release;
-	}
-
 	if (!netif_running(ndev)) {
 		unsigned long atmost, atleast;
 
@@ -786,7 +753,7 @@ int netpoll_setup(struct netpoll *np)
 		if (err) {
 			printk(KERN_ERR "%s: failed to open %s\n",
 			       np->name, ndev->name);
-			goto release;
+			goto put;
 		}
 
 		atleast = jiffies + HZ/10;
@@ -823,7 +790,7 @@ int netpoll_setup(struct netpoll *np)
 			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
 			       np->name, np->dev_name);
 			err = -EDESTADDRREQ;
-			goto release;
+			goto put;
 		}
 
 		np->local_ip = in_dev->ifa_list->ifa_local;
@@ -831,6 +798,43 @@ int netpoll_setup(struct netpoll *np)
 		printk(KERN_INFO "%s: local IP %pI4\n", np->name, &np->local_ip);
 	}
 
+	np->dev = ndev;
+
+	/* fill up the skb queue */
+	refill_skbs();
+
+	rtnl_lock();
+	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
+	    !ndev->netdev_ops->ndo_poll_controller) {
+		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
+		       np->name, np->dev_name);
+		err = -ENOTSUPP;
+		goto unlock;
+	}
+
+	if (!ndev->npinfo) {
+		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
+		if (!npinfo) {
+			err = -ENOMEM;
+			goto unlock;
+		}
+
+		npinfo->rx_flags = 0;
+		INIT_LIST_HEAD(&npinfo->rx_np);
+
+		spin_lock_init(&npinfo->rx_lock);
+		skb_queue_head_init(&npinfo->arp_tx);
+		skb_queue_head_init(&npinfo->txq);
+		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
+
+		atomic_set(&npinfo->refcnt, 1);
+	} else {
+		npinfo = ndev->npinfo;
+		atomic_inc(&npinfo->refcnt);
+	}
+
+	npinfo->netpoll = np;
+
 	if (np->rx_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
@@ -838,24 +842,14 @@ int netpoll_setup(struct netpoll *np)
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
 
-	/* fill up the skb queue */
-	refill_skbs();
-
 	/* last thing to do is link it to the net device structure */
 	rcu_assign_pointer(ndev->npinfo, npinfo);
+	rtnl_unlock();
 
 	return 0;
 
- release:
-	if (!ndev->npinfo) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		list_for_each_entry_safe(npe, tmp, &npinfo->rx_np, rx) {
-			npe->dev = NULL;
-		}
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-
-		kfree(npinfo);
-	}
+unlock:
+	rtnl_unlock();
 put:
 	dev_put(ndev);
 	return err;
@@ -872,43 +866,50 @@ void netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;
 	unsigned long flags;
+	int free = 0;
 
-	if (np->dev) {
-		npinfo = np->dev->npinfo;
-		if (npinfo) {
-			if (!list_empty(&npinfo->rx_np)) {
-				spin_lock_irqsave(&npinfo->rx_lock, flags);
-				list_del(&np->rx);
-				if (list_empty(&npinfo->rx_np))
-					npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
-				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-			}
+	if (!np->dev)
+		return;
 
-			if (atomic_dec_and_test(&npinfo->refcnt)) {
-				const struct net_device_ops *ops;
+	rtnl_lock();
+	npinfo = np->dev->npinfo;
+	if (npinfo) {
+		if (!list_empty(&npinfo->rx_np)) {
+			spin_lock_irqsave(&npinfo->rx_lock, flags);
+			list_del(&np->rx);
+			if (list_empty(&npinfo->rx_np))
+				npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
+			spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+		}
 
-				ops = np->dev->netdev_ops;
-				if (ops->ndo_netpoll_cleanup)
-					ops->ndo_netpoll_cleanup(np->dev);
+		free = atomic_dec_and_test(&npinfo->refcnt);
+		if (free) {
+			const struct net_device_ops *ops;
 
-				rcu_assign_pointer(np->dev->npinfo, NULL);
+			ops = np->dev->netdev_ops;
+			if (ops->ndo_netpoll_cleanup)
+				ops->ndo_netpoll_cleanup(np->dev);
 
-				/* avoid racing with NAPI reading npinfo */
-				synchronize_rcu_bh();
+			rcu_assign_pointer(np->dev->npinfo, NULL);
+		}
+	}
+	rtnl_unlock();
 
-				skb_queue_purge(&npinfo->arp_tx);
-				skb_queue_purge(&npinfo->txq);
-				cancel_rearming_delayed_work(&npinfo->tx_work);
+	if (free) {
+		/* avoid racing with NAPI reading npinfo */
+		synchronize_rcu_bh();
 
-				/* clean after last, unfinished work */
-				__skb_queue_purge(&npinfo->txq);
-				kfree(npinfo);
-			}
-		}
+		skb_queue_purge(&npinfo->arp_tx);
+		skb_queue_purge(&npinfo->txq);
+		cancel_rearming_delayed_work(&npinfo->tx_work);
 
-		dev_put(np->dev);
+		/* clean after last, unfinished work */
+		__skb_queue_purge(&npinfo->txq);
+		kfree(npinfo);
 	}
 
+	dev_put(np->dev);
+
 	np->dev = NULL;
 }
 
