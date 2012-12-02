From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] workqueue: mod_delayed_work_on() shouldn't queue timer on 0
 delay
Date: Sat, 1 Dec 2012 17:11:57 -0800
Message-ID: <20121202011157.GE2685@htj.dyndns.org>
References: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu>
 <alpine.DEB.2.00.1211281016320.26602@dr-wily.mit.edu>
 <20121130211435.GJ3873@htj.dyndns.org>
 <20121130225619.GD6021@htj.dyndns.org>
 <alpine.DEB.2.00.1211302234410.25064@dr-wily.mit.edu>
 <20121201143926.GB2685@htj.dyndns.org>
 <alpine.DEB.2.00.1212011852100.25064@dr-wily.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Zlatko Calusic <zlatko.calusic@iskon.hr>,
	Joonsoo Kim <js1304@gmail.com>
To: Anders Kaseorg <andersk@MIT.EDU>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1212011852100.25064@dr-wily.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 8852aac25e79e38cc6529f20298eed154f60b574 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj@kernel.org>
Date: Sat, 1 Dec 2012 16:23:42 -0800

8376fe22c7 ("workqueue: implement mod_delayed_work[_on]()")
implemented mod_delayed_work[_on]() using the improved
try_to_grab_pending().  The function is later used, among others, to
replace [__]candel_delayed_work() + queue_delayed_work() combinations.

Unfortunately, a delayed_work item w/ zero @delay is handled slightly
differently by mod_delayed_work_on() compared to
queue_delayed_work_on().  The latter skips timer altogether and
directly queues it using queue_work_on() while the former schedules
timer which will expire on the closest tick.  This means, when @delay
is zero, that [__]cancel_delayed_work() + queue_delayed_work_on()
makes the target item immediately executable while
mod_delayed_work_on() may induce delay of upto a full tick.

This somewhat subtle difference breaks some of the converted users.
e.g. block queue plugging uses delayed_work for deferred processing
and uses mod_delayed_work_on() when the queue needs to be immediately
unplugged.  The above problem manifested as noticeably higher number
of context switches under certain circumstances.

The difference in behavior was caused by missing special case handling
for 0 delay in mod_delayed_work_on() compared to
queue_delayed_work_on().  Joonsoo Kim posted a patch to add it -
("workqueue: optimize mod_delayed_work_on() when @delay == 0")[1].
The patch was queued for 3.8 but it was described as optimization and
I missed that it was a correctness issue.

As both queue_delayed_work_on() and mod_delayed_work_on() use
__queue_delayed_work() for queueing, it seems that the better approach
is to move the 0 delay special handling to the function instead of
duplicating it in mod_delayed_work_on().

Fix the problem by moving 0 delay special case handling from
queue_delayed_work_on() to __queue_delayed_work().  This replaces
Joonsoo's patch.

[1] http://thread.gmane.org/gmane.linux.kernel/1379011/focus=1379012

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-and-tested-by: Anders Kaseorg <andersk@MIT.EDU>
Reported-and-tested-by: Zlatko Calusic <zlatko.calusic@iskon.hr>
LKML-Reference: <alpine.DEB.2.00.1211280953350.26602@dr-wily.mit.edu>
LKML-Reference: <50A78AA9.5040904@iskon.hr>
Cc: Joonsoo Kim <js1304@gmail.com>
---
Applied to wq/for-3.7-fixes.  Pull request sent.

Thanks!

 kernel/workqueue.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ac25db1..084aa47 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1364,6 +1364,17 @@ static void __queue_delayed_work(int cpu, struct workqueue_struct *wq,
 	BUG_ON(timer_pending(timer));
 	BUG_ON(!list_empty(&work->entry));
 
+	/*
+	 * If @delay is 0, queue @dwork->work immediately.  This is for
+	 * both optimization and correctness.  The earliest @timer can
+	 * expire is on the closest next tick and delayed_work users depend
+	 * on that there's no such delay when @delay is 0.
+	 */
+	if (!delay) {
+		__queue_work(cpu, wq, &dwork->work);
+		return;
+	}
+
 	timer_stats_timer_set_start_info(&dwork->timer);
 
 	/*
@@ -1417,9 +1428,6 @@ bool queue_delayed_work_on(int cpu, struct workqueue_struct *wq,
 	bool ret = false;
 	unsigned long flags;
 
-	if (!delay)
-		return queue_work_on(cpu, wq, &dwork->work);
-
 	/* read the comment in __queue_work() */
 	local_irq_save(flags);
 
-- 
1.7.11.7
