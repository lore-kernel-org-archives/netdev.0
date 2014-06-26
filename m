From: Piotr Wilczek <p.wilczek@samsung.com>
Subject: [PATCH net-next V2 1/2] lib:proc_info:add library to get process
 information
Date: Thu, 26 Jun 2014 14:55:53 +0200
Message-ID: <1403787354-15177-2-git-send-email-p.wilczek@samsung.com>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
Cc: netdev@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>,
	Juho Son <juho80.son@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Jan Kaluza <jkaluza@redhat.com>,
	Piotr Wilczek <p.wilczek@samsung.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:12446 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbaFZM4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 08:56:51 -0400
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N7S00DUO1AOZZ70@mailout1.samsung.com> for
 netdev@vger.kernel.org; Thu, 26 Jun 2014 21:56:48 +0900 (KST)
In-reply-to: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds library to get process information without dependency
on CONFIG_PROC_FS. The new library code is moved from
fs/proc/array.c and fs/proc/task_(no)mmu.c. The functions are modified that
all process information can be retrived with a single process lock improving
performance.

Signed-off-by: Piotr Wilczek <p.wilczek@samsung.com>
---
Changes for v2:
 - new patch with new proc info library

 fs/proc/Kconfig           |   1 +
 fs/proc/array.c           | 476 +-------------------------------
 fs/proc/task_mmu.c        |  66 -----
 fs/proc/task_nommu.c      | 114 --------
 include/linux/proc_info.h |  35 +++
 lib/Kconfig               |   5 +
 lib/Makefile              |   2 +
 lib/proc_info.c           | 686 ++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 738 insertions(+), 647 deletions(-)
 create mode 100644 include/linux/proc_info.h
 create mode 100644 lib/proc_info.c

diff --git a/fs/proc/Kconfig b/fs/proc/Kconfig
index 2183fcf..2e27c48 100644
--- a/fs/proc/Kconfig
+++ b/fs/proc/Kconfig
@@ -1,5 +1,6 @@
 config PROC_FS
 	bool "/proc file system support" if EXPERT
+	select PROC_INFO
 	default y
 	help
 	  This is a virtual file system providing information about the status
diff --git a/fs/proc/array.c b/fs/proc/array.c
index 64db2bc..8be396d 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -72,481 +72,39 @@
 #include <linux/signal.h>
 #include <linux/highmem.h>
 #include <linux/file.h>
-#include <linux/fdtable.h>
 #include <linux/times.h>
 #include <linux/cpuset.h>
 #include <linux/rcupdate.h>
 #include <linux/delayacct.h>
-#include <linux/seq_file.h>
-#include <linux/pid_namespace.h>
 #include <linux/ptrace.h>
 #include <linux/tracehook.h>
-#include <linux/user_namespace.h>
+#include <linux/proc_info.h>
 
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include "internal.h"
 
