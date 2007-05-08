From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] sched: teql_enqueue can check limits before skb enqueue
Date: Tue, 08 May 2007 13:01:24 +0530
Message-ID: <20070508073124.17543.7859.sendpatchset@localhost.localdomain>
Cc: krkumar2@in.ibm.com, Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:64545 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933949AbXEHHb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 03:31:56 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l487pT64266888
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:51:30 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l487ZKYs167166
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:35:21 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l487Vl9J010089
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:31:48 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Optimize teql_enqueue so that it first checks limits before
enqueing.

Patch against net-2.6.22.git

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
diff -ruNp org/net/sched/sch_teql.c new/net/sched/sch_teql.c
--- org/net/sched/sch_teql.c	2007-04-09 12:37:41.000000000 +0530
+++ new/net/sched/sch_teql.c	2007-04-09 12:39:15.000000000 +0530
@@ -94,14 +94,13 @@ teql_enqueue(struct sk_buff *skb, struct
 	struct net_device *dev = sch->dev;
 	struct teql_sched_data *q = qdisc_priv(sch);
 
-	__skb_queue_tail(&q->q, skb);
-	if (q->q.qlen <= dev->tx_queue_len) {
+	if (q->q.qlen < dev->tx_queue_len) {
+		__skb_queue_tail(&q->q, skb);
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
 		return 0;
 	}
 
-	__skb_unlink(skb, &q->q);
 	kfree_skb(skb);
 	sch->qstats.drops++;
 	return NET_XMIT_DROP;
