From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v4 6/6] posix-timers: make it configurable
Date: Fri, 11 Nov 2016 00:10:10 -0500
Message-ID: <1478841010-28605-7-git-send-email-nicolas.pitre@linaro.org>
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

Some embedded systems have no use for them.  This removes about
25KB from the kernel binary size when configured out.

Corresponding syscalls are routed to a stub logging the attempt to
use those syscalls which should be enough of a clue if they were
disabled without proper consideration. They are: timer_create,
timer_gettime: timer_getoverrun, timer_settime, timer_delete,
clock_adjtime, setitimer, getitimer, alarm.

The clock_settime, clock_gettime, clock_getres and clock_nanosleep
syscalls are replaced by simple wrappers compatible with CLOCK_REALTIME,
CLOCK_MONOTONIC and CLOCK_BOOTTIME only which should cover the vast
majority of use cases with very little code.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/alpha/kernel/osf_sys.c |   8 +++
 drivers/char/Kconfig        |   1 +
 drivers/ptp/Kconfig         |   2 +-
 fs/exec.c                   |   2 +
 init/Kconfig                |  17 ++++++
 kernel/compat.c             |   8 +++
 kernel/exit.c               |  11 +++-
 kernel/fork.c               |   2 +
 kernel/signal.c             |   6 +++
 kernel/sys.c                |   3 +-
 kernel/time/Makefile        |  10 +++-
 kernel/time/alarmtimer.c    |   6 ++-
 kernel/time/posix-stubs.c   | 123 ++++++++++++++++++++++++++++++++++++++++++++
 kernel/time/timer.c         |   3 +-
 security/selinux/hooks.c    |  11 ++--
 15 files changed, 200 insertions(+), 13 deletions(-)
 create mode 100644 kernel/time/posix-stubs.c

diff --git a/arch/alpha/kernel/osf_sys.c b/arch/alpha/kernel/osf_sys.c
index ffb93f499c..56e427c7aa 100644
--- a/arch/alpha/kernel/osf_sys.c
+++ b/arch/alpha/kernel/osf_sys.c
@@ -1029,11 +1029,16 @@ SYSCALL_DEFINE2(osf_settimeofday, struct timeval32 __user *, tv,
 	return do_sys_settimeofday(tv ? &kts : NULL, tz ? &ktz : NULL);
 }
 
