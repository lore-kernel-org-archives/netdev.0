From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Fri, 10 Oct 2008 07:56:40 +0000
Message-ID: <20081010075640.GA5204@ff.dom.local>
References: <48EEEBC1.2090008@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:45104 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbYJJH4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 03:56:47 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1210450ugf.37
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 00:56:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48EEEBC1.2090008@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-10-2008 07:44, Badalian Vyacheslav wrote:
> Hello all!

Hello Slavon,

> 
> Please look to if you have time:
> http://bugzilla.kernel.org/show_bug.cgi?id=11718
> 
> We have deadlocks at few PC one times in week.
> I can test any patches to detect and fix problem.
> Now i test 2.6.27-rc kernel at one PC.

A similar bug was reported by Denys Fedoryshchenko but it wasn't fully
diagnosed. Anyway it looks like hardware dependent. The patch below
can sometimes help. 2.6.27 may have this fixed too (some other way).

Jarek P.

(some offsets are OK when patching 2.6.26)
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
