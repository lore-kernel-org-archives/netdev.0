From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: Re: [PATCH] PATCH 1/2 [SCHED 2.6.24]: Check subqueue status before calling hard_start_xmit
Date: Wed, 14 Nov 2007 11:34:12 +0530
Message-ID: <20071114060412.9556.84833.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:38645 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbXKNGBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 01:01:04 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAE62cps016925
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 01:02:38 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAE611d3138534
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 01:01:01 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAE610Iw003028
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 01:01:01 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter,

Peter wrote on 11/13/2007 11:14:50 PM:
> @@ -134,7 +134,7 @@ static inline int qdisc_restart(struct net_device *dev)
>  {
>     struct Qdisc *q = dev->qdisc;
>     struct sk_buff *skb;
> -   int ret;
> +   int ret = NETDEV_TX_BUSY;
>  
>     /* Dequeue packet */
>     if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
> @@ -145,7 +145,8 @@ static inline int qdisc_restart(struct net_device *dev)
>     spin_unlock(&dev->queue_lock);
>  
>     HARD_TX_LOCK(dev, smp_processor_id());
> -   ret = dev_hard_start_xmit(skb, dev);
> +   if (!netif_subqueue_stopped(dev, skb))
> +      ret = dev_hard_start_xmit(skb, dev);
>     HARD_TX_UNLOCK(dev);

You could optimize this by getting HARD_TX_LOCK after the check. I
assume that netif_stop_subqueue (from another CPU) would always be
called by the driver xmit, and that is not possible since we hold
the __LINK_STATE_QDISC_RUNNING bit. Does that sound correct?

PATCH
------

diff -ruNp 1/net/sched/sch_generic.c 2/net/sched/sch_generic.c
--- 1/net/sched/sch_generic.c	2007-11-14 11:14:10.000000000 +0530
+++ 2/net/sched/sch_generic.c	2007-11-14 11:18:27.000000000 +0530
@@ -144,10 +144,11 @@ static inline int qdisc_restart(struct n
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
-	HARD_TX_LOCK(dev, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
+		HARD_TX_LOCK(dev, smp_processor_id());
 		ret = dev_hard_start_xmit(skb, dev);
-	HARD_TX_UNLOCK(dev);
+		HARD_TX_UNLOCK(dev);
+	}
 
 	spin_lock(&dev->queue_lock);
 	q = dev->qdisc;

Thanks,

- KK
