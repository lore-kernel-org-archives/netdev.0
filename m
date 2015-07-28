From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH 1/5] Add functions producing system time given a backing counter value
Date: Mon, 27 Jul 2015 17:46:52 -0700
Message-ID: <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* counter_to_rawmono64
* counter_to_mono64
* counter_to_realtime64

Enables drivers to translate a captured system clock counter to system
time. This is useful for network and audio devices that capture timestamps
in terms of both the system clock and device clock.

Signed-off-by: Christopher Hall <christopher.s.hall@intel.com>
---
 include/linux/timekeeping.h |   8 ++
 kernel/time/timekeeping.c   | 211 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 199 insertions(+), 20 deletions(-)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 6e191e4..04e6455 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_TIMEKEEPING_H
 #define _LINUX_TIMEKEEPING_H
 
+struct clocksource; /* Defined in clocksource.h */
+
 /* Included from linux/ktime.h */
 
 void timekeeping_init(void);
@@ -27,6 +29,12 @@ struct timespec __current_kernel_time(void);
  */
 struct timespec64 get_monotonic_coarse64(void);
 extern void getrawmonotonic64(struct timespec64 *ts);
+extern int counter_to_rawmono64
+(struct timespec64 *rawmono, cycle_t counterval, struct clocksource *cs);
+extern int counter_to_mono64
+(struct timespec64 *mono, cycle_t counterval, struct clocksource *cs);
+extern int counter_to_realtime64
+(struct timespec64 *realtime, cycle_t counterval, struct clocksource *cs);
 extern void ktime_get_ts64(struct timespec64 *ts);
 extern time64_t ktime_get_seconds(void);
 extern time64_t ktime_get_real_seconds(void);
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index bca3667..1ca4fe0 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -116,6 +116,8 @@ static inline void tk_update_sleep_time(struct timekeeper *tk, ktime_t delta)
 	tk->offs_boot = ktime_add(tk->offs_boot, delta);
 }
 
+#define ROLLOVER_THRESHOLD (2ULL << 39)
+
 #ifdef CONFIG_DEBUG_TIMEKEEPING
 #define WARNING_FREQ (HZ*300) /* 5 minute rate-limiting */
 
@@ -158,10 +160,11 @@ static void timekeeping_check_update(struct timekeeper *tk, cycle_t offset)
 	}
 }
 