-static inline void task_name(struct seq_file *m, struct task_struct *p)
-{
-	int i;
-	char *buf, *end;
-	char *name;
-	char tcomm[sizeof(p->comm)];
-
-	get_task_comm(tcomm, p);
-
-	seq_puts(m, "Name:\t");
-	end = m->buf + m->size;
-	buf = m->buf + m->count;
-	name = tcomm;
-	i = sizeof(tcomm);
-	while (i && (buf < end)) {
-		unsigned char c = *name;
-		name++;
-		i--;
-		*buf = c;
-		if (!c)
-			break;
-		if (c == '\\') {
-			buf++;
-			if (buf < end)
-				*buf++ = c;
-			continue;
-		}
-		if (c == '\n') {
-			*buf++ = '\\';
-			if (buf < end)
-				*buf++ = 'n';
-			continue;
-		}
-		buf++;
-	}
-	m->count = buf - m->buf;
-	seq_putc(m, '\n');
-}
-
-/*
- * The task state array is a strange "bitmap" of
- * reasons to sleep. Thus "running" is zero, and
- * you can test for combinations of others with
- * simple bit tests.
- */
-static const char * const task_state_array[] = {
-	"R (running)",		/*   0 */
-	"S (sleeping)",		/*   1 */
-	"D (disk sleep)",	/*   2 */
-	"T (stopped)",		/*   4 */
-	"t (tracing stop)",	/*   8 */
-	"X (dead)",		/*  16 */
-	"Z (zombie)",		/*  32 */
-};
-
-static inline const char *get_task_state(struct task_struct *tsk)
-{
-	unsigned int state = (tsk->state | tsk->exit_state) & TASK_REPORT;
-
-	BUILD_BUG_ON(1 + ilog2(TASK_REPORT) != ARRAY_SIZE(task_state_array)-1);
-
-	return task_state_array[fls(state)];
-}
-
-static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
-				struct pid *pid, struct task_struct *p)
-{
-	struct user_namespace *user_ns = seq_user_ns(m);
-	struct group_info *group_info;
-	int g;
-	struct fdtable *fdt = NULL;
-	const struct cred *cred;
-	pid_t ppid, tpid;
-
-	rcu_read_lock();
-	ppid = pid_alive(p) ?
-		task_tgid_nr_ns(rcu_dereference(p->real_parent), ns) : 0;
-	tpid = 0;
-	if (pid_alive(p)) {
-		struct task_struct *tracer = ptrace_parent(p);
-		if (tracer)
-			tpid = task_pid_nr_ns(tracer, ns);
-	}
-	cred = get_task_cred(p);
-	seq_printf(m,
-		"State:\t%s\n"
-		"Tgid:\t%d\n"
-		"Ngid:\t%d\n"
-		"Pid:\t%d\n"
-		"PPid:\t%d\n"
-		"TracerPid:\t%d\n"
-		"Uid:\t%d\t%d\t%d\t%d\n"
-		"Gid:\t%d\t%d\t%d\t%d\n",
-		get_task_state(p),
-		task_tgid_nr_ns(p, ns),
-		task_numa_group_id(p),
-		pid_nr_ns(pid, ns),
-		ppid, tpid,
-		from_kuid_munged(user_ns, cred->uid),
-		from_kuid_munged(user_ns, cred->euid),
-		from_kuid_munged(user_ns, cred->suid),
-		from_kuid_munged(user_ns, cred->fsuid),
-		from_kgid_munged(user_ns, cred->gid),
-		from_kgid_munged(user_ns, cred->egid),
-		from_kgid_munged(user_ns, cred->sgid),
-		from_kgid_munged(user_ns, cred->fsgid));
-
-	task_lock(p);
-	if (p->files)
-		fdt = files_fdtable(p->files);
-	seq_printf(m,
-		"FDSize:\t%d\n"
-		"Groups:\t",
-		fdt ? fdt->max_fds : 0);
-	rcu_read_unlock();
-
-	group_info = cred->group_info;
-	task_unlock(p);
-
-	for (g = 0; g < group_info->ngroups; g++)
-		seq_printf(m, "%d ",
-			   from_kgid_munged(user_ns, GROUP_AT(group_info, g)));
-	put_cred(cred);
-
-	seq_putc(m, '\n');
-}
-
-void render_sigset_t(struct seq_file *m, const char *header,
-				sigset_t *set)
-{
-	int i;
-
-	seq_puts(m, header);
-
-	i = _NSIG;
-	do {
-		int x = 0;
-
-		i -= 4;
-		if (sigismember(set, i+1)) x |= 1;
-		if (sigismember(set, i+2)) x |= 2;
-		if (sigismember(set, i+3)) x |= 4;
-		if (sigismember(set, i+4)) x |= 8;
-		seq_printf(m, "%x", x);
-	} while (i >= 4);
-
-	seq_putc(m, '\n');
-}
-
-static void collect_sigign_sigcatch(struct task_struct *p, sigset_t *ign,
-				    sigset_t *catch)
-{
-	struct k_sigaction *k;
-	int i;
-
-	k = p->sighand->action;
-	for (i = 1; i <= _NSIG; ++i, ++k) {
-		if (k->sa.sa_handler == SIG_IGN)
-			sigaddset(ign, i);
-		else if (k->sa.sa_handler != SIG_DFL)
-			sigaddset(catch, i);
-	}
-}
-
-static inline void task_sig(struct seq_file *m, struct task_struct *p)
-{
-	unsigned long flags;
-	sigset_t pending, shpending, blocked, ignored, caught;
-	int num_threads = 0;
-	unsigned long qsize = 0;
-	unsigned long qlim = 0;
-
-	sigemptyset(&pending);
-	sigemptyset(&shpending);
-	sigemptyset(&blocked);
-	sigemptyset(&ignored);
-	sigemptyset(&caught);
-
-	if (lock_task_sighand(p, &flags)) {
-		pending = p->pending.signal;
-		shpending = p->signal->shared_pending.signal;
-		blocked = p->blocked;
-		collect_sigign_sigcatch(p, &ignored, &caught);
-		num_threads = get_nr_threads(p);
-		rcu_read_lock();  /* FIXME: is this correct? */
-		qsize = atomic_read(&__task_cred(p)->user->sigpending);
-		rcu_read_unlock();
-		qlim = task_rlimit(p, RLIMIT_SIGPENDING);
-		unlock_task_sighand(p, &flags);
-	}
-
-	seq_printf(m, "Threads:\t%d\n", num_threads);
-	seq_printf(m, "SigQ:\t%lu/%lu\n", qsize, qlim);
-
-	/* render them all */
-	render_sigset_t(m, "SigPnd:\t", &pending);
-	render_sigset_t(m, "ShdPnd:\t", &shpending);
-	render_sigset_t(m, "SigBlk:\t", &blocked);
-	render_sigset_t(m, "SigIgn:\t", &ignored);
-	render_sigset_t(m, "SigCgt:\t", &caught);
-}
-
-static void render_cap_t(struct seq_file *m, const char *header,
-			kernel_cap_t *a)
-{
-	unsigned __capi;
-
-	seq_puts(m, header);
-	CAP_FOR_EACH_U32(__capi) {
-		seq_printf(m, "%08x",
-			   a->cap[(_KERNEL_CAPABILITY_U32S-1) - __capi]);
-	}
-	seq_putc(m, '\n');
-}
-
-/* Remove non-existent capabilities */
-#define NORM_CAPS(v) (v.cap[CAP_TO_INDEX(CAP_LAST_CAP)] &= \
-				CAP_TO_MASK(CAP_LAST_CAP + 1) - 1)
-
-static inline void task_cap(struct seq_file *m, struct task_struct *p)
-{
-	const struct cred *cred;
-	kernel_cap_t cap_inheritable, cap_permitted, cap_effective, cap_bset;
-
-	rcu_read_lock();
-	cred = __task_cred(p);
-	cap_inheritable	= cred->cap_inheritable;
-	cap_permitted	= cred->cap_permitted;
-	cap_effective	= cred->cap_effective;
-	cap_bset	= cred->cap_bset;
-	rcu_read_unlock();
-
-	NORM_CAPS(cap_inheritable);
-	NORM_CAPS(cap_permitted);
-	NORM_CAPS(cap_effective);
-	NORM_CAPS(cap_bset);
-
-	render_cap_t(m, "CapInh:\t", &cap_inheritable);
-	render_cap_t(m, "CapPrm:\t", &cap_permitted);
-	render_cap_t(m, "CapEff:\t", &cap_effective);
-	render_cap_t(m, "CapBnd:\t", &cap_bset);
-}
-
-static inline void task_seccomp(struct seq_file *m, struct task_struct *p)
-{
-#ifdef CONFIG_SECCOMP
-	seq_printf(m, "Seccomp:\t%d\n", p->seccomp.mode);
-#endif
-}
-
-static inline void task_context_switch_counts(struct seq_file *m,
-						struct task_struct *p)
-{
-	seq_printf(m,	"voluntary_ctxt_switches:\t%lu\n"
-			"nonvoluntary_ctxt_switches:\t%lu\n",
-			p->nvcsw,
-			p->nivcsw);
-}
-
-static void task_cpus_allowed(struct seq_file *m, struct task_struct *task)
-{
-	seq_puts(m, "Cpus_allowed:\t");
-	seq_cpumask(m, &task->cpus_allowed);
-	seq_putc(m, '\n');
-	seq_puts(m, "Cpus_allowed_list:\t");
-	seq_cpumask_list(m, &task->cpus_allowed);
-	seq_putc(m, '\n');
-}
-
 int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
 	struct mm_struct *mm = get_task_mm(task);
 
-	task_name(m, task);
-	task_state(m, ns, pid, task);
-
-	if (mm) {
-		task_mem(m, mm);
+	proc_pid_status_mm(m, ns, pid, task, mm);
+	if (mm)
 		mmput(mm);
-	}
-	task_sig(m, task);
-	task_cap(m, task);
-	task_seccomp(m, task);
-	task_cpus_allowed(m, task);
-	cpuset_task_status_allowed(m, task);
-	task_context_switch_counts(m, task);
+
 	return 0;
 }
 
 static int do_task_stat(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task, int whole)
 {
-	unsigned long vsize, eip, esp, wchan = ~0UL;
-	int priority, nice;
-	int tty_pgrp = -1, tty_nr = 0;
-	sigset_t sigign, sigcatch;
-	char state;
-	pid_t ppid = 0, pgid = -1, sid = -1;
-	int num_threads = 0;
-	int permitted;
-	struct mm_struct *mm;
-	unsigned long long start_time;
-	unsigned long cmin_flt = 0, cmaj_flt = 0;
-	unsigned long  min_flt = 0,  maj_flt = 0;
-	cputime_t cutime, cstime, utime, stime;
-	cputime_t cgtime, gtime;
-	unsigned long rsslim = 0;
-	char tcomm[sizeof(task->comm)];
-	unsigned long flags;
-
-	state = *get_task_state(task);
-	vsize = eip = esp = 0;
-	permitted = ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_NOAUDIT);
-	mm = get_task_mm(task);
-	if (mm) {
-		vsize = task_vsize(mm);
-		if (permitted) {
-			eip = KSTK_EIP(task);
-			esp = KSTK_ESP(task);
-		}
-	}
-
-	get_task_comm(tcomm, task);
-
-	sigemptyset(&sigign);
-	sigemptyset(&sigcatch);
-	cutime = cstime = utime = stime = 0;
-	cgtime = gtime = 0;
-
-	if (lock_task_sighand(task, &flags)) {
-		struct signal_struct *sig = task->signal;
-
-		if (sig->tty) {
-			struct pid *pgrp = tty_get_pgrp(sig->tty);
-			tty_pgrp = pid_nr_ns(pgrp, ns);
-			put_pid(pgrp);
-			tty_nr = new_encode_dev(tty_devnum(sig->tty));
-		}
-
-		num_threads = get_nr_threads(task);
-		collect_sigign_sigcatch(task, &sigign, &sigcatch);
-
-		cmin_flt = sig->cmin_flt;
-		cmaj_flt = sig->cmaj_flt;
-		cutime = sig->cutime;
-		cstime = sig->cstime;
-		cgtime = sig->cgtime;
-		rsslim = ACCESS_ONCE(sig->rlim[RLIMIT_RSS].rlim_cur);
-
-		/* add up live thread stats at the group level */
-		if (whole) {
-			struct task_struct *t = task;
-			do {
-				min_flt += t->min_flt;
-				maj_flt += t->maj_flt;
-				gtime += task_gtime(t);
-			} while_each_thread(task, t);
-
-			min_flt += sig->min_flt;
-			maj_flt += sig->maj_flt;
-			thread_group_cputime_adjusted(task, &utime, &stime);
-			gtime += sig->gtime;
-		}
-
-		sid = task_session_nr_ns(task, ns);
-		ppid = task_tgid_nr_ns(task->real_parent, ns);
-		pgid = task_pgrp_nr_ns(task, ns);
-
-		unlock_task_sighand(task, &flags);
-	}
-
-	if (permitted && (!whole || num_threads < 2))
-		wchan = get_wchan(task);
-	if (!whole) {
-		min_flt = task->min_flt;
-		maj_flt = task->maj_flt;
-		task_cputime_adjusted(task, &utime, &stime);
-		gtime = task_gtime(task);
-	}
+	struct mm_struct *mm = get_task_mm(task);
 
