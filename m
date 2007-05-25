From: jamal <hadi@cyberus.ca>
Subject: [RESEND][PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Thu, 24 May 2007 21:58:00 -0400
Message-ID: <1180058280.4069.9.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902E7C23A@orsmsx414.amr.corp.intel.com>
	 <4655B9C2.4050200@trash.net>  <1180057935.4069.5.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-N76uu6DIdgYbOwVKHU6v"
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:40296 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbXEYB6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 21:58:07 -0400
Received: by wx-out-0506.google.com with SMTP id t15so487266wxc
        for <netdev@vger.kernel.org>; Thu, 24 May 2007 18:58:05 -0700 (PDT)
In-Reply-To: <1180057935.4069.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-N76uu6DIdgYbOwVKHU6v
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave please apply this patch; against latest net-2.6 

cheers,
jamal


--=-N76uu6DIdgYbOwVKHU6v
Content-Disposition: attachment; filename=rqs-2
Content-Type: text/plain; name=rqs-2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_SCHED]: Cleanup readability of qdisc restart

Over the years this code has gotten hairier. Resulting in many long
discussions over long summer days and patches that get it wrong.
This patch helps tame that code so normal people will understand it.

Thanks to Thomas Graf, Peter J. waskiewicz Jr, and Patrick McHardy
for their valuable reviews.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 689af2a1508887470b61cd4f5f24629e796d8436
tree 0bbab1b24b9bd0522f3310b6b99f42c7f02c4d43
parent 04efb8787e4d8a7b21a61aeb723de33154311256
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 24 May 2007 21:42:50 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 24 May 2007 21:42:50 -0400

 net/sched/sch_generic.c |  205 ++++++++++++++++++++++++++---------------------
 1 files changed, 112 insertions(+), 93 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cbefe22..5159e0d 100644
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
+			printk(KERN_WARNING
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
 
@@ -67,116 +137,65 @@ void qdisc_unlock_tree(struct net_device *dev)
 
    dev->queue_lock and netif_tx_lock are mutually exclusive,
    if one is grabbed, another must be free.
- */
 
+   Multiple CPUs may contend for the two locks.
 
-/* Kick device.
+   Note, that this procedure can be called by a watchdog timer
 
+   Returns to the caller:
    Returns:  0  - queue is empty or throttled.
 	    >0  - queue is not empty.
 
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
-
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
+	skb = try_get_tx_pkt(dev, q);
+	if (skb == NULL)
+		return 0;
 
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
+	/* we have a packet to send */
+	if (!lockless) {
+		if (!netif_tx_trylock(dev))
+			return tx_islocked(skb, dev, q);
 	}
-	return 0;
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
+		printk(KERN_WARNING " BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);
+
+	return do_dev_requeue(skb, dev, q);
 }
 
+
 void __qdisc_run(struct net_device *dev)
 {
 	do {

--=-N76uu6DIdgYbOwVKHU6v--

