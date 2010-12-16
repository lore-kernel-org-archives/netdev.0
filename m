From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V7 2/8] posix clocks: introduce a syscall for clock tuning.
Date: Thu, 16 Dec 2010 16:42:20 +0100
Message-ID: <a93ce18c2987f7e102bc2ff5b12130211c222ea7.1292512461.git.richard.cochran@omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1292512461.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A new syscall is introduced that allows tuning of a POSIX clock. The
syscall is implemented for four architectures: arm, blackfin, powerpc,
and x86.

The new syscall, clock_adjtime, takes two parameters, the clock ID,
and a pointer to a struct timex. Any ADJTIMEX(2) operation may be
requested via this system call, but various POSIX clocks may or may
not support tuning.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 arch/arm/include/asm/unistd.h      |    1 +
 arch/arm/kernel/calls.S            |    1 +
 arch/blackfin/include/asm/unistd.h |    3 +-
 arch/blackfin/mach-common/entry.S  |    1 +
 arch/powerpc/include/asm/systbl.h  |    1 +
 arch/powerpc/include/asm/unistd.h  |    3 +-
 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/include/asm/unistd_32.h   |    3 +-
 arch/x86/include/asm/unistd_64.h   |    2 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 drivers/char/mmtimer.c             |    1 +
 include/linux/posix-timers.h       |    4 +
 include/linux/syscalls.h           |    2 +
 kernel/compat.c                    |  136 +++++++++++++++++++++++-------------
 kernel/posix-cpu-timers.c          |    6 ++
 kernel/posix-timers.c              |   35 +++++++++
 16 files changed, 150 insertions(+), 51 deletions(-)

diff --git a/arch/arm/include/asm/unistd.h b/arch/arm/include/asm/unistd.h
index c891eb7..f58d881 100644
--- a/arch/arm/include/asm/unistd.h
+++ b/arch/arm/include/asm/unistd.h
@@ -396,6 +396,7 @@
 #define __NR_fanotify_init		(__NR_SYSCALL_BASE+367)
 #define __NR_fanotify_mark		(__NR_SYSCALL_BASE+368)
 #define __NR_prlimit64			(__NR_SYSCALL_BASE+369)
+#define __NR_clock_adjtime		(__NR_SYSCALL_BASE+370)
 
 /*
  * The following SWIs are ARM private.
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 5c26ecc..430de4c 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -379,6 +379,7 @@
 		CALL(sys_fanotify_init)
 		CALL(sys_fanotify_mark)
 		CALL(sys_prlimit64)
+/* 370 */	CALL(sys_clock_adjtime)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/blackfin/include/asm/unistd.h b/arch/blackfin/include/asm/unistd.h
index 928ae97..e640c51 100644
--- a/arch/blackfin/include/asm/unistd.h
+++ b/arch/blackfin/include/asm/unistd.h
@@ -393,8 +393,9 @@
 #define __NR_fanotify_mark	372
 #define __NR_prlimit64		373
 #define __NR_cacheflush		374
+#define __NR_clock_adjtime	375
 
-#define __NR_syscall		375
+#define __NR_syscall		376
 #define NR_syscalls		__NR_syscall
 
 /* Old optional stuff no one actually uses */
diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-common/entry.S
index 2ca915e..cb6cc1e 100644
--- a/arch/blackfin/mach-common/entry.S
+++ b/arch/blackfin/mach-common/entry.S
@@ -1738,6 +1738,7 @@ ENTRY(_sys_call_table)
 	.long _sys_fanotify_mark
 	.long _sys_prlimit64
 	.long _sys_cacheflush
+	.long _sys_clock_adjtime	/* 375 */
 
 	.rept NR_syscalls-(.-_sys_call_table)/4
 	.long _sys_ni_syscall
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index aa0f1eb..6a1152c 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -348,3 +348,4 @@ COMPAT_SYS_SPU(sendmsg)
 COMPAT_SYS_SPU(recvmsg)
 COMPAT_SYS_SPU(recvmmsg)
 SYSCALL_SPU(accept4)
