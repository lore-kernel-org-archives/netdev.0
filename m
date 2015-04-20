From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 05/11] time/posix-timers:Convert to the 64bit methods for k_clock callback functions
Date: Mon, 20 Apr 2015 13:57:33 +0800
Message-ID: <1429509459-17068-6-git-send-email-baolin.wang@linaro.org>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Cc: arnd@arndb.de, john.stultz@linaro.org, heenasirwani@gmail.com,
	pang.xunlei@linaro.org, peterz@infradead.org,
	rafael.j.wysocki@intel.com, gregkh@linuxfoundation.org,
	richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	baolin.wang@linaro.org, y2038@lists.linaro.org
To: tglx@linutronix.de
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts the timepsec type to timespec64 type, and converts the
itimerspec type to itimerspec64 type for the k_clock callback functions.

This patch also converts the timespec type to timespec64 type for timekeeping_clocktai()
function which is used only in the posix-timers.c file.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/timekeeping.h |    4 +-
 kernel/time/posix-timers.c  |  102 +++++++++++++++++++++++--------------------
 kernel/time/timekeeping.h   |    2 +-
 3 files changed, 57 insertions(+), 51 deletions(-)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index c6d5ae9..bd3df93 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -242,9 +242,9 @@ static inline void get_monotonic_boottime64(struct timespec64 *ts)
 	*ts = ktime_to_timespec64(ktime_get_boottime());
 }
 
-static inline void timekeeping_clocktai(struct timespec *ts)
+static inline void timekeeping_clocktai(struct timespec64 *ts)
 {
-	*ts = ktime_to_timespec(ktime_get_clocktai());
+	*ts = ktime_to_timespec64(ktime_get_clocktai());
 }
 
 /*
diff --git a/kernel/time/posix-timers.c b/kernel/time/posix-timers.c
index 9070387..47d1abf 100644
--- a/kernel/time/posix-timers.c
+++ b/kernel/time/posix-timers.c
@@ -132,9 +132,9 @@ static struct k_clock posix_clocks[MAX_CLOCKS];
 static int common_nsleep(const clockid_t, int flags, struct timespec *t,
 			 struct timespec __user *rmtp);
 static int common_timer_create(struct k_itimer *new_timer);
-static void common_timer_get(struct k_itimer *, struct itimerspec *);
+static void common_timer_get(struct k_itimer *, struct itimerspec64 *);
 static int common_timer_set(struct k_itimer *, int,
-			    struct itimerspec *, struct itimerspec *);
+			    struct itimerspec64 *, struct itimerspec64 *);
 static int common_timer_del(struct k_itimer *timer);
 
 static enum hrtimer_restart posix_timer_fn(struct hrtimer *data);
@@ -203,17 +203,20 @@ static inline void unlock_timer(struct k_itimer *timr, unsigned long flags)
 }
 
 /* Get clock_realtime */
