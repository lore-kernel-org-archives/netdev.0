From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V9 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Thu, 13 Jan 2011 12:35:17 +0100
Message-ID: <90b2beef441615d01c93fcad029c44af4e505c5f.1294917348.git.richard.cochran@omicron.at>
References: <cover.1294917347.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1294917347.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paraphrasing tglx:

This patch simplifies and clarifies the code, doing the normal thing
with function pointer structures. Stuff which is not implemented does
not magically become called via some common function. There is no
point in doing that.

We fill in the various k_clock structs with the correct pointers in
the first place and let the NULL case return a sensible error
value. The data structure does not become larger that way. It's a
little bit more init code, but that's fine if we make the code better
in general. In that case it's not even more init code, it's just
filling the data structures which we register.

My own words:

For now, each of the registered k_clocks has the previously NULL
functions assigned to the common_xyz function, since that usage was
implicitly enforced by the CLOCK_DISPTACH macro. These functions are
marked with a /* default: */ comment.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/posix-timers.h |   16 +++-
 include/linux/time.h         |    2 +
 kernel/posix-cpu-timers.c    |    2 +-
 kernel/posix-timers.c        |  218 +++++++++++++++++++++++-------------------
 4 files changed, 137 insertions(+), 101 deletions(-)

diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index b05d9b8..b83cceb 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -18,6 +18,18 @@ struct cpu_timer_list {
 	int firing;
 };
 
+/* Bit fields within a clockid:
+ *
+ * The most significant 29 bits hold either a pid or a file descriptor.
+ *
+ * Bit 2 indicates whether a cpu clock refers to a thread or a process.
+ *
+ * Bits 1 and 0 give the type: PROF=0, VIRT=1, SCHED=2, or FD=3.
+ *
+ * A clockid is invalid if bits 2, 1, and 0 all set (see also CLOCK_INVALID
+ * in include/linux/time.h)
+ */
+
 #define CPUCLOCK_PID(clock)		((pid_t) ~((clock) >> 3))
 #define CPUCLOCK_PERTHREAD(clock) \
 	(((clock) & (clockid_t) CPUCLOCK_PERTHREAD_MASK) != 0)