+asmlinkage long sys_ni_posix_timers(void);
+
 SYSCALL_DEFINE2(osf_getitimer, int, which, struct itimerval32 __user *, it)
 {
 	struct itimerval kit;
 	int error;
 
+	if (!IS_ENABLED(CONFIG_POSIX_TIMERS))
+		return sys_ni_posix_timers();
+
 	error = do_getitimer(which, &kit);
 	if (!error && put_it32(it, &kit))
 		error = -EFAULT;
@@ -1047,6 +1052,9 @@ SYSCALL_DEFINE3(osf_setitimer, int, which, struct itimerval32 __user *, in,
 	struct itimerval kin, kout;
 	int error;
 
+	if (!IS_ENABLED(CONFIG_POSIX_TIMERS))
+		return sys_ni_posix_timers();
+
 	if (in) {
 		if (get_it32(&kin, in))
 			return -EFAULT;
diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index dcc09739a5..45ba878ae0 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -542,6 +542,7 @@ config HANGCHECK_TIMER
 config MMTIMER
 	tristate "MMTIMER Memory mapped RTC for SGI Altix"
 	depends on IA64_GENERIC || IA64_SGI_SN2
+	depends on POSIX_TIMERS
 	default y
 	help
 	  The mmtimer device allows direct userspace access to the
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
diff --git a/fs/exec.c b/fs/exec.c
index 6fcfb3f7b1..a67a172332 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1164,8 +1164,10 @@ static int de_thread(struct task_struct *tsk)
 	/* we have changed execution domain */
 	tsk->exit_signal = SIGCHLD;
 
+#ifdef CONFIG_POSIX_TIMERS
 	exit_itimers(sig);
 	flush_itimer_signals();
+#endif
 
 	if (atomic_read(&oldsighand->count) != 1) {
 		struct sighand_struct *newsighand;
diff --git a/init/Kconfig b/init/Kconfig
index 34407f15e6..456e0b8912 100644
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
+	  timer_settime, timer_delete, clock_adjtime, getitimer,
+	  setitimer, alarm. Furthermore, the clock_settime, clock_gettime,
+	  clock_getres and clock_nanosleep syscalls will be limited to
+	  CLOCK_REALTIME, CLOCK_MONOTONIC and CLOCK_BOOTTIME only.
+
+	  If unsure say y.
+
 config KALLSYMS
 	 bool "Load all symbols for debugging/ksymoops" if EXPERT
 	 default y
diff --git a/kernel/compat.c b/kernel/compat.c
index 333d364be2..b3a047f208 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -307,12 +307,17 @@ static inline long put_compat_itimerval(struct compat_itimerval __user *o,
 		 __put_user(i->it_value.tv_usec, &o->it_value.tv_usec)));
 }
 
+asmlinkage long sys_ni_posix_timers(void);
+
 COMPAT_SYSCALL_DEFINE2(getitimer, int, which,
 		struct compat_itimerval __user *, it)
 {
 	struct itimerval kit;
 	int error;
 
+	if (!IS_ENABLED(CONFIG_POSIX_TIMERS))
+		return sys_ni_posix_timers();
+
 	error = do_getitimer(which, &kit);
 	if (!error && put_compat_itimerval(it, &kit))
 		error = -EFAULT;
@@ -326,6 +331,9 @@ COMPAT_SYSCALL_DEFINE3(setitimer, int, which,
 	struct itimerval kin, kout;
 	int error;
 
+	if (!IS_ENABLED(CONFIG_POSIX_TIMERS))
+		return sys_ni_posix_timers();
+
 	if (in) {
 		if (get_compat_itimerval(&kin, in))
 			return -EFAULT;
diff --git a/kernel/exit.c b/kernel/exit.c
index d16bcdd89d..684de019b6 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -92,11 +92,10 @@ static void __exit_signal(struct task_struct *tsk)
 					lockdep_tasklist_lock_is_held());
 	spin_lock(&sighand->siglock);
 
+#ifdef CONFIG_POSIX_TIMERS
 	posix_cpu_timers_exit(tsk);
 	if (group_dead) {
 		posix_cpu_timers_exit_group(tsk);
-		tty = sig->tty;
-		sig->tty = NULL;
 	} else {
 		/*
 		 * This can only happen if the caller is de_thread().
@@ -105,7 +104,13 @@ static void __exit_signal(struct task_struct *tsk)
 		 */
 		if (unlikely(has_group_leader_pid(tsk)))
 			posix_cpu_timers_exit_group(tsk);
+	}
+#endif
 
+	if (group_dead) {
+		tty = sig->tty;
+		sig->tty = NULL;
+	} else {
 		/*
 		 * If there is any task waiting for the group exit
 		 * then notify it:
@@ -803,8 +808,10 @@ void __noreturn do_exit(long code)
 	acct_update_integrals(tsk);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
+#ifdef CONFIG_POSIX_TIMERS
 		hrtimer_cancel(&tsk->signal->real_timer);
 		exit_itimers(tsk->signal);
+#endif
 		if (tsk->mm)
 			setmax_mm_hiwater_rss(&tsk->signal->maxrss, tsk->mm);
 	}
diff --git a/kernel/fork.c b/kernel/fork.c
index 623259fc79..17da35fa77 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1342,8 +1342,10 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	seqlock_init(&sig->stats_lock);
 	prev_cputime_init(&sig->prev_cputime);
 
+#ifdef CONFIG_POSIX_TIMERS
 	hrtimer_init(&sig->real_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 	sig->real_timer.function = it_real_fn;
+#endif
 
 	task_lock(current->group_leader);
 	memcpy(sig->rlim, current->signal->rlim, sizeof sig->rlim);
diff --git a/kernel/signal.c b/kernel/signal.c
index 75761acc77..29a410780a 100644
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
@@ -567,6 +569,7 @@ int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
 	if (!signr) {
 		signr = __dequeue_signal(&tsk->signal->shared_pending,
 					 mask, info);
+#ifdef CONFIG_POSIX_TIMERS
 		/*
 		 * itimer signal ?
 		 *
@@ -590,6 +593,7 @@ int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
 				hrtimer_restart(tmr);
 			}
 		}
+#endif
 	}
 
 	recalc_sigpending();
@@ -611,6 +615,7 @@ int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
 		 */
 		current->jobctl |= JOBCTL_STOP_DEQUEUED;
 	}
+#ifdef CONFIG_POSIX_TIMERS
 	if ((info->si_code & __SI_MASK) == __SI_TIMER && info->si_sys_private) {
 		/*
 		 * Release the siglock to ensure proper locking order
@@ -622,6 +627,7 @@ int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
 		do_schedule_next_timer(info);
 		spin_lock(&tsk->sighand->siglock);
 	}
+#endif
 	return signr;
 }
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 89d5be4181..78c9fb7dd6 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1416,7 +1416,8 @@ int do_prlimit(struct task_struct *tsk, unsigned int resource,
 	 * applications, so we live with it
 	 */
 	 if (!retval && new_rlim && resource == RLIMIT_CPU &&
-			 new_rlim->rlim_cur != RLIM_INFINITY)
+	     new_rlim->rlim_cur != RLIM_INFINITY &&
+	     IS_ENABLED(CONFIG_POSIX_TIMERS))
 		update_rlimit_cpu(tsk, new_rlim->rlim_cur);
 out:
 	read_unlock(&tasklist_lock);
diff --git a/kernel/time/Makefile b/kernel/time/Makefile
index 49eca0beed..976840d29a 100644
--- a/kernel/time/Makefile
+++ b/kernel/time/Makefile
@@ -1,6 +1,12 @@
-obj-y += time.o timer.o hrtimer.o itimer.o posix-timers.o posix-cpu-timers.o
+obj-y += time.o timer.o hrtimer.o
 obj-y += timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o
-obj-y += timeconv.o timecounter.o posix-clock.o alarmtimer.o
+obj-y += timeconv.o timecounter.o alarmtimer.o
+
+ifeq ($(CONFIG_POSIX_TIMERS),y)
+ obj-y += posix-timers.o posix-cpu-timers.o posix-clock.o itimer.o
+else
+ obj-y += posix-stubs.o
+endif
 
 obj-$(CONFIG_GENERIC_CLOCKEVENTS)		+= clockevents.o tick-common.o
 ifeq ($(CONFIG_GENERIC_CLOCKEVENTS_BROADCAST),y)
diff --git a/kernel/time/alarmtimer.c b/kernel/time/alarmtimer.c
index c3aad685bb..9a878eacf9 100644
--- a/kernel/time/alarmtimer.c
+++ b/kernel/time/alarmtimer.c
@@ -848,8 +848,10 @@ static int __init alarmtimer_init(void)
 
 	alarmtimer_rtc_timer_init();
 
-	posix_timers_register_clock(CLOCK_REALTIME_ALARM, &alarm_clock);
-	posix_timers_register_clock(CLOCK_BOOTTIME_ALARM, &alarm_clock);
+	if (IS_ENABLED(CONFIG_POSIX_TIMERS)) {
+		posix_timers_register_clock(CLOCK_REALTIME_ALARM, &alarm_clock);
+		posix_timers_register_clock(CLOCK_BOOTTIME_ALARM, &alarm_clock);
+	}
 
 	/* Initialize alarm bases */
 	alarm_bases[ALARM_REALTIME].base_clockid = CLOCK_REALTIME;
diff --git a/kernel/time/posix-stubs.c b/kernel/time/posix-stubs.c
new file mode 100644
index 0000000000..cd6716e115
--- /dev/null
+++ b/kernel/time/posix-stubs.c
@@ -0,0 +1,123 @@
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
+SYS_NI(getitimer);
+SYS_NI(setitimer);
+#ifdef __ARCH_WANT_SYS_ALARM
+SYS_NI(alarm);
+#endif
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
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index 3ed6c67e17..099e43311f 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1601,7 +1601,8 @@ void update_process_times(int user_tick)
 		irq_work_tick();
 #endif
 	scheduler_tick();
-	run_posix_cpu_timers(p);
+	if (IS_ENABLED(CONFIG_POSIX_TIMERS))
+		run_posix_cpu_timers(p);
 }
 
 /**
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 0850579362..d769a136ea 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2525,7 +2525,8 @@ static void selinux_bprm_committing_creds(struct linux_binprm *bprm)
 			rlim->rlim_cur = min(rlim->rlim_max, initrlim->rlim_cur);
 		}
 		task_unlock(current);
-		update_rlimit_cpu(current, rlimit(RLIMIT_CPU));
+		if (IS_ENABLED(CONFIG_POSIX_TIMERS))
+			update_rlimit_cpu(current, rlimit(RLIMIT_CPU));
 	}
 }
 
@@ -2555,9 +2556,11 @@ static void selinux_bprm_committed_creds(struct linux_binprm *bprm)
 	 */
 	rc = avc_has_perm(osid, sid, SECCLASS_PROCESS, PROCESS__SIGINH, NULL);
 	if (rc) {
-		memset(&itimer, 0, sizeof itimer);
-		for (i = 0; i < 3; i++)
-			do_setitimer(i, &itimer, NULL);
+		if (IS_ENABLED(CONFIG_POSIX_TIMERS)) {
+			memset(&itimer, 0, sizeof itimer);
+			for (i = 0; i < 3; i++)
+				do_setitimer(i, &itimer, NULL);
+		}
 		spin_lock_irq(&current->sighand->siglock);
 		if (!fatal_signal_pending(current)) {
 			flush_sigqueue(&current->pending);
-- 
2.7.4
