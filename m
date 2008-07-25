From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Fri, 25 Jul 2008 07:36:28 +0000
Message-ID: <20080725073628.GA10399@ff.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <20080723222631.GA2397@ami.dom.local> <20080723232456.GA5835@ami.dom.local> <200807240256.36098.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:4783 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbYGYHbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 03:31:21 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1213052nfc.21
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 00:31:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200807240256.36098.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Denys,

In case this is still working after hrtimer -> timer change here is
another patch for testing: to check if limiting hrtimers scheduling
could matter here. Btw. could you write what is the approximate
number of htb qdiscs and classes working on each device of this box
(including ifbs)?

Thanks,
Jarek P.

(This patch should be applided to 2.6.26 or .25 after reverting
the previous debugging patch.)

---

 net/sched/sch_htb.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 30c999c..ff9e965 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -162,6 +162,7 @@ struct htb_sched {
 
 	int rate2quantum;	/* quant = rate / rate2quantum */
 	psched_time_t now;	/* cached dequeue time */
+	psched_time_t next_watchdog;
 	struct qdisc_watchdog watchdog;
 
 	/* non shaped skbs; let them go directly thru */
@@ -920,7 +921,11 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		}
 	}
 	sch->qstats.overlimits++;
-	qdisc_watchdog_schedule(&q->watchdog, next_event);
+	if (q->next_watchdog < q->now || next_event <=
+	     q->next_watchdog - PSCHED_TICKS_PER_SEC / HZ) {
+		qdisc_watchdog_schedule(&q->watchdog, next_event);
+		q->next_watchdog = next_event;
+	}
 fin:
 	return skb;
 }
@@ -973,6 +978,7 @@ static void htb_reset(struct Qdisc *sch)
 		}
 	}
 	qdisc_watchdog_cancel(&q->watchdog);
+	q->next_watchdog = 0;
 	__skb_queue_purge(&q->direct_queue);
 	sch->q.qlen = 0;
 	memset(q->row, 0, sizeof(q->row));
