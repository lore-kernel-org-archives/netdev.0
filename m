From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/7] netpoll: Fix RCU usage
Date: Thu, 10 Jun 2010 22:42:03 +1000
Message-ID: <E1OMh59-0004NM-5D@gondolin.me.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52021 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758807Ab0FJMmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 08:42:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll: Fix RCU usage

The use of RCU in netpoll is incorrect in a number of places:

1) The initial setting is lacking a write barrier.
2) The synchronize_rcu is in the wrong place.
3) Read barriers are missing.
4) Some places are even missing rcu_read_lock.
5) npinfo is zeroed after freeing.

This patch fixes those issues.  As most users are in BH context,
this also converts the RCU usage to the BH variant.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netpoll.h |   13 ++++++++-----
 net/core/netpoll.c      |   20 ++++++++++++--------
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index e9e2312..95c9f7e 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -57,12 +57,15 @@ void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
 #ifdef CONFIG_NETPOLL
 static inline bool netpoll_rx(struct sk_buff *skb)
 {
-	struct netpoll_info *npinfo = skb->dev->npinfo;
+	struct netpoll_info *npinfo;
 	unsigned long flags;
 	bool ret = false;
 
+	rcu_read_lock_bh();
+	npinfo = rcu_dereference(skb->dev->npinfo);
+
 	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
-		return false;
+		goto out;
 
 	spin_lock_irqsave(&npinfo->rx_lock, flags);
 	/* check rx_flags again with the lock held */
@@ -70,12 +73,14 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 		ret = true;
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 
+out:
+	rcu_read_unlock_bh();
 	return ret;
 }
 
 static inline int netpoll_rx_on(struct sk_buff *skb)
 {
-	struct netpoll_info *npinfo = skb->dev->npinfo;
+	struct netpoll_info *npinfo = rcu_dereference(skb->dev->npinfo);
 
 	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
 }
@@ -91,7 +96,6 @@ static inline void *netpoll_poll_lock(struct napi_struct *napi)
 {
 	struct net_device *dev = napi->dev;
 
-	rcu_read_lock(); /* deal with race on ->npinfo */
 	if (dev && dev->npinfo) {
 		spin_lock(&napi->poll_lock);
 		napi->poll_owner = smp_processor_id();
@@ -108,7 +112,6 @@ static inline void netpoll_poll_unlock(void *have)
 		napi->poll_owner = -1;
 		spin_unlock(&napi->poll_lock);
 	}
-	rcu_read_unlock();
 }
 
 #else
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 748c930..4b7623d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -292,6 +292,7 @@ void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 	unsigned long tries;
 	struct net_device *dev = np->dev;
 	const struct net_device_ops *ops = dev->netdev_ops;
+	/* It is up to the caller to keep npinfo alive. */
 	struct netpoll_info *npinfo = np->dev->npinfo;
 
 	if (!npinfo || !netif_running(dev) || !netif_device_present(dev)) {
@@ -841,10 +842,7 @@ int netpoll_setup(struct netpoll *np)
 	refill_skbs();
 
 	/* last thing to do is link it to the net device structure */
-	ndev->npinfo = npinfo;
-
-	/* avoid racing with NAPI reading npinfo */
-	synchronize_rcu();
+	rcu_assign_pointer(ndev->npinfo, npinfo);
 
 	return 0;
 
@@ -888,6 +886,16 @@ void netpoll_cleanup(struct netpoll *np)
 
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
 				const struct net_device_ops *ops;
+
+				ops = np->dev->netdev_ops;
+				if (ops->ndo_netpoll_cleanup)
+					ops->ndo_netpoll_cleanup(np->dev);
+
+				rcu_assign_pointer(np->dev->npinfo, NULL);
+
+				/* avoid racing with NAPI reading npinfo */
+				synchronize_rcu_bh();
+
 				skb_queue_purge(&npinfo->arp_tx);
 				skb_queue_purge(&npinfo->txq);
 				cancel_rearming_delayed_work(&npinfo->tx_work);
@@ -895,10 +903,6 @@ void netpoll_cleanup(struct netpoll *np)
 				/* clean after last, unfinished work */
 				__skb_queue_purge(&npinfo->txq);
 				kfree(npinfo);
-				ops = np->dev->netdev_ops;
-				if (ops->ndo_netpoll_cleanup)
-					ops->ndo_netpoll_cleanup(np->dev);
-				np->dev->npinfo = NULL;
 			}
 		}
 
