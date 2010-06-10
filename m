From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/7] netpoll: Allow netpoll_setup/cleanup recursion
Date: Thu, 10 Jun 2010 22:42:06 +1000
Message-ID: <E1OMh5C-0004Nt-H2@gondolin.me.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52034 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759014Ab0FJMmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 08:42:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll: Allow netpoll_setup/cleanup recursion

This patch adds the functions __netpoll_setup/__netpoll_cleanup
which is designed to be called recursively through ndo_netpoll_seutp.

They must be called with RTNL held, and the caller must initialise
np->dev and ensure that it has a valid reference count.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netpoll.h |    2 
 net/core/netpoll.c      |  176 ++++++++++++++++++++++++++----------------------
 2 files changed, 99 insertions(+), 79 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 95c9f7e..f3ad74a 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -46,9 +46,11 @@ void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
+int __netpoll_setup(struct netpoll *np);
 int netpoll_setup(struct netpoll *np);
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
+void __netpoll_cleanup(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
 void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c445896..f728208 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -724,15 +724,78 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	return -1;
 }
 
-int netpoll_setup(struct netpoll *np)
+int __netpoll_setup(struct netpoll *np)
 {
-	struct net_device *ndev = NULL;
-	struct in_device *in_dev;
+	struct net_device *ndev = np->dev;
 	struct netpoll_info *npinfo;
 	const struct net_device_ops *ops;
 	unsigned long flags;
 	int err;
 
+	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
+	    !ndev->netdev_ops->ndo_poll_controller) {
+		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
+		       np->name, np->dev_name);
+		err = -ENOTSUPP;
+		goto out;
+	}
+
+	if (!ndev->npinfo) {
+		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
+		if (!npinfo) {
+			err = -ENOMEM;
+			goto out;
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
+
+		ops = np->dev->netdev_ops;
+		if (ops->ndo_netpoll_setup) {
+			err = ops->ndo_netpoll_setup(ndev, npinfo);
+			if (err)
+				goto free_npinfo;
+		}
+	} else {
+		npinfo = ndev->npinfo;
+		atomic_inc(&npinfo->refcnt);
+	}
+
+	npinfo->netpoll = np;
+
+	if (np->rx_hook) {
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
+		list_add_tail(&np->rx, &npinfo->rx_np);
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+	}
+
+	/* last thing to do is link it to the net device structure */
+	rcu_assign_pointer(ndev->npinfo, npinfo);
+	rtnl_unlock();
+
+	return 0;
+
+free_npinfo:
+	kfree(npinfo);
+out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(__netpoll_setup);
+
+int netpoll_setup(struct netpoll *np)
+{
+	struct net_device *ndev = NULL;
+	struct in_device *in_dev;
+	int err;
+
 	if (np->dev_name)
 		ndev = dev_get_by_name(&init_net, np->dev_name);
 	if (!ndev) {
@@ -805,61 +868,14 @@ int netpoll_setup(struct netpoll *np)
 	refill_skbs();
 
 	rtnl_lock();
-	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
-	    !ndev->netdev_ops->ndo_poll_controller) {
-		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
-		       np->name, np->dev_name);
-		err = -ENOTSUPP;
-		goto unlock;
-	}
-
-	if (!ndev->npinfo) {
-		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
-		if (!npinfo) {
-			err = -ENOMEM;
-			goto unlock;
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
-
-		ops = np->dev->netdev_ops;
-		if (ops->ndo_netpoll_setup) {
-			err = ops->ndo_netpoll_setup(ndev, npinfo);
-			if (err)
-				goto free_npinfo;
-		}
-	} else {
-		npinfo = ndev->npinfo;
-		atomic_inc(&npinfo->refcnt);
-	}
-
-	npinfo->netpoll = np;
-
-	if (np->rx_hook) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
-		list_add_tail(&np->rx, &npinfo->rx_np);
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	}
-
-	/* last thing to do is link it to the net device structure */
-	rcu_assign_pointer(ndev->npinfo, npinfo);
+	err = __netpoll_setup(np);
 	rtnl_unlock();
 
+	if (err)
+		goto put;
+
 	return 0;
 
-free_npinfo:
-	kfree(npinfo);
-unlock:
-	rtnl_unlock();
 put:
 	dev_put(ndev);
 	return err;
@@ -872,40 +888,32 @@ static int __init netpoll_init(void)
 }
 core_initcall(netpoll_init);
 
-void netpoll_cleanup(struct netpoll *np)
+void __netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;
 	unsigned long flags;
-	int free = 0;
 
-	if (!np->dev)
+	npinfo = np->dev->npinfo;
+	if (!npinfo)
 		return;
 
-	rtnl_lock();
-	npinfo = np->dev->npinfo;
-	if (npinfo) {
-		if (!list_empty(&npinfo->rx_np)) {
-			spin_lock_irqsave(&npinfo->rx_lock, flags);
-			list_del(&np->rx);
-			if (list_empty(&npinfo->rx_np))
-				npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
-			spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-		}
+	if (!list_empty(&npinfo->rx_np)) {
+		spin_lock_irqsave(&npinfo->rx_lock, flags);
+		list_del(&np->rx);
+		if (list_empty(&npinfo->rx_np))
+			npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
+		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+	}
 
-		free = atomic_dec_and_test(&npinfo->refcnt);
-		if (free) {
-			const struct net_device_ops *ops;
+	if (atomic_dec_and_test(&npinfo->refcnt)) {
+		const struct net_device_ops *ops;
 
-			ops = np->dev->netdev_ops;
-			if (ops->ndo_netpoll_cleanup)
-				ops->ndo_netpoll_cleanup(np->dev);
+		ops = np->dev->netdev_ops;
+		if (ops->ndo_netpoll_cleanup)
+			ops->ndo_netpoll_cleanup(np->dev);
 
-			rcu_assign_pointer(np->dev->npinfo, NULL);
-		}
-	}
-	rtnl_unlock();
+		rcu_assign_pointer(np->dev->npinfo, NULL);
 
-	if (free) {
 		/* avoid racing with NAPI reading npinfo */
 		synchronize_rcu_bh();
 
@@ -917,9 +925,19 @@ void netpoll_cleanup(struct netpoll *np)
 		__skb_queue_purge(&npinfo->txq);
 		kfree(npinfo);
 	}
+}
+EXPORT_SYMBOL_GPL(__netpoll_cleanup);
 
-	dev_put(np->dev);
+void netpoll_cleanup(struct netpoll *np)
+{
+	if (!np->dev)
+		return;
 
+	rtnl_lock();
+	__netpoll_cleanup(np);
+	rtnl_unlock();
+
+	dev_put(np->dev);
 	np->dev = NULL;
 }
 
