From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v4 5/6] posix_cpu_timers_exit: wrong place to collect entropy
Date: Fri, 11 Nov 2016 00:10:09 -0500
Message-ID: <1478841010-28605-6-git-send-email-nicolas.pitre@linaro.org>
References: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478841010-28605-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no logical relation between add_device_randomness() and
posix_cpu_timers_exit(). Let's move the former to where the later
is called. This way, when posix-cpu-timers.c is compiled out, there
is no need to worry about not losing a call to add_device_randomness().

Signed-off-by: Nicolas Pitre <nico@linaro.org>
---
 kernel/exit.c                  | 4 ++++
 kernel/time/posix-cpu-timers.c | 4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 9d68c45ebb..d16bcdd89d 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -54,6 +54,7 @@
 #include <linux/writeback.h>
 #include <linux/shm.h>
 #include <linux/kcov.h>
+#include <linux/random.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -116,6 +117,9 @@ static void __exit_signal(struct task_struct *tsk)
 			sig->curr_target = next_thread(tsk);
 	}
 
+	add_device_randomness((const void*) &tsk->se.sum_exec_runtime,
+			      sizeof(unsigned long long));
+
 	/*
 	 * Accumulate here the counters for all threads as they die. We could
 	 * skip the group leader because it is the last user of signal_struct,
diff --git a/kernel/time/posix-cpu-timers.c b/kernel/time/posix-cpu-timers.c
index 39008d7892..e582f20f47 100644
--- a/kernel/time/posix-cpu-timers.c
+++ b/kernel/time/posix-cpu-timers.c
@@ -9,7 +9,6 @@
 #include <asm/uaccess.h>
 #include <linux/kernel_stat.h>
 #include <trace/events/timer.h>
-#include <linux/random.h>
 #include <linux/tick.h>
 #include <linux/workqueue.h>
 
@@ -447,10 +446,7 @@ static void cleanup_timers(struct list_head *head)
  */
 void posix_cpu_timers_exit(struct task_struct *tsk)
 {
-	add_device_randomness((const void*) &tsk->se.sum_exec_runtime,
-						sizeof(unsigned long long));
 	cleanup_timers(tsk->cpu_timers);
-
 }
 void posix_cpu_timers_exit_group(struct task_struct *tsk)
 {
-- 
2.7.4
