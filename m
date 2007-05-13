From: jamal <hadi@cyberus.ca>
Subject: [LAST CALL] [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Sun, 13 May 2007 10:28:38 -0400
Message-ID: <1179066518.15622.60.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>
	 <4645F325.3060607@trash.net>  <1178999773.15622.44.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-85kO44j9oT7ZumcmHVW4"
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:28754 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754239AbXEMO2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2007 10:28:48 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1335137wxd
        for <netdev@vger.kernel.org>; Sun, 13 May 2007 07:28:44 -0700 (PDT)
In-Reply-To: <1178999773.15622.44.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-85kO44j9oT7ZumcmHVW4
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Ok, I am upgrading this to last call after taking in Patricks feedback.
Speak now - or send patches against it later. 
Dave, just let it simmer down for a day or two, then if no complaints,
go ahead and apply it. It is against net-2.6
Many thanks to Thomas, Peter and Patrick for their reviews.

cheers,
jamal


--=-85kO44j9oT7ZumcmHVW4
Content-Disposition: attachment; filename=lastcall-qrs
Content-Type: text/plain; name=lastcall-qrs; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_SCHED]: Cleanup readability of qdisc restart

Over the years this code has gotten hairier. Resulting in many long
discussions and patches that get it wrong.
This patch helps tame that code so normal people will understand it.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit d5088c3eb28211ac8c4137d6e2e69edf6061a57d
tree 7c683e412072a992ba49bccc34f3e1ab3c42efa3
parent 15cfc8c4efe964593b0246df53e3aa30502d9550
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 13 May 2007 10:19:52 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 13 May 2007 10:19:52 -0400

 net/sched/sch_generic.c |  205 +++++++++++++++++++++++++----------------------
 1 files changed, 111 insertions(+), 94 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f28bb2d..0a000a9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -34,6 +34,9 @@
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
+#define SCHED_TX_DROP -2
+#define SCHED_TX_QUEUE -3
+
 /* Main transmission queue. */
 
 /* Modifications to data participating in scheduling must be protected with
@@ -59,7 +62,74 @@ void qdisc_unlock_tree(struct net_device *dev)
 	spin_unlock_bh(&dev->queue_lock);
 }
 
+static inline int qdisc_qlen(struct Qdisc *q)
+{
+	BUG_ON((int) q->q.qlen < 0);
+	return q->q.qlen;
+}
+
+static inline int handle_dev_cpu_collision(struct net_device *dev)
+{
+	if (unlikely(dev->xmit_lock_owner == smp_processor_id())) {
+		if (net_ratelimit())
+			printk(KERN_DEBUG
+			       "Dead loop on netdevice %s, fix it urgently!\n",
+			       dev->name);
+		return SCHED_TX_DROP;
+	}
+	__get_cpu_var(netdev_rx_stat).cpu_collision++;
+	return SCHED_TX_QUEUE;
+}
+
+static inline int
+do_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
+{
+
+	if (unlikely(skb->next))
+		dev->gso_skb = skb;
+	else
+		q->ops->requeue(skb, q);
+	/* XXX: Could netif_schedule fail? Or is that fact we are
+	 * requeueing imply the hardware path is closed
+	 * and even if we fail, some interupt will wake us
+	*/
+	netif_schedule(dev);
+	return 0;
+}
+
+static inline struct sk_buff *
+try_get_tx_pkt(struct net_device *dev, struct Qdisc *q)
+{
+	struct sk_buff *skb = dev->gso_skb;
+
+	if (skb)
+		dev->gso_skb = NULL;
+	else
+		skb = q->dequeue(q);
+
+	return skb;
+}
+
+static inline int
+tx_islocked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
+{
+	int ret = handle_dev_cpu_collision(dev);
+
+	if (ret == SCHED_TX_DROP) {
+		kfree_skb(skb);
+		return qdisc_qlen(q);
+	}
+
+	return do_dev_requeue(skb, dev, q);
+}
+
+
 /*
+   NOTE: Called under dev->queue_lock with locally disabled BH.
+
+   __LINK_STATE_QDISC_RUNNING guarantees only one CPU
+   can enter this region at a time.
+
    dev->queue_lock serializes queue accesses for this device
    AND dev->qdisc pointer itself.
 
@@ -67,114 +137,61 @@ void qdisc_unlock_tree(struct net_device *dev)
 
    dev->queue_lock and netif_tx_lock are mutually exclusive,
    if one is grabbed, another must be free.
- */
 
+   Multiple CPUs may contend for the two locks.
 