-static int posix_clock_realtime_get(clockid_t which_clock, struct timespec *tp)
+static int posix_clock_realtime_get(clockid_t which_clock,
+				    struct timespec64 *tp)
 {
-	ktime_get_real_ts(tp);
+	ktime_get_real_ts64(tp);
 	return 0;
 }
 
 /* Set clock_realtime */
 static int posix_clock_realtime_set(const clockid_t which_clock,
-				    const struct timespec *tp)
+				    const struct timespec64 *tp)
 {
-	return do_sys_settimeofday(tp, NULL);
+	struct timespec ts = timespec64_to_timespec(*tp);
+
+	return do_sys_settimeofday(&ts, NULL);
 }
 
 static int posix_clock_realtime_adj(const clockid_t which_clock,
@@ -225,48 +228,51 @@ static int posix_clock_realtime_adj(const clockid_t which_clock,
 /*
  * Get monotonic time for posix timers
  */
-static int posix_ktime_get_ts(clockid_t which_clock, struct timespec *tp)
+static int posix_ktime_get_ts(clockid_t which_clock, struct timespec64 *tp)
 {
-	ktime_get_ts(tp);
+	ktime_get_ts64(tp);
 	return 0;
 }
 
 /*
  * Get monotonic-raw time for posix timers
  */
-static int posix_get_monotonic_raw(clockid_t which_clock, struct timespec *tp)
+static int posix_get_monotonic_raw(clockid_t which_clock, struct timespec64 *tp)
 {
-	getrawmonotonic(tp);
+	getrawmonotonic64(tp);
 	return 0;
 }
 
 
-static int posix_get_realtime_coarse(clockid_t which_clock, struct timespec *tp)
+static int posix_get_realtime_coarse(clockid_t which_clock,
+				     struct timespec64 *tp)
 {
-	*tp = current_kernel_time();
+	*tp = current_kernel_time64();
 	return 0;
 }
 
 static int posix_get_monotonic_coarse(clockid_t which_clock,
-						struct timespec *tp)
+						struct timespec64 *tp)
 {
-	*tp = get_monotonic_coarse();
+	*tp = get_monotonic_coarse64();
 	return 0;
 }
 
-static int posix_get_coarse_res(const clockid_t which_clock, struct timespec *tp)
+static int posix_get_coarse_res(const clockid_t which_clock,
+				struct timespec64 *tp)
 {
-	*tp = ktime_to_timespec(KTIME_LOW_RES);
+	*tp = ktime_to_timespec64(KTIME_LOW_RES);
 	return 0;
 }
 
-static int posix_get_boottime(const clockid_t which_clock, struct timespec *tp)
+static int posix_get_boottime(const clockid_t which_clock,
+			      struct timespec64 *tp)
 {
-	get_monotonic_boottime(tp);
+	get_monotonic_boottime64(tp);
 	return 0;
 }
 
-static int posix_get_tai(clockid_t which_clock, struct timespec *tp)
+static int posix_get_tai(clockid_t which_clock, struct timespec64 *tp)
 {
 	timekeeping_clocktai(tp);
 	return 0;
@@ -278,57 +284,57 @@ static int posix_get_tai(clockid_t which_clock, struct timespec *tp)
 static __init int init_posix_timers(void)
 {
 	struct k_clock clock_realtime = {
-		.clock_getres	= hrtimer_get_res,
-		.clock_get	= posix_clock_realtime_get,
-		.clock_set	= posix_clock_realtime_set,
+		.clock_getres64	= hrtimer_get_res64,
+		.clock_get64	= posix_clock_realtime_get,
+		.clock_set64	= posix_clock_realtime_set,
 		.clock_adj	= posix_clock_realtime_adj,
 		.nsleep		= common_nsleep,
 		.nsleep_restart	= hrtimer_nanosleep_restart,
 		.timer_create	= common_timer_create,
-		.timer_set	= common_timer_set,
-		.timer_get	= common_timer_get,
+		.timer_set64	= common_timer_set,
+		.timer_get64	= common_timer_get,
 		.timer_del	= common_timer_del,
 	};
 	struct k_clock clock_monotonic = {
-		.clock_getres	= hrtimer_get_res,
-		.clock_get	= posix_ktime_get_ts,
+		.clock_getres64	= hrtimer_get_res64,
+		.clock_get64	= posix_ktime_get_ts,
 		.nsleep		= common_nsleep,
 		.nsleep_restart	= hrtimer_nanosleep_restart,
 		.timer_create	= common_timer_create,
-		.timer_set	= common_timer_set,
-		.timer_get	= common_timer_get,
+		.timer_set64	= common_timer_set,
+		.timer_get64	= common_timer_get,
 		.timer_del	= common_timer_del,
 	};
 	struct k_clock clock_monotonic_raw = {
-		.clock_getres	= hrtimer_get_res,
-		.clock_get	= posix_get_monotonic_raw,
+		.clock_getres64	= hrtimer_get_res64,
+		.clock_get64	= posix_get_monotonic_raw,
 	};
 	struct k_clock clock_realtime_coarse = {
-		.clock_getres	= posix_get_coarse_res,
-		.clock_get	= posix_get_realtime_coarse,
+		.clock_getres64	= posix_get_coarse_res,
+		.clock_get64	= posix_get_realtime_coarse,
 	};
 	struct k_clock clock_monotonic_coarse = {
-		.clock_getres	= posix_get_coarse_res,
-		.clock_get	= posix_get_monotonic_coarse,
+		.clock_getres64	= posix_get_coarse_res,
+		.clock_get64	= posix_get_monotonic_coarse,
 	};
 	struct k_clock clock_tai = {
-		.clock_getres	= hrtimer_get_res,
-		.clock_get	= posix_get_tai,
+		.clock_getres64	= hrtimer_get_res64,
+		.clock_get64	= posix_get_tai,
 		.nsleep		= common_nsleep,
 		.nsleep_restart	= hrtimer_nanosleep_restart,
 		.timer_create	= common_timer_create,
-		.timer_set	= common_timer_set,
-		.timer_get	= common_timer_get,
+		.timer_set64	= common_timer_set,
+		.timer_get64	= common_timer_get,
 		.timer_del	= common_timer_del,
 	};
 	struct k_clock clock_boottime = {
-		.clock_getres	= hrtimer_get_res,
-		.clock_get	= posix_get_boottime,
+		.clock_getres64	= hrtimer_get_res64,
+		.clock_get64	= posix_get_boottime,
 		.nsleep		= common_nsleep,
 		.nsleep_restart	= hrtimer_nanosleep_restart,
 		.timer_create	= common_timer_create,
-		.timer_set	= common_timer_set,
-		.timer_get	= common_timer_get,
+		.timer_set64	= common_timer_set,
+		.timer_get64	= common_timer_get,
 		.timer_del	= common_timer_del,
 	};
 
@@ -726,7 +732,7 @@ static struct k_itimer *__lock_timer(timer_t timer_id, unsigned long *flags)
  * report.
  */
 static void
-common_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting)
+common_timer_get(struct k_itimer *timr, struct itimerspec64 *cur_setting)
 {
 	ktime_t now, remaining, iv;
 	struct hrtimer *timer = &timr->it.real.timer;
@@ -737,7 +743,7 @@ common_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting)
 
 	/* interval timer ? */
 	if (iv.tv64)
-		cur_setting->it_interval = ktime_to_timespec(iv);
+		cur_setting->it_interval = ktime_to_timespec64(iv);
 	else if (!hrtimer_active(timer) &&
 		 (timr->it_sigev_notify & ~SIGEV_THREAD_ID) != SIGEV_NONE)
 		return;
@@ -763,7 +769,7 @@ common_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting)
 		if ((timr->it_sigev_notify & ~SIGEV_THREAD_ID) != SIGEV_NONE)
 			cur_setting->it_value.tv_nsec = 1;
 	} else
