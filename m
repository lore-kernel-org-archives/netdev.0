From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V7 4/8] posix clocks: hook dynamic clocks into system calls
Date: Thu, 16 Dec 2010 16:43:55 +0100
Message-ID: <6241238a1df55033e50b151ec9d35ba957e43d53.1292512461.git.richard.cochran@omicron.at>
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

This patch lets the various posix clock and timer system calls use
dynamic posix clocks, as well as the traditional static clocks.

For the performance critical calls (eg clock_gettime) the code path
from the traditional static clocks is preserved.

The following system calls are affected:

   - clock_adjtime (brand new syscall)
   - clock_gettime
   - clock_getres
   - clock_settime
   - timer_create
   - timer_delete
   - timer_gettime
   - timer_settime

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 include/linux/posix-clock.h  |   25 +++++++
 include/linux/posix-timers.h |   28 +++++++-
 include/linux/time.h         |    2 +
 kernel/posix-timers.c        |  122 +++++++++++++++++++++++++++-----
 kernel/time/posix-clock.c    |  159 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 316 insertions(+), 20 deletions(-)

diff --git a/include/linux/posix-clock.h b/include/linux/posix-clock.h
index 1ce7fb7..7ea94f5 100644
--- a/include/linux/posix-clock.h
+++ b/include/linux/posix-clock.h
@@ -108,4 +108,29 @@ struct posix_clock *posix_clock_create(struct posix_clock_operations *cops,
  */
 void posix_clock_destroy(struct posix_clock *clk);
 
+/**
+ * clockid_to_posix_clock() - obtain clock device pointer from a clock id
+ * @id: user space clock id
+ *
+ * Returns a pointer to the clock device, or NULL if the id is not a
+ * dynamic clock id.
+ */
+struct posix_clock *clockid_to_posix_clock(clockid_t id);
+
+/*
+ * The following functions are only to be called from posix-timers.c
+ */
+int pc_clock_adjtime(struct posix_clock *clk, struct timex *tx);
+int pc_clock_gettime(struct posix_clock *clk, struct timespec *ts);
+int pc_clock_getres(struct posix_clock *clk, struct timespec *ts);
+int pc_clock_settime(struct posix_clock *clk, const struct timespec *ts);
+
+int pc_timer_create(struct posix_clock *clk, struct k_itimer *kit);
+int pc_timer_delete(struct posix_clock *clk, struct k_itimer *kit);
+
+void pc_timer_gettime(struct posix_clock *clk, struct k_itimer *kit,
+		      struct itimerspec *ts);
+int pc_timer_settime(struct posix_clock *clk, struct k_itimer *kit,
+		     int flags, struct itimerspec *ts, struct itimerspec *old);
+
 #endif
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index b05d9b8..62ae296 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -18,10 +18,22 @@ struct cpu_timer_list {
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
-#define CPUCLOCK_PID_MASK	7
+
 #define CPUCLOCK_PERTHREAD_MASK	4
 #define CPUCLOCK_WHICH(clock)	((clock) & (clockid_t) CPUCLOCK_CLOCK_MASK)
 #define CPUCLOCK_CLOCK_MASK	3
@@ -29,12 +41,26 @@ struct cpu_timer_list {
 #define CPUCLOCK_VIRT		1
 #define CPUCLOCK_SCHED		2
 #define CPUCLOCK_MAX		3
+#define CLOCKFD			CPUCLOCK_MAX
+#define CLOCKFD_MASK		(CPUCLOCK_PERTHREAD_MASK|CPUCLOCK_CLOCK_MASK)
 
 #define MAKE_PROCESS_CPUCLOCK(pid, clock) \
 	((~(clockid_t) (pid) << 3) | (clockid_t) (clock))
 #define MAKE_THREAD_CPUCLOCK(tid, clock) \
 	MAKE_PROCESS_CPUCLOCK((tid), (clock) | CPUCLOCK_PERTHREAD_MASK)
 
+#define FD_TO_CLOCKID(fd)  ((clockid_t) (fd << 3) | CLOCKFD)
+#define CLOCKID_TO_FD(clk) (((unsigned int) clk) >> 3)
+
+static inline bool clock_is_static(const clockid_t id)
+{
+	if (0 == (id & ~CLOCKFD_MASK))
+		return true;
+	if (CLOCKFD == (id & CLOCKFD_MASK))
+		return false;
+	return true;
+}
+
 /* POSIX.1b interval timer structure. */
 struct k_itimer {
 	struct list_head list;		/* free/ allocate list */
diff --git a/include/linux/time.h b/include/linux/time.h
index 9f15ac7..914c48d 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -299,6 +299,8 @@ struct itimerval {
 #define CLOCKS_MASK			(CLOCK_REALTIME | CLOCK_MONOTONIC)
 #define CLOCKS_MONO			CLOCK_MONOTONIC
 
+#define CLOCK_INVALID			-1
+
 /*
  * The various flags for setting POSIX.1b interval timers:
  */
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 502bde4..cca3bd5 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -41,6 +41,7 @@
 #include <linux/init.h>
 #include <linux/compiler.h>
 #include <linux/idr.h>
+#include <linux/posix-clock.h>
 #include <linux/posix-timers.h>
 #include <linux/syscalls.h>
 #include <linux/wait.h>
@@ -532,12 +533,15 @@ SYSCALL_DEFINE3(timer_create, const clockid_t, which_clock,
 		struct sigevent __user *, timer_event_spec,
 		timer_t __user *, created_timer_id)
 {
+	struct posix_clock *clk_dev;
 	struct k_itimer *new_timer;
 	int error, new_timer_id;
 	sigevent_t event;
 	int it_id_set = IT_ID_NOT_SET;
 
-	if (invalid_clockid(which_clock))
+	clk_dev = clockid_to_posix_clock(which_clock);
+
+	if (!clk_dev && invalid_clockid(which_clock))
 		return -EINVAL;
 
 	new_timer = alloc_posix_timer();
@@ -600,7 +604,11 @@ SYSCALL_DEFINE3(timer_create, const clockid_t, which_clock,
 		goto out;
 	}
 
-	error = CLOCK_DISPATCH(which_clock, timer_create, (new_timer));
+	if (unlikely(clk_dev))
+		error = pc_timer_create(clk_dev, new_timer);
+	else {
+		error = CLOCK_DISPATCH(which_clock, timer_create, (new_timer));
+	}
 	if (error)
 		goto out;
 
@@ -712,6 +720,7 @@ common_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting)
 SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 		struct itimerspec __user *, setting)
 {
+	struct posix_clock *clk_dev;
 	struct k_itimer *timr;
 	struct itimerspec cur_setting;
 	unsigned long flags;
@@ -720,7 +729,15 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 	if (!timr)
 		return -EINVAL;
 
-	CLOCK_DISPATCH(timr->it_clock, timer_get, (timr, &cur_setting));
+	if (likely(clock_is_static(timr->it_clock))) {
+
+		CLOCK_DISPATCH(timr->it_clock, timer_get, (timr, &cur_setting));
+
+	} else {
+		clk_dev = clockid_to_posix_clock(timr->it_clock);
+		if (clk_dev)
+			pc_timer_gettime(clk_dev, timr, &cur_setting);
+	}
 
 	unlock_timer(timr, flags);
 
@@ -811,6 +828,7 @@ SYSCALL_DEFINE4(timer_settime, timer_t, timer_id, int, flags,
 		const struct itimerspec __user *, new_setting,
 		struct itimerspec __user *, old_setting)
 {
+	struct posix_clock *clk_dev;
 	struct k_itimer *timr;
 	struct itimerspec new_spec, old_spec;
 	int error = 0;
@@ -831,8 +849,19 @@ retry:
 	if (!timr)
 		return -EINVAL;
 
-	error = CLOCK_DISPATCH(timr->it_clock, timer_set,
-			       (timr, flags, &new_spec, rtn));
+	if (likely(clock_is_static(timr->it_clock))) {
+
+		error = CLOCK_DISPATCH(timr->it_clock, timer_set,
+				       (timr, flags, &new_spec, rtn));
+
+	} else {
+		clk_dev = clockid_to_posix_clock(timr->it_clock);
+		if (clk_dev)
+			error = pc_timer_settime(clk_dev, timr,
+						 flags, &new_spec, rtn);
+		else
+			error = -EINVAL;
+	}
 
 	unlock_timer(timr, flag);
 	if (error == TIMER_RETRY) {
@@ -858,6 +887,13 @@ static inline int common_timer_del(struct k_itimer *timer)
 
 static inline int timer_delete_hook(struct k_itimer *timer)
 {
+	struct posix_clock *clk_dev;
+
+	clk_dev = clockid_to_posix_clock(timer->it_clock);
+
+	if (clk_dev)
+		return pc_timer_delete(clk_dev, timer);
+
 	return CLOCK_DISPATCH(timer->it_clock, timer_del, (timer));
 }
 
@@ -957,26 +993,51 @@ EXPORT_SYMBOL_GPL(do_posix_clock_nonanosleep);
 SYSCALL_DEFINE2(clock_settime, const clockid_t, which_clock,
 		const struct timespec __user *, tp)
 {
+	struct posix_clock *clk_dev = NULL;
 	struct timespec new_tp;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
+	if (likely(clock_is_static(which_clock))) {
+
+		if (invalid_clockid(which_clock))
+			return -EINVAL;
+	} else {
+		clk_dev = clockid_to_posix_clock(which_clock);
+		if (!clk_dev)
+			return -EINVAL;
+	}
+
 	if (copy_from_user(&new_tp, tp, sizeof (*tp)))
 		return -EFAULT;
 
+	if (unlikely(clk_dev))
+		return pc_clock_settime(clk_dev, &new_tp);
+
 	return CLOCK_DISPATCH(which_clock, clock_set, (which_clock, &new_tp));
 }
 
 SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
-		struct timespec __user *,tp)
+		struct timespec __user *, tp)
 {
+	struct posix_clock *clk_dev;
 	struct timespec kernel_tp;
 	int error;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
-	error = CLOCK_DISPATCH(which_clock, clock_get,
-			       (which_clock, &kernel_tp));
+	if (likely(clock_is_static(which_clock))) {
+
+		if (invalid_clockid(which_clock))
+			return -EINVAL;
+
+		error = CLOCK_DISPATCH(which_clock, clock_get,
+				       (which_clock, &kernel_tp));
+	} else {
+		clk_dev = clockid_to_posix_clock(which_clock);
+
+		if (!clk_dev)
+			return -EINVAL;
+
+		error = pc_clock_gettime(clk_dev, &kernel_tp);
+	}
+
 	if (!error && copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
 		error = -EFAULT;
 
@@ -987,16 +1048,28 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
 SYSCALL_DEFINE2(clock_adjtime, const clockid_t, which_clock,
 		struct timex __user *, utx)
 {
+	struct posix_clock *clk_dev;
 	struct timex ktx;
 	int err;
 
 	if (copy_from_user(&ktx, utx, sizeof(ktx)))
 		return -EFAULT;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
+	if (likely(clock_is_static(which_clock))) {
 
-	err = CLOCK_DISPATCH(which_clock, clock_adj, (which_clock, &ktx));
+		if (invalid_clockid(which_clock))
+			return -EINVAL;
+
+		err = CLOCK_DISPATCH(which_clock, clock_adj,
+				     (which_clock, &ktx));
+	} else {
+		clk_dev = clockid_to_posix_clock(which_clock);
+
+		if (!clk_dev)
+			return -EINVAL;
+
+		err = pc_clock_adjtime(clk_dev, &ktx);
+	}
 
 	if (copy_to_user(utx, &ktx, sizeof(ktx)))
 		return -EFAULT;
@@ -1007,14 +1080,25 @@ SYSCALL_DEFINE2(clock_adjtime, const clockid_t, which_clock,
 SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock,
 		struct timespec __user *, tp)
 {
+	struct posix_clock *clk_dev;
 	struct timespec rtn_tp;
 	int error;
 
-	if (invalid_clockid(which_clock))
-		return -EINVAL;
+	if (likely(clock_is_static(which_clock))) {
 
-	error = CLOCK_DISPATCH(which_clock, clock_getres,
-			       (which_clock, &rtn_tp));
+		if (invalid_clockid(which_clock))
+			return -EINVAL;
+
+		error = CLOCK_DISPATCH(which_clock, clock_getres,
+				       (which_clock, &rtn_tp));
+	} else {
+		clk_dev = clockid_to_posix_clock(which_clock);
+
+		if (!clk_dev)
+			return -EINVAL;
+
+		error = pc_clock_getres(clk_dev, &rtn_tp);
+	}
 
 	if (!error && tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp))) {
 		error = -EFAULT;
diff --git a/kernel/time/posix-clock.c b/kernel/time/posix-clock.c
index e5924c9..a707c10 100644
--- a/kernel/time/posix-clock.c
+++ b/kernel/time/posix-clock.c
@@ -19,9 +19,12 @@
  */
 #include <linux/cdev.h>
 #include <linux/device.h>
+#include <linux/file.h>
 #include <linux/mutex.h>
 #include <linux/posix-clock.h>
 #include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/uaccess.h>
 
 #define MAX_CLKDEV BITS_PER_LONG
 static DECLARE_BITMAP(clocks_map, MAX_CLKDEV);
@@ -215,3 +218,159 @@ void posix_clock_destroy(struct posix_clock *clk)
 	kref_put(&clk->kref, delete_clock);
 }
 EXPORT_SYMBOL_GPL(posix_clock_destroy);
+
+struct posix_clock *clockid_to_posix_clock(const clockid_t id)
+{
+	struct posix_clock *clk = NULL;
+	struct file *fp;
+
+	if (clock_is_static(id))
+		return NULL;
+
+	fp = fget(CLOCKID_TO_FD(id));
+	if (!fp)
+		return NULL;
+
+	if (fp->f_op->open == posix_clock_open)
+		clk = fp->private_data;
+
+	fput(fp);
+	return clk;
+}
+
+int pc_clock_adjtime(struct posix_clock *clk, struct timex *tx)
+{
+	int err;
+
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		err = -ENODEV;
+	else if (!clk->ops->clock_adjtime)
+		err = -EOPNOTSUPP;
+	else
+		err = clk->ops->clock_adjtime(clk->priv, tx);
+
+	mutex_unlock(&clk->mux);
+	return err;
+}
+
+int pc_clock_gettime(struct posix_clock *clk, struct timespec *ts)
+{
+	int err;
+
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		err = -ENODEV;
+	else if (!clk->ops->clock_gettime)
+		err = -EOPNOTSUPP;
+	else
+		err = clk->ops->clock_gettime(clk->priv, ts);
+
+	mutex_unlock(&clk->mux);
+	return err;
+}
+
+int pc_clock_getres(struct posix_clock *clk, struct timespec *ts)
+{
+	int err;
+
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		err = -ENODEV;
+	else if (!clk->ops->clock_getres)
+		err = -EOPNOTSUPP;
+	else
+		err = clk->ops->clock_getres(clk->priv, ts);
+
+	mutex_unlock(&clk->mux);
+	return err;
+}
+
+int pc_clock_settime(struct posix_clock *clk, const struct timespec *ts)
+{
+	int err;
+
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		err = -ENODEV;
+	else if (!clk->ops->clock_settime)
+		err = -EOPNOTSUPP;
+	else
+		err = clk->ops->clock_settime(clk->priv, ts);
+
+	mutex_unlock(&clk->mux);
+	return err;
+}
+
+int pc_timer_create(struct posix_clock *clk, struct k_itimer *kit)
+{
+	int err;
+
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		err = -ENODEV;
+	else if (!clk->ops->timer_create)
+		err = -EOPNOTSUPP;
+	else
+		err = clk->ops->timer_create(clk->priv, kit);
+
+	mutex_unlock(&clk->mux);
+	return err;
+}
+
+int pc_timer_delete(struct posix_clock *clk, struct k_itimer *kit)
+{
+	int err;
+
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		err = -ENODEV;
+	else if (!clk->ops->timer_delete)
+		err = -EOPNOTSUPP;
+	else
+		err = clk->ops->timer_delete(clk->priv, kit);
+
+	mutex_unlock(&clk->mux);
+
+	return err;
+}
+
+void pc_timer_gettime(struct posix_clock *clk, struct k_itimer *kit,
+		      struct itimerspec *ts)
+{
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		goto out;
+	else if (!clk->ops->timer_gettime)
+		goto out;
+	else
+		clk->ops->timer_gettime(clk->priv, kit, ts);
+out:
+	mutex_unlock(&clk->mux);
+}
+
+int pc_timer_settime(struct posix_clock *clk, struct k_itimer *kit,
+		     int flags, struct itimerspec *ts, struct itimerspec *old)
+{
+	int err;
+
+	mutex_lock(&clk->mux);
+
+	if (clk->zombie)
+		err = -ENODEV;
+	else if (!clk->ops->timer_settime)
+		err = -EOPNOTSUPP;
+	else
+		err = clk->ops->timer_settime(clk->priv, kit, flags, ts, old);
+
+	mutex_unlock(&clk->mux);
+
+	return err;
+}
-- 
1.7.0.4
