From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] sched: Optimize return value of qdisc_restart
Date: Tue, 08 May 2007 13:01:32 +0530
Message-ID: <20070508073132.17547.68502.sendpatchset@localhost.localdomain>
Cc: krkumar2@in.ibm.com, Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:64592 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934465AbXEHHcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 03:32:02 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l487pZbF242744
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:51:35 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l487ZRdE163232
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:35:27 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l487VtdQ013866
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:31:55 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Optimize return value of qdisc_restart so that it is not called an
extra time if there are no more packets on the queue to be sent out.
It is also not required to check for gso_skb (though the lock is
dropped) since another cpu which added this would have done a
netif_schedule.

Patch against net-2.6.22.git

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2007-05-07 17:25:25.000000000 +0530
+++ new/net/sched/sch_generic.c	2007-05-07 17:39:04.000000000 +0530
@@ -115,7 +115,7 @@ static inline int qdisc_restart(struct n
 					kfree_skb(skb);
 					if (net_ratelimit())
 						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
-					return -1;
+					return q->q.qlen ? -1 : 0;
 				}
 				__get_cpu_var(netdev_rx_stat).cpu_collision++;
 				goto requeue;
@@ -135,7 +135,7 @@ static inline int qdisc_restart(struct n
 						netif_tx_unlock(dev);
 					}
 					spin_lock(&dev->queue_lock);
-					return -1;
+					return q->q.qlen ? -1 : 0;
 				}
 				if (ret == NETDEV_TX_LOCKED && nolock) {
 					spin_lock(&dev->queue_lock);