-static inline cycle_t timekeeping_get_delta(struct tk_read_base *tkr)
+static inline int timekeeping_get_delta
+(cycle_t *delta, struct tk_read_base *tkr, cycle_t *counterval)
 {
 	struct timekeeper *tk = &tk_core.timekeeper;
-	cycle_t now, last, mask, max, delta;
+	cycle_t now = *counterval, last, mask, max, delta;
 	unsigned int seq;
 
 	/*
@@ -173,46 +176,61 @@ static inline cycle_t timekeeping_get_delta(struct tk_read_base *tkr)
 	 */
 	do {
 		seq = read_seqcount_begin(&tk_core.seq);
-		now = tkr->read(tkr->clock);
+		if (counterval == NULL) {
+			now = tkr->read(tkr->clock);
+		} else {
+			if (now < tkr->cycle_last &&
+			   tkr->cycle_last - now < ROLLOVER_THRESHOLD)
+				return -EAGAIN;
+		}
 		last = tkr->cycle_last;
 		mask = tkr->mask;
 		max = tkr->clock->max_cycles;
 	} while (read_seqcount_retry(&tk_core.seq, seq));
 
-	delta = clocksource_delta(now, last, mask);
+	*delta = clocksource_delta(now, last, mask);
 
 	/*
 	 * Try to catch underflows by checking if we are seeing small
 	 * mask-relative negative values.
 	 */
-	if (unlikely((~delta & mask) < (mask >> 3))) {
+	if (unlikely((~*delta & mask) < (mask >> 3))) {
 		tk->underflow_seen = 1;
-		delta = 0;
+		*delta = 0;
 	}
 
 	/* Cap delta value to the max_cycles values to avoid mult overflows */
-	if (unlikely(delta > max)) {
-		tk->overflow_seen = 1;
-		delta = tkr->clock->max_cycles;
+	if (unlikely(*delta > max)) {
+		tk->underflow_seen = 1;
+		*delta = tkr->clock->max_cycles;
 	}
 
-	return delta;
+	return 0;
 }
 #else
-static inline void timekeeping_check_update(struct timekeeper *tk, cycle_t offset)
+static inline void timekeeping_check_update
+(struct timekeeper *tk, cycle_t offset)
 {
 }
-static inline cycle_t timekeeping_get_delta(struct tk_read_base *tkr)
+static inline cycle_t timekeeping_get_delta
+(cycle_t *delta, struct tk_read_base *tkr, cycle_t *counterval)
 {
-	cycle_t cycle_now, delta;
+	cycle_t cycle_now;
 
 	/* read clocksource */
-	cycle_now = tkr->read(tkr->clock);
+	if (counterval == NULL) {
+		cycle_now = tkr->read(tkr->clock);
+	} else {
+		cycle_now = *counterval;
+		if (cycle_now < tkr->cycle_last &&
+		   tkr->cycle_last - cycle_now < ROLLOVER_THRESHOLD)
+			return -EAGAIN;
+	}
 
 	/* calculate the delta since the last update_wall_time */
-	delta = clocksource_delta(cycle_now, tkr->cycle_last, tkr->mask);
+	*delta = clocksource_delta(cycle_now, tkr->cycle_last, tkr->mask);
 
-	return delta;
+	return 0;
 }
 #endif
 
@@ -298,13 +316,11 @@ u32 (*arch_gettimeoffset)(void) = default_arch_gettimeoffset;
 static inline u32 arch_gettimeoffset(void) { return 0; }
 #endif
 
-static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
+static inline s64 timekeeping_delta_to_ns
+(struct tk_read_base *tkr, cycle_t delta)
 {
-	cycle_t delta;
 	s64 nsec;
 
-	delta = timekeeping_get_delta(tkr);
-
 	nsec = delta * tkr->mult + tkr->xtime_nsec;
 	nsec >>= tkr->shift;
 
@@ -312,6 +328,28 @@ static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
 	return nsec + arch_gettimeoffset();
 }
 
+static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
+{
+	cycle_t delta;
+
+	timekeeping_get_delta(&delta, tkr, NULL);
+	return timekeeping_delta_to_ns(tkr, delta);
+}
+
+static inline int timekeeping_counter_to_ns
+(s64 *nsec, struct tk_read_base *tkr, cycle_t counterval)
+{
+	cycle_t delta;
+	int err;
+
+	err = timekeeping_get_delta(&delta, tkr, &counterval);
+	if (err != 0)
+		return err;
+
+	*nsec = timekeeping_delta_to_ns(tkr, delta);
+	return 0;
+}
+
 /**
  * update_fast_timekeeper - Update the fast and NMI safe monotonic timekeeper.
  * @tkr: Timekeeping readout base from which we take the update
@@ -1117,6 +1155,139 @@ void getrawmonotonic64(struct timespec64 *ts)
 EXPORT_SYMBOL(getrawmonotonic64);
 
 
+ /**
+ * counterval_to_rawmono64 - Returns the raw monotonic time given a counter
+ * value
+ * @counterval:          counter value (input)
+ * @rawmono:             raw monotonic clock (output)
+ * @cs:                  clocksource from which clockvalue is derived
+ *
+ * Returns:
+ *   0      - Success
+ *  -EAGAIN - Clock value is in the past, try again
+ *  -ENXIO  - Clocksource 'cs' doesn't match the current clocksource
+ *
+ */
+int counter_to_rawmono64(struct timespec64 *rawmono, cycle_t counterval,
+			 struct clocksource *cs)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	struct clocksource *curr_clock;
+	struct timespec64 ts64;
+	unsigned long seq;
+	s64 nsecs;
+	int err;
+
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+		err = timekeeping_counter_to_ns
+			(&nsecs, &tk->tkr_raw, counterval);
+		if (err != 0)
+			return err;
+		ts64 = tk->raw_time;
+		curr_clock = tk->tkr_raw.clock;
+	} while (read_seqcount_retry(&tk_core.seq, seq));
+
+	if (curr_clock != cs)
+		return -ENXIO;
+
+	timespec64_add_ns(&ts64, nsecs);
+	*rawmono = ts64;
+
+	return 0;
+}
+EXPORT_SYMBOL(counter_to_rawmono64);
+
+ /**
+ * counterval_to_realtime64 - Returns the real time given a counter
+ * value
+ * @counterval:          counter value (input)
+ * @realtime:             realtime clock (output)
+ * @cs:                  clocksource from which clockvalue is derived
+ *
+ * Returns:
+ *   0      - Success
+ *  -EAGAIN - Clock value is in the past, try again
+ *  -ENXIO  - Clocksource 'cs' doesn't match the current clocksource
+ *
+ */
+int counter_to_realtime64(struct timespec64 *realtime, cycle_t counterval,
+			  struct clocksource *cs)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	struct clocksource *curr_clock;
+	struct timespec64 ts64;
+	unsigned long seq;
+	s64 nsecs;
+	int err;
+
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+		err = timekeeping_counter_to_ns
+			(&nsecs, &tk->tkr_mono, counterval);
+		if (err != 0)
+			return err;
+		ts64.tv_sec = tk->xtime_sec;
+		curr_clock = tk->tkr_mono.clock;
+	} while (read_seqcount_retry(&tk_core.seq, seq));
+
+	if (curr_clock != cs)
+		return -ENXIO;
+
+	ts64.tv_nsec = 0;
+	timespec64_add_ns(&ts64, nsecs);
+	*realtime = ts64;
+
+	return 0;
+}
+EXPORT_SYMBOL(counter_to_realtime64);
+
+ /**
+ * counterval_to_mono64 - Returns the real time given a counter
+ * value
+ * @counterval:          counter value (input)
+ * @realtime:             realtime clock (output)
+ * @cs:                  clocksource from which clockvalue is derived
+ *
+ * Returns:
+ *   0      - Success
+ *  -EAGAIN - Clock value is in the past, try again
+ *  -ENXIO  - Clocksource 'cs' doesn't match the current clocksource
+ *
+ */
+int counter_to_mono64(struct timespec64 *mono, cycle_t counterval,
+		      struct clocksource *cs)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	struct clocksource *curr_clock;
+	struct timespec64 tomono;
+	struct timespec64 ts64;
+	unsigned long seq;
+	s64 nsecs;
+	int err;
+
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+		err = timekeeping_counter_to_ns
+			(&nsecs, &tk->tkr_mono, counterval);
+		if (err != 0)
+			return err;
+		ts64.tv_sec = tk->xtime_sec;
+		tomono = tk->wall_to_monotonic;
+		curr_clock = tk->tkr_mono.clock;
+	} while (read_seqcount_retry(&tk_core.seq, seq));
+
+	if (curr_clock != cs)
+		return -ENXIO;
+
+	ts64.tv_nsec = 0;
+	timespec64_add_ns(&ts64, nsecs);
+	*mono = timespec64_add(ts64, tomono);
+
+	return 0;
+}
+EXPORT_SYMBOL(counter_to_mono64);
+
 /**
  * timekeeping_valid_for_hres - Check if timekeeping is suitable for hres
  */
-- 
1.9.1
