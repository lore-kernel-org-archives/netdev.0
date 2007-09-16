From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Sun, 16 Sep 2007 17:10:00 -0400
Message-ID: <1189977000.4230.25.camel@localhost>
References: <1189959274.4241.30.camel@localhost>
	 <20070916.123158.92582301.davem@davemloft.net>
	 <1189975284.4230.14.camel@localhost>  <1189975939.4230.19.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jIf/YdHG4gn7bPVxqpJ2"
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:13746 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbXIPVKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 17:10:04 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1183626wxd
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 14:10:04 -0700 (PDT)
In-Reply-To: <1189975939.4230.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jIf/YdHG4gn7bPVxqpJ2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2007-16-09 at 16:52 -0400, jamal wrote:

> What i should say is
> if i grabbed the lock explicitly without disabling irqs it wont be much
> different than what is done today and should always work.
> No?

And to be more explicit, heres a patch using the macros from previous
patch. So far tested on 3 NICs.

cheers,
jamal


--=-jIf/YdHG4gn7bPVxqpJ2
Content-Disposition: attachment; filename=nsqr2
Content-Type: text/x-patch; name=nsqr2; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e970e8e..1ae905e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -134,34 +134,18 @@ static inline int qdisc_restart(struct net_device *dev)
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
-
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

--=-jIf/YdHG4gn7bPVxqpJ2--