+COMPAT_SYS_SPU(clock_adjtime)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index 6151937..386de07 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -367,10 +367,11 @@
 #define __NR_recvmsg		342
 #define __NR_recvmmsg		343
 #define __NR_accept4		344
+#define __NR_clock_adjtime	345
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		345
+#define __NR_syscalls		346
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 518bb99..0ed7896 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -851,4 +851,5 @@ ia32_sys_call_table:
 	.quad sys_fanotify_init
 	.quad sys32_fanotify_mark
 	.quad sys_prlimit64		/* 340 */
+	.quad compat_sys_clock_adjtime
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index b766a5e..b6f73f1 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -346,10 +346,11 @@
 #define __NR_fanotify_init	338
 #define __NR_fanotify_mark	339
 #define __NR_prlimit64		340
+#define __NR_clock_adjtime	341
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 341
+#define NR_syscalls 342
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 363e9b8..5ee3085 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -669,6 +669,8 @@ __SYSCALL(__NR_fanotify_init, sys_fanotify_init)
 __SYSCALL(__NR_fanotify_mark, sys_fanotify_mark)
 #define __NR_prlimit64				302
 __SYSCALL(__NR_prlimit64, sys_prlimit64)
+#define __NR_clock_adjtime			303
+__SYSCALL(__NR_clock_adjtime, sys_clock_adjtime)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index b35786d..68c7b9a 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -340,3 +340,4 @@ ENTRY(sys_call_table)
 	.long sys_fanotify_init
 	.long sys_fanotify_mark
 	.long sys_prlimit64		/* 340 */
