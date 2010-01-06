From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH] workqueue.c: should schedule work serialize work->func
Date: Wed, 06 Jan 2010 23:05:12 +0000
Message-ID: <20100106230512.17900.47310.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jesse.brandeburg@ingel.com, tj@kernel.org,
	tglx@linuxtronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51734 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933023Ab0AFXGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 18:06:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

codepath
schedule_work(); ... ; run_workqueue() -> work_clear_pending() -> f(work)

Although schedule_work() will only schedule the task if it is not already
on the work queue the WORK_STRUCT_PENDING bits are cleared just before
calling the work function.  If work is scheduled after this occurs and
before f(work) completes it is possible to have multiple calls into f().

Should the kernel protect us from this? With something like the patch
below.

Thanks
---

 include/linux/workqueue.h |    3 ++-
 kernel/workqueue.c        |    3 +++
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 9466e86..fa6ffea 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -26,7 +26,8 @@ struct work_struct {
 	atomic_long_t data;
 #define WORK_STRUCT_PENDING 0		/* T if work item pending execution */
 #define WORK_STRUCT_STATIC  1		/* static initializer (debugobjects) */
-#define WORK_STRUCT_FLAG_MASK (3UL)
+#define WORK_STRUCT_RUNNING 2
+#define WORK_STRUCT_FLAG_MASK (7UL)	/* 0111 */
 #define WORK_STRUCT_WQ_DATA_MASK (~WORK_STRUCT_FLAG_MASK)
 	struct list_head entry;
 	work_func_t func;
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index dee4865..b867125 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -397,10 +397,13 @@ static void run_workqueue(struct cpu_workqueue_struct *cwq)
 		spin_unlock_irq(&cwq->lock);
 
 		BUG_ON(get_wq_data(work) != cwq);
+		while (test_and_set_bit(WORK_STRUCT_RUNNING, work_data_bits(work)))
+			cpu_relax();
 		work_clear_pending(work);
 		lock_map_acquire(&cwq->wq->lockdep_map);
 		lock_map_acquire(&lockdep_map);
 		f(work);
+		clear_bit(WORK_STRUCT_RUNNING, work_data_bits(work));
 		lock_map_release(&lockdep_map);
 		lock_map_release(&cwq->wq->lockdep_map);
 

