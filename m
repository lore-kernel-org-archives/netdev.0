From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCHv2] workqueue: Catch more locking problems with flush_work()
Date: Fri, 20 Apr 2012 17:28:50 -0700
Message-ID: <1334968130-20724-1-git-send-email-sboyd@codeaurora.org>
References: <20120420173529.GD32324@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>,
	Yong Zhang <yong.zhang0@gmail.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120420173529.GD32324@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a workqueue is flushed with flush_work() lockdep checking can
be circumvented. For example:

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

would not always print a warning when flush_work() was called.
In this trivial example nothing could go wrong since we are
guaranteed module_init() and module_exit() don't run concurrently,
but if the work item is schedule asynchronously we could have a
scenario where the work item is running just at the time flush_work()
is called resulting in a classic ABBA locking problem.

Add a lockdep hint by acquiring and releasing the work item
lockdep_map in flush_work() so that we always catch this
potential deadlock scenario.

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 kernel/workqueue.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 5abf42f..038cf64 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2506,6 +2506,9 @@ bool flush_work(struct work_struct *work)
 {
 	struct wq_barrier barr;
 
+	lock_map_acquire(&work->lockdep_map);
+	lock_map_release(&work->lockdep_map);
+
 	if (start_flush_work(work, &barr, true)) {
 		wait_for_completion(&barr.done);
 		destroy_work_on_stack(&barr.work);
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