-	/* scale priority and nice values from timeslices to -20..20 */
-	/* to make it look like a "normal" Unix priority/nice value  */
-	priority = task_prio(task);
-	nice = task_nice(task);
-
-	/* Temporary variable needed for gcc-2.96 */
-	/* convert timespec -> nsec*/
-	start_time =
-		(unsigned long long)task->real_start_time.tv_sec * NSEC_PER_SEC
-				+ task->real_start_time.tv_nsec;
-	/* convert nsec -> ticks */
-	start_time = nsec_to_clock_t(start_time);
-
-	seq_printf(m, "%d (%s) %c", pid_nr_ns(pid, ns), tcomm, state);
-	seq_put_decimal_ll(m, ' ', ppid);
-	seq_put_decimal_ll(m, ' ', pgid);
-	seq_put_decimal_ll(m, ' ', sid);
-	seq_put_decimal_ll(m, ' ', tty_nr);
-	seq_put_decimal_ll(m, ' ', tty_pgrp);
-	seq_put_decimal_ull(m, ' ', task->flags);
-	seq_put_decimal_ull(m, ' ', min_flt);
-	seq_put_decimal_ull(m, ' ', cmin_flt);
-	seq_put_decimal_ull(m, ' ', maj_flt);
-	seq_put_decimal_ull(m, ' ', cmaj_flt);
-	seq_put_decimal_ull(m, ' ', cputime_to_clock_t(utime));
-	seq_put_decimal_ull(m, ' ', cputime_to_clock_t(stime));
-	seq_put_decimal_ll(m, ' ', cputime_to_clock_t(cutime));
-	seq_put_decimal_ll(m, ' ', cputime_to_clock_t(cstime));
-	seq_put_decimal_ll(m, ' ', priority);
-	seq_put_decimal_ll(m, ' ', nice);
-	seq_put_decimal_ll(m, ' ', num_threads);
-	seq_put_decimal_ull(m, ' ', 0);
-	seq_put_decimal_ull(m, ' ', start_time);
-	seq_put_decimal_ull(m, ' ', vsize);
-	seq_put_decimal_ull(m, ' ', mm ? get_mm_rss(mm) : 0);
-	seq_put_decimal_ull(m, ' ', rsslim);
-	seq_put_decimal_ull(m, ' ', mm ? (permitted ? mm->start_code : 1) : 0);
-	seq_put_decimal_ull(m, ' ', mm ? (permitted ? mm->end_code : 1) : 0);
-	seq_put_decimal_ull(m, ' ', (permitted && mm) ? mm->start_stack : 0);
-	seq_put_decimal_ull(m, ' ', esp);
-	seq_put_decimal_ull(m, ' ', eip);
-	/* The signal information here is obsolete.
-	 * It must be decimal for Linux 2.0 compatibility.
-	 * Use /proc/#/status for real-time signals.
-	 */
-	seq_put_decimal_ull(m, ' ', task->pending.signal.sig[0] & 0x7fffffffUL);
-	seq_put_decimal_ull(m, ' ', task->blocked.sig[0] & 0x7fffffffUL);
-	seq_put_decimal_ull(m, ' ', sigign.sig[0] & 0x7fffffffUL);
-	seq_put_decimal_ull(m, ' ', sigcatch.sig[0] & 0x7fffffffUL);
-	seq_put_decimal_ull(m, ' ', wchan);
-	seq_put_decimal_ull(m, ' ', 0);
-	seq_put_decimal_ull(m, ' ', 0);
-	seq_put_decimal_ll(m, ' ', task->exit_signal);
-	seq_put_decimal_ll(m, ' ', task_cpu(task));
-	seq_put_decimal_ull(m, ' ', task->rt_priority);
-	seq_put_decimal_ull(m, ' ', task->policy);
-	seq_put_decimal_ull(m, ' ', delayacct_blkio_ticks(task));
-	seq_put_decimal_ull(m, ' ', cputime_to_clock_t(gtime));
-	seq_put_decimal_ll(m, ' ', cputime_to_clock_t(cgtime));
-
-	if (mm && permitted) {
-		seq_put_decimal_ull(m, ' ', mm->start_data);
-		seq_put_decimal_ull(m, ' ', mm->end_data);
-		seq_put_decimal_ull(m, ' ', mm->start_brk);
-		seq_put_decimal_ull(m, ' ', mm->arg_start);
-		seq_put_decimal_ull(m, ' ', mm->arg_end);
-		seq_put_decimal_ull(m, ' ', mm->env_start);
-		seq_put_decimal_ull(m, ' ', mm->env_end);
-	} else
-		seq_printf(m, " 0 0 0 0 0 0 0");
-
-	if (permitted)
-		seq_put_decimal_ll(m, ' ', task->exit_code);
-	else
-		seq_put_decimal_ll(m, ' ', 0);
-
-	seq_putc(m, '\n');
+	task_stat_mm(m, ns, pid, task, whole, mm);
 	if (mm)
 		mmput(mm);
+
 	return 0;
 }
 
