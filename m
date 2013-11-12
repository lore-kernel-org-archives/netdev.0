From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] ipvs: Remove unused variable ret from
 sync_thread_master()
Date: Tue, 12 Nov 2013 15:52:43 +0100
Message-ID: <20131112145243.GU5056@laptop.programming.kicks-ass.net>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org>
 <20131112141314.GQ5056@laptop.programming.kicks-ass.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 02:21:39PM -0000, David Laight wrote:
> Shame there isn't a process flag to indicate that the process
> will sleep uninterruptibly and that it doesn't matter.
> So don't count to the load average and don't emit a warning
> if it has been sleeping for a long time.

A process flag wouldn't work, because the task could block waiting for
actual work to complete in other sleeps.

However, we could do something like the below; which would allow us
writing things like:

	(void)___wait_event(*sk_sleep(sk),
			    sock_writeable(sk) || kthread_should_stop(),
			    TASK_UNINTERRUPTIBLE | TASK_IDLE, 0, 0,
			    schedule());

Marking the one wait-for-more-work as TASK_IDLE such that it doesn't
contribute to the load avg.

---
 fs/proc/array.c              | 23 ++++++++++++-----------
 include/linux/sched.h        |  8 +++++---
 include/trace/events/sched.h |  3 ++-
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 1bd2077187fd..da9a9c8b5bba 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -133,17 +133,18 @@ static inline void task_name(struct seq_file *m, struct task_struct *p)
  * simple bit tests.
  */
 static const char * const task_state_array[] = {
-	"R (running)",		/*   0 */
-	"S (sleeping)",		/*   1 */
-	"D (disk sleep)",	/*   2 */
-	"T (stopped)",		/*   4 */
-	"t (tracing stop)",	/*   8 */
-	"Z (zombie)",		/*  16 */
-	"X (dead)",		/*  32 */
-	"x (dead)",		/*  64 */
-	"K (wakekill)",		/* 128 */
-	"W (waking)",		/* 256 */
-	"P (parked)",		/* 512 */
+	"R (running)",		/*    0 */
+	"S (sleeping)",		/*    1 */
+	"D (disk sleep)",	/*    2 */
+	"T (stopped)",		/*    4 */
+	"t (tracing stop)",	/*    8 */
+	"Z (zombie)",		/*   16 */
+	"X (dead)",		/*   32 */
+	"x (dead)",		/*   64 */
+	"K (wakekill)",		/*  128 */
+	"W (waking)",		/*  256 */
+	"P (parked)",		/*  512 */
+	"I (idle)",		/* 1024 */
 };
 
 static inline const char *get_task_state(struct task_struct *tsk)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 045b0d227846..a4a9e80688d8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -145,9 +145,10 @@ print_cfs_rq(struct seq_file *m, int cpu, struct cfs_rq *cfs_rq);
 #define TASK_WAKEKILL		128
 #define TASK_WAKING		256
 #define TASK_PARKED		512
-#define TASK_STATE_MAX		1024
+#define TASK_IDLE		1024
+#define TASK_STATE_MAX		2048
 
-#define TASK_STATE_TO_CHAR_STR "RSDTtZXxKWP"
+#define TASK_STATE_TO_CHAR_STR "RSDTtZXxKWPI"
 
 extern char ___assert_task_state[1 - 2*!!(
 		sizeof(TASK_STATE_TO_CHAR_STR)-1 != ilog2(TASK_STATE_MAX)+1)];
@@ -173,7 +174,8 @@ extern char ___assert_task_state[1 - 2*!!(
 			((task->state & (__TASK_STOPPED | __TASK_TRACED)) != 0)
 #define task_contributes_to_load(task)	\
 				((task->state & TASK_UNINTERRUPTIBLE) != 0 && \
-				 (task->flags & PF_FROZEN) == 0)
+				 (task->flags & PF_FROZEN) == 0 && \
+				 (task->state & TASK_IDLE) == 0)
 
 #define __set_task_state(tsk, state_value)		\
 	do { (tsk)->state = (state_value); } while (0)
diff --git a/include/trace/events/sched.h b/include/trace/events/sched.h
index 04c308413a5d..4553a2495c25 100644
--- a/include/trace/events/sched.h
+++ b/include/trace/events/sched.h
@@ -144,7 +144,8 @@ TRACE_EVENT(sched_switch,
 		  __print_flags(__entry->prev_state & (TASK_STATE_MAX-1), "|",
 				{ 1, "S"} , { 2, "D" }, { 4, "T" }, { 8, "t" },
 				{ 16, "Z" }, { 32, "X" }, { 64, "x" },
-				{ 128, "K" }, { 256, "W" }, { 512, "P" }) : "R",
+				{ 128, "K" }, { 256, "W" }, { 512, "P" },
+				{ 1024, "I" }) : "R",
 		__entry->prev_state & TASK_STATE_MAX ? "+" : "",
 		__entry->next_comm, __entry->next_pid, __entry->next_prio)
 );
