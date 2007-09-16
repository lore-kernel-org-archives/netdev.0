From: jamal <hadi@cyberus.ca>
Subject: [RFC][NET_SCHED] explict hold dev tx lock
Date: Sun, 16 Sep 2007 12:14:34 -0400
Message-ID: <1189959274.4241.30.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wDTibh3ERbKq8FWkIFPC"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:46884 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbXIPQOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 12:14:38 -0400
Received: by an-out-0708.google.com with SMTP id d31so194589and
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 09:14:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wDTibh3ERbKq8FWkIFPC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


While trying to port my batching changes to net-2.6.24 from this morning
i realized this is something i had wanted to probe people on....

Challenge:
For N Cpus, with full throttle traffic on all N CPUs, funneling traffic
to the same ethernet device, the devices queue lock is contended by all
N CPUs constantly. The TX lock is only contended by a max of 2 CPUS. 
In the current mode of operation, after all the work of entering the
dequeue region, we may endup aborting the path if we are unable to get
the tx lock and go back to contend for the queue lock. As N goes up,
this gets worse.

Testing:
I did some testing with a 4 cpu (2xdual core) with no irq binding. I run
about 10 runs of 30M packets each from the stack with a udp app i wrote
which is intended to run keep all 4 cpus busy -  and to my suprise i
found that we only bail out less than 0.1%. I may need a better test
case.

Changes:
I made changes to the code path as defined in the patch included to 
and noticed a slight increase (2-3%) in performance with both e1000 and
tg3; which was a relief because i thought the spinlock_irq (which is
needed because some drivers grab tx lock in interupts) may have negative
effects. The fact it didnt reduce performance was a good thing.
Note: This is the highest end machine ive ever laid hands on, so this
may be misleading.
 
So - what side effects do people see in doing this? If none, i will
clean it up and submit.

cheers,
jamal

--=-wDTibh3ERbKq8FWkIFPC
Content-Disposition: attachment; filename=nsqr1
Content-Type: text/x-patch; name=nsqr1; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dc5e35f..ab9966f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1271,6 +1271,12 @@ static inline void netif_tx_lock(struct net_device *dev)
 	dev->xmit_lock_owner = smp_processor_id();
 }
 
+static inline void netif_tx_lock_irq(struct net_device *dev)
+{
+	spin_lock_irq(&dev->_xmit_lock);
+	dev->xmit_lock_owner = smp_processor_id();
+}
+
 static inline void netif_tx_lock_bh(struct net_device *dev)
 {
 	spin_lock_bh(&dev->_xmit_lock);
@@ -1291,6 +1297,12 @@ static inline void netif_tx_unlock(struct net_device *dev)
 	spin_unlock(&dev->_xmit_lock);
 }
 
+static inline void netif_tx_unlock_irq(struct net_device *dev)
+{
+	dev->xmit_lock_owner = -1;
+	spin_unlock_irq(&dev->_xmit_lock);
+}
+
 static inline void netif_tx_unlock_bh(struct net_device *dev)
 {
 	dev->xmit_lock_owner = -1;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e970e8e..f75a924 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -134,34 +134,23 @@ static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
-	unsigned lockless;
+	unsigned lockless = (dev->features & NETIF_F_LLTX);
 	int ret;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
 		return 0;
 
-	/*
-	 * When the driver has LLTX set, it does its own locking in
-	 * start_xmit. These checks are worth it because even uncongested
-	 * locks can be quite expensive. The driver can do a trylock, as
-	 * is being done here; in case of lock contention it should return
-	 * NETDEV_TX_LOCKED and the packet will be requeued.
-	 */
-	lockless = (dev->features & NETIF_F_LLTX);
-
-	if (!lockless && !netif_tx_trylock(dev)) {
-		/* Another CPU grabbed the driver tx lock */
-		return handle_dev_cpu_collision(skb, dev, q);
-	}
-
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
+	if (!lockless)
+		netif_tx_lock_irq(dev);
+
 	ret = dev_hard_start_xmit(skb, dev);
 
 	if (!lockless)
-		netif_tx_unlock(dev);
+		netif_tx_unlock_irq(dev);
 
 	spin_lock(&dev->queue_lock);
 	q = dev->qdisc;

--=-wDTibh3ERbKq8FWkIFPC--