@@ -565,27 +123,11 @@ int proc_tgid_stat(struct seq_file *m, struct pid_namespace *ns,
 int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
-	unsigned long size = 0, resident = 0, shared = 0, text = 0, data = 0;
 	struct mm_struct *mm = get_task_mm(task);
 
-	if (mm) {
-		size = task_statm(mm, &shared, &text, &data, &resident);
+	proc_pid_statm_mm(m, ns, pid, task, mm);
+	if (mm)
 		mmput(mm);
-	}
-	/*
-	 * For quick read, open code by putting numbers directly
-	 * expected format is
-	 * seq_printf(m, "%lu %lu %lu %lu 0 %lu 0\n",
-	 *               size, resident, shared, text, data);
-	 */
-	seq_put_decimal_ull(m, 0, size);
-	seq_put_decimal_ull(m, ' ', resident);
-	seq_put_decimal_ull(m, ' ', shared);
-	seq_put_decimal_ull(m, ' ', text);
-	seq_put_decimal_ull(m, ' ', 0);
-	seq_put_decimal_ull(m, ' ', data);
-	seq_put_decimal_ull(m, ' ', 0);
-	seq_putc(m, '\n');
 
 	return 0;
 }
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index cfa63ee..8e88002 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -19,72 +19,6 @@
 #include <asm/tlbflush.h>
 #include "internal.h"
 
-void task_mem(struct seq_file *m, struct mm_struct *mm)
-{
-	unsigned long data, text, lib, swap;
-	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
-
-	/*
-	 * Note: to minimize their overhead, mm maintains hiwater_vm and
-	 * hiwater_rss only when about to *lower* total_vm or rss.  Any
-	 * collector of these hiwater stats must therefore get total_vm
-	 * and rss too, which will usually be the higher.  Barriers? not
-	 * worth the effort, such snapshots can always be inconsistent.
-	 */
-	hiwater_vm = total_vm = mm->total_vm;
-	if (hiwater_vm < mm->hiwater_vm)
-		hiwater_vm = mm->hiwater_vm;
-	hiwater_rss = total_rss = get_mm_rss(mm);
-	if (hiwater_rss < mm->hiwater_rss)
-		hiwater_rss = mm->hiwater_rss;
-
-	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
-	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
-	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
-	swap = get_mm_counter(mm, MM_SWAPENTS);
-	seq_printf(m,
-		"VmPeak:\t%8lu kB\n"
-		"VmSize:\t%8lu kB\n"
-		"VmLck:\t%8lu kB\n"
-		"VmPin:\t%8lu kB\n"
-		"VmHWM:\t%8lu kB\n"
-		"VmRSS:\t%8lu kB\n"
-		"VmData:\t%8lu kB\n"
-		"VmStk:\t%8lu kB\n"
-		"VmExe:\t%8lu kB\n"
-		"VmLib:\t%8lu kB\n"
-		"VmPTE:\t%8lu kB\n"
-		"VmSwap:\t%8lu kB\n",
-		hiwater_vm << (PAGE_SHIFT-10),
-		total_vm << (PAGE_SHIFT-10),
-		mm->locked_vm << (PAGE_SHIFT-10),
-		mm->pinned_vm << (PAGE_SHIFT-10),
-		hiwater_rss << (PAGE_SHIFT-10),
-		total_rss << (PAGE_SHIFT-10),
-		data << (PAGE_SHIFT-10),
-		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
-		(PTRS_PER_PTE * sizeof(pte_t) *
-		 atomic_long_read(&mm->nr_ptes)) >> 10,
-		swap << (PAGE_SHIFT-10));
-}
-
-unsigned long task_vsize(struct mm_struct *mm)
-{
-	return PAGE_SIZE * mm->total_vm;
-}
-
-unsigned long task_statm(struct mm_struct *mm,
-			 unsigned long *shared, unsigned long *text,
-			 unsigned long *data, unsigned long *resident)
-{
-	*shared = get_mm_counter(mm, MM_FILEPAGES);
-	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
-								>> PAGE_SHIFT;
-	*data = mm->total_vm - mm->shared_vm;
-	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
-	return mm->total_vm;
-}
-
 #ifdef CONFIG_NUMA
 /*
  * These functions are for numa_maps but called in generic **maps seq_file
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 678455d..ab50d9f 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -10,120 +10,6 @@
 #include "internal.h"
 
 /*
- * Logic: we've got two memory sums for each process, "shared", and
- * "non-shared". Shared memory may get counted more than once, for
- * each process that owns it. Non-shared memory is counted
- * accurately.
- */
-void task_mem(struct seq_file *m, struct mm_struct *mm)
-{
-	struct vm_area_struct *vma;
-	struct vm_region *region;
-	struct rb_node *p;
-	unsigned long bytes = 0, sbytes = 0, slack = 0, size;
-        
-	down_read(&mm->mmap_sem);
-	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
-		vma = rb_entry(p, struct vm_area_struct, vm_rb);
-
-		bytes += kobjsize(vma);
-
-		region = vma->vm_region;
-		if (region) {
-			size = kobjsize(region);
-			size += region->vm_end - region->vm_start;
-		} else {
-			size = vma->vm_end - vma->vm_start;
-		}
-
-		if (atomic_read(&mm->mm_count) > 1 ||
-		    vma->vm_flags & VM_MAYSHARE) {
-			sbytes += size;
-		} else {
-			bytes += size;
-			if (region)
-				slack = region->vm_end - vma->vm_end;
-		}
-	}
-
-	if (atomic_read(&mm->mm_count) > 1)
-		sbytes += kobjsize(mm);
-	else
-		bytes += kobjsize(mm);
-	
-	if (current->fs && current->fs->users > 1)
-		sbytes += kobjsize(current->fs);
-	else
-		bytes += kobjsize(current->fs);
-
-	if (current->files && atomic_read(&current->files->count) > 1)
-		sbytes += kobjsize(current->files);
-	else
-		bytes += kobjsize(current->files);
-
-	if (current->sighand && atomic_read(&current->sighand->count) > 1)
-		sbytes += kobjsize(current->sighand);
-	else
-		bytes += kobjsize(current->sighand);
-
-	bytes += kobjsize(current); /* includes kernel stack */
-
-	seq_printf(m,
-		"Mem:\t%8lu bytes\n"
-		"Slack:\t%8lu bytes\n"
-		"Shared:\t%8lu bytes\n",
-		bytes, slack, sbytes);
-
-	up_read(&mm->mmap_sem);
-}
-
-unsigned long task_vsize(struct mm_struct *mm)
-{
-	struct vm_area_struct *vma;
-	struct rb_node *p;
-	unsigned long vsize = 0;
-
-	down_read(&mm->mmap_sem);
-	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
-		vma = rb_entry(p, struct vm_area_struct, vm_rb);
-		vsize += vma->vm_end - vma->vm_start;
-	}
-	up_read(&mm->mmap_sem);
-	return vsize;
-}
-
-unsigned long task_statm(struct mm_struct *mm,
-			 unsigned long *shared, unsigned long *text,
-			 unsigned long *data, unsigned long *resident)
-{
-	struct vm_area_struct *vma;
-	struct vm_region *region;
-	struct rb_node *p;
-	unsigned long size = kobjsize(mm);
-
-	down_read(&mm->mmap_sem);
-	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
-		vma = rb_entry(p, struct vm_area_struct, vm_rb);
-		size += kobjsize(vma);
-		region = vma->vm_region;
-		if (region) {
-			size += kobjsize(region);
-			size += region->vm_end - region->vm_start;
-		}
-	}
-
-	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
-		>> PAGE_SHIFT;
-	*data = (PAGE_ALIGN(mm->start_stack) - (mm->start_data & PAGE_MASK))
-		>> PAGE_SHIFT;
-	up_read(&mm->mmap_sem);
-	size >>= PAGE_SHIFT;
-	size += *text + *data;
-	*resident = size;
-	return size;
-}
-
-/*
  * display a single VMA to a sequenced file
  */
 static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma,
