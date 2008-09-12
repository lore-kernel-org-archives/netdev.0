From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/1] net: fix scheduling of dst_gc_task by __dst_free
Date: Fri, 12 Sep 2008 14:31:23 +0200
Message-ID: <20080912123118.993434427@theryb.frec.bull.fr>
References: <20080912123113.770453085@theryb.frec.bull.fr>
Cc: netdev@vger.kernel.org, Benjamin Thery <benjamin.thery@bull.net>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:41604 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbYILMcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 08:32:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dst garbage collector dst_gc_task() may not be scheduled as we
expect it to be in __dst_free().

Indeed, when the dst_gc_timer was replaced by the delayed_work
dst_gc_work, the mod_timer() call used to schedule the garbage
collector at an earlier date was replaced by a schedule_delayed_work()
(see commit 86bba269d08f0c545ae76c90b56727f65d62d57f).

But, the behaviour of mod_timer() and schedule_delayed_work() is
different in the way they handle the delay. 

mod_timer() stops the timer and re-arm it with the new given delay,
whereas schedule_delayed_work() only check if the work is already
queued in the workqueue (and queue it (with delay) if it is not)
BUT it does NOT take into account the new delay (even if the new delay
is earlier in time).
schedule_delayed_work() returns 0 if it didn't queue the work,
but we don't check the return code in __dst_free().

If I understand the code in __dst_free() correctly, we want dst_gc_task
to be queued after DST_GC_INC jiffies if we pass the test (and not in
some undetermined time in the future), so I think we should add a call
to cancel_delayed_work() before schedule_delayed_work(). Patch below.

Or we should at least test the return code of schedule_delayed_work(),
and reset the values of dst_garbage.timer_inc and dst_garbage.timer_expires
back to their former values if schedule_delayed_work() failed.
Otherwise the subsequent calls to __dst_free will test the wrong values
and assume wrong thing about when the garbage collector is supposed to
be scheduled.

dst_gc_task() also calls schedule_delayed_work() without checking
its return code (or calling cancel_scheduled_work() first), but it
should fine there: dst_gc_task is the routine of the delayed_work, so
no dst_gc_work should be pending in the queue when it's running.
 
This patch applies on top of net-2.6.

(Sorry, I think I've been a bit verbose to expose this simple issue :)

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/core/dst.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6/net/core/dst.c
===================================================================
--- net-2.6.orig/net/core/dst.c
+++ net-2.6/net/core/dst.c
@@ -203,6 +203,7 @@ void __dst_free(struct dst_entry * dst)
 	if (dst_garbage.timer_inc > DST_GC_INC) {
 		dst_garbage.timer_inc = DST_GC_INC;
 		dst_garbage.timer_expires = DST_GC_MIN;
+		cancel_delayed_work(&dst_gc_work);
 		schedule_delayed_work(&dst_gc_work, dst_garbage.timer_expires);
 	}
 	spin_unlock_bh(&dst_garbage.lock);

-- 
