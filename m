From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 11/11] k_clock:Remove the 32bit methods with timespec type
Date: Mon, 20 Apr 2015 13:57:39 +0800
Message-ID: <1429509459-17068-12-git-send-email-baolin.wang@linaro.org>
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
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33874 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718AbbDTF7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 01:59:52 -0400
Received: by pdbqa5 with SMTP id qa5so197308369pdb.1
        for <netdev@vger.kernel.org>; Sun, 19 Apr 2015 22:59:52 -0700 (PDT)
In-Reply-To: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of the k_clock users have been converted to the new methods. This patch
removes the older methods with timepsec/itimerspec type.  As a result, the k_clock
structure is ready for the year 2038.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/posix-timers.h |    9 ------
 kernel/time/posix-timers.c   |   72 +++++++++++++++++-------------------------
 2 files changed, 29 insertions(+), 52 deletions(-)

diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 35786c5..7c3dae2 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -97,29 +97,20 @@ struct k_itimer {
 };
 
 struct k_clock {
-	int (*clock_getres) (const clockid_t which_clock, struct timespec *tp);
 	int (*clock_getres64) (const clockid_t which_clock, struct timespec64 *tp);
-	int (*clock_set) (const clockid_t which_clock,
-			  const struct timespec *tp);
 	int (*clock_set64) (const clockid_t which_clock,
 			    const struct timespec64 *tp);
-	int (*clock_get) (const clockid_t which_clock, struct timespec * tp);
 	int (*clock_get64) (const clockid_t which_clock, struct timespec64 *tp);
 	int (*clock_adj) (const clockid_t which_clock, struct timex *tx);
 	int (*timer_create) (struct k_itimer *timer);
 	int (*nsleep) (const clockid_t which_clock, int flags,
 		       struct timespec *, struct timespec __user *);
 	long (*nsleep_restart) (struct restart_block *restart_block);
-	int (*timer_set) (struct k_itimer * timr, int flags,
-			  struct itimerspec * new_setting,
-			  struct itimerspec * old_setting);
 	int (*timer_set64) (struct k_itimer *timr, int flags,
 			    struct itimerspec64 *new_setting,
 			    struct itimerspec64 *old_setting);
 	int (*timer_del) (struct k_itimer * timr);
 #define TIMER_RETRY 1
-	void (*timer_get) (struct k_itimer * timr,
-			   struct itimerspec * cur_setting);
 	void (*timer_get64) (struct k_itimer *timr,
 			     struct itimerspec64 *cur_setting);
 };
diff --git a/kernel/time/posix-timers.c b/kernel/time/posix-timers.c
index 47d1abf..3196ec0 100644
--- a/kernel/time/posix-timers.c
+++ b/kernel/time/posix-timers.c
@@ -528,13 +528,13 @@ void posix_timers_register_clock(const clockid_t clock_id,
 		return;
 	}
 
