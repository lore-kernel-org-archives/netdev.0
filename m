From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Tue, 12 Aug 2008 12:40:34 +0000
Message-ID: <20080812124034.GA7666@ff.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <200808021555.10733.denys@visp.net.lb> <20080802130740.GA2970@ami.dom.local> <200808121431.40852.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:58275 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbYHLMkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 08:40:42 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1336121fgg.17
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 05:40:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808121431.40852.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 02:31:40PM +0300, Denys Fedoryshchenko wrote:
...
> With second patch it works fine, 9 days uptime now

Great! I didn't expect it would be so easy with this strange problem.
So, it looks like hrtimers could break probably after some
overscheduling. The only problem with this is to find some reasonable
limit which is both safe and doesn't harm resolution too much for
others.

IMHO this second patch with 1 jiffie watchdog resolution looks
reasonable and should be acceptable, but it would be nice to check if
we can go lower. Here is "the same" patch with only change in
resolution (1/10 of jiffie). If there are any problems with testing
this please let me know. (It should be applied after reverting
patch #2.)

Thanks,
Jarek P.

(testing patch #3)
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
+	     q->next_watchdog - PSCHED_TICKS_PER_SEC / (10 * HZ)) {
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