diff --git a/include/linux/proc_info.h b/include/linux/proc_info.h
new file mode 100644
index 0000000..b083499
--- /dev/null
+++ b/include/linux/proc_info.h
@@ -0,0 +1,35 @@
+#ifndef _LINUX_PROC_INFO_H
+#define _LINUX_PROC_INFO_H
+
+#include <linux/types.h>
+#include <linux/fdtable.h>
+#include <linux/seq_file.h>
+#include <linux/user_namespace.h>
+#include <linux/ptrace.h>
+
+void task_mem(struct seq_file *m, struct mm_struct *mm);
+unsigned long task_vsize(struct mm_struct *mm);
+unsigned long task_statm(struct mm_struct *mm,
+			 unsigned long *shared, unsigned long *text,
+			 unsigned long *data, unsigned long *resident);
+void task_name(struct seq_file *m, struct task_struct *p);
+const char *get_task_state(struct task_struct *tsk);
+void task_state(struct seq_file *m, struct pid_namespace *ns,
+		struct pid *pid, struct task_struct *p);
+void task_sig(struct seq_file *m, struct task_struct *p);
+void task_cap(struct seq_file *m, struct task_struct *p);
+void task_seccomp(struct seq_file *m, struct task_struct *p);
+void task_context_switch_counts(struct seq_file *m, struct task_struct *p);
+void task_cpus_allowed(struct seq_file *m, struct task_struct *task);
+void render_sigset_t(struct seq_file *m, const char *header, sigset_t *set);
+int proc_pid_status_mm(struct seq_file *m, struct pid_namespace *ns,
+		       struct pid *pid, struct task_struct *task,
+		       struct mm_struct *mm);
+int task_stat_mm(struct seq_file *m, struct pid_namespace *ns,
+		 struct pid *pid, struct task_struct *task, int whole,
+		 struct mm_struct *mm);
+int proc_pid_statm_mm(struct seq_file *m, struct pid_namespace *ns,
+		      struct pid *pid, struct task_struct *task,
+		      struct mm_struct *mm);
+
+#endif /* _LINUX_PROC_INFO_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 334f772..037acda 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -474,4 +474,9 @@ config UCS2_STRING
 
 source "lib/fonts/Kconfig"
 
+config PROC_INFO
+	bool
+	help
+	  This option provides process information
+
 endmenu
diff --git a/lib/Makefile b/lib/Makefile
index ba967a1..f2a492c 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -40,6 +40,8 @@ CFLAGS_kobject.o += -DDEBUG
 CFLAGS_kobject_uevent.o += -DDEBUG
 endif
 
+obj-$(CONFIG_PROC_INFO) += proc_info.o
+
 obj-$(CONFIG_GENERIC_IOMAP) += iomap.o
 obj-$(CONFIG_GENERIC_PCI_IOMAP) += pci_iomap.o
 obj-$(CONFIG_HAS_IOMEM) += iomap_copy.o devres.o
