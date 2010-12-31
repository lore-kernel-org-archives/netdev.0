From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V8 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Fri, 31 Dec 2010 20:15:33 +0100
Message-ID: <503cd1fa268867573001cfc9bb5681ee3b5b32fa.1293820862.git.richard.cochran@omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
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
In-Reply-To: <cover.1293820862.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

As as possible further improvement for the future, one could go
through and replace the various no_xyz function pointers in the
k_clocks with NULL pointers.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 include/linux/posix-timers.h |   14 +++
 include/linux/time.h         |    2 +
 kernel/posix-timers.c        |  241 ++++++++++++++++++++++++++++++++++--------
 3 files changed, 213 insertions(+), 44 deletions(-)

diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index b05d9b8..eef7f9c 100644
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
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 502bde4..65b0599 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -138,6 +138,7 @@ static struct k_clock posix_clocks[MAX_CLOCKS];
  */
 static int common_nsleep(const clockid_t, int flags, struct timespec *t,
 			 struct timespec __user *rmtp);
+static long common_nsleep_restart(struct restart_block *restart_block);
 static void common_timer_get(struct k_itimer *, struct itimerspec *);
 static int common_timer_set(struct k_itimer *, int,
 			    struct itimerspec *, struct itimerspec *);
@@ -152,41 +153,14 @@ static inline void unlock_timer(struct k_itimer *timr, unsigned long flags)
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
@@ -197,7 +171,7 @@ static int common_timer_create(struct k_itimer *new_timer)
 	return 0;
 }
 
-static inline int common_clock_adj(const clockid_t which_clock, struct timex *t)
+static int common_clock_adj(const clockid_t which_clock, struct timex *t)
 {
 	return do_adjtimex(t);
 }
@@ -214,19 +188,14 @@ static int no_nsleep(const clockid_t which_clock, int flags,
 }
 
 /*
- * Return nonzero if we know a priori this clockid_t value is bogus.
+ * Return 'true' if we know a priori this clockid_t value is bogus.
  */
-static inline int invalid_clockid(const clockid_t which_clock)
+static inline bool invalid_clockid(const clockid_t which_clock)
 {
-	if (which_clock < 0)	/* CPU clock, posix_cpu_* will check it */
-		return 0;
-	if ((unsigned) which_clock >= MAX_CLOCKS)
-		return 1;
-	if (posix_clocks[which_clock].clock_getres != NULL)
-		return 0;
-	if (posix_clocks[which_clock].res != 0)
-		return 0;
-	return 1;
+	if (which_clock >= MAX_CLOCKS)
+		return true;
+	else
+		return false;
 }
 
 /*
@@ -273,12 +242,29 @@ static __init int init_posix_timers(void)
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
@@ -287,6 +273,11 @@ static __init int init_posix_timers(void)
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
@@ -295,6 +286,11 @@ static __init int init_posix_timers(void)
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
@@ -303,6 +299,11 @@ static __init int init_posix_timers(void)
 		.clock_adj = do_posix_clock_noadjtime,
 		.timer_create = no_timer_create,
 		.nsleep = no_nsleep,
+		/* defaults: */
+		.nsleep_restart	= common_nsleep_restart,
+		.timer_del	= common_timer_del,
+		.timer_get	= common_timer_get,
+		.timer_set	= common_timer_set,
 	};
 
 	register_posix_clock(CLOCK_REALTIME, &clock_realtime);