+	.long sys_clock_adjtime
diff --git a/drivers/char/mmtimer.c b/drivers/char/mmtimer.c
index e6d7562..98f2488 100644
--- a/drivers/char/mmtimer.c
+++ b/drivers/char/mmtimer.c
@@ -767,6 +767,7 @@ static struct k_clock sgi_clock = {
 	.res = 0,
 	.clock_set = sgi_clock_set,
 	.clock_get = sgi_clock_get,
+	.clock_adj = do_posix_clock_noadjtime,
 	.timer_create = sgi_timer_create,
 	.nsleep = do_posix_clock_nonanosleep,
 	.timer_set = sgi_timer_set,
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 3e23844..b05d9b8 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -4,6 +4,7 @@
 #include <linux/spinlock.h>
 #include <linux/list.h>
 #include <linux/sched.h>
+#include <linux/timex.h>
 
 union cpu_time_count {
 	cputime_t cpu;
@@ -71,6 +72,7 @@ struct k_clock {
 	int (*clock_getres) (const clockid_t which_clock, struct timespec *tp);
 	int (*clock_set) (const clockid_t which_clock, struct timespec * tp);
 	int (*clock_get) (const clockid_t which_clock, struct timespec * tp);
+	int (*clock_adj) (const clockid_t which_clock, struct timex *tx);
 	int (*timer_create) (struct k_itimer *timer);
 	int (*nsleep) (const clockid_t which_clock, int flags,
 		       struct timespec *, struct timespec __user *);
@@ -90,6 +92,7 @@ void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock);
 int do_posix_clock_nonanosleep(const clockid_t, int flags, struct timespec *,
 			       struct timespec __user *);
 int do_posix_clock_nosettime(const clockid_t, struct timespec *tp);
+int do_posix_clock_noadjtime(const clockid_t, struct timex *tx);
 
 /* function to call to trigger timer event */
 int posix_timer_event(struct k_itimer *timr, int si_private);
@@ -97,6 +100,7 @@ int posix_timer_event(struct k_itimer *timr, int si_private);
 int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
+int posix_cpu_clock_adj(const clockid_t which_clock, struct timex *tx);
 int posix_cpu_timer_create(struct k_itimer *timer);
 int posix_cpu_nsleep(const clockid_t which_clock, int flags,
 		     struct timespec *rqtp, struct timespec __user *rmtp);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index cacc27a..c76cefb 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -313,6 +313,8 @@ asmlinkage long sys_clock_settime(clockid_t which_clock,
 				const struct timespec __user *tp);
 asmlinkage long sys_clock_gettime(clockid_t which_clock,
 				struct timespec __user *tp);
+asmlinkage long sys_clock_adjtime(clockid_t which_clock,
+				struct timex __user *tx);
 asmlinkage long sys_clock_getres(clockid_t which_clock,
 				struct timespec __user *tp);
 asmlinkage long sys_clock_nanosleep(clockid_t which_clock, int flags,
diff --git a/kernel/compat.c b/kernel/compat.c
index c9e2ec0..38b1d2c 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -52,6 +52,64 @@ static int compat_put_timeval(struct compat_timeval __user *o,
 		put_user(i->tv_usec, &o->tv_usec)) ? -EFAULT : 0;
 }
 
+static int compat_get_timex(struct timex *txc, struct compat_timex __user *utp)
+{
+	memset(txc, 0, sizeof(struct timex));
+
+	if (!access_ok(VERIFY_READ, utp, sizeof(struct compat_timex)) ||
+			__get_user(txc->modes, &utp->modes) ||
+			__get_user(txc->offset, &utp->offset) ||
+			__get_user(txc->freq, &utp->freq) ||
+			__get_user(txc->maxerror, &utp->maxerror) ||
+			__get_user(txc->esterror, &utp->esterror) ||
+			__get_user(txc->status, &utp->status) ||
+			__get_user(txc->constant, &utp->constant) ||
+			__get_user(txc->precision, &utp->precision) ||
+			__get_user(txc->tolerance, &utp->tolerance) ||
+			__get_user(txc->time.tv_sec, &utp->time.tv_sec) ||
+			__get_user(txc->time.tv_usec, &utp->time.tv_usec) ||
+			__get_user(txc->tick, &utp->tick) ||
+			__get_user(txc->ppsfreq, &utp->ppsfreq) ||
+			__get_user(txc->jitter, &utp->jitter) ||
+			__get_user(txc->shift, &utp->shift) ||
+			__get_user(txc->stabil, &utp->stabil) ||
+			__get_user(txc->jitcnt, &utp->jitcnt) ||
+			__get_user(txc->calcnt, &utp->calcnt) ||
+			__get_user(txc->errcnt, &utp->errcnt) ||
+			__get_user(txc->stbcnt, &utp->stbcnt))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int compat_put_timex(struct compat_timex __user *utp, struct timex *txc)
+{
+	if (!access_ok(VERIFY_WRITE, utp, sizeof(struct compat_timex)) ||
+			__put_user(txc->modes, &utp->modes) ||
+			__put_user(txc->offset, &utp->offset) ||
+			__put_user(txc->freq, &utp->freq) ||
+			__put_user(txc->maxerror, &utp->maxerror) ||
+			__put_user(txc->esterror, &utp->esterror) ||
+			__put_user(txc->status, &utp->status) ||
+			__put_user(txc->constant, &utp->constant) ||
+			__put_user(txc->precision, &utp->precision) ||
+			__put_user(txc->tolerance, &utp->tolerance) ||
+			__put_user(txc->time.tv_sec, &utp->time.tv_sec) ||
+			__put_user(txc->time.tv_usec, &utp->time.tv_usec) ||
+			__put_user(txc->tick, &utp->tick) ||
+			__put_user(txc->ppsfreq, &utp->ppsfreq) ||
+			__put_user(txc->jitter, &utp->jitter) ||
+			__put_user(txc->shift, &utp->shift) ||
+			__put_user(txc->stabil, &utp->stabil) ||
+			__put_user(txc->jitcnt, &utp->jitcnt) ||
+			__put_user(txc->calcnt, &utp->calcnt) ||
+			__put_user(txc->errcnt, &utp->errcnt) ||
+			__put_user(txc->stbcnt, &utp->stbcnt) ||
+			__put_user(txc->tai, &utp->tai))
+		return -EFAULT;
+	return 0;
+}
+
 asmlinkage long compat_sys_gettimeofday(struct compat_timeval __user *tv,
 		struct timezone __user *tz)
 {
@@ -617,6 +675,29 @@ long compat_sys_clock_gettime(clockid_t which_clock,
 	return err;
 }
 
+long compat_sys_clock_adjtime(clockid_t which_clock,
+		struct compat_timex __user *utp)
+{
+	struct timex txc;
+	mm_segment_t oldfs;
+	int err, ret;
+
+	err = compat_get_timex(&txc, utp);
+	if (err)
+		return err;
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = sys_clock_adjtime(which_clock, (struct timex __user *) &txc);
+	set_fs(oldfs);
+
+	err = compat_put_timex(utp, &txc);
+	if (err)
+		return err;
+
+	return ret;
+}
+
 long compat_sys_clock_getres(clockid_t which_clock,
 		struct compat_timespec __user *tp)
 {
@@ -951,58 +1032,17 @@ asmlinkage long compat_sys_rt_sigsuspend(compat_sigset_t __user *unewset, compat
 asmlinkage long compat_sys_adjtimex(struct compat_timex __user *utp)
 {
 	struct timex txc;
-	int ret;
-
-	memset(&txc, 0, sizeof(struct timex));
+	int err, ret;
 
-	if (!access_ok(VERIFY_READ, utp, sizeof(struct compat_timex)) ||
-			__get_user(txc.modes, &utp->modes) ||
-			__get_user(txc.offset, &utp->offset) ||
-			__get_user(txc.freq, &utp->freq) ||
-			__get_user(txc.maxerror, &utp->maxerror) ||
-			__get_user(txc.esterror, &utp->esterror) ||
-			__get_user(txc.status, &utp->status) ||
-			__get_user(txc.constant, &utp->constant) ||
-			__get_user(txc.precision, &utp->precision) ||
-			__get_user(txc.tolerance, &utp->tolerance) ||
-			__get_user(txc.time.tv_sec, &utp->time.tv_sec) ||
-			__get_user(txc.time.tv_usec, &utp->time.tv_usec) ||
-			__get_user(txc.tick, &utp->tick) ||
-			__get_user(txc.ppsfreq, &utp->ppsfreq) ||
-			__get_user(txc.jitter, &utp->jitter) ||
-			__get_user(txc.shift, &utp->shift) ||
-			__get_user(txc.stabil, &utp->stabil) ||
-			__get_user(txc.jitcnt, &utp->jitcnt) ||
-			__get_user(txc.calcnt, &utp->calcnt) ||
-			__get_user(txc.errcnt, &utp->errcnt) ||
-			__get_user(txc.stbcnt, &utp->stbcnt))
-		return -EFAULT;
+	err = compat_get_timex(&txc, utp);
+	if (err)
+		return err;
 
 	ret = do_adjtimex(&txc);
 
-	if (!access_ok(VERIFY_WRITE, utp, sizeof(struct compat_timex)) ||
-			__put_user(txc.modes, &utp->modes) ||
-			__put_user(txc.offset, &utp->offset) ||
-			__put_user(txc.freq, &utp->freq) ||
-			__put_user(txc.maxerror, &utp->maxerror) ||
-			__put_user(txc.esterror, &utp->esterror) ||
-			__put_user(txc.status, &utp->status) ||
-			__put_user(txc.constant, &utp->constant) ||
-			__put_user(txc.precision, &utp->precision) ||
-			__put_user(txc.tolerance, &utp->tolerance) ||
-			__put_user(txc.time.tv_sec, &utp->time.tv_sec) ||
-			__put_user(txc.time.tv_usec, &utp->time.tv_usec) ||
-			__put_user(txc.tick, &utp->tick) ||
-			__put_user(txc.ppsfreq, &utp->ppsfreq) ||
-			__put_user(txc.jitter, &utp->jitter) ||
-			__put_user(txc.shift, &utp->shift) ||
-			__put_user(txc.stabil, &utp->stabil) ||
-			__put_user(txc.jitcnt, &utp->jitcnt) ||
-			__put_user(txc.calcnt, &utp->calcnt) ||
-			__put_user(txc.errcnt, &utp->errcnt) ||
-			__put_user(txc.stbcnt, &utp->stbcnt) ||
-			__put_user(txc.tai, &utp->tai))
-		ret = -EFAULT;
+	err = compat_put_timex(utp, &txc);
+	if (err)
+		return err;
 
 	return ret;
 }
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index 05bb717..0206116 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -207,6 +207,10 @@ int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *tp)
 	return error;
 }
 
+int posix_cpu_clock_adj(const clockid_t which_clock, struct timex *tx)
+{
+	return -EOPNOTSUPP;
+}
 
 /*
  * Sample a per-thread clock for the given task.
@@ -1610,6 +1614,7 @@ static __init int init_posix_cpu_timers(void)
 		.clock_getres = process_cpu_clock_getres,
 		.clock_get = process_cpu_clock_get,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = process_cpu_timer_create,
 		.nsleep = process_cpu_nsleep,
 		.nsleep_restart = process_cpu_nsleep_restart,
@@ -1618,6 +1623,7 @@ static __init int init_posix_cpu_timers(void)
 		.clock_getres = thread_cpu_clock_getres,
 		.clock_get = thread_cpu_clock_get,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = thread_cpu_timer_create,
 		.nsleep = thread_cpu_nsleep,
 		.nsleep_restart = thread_cpu_nsleep_restart,
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 9ca4973..502bde4 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -197,6 +197,11 @@ static int common_timer_create(struct k_itimer *new_timer)
 	return 0;
 }
 
+static inline int common_clock_adj(const clockid_t which_clock, struct timex *t)
+{
+	return do_adjtimex(t);
+}
+
 static int no_timer_create(struct k_itimer *new_timer)
 {
 	return -EOPNOTSUPP;
@@ -273,11 +278,13 @@ static __init int init_posix_timers(void)
 		.clock_getres = hrtimer_get_res,
 		.clock_get = posix_ktime_get_ts,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 	};
 	struct k_clock clock_monotonic_raw = {
 		.clock_getres = hrtimer_get_res,
 		.clock_get = posix_get_monotonic_raw,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
 	};
@@ -285,6 +292,7 @@ static __init int init_posix_timers(void)
 		.clock_getres = posix_get_coarse_res,
 		.clock_get = posix_get_realtime_coarse,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
 	};
@@ -292,6 +300,7 @@ static __init int init_posix_timers(void)
 		.clock_getres = posix_get_coarse_res,
 		.clock_get = posix_get_monotonic_coarse,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
 	};
@@ -928,6 +937,12 @@ int do_posix_clock_nosettime(const clockid_t clockid, struct timespec *tp)
 }
 EXPORT_SYMBOL_GPL(do_posix_clock_nosettime);
 
+int do_posix_clock_noadjtime(const clockid_t which_clock, struct timex *t)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL_GPL(do_posix_clock_noadjtime);
+
 int do_posix_clock_nonanosleep(const clockid_t clock, int flags,
 			       struct timespec *t, struct timespec __user *r)
 {
@@ -969,6 +984,26 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
 
 }
 
+SYSCALL_DEFINE2(clock_adjtime, const clockid_t, which_clock,
+		struct timex __user *, utx)
+{
+	struct timex ktx;
+	int err;
+
+	if (copy_from_user(&ktx, utx, sizeof(ktx)))
+		return -EFAULT;
+
+	if (invalid_clockid(which_clock))
+		return -EINVAL;
+
+	err = CLOCK_DISPATCH(which_clock, clock_adj, (which_clock, &ktx));
+
+	if (copy_to_user(utx, &ktx, sizeof(ktx)))
+		return -EFAULT;
+
+	return err;
+}
+
 SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock,
 		struct timespec __user *, tp)
 {
-- 
1.7.0.4
