From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Subject: [PATCH 2/2] qdisc_restart - couple of optimizations.
Date: Wed, 13 Jun 2007 14:10:49 +0530
Message-ID: <1181724049.10679.31.camel@localhost.localdomain>
Reply-To: kumarkr@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jamal@cyberus.ca, herbert@gondor.apana.org.au,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:41736 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbXFMIk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 04:40:59 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5D923Vm186628
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 19:02:03 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5D8hwGb131252
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 18:44:05 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5D8eLn2015253
	for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 18:40:22 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- netif_queue_stopped need not be called inside qdisc_restart as
  it has been called already in qdisc_run() before the first skb
  is sent, and in __qdisc_run() after each intermediate skb is 
  sent (note : we are the only sender, so the queue cannot get
  stopped while the tx lock was got in the ~LLTX case).

- BUG_ON((int) q->q.qlen < 0) was a relic from old times when -1
  meant more packets are available, and __qdisc_run used to loop
  when qdisc_restart() returned -1. During those days, it was
  necessary to make sure that qlen is never less than zero, since
  __qdisc_run would get into an infinite loop if no packets are on
  the queue and this bug in qdisc was there (and worse - no more
  skbs could ever get queue'd as we hold the queue lock too). With
  Herbert's recent change to return values, this check is not
  required.  Hopefully Herbert can validate this change. If at all
  this is required, it should be added to skb_dequeue (in failure
  case), and not to qdisc_qlen.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c 2007-06-11 13:12:11.000000000 +0530
+++ new/net/sched/sch_generic.c 2007-06-11 15:37:48.000000000 +0530
@@ -61,7 +61,6 @@ void qdisc_unlock_tree(struct net_device
 
 static inline int qdisc_qlen(struct Qdisc *q)
 {
-	BUG_ON((int) q->q.qlen < 0);
 	return q->q.qlen;
 }
 
@@ -167,9 +166,7 @@ static inline int qdisc_restart(struct n
 	/* And release queue */
 	spin_unlock(&dev->queue_lock);
 
-	ret = NETDEV_TX_BUSY;
-	if (!netif_queue_stopped(dev))
-		ret = dev_hard_start_xmit(skb, dev);
+	ret = dev_hard_start_xmit(skb, dev);
 
 	if (!lockless)
 		netif_tx_unlock(dev);


