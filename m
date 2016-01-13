From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v6 7/9] Remove duplicated code in ktime_get_raw_and_real()
Date: Wed, 13 Jan 2016 04:12:27 -0800
Message-ID: <1452687149-11281-8-git-send-email-christopher.s.hall@intel.com>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code in ktime_get_snapshot() is a superset of the code in
ktime_get_raw_and_real() code. Further, ktime_get_raw_and_real() is
called only by the PPS code, pps_get_ts(). Consolidate the
pps_get_ts() code into a single function calling ktime_get_snapshot()
and eliminate ktime_get_raw_and_real(). A side effect of this is that
the raw and real results of pps_get_ts() correspond to exactly the
same clock cycle. Previously these values represented separate reads
of the system clock.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 include/linux/pps_kernel.h | 17 ++++++-----------
 kernel/time/timekeeping.c  | 40 ++--------------------------------------
 2 files changed, 8 insertions(+), 49 deletions(-)

diff --git a/include/linux/pps_kernel.h b/include/linux/pps_kernel.h
index 54bf148..35ac903 100644
--- a/include/linux/pps_kernel.h
+++ b/include/linux/pps_kernel.h
@@ -111,22 +111,17 @@ static inline void timespec_to_pps_ktime(struct pps_ktime *kt,
 	kt->nsec = ts.tv_nsec;
 }
 
-#ifdef CONFIG_NTP_PPS
-
 static inline void pps_get_ts(struct pps_event_time *ts)
 {
-	ktime_get_raw_and_real_ts64(&ts->ts_raw, &ts->ts_real);
-}
+	struct system_time_snapshot snap;
 
-#else /* CONFIG_NTP_PPS */
-
-static inline void pps_get_ts(struct pps_event_time *ts)
-{
-	ktime_get_real_ts64(&ts->ts_real);
+	ktime_get_snapshot(&snap);
+	ts->ts_real = ktime_to_timespec64(snap.real);
+#ifdef CONFIG_NTP_PPS
+	ts->ts_raw = ktime_to_timespec64(snap.raw);
+#endif
 }
 
-#endif /* CONFIG_NTP_PPS */
-
 /* Subtract known time delay from PPS event time(s) */
 static inline void pps_sub_ts(struct pps_event_time *ts, struct timespec64 delta)
 {
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 54554ac..9975ca4 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -877,6 +877,8 @@ void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
 	s64 nsec_real;
 	cycle_t now;
 
+	WARN_ON(timekeeping_suspended);
+
 	do {
 		seq = read_seqcount_begin(&tk_core.seq);
 
@@ -896,44 +898,6 @@ void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
 }
 EXPORT_SYMBOL_GPL(ktime_get_snapshot);
 
-#ifdef CONFIG_NTP_PPS
-
-/**
- * ktime_get_raw_and_real_ts64 - get day and raw monotonic time in timespec format
- * @ts_raw:	pointer to the timespec to be set to raw monotonic time
- * @ts_real:	pointer to the timespec to be set to the time of day
- *
- * This function reads both the time of day and raw monotonic time at the
- * same time atomically and stores the resulting timestamps in timespec
- * format.
- */
-void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw, struct timespec64 *ts_real)
-{
-	struct timekeeper *tk = &tk_core.timekeeper;
-	unsigned long seq;
-	s64 nsecs_raw, nsecs_real;
-
-	WARN_ON_ONCE(timekeeping_suspended);
-
-	do {
-		seq = read_seqcount_begin(&tk_core.seq);
-
-		*ts_raw = tk->raw_time;
-		ts_real->tv_sec = tk->xtime_sec;
-		ts_real->tv_nsec = 0;
-
-		nsecs_raw  = timekeeping_get_ns(&tk->tkr_raw);
-		nsecs_real = timekeeping_get_ns(&tk->tkr_mono);
-
-	} while (read_seqcount_retry(&tk_core.seq, seq));
-
-	timespec64_add_ns(ts_raw, nsecs_raw);
-	timespec64_add_ns(ts_real, nsecs_real);
-}
-EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
-
-#endif /* CONFIG_NTP_PPS */
-
 /**
  * adjust_historical_crosststamp - adjust crosstimestamp previous to current interval
  * @total_history_cycles:	Total history length in cycles
-- 
2.1.4