@@ -526,6 +527,160 @@ static void release_posix_timer(struct k_itimer *tmr, int it_id_set)
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
+static inline int dispatch_clock_getres(const clockid_t id, struct timespec *ts)
+{
+	if (id >= 0) {
+		return posix_clocks[id].clock_getres ?
+			posix_clocks[id].clock_getres(id, ts) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_clock_getres(id, ts);
+
+	return -EINVAL;
+}
+
+static inline int dispatch_clock_set(const clockid_t id, struct timespec *ts)
+{
+	if (id >= 0) {
+		return posix_clocks[id].clock_set ?
+			posix_clocks[id].clock_set(id, ts) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_clock_set(id, ts);
+
+	return -EINVAL;
+}
+
+static inline int dispatch_clock_get(const clockid_t id, struct timespec *ts)
+{
+	if (id >= 0) {
+		return posix_clocks[id].clock_get ?
+			posix_clocks[id].clock_get(id, ts) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_clock_get(id, ts);
+
+	return -EINVAL;
+}
+
+static inline int dispatch_clock_adj(const clockid_t id, struct timex *tx)
+{
+	if (id >= 0) {
+		return posix_clocks[id].clock_adj ?
+			posix_clocks[id].clock_adj(id, tx) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_clock_adj(id, tx);
+
+	return -EINVAL;
+}
+
+static inline int dispatch_timer_create(struct k_itimer *kit)
+{
+	clockid_t id = kit->it_clock;
+
+	if (id >= 0) {
+		return posix_clocks[id].timer_create ?
+			posix_clocks[id].timer_create(kit) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_timer_create(kit);
+
+	return -EINVAL;
+}
+
+static inline int dispatch_nsleep(const clockid_t id, int flags,
+				  struct timespec *ts,
+				  struct timespec __user *rts)
+{
+	if (id >= 0) {
+		return posix_clocks[id].nsleep ?
+			posix_clocks[id].nsleep(id, flags, ts, rts) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_nsleep(id, flags, ts, rts);
+
+	return -EINVAL;
+}
+
+static inline long dispatch_nsleep_restart(struct restart_block *block)
+{
+	clockid_t id = block->arg0;
+
+	if (id >= 0) {
+		return posix_clocks[id].nsleep_restart ?
+			posix_clocks[id].nsleep_restart(block) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_nsleep_restart(block);
+
+	return -EINVAL;
+}
+
+static inline int dispatch_timer_set(struct k_itimer *kit, int flags,
+				     struct itimerspec *tsp,
+				     struct itimerspec *old)
+{
+	clockid_t id = kit->it_clock;
+
+	if (id >= 0) {
+		return posix_clocks[id].timer_set ?
+			posix_clocks[id].timer_set(kit, flags, tsp, old) :
+			-EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_timer_set(kit, flags, tsp, old);
+
+	return -EINVAL;
+}
+
+static inline int dispatch_timer_del(struct k_itimer *kit)
+{
+	clockid_t id = kit->it_clock;
+
+	if (id >= 0) {
+		return posix_clocks[id].timer_del ?
+			posix_clocks[id].timer_del(kit) : -EINVAL;
+	}
+
+	if (clock_is_posix_cpu(id))
+		return posix_cpu_timer_del(kit);
+
+	return -EINVAL;
+}
+
+static inline void dispatch_timer_get(struct k_itimer *kit,
+				      struct itimerspec *tsp)
+{
+	clockid_t id = kit->it_clock;
+
+	if (id >= 0 && posix_clocks[id].timer_get)
+
+		posix_clocks[id].timer_get(kit, tsp);
+
+	else if (clock_is_posix_cpu(id))
+
+		posix_cpu_timer_get(kit, tsp);
+}
+
+#define CLOCK_DISPATCH(clock, call, arglist) dispatch_##call arglist
+
 /* Create a POSIX.1b interval timer. */
 
 SYSCALL_DEFINE3(timer_create, const clockid_t, which_clock,
@@ -847,7 +1002,7 @@ retry:
 	return error;
 }
 
-static inline int common_timer_del(struct k_itimer *timer)
+static int common_timer_del(struct k_itimer *timer)
 {
 	timer->it.real.interval.tv64 = 0;
 
@@ -1056,7 +1211,7 @@ SYSCALL_DEFINE4(clock_nanosleep, const clockid_t, which_clock, int, flags,
 /*
  * nanosleep_restart for monotonic and realtime clocks
  */
-static int common_nsleep_restart(struct restart_block *restart_block)
+static long common_nsleep_restart(struct restart_block *restart_block)
 {
 	return hrtimer_nanosleep_restart(restart_block);
 }
@@ -1068,8 +1223,6 @@ static int common_nsleep_restart(struct restart_block *restart_block)
 long
 clock_nanosleep_restart(struct restart_block *restart_block)
 {
-	clockid_t which_clock = restart_block->arg0;
-
 	return CLOCK_DISPATCH(which_clock, nsleep_restart,
 			      (restart_block));
 }
-- 
1.7.0.4
