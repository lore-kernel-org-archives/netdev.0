From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v3 4/4] posix-timers: make it configurable
Date: Mon,  7 Nov 2016 17:14:59 -0500
Message-ID: <1478556899-2951-5-git-send-email-nicolas.pitre@linaro.org>
References: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Paul Bolle <pebolle@tiscali.nl>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478556899-2951-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some embedded systems have no use for them.  This removes about
22KB from the kernel binary size when configured out.

Corresponding syscalls are routed to a stub logging the attempt to
use those syscalls which should be enough of a clue if they were
disabled without proper consideration. They are: timer_create,
timer_gettime: timer_getoverrun, timer_settime, timer_delete,
clock_adjtime.

The clock_settime, clock_gettime, clock_getres and clock_nanosleep
syscalls are replaced by simple wrappers compatible with CLOCK_REALTIME,
CLOCK_MONOTONIC and CLOCK_BOOTTIME only which should cover the vast
majority of use cases with very little code.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/Kconfig          |   2 +-
 include/linux/posix-timers.h |  28 +++++++++-
 include/linux/sched.h        |  10 ++++
 init/Kconfig                 |  17 +++++++
 kernel/signal.c              |   4 ++
 kernel/time/Makefile         |  10 +++-
 kernel/time/posix-stubs.c    | 118 +++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 184 insertions(+), 5 deletions(-)
 create mode 100644 kernel/time/posix-stubs.c

diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 0f7492f8ea..bdce332911 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -6,7 +6,7 @@ menu "PTP clock support"
 
 config PTP_1588_CLOCK
 	tristate "PTP clock support"