-/* Kick device.
+   Note, that this procedure can be called by a watchdog timer
 
+   Returns to the caller:
    Returns:  0  - queue is empty or throttled.
 	    >0  - queue is not empty.
-
-   NOTE: Called under dev->queue_lock with locally disabled BH.
 */
 
 static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
+	unsigned lockless = (dev->features & NETIF_F_LLTX);
 	struct sk_buff *skb;
+	int ret;
 
-	/* Dequeue packet */
-	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {
-		unsigned nolock = (dev->features & NETIF_F_LLTX);
-
-		dev->gso_skb = NULL;
+	skb = try_get_tx_pkt(dev, q);
+	if (skb == NULL)
+		return qdisc_qlen(q);
 
-		/*
-		 * When the driver has LLTX set it does its own locking
-		 * in start_xmit. No need to add additional overhead by
-		 * locking again. These checks are worth it because
-		 * even uncongested locks can be quite expensive.
-		 * The driver can do trylock like here too, in case
-		 * of lock congestion it should return -1 and the packet
-		 * will be requeued.
-		 */
-		if (!nolock) {
-			if (!netif_tx_trylock(dev)) {
-			collision:
-				/* So, someone grabbed the driver. */
-
-				/* It may be transient configuration error,
-				   when hard_start_xmit() recurses. We detect
-				   it by checking xmit owner and drop the
-				   packet when deadloop is detected.
-				*/
-				if (dev->xmit_lock_owner == smp_processor_id()) {
-					kfree_skb(skb);
-					if (net_ratelimit())
-						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
-					goto out;
-				}
-				__get_cpu_var(netdev_rx_stat).cpu_collision++;
-				goto requeue;
-			}
-		}
-
-		{
-			/* And release queue */
-			spin_unlock(&dev->queue_lock);
-
-			if (!netif_queue_stopped(dev)) {
-				int ret;
-
-				ret = dev_hard_start_xmit(skb, dev);
-				if (ret == NETDEV_TX_OK) {
-					if (!nolock) {
-						netif_tx_unlock(dev);
-					}
-					spin_lock(&dev->queue_lock);
-					q = dev->qdisc;
-					goto out;
-				}
-				if (ret == NETDEV_TX_LOCKED && nolock) {
-					spin_lock(&dev->queue_lock);
-					q = dev->qdisc;
-					goto collision;
-				}
-			}
-
-			/* NETDEV_TX_BUSY - we need to requeue */
-			/* Release the driver */
-			if (!nolock) {
-				netif_tx_unlock(dev);
-			}
-			spin_lock(&dev->queue_lock);
-			q = dev->qdisc;
-		}
-
-		/* Device kicked us out :(
-		   This is possible in three cases:
-
-		   0. driver is locked
-		   1. fastroute is enabled
-		   2. device cannot determine busy state
-		      before start of transmission (f.e. dialout)
-		   3. device is buggy (ppp)
-		 */
-
-requeue:
-		if (unlikely(q == &noop_qdisc))
-			kfree_skb(skb);
-		else if (skb->next)
-			dev->gso_skb = skb;
-		else
-			q->ops->requeue(skb, q);
-		netif_schedule(dev);
-		return 0;
+	/* we have a packet to send */
+	if (!lockless) {
+		if (!netif_tx_trylock(dev))
+			return tx_islocked(skb, dev, q);
 	}
-
-out:
-	BUG_ON((int) q->q.qlen < 0);
-	return q->q.qlen;
+	/* all clear .. */
+	spin_unlock(&dev->queue_lock);
+
+	ret = NETDEV_TX_BUSY;
+	if (!netif_queue_stopped(dev))
+		/* churn baby churn .. */
+		ret = dev_hard_start_xmit(skb, dev);
+
+	if (!lockless)
+		netif_tx_unlock(dev);
+
+	spin_lock(&dev->queue_lock);
+
+	/* we need to refresh q because it may be invalid since
+	 * we dropped  dev->queue_lock earlier ...
+	 * So dont try to be clever grasshopper
+	*/
+	q = dev->qdisc;
+	/* most likely result, packet went ok */
+	if (ret == NETDEV_TX_OK)
+		return qdisc_qlen(q);
+	/* only for lockless drivers .. */
+	if (ret == NETDEV_TX_LOCKED && lockless)
+		return tx_islocked(skb, dev, q);
+
+	if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
+		printk(KERN_DEBUG " BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);
+
+	return do_dev_requeue(skb, dev, q);
 }
 
 void __qdisc_run(struct net_device *dev)

--=-85kO44j9oT7ZumcmHVW4--

