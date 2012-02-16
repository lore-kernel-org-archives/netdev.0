From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netem: fix dequeue
Date: Thu, 16 Feb 2012 07:28:25 +0100
Message-ID: <1329373705.5646.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61763 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942Ab2BPG2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 01:28:30 -0500
Received: by wgbdt10 with SMTP id dt10so1631660wgb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 22:28:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 50612537e9 (netem: fix classful handling) added two errors in
netem_dequeue() 

1) After checking skb at the head of tfifo queue for time constraints,
   it dequeues tail skb, thus adding unwanted reordering.

2) qdisc stats are updated twice per packet
   (one when packet dequeued from tfifo, once when delivered)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_netem.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index e83d61c..5da548f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -501,9 +501,8 @@ tfifo_dequeue:
 
 		/* if more time remaining? */
 		if (cb->time_to_send <= psched_get_time()) {
-			skb = qdisc_dequeue_tail(sch);
-			if (unlikely(!skb))
-				goto qdisc_dequeue;
+			__skb_unlink(skb, &sch->q);
+			sch->qstats.backlog -= qdisc_pkt_len(skb);
 
 #ifdef CONFIG_NET_CLS_ACT
 			/*
@@ -539,7 +538,6 @@ deliver:
 		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
 	}
 
-qdisc_dequeue:
 	if (q->qdisc) {
 		skb = q->qdisc->ops->dequeue(q->qdisc);
 		if (skb)