-	depends on NET
+	depends on NET && POSIX_TIMERS
 	select PPS
 	select NET_PTP_CLASSIFY
 	help
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 62d44c1760..2288c5c557 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -118,6 +118,8 @@ struct k_clock {
 extern struct k_clock clock_posix_cpu;
 extern struct k_clock clock_posix_dynamic;
 
+#ifdef CONFIG_POSIX_TIMERS
+
 void posix_timers_register_clock(const clockid_t clock_id, struct k_clock *new_clock);
 
 /* function to call to trigger timer event */
@@ -131,8 +133,30 @@ void posix_cpu_timers_exit_group(struct task_struct *task);
 void set_process_cpu_timer(struct task_struct *task, unsigned int clock_idx,
 			   cputime_t *newval, cputime_t *oldval);
 
-long clock_nanosleep_restart(struct restart_block *restart_block);
-
 void update_rlimit_cpu(struct task_struct *task, unsigned long rlim_new);
 
+#else
+
+#include <linux/random.h>
+
+static inline void posix_timers_register_clock(const clockid_t clock_id,
+					       struct k_clock *new_clock) {}
+static inline int posix_timer_event(struct k_itimer *timr, int si_private)
+{ return 0; }
+static inline void run_posix_cpu_timers(struct task_struct *task) {}
+static inline void posix_cpu_timers_exit(struct task_struct *task)
+{
+	add_device_randomness((const void*) &task->se.sum_exec_runtime,
+			      sizeof(unsigned long long));
+}
+static inline void posix_cpu_timers_exit_group(struct task_struct *task) {}
+static inline void set_process_cpu_timer(struct task_struct *task,
+		unsigned int clock_idx, cputime_t *newval, cputime_t *oldval) {}
+static inline void update_rlimit_cpu(struct task_struct *task,
+				     unsigned long rlim_new) {}
+
+#endif
+
+long clock_nanosleep_restart(struct restart_block *restart_block);
+
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 348f51b0ec..ad716d5559 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2946,8 +2946,13 @@ static inline void exit_thread(struct task_struct *tsk)
 extern void exit_files(struct task_struct *);
 extern void __cleanup_sighand(struct sighand_struct *);
 
+#ifdef CONFIG_POSIX_TIMERS
 extern void exit_itimers(struct signal_struct *);
 extern void flush_itimer_signals(void);
+#else
+static inline void exit_itimers(struct signal_struct *s) {}
+static inline void flush_itimer_signals(void) {}
+#endif
 
 extern void do_group_exit(int);
 
@@ -3450,7 +3455,12 @@ static __always_inline bool need_resched(void)
  * Thread group CPU time accounting.
  */
 void thread_group_cputime(struct task_struct *tsk, struct task_cputime *times);
+#ifdef CONFIG_POSIX_TIMERS
 void thread_group_cputimer(struct task_struct *tsk, struct task_cputime *times);
+#else
+static inline void thread_group_cputimer(struct task_struct *tsk,
+					 struct task_cputime *times) {}
+#endif
 
 /*
  * Reevaluate whether the task has signals pending delivery.
diff --git a/init/Kconfig b/init/Kconfig
index 34407f15e6..f430f776e8 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1445,6 +1445,23 @@ config SYSCTL_SYSCALL
 
 	  If unsure say N here.
 
+config POSIX_TIMERS
+	bool "Posix Clocks & timers" if EXPERT
+	default y
+	help
+	  This includes native support for POSIX timers to the kernel.
+	  Some embedded systems have no use for them and therefore they
+	  can be configured out to reduce the size of the kernel image.
+
+	  When this option is disabled, the following syscalls won't be
+	  available: timer_create, timer_gettime: timer_getoverrun,
+	  timer_settime, timer_delete, clock_adjtime. Furthermore, the
+	  clock_settime, clock_gettime, clock_getres and clock_nanosleep
+	  syscalls will be limited to CLOCK_REALTIME and CLOCK_MONOTONIC
+	  only.
+
+	  If unsure say y.
+
 config KALLSYMS
 	 bool "Load all symbols for debugging/ksymoops" if EXPERT
 	 default y
diff --git a/kernel/signal.c b/kernel/signal.c
index 75761acc77..0a38c9d646 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -427,6 +427,7 @@ void flush_signals(struct task_struct *t)
 	spin_unlock_irqrestore(&t->sighand->siglock, flags);
 }
 
+#ifdef CONFIG_POSIX_TIMERS
 static void __flush_itimer_signals(struct sigpending *pending)
 {
 	sigset_t signal, retain;
@@ -460,6 +461,7 @@ void flush_itimer_signals(void)
 	__flush_itimer_signals(&tsk->signal->shared_pending);
 	spin_unlock_irqrestore(&tsk->sighand->siglock, flags);
 }
+#endif
 
 void ignore_signals(struct task_struct *t)
 {
@@ -611,6 +613,7 @@ int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
 		 */
 		current->jobctl |= JOBCTL_STOP_DEQUEUED;
 	}
