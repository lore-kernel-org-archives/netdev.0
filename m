From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] netdevice: Use existing macros
Date: Sun, 30 Aug 2009 11:51:21 +0530
Message-ID: <20090830062121.6296.60149.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:49114 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbZH3GVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 02:21:23 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7U6LMVk012093
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 16:21:22 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7U6LNQA397776
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 16:21:24 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7U6LNPP015655
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 16:21:23 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

netdevice: Consolidate to use existing macros where available.

Patch compiled and 32 simultaneous netperf testing ran fine. 

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 include/linux/netdevice.h |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2009-08-29 13:53:51.000000000 +0530
+++ new/include/linux/netdevice.h	2009-08-29 13:54:07.000000000 +0530
@@ -1257,7 +1257,7 @@ static inline void netif_tx_wake_queue(s
 {
 #ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap()) {
-		clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+		netif_tx_start_queue(dev_queue);
 		return;
 	}
 #endif
@@ -1363,7 +1363,8 @@ static inline int netif_running(const st
 static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
-	clear_bit(__QUEUE_STATE_XOFF, &txq->state);
+
+	netif_tx_start_queue(txq);
 }
 
 /**
@@ -1380,7 +1381,7 @@ static inline void netif_stop_subqueue(s
 	if (netpoll_trap())
 		return;
 #endif
-	set_bit(__QUEUE_STATE_XOFF, &txq->state);
+	netif_tx_stop_queue(txq);
 }
 
 /**
@@ -1394,7 +1395,8 @@ static inline int __netif_subqueue_stopp
 					 u16 queue_index)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
-	return test_bit(__QUEUE_STATE_XOFF, &txq->state);
+
+	return netif_tx_queue_stopped(txq);
 }
 
 static inline int netif_subqueue_stopped(const struct net_device *dev,
@@ -1746,8 +1748,7 @@ static inline void netif_tx_unlock(struc
 		 * force a schedule.
 		 */
 		clear_bit(__QUEUE_STATE_FROZEN, &txq->state);
-		if (!test_bit(__QUEUE_STATE_XOFF, &txq->state))
-			__netif_schedule(txq->qdisc);
+		netif_schedule_queue(txq);
 	}
 	spin_unlock(&dev->tx_global_lock);
 }
