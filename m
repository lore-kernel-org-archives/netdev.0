From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v6 6/9] Add history to cross timestamp interface supporting slower devices
Date: Wed, 13 Jan 2016 04:12:26 -0800
Message-ID: <1452687149-11281-7-git-send-email-christopher.s.hall@intel.com>
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

Another representative use case of time sync and the correlated
clocksource (in addition to PTP noted above) is PTP synchronized
audio.

In a streaming application, as an example, samples will be sent and/or
received by multiple devices with a presentation time that is in terms
of the PTP master clock. Synchronizing the audio output on these
devices requires correlating the audio clock with the PTP master
clock. The more precise this correlation is, the better the audio
quality (i.e. out of sync audio sounds bad).

>From an application standpoint, to correlate the PTP master clock with
the audio device clock, the system clock is used as a intermediate
timebase. The transforms such an application would perform are:

    System Clock <-> Audio clock
    System Clock <-> Network Device Clock [<-> PTP Master Clock]

Such audio applications make use of some existing ALSA library calls
that provide audio/system cross-timestamps (e.g.
snd_pcm_status_get_htstamp()). Previous driver implementations capture
these cross timestamps by reading the system clock (raw/mono/real) and
the device clock with greatest degree of simultaneity possible in
software.

Modern Intel platforms can perform a more accurate cross timestamp in
hardware (ART,audio device clock).  The audio driver requires
ART->system time transforms -- the same as required for the network
driver. These platforms offload audio processing (including
cross-timestamps) to a DSP which to ensure uninterrupted audio
processing, communicates and response to the host only once every
millsecond. As a result is takes up to a millisecond for the DSP to
receive a request, the request is processed by the DSP, the audio
output hardware is polled for completion, the result is copied into
shared memory, and the host is notified. All of these operation occur
on a millisecond cadence.  This transaction requires about 2 ms, but
under heavier workloads it may take up to 4 ms.

If update_wall_time() is called while waiting for a response within
get_device_system_crosststamp() (from previous patch), a retry is
attempted. This will occur if the cycle_interval (determined by
CONFIG_HZ and mult/shift values) cycles elapse.

Adding a history allows these slow devices the option of providing an
ART value outside of the retry loop. In this case, the callback
provided is an accessor function for the previously obtained counter
value. If get_system_device_crosststamp() receives a counter value
previous to cycle_last, it consults the history provided as an
argument in history_ref and interpolates the realtime and monotonic
raw system time using the provided counter value. If there are any
clock discontinuities, e.g. from calling settimeofday(), the monotonic
raw time is interpolated in the usual way, but the realtime clock time
is adjusted by scaling the monotonic raw adjustment.

When an accessor function is used a history argument *must* be
provided. The history is initialized using ktime_get_snapshot() and
must be called before the counter values are read.

