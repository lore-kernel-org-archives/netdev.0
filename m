From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Thu, 24 Jul 2008 01:24:56 +0200
Message-ID: <20080723232456.GA5835@ami.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <200807222346.36284.denys@visp.net.lb> <20080722213603.GA3026@ami.dom.local> <200807232247.17218.denys@visp.net.lb> <20080723222631.GA2397@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:41119 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754268AbYGWXZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 19:25:15 -0400
Received: by nf-out-0910.google.com with SMTP id d3so994042nfc.21
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 16:25:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080723222631.GA2397@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(take 3)

...I'm really sorry! If it's possible better try to restart with this one.

Jarek P.

---

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3fb58f4..6b6fff3 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -169,7 +169,8 @@ struct htb_sched {
 
 	int rate2quantum;	/* quant = rate / rate2quantum */
 	psched_time_t now;	/* cached dequeue time */
-	struct qdisc_watchdog watchdog;
+	//struct qdisc_watchdog watchdog;
+	struct timer_list timer;	/* send delay timer */
 
 	/* non shaped skbs; let them go directly thru */
 	struct sk_buff_head direct_queue;
@@ -893,6 +894,14 @@ next:
 	return skb;
 }
 
+static void htb_timer(unsigned long arg)
+{
+	struct Qdisc *sch = (struct Qdisc*)arg;
+	sch->flags &= ~TCQ_F_THROTTLED;
+	wmb();
+	netif_schedule(sch->dev);
+}
+
 static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 {
 	struct sk_buff *skb = NULL;
@@ -943,7 +952,10 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		}
 	}
 	sch->qstats.overlimits++;
-	qdisc_watchdog_schedule(&q->watchdog, next_event);
+	//qdisc_watchdog_schedule(&q->watchdog, next_event);
+	next_event = next_event - q->now;
+	mod_timer(&q->timer, jiffies + (unsigned long)next_event * HZ /
+				 PSCHED_TICKS_PER_SEC);
 fin:
 	return skb;
 }
@@ -996,7 +1008,9 @@ static void htb_reset(struct Qdisc *sch)
 
 		}
 	}
-	qdisc_watchdog_cancel(&q->watchdog);
+	//qdisc_watchdog_cancel(&q->watchdog);
+	sch->flags &= ~TCQ_F_THROTTLED;
+	del_timer(&q->timer);
 	__skb_queue_purge(&q->direct_queue);
 	sch->q.qlen = 0;
 	memset(q->row, 0, sizeof(q->row));
@@ -1047,7 +1061,11 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
 		INIT_LIST_HEAD(q->drops + i);
 
-	qdisc_watchdog_init(&q->watchdog, sch);
+	//qdisc_watchdog_init(&q->watchdog, sch);
+	q->timer.function = htb_timer;
+	q->timer.data = (unsigned long)sch;
+	init_timer(&q->timer);
+
 	skb_queue_head_init(&q->direct_queue);
 
 	q->direct_qlen = sch->dev->tx_queue_len;
@@ -1262,7 +1280,8 @@ static void htb_destroy(struct Qdisc *sch)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 
-	qdisc_watchdog_cancel(&q->watchdog);
+	//qdisc_watchdog_cancel(&q->watchdog);
+	del_timer_sync(&q->timer);
 	/* This line used to be after htb_destroy_class call below
 	   and surprisingly it worked in 2.4. But it must precede it
 	   because filter need its target class alive to be able to call