-		cur_setting->it_value = ktime_to_timespec(remaining);
+		cur_setting->it_value = ktime_to_timespec64(remaining);
 }
 
 /* Get the time remaining on a POSIX.1b interval timer. */
@@ -830,7 +836,7 @@ SYSCALL_DEFINE1(timer_getoverrun, timer_t, timer_id)
 /* timr->it_lock is taken. */
 static int
 common_timer_set(struct k_itimer *timr, int flags,
-		 struct itimerspec *new_setting, struct itimerspec *old_setting)
+		 struct itimerspec64 *new_setting, struct itimerspec64 *old_setting)
 {
 	struct hrtimer *timer = &timr->it.real.timer;
 	enum hrtimer_mode mode;
@@ -859,10 +865,10 @@ common_timer_set(struct k_itimer *timr, int flags,
 	hrtimer_init(&timr->it.real.timer, timr->it_clock, mode);
 	timr->it.real.timer.function = posix_timer_fn;
 
-	hrtimer_set_expires(timer, timespec_to_ktime(new_setting->it_value));
+	hrtimer_set_expires(timer, timespec64_to_ktime(new_setting->it_value));
 
 	/* Convert interval */
-	timr->it.real.interval = timespec_to_ktime(new_setting->it_interval);
+	timr->it.real.interval = timespec64_to_ktime(new_setting->it_interval);
 
 	/* SIGEV_NONE timers are not queued ! See common_timer_get */
 	if (((timr->it_sigev_notify & ~SIGEV_THREAD_ID) == SIGEV_NONE)) {
diff --git a/kernel/time/timekeeping.h b/kernel/time/timekeeping.h
index 1d91416..144af14 100644
--- a/kernel/time/timekeeping.h
+++ b/kernel/time/timekeeping.h
@@ -15,7 +15,7 @@ extern u64 timekeeping_max_deferment(void);
 extern int timekeeping_inject_offset(struct timespec *ts);
 extern s32 timekeeping_get_tai_offset(void);
 extern void timekeeping_set_tai_offset(s32 tai_offset);
-extern void timekeeping_clocktai(struct timespec *ts);
+extern void timekeeping_clocktai(struct timespec64 *ts);
 extern int timekeeping_suspend(void);
 extern void timekeeping_resume(void);
 
-- 
1.7.9.5