When the history is used to interpolate timestamp values, the realtime
clock time may be inaccurate to some degree. In general, the
longer the length of history the larger the interpolation error. If
there are discontinuities (large step changes) to the time, the error
can be very large.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 include/linux/clocksource.h         |   4 ++
 include/linux/timekeeper_internal.h |   2 +
 include/linux/timekeeping.h         |   3 +-
 kernel/time/timekeeping.c           | 130 ++++++++++++++++++++++++++++++++++++
 4 files changed, 138 insertions(+), 1 deletion(-)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index cccbd1c..229aee0 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -287,11 +287,15 @@ struct correlated_cs {
  * @cycles:	Clocksource counter value to produce the system times
  * @real:	Realtime system time
  * @raw:	Monotonic raw system time
+ * @clock_was_set_seq:	The sequence number of clock was set events
+ * @cs_was_changed_seq:	The sequence number of clocksource change events
  */
 struct system_time_snapshot {
 	cycles_t	cycles;
 	ktime_t		real;
 	ktime_t		raw;
+	unsigned int	clock_was_set_seq;
+	u8		cs_was_changed_seq;
 };
 
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/include/linux/timekeeper_internal.h b/include/linux/timekeeper_internal.h
index 2524722..e880054 100644
--- a/include/linux/timekeeper_internal.h
+++ b/include/linux/timekeeper_internal.h
@@ -50,6 +50,7 @@ struct tk_read_base {
  * @offs_tai:		Offset clock monotonic -> clock tai
  * @tai_offset:		The current UTC to TAI offset in seconds
  * @clock_was_set_seq:	The sequence number of clock was set events
+ * @cs_was_changed_seq:	The sequence number of clocksource change events
  * @next_leap_ktime:	CLOCK_MONOTONIC time value of a pending leap-second
  * @raw_time:		Monotonic raw base time in timespec64 format
  * @cycle_interval:	Number of clock cycles in one NTP interval
@@ -91,6 +92,7 @@ struct timekeeper {
 	ktime_t			offs_tai;
 	s32			tai_offset;
 	unsigned int		clock_was_set_seq;
+	u8			cs_was_changed_seq;
 	ktime_t			next_leap_ktime;
 	struct timespec64	raw_time;
 
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index f5fe657..dff97c4 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -295,13 +295,14 @@ struct sync_device_time_cb {
 	void	 *ctx;
 };
 
+struct system_time_snapshot;
 /*
  * Get cross timestamp between system clock and device clock
  */
 extern int get_device_system_crosststamp(struct sync_device_time_cb *cb,
+					 struct system_time_snapshot *history,
 					 struct system_device_crosststamp *ts);
 
-struct system_time_snapshot;
 /*
  * Simultaneously snapshot realtime and monotonic raw clocks
  */
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 26049df..54554ac 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -233,6 +233,7 @@ static void tk_setup_internals(struct timekeeper *tk, struct clocksource *clock)
 	u64 tmp, ntpinterval;
 	struct clocksource *old_clock;
 
+	++tk->cs_was_changed_seq;
 	old_clock = tk->tkr_mono.clock;
 	tk->tkr_mono.clock = clock;
 	tk->tkr_mono.read = clock->read;
@@ -880,6 +881,8 @@ void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
 		seq = read_seqcount_begin(&tk_core.seq);
 
 		now = tk->tkr_mono.read(tk->tkr_mono.clock);
+		systime_snapshot->cs_was_changed_seq = tk->cs_was_changed_seq;
+		systime_snapshot->clock_was_set_seq = tk->clock_was_set_seq;
 		base_real = ktime_add(tk->tkr_mono.base,
 				      tk_core.timekeeper.offs_real);
 		base_raw = tk->tkr_raw.base;
@@ -932,14 +935,83 @@ EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
 #endif /* CONFIG_NTP_PPS */
 
 /**
+ * adjust_historical_crosststamp - adjust crosstimestamp previous to current interval
+ * @total_history_cycles:	Total history length in cycles
+ * @partial_history_cycles:	Cycle offset into history (fractional part)
+ * @total_history_monoraw:	Total history length in monotonic raw ns
+ * @total_history_realtime:	Total history length in realtime ns
+ * @discontinuity:		True indicates clock was set on history period
+ * @ts:				Cross timestamp that should be adjusted using
+ *	partial/total ratio
+ *
+ * Helper function used by get_device_system_crosststamp() to correct the
+ * crosstimestamp corresponding to the start of the current interval to the
+ * system counter value (timestamp point) provided by the driver. The
+ * total_history_* quantities are the total history starting at the provided
+ * reference point and ending at the start of the current interval. The cycle
+ * count between the driver timestamp point and the start of the current
+ * interval is partial_history_cycles.
+ */
+static void adjust_historical_crosststamp(cycle_t total_history_cycles,
+					  cycle_t partial_history_cycles,
+					  ktime_t total_history_monoraw,
+					  ktime_t total_history_realtime,
+					  bool discontinuity,
+					  struct system_device_crosststamp *ts)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	u64 corr_monoraw;
+	u64 corr_realtime;
+
+	/*
+	 * Scale the monotonic raw time delta by:
+	 *	partial_history_cycles / total_history_cycles
+	 */
+	corr_monoraw = (ktime_to_ns(total_history_monoraw) *
+			partial_history_cycles) / total_history_cycles;
+	/*
+	 * If there is a discontinuity in the history, scale monotonic raw
+	 *	correction by:
+	 *	mult(real)/mult(raw) yielding the realtime correction
+	 * Otherwise, calculate the realtime correction similar to monotonic
+	 *	raw calculation
+	 */
+	if (discontinuity)
+		corr_realtime = (corr_monoraw * tk->tkr_mono.mult) /
+			tk->tkr_raw.mult;
+	else
+		corr_realtime = (ktime_to_ns(total_history_realtime) *
+				 partial_history_cycles)/total_history_cycles;
+
+	/* Fixup monotonic raw and real time time values */
+	ts->sys_monoraw = ktime_sub_ns(ts->sys_monoraw, corr_monoraw);
+	ts->sys_realtime = ktime_sub_ns(ts->sys_realtime, corr_realtime);
+}
+
+/*
+ * cycle_between - true if test occurs chronologically between before and after
+ */
+static bool cycle_between(cycles_t before, cycles_t test, cycles_t after)
+{
+	if (test > before && test < after)
+		return true;
+	if (test < before && before > after)
+		return true;
+	return false;
+}
+
+/**
  * get_device_system_crosststamp - Synchronously capture system/device timestamp
  * @sync_devicetime:	Callback to get simultaneous device time and
  *	system counter from the device driver
+ *@history_ref:		Historical reference point used to interpolate system
+ *	time when counter provided by the driver is before the current interval
  * @xtstamp:		Receives simultaneously captured system and device time
  *
  * Reads a timestamp from a device and correlates it to system time
  */
 int get_device_system_crosststamp(struct sync_device_time_cb *sync_devicetime,
+				  struct system_time_snapshot *history_ref,
 				  struct system_device_crosststamp *xtstamp)
 {
 	struct timekeeper *tk = &tk_core.timekeeper;
@@ -949,6 +1021,12 @@ int get_device_system_crosststamp(struct sync_device_time_cb *sync_devicetime,
 	ktime_t base_real;
 	s64 nsec_raw;
 	s64 nsec_real;
+	cycles_t cycles;
+	cycle_t now;
+	cycle_t interval_start;
+	unsigned int clock_was_set_seq;
+	u8 cs_was_changed_seq;
+	bool do_interp;
 	int ret;
 
 	do {
@@ -970,6 +1048,23 @@ int get_device_system_crosststamp(struct sync_device_time_cb *sync_devicetime,
 		 */
 		if (tk->tkr_mono.clock != system_counterval.cs)
 			return -ENODEV;
+		cycles = system_counterval.cycles;
+
+		/*
+		 * Check whether the system counter value provided by the
+		 * device driver is on the current timekeeping interval.
+		 */
+		now = tk->tkr_mono.read(tk->tkr_mono.clock);
+		interval_start = tk->tkr_mono.cycle_last;
+		if (!cycle_between(interval_start, cycles, now)) {
+			cs_was_changed_seq = tk->cs_was_changed_seq;
+			clock_was_set_seq = tk->clock_was_set_seq;
+			cycles = interval_start;
+			do_interp = true;
+		} else {
+			do_interp = false;
+		}
+
 
 		base_real = ktime_add(tk->tkr_mono.base,
 				      tk_core.timekeeper.offs_real);
@@ -983,6 +1078,41 @@ int get_device_system_crosststamp(struct sync_device_time_cb *sync_devicetime,
 
 	xtstamp->sys_realtime = ktime_add_ns(base_real, nsec_real);
 	xtstamp->sys_monoraw = ktime_add_ns(base_raw, nsec_raw);
+
+	/*
+	 * Interpolate if necessary, adjusting back from the start of the
+	 * current interval
+	 */
+	if (do_interp) {
+		cycle_t total_history_cycles, partial_history_cycles;
+		ktime_t history_monoraw, history_realtime;
+		bool discontinuity;
+
+		/*
+		 * Check that the counter value occurs after the provided
+		 * history reference and that the history doesn't cross a
+		 * clocksource change
+		 */
+		if (!history_ref ||
+		    !cycle_between(history_ref->cycles,
+				   system_counterval.cycles, interval_start) ||
+		    history_ref->cs_was_changed_seq != cs_was_changed_seq)
+			return -EINVAL;
+		partial_history_cycles = cycles - system_counterval.cycles;
+		history_monoraw = ktime_sub(xtstamp->sys_monoraw,
+					    history_ref->raw);
+		history_realtime = ktime_sub(xtstamp->sys_realtime,
+					     history_ref->real);
+		total_history_cycles = cycles - history_ref->cycles;
+		discontinuity =
+			history_ref->clock_was_set_seq != clock_was_set_seq;
+		adjust_historical_crosststamp(total_history_cycles,
+					      partial_history_cycles,
+					      history_monoraw,
+					      history_realtime, discontinuity,
+					      xtstamp);
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(get_device_system_crosststamp);
-- 
2.1.4
