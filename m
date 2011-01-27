From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V10 04/15] posix clocks: introduce a syscall for clock
 tuning.
Date: Thu, 27 Jan 2011 11:55:50 +0100
Message-ID: <2d5e2f3e6f388aa1848d40406646aab2e26a906f.1296124770.git.richard.cochran@omicron.at>
References: <cover.1296124770.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1296124770.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A new syscall is introduced that allows tuning of a POSIX clock. The
new call, clock_adjtime, takes two parameters, the clock ID and a
pointer to a struct timex. Any ADJTIMEX(2) operation may be requested
via this system call, but various POSIX clocks may or may not support
tuning.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 drivers/char/mmtimer.c       |    1 +
 include/linux/posix-timers.h |    4 +
 include/linux/syscalls.h     |    2 +
 kernel/compat.c              |  136 +++++++++++++++++++++++++++---------------
 kernel/posix-cpu-timers.c    |    6 ++
 kernel/posix-timers.c        |   35 +++++++++++
 6 files changed, 136 insertions(+), 48 deletions(-)

diff --git a/drivers/char/mmtimer.c b/drivers/char/mmtimer.c
index ecd0082..f365ae8 100644
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
index b2c14cb..24f01de 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -4,6 +4,7 @@
 #include <linux/spinlock.h>
 #include <linux/list.h>
 #include <linux/sched.h>
+#include <linux/timex.h>
 
 union cpu_time_count {
 	cputime_t cpu;
@@ -72,6 +73,7 @@ struct k_clock {
 	int (*clock_set) (const clockid_t which_clock,
 			  const struct timespec *tp);
 	int (*clock_get) (const clockid_t which_clock, struct timespec * tp);
+	int (*clock_adj) (const clockid_t which_clock, struct timex *tx);
 	int (*timer_create) (struct k_itimer *timer);
 	int (*nsleep) (const clockid_t which_clock, int flags,
 		       struct timespec *, struct timespec __user *);
@@ -91,6 +93,7 @@ void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock);
 int do_posix_clock_nonanosleep(const clockid_t, int flags, struct timespec *,
 			       struct timespec __user *);
 int do_posix_clock_nosettime(const clockid_t, const struct timespec *tp);
+int do_posix_clock_noadjtime(const clockid_t, struct timex *tx);
 
 /* function to call to trigger timer event */
 int posix_timer_event(struct k_itimer *timr, int si_private);
@@ -98,6 +101,7 @@ int posix_timer_event(struct k_itimer *timr, int si_private);
 int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
+int posix_cpu_clock_adj(const clockid_t which_clock, struct timex *tx);
 int posix_cpu_timer_create(struct k_itimer *timer);
 int posix_cpu_nsleep(const clockid_t which_clock, int flags,
 		     struct timespec *rqtp, struct timespec __user *rmtp);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 18cd068..bfacab9 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -311,6 +311,8 @@ asmlinkage long sys_clock_settime(clockid_t which_clock,
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
index 21b7ca2..7279cd1 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -203,6 +203,11 @@ static int common_timer_create(struct k_itimer *new_timer)
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
@@ -279,11 +284,13 @@ static __init int init_posix_timers(void)
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
@@ -291,6 +298,7 @@ static __init int init_posix_timers(void)
 		.clock_getres = posix_get_coarse_res,
 		.clock_get = posix_get_realtime_coarse,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
 	};
@@ -298,6 +306,7 @@ static __init int init_posix_timers(void)
 		.clock_getres = posix_get_coarse_res,
 		.clock_get = posix_get_monotonic_coarse,
 		.clock_set = do_posix_clock_nosettime,
+		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
 	};
@@ -934,6 +943,12 @@ int do_posix_clock_nosettime(const clockid_t clockid, const struct timespec *tp)
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
@@ -975,6 +990,26 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
 
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
