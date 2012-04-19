From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 1/2] workqueue: Catch more locking problems with flush_work()
Date: Wed, 18 Apr 2012 20:25:57 -0700
Message-ID: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org>
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a workqueue is flushed but the work item is not scheduled to
run, lockdep checking will be circumvented. For example:

 static DEFINE_MUTEX(mutex);

 static void my_work(struct work_struct *w)
 {
         mutex_lock(&mutex);
         mutex_unlock(&mutex);
 }

 static DECLARE_WORK(work, my_work);

 static int __init start_test_module(void)
 {
         schedule_work(&work);
         return 0;
 }
 module_init(start_test_module);

 static void __exit stop_test_module(void)
 {
         mutex_lock(&mutex);
         flush_work(&work);
         mutex_unlock(&mutex);
 }
 module_exit(stop_test_module);

would only print a warning if the work item was actively running
when flush_work() was called. Otherwise flush_work() returns
early. In this trivial example nothing could go wrong, but if the
work item is schedule via an interrupt we could potentially have a
scenario where the work item is running just at the time flush_work()
is called. This could become a classic AB-BA locking problem.

Add a lockdep hint in flush_work() in the "work not running" case
so that we always catch this potential deadlock scenario.

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 kernel/workqueue.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 66ec08d..eb800df 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2513,8 +2513,11 @@ bool flush_work(struct work_struct *work)
 		wait_for_completion(&barr.done);
 		destroy_work_on_stack(&barr.work);
 		return true;
-	} else
+	} else {
+		lock_map_acquire(&work->lockdep_map);
+		lock_map_release(&work->lockdep_map);
 		return false;
+	}
 }
 EXPORT_SYMBOL_GPL(flush_work);
 
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