diff --git a/lib/proc_info.c b/lib/proc_info.c
new file mode 100644
index 0000000..f5f86a0
--- /dev/null
+++ b/lib/proc_info.c
@@ -0,0 +1,686 @@
+/*
+ * lib/proc_info.c
+ *
+ * The code is copied from fs/proc/array.c
+ *
+ * Helper functions used for process information.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/export.h>
+#include <linux/cpuset.h>
+#include <linux/tty.h>
+#include <linux/taskstats.h>
+#include <linux/delayacct.h>
+#include <linux/proc_info.h>
+
+#ifdef CONFIG_MMU
+void task_mem(struct seq_file *m, struct mm_struct *mm)
+{
+	unsigned long data, text, lib, swap;
+	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
+
+	/*
+	 * Note: to minimize their overhead, mm maintains hiwater_vm and
+	 * hiwater_rss only when about to *lower* total_vm or rss.  Any
+	 * collector of these hiwater stats must therefore get total_vm
+	 * and rss too, which will usually be the higher.  Barriers? not
+	 * worth the effort, such snapshots can always be inconsistent.
+	 */
+	hiwater_vm = total_vm = mm->total_vm;
+	if (hiwater_vm < mm->hiwater_vm)
+		hiwater_vm = mm->hiwater_vm;
+	hiwater_rss = total_rss = get_mm_rss(mm);
+	if (hiwater_rss < mm->hiwater_rss)
+		hiwater_rss = mm->hiwater_rss;
+
+	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
+	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
+	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
+	swap = get_mm_counter(mm, MM_SWAPENTS);
+	seq_printf(m,
+		"VmPeak:\t%8lu kB\n"
+		"VmSize:\t%8lu kB\n"
+		"VmLck:\t%8lu kB\n"
+		"VmPin:\t%8lu kB\n"
+		"VmHWM:\t%8lu kB\n"
+		"VmRSS:\t%8lu kB\n"
+		"VmData:\t%8lu kB\n"
+		"VmStk:\t%8lu kB\n"
+		"VmExe:\t%8lu kB\n"
+		"VmLib:\t%8lu kB\n"
+		"VmPTE:\t%8lu kB\n"
+		"VmSwap:\t%8lu kB\n",
+		hiwater_vm << (PAGE_SHIFT-10),
+		total_vm << (PAGE_SHIFT-10),
+		mm->locked_vm << (PAGE_SHIFT-10),
+		mm->pinned_vm << (PAGE_SHIFT-10),
+		hiwater_rss << (PAGE_SHIFT-10),
+		total_rss << (PAGE_SHIFT-10),
+		data << (PAGE_SHIFT-10),
+		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
+		(PTRS_PER_PTE * sizeof(pte_t) *
+		 atomic_long_read(&mm->nr_ptes)) >> 10,
+		swap << (PAGE_SHIFT-10));
+}
+
+unsigned long task_vsize(struct mm_struct *mm)
+{
+	return PAGE_SIZE * mm->total_vm;
+}
+
+unsigned long task_statm(struct mm_struct *mm,
+			 unsigned long *shared, unsigned long *text,
+			 unsigned long *data, unsigned long *resident)
+{
+	*shared = get_mm_counter(mm, MM_FILEPAGES);
+	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
+								>> PAGE_SHIFT;
+	*data = mm->total_vm - mm->shared_vm;
+	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
+	return mm->total_vm;
+}
+#else
+/*
+ * Logic: we've got two memory sums for each process, "shared", and
+ * "non-shared". Shared memory may get counted more than once, for
+ * each process that owns it. Non-shared memory is counted
+ * accurately.
+ */
+void task_mem(struct seq_file *m, struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	struct vm_region *region;
+	struct rb_node *p;
+	unsigned long bytes = 0, sbytes = 0, slack = 0, size;
+
+	down_read(&mm->mmap_sem);
+	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
+		vma = rb_entry(p, struct vm_area_struct, vm_rb);
+
+		bytes += kobjsize(vma);
+
+		region = vma->vm_region;
+		if (region) {
+			size = kobjsize(region);
+			size += region->vm_end - region->vm_start;
+		} else {
+			size = vma->vm_end - vma->vm_start;
+		}
+
+		if (atomic_read(&mm->mm_count) > 1 ||
+		    vma->vm_flags & VM_MAYSHARE) {
+			sbytes += size;
+		} else {
+			bytes += size;
+			if (region)
+				slack = region->vm_end - vma->vm_end;
+		}
+	}
+
+	if (atomic_read(&mm->mm_count) > 1)
+		sbytes += kobjsize(mm);
+	else
+		bytes += kobjsize(mm);
+
+	if (current->fs && current->fs->users > 1)
+		sbytes += kobjsize(current->fs);
+	else
+		bytes += kobjsize(current->fs);
+
+	if (current->files && atomic_read(&current->files->count) > 1)
+		sbytes += kobjsize(current->files);
+	else
+		bytes += kobjsize(current->files);
+
+	if (current->sighand && atomic_read(&current->sighand->count) > 1)
+		sbytes += kobjsize(current->sighand);
+	else
+		bytes += kobjsize(current->sighand);
+
+	bytes += kobjsize(current); /* includes kernel stack */
+
+	seq_printf(m,
+		"Mem:\t%8lu bytes\n"
+		"Slack:\t%8lu bytes\n"
+		"Shared:\t%8lu bytes\n",
+		bytes, slack, sbytes);
+
+	up_read(&mm->mmap_sem);
+}
+
+unsigned long task_vsize(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	struct rb_node *p;
+	unsigned long vsize = 0;
+
+	down_read(&mm->mmap_sem);
+	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
+		vma = rb_entry(p, struct vm_area_struct, vm_rb);
+		vsize += vma->vm_end - vma->vm_start;
+	}
+	up_read(&mm->mmap_sem);
+	return vsize;
+}
+
+unsigned long task_statm(struct mm_struct *mm,
+			 unsigned long *shared, unsigned long *text,
+			 unsigned long *data, unsigned long *resident)
+{
+	struct vm_area_struct *vma;
+	struct vm_region *region;
+	struct rb_node *p;
+	unsigned long size = kobjsize(mm);
+
+	down_read(&mm->mmap_sem);
+	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
+		vma = rb_entry(p, struct vm_area_struct, vm_rb);
+		size += kobjsize(vma);
+		region = vma->vm_region;
+		if (region) {
+			size += kobjsize(region);
+			size += region->vm_end - region->vm_start;
+		}
+	}
+
+	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
+		>> PAGE_SHIFT;
+	*data = (PAGE_ALIGN(mm->start_stack) - (mm->start_data & PAGE_MASK))
+		>> PAGE_SHIFT;
+	up_read(&mm->mmap_sem);
+	size >>= PAGE_SHIFT;
+	size += *text + *data;
+	*resident = size;
+	return size;
+}
+#endif
+
+void task_name(struct seq_file *m, struct task_struct *p)
+{
+	int i;
+	char *buf, *end;
+	char *name;
+	char tcomm[sizeof(p->comm)];
+
+	get_task_comm(tcomm, p);
+
+	seq_puts(m, "Name:\t");
+	end = m->buf + m->size;
+	buf = m->buf + m->count;
+	name = tcomm;
+	i = sizeof(tcomm);
+	while (i && (buf < end)) {
+		unsigned char c = *name;
+
+		name++;
+		i--;
+		*buf = c;
+		if (!c)
+			break;
+		if (c == '\\') {
+			buf++;
+			if (buf < end)
+				*buf++ = c;
+			continue;
+		}
+		if (c == '\n') {
+			*buf++ = '\\';
+			if (buf < end)
+				*buf++ = 'n';
+			continue;
+		}
+		buf++;
+	}
+	m->count = buf - m->buf;
+	seq_putc(m, '\n');
+}
+
+/*
+ * The task state array is a strange "bitmap" of
+ * reasons to sleep. Thus "running" is zero, and
+ * you can test for combinations of others with
+ * simple bit tests.
+ */
+static const char * const task_state_array[] = {
+	"R (running)",		/*   0 */
+	"S (sleeping)",		/*   1 */
+	"D (disk sleep)",	/*   2 */
+	"T (stopped)",		/*   4 */
+	"t (tracing stop)",	/*   8 */
+	"X (dead)",		/*  16 */
+	"Z (zombie)",		/*  32 */
+};
+
+const char *get_task_state(struct task_struct *tsk)
+{
+	unsigned int state = (tsk->state | tsk->exit_state) & TASK_REPORT;
+
+	BUILD_BUG_ON(1 + ilog2(TASK_REPORT) != ARRAY_SIZE(task_state_array)-1);
+
+	return task_state_array[fls(state)];
+}
+
+void task_state(struct seq_file *m, struct pid_namespace *ns,
+		struct pid *pid, struct task_struct *p)
+{
+	struct user_namespace *user_ns = seq_user_ns(m);
+	struct group_info *group_info;
+	int g;
+	struct fdtable *fdt = NULL;
+	const struct cred *cred;
+	pid_t ppid, tpid;
+
+	rcu_read_lock();
+	ppid = pid_alive(p) ?
+		task_tgid_nr_ns(rcu_dereference(p->real_parent), ns) : 0;
+	tpid = 0;
+	if (pid_alive(p)) {
+		struct task_struct *tracer = ptrace_parent(p);
+
+		if (tracer)
+			tpid = task_pid_nr_ns(tracer, ns);
+	}
+	cred = get_task_cred(p);
+	seq_printf(m,
+		"State:\t%s\n"
+		"Tgid:\t%d\n"
+		"Ngid:\t%d\n"
+		"Pid:\t%d\n"
+		"PPid:\t%d\n"
+		"TracerPid:\t%d\n"
+		"Uid:\t%d\t%d\t%d\t%d\n"
+		"Gid:\t%d\t%d\t%d\t%d\n",
+		get_task_state(p),
+		task_tgid_nr_ns(p, ns),
+		task_numa_group_id(p),
+		pid_nr_ns(pid, ns),
+		ppid, tpid,
+		from_kuid_munged(user_ns, cred->uid),
+		from_kuid_munged(user_ns, cred->euid),
+		from_kuid_munged(user_ns, cred->suid),
+		from_kuid_munged(user_ns, cred->fsuid),
+		from_kgid_munged(user_ns, cred->gid),
+		from_kgid_munged(user_ns, cred->egid),
+		from_kgid_munged(user_ns, cred->sgid),
+		from_kgid_munged(user_ns, cred->fsgid));
+
+	task_lock(p);
+	if (p->files)
+		fdt = files_fdtable(p->files);
+	seq_printf(m,
+		"FDSize:\t%d\n"
+		"Groups:\t",
+		fdt ? fdt->max_fds : 0);
+	rcu_read_unlock();
+
+	group_info = cred->group_info;
+	task_unlock(p);
+
+	for (g = 0; g < group_info->ngroups; g++)
+		seq_printf(m, "%d ",
+			   from_kgid_munged(user_ns, GROUP_AT(group_info, g)));
+	put_cred(cred);
+
+	seq_putc(m, '\n');
+}
+
+void render_sigset_t(struct seq_file *m, const char *header, sigset_t *set)
+{
+	int i;
+
+	seq_puts(m, header);
+
+	i = _NSIG;
+	do {
+		int x = 0;
+
+		i -= 4;
+		if (sigismember(set, i+1)) x |= 1;
+		if (sigismember(set, i+2)) x |= 2;
+		if (sigismember(set, i+3)) x |= 4;
+		if (sigismember(set, i+4)) x |= 8;
+		seq_printf(m, "%x", x);
+	} while (i >= 4);
+
+	seq_putc(m, '\n');
+}
+
+static void collect_sigign_sigcatch(struct task_struct *p, sigset_t *ign,
+				    sigset_t *catch)
+{
+	struct k_sigaction *k;
+	int i;
+
+	k = p->sighand->action;
+	for (i = 1; i <= _NSIG; ++i, ++k) {
+		if (k->sa.sa_handler == SIG_IGN)
+			sigaddset(ign, i);
+		else if (k->sa.sa_handler != SIG_DFL)
+			sigaddset(catch, i);
+	}
+}
+
+void task_sig(struct seq_file *m, struct task_struct *p)
+{
+	unsigned long flags;
+	sigset_t pending, shpending, blocked, ignored, caught;
+	int num_threads = 0;
+	unsigned long qsize = 0;
+	unsigned long qlim = 0;
+
+	sigemptyset(&pending);
+	sigemptyset(&shpending);
+	sigemptyset(&blocked);
+	sigemptyset(&ignored);
+	sigemptyset(&caught);
+
+	if (lock_task_sighand(p, &flags)) {
+		pending = p->pending.signal;
+		shpending = p->signal->shared_pending.signal;
+		blocked = p->blocked;
+		collect_sigign_sigcatch(p, &ignored, &caught);
+		num_threads = get_nr_threads(p);
+		rcu_read_lock();  /* FIXME: is this correct? */
+		qsize = atomic_read(&__task_cred(p)->user->sigpending);
+		rcu_read_unlock();
+		qlim = task_rlimit(p, RLIMIT_SIGPENDING);
+		unlock_task_sighand(p, &flags);
+	}
+
+	seq_printf(m, "Threads:\t%d\n", num_threads);
+	seq_printf(m, "SigQ:\t%lu/%lu\n", qsize, qlim);
+
+	/* render them all */
+	render_sigset_t(m, "SigPnd:\t", &pending);
+	render_sigset_t(m, "ShdPnd:\t", &shpending);
+	render_sigset_t(m, "SigBlk:\t", &blocked);
+	render_sigset_t(m, "SigIgn:\t", &ignored);
+	render_sigset_t(m, "SigCgt:\t", &caught);
+}
+
+static void render_cap_t(struct seq_file *m, const char *header,
+			 kernel_cap_t *a)
+{
+	unsigned __capi;
+
+	seq_puts(m, header);
+	CAP_FOR_EACH_U32(__capi) {
+		seq_printf(m, "%08x",
+			   a->cap[(_KERNEL_CAPABILITY_U32S-1) - __capi]);
+	}
+	seq_putc(m, '\n');
+}
+
+/* Remove non-existent capabilities */
+#define NORM_CAPS(v) (v.cap[CAP_TO_INDEX(CAP_LAST_CAP)] &= \
+				CAP_TO_MASK(CAP_LAST_CAP + 1) - 1)
+
+void task_cap(struct seq_file *m, struct task_struct *p)
+{
+	const struct cred *cred;
+	kernel_cap_t cap_inheritable, cap_permitted, cap_effective, cap_bset;
+
+	rcu_read_lock();
+	cred = __task_cred(p);
+	cap_inheritable	= cred->cap_inheritable;
+	cap_permitted	= cred->cap_permitted;
+	cap_effective	= cred->cap_effective;
+	cap_bset	= cred->cap_bset;
+	rcu_read_unlock();
+
+	NORM_CAPS(cap_inheritable);
+	NORM_CAPS(cap_permitted);
+	NORM_CAPS(cap_effective);
+	NORM_CAPS(cap_bset);
+
+	render_cap_t(m, "CapInh:\t", &cap_inheritable);
+	render_cap_t(m, "CapPrm:\t", &cap_permitted);
+	render_cap_t(m, "CapEff:\t", &cap_effective);
+	render_cap_t(m, "CapBnd:\t", &cap_bset);
+}
+
+void task_seccomp(struct seq_file *m, struct task_struct *p)
+{
+#ifdef CONFIG_SECCOMP
+	seq_printf(m, "Seccomp:\t%d\n", p->seccomp.mode);
+#endif
+}
+
+void task_context_switch_counts(struct seq_file *m, struct task_struct *p)
+{
+	seq_printf(m,	"voluntary_ctxt_switches:\t%lu\n"
+			"nonvoluntary_ctxt_switches:\t%lu\n",
+			p->nvcsw,
+			p->nivcsw);
+}
+
+void task_cpus_allowed(struct seq_file *m, struct task_struct *task)
+{
+	seq_puts(m, "Cpus_allowed:\t");
+	seq_cpumask(m, &task->cpus_allowed);
+	seq_putc(m, '\n');
+	seq_puts(m, "Cpus_allowed_list:\t");
+	seq_cpumask_list(m, &task->cpus_allowed);
+	seq_putc(m, '\n');
+}
+
+int proc_pid_status_mm(struct seq_file *m, struct pid_namespace *ns,
+		       struct pid *pid, struct task_struct *task,
+		       struct mm_struct *mm)
+{
+	task_name(m, task);
+	task_state(m, ns, pid, task);
+
+	if (mm)
+		task_mem(m, mm);
+
+	task_sig(m, task);
+	task_cap(m, task);
+	task_seccomp(m, task);
+	task_cpus_allowed(m, task);
+	cpuset_task_status_allowed(m, task);
+	task_context_switch_counts(m, task);
+	return 0;
+}
+
+int task_stat_mm(struct seq_file *m, struct pid_namespace *ns,
+		 struct pid *pid, struct task_struct *task, int whole,
+		 struct mm_struct *mm)
+{
+	unsigned long vsize, eip, esp, wchan = ~0UL;
+	int priority, nice;
+	int tty_pgrp = -1, tty_nr = 0;
+	sigset_t sigign, sigcatch;
+	char state;
+	pid_t ppid = 0, pgid = -1, sid = -1;
+	int num_threads = 0;
+	int permitted;
+	unsigned long long start_time;
+	unsigned long cmin_flt = 0, cmaj_flt = 0;
+	unsigned long  min_flt = 0,  maj_flt = 0;
+	cputime_t cutime, cstime, utime, stime;
+	cputime_t cgtime, gtime;
+	unsigned long rsslim = 0;
+	char tcomm[sizeof(task->comm)];
+	unsigned long flags;
+
+	state = *get_task_state(task);
+	vsize = eip = esp = 0;
+	permitted = ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_NOAUDIT);
+	if (mm) {
+		vsize = task_vsize(mm);
+		if (permitted) {
+			eip = KSTK_EIP(task);
+			esp = KSTK_ESP(task);
+		}
+	}
+
+	get_task_comm(tcomm, task);
+
+	sigemptyset(&sigign);
+	sigemptyset(&sigcatch);
+	cutime = cstime = utime = stime = 0;
+	cgtime = gtime = 0;
+
+	if (lock_task_sighand(task, &flags)) {
+		struct signal_struct *sig = task->signal;
+
+		if (sig->tty) {
+			struct pid *pgrp = tty_get_pgrp(sig->tty);
+
+			tty_pgrp = pid_nr_ns(pgrp, ns);
+			put_pid(pgrp);
+			tty_nr = new_encode_dev(tty_devnum(sig->tty));
+		}
+
+		num_threads = get_nr_threads(task);
+		collect_sigign_sigcatch(task, &sigign, &sigcatch);
+
+		cmin_flt = sig->cmin_flt;
+		cmaj_flt = sig->cmaj_flt;
+		cutime = sig->cutime;
+		cstime = sig->cstime;
+		cgtime = sig->cgtime;
+		rsslim = ACCESS_ONCE(sig->rlim[RLIMIT_RSS].rlim_cur);
+
+		/* add up live thread stats at the group level */
+		if (whole) {
+			struct task_struct *t = task;
+
+			do {
+				min_flt += t->min_flt;
+				maj_flt += t->maj_flt;
+				gtime += task_gtime(t);
+			} while_each_thread(task, t);
+
+			min_flt += sig->min_flt;
+			maj_flt += sig->maj_flt;
+			thread_group_cputime_adjusted(task, &utime, &stime);
+			gtime += sig->gtime;
+		}
+
+		sid = task_session_nr_ns(task, ns);
+		ppid = task_tgid_nr_ns(task->real_parent, ns);
+		pgid = task_pgrp_nr_ns(task, ns);
+
+		unlock_task_sighand(task, &flags);
+	}
+
+	if (permitted && (!whole || num_threads < 2))
+		wchan = get_wchan(task);
+	if (!whole) {
+		min_flt = task->min_flt;
+		maj_flt = task->maj_flt;
+		task_cputime_adjusted(task, &utime, &stime);
+		gtime = task_gtime(task);
+	}
+
+	/* scale priority and nice values from timeslices to -20..20 */
+	/* to make it look like a "normal" Unix priority/nice value  */
+	priority = task_prio(task);
+	nice = task_nice(task);
+
+	/* Temporary variable needed for gcc-2.96 */
+	/* convert timespec -> nsec*/
+	start_time =
+		(unsigned long long)task->real_start_time.tv_sec * NSEC_PER_SEC
+				+ task->real_start_time.tv_nsec;
+	/* convert nsec -> ticks */
+	start_time = nsec_to_clock_t(start_time);
+
+	seq_printf(m, "%d (%s) %c", pid_nr_ns(pid, ns), tcomm, state);
+	seq_put_decimal_ll(m, ' ', ppid);
+	seq_put_decimal_ll(m, ' ', pgid);
+	seq_put_decimal_ll(m, ' ', sid);
+	seq_put_decimal_ll(m, ' ', tty_nr);
+	seq_put_decimal_ll(m, ' ', tty_pgrp);
+	seq_put_decimal_ull(m, ' ', task->flags);
+	seq_put_decimal_ull(m, ' ', min_flt);
+	seq_put_decimal_ull(m, ' ', cmin_flt);
+	seq_put_decimal_ull(m, ' ', maj_flt);
+	seq_put_decimal_ull(m, ' ', cmaj_flt);
+	seq_put_decimal_ull(m, ' ', cputime_to_clock_t(utime));
+	seq_put_decimal_ull(m, ' ', cputime_to_clock_t(stime));
+	seq_put_decimal_ll(m, ' ', cputime_to_clock_t(cutime));
+	seq_put_decimal_ll(m, ' ', cputime_to_clock_t(cstime));
+	seq_put_decimal_ll(m, ' ', priority);
+	seq_put_decimal_ll(m, ' ', nice);
+	seq_put_decimal_ll(m, ' ', num_threads);
+	seq_put_decimal_ull(m, ' ', 0);
+	seq_put_decimal_ull(m, ' ', start_time);
+	seq_put_decimal_ull(m, ' ', vsize);
+	seq_put_decimal_ull(m, ' ', mm ? get_mm_rss(mm) : 0);
+	seq_put_decimal_ull(m, ' ', rsslim);
+	seq_put_decimal_ull(m, ' ', mm ? (permitted ? mm->start_code : 1) : 0);
+	seq_put_decimal_ull(m, ' ', mm ? (permitted ? mm->end_code : 1) : 0);
+	seq_put_decimal_ull(m, ' ', (permitted && mm) ? mm->start_stack : 0);
+	seq_put_decimal_ull(m, ' ', esp);
+	seq_put_decimal_ull(m, ' ', eip);
+	/* The signal information here is obsolete.
+	 * It must be decimal for Linux 2.0 compatibility.
+	 * Use /proc/#/status for real-time signals.
+	 */
+	seq_put_decimal_ull(m, ' ', task->pending.signal.sig[0] & 0x7fffffffUL);
+	seq_put_decimal_ull(m, ' ', task->blocked.sig[0] & 0x7fffffffUL);
+	seq_put_decimal_ull(m, ' ', sigign.sig[0] & 0x7fffffffUL);
+	seq_put_decimal_ull(m, ' ', sigcatch.sig[0] & 0x7fffffffUL);
+	seq_put_decimal_ull(m, ' ', wchan);
+	seq_put_decimal_ull(m, ' ', 0);
+	seq_put_decimal_ull(m, ' ', 0);
+	seq_put_decimal_ll(m, ' ', task->exit_signal);
+	seq_put_decimal_ll(m, ' ', task_cpu(task));
+	seq_put_decimal_ull(m, ' ', task->rt_priority);
+	seq_put_decimal_ull(m, ' ', task->policy);
+	seq_put_decimal_ull(m, ' ', delayacct_blkio_ticks(task));
+	seq_put_decimal_ull(m, ' ', cputime_to_clock_t(gtime));
+	seq_put_decimal_ll(m, ' ', cputime_to_clock_t(cgtime));
+
+	if (mm && permitted) {
+		seq_put_decimal_ull(m, ' ', mm->start_data);
+		seq_put_decimal_ull(m, ' ', mm->end_data);
+		seq_put_decimal_ull(m, ' ', mm->start_brk);
+		seq_put_decimal_ull(m, ' ', mm->arg_start);
+		seq_put_decimal_ull(m, ' ', mm->arg_end);
+		seq_put_decimal_ull(m, ' ', mm->env_start);
+		seq_put_decimal_ull(m, ' ', mm->env_end);
+	} else {
+		seq_printf(m, " 0 0 0 0 0 0 0");
+	}
+
+	if (permitted)
+		seq_put_decimal_ll(m, ' ', task->exit_code);
+	else
+		seq_put_decimal_ll(m, ' ', 0);
+
+	seq_putc(m, '\n');
+	return 0;
+}
+
+int proc_pid_statm_mm(struct seq_file *m, struct pid_namespace *ns,
+		      struct pid *pid, struct task_struct *task,
+		      struct mm_struct *mm)
+{
+	unsigned long size = 0, resident = 0, shared = 0, text = 0, data = 0;
+
+	if (mm)
+		size = task_statm(mm, &shared, &text, &data, &resident);
+
+	/*
+	 * For quick read, open code by putting numbers directly
+	 * expected format is
+	 * seq_printf(m, "%lu %lu %lu %lu 0 %lu 0\n",
+	 *               size, resident, shared, text, data);
+	 */
+	seq_put_decimal_ull(m, 0, size);
+	seq_put_decimal_ull(m, ' ', resident);
+	seq_put_decimal_ull(m, ' ', shared);
+	seq_put_decimal_ull(m, ' ', text);
+	seq_put_decimal_ull(m, ' ', 0);
+	seq_put_decimal_ull(m, ' ', data);
+	seq_put_decimal_ull(m, ' ', 0);
+	seq_putc(m, '\n');
+
+	return 0;
+}
-- 
1.9.1
