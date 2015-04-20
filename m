From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 04/11] posix timers:Introduce the 64bit methods with timespec64 type for k_clock structure
Date: Mon, 20 Apr 2015 13:57:32 +0800
Message-ID: <1429509459-17068-5-git-send-email-baolin.wang@linaro.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the new methods with timespec64 type for k_clcok structure,
converts the timepsec type to timespec64 type in k_clock structure and converts
the itimerspec type to itimerspec64 type to ready for 2038 issue.

And also introduces the 64bit methods with timespec64 type for the framework
functions.

Next step will migrate all the k_clock users to use the new methods with timespec64 type
nd itimerspec64 type, and it contains the files of posix-timers.c, mmtimer.c, alarmtimer.c,
posix-clock.c and posix-cpu-timers.c.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/posix-timers.h |    9 ++++++
 kernel/time/posix-timers.c   |   65 ++++++++++++++++++++++++++++++++----------
 2 files changed, 59 insertions(+), 15 deletions(-)

diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 907f3fd..35786c5 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -98,9 +98,13 @@ struct k_itimer {
 
 struct k_clock {
 	int (*clock_getres) (const clockid_t which_clock, struct timespec *tp);
+	int (*clock_getres64) (const clockid_t which_clock, struct timespec64 *tp);
 	int (*clock_set) (const clockid_t which_clock,
 			  const struct timespec *tp);
+	int (*clock_set64) (const clockid_t which_clock,
+			    const struct timespec64 *tp);
 	int (*clock_get) (const clockid_t which_clock, struct timespec * tp);
+	int (*clock_get64) (const clockid_t which_clock, struct timespec64 *tp);
 	int (*clock_adj) (const clockid_t which_clock, struct timex *tx);
 	int (*timer_create) (struct k_itimer *timer);
 	int (*nsleep) (const clockid_t which_clock, int flags,
@@ -109,10 +113,15 @@ struct k_clock {
 	int (*timer_set) (struct k_itimer * timr, int flags,
 			  struct itimerspec * new_setting,
 			  struct itimerspec * old_setting);
+	int (*timer_set64) (struct k_itimer *timr, int flags,
+			    struct itimerspec64 *new_setting,
+			    struct itimerspec64 *old_setting);
 	int (*timer_del) (struct k_itimer * timr);
 #define TIMER_RETRY 1
 	void (*timer_get) (struct k_itimer * timr,
 			   struct itimerspec * cur_setting);
+	void (*timer_get64) (struct k_itimer *timr,
+			     struct itimerspec64 *cur_setting);
 };
 
 extern struct k_clock clock_posix_cpu;
diff --git a/kernel/time/posix-timers.c b/kernel/time/posix-timers.c
index 31ea01f..9070387 100644
--- a/kernel/time/posix-timers.c
+++ b/kernel/time/posix-timers.c
@@ -522,13 +522,13 @@ void posix_timers_register_clock(const clockid_t clock_id,
 		return;
 	}
 
-	if (!new_clock->clock_get) {
-		printk(KERN_WARNING "POSIX clock id %d lacks clock_get()\n",
+	if (!new_clock->clock_get && !new_clock->clock_get64) {
+		printk(KERN_WARNING "POSIX clock id %d lacks clock_get() and clock_get64()\n",
 		       clock_id);
 		return;
 	}
-	if (!new_clock->clock_getres) {
-		printk(KERN_WARNING "POSIX clock id %d lacks clock_getres()\n",
+	if (!new_clock->clock_getres && !new_clock->clock_getres64) {
+		printk(KERN_WARNING "POSIX clock id %d lacks clock_getres() and clock_getres64()\n",
 		       clock_id);
 		return;
 	}
@@ -579,7 +579,7 @@ static struct k_clock *clockid_to_kclock(const clockid_t id)
 		return (id & CLOCKFD_MASK) == CLOCKFD ?
 			&clock_posix_dynamic : &clock_posix_cpu;
 
-	if (id >= MAX_CLOCKS || !posix_clocks[id].clock_getres)
+	if (id >= MAX_CLOCKS || (!posix_clocks[id].clock_getres && !posix_clocks[id].clock_getres64))
 		return NULL;
 	return &posix_clocks[id];
 }
@@ -771,6 +771,7 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 		struct itimerspec __user *, setting)
 {
 	struct itimerspec cur_setting;
+	struct itimerspec64 cur_setting64;
 	struct k_itimer *timr;
 	struct k_clock *kc;
 	unsigned long flags;
@@ -781,10 +782,16 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 		return -EINVAL;
 
 	kc = clockid_to_kclock(timr->it_clock);
-	if (WARN_ON_ONCE(!kc || !kc->timer_get))
+	if (WARN_ON_ONCE(!kc || (!kc->timer_get && !kc->timer_get64))) {
 		ret = -EINVAL;
-	else
-		kc->timer_get(timr, &cur_setting);
+	} else {
+		if (kc->timer_get64) {
+			kc->timer_get64(timr, &cur_setting64);
+			cur_setting = itimerspec64_to_itimerspec(cur_setting64);
+		} else {
+			kc->timer_get(timr, &cur_setting);
+		}
+	}
 
 	unlock_timer(timr, flags);
 
@@ -877,6 +884,7 @@ SYSCALL_DEFINE4(timer_settime, timer_t, timer_id, int, flags,
 {
 	struct k_itimer *timr;
 	struct itimerspec new_spec, old_spec;
+	struct itimerspec64 new_spec64, old_spec64;
 	int error = 0;
 	unsigned long flag;
 	struct itimerspec *rtn = old_setting ? &old_spec : NULL;
@@ -897,10 +905,19 @@ retry:
 		return -EINVAL;
 
 	kc = clockid_to_kclock(timr->it_clock);
-	if (WARN_ON_ONCE(!kc || !kc->timer_set))
+	if (WARN_ON_ONCE(!kc || (!kc->timer_set && !kc->timer_set64))) {
 		error = -EINVAL;
-	else
-		error = kc->timer_set(timr, flags, &new_spec, rtn);
+	} else {
+		if (kc->timer_set64) {
+			new_spec64 = itimerspec_to_itimerspec64(new_spec);
+			error = kc->timer_set64(timr, flags, &new_spec64,
+						&old_spec64);
+			if (old_setting)
+				old_spec = itimerspec64_to_itimerspec(old_spec64);
+		} else {
+			error = kc->timer_set(timr, flags, &new_spec, rtn);
+		}
+	}
 
 	unlock_timer(timr, flag);
 	if (error == TIMER_RETRY) {
@@ -1007,14 +1024,20 @@ SYSCALL_DEFINE2(clock_settime, const clockid_t, which_clock,
 {
 	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timespec new_tp;
+	struct timespec64 new_tp64;
 
-	if (!kc || !kc->clock_set)
+	if (!kc || (!kc->clock_set && !kc->clock_set64))
 		return -EINVAL;
 
 	if (copy_from_user(&new_tp, tp, sizeof (*tp)))
 		return -EFAULT;
 
-	return kc->clock_set(which_clock, &new_tp);
+	if (kc->clock_set64) {
+		new_tp64 = timespec_to_timespec64(new_tp);
+		return kc->clock_set64(which_clock, &new_tp64);
+	} else {
+		return kc->clock_set(which_clock, &new_tp);
+	}
 }
 
 SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
@@ -1022,12 +1045,18 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
 {
 	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timespec kernel_tp;
+	struct timespec64 kernel_tp64;
 	int error;
 
 	if (!kc)
 		return -EINVAL;
 
-	error = kc->clock_get(which_clock, &kernel_tp);
+	if (kc->clock_get64) {
+		error = kc->clock_get64(which_clock, &kernel_tp64);
+		kernel_tp = timespec64_to_timespec(kernel_tp64);
+	} else {
+		error = kc->clock_get(which_clock, &kernel_tp);
+	}
 
 	if (!error && copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
 		error = -EFAULT;
@@ -1063,12 +1092,18 @@ SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock,
 {
 	struct k_clock *kc = clockid_to_kclock(which_clock);
 	struct timespec rtn_tp;
+	struct timespec64 rtn_tp64;
 	int error;
 
 	if (!kc)
 		return -EINVAL;
 
-	error = kc->clock_getres(which_clock, &rtn_tp);
+	if (kc->clock_getres64) {
+		error = kc->clock_getres64(which_clock, &rtn_tp64);
+		rtn_tp = timespec64_to_timespec(rtn_tp64);
+	} else {
+		error = kc->clock_getres(which_clock, &rtn_tp);
+	}
 
 	if (!error && tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp)))
 		error = -EFAULT;
-- 
1.7.9.5
