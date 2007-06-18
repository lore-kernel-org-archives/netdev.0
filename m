From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Subject: [PATCH 2/2 - rev2] qdisc_restart - couple of optimizations.
Date: Mon, 18 Jun 2007 10:24:11 +0530
Message-ID: <1182142451.6082.12.camel@localhost.localdomain>
References: <1181724049.10679.31.camel@localhost.localdomain>
Reply-To: kumarkr@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:65361 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbXFRExf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 00:53:35 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5I5F7sT293586
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 15:15:07 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5I4uxWk147566
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 14:57:00 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5I4rQTD015870
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 14:53:27 +1000
In-Reply-To: <1181724049.10679.31.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Same from previous patch, resending for completion)

Changes :

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


