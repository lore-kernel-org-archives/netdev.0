From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 10/11] time/posix-cpu-timers:Convert to the 64bit methods for k_clock structure
Date: Mon, 20 Apr 2015 13:57:38 +0800
Message-ID: <1429509459-17068-11-git-send-email-baolin.wang@linaro.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35549 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689AbbDTF7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 01:59:43 -0400
Received: by pabtp1 with SMTP id tp1so196490908pab.2
        for <netdev@vger.kernel.org>; Sun, 19 Apr 2015 22:59:43 -0700 (PDT)
In-Reply-To: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes to the new methods of k_clock structure with timespec64
type, converts the timespec/itimerspec type to timespec64/itimerspec64 type
for the callback function in posix-cpu-timers.c file.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 kernel/time/posix-cpu-timers.c |   83 +++++++++++++++++++++-------------------
 1 file changed, 44 insertions(+), 39 deletions(-)

diff --git a/kernel/time/posix-cpu-timers.c b/kernel/time/posix-cpu-timers.c
index 0075da7..51cfead 100644
--- a/kernel/time/posix-cpu-timers.c
+++ b/kernel/time/posix-cpu-timers.c
@@ -52,7 +52,7 @@ static int check_clock(const clockid_t which_clock)
 }
 
 static inline unsigned long long
-timespec_to_sample(const clockid_t which_clock, const struct timespec *tp)
+timespec64_to_sample(const clockid_t which_clock, const struct timespec64 *tp)
 {
 	unsigned long long ret;
 
@@ -60,19 +60,19 @@ timespec_to_sample(const clockid_t which_clock, const struct timespec *tp)
 	if (CPUCLOCK_WHICH(which_clock) == CPUCLOCK_SCHED) {
 		ret = (unsigned long long)tp->tv_sec * NSEC_PER_SEC + tp->tv_nsec;
 	} else {
-		ret = cputime_to_expires(timespec_to_cputime(tp));
+		ret = cputime_to_expires(timespec64_to_cputime(tp));
 	}
 	return ret;
 }
 
