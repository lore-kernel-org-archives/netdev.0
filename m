From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 23/39]: net: In core generic transmit paths, use queue
 aware tests.
Date: Thu, 03 Jul 2008 00:04:31 -0700 (PDT)
Message-ID: <20080703.000431.36765176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Even pktgen is mostly queue aware now.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |    3 ++-
 include/net/pkt_sched.h   |    4 +---
 net/core/dev.c            |   11 +++++------
 net/core/netpoll.c        |    8 +++-----
 net/core/pktgen.c         |   16 +++++++---------
 net/sched/sch_generic.c   |    5 ++---
 net/sched/sch_teql.c      |    6 ++----
 7 files changed, 22 insertions(+), 31 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 89bab7e..2ab4d92 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1162,7 +1162,8 @@ extern int		dev_set_mtu(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
-					    struct net_device *dev);
+					    struct net_device *dev,
+					    struct netdev_queue *dev_queue);
 
 extern int		netdev_budget;
 
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 1e2263c..89b106e 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -84,9 +84,7 @@ extern void __qdisc_run(struct netdev_queue *dev_queue);
 
 static inline void qdisc_run(struct netdev_queue *dev_queue)
 {
-	struct net_device *dev = dev_queue->dev;
-
-	if (!netif_queue_stopped(dev) &&
+	if (!netif_tx_queue_stopped(dev_queue) &&
 	    !test_and_set_bit(__QUEUE_STATE_QDISC_RUNNING, &dev_queue->state))
 		__qdisc_run(dev_queue);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 039ceff..5209a3f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1598,7 +1598,8 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
 
-int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			struct netdev_queue *dev_queue)
 {
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
@@ -1627,8 +1628,7 @@ gso:
 			skb->next = nskb;
 			return rc;
 		}
-		if (unlikely((netif_queue_stopped(dev) ||
-			     netif_subqueue_stopped(dev, skb)) &&
+		if (unlikely(netif_tx_queue_stopped(dev_queue) &&
 			     skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
@@ -1762,10 +1762,9 @@ gso:
 
 			HARD_TX_LOCK(dev, txq, cpu);
 
-			if (!netif_queue_stopped(dev) &&
-			    !netif_subqueue_stopped(dev, skb)) {
+			if (!netif_tx_queue_stopped(txq)) {
 				rc = 0;
-				if (!dev_hard_start_xmit(skb, dev)) {
+				if (!dev_hard_start_xmit(skb, dev, txq)) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
 				}
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 8fb134d..2271d19 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -66,9 +66,8 @@ static void queue_process(struct work_struct *work)
 
 		local_irq_save(flags);
 		netif_tx_lock(dev);
-		if ((netif_queue_stopped(dev) ||
-		     netif_subqueue_stopped(dev, skb)) ||
-		     dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
+		if (netif_subqueue_stopped(dev, skb) ||
+		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			netif_tx_unlock(dev);
 			local_irq_restore(flags);
@@ -285,8 +284,7 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
 			if (netif_tx_trylock(dev)) {
-				if (!netif_queue_stopped(dev) &&
-				    !netif_subqueue_stopped(dev, skb))
+				if (!netif_subqueue_stopped(dev, skb))
 					status = dev->hard_start_xmit(skb, dev);
 				netif_tx_unlock(dev);
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fdf5377..f6dc5b3 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3262,6 +3262,7 @@ static void pktgen_rem_thread(struct pktgen_thread *t)
 
 static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
+	struct netdev_queue *odev_queue;
 	struct net_device *odev = NULL;
 	__u64 idle_start = 0;
 	int ret;
@@ -3285,9 +3286,8 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		}
 	}
 
-	if ((netif_queue_stopped(odev) ||
-	     (pkt_dev->skb &&
-	      netif_subqueue_stopped(odev, pkt_dev->skb))) ||
+	odev_queue = &odev->tx_queue;
+	if (netif_tx_queue_stopped(odev_queue) ||
 	    need_resched()) {
 		idle_start = getCurUs();
 
@@ -3303,8 +3303,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		pkt_dev->idle_acc += getCurUs() - idle_start;
 
-		if (netif_queue_stopped(odev) ||
-		    netif_subqueue_stopped(odev, pkt_dev->skb)) {
+		if (netif_tx_queue_stopped(odev_queue)) {
 			pkt_dev->next_tx_us = getCurUs();	/* TODO */
 			pkt_dev->next_tx_ns = 0;
 			goto out;	/* Try the next interface */
@@ -3331,9 +3330,8 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		}
 	}
 
-	netif_tx_lock_bh(odev);
-	if (!netif_queue_stopped(odev) &&
-	    !netif_subqueue_stopped(odev, pkt_dev->skb)) {
+	__netif_tx_lock_bh(odev_queue);
+	if (!netif_tx_queue_stopped(odev_queue)) {
 
 		atomic_inc(&(pkt_dev->skb->users));
 	      retry_now:
@@ -3377,7 +3375,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->next_tx_ns = 0;
 	}
 
-	netif_tx_unlock_bh(odev);
+	__netif_tx_unlock_bh(odev_queue);
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b919c0b..1092d54 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -156,7 +156,7 @@ static inline int qdisc_restart(struct netdev_queue *dev_queue)
 
 	HARD_TX_LOCK(dev, dev_queue, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
-		ret = dev_hard_start_xmit(skb, dev);
+		ret = dev_hard_start_xmit(skb, dev, dev_queue);
 	HARD_TX_UNLOCK(dev, dev_queue);
 
 	spin_lock(&dev_queue->lock);
@@ -188,11 +188,10 @@ static inline int qdisc_restart(struct netdev_queue *dev_queue)
 
 void __qdisc_run(struct netdev_queue *dev_queue)
 {
-	struct net_device *dev = dev_queue->dev;
 	unsigned long start_time = jiffies;
 
 	while (qdisc_restart(dev_queue)) {
-		if (netif_queue_stopped(dev))
+		if (netif_tx_queue_stopped(dev_queue))
 			break;
 
 		/*
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 8ac0598..16d975f 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -288,8 +288,7 @@ restart:
 
 		if (slave->tx_queue.qdisc_sleeping != q)
 			continue;
-		if (netif_queue_stopped(slave) ||
-		    __netif_subqueue_stopped(slave, subq) ||
+		if (__netif_subqueue_stopped(slave, subq) ||
 		    !netif_running(slave)) {
 			busy = 1;
 			continue;
@@ -298,8 +297,7 @@ restart:
 		switch (teql_resolve(skb, skb_res, slave)) {
 		case 0:
 			if (netif_tx_trylock(slave)) {
-				if (!netif_queue_stopped(slave) &&
-				    !__netif_subqueue_stopped(slave, subq) &&
+				if (!__netif_subqueue_stopped(slave, subq) &&
 				    slave->hard_start_xmit(skb, slave) == 0) {
 					netif_tx_unlock(slave);
 					master->slaves = NEXT_SLAVE(q);
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