@@ -29,6 +41,8 @@ struct cpu_timer_list {
 #define CPUCLOCK_VIRT		1
 #define CPUCLOCK_SCHED		2
 #define CPUCLOCK_MAX		3
+#define CLOCKFD			CPUCLOCK_MAX
+#define CLOCKFD_MASK		(CPUCLOCK_PERTHREAD_MASK|CPUCLOCK_CLOCK_MASK)
 
 #define MAKE_PROCESS_CPUCLOCK(pid, clock) \
 	((~(clockid_t) (pid) << 3) | (clockid_t) (clock))
@@ -99,7 +113,7 @@ int posix_timer_event(struct k_itimer *timr, int si_private);
 
 int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
-int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
+int posix_cpu_clock_set(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_adj(const clockid_t which_clock, struct timex *tx);
 int posix_cpu_timer_create(struct k_itimer *timer);
 int posix_cpu_nsleep(const clockid_t which_clock, int flags,
diff --git a/include/linux/time.h b/include/linux/time.h
index b402134..99d4b14 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -300,6 +300,8 @@ struct itimerval {
 #define CLOCKS_MASK			(CLOCK_REALTIME | CLOCK_MONOTONIC)
 #define CLOCKS_MONO			CLOCK_MONOTONIC
 
+#define CLOCK_INVALID			-1
+
 /*
  * The various flags for setting POSIX.1b interval timers:
  */
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index 0206116..6ebf01c 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -194,7 +194,7 @@ int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *tp)
 	return error;
 }
 
-int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *tp)
+int posix_cpu_clock_set(const clockid_t which_clock, struct timespec *tp)
 {
 	/*
 	 * You can never reset a CPU clock, but we check for other errors
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 91f9b4b..519802e 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -94,11 +94,7 @@ static DEFINE_SPINLOCK(idr_lock);
 /*
  * CLOCKs: The POSIX standard calls for a couple of clocks and allows us
  *	    to implement others.  This structure defines the various
- *	    clocks and allows the possibility of adding others.	 We
- *	    provide an interface to add clocks to the table and expect
- *	    the "arch" code to add at least one clock that is high
- *	    resolution.	 Here we define the standard CLOCK_REALTIME as a
- *	    1/HZ resolution clock.
+ *	    clocks.
  *
  * RESOLUTION: Clock resolution is used to round up timer and interval
  *	    times, NOT to report clock times, which are reported with as
@@ -108,20 +104,13 @@ static DEFINE_SPINLOCK(idr_lock);
  *	    necessary code is written.	The standard says we should say
  *	    something about this issue in the documentation...
  *
- * FUNCTIONS: The CLOCKs structure defines possible functions to handle
- *	    various clock functions.  For clocks that use the standard
- *	    system timer code these entries should be NULL.  This will
- *	    allow dispatch without the overhead of indirect function
- *	    calls.  CLOCKS that depend on other sources (e.g. WWV or GPS)
- *	    must supply functions here, even if the function just returns
- *	    ENOSYS.  The standard POSIX timer management code assumes the
- *	    following: 1.) The k_itimer struct (sched.h) is used for the
- *	    timer.  2.) The list, it_lock, it_clock, it_id and it_pid
- *	    fields are not modified by timer code.
+ * FUNCTIONS: The CLOCKs structure defines possible functions to
+ *	    handle various clock functions.
  *
- *          At this time all functions EXCEPT clock_nanosleep can be
- *          redirected by the CLOCKS structure.  Clock_nanosleep is in
- *          there, but the code ignores it.
+ *	    The standard POSIX timer management code assumes the
+ *	    following: 1.) The k_itimer struct (sched.h) is used for
+ *	    the timer.  2.) The list, it_lock, it_clock, it_id and
+ *	    it_pid fields are not modified by timer code.
  *
  * Permissions: It is assumed that the clock_settime() function defined
  *	    for each clock will take care of permission checks.	 Some
@@ -131,13 +120,18 @@ static DEFINE_SPINLOCK(idr_lock);
  *	    which we beg off on and pass to do_sys_settimeofday().
  */
 
-static struct k_clock posix_clocks[MAX_CLOCKS];
+#define POSIX_INV_CLOCK_ID	MAX_CLOCKS
+#define POSIX_CPU_CLOCK_ID	(MAX_CLOCKS + 1)
+#define NR_CLOCK_ENTRIES	(MAX_CLOCKS + 2)
+
+static struct k_clock posix_clocks[NR_CLOCK_ENTRIES];
 
 /*
  * These ones are defined below.
  */
 static int common_nsleep(const clockid_t, int flags, struct timespec *t,
 			 struct timespec __user *rmtp);
+static long common_nsleep_restart(struct restart_block *restart_block);
 static void common_timer_get(struct k_itimer *, struct itimerspec *);
 static int common_timer_set(struct k_itimer *, int,
 			    struct itimerspec *, struct itimerspec *);
@@ -158,41 +152,14 @@ static inline void unlock_timer(struct k_itimer *timr, unsigned long flags)
 	spin_unlock_irqrestore(&timr->it_lock, flags);
 }
 
-/*
- * Call the k_clock hook function if non-null, or the default function.
- */
-#define CLOCK_DISPATCH(clock, call, arglist) \
- 	((clock) < 0 ? posix_cpu_##call arglist : \
- 	 (posix_clocks[clock].call != NULL \
- 	  ? (*posix_clocks[clock].call) arglist : common_##call arglist))
-
-/*
- * Default clock hook functions when the struct k_clock passed
- * to register_posix_clock leaves a function pointer null.
- *
- * The function common_CALL is the default implementation for
- * the function pointer CALL in struct k_clock.
- */
 
-static inline int common_clock_getres(const clockid_t which_clock,
-				      struct timespec *tp)
-{
-	tp->tv_sec = 0;
-	tp->tv_nsec = posix_clocks[which_clock].res;
-	return 0;
-}
-
-/*
- * Get real time for posix timers
- */
 static int common_clock_get(clockid_t which_clock, struct timespec *tp)
 {
 	ktime_get_real_ts(tp);
 	return 0;
 }
 
-static inline int common_clock_set(const clockid_t which_clock,
-				   struct timespec *tp)
+static int common_clock_set(const clockid_t which_clock, struct timespec *tp)
 {
 	return do_sys_settimeofday(tp, NULL);
 }
@@ -203,7 +170,7 @@ static int common_timer_create(struct k_itimer *new_timer)
 	return 0;
 }
 
-static inline int common_clock_adj(const clockid_t which_clock, struct timex *t)
+static int common_clock_adj(const clockid_t which_clock, struct timex *t)
 {
 	return do_adjtimex(t);
 }
@@ -220,22 +187,6 @@ static int no_nsleep(const clockid_t which_clock, int flags,
 }
 
 /*
- * Return nonzero if we know a priori this clockid_t value is bogus.
- */
-static inline int invalid_clockid(const clockid_t which_clock)
-{
-	if (which_clock < 0)	/* CPU clock, posix_cpu_* will check it */
-		return 0;
-	if ((unsigned) which_clock >= MAX_CLOCKS)
-		return 1;
-	if (posix_clocks[which_clock].clock_getres != NULL)
-		return 0;
-	if (posix_clocks[which_clock].res != 0)
-		return 0;
-	return 1;
-}
-
-/*
  * Get monotonic time for posix timers
  */
 static int posix_ktime_get_ts(clockid_t which_clock, struct timespec *tp)
@@ -279,12 +230,29 @@ static __init int init_posix_timers(void)
 {
 	struct k_clock clock_realtime = {
 		.clock_getres = hrtimer_get_res,
+		/* defaults: */
+		.clock_adj	= common_clock_adj,
+		.clock_get	= common_clock_get,
+		.clock_set	= common_clock_set,
+		.nsleep		= common_nsleep,
+		.nsleep_restart	= common_nsleep_restart,
+		.timer_create	= common_timer_create,
+		.timer_del	= common_timer_del,
+		.timer_get	= common_timer_get,
+		.timer_set	= common_timer_set,
 	};
 	struct k_clock clock_monotonic = {
 		.clock_getres = hrtimer_get_res,
 		.clock_get = posix_ktime_get_ts,
 		.clock_set = do_posix_clock_nosettime,
 		.clock_adj = do_posix_clock_noadjtime,
+		/* defaults: */
+		.nsleep		= common_nsleep,
+		.nsleep_restart	= common_nsleep_restart,
+		.timer_create	= common_timer_create,
+		.timer_del	= common_timer_del,
+		.timer_get	= common_timer_get,
+		.timer_set	= common_timer_set,
 	};
 	struct k_clock clock_monotonic_raw = {
 		.clock_getres = hrtimer_get_res,
@@ -293,6 +261,11 @@ static __init int init_posix_timers(void)
 		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
+		/* defaults: */
+		.nsleep_restart	= common_nsleep_restart,
+		.timer_del	= common_timer_del,
+		.timer_get	= common_timer_get,
+		.timer_set	= common_timer_set,
 	};
 	struct k_clock clock_realtime_coarse = {
 		.clock_getres = posix_get_coarse_res,
@@ -301,6 +274,11 @@ static __init int init_posix_timers(void)
 		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
+		/* defaults: */
+		.nsleep_restart	= common_nsleep_restart,
+		.timer_del	= common_timer_del,
+		.timer_get	= common_timer_get,
+		.timer_set	= common_timer_set,
 	};
 	struct k_clock clock_monotonic_coarse = {
 		.clock_getres = posix_get_coarse_res,
@@ -309,6 +287,23 @@ static __init int init_posix_timers(void)
 		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
+		/* defaults: */
+		.nsleep_restart	= common_nsleep_restart,
+		.timer_del	= common_timer_del,
+		.timer_get	= common_timer_get,
+		.timer_set	= common_timer_set,
+	};
+	struct k_clock clock_posix_cpu = {
+		.clock_getres	= posix_cpu_clock_getres,
+		.clock_set	= posix_cpu_clock_set,
+		.clock_get	= posix_cpu_clock_get,
+		.clock_adj	= posix_cpu_clock_adj,
+		.timer_create	= posix_cpu_timer_create,
+		.nsleep		= posix_cpu_nsleep,
+		.nsleep_restart	= posix_cpu_nsleep_restart,
+		.timer_set	= posix_cpu_timer_set,
+		.timer_del	= posix_cpu_timer_del,
+		.timer_get	= posix_cpu_timer_get,
 	};
 
 	register_posix_clock(CLOCK_REALTIME, &clock_realtime);
@@ -317,10 +312,17 @@ static __init int init_posix_timers(void)
 	register_posix_clock(CLOCK_REALTIME_COARSE, &clock_realtime_coarse);
 	register_posix_clock(CLOCK_MONOTONIC_COARSE, &clock_monotonic_coarse);
 
+	/*
+	 * We leave the POSIX_INV_CLOCK_ID entry zeroed out, so that
+	 * the clock returned by clockid_to_kclock() will trigger -EINVAL.
+	 */
+	posix_clocks[POSIX_CPU_CLOCK_ID] = clock_posix_cpu;
+
 	posix_timers_cache = kmem_cache_create("posix_timers_cache",
 					sizeof (struct k_itimer), 0, SLAB_PANIC,
 					NULL);
 	idr_init(&posix_timers_id);
+
 	return 0;
 }
 
@@ -532,20 +534,39 @@ static void release_posix_timer(struct k_itimer *tmr, int it_id_set)
 	kmem_cache_free(posix_timers_cache, tmr);
 }
 
+static inline bool clock_is_posix_cpu(const clockid_t id)
+{
+	if ((id & CLOCKFD_MASK) == CLOCKFD)
+		return false;
+	else
+		return true;
+}
+
+static struct k_clock *clockid_to_kclock(const clockid_t id)
+{
+	if (id >= 0) {
+		return id < MAX_CLOCKS ?
+			&posix_clocks[id] : &posix_clocks[POSIX_INV_CLOCK_ID];
+	}
+
+	if (clock_is_posix_cpu(id))
+		return &posix_clocks[POSIX_CPU_CLOCK_ID];
+
+	return &posix_clocks[POSIX_INV_CLOCK_ID];
+}
+
 /* Create a POSIX.1b interval timer. */
 
 SYSCALL_DEFINE3(timer_create, const clockid_t, which_clock,
 		struct sigevent __user *, timer_event_spec,
 		timer_t __user *, created_timer_id)
 {
+	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct k_itimer *new_timer;
 	int error, new_timer_id;
 	sigevent_t event;
 	int it_id_set = IT_ID_NOT_SET;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
-
 	new_timer = alloc_posix_timer();
 	if (unlikely(!new_timer))
 		return -EAGAIN;
@@ -606,7 +627,7 @@ SYSCALL_DEFINE3(timer_create, const clockid_t, which_clock,
 		goto out;
 	}
 
-	error = CLOCK_DISPATCH(which_clock, timer_create, (new_timer));
+	error = kc->timer_create ? kc->timer_create(new_timer) : -EINVAL;
 	if (error)
 		goto out;
 
@@ -718,6 +739,7 @@ common_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting)
 SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 		struct itimerspec __user *, setting)
 {
+	struct k_clock *kc;
 	struct k_itimer *timr;
 	struct itimerspec cur_setting;
 	unsigned long flags;
@@ -726,7 +748,10 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 	if (!timr)
 		return -EINVAL;
 
-	CLOCK_DISPATCH(timr->it_clock, timer_get, (timr, &cur_setting));
+	kc = clockid_to_kclock(timr->it_clock);
+
+	if (kc->timer_get)
+		kc->timer_get(timr, &cur_setting);
 
 	unlock_timer(timr, flags);
 
@@ -817,6 +842,7 @@ SYSCALL_DEFINE4(timer_settime, timer_t, timer_id, int, flags,
 		const struct itimerspec __user *, new_setting,
 		struct itimerspec __user *, old_setting)
 {
+	struct k_clock *kc;
 	struct k_itimer *timr;
 	struct itimerspec new_spec, old_spec;
 	int error = 0;
@@ -837,8 +863,10 @@ retry:
 	if (!timr)
 		return -EINVAL;
 
-	error = CLOCK_DISPATCH(timr->it_clock, timer_set,
-			       (timr, flags, &new_spec, rtn));
+	kc = clockid_to_kclock(timr->it_clock);
+
+	error = kc->timer_set ?
+		kc->timer_set(timr, flags, &new_spec, rtn) : -EINVAL;
 
 	unlock_timer(timr, flag);
 	if (error == TIMER_RETRY) {
@@ -853,7 +881,7 @@ retry:
 	return error;
 }
 
-static inline int common_timer_del(struct k_itimer *timer)
+static int common_timer_del(struct k_itimer *timer)
 {
 	timer->it.real.interval.tv64 = 0;
 
@@ -864,7 +892,9 @@ static inline int common_timer_del(struct k_itimer *timer)
 
 static inline int timer_delete_hook(struct k_itimer *timer)
 {
-	return CLOCK_DISPATCH(timer->it_clock, timer_del, (timer));
+	struct k_clock *kc = clockid_to_kclock(timer->it_clock);
+
+	return kc->timer_del ? kc->timer_del(timer) : -EINVAL;
 }
 
 /* Delete a POSIX.1b interval timer. */
@@ -963,46 +993,42 @@ EXPORT_SYMBOL_GPL(do_posix_clock_nonanosleep);
 SYSCALL_DEFINE2(clock_settime, const clockid_t, which_clock,
 		const struct timespec __user *, tp)
 {
+	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timespec new_tp;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
 	if (copy_from_user(&new_tp, tp, sizeof (*tp)))
 		return -EFAULT;
 
-	return CLOCK_DISPATCH(which_clock, clock_set, (which_clock, &new_tp));
+	return kc->clock_set ? kc->clock_set(which_clock, &new_tp) : -EINVAL;
 }
 
 SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
 		struct timespec __user *,tp)
 {
+	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timespec kernel_tp;
 	int error;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
-	error = CLOCK_DISPATCH(which_clock, clock_get,
-			       (which_clock, &kernel_tp));
+	error = kc->clock_get ?
+		kc->clock_get(which_clock, &kernel_tp) : -EINVAL;
+
 	if (!error && copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
 		error = -EFAULT;
 
 	return error;
-
 }
 
 SYSCALL_DEFINE2(clock_adjtime, const clockid_t, which_clock,
 		struct timex __user *, utx)
 {
+	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timex ktx;
 	int err;
 
 	if (copy_from_user(&ktx, utx, sizeof(ktx)))
 		return -EFAULT;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
-
-	err = CLOCK_DISPATCH(which_clock, clock_adj, (which_clock, &ktx));
+	err = kc->clock_adj ? kc->clock_adj(which_clock, &ktx) : -EINVAL;
 
 	if (copy_to_user(utx, &ktx, sizeof(ktx)))
 		return -EFAULT;
@@ -1013,14 +1039,12 @@ SYSCALL_DEFINE2(clock_adjtime, const clockid_t, which_clock,
 SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock,
 		struct timespec __user *, tp)
 {
+	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timespec rtn_tp;
 	int error;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
-
-	error = CLOCK_DISPATCH(which_clock, clock_getres,
-			       (which_clock, &rtn_tp));
+	error = kc->clock_getres ?
+		kc->clock_getres(which_clock, &rtn_tp) : -EINVAL;
 
 	if (!error && tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp))) {
 		error = -EFAULT;
@@ -1044,25 +1068,22 @@ SYSCALL_DEFINE4(clock_nanosleep, const clockid_t, which_clock, int, flags,
 		const struct timespec __user *, rqtp,
 		struct timespec __user *, rmtp)
 {
+	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timespec t;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
-
 	if (copy_from_user(&t, rqtp, sizeof (struct timespec)))
 		return -EFAULT;
 
 	if (!timespec_valid(&t))
 		return -EINVAL;
 
-	return CLOCK_DISPATCH(which_clock, nsleep,
-			      (which_clock, flags, &t, rmtp));
+	return kc->nsleep ? kc->nsleep(which_clock, flags, &t, rmtp) : -EINVAL;
 }
 
 /*
  * nanosleep_restart for monotonic and realtime clocks
  */
-static int common_nsleep_restart(struct restart_block *restart_block)
+static long common_nsleep_restart(struct restart_block *restart_block)
 {
 	return hrtimer_nanosleep_restart(restart_block);
 }
@@ -1074,8 +1095,7 @@ static int common_nsleep_restart(struct restart_block *restart_block)
 long
 clock_nanosleep_restart(struct restart_block *restart_block)
 {
-	clockid_t which_clock = restart_block->arg0;
+	struct k_clock *kc = clockid_to_kclock(restart_block->arg0);
 
-	return CLOCK_DISPATCH(which_clock, nsleep_restart,
-			      (restart_block));
+	return kc->nsleep_restart ? kc->nsleep_restart(restart_block) : -EINVAL;
 }
-- 
1.7.0.4
