From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] Bluetooth: Revert "Bluetooth: rfcomm: Remove unnecessary krfcommd event"
Date: Wed, 29 Oct 2014 21:32:16 -0400
Message-ID: <1414632736-18782-1-git-send-email-sasha.levin@oracle.com>
Cc: peter@hurleysoftware.com, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit e5842cdb0f4f2c68f6acd39e286e5d10d8c073e8.

We can't call rfcomm_process_sessions() while our task state is not
TASK_RUNNING since rfcomm_process_sessions() tries to lock mutexes
and sleep. The scheduler even complains about it:

[   21.683959] WARNING: CPU: 13 PID: 8165 at kernel/sched/core.c:7305 __might_sleep+0xe5/0x1b0()
[   21.683962] do not call blocking ops when !TASK_RUNNING; state=1 set at rfcomm_run (net/bluetooth/rfcomm/core.c:2096)
[   21.683963] Modules linked in:
[   21.683966] CPU: 13 PID: 8165 Comm: krfcommd Tainted: G        W      3.18.0-rc2-next-20141029-sasha-00035-gd14bbcb-dirty #1425
[   21.683969]  ffffffffae2b4d0e 0000000000000000 ffff8805c0b23c00 ffff8805c0b23b98
[   21.683972]  ffffffffad010b76 0000000000000000 ffff8805c0b23bf8 ffff8805c0b23be8
[   21.683975]  ffffffffa3298dd8 ffffffffad0a0910 ffffffffa3309f95 ffff8805c0b23bc8
[   21.683976] Call Trace:
[   21.683979] dump_stack (lib/dump_stack.c:52)
[   21.683982] warn_slowpath_common (kernel/panic.c:432)
[   21.683985] ? __schedule (kernel/sched/core.c:2840)
[   21.683987] ? __might_sleep (kernel/sched/core.c:7311)
[   21.683990] warn_slowpath_fmt (kernel/panic.c:446)
[   21.683993] ? rfcomm_run (net/bluetooth/rfcomm/core.c:2096)
[   21.683996] ? rfcomm_run (net/bluetooth/rfcomm/core.c:2096)
[   21.683999] __might_sleep (kernel/sched/core.c:7311)
[   21.684002] mutex_lock_nested (kernel/locking/mutex.c:508 kernel/locking/mutex.c:622)
[   21.684004] ? __schedule (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 include/linux/sched.h:2937 kernel/sched/core.c:2845)
[   21.684008] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[   21.684011] rfcomm_run (net/bluetooth/rfcomm/core.c:1990 net/bluetooth/rfcomm/core.c:2102)
[   21.684014] ? preempt_count_sub (kernel/sched/core.c:2641)
[   21.684017] ? __schedule (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 include/linux/sched.h:2937 kernel/sched/core.c:2845)
[   21.684020] ? rfcomm_process_rx (net/bluetooth/rfcomm/core.c:2088)
[   21.684023] ? rfcomm_process_rx (net/bluetooth/rfcomm/core.c:2088)
[   21.684025] kthread (kernel/kthread.c:207)
[   21.684029] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2559 kernel/locking/lockdep.c:2601)
[   21.684032] ? flush_kthread_work (kernel/kthread.c:176)
[   21.684035] ret_from_fork (arch/x86/kernel/entry_64.S:348)
[   21.684038] ? flush_kthread_work (kernel/kthread.c:176)

Instead, just go to the old way oftracking wakeups.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/bluetooth/rfcomm/core.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index bce9c3d..942de7765 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -48,6 +48,7 @@ static DEFINE_MUTEX(rfcomm_mutex);
 #define rfcomm_lock()	mutex_lock(&rfcomm_mutex)
 #define rfcomm_unlock()	mutex_unlock(&rfcomm_mutex)
 
+static unsigned long rfcomm_event;
 
 static LIST_HEAD(session_list);
 
@@ -105,6 +106,7 @@ static void rfcomm_schedule(void)
 {
 	if (!rfcomm_thread)
 		return;
+	set_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event);
 	wake_up_process(rfcomm_thread);
 }
 
@@ -2092,18 +2094,19 @@ static int rfcomm_run(void *unused)
 
 	rfcomm_add_listener(BDADDR_ANY);
 
-	while (1) {
+	while (!kthread_should_stop()) {
 		set_current_state(TASK_INTERRUPTIBLE);
-
-		if (kthread_should_stop())
-			break;
+		if (!test_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event)) {
+			/* No pending events. Let's sleep.
+			 * Incoming connections and data will wake us up. */
+			schedule();
+		}
+		set_current_state(TASK_RUNNING);
 
 		/* Process stuff */
+		clear_bit(RFCOMM_SCHED_WAKEUP, &rfcomm_event);
 		rfcomm_process_sessions();
-
-		schedule();
 	}
-	__set_current_state(TASK_RUNNING);
 
 	rfcomm_kill_listener();
 
-- 
1.7.10.4
