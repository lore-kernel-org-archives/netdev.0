From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 07/11] time/alarmtimer:Convert to the new methods for k_clock structure
Date: Mon, 20 Apr 2015 13:57:35 +0800
Message-ID: <1429509459-17068-8-git-send-email-baolin.wang@linaro.org>
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

This patch changes to the new methods with timespec64/itimerspec64
type of k_clock structure, and converts the timespec/itimerspec type to
timespec64/itimerspec64 typein alarmtimer.c file.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 kernel/time/alarmtimer.c |   43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/kernel/time/alarmtimer.c b/kernel/time/alarmtimer.c
index 1b001ed..68186e1 100644
--- a/kernel/time/alarmtimer.c
+++ b/kernel/time/alarmtimer.c
@@ -489,35 +489,36 @@ static enum alarmtimer_restart alarm_handle_timer(struct alarm *alarm,
 /**
  * alarm_clock_getres - posix getres interface
  * @which_clock: clockid
- * @tp: timespec to fill
+ * @tp: timespec64 to fill
  *
  * Returns the granularity of underlying alarm base clock
  */
-static int alarm_clock_getres(const clockid_t which_clock, struct timespec *tp)
+static int alarm_clock_getres(const clockid_t which_clock,
+				struct timespec64 *tp)
 {
 	clockid_t baseid = alarm_bases[clock2alarm(which_clock)].base_clockid;
 
 	if (!alarmtimer_get_rtcdev())
 		return -EINVAL;
 
-	return hrtimer_get_res(baseid, tp);
+	return hrtimer_get_res64(baseid, tp);
 }
 
 /**
  * alarm_clock_get - posix clock_get interface
  * @which_clock: clockid
- * @tp: timespec to fill.
+ * @tp: timespec64 to fill.
  *
  * Provides the underlying alarm base time.
  */
-static int alarm_clock_get(clockid_t which_clock, struct timespec *tp)
+static int alarm_clock_get(clockid_t which_clock, struct timespec64 *tp)
 {
 	struct alarm_base *base = &alarm_bases[clock2alarm(which_clock)];
 
 	if (!alarmtimer_get_rtcdev())
 		return -EINVAL;
 
-	*tp = ktime_to_timespec(base->gettime());
+	*tp = ktime_to_timespec64(base->gettime());
 	return 0;
 }
 
@@ -547,24 +548,24 @@ static int alarm_timer_create(struct k_itimer *new_timer)
 /**
  * alarm_timer_get - posix timer_get interface
  * @new_timer: k_itimer pointer
- * @cur_setting: itimerspec data to fill
+ * @cur_setting: itimerspec64 data to fill
  *
  * Copies out the current itimerspec data
  */
 static void alarm_timer_get(struct k_itimer *timr,
-				struct itimerspec *cur_setting)
+				struct itimerspec64 *cur_setting)
 {
 	ktime_t relative_expiry_time =
 		alarm_expires_remaining(&(timr->it.alarm.alarmtimer));
 
 	if (ktime_to_ns(relative_expiry_time) > 0) {
-		cur_setting->it_value = ktime_to_timespec(relative_expiry_time);
+		cur_setting->it_value = ktime_to_timespec64(relative_expiry_time);
 	} else {
 		cur_setting->it_value.tv_sec = 0;
 		cur_setting->it_value.tv_nsec = 0;
 	}
 
-	cur_setting->it_interval = ktime_to_timespec(timr->it.alarm.interval);
+	cur_setting->it_interval = ktime_to_timespec64(timr->it.alarm.interval);
 }
 
 /**
@@ -588,14 +589,14 @@ static int alarm_timer_del(struct k_itimer *timr)
  * alarm_timer_set - posix timer_set interface
  * @timr: k_itimer pointer to be deleted
  * @flags: timer flags
- * @new_setting: itimerspec to be used
- * @old_setting: itimerspec being replaced
+ * @new_setting: itimerspec64 to be used
+ * @old_setting: itimerspec64 being replaced
  *
  * Sets the timer to new_setting, and starts the timer.
  */
 static int alarm_timer_set(struct k_itimer *timr, int flags,
-				struct itimerspec *new_setting,
-				struct itimerspec *old_setting)
+				struct itimerspec64 *new_setting,
+				struct itimerspec64 *old_setting)
 {
 	ktime_t exp;
 
@@ -613,8 +614,8 @@ static int alarm_timer_set(struct k_itimer *timr, int flags,
 		return TIMER_RETRY;
 
 	/* start the timer */
-	timr->it.alarm.interval = timespec_to_ktime(new_setting->it_interval);
-	exp = timespec_to_ktime(new_setting->it_value);
+	timr->it.alarm.interval = timespec64_to_ktime(new_setting->it_interval);
+	exp = timespec64_to_ktime(new_setting->it_value);
 	/* Convert (if necessary) to absolute time */
 	if (flags != TIMER_ABSTIME) {
 		ktime_t now;
@@ -670,7 +671,7 @@ static int alarmtimer_do_nsleep(struct alarm *alarm, ktime_t absexp)
 
 
 /**
- * update_rmtp - Update remaining timespec value
+ * update_rmtp - Update remaining timespec64 value
  * @exp: expiration time
  * @type: timer type
  * @rmtp: user pointer to remaining timepsec value
@@ -824,12 +825,12 @@ static int __init alarmtimer_init(void)
 	int error = 0;
 	int i;
 	struct k_clock alarm_clock = {
-		.clock_getres	= alarm_clock_getres,
-		.clock_get	= alarm_clock_get,
+		.clock_getres64	= alarm_clock_getres,
+		.clock_get64	= alarm_clock_get,
 		.timer_create	= alarm_timer_create,
-		.timer_set	= alarm_timer_set,
+		.timer_set64	= alarm_timer_set,
 		.timer_del	= alarm_timer_del,
-		.timer_get	= alarm_timer_get,
+		.timer_get64	= alarm_timer_get,
 		.nsleep		= alarm_timer_nsleep,
 	};
 
-- 
1.7.9.5
