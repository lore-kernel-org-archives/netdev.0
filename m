From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Wed, 19 Sep 2007 22:43:03 -0400
Message-ID: <1190256183.4818.28.camel@localhost>
References: <20070917.190133.79431533.davem@davemloft.net>
	 <1190083728.4237.59.camel@localhost> <1190208832.4259.6.camel@localhost>
	 <20070919.090937.32177545.davem@davemloft.net>
	 <1190255605.4818.25.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fBuzyDJgWVx6UUfhk+pE"
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:28721 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbXITCnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 22:43:10 -0400
Received: by an-out-0708.google.com with SMTP id d31so62442and
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 19:43:09 -0700 (PDT)
In-Reply-To: <1190255605.4818.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fBuzyDJgWVx6UUfhk+pE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Ok, this is from the net-2.6.24 of about an hour ago. 

cheers,
jamal



--=-fBuzyDJgWVx6UUfhk+pE
Content-Disposition: attachment; filename=nsqr3
Content-Type: text/plain; name=nsqr3; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_SCHED] explict hold dev tx lock

For N cpus, with full throttle traffic on all N CPUs, funneling traffic
to the same ethernet device, the devices queue lock is contended by all
N CPUs constantly. The TX lock is only contended by a max of 2 CPUS.
In the current mode of operation, after all the work of entering the
dequeue region, we may endup aborting the path if we are unable to get
the tx lock and go back to contend for the queue lock. As N goes up,
this gets worse.

The changes in this patch result in a small increase in performance
with a 4CPU (2xdual-core) with no irq binding. Both e1000 and tg3
showed similar behavior;

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 5973a9734a93903e7c3547dbe19addc42600240f
tree a57bd488e200fdaa3dfef7f27de52cbe02238dd3
parent 31b9dd879cd9fd254484de2950341acdcb62680f
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 19 Sep 2007 22:29:16 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 19 Sep 2007 22:29:16 -0400

 net/sched/sch_generic.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e970e8e..95ae119 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -134,34 +134,19 @@ static inline int qdisc_restart(struct net_device *dev)
 {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
-	unsigned lockless;
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
 
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
+	HARD_TX_LOCK(dev, smp_processor_id());
 	ret = dev_hard_start_xmit(skb, dev);
-
-	if (!lockless)
-		netif_tx_unlock(dev);
+	HARD_TX_UNLOCK(dev);
 
 	spin_lock(&dev->queue_lock);
 	q = dev->qdisc;

--=-fBuzyDJgWVx6UUfhk+pE--