+#ifdef CONFIG_POSIX_TIMERS
 	if ((info->si_code & __SI_MASK) == __SI_TIMER && info->si_sys_private) {
 		/*
 		 * Release the siglock to ensure proper locking order
@@ -622,6 +625,7 @@ int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
 		do_schedule_next_timer(info);
 		spin_lock(&tsk->sighand->siglock);
 	}
+#endif
 	return signr;
 }
 
diff --git a/kernel/time/Makefile b/kernel/time/Makefile
index 49eca0beed..fc26c308f5 100644
--- a/kernel/time/Makefile
+++ b/kernel/time/Makefile
@@ -1,6 +1,12 @@
-obj-y += time.o timer.o hrtimer.o itimer.o posix-timers.o posix-cpu-timers.o
+obj-y += time.o timer.o hrtimer.o itimer.o
 obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o
-obj-y += timeconv.o timecounter.o posix-clock.o alarmtimer.o
+obj-y += timeconv.o timecounter.o alarmtimer.o
+
+ifeq ($(CONFIG_POSIX_TIMERS),y)
+ obj-y += posix-timers.o posix-cpu-timers.o posix-clock.o
+else
+ obj-y += posix-stubs.o
+endif
 
 obj-$(CONFIG_GENERIC_CLOCKEVENTS)		+= clockevents.o tick-common.o
 ifeq ($(CONFIG_GENERIC_CLOCKEVENTS_BROADCAST),y)
diff --git a/kernel/time/posix-stubs.c b/kernel/time/posix-stubs.c
new file mode 100644
index 0000000000..fe857bd4a0
--- /dev/null
+++ b/kernel/time/posix-stubs.c
@@ -0,0 +1,118 @@
+/*
+ * Dummy stubs used when CONFIG_POSIX_TIMERS=n
+ *
+ * Created by:  Nicolas Pitre, July 2016
+ * Copyright:   (C) 2016 Linaro Limited
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/linkage.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/errno.h>
+#include <linux/syscalls.h>
+#include <linux/ktime.h>
+#include <linux/timekeeping.h>
+#include <linux/posix-timers.h>
+
+asmlinkage long sys_ni_posix_timers(void)
+{
+	pr_err_once("process %d (%s) attempted a POSIX timer syscall "
+		    "while CONFIG_POSIX_TIMERS is not set\n",
+		    current->pid, current->comm);
+	return -ENOSYS;
+}
+
+#define SYS_NI(name)  SYSCALL_ALIAS(sys_##name, sys_ni_posix_timers)
+
+SYS_NI(timer_create);
+SYS_NI(timer_gettime);
+SYS_NI(timer_getoverrun);
+SYS_NI(timer_settime);
+SYS_NI(timer_delete);
+SYS_NI(clock_adjtime);
+
+/*
+ * We preserve minimal support for CLOCK_REALTIME and CLOCK_MONOTONIC
+ * as it is easy to remain compatible with little code. CLOCK_BOOTTIME
+ * is also included for convenience as at least systemd uses it.
+ */
+
+SYSCALL_DEFINE2(clock_settime, const clockid_t, which_clock,
+		const struct timespec __user *, tp)
+{
+	struct timespec new_tp;
+
+	if (which_clock != CLOCK_REALTIME)
+		return -EINVAL;
+	if (copy_from_user(&new_tp, tp, sizeof (*tp)))
+		return -EFAULT;
+	return do_sys_settimeofday(&new_tp, NULL);
+}
+
+SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
+		struct timespec __user *,tp)
+{
+	struct timespec kernel_tp;
+
+	switch (which_clock) {
+	case CLOCK_REALTIME: ktime_get_real_ts(&kernel_tp); break;
+	case CLOCK_MONOTONIC: ktime_get_ts(&kernel_tp); break;
+	case CLOCK_BOOTTIME: get_monotonic_boottime(&kernel_tp); break;
+	default: return -EINVAL;
+	}
+	if (copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
+		return -EFAULT;
+	return 0;
+}
+
+SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock, struct timespec __user *, tp)
+{
+	struct timespec rtn_tp = {
+		.tv_sec = 0,
+		.tv_nsec = hrtimer_resolution,
+	};
+
+	switch (which_clock) {
+	case CLOCK_REALTIME:
+	case CLOCK_MONOTONIC:
+	case CLOCK_BOOTTIME:
+		if (copy_to_user(tp, &rtn_tp, sizeof(rtn_tp)))
+			return -EFAULT;
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
+SYSCALL_DEFINE4(clock_nanosleep, const clockid_t, which_clock, int, flags,
+		const struct timespec __user *, rqtp,
+		struct timespec __user *, rmtp)
+{
+	struct timespec t;
+
+	switch (which_clock) {
+	case CLOCK_REALTIME:
+	case CLOCK_MONOTONIC:
+	case CLOCK_BOOTTIME:
+		if (copy_from_user(&t, rqtp, sizeof (struct timespec)))
+			return -EFAULT;
+		if (!timespec_valid(&t))
+			return -EINVAL;
+		return hrtimer_nanosleep(&t, rmtp, flags & TIMER_ABSTIME ?
+					 HRTIMER_MODE_ABS : HRTIMER_MODE_REL,
+					 which_clock);
+	default:
+		return -EINVAL;
+	}
+}
+
+#ifdef CONFIG_COMPAT
+long clock_nanosleep_restart(struct restart_block *restart_block)
+{
+	return hrtimer_nanosleep_restart(restart_block);
+}
+#endif
-- 
2.7.4
