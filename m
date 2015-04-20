From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 03/11] time/hrtimer:Introduce hrtimer_get_res64() with timespec64 type for getting the timer resolution
Date: Mon, 20 Apr 2015 13:57:31 +0800
Message-ID: <1429509459-17068-4-git-send-email-baolin.wang@linaro.org>
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

This patch introduces hrtimer_get_res64() function to get the timer resolution
with timespec64 type, and moves the hrtimer_get_res() function into
include/linux/hrtimer.h as a 'static inline' helper that just calls hrtimer_get_res64.

It is ready for 2038 year when getting the timer resolution by hrtimer_get_res64() function
with timespec64 type, and it is convenient to delete the old hrtimer_get_res() function
in hrtimer.h file.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/hrtimer.h |   12 +++++++++++-
 kernel/time/hrtimer.c   |   10 +++++-----
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
index 05f6df1..ee8ed44 100644
--- a/include/linux/hrtimer.h
+++ b/include/linux/hrtimer.h
@@ -383,7 +383,17 @@ static inline int hrtimer_restart(struct hrtimer *timer)
 
 /* Query timers: */
 extern ktime_t hrtimer_get_remaining(const struct hrtimer *timer);
-extern int hrtimer_get_res(const clockid_t which_clock, struct timespec *tp);
+extern int hrtimer_get_res64(const clockid_t which_clock,
+			     struct timespec64 *tp);
+
+static inline int hrtimer_get_res(const clockid_t which_clock,
+				  struct timespec *tp)
+{
+	struct timespec64 *ts64;
+
+	*ts64 = timespec_to_timespec64(*tp);
+	return hrtimer_get_res64(which_clock, ts64);
+}
 
 extern ktime_t hrtimer_get_next_event(void);
 
diff --git a/kernel/time/hrtimer.c b/kernel/time/hrtimer.c
index bee0c1f..508d936 100644
--- a/kernel/time/hrtimer.c
+++ b/kernel/time/hrtimer.c
@@ -1175,24 +1175,24 @@ void hrtimer_init(struct hrtimer *timer, clockid_t clock_id,
 EXPORT_SYMBOL_GPL(hrtimer_init);
 
 /**
- * hrtimer_get_res - get the timer resolution for a clock
+ * hrtimer_get_res64 - get the timer resolution for a clock
  * @which_clock: which clock to query
- * @tp:		 pointer to timespec variable to store the resolution
+ * @tp:		 pointer to timespec64 variable to store the resolution
  *
  * Store the resolution of the clock selected by @which_clock in the
  * variable pointed to by @tp.
  */
-int hrtimer_get_res(const clockid_t which_clock, struct timespec *tp)
+int hrtimer_get_res64(const clockid_t which_clock, struct timespec64 *tp)
 {
 	struct hrtimer_cpu_base *cpu_base;
 	int base = hrtimer_clockid_to_base(which_clock);
 
 	cpu_base = raw_cpu_ptr(&hrtimer_bases);
-	*tp = ktime_to_timespec(cpu_base->clock_base[base].resolution);
+	*tp = ktime_to_timespec64(cpu_base->clock_base[base].resolution);
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(hrtimer_get_res);
+EXPORT_SYMBOL_GPL(hrtimer_get_res64);
 
 static void __run_hrtimer(struct hrtimer *timer, ktime_t *now)
 {
-- 
1.7.9.5