-	if (!new_clock->clock_get && !new_clock->clock_get64) {
-		printk(KERN_WARNING "POSIX clock id %d lacks clock_get() and clock_get64()\n",
+	if (!new_clock->clock_get64) {
+		printk(KERN_WARNING "POSIX clock id %d lacks clock_get64()\n",
 		       clock_id);
 		return;
 	}
-	if (!new_clock->clock_getres && !new_clock->clock_getres64) {
-		printk(KERN_WARNING "POSIX clock id %d lacks clock_getres() and clock_getres64()\n",
+	if (!!new_clock->clock_getres64) {
+		printk(KERN_WARNING "POSIX clock id %d lacks clock_getres64()\n",
 		       clock_id);
 		return;
 	}
@@ -585,7 +585,7 @@ static struct k_clock *clockid_to_kclock(const clockid_t id)
 		return (id & CLOCKFD_MASK) == CLOCKFD ?
 			&clock_posix_dynamic : &clock_posix_cpu;
 
-	if (id >= MAX_CLOCKS || (!posix_clocks[id].clock_getres && !posix_clocks[id].clock_getres64))
+	if (id >= MAX_CLOCKS || !posix_clocks[id].clock_getres64)
 		return NULL;
 	return &posix_clocks[id];
 }
@@ -788,15 +788,11 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
 		return -EINVAL;
 
 	kc = clockid_to_kclock(timr->it_clock);
-	if (WARN_ON_ONCE(!kc || (!kc->timer_get && !kc->timer_get64))) {
+	if (WARN_ON_ONCE(!kc || !kc->timer_get64)) {
 		ret = -EINVAL;
 	} else {
-		if (kc->timer_get64) {
-			kc->timer_get64(timr, &cur_setting64);
-			cur_setting = itimerspec64_to_itimerspec(cur_setting64);
-		} else {
-			kc->timer_get(timr, &cur_setting);
-		}
+		kc->timer_get64(timr, &cur_setting64);
+		cur_setting = itimerspec64_to_itimerspec(cur_setting64);
 	}
 
 	unlock_timer(timr, flags);
@@ -911,18 +907,14 @@ retry:
 		return -EINVAL;
 
 	kc = clockid_to_kclock(timr->it_clock);
-	if (WARN_ON_ONCE(!kc || (!kc->timer_set && !kc->timer_set64))) {
+	if (WARN_ON_ONCE(!kc || !kc->timer_set64)) {
 		error = -EINVAL;
 	} else {
-		if (kc->timer_set64) {
-			new_spec64 = itimerspec_to_itimerspec64(new_spec);
-			error = kc->timer_set64(timr, flags, &new_spec64,
-						&old_spec64);
-			if (old_setting)
-				old_spec = itimerspec64_to_itimerspec(old_spec64);
-		} else {
-			error = kc->timer_set(timr, flags, &new_spec, rtn);
-		}
+		new_spec64 = itimerspec_to_itimerspec64(new_spec);
+		error = kc->timer_set64(timr, flags, &new_spec64,
+					&old_spec64);
+		if (old_setting)
+			old_spec = itimerspec64_to_itimerspec(old_spec64);
 	}
 
 	unlock_timer(timr, flag);
@@ -1032,18 +1024,14 @@ SYSCALL_DEFINE2(clock_settime, const clockid_t, which_clock,
 	struct timespec new_tp;
 	struct timespec64 new_tp64;
 
-	if (!kc || (!kc->clock_set && !kc->clock_set64))
+	if (!kc || !kc->clock_set64)
 		return -EINVAL;
 
 	if (copy_from_user(&new_tp, tp, sizeof (*tp)))
 		return -EFAULT;
 
-	if (kc->clock_set64) {
-		new_tp64 = timespec_to_timespec64(new_tp);
-		return kc->clock_set64(which_clock, &new_tp64);
-	} else {
-		return kc->clock_set(which_clock, &new_tp);
-	}
+	new_tp64 = timespec_to_timespec64(new_tp);
+	return kc->clock_set64(which_clock, &new_tp64);
 }
 
 SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
@@ -1057,14 +1045,13 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
 	if (!kc)
 		return -EINVAL;
 
-	if (kc->clock_get64) {
-		error = kc->clock_get64(which_clock, &kernel_tp64);
-		kernel_tp = timespec64_to_timespec(kernel_tp64);
-	} else {
-		error = kc->clock_get(which_clock, &kernel_tp);
-	}
+	error = kc->clock_get64(which_clock, &kernel_tp64);
+	if (!error)
+		return error;
+
+	kernel_tp = timespec64_to_timespec(kernel_tp64);
 
-	if (!error && copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
+	if (copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
 		error = -EFAULT;
 
 	return error;
@@ -1104,14 +1091,13 @@ SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock,
 	if (!kc)
 		return -EINVAL;
 
-	if (kc->clock_getres64) {
-		error = kc->clock_getres64(which_clock, &rtn_tp64);
-		rtn_tp = timespec64_to_timespec(rtn_tp64);
-	} else {
-		error = kc->clock_getres(which_clock, &rtn_tp);
-	}
+	error = kc->clock_getres64(which_clock, &rtn_tp64);
+	if (!error)
+		return error;
+
+	rtn_tp = timespec64_to_timespec(rtn_tp64);
 
-	if (!error && tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp)))
+	if (tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp)))
 		error = -EFAULT;
 
 	return error;
-- 
1.7.9.5