-static void sample_to_timespec(const clockid_t which_clock,
+static void sample_to_timespec64(const clockid_t which_clock,
 			       unsigned long long expires,
-			       struct timespec *tp)
+			       struct timespec64 *tp)
 {
 	if (CPUCLOCK_WHICH(which_clock) == CPUCLOCK_SCHED)
-		*tp = ns_to_timespec(expires);
+		*tp = ns_to_timespec64(expires);
 	else
-		cputime_to_timespec((__force cputime_t)expires, tp);
+		cputime_to_timespec64((__force cputime_t)expires, tp);
 }
 
 /*
@@ -141,7 +141,7 @@ static inline unsigned long long virt_ticks(struct task_struct *p)
 }
 
 static int
-posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *tp)
+posix_cpu_clock_getres(const clockid_t which_clock, struct timespec64 *tp)
 {
 	int error = check_clock(which_clock);
 	if (!error) {
@@ -160,7 +160,7 @@ posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *tp)
 }
 
 static int
-posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *tp)
+posix_cpu_clock_set(const clockid_t which_clock, const struct timespec64 *tp)
 {
 	/*
 	 * You can never reset a CPU clock, but we check for other errors
@@ -263,7 +263,7 @@ static int cpu_clock_sample_group(const clockid_t which_clock,
 
 static int posix_cpu_clock_get_task(struct task_struct *tsk,
 				    const clockid_t which_clock,
-				    struct timespec *tp)
+				    struct timespec64 *tp)
 {
 	int err = -EINVAL;
 	unsigned long long rtn;
@@ -277,13 +277,14 @@ static int posix_cpu_clock_get_task(struct task_struct *tsk,
 	}
 
 	if (!err)
-		sample_to_timespec(which_clock, rtn, tp);
+		sample_to_timespec64(which_clock, rtn, tp);
 
 	return err;
 }
 
 
-static int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *tp)
+static int posix_cpu_clock_get(const clockid_t which_clock,
+				struct timespec64 *tp)
 {
 	const pid_t pid = CPUCLOCK_PID(which_clock);
 	int err = -EINVAL;
@@ -598,7 +599,7 @@ static inline void posix_cpu_timer_kick_nohz(void) { }
  * and try again.  (This happens when the timer is in the middle of firing.)
  */
 static int posix_cpu_timer_set(struct k_itimer *timer, int timer_flags,
-			       struct itimerspec *new, struct itimerspec *old)
+			       struct itimerspec64 *new, struct itimerspec64 *old)
 {
 	unsigned long flags;
 	struct sighand_struct *sighand;
@@ -608,7 +609,7 @@ static int posix_cpu_timer_set(struct k_itimer *timer, int timer_flags,
 
 	WARN_ON_ONCE(p == NULL);
 
-	new_expires = timespec_to_sample(timer->it_clock, &new->it_value);
+	new_expires = timespec64_to_sample(timer->it_clock, &new->it_value);
 
 	/*
 	 * Protect against sighand release/switch in exit/exec and p->cpu_timers
@@ -669,7 +670,7 @@ static int posix_cpu_timer_set(struct k_itimer *timer, int timer_flags,
 			bump_cpu_timer(timer, val);
 			if (val < timer->it.cpu.expires) {
 				old_expires = timer->it.cpu.expires - val;
-				sample_to_timespec(timer->it_clock,
+				sample_to_timespec64(timer->it_clock,
 						   old_expires,
 						   &old->it_value);
 			} else {
@@ -709,7 +710,7 @@ static int posix_cpu_timer_set(struct k_itimer *timer, int timer_flags,
 	 * Install the new reload setting, and
 	 * set up the signal and overrun bookkeeping.
 	 */
-	timer->it.cpu.incr = timespec_to_sample(timer->it_clock,
+	timer->it.cpu.incr = timespec64_to_sample(timer->it_clock,
 						&new->it_interval);
 
 	/*
@@ -734,7 +735,7 @@ static int posix_cpu_timer_set(struct k_itimer *timer, int timer_flags,
 	ret = 0;
  out:
 	if (old) {
-		sample_to_timespec(timer->it_clock,
+		sample_to_timespec64(timer->it_clock,
 				   old_incr, &old->it_interval);
 	}
 	if (!ret)
@@ -742,7 +743,7 @@ static int posix_cpu_timer_set(struct k_itimer *timer, int timer_flags,
 	return ret;
 }
 
-static void posix_cpu_timer_get(struct k_itimer *timer, struct itimerspec *itp)
+static void posix_cpu_timer_get(struct k_itimer *timer, struct itimerspec64 *itp)
 {
 	unsigned long long now;
 	struct task_struct *p = timer->it.cpu.task;
@@ -752,7 +753,7 @@ static void posix_cpu_timer_get(struct k_itimer *timer, struct itimerspec *itp)
 	/*
 	 * Easy part: convert the reload time.
 	 */
-	sample_to_timespec(timer->it_clock,
+	sample_to_timespec64(timer->it_clock,
 			   timer->it.cpu.incr, &itp->it_interval);
 
 	if (timer->it.cpu.expires == 0) {	/* Timer not armed at all.  */
@@ -782,7 +783,7 @@ static void posix_cpu_timer_get(struct k_itimer *timer, struct itimerspec *itp)
 			 * Call the timer disarmed, nothing else to do.
 			 */
 			timer->it.cpu.expires = 0;
-			sample_to_timespec(timer->it_clock, timer->it.cpu.expires,
+			sample_to_timespec64(timer->it_clock, timer->it.cpu.expires,
 					   &itp->it_value);
 		} else {
 			cpu_timer_sample_group(timer->it_clock, p, &now);
@@ -791,7 +792,7 @@ static void posix_cpu_timer_get(struct k_itimer *timer, struct itimerspec *itp)
 	}
 
 	if (now < timer->it.cpu.expires) {
-		sample_to_timespec(timer->it_clock,
+		sample_to_timespec64(timer->it_clock,
 				   timer->it.cpu.expires - now,
 				   &itp->it_value);
 	} else {
@@ -1248,6 +1249,8 @@ static int do_cpu_nanosleep(const clockid_t which_clock, int flags,
 			    struct timespec *rqtp, struct itimerspec *it)
 {
 	struct k_itimer timer;
+	struct timespec64 ts64;
+	struct itimerspec64 *it64;
 	int error;
 
 	/*
@@ -1260,13 +1263,14 @@ static int do_cpu_nanosleep(const clockid_t which_clock, int flags,
 	error = posix_cpu_timer_create(&timer);
 	timer.it_process = current;
 	if (!error) {
-		static struct itimerspec zero_it;
+		static struct itimerspec64 zero_it;
 
 		memset(it, 0, sizeof *it);
 		it->it_value = *rqtp;
 
 		spin_lock_irq(&timer.it_lock);
-		error = posix_cpu_timer_set(&timer, flags, it, NULL);
+		*it64 = itimerspec_to_itimerspec64(*it);
+		error = posix_cpu_timer_set(&timer, flags, it64, NULL);
 		if (error) {
 			spin_unlock_irq(&timer.it_lock);
 			return error;
@@ -1295,8 +1299,9 @@ static int do_cpu_nanosleep(const clockid_t which_clock, int flags,
 		/*
 		 * We were interrupted by a signal.
 		 */
-		sample_to_timespec(which_clock, timer.it.cpu.expires, rqtp);
-		error = posix_cpu_timer_set(&timer, 0, &zero_it, it);
+		sample_to_timespec64(which_clock, timer.it.cpu.expires, &ts64);
+		*rqtp = timespec64_to_timespec(ts64);
+		error = posix_cpu_timer_set(&timer, 0, &zero_it, it64);
 		if (!error) {
 			/*
 			 * Timer is now unarmed, deletion can not fail.
@@ -1395,12 +1400,12 @@ static long posix_cpu_nsleep_restart(struct restart_block *restart_block)
 #define THREAD_CLOCK	MAKE_THREAD_CPUCLOCK(0, CPUCLOCK_SCHED)
 
 static int process_cpu_clock_getres(const clockid_t which_clock,
-				    struct timespec *tp)
+				    struct timespec64 *tp)
 {
 	return posix_cpu_clock_getres(PROCESS_CLOCK, tp);
 }
 static int process_cpu_clock_get(const clockid_t which_clock,
-				 struct timespec *tp)
+				 struct timespec64 *tp)
 {
 	return posix_cpu_clock_get(PROCESS_CLOCK, tp);
 }
@@ -1420,12 +1425,12 @@ static long process_cpu_nsleep_restart(struct restart_block *restart_block)
 	return -EINVAL;
 }
 static int thread_cpu_clock_getres(const clockid_t which_clock,
-				   struct timespec *tp)
+				   struct timespec64 *tp)
 {
 	return posix_cpu_clock_getres(THREAD_CLOCK, tp);
 }
 static int thread_cpu_clock_get(const clockid_t which_clock,
-				struct timespec *tp)
+				struct timespec64 *tp)
 {
 	return posix_cpu_clock_get(THREAD_CLOCK, tp);
 }
@@ -1436,37 +1441,37 @@ static int thread_cpu_timer_create(struct k_itimer *timer)
 }
 
 struct k_clock clock_posix_cpu = {
-	.clock_getres	= posix_cpu_clock_getres,
-	.clock_set	= posix_cpu_clock_set,
-	.clock_get	= posix_cpu_clock_get,
+	.clock_getres64	= posix_cpu_clock_getres,
+	.clock_set64	= posix_cpu_clock_set,
+	.clock_get64	= posix_cpu_clock_get,
 	.timer_create	= posix_cpu_timer_create,
 	.nsleep		= posix_cpu_nsleep,
 	.nsleep_restart	= posix_cpu_nsleep_restart,
-	.timer_set	= posix_cpu_timer_set,
+	.timer_set64	= posix_cpu_timer_set,
 	.timer_del	= posix_cpu_timer_del,
-	.timer_get	= posix_cpu_timer_get,
+	.timer_get64	= posix_cpu_timer_get,
 };
 
 static __init int init_posix_cpu_timers(void)
 {
 	struct k_clock process = {
-		.clock_getres	= process_cpu_clock_getres,
-		.clock_get	= process_cpu_clock_get,
+		.clock_getres64	= process_cpu_clock_getres,
+		.clock_get64	= process_cpu_clock_get,
 		.timer_create	= process_cpu_timer_create,
 		.nsleep		= process_cpu_nsleep,
 		.nsleep_restart	= process_cpu_nsleep_restart,
 	};
 	struct k_clock thread = {
-		.clock_getres	= thread_cpu_clock_getres,
-		.clock_get	= thread_cpu_clock_get,
+		.clock_getres64	= thread_cpu_clock_getres,
+		.clock_get64	= thread_cpu_clock_get,
 		.timer_create	= thread_cpu_timer_create,
 	};
-	struct timespec ts;
+	struct timespec64 ts;
 
 	posix_timers_register_clock(CLOCK_PROCESS_CPUTIME_ID, &process);
 	posix_timers_register_clock(CLOCK_THREAD_CPUTIME_ID, &thread);
 
-	cputime_to_timespec(cputime_one_jiffy, &ts);
+	cputime_to_timespec64(cputime_one_jiffy, &ts);
 	onecputick = ts.tv_nsec;
 	WARN_ON(ts.tv_sec != 0);
 
-- 
1.7.9.5
