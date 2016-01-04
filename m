From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [RFC v5 3/6] Add history to cross timestamp interface supporting slower devices
Date: Mon,  4 Jan 2016 04:45:20 -0800
Message-ID: <1451911523-8534-4-git-send-email-christopher.s.hall@intel.com>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
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
 include/linux/clocksource.h         |  16 ++++
 include/linux/timekeeper_internal.h |   4 +
 include/linux/timekeeping.h         |   9 +-
 kernel/time/timekeeping.c           | 162 ++++++++++++++++++++++++++++++++++--
 4 files changed, 185 insertions(+), 6 deletions(-)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 4b7973d..f413157 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -282,4 +282,20 @@ struct raw_system_counterval {
 	struct clocksource	*cs;
 };
 
+/*
+ * struct system_time_snapshot - simultaneous raw/real time capture with
+ *	counter value
+ * @cycles:	Clocksource counter value to produce the system times
+ * @real:	Realtime system time
+ * @raw:	Monotonic raw system time
+ * @cs_seq:	Sequence number associated with changed clocksource
+ */
+struct system_time_snapshot {
+	cycles_t	cycles;
+	ktime_t		real;
+	ktime_t		raw;
+	u8		cs_seq;
+	unsigned int	clock_set_seq;
+};
+
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/include/linux/timekeeper_internal.h b/include/linux/timekeeper_internal.h
index 2524722..156b51d 100644
--- a/include/linux/timekeeper_internal.h
+++ b/include/linux/timekeeper_internal.h
@@ -13,6 +13,9 @@
 /**
  * struct tk_read_base - base structure for timekeeping readout
  * @clock:	Current clocksource used for timekeeping.
+ * @cs_seq:	Clocksource sequence is incremented per clocksource change.
+ *	It's used to determine whether past system time can be related to
+ *	current system time
  * @read:	Read function of @clock
  * @mask:	Bitmask for two's complement subtraction of non 64bit clocks
  * @cycle_last: @clock cycle value at last update
@@ -29,6 +32,7 @@
  */
 struct tk_read_base {
 	struct clocksource	*clock;
+	u8			cs_seq;
 	cycle_t			(*read)(struct clocksource *cs);
 	cycle_t			mask;
 	cycle_t			cycle_last;
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 2209943..2f290a2 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -295,11 +295,18 @@ struct get_sync_device_time {
 	void	 *ctx;
 };
 
+struct system_time_snapshot;
+/*
+ * Simultaneously snapshot realtime and monotonic raw clocks
+ */
+extern void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot);
+
 /*
  * Get cross timestamp between system clock and device clock
  */
 extern int get_device_system_crosststamp(struct system_device_crosststamp *ct,
-					 struct get_sync_device_time *dt);
+					 struct get_sync_device_time *dt,
+					 struct system_time_snapshot *history);
 
 /*
  * Persistent clock related interfaces
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 9c1ddc3..5a7f784 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -235,11 +235,13 @@ static void tk_setup_internals(struct timekeeper *tk, struct clocksource *clock)
 
 	old_clock = tk->tkr_mono.clock;
 	tk->tkr_mono.clock = clock;
+	++tk->tkr_mono.cs_seq;
 	tk->tkr_mono.read = clock->read;
 	tk->tkr_mono.mask = clock->mask;
 	tk->tkr_mono.cycle_last = tk->tkr_mono.read(clock);
 
 	tk->tkr_raw.clock = clock;
+	++tk->tkr_raw.cs_seq;
 	tk->tkr_raw.read = clock->read;
 	tk->tkr_raw.mask = clock->mask;
 	tk->tkr_raw.cycle_last = tk->tkr_mono.cycle_last;
@@ -862,6 +864,39 @@ time64_t ktime_get_real_seconds(void)
 }
 EXPORT_SYMBOL_GPL(ktime_get_real_seconds);
 
+/**
+ * ktime_get_snapshot - snapshots the realtime/monotonic raw clocks with counter
+ * @snapshot:	pointer to struct receiving the system time snapshot
+ */
+void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	unsigned long seq;
+	ktime_t base_raw;
+	ktime_t base_real;
+	s64 nsec_raw;
+	s64 nsec_real;
+	cycle_t now;
+
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+
+		now = tk->tkr_mono.read(tk->tkr_mono.clock);
+		systime_snapshot->cs_seq = tk->tkr_mono.cs_seq;
+		systime_snapshot->clock_set_seq = tk->clock_was_set_seq;
+		base_real = ktime_add(tk->tkr_mono.base,
+				      tk_core.timekeeper.offs_real);
+		base_raw = tk->tkr_raw.base;
+		nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono, now);
+		nsec_raw  = timekeeping_cycles_to_ns(&tk->tkr_raw, now);
+	} while (read_seqcount_retry(&tk_core.seq, seq));
+
+	systime_snapshot->cycles = now;
+	systime_snapshot->real = ktime_add_ns(base_real, nsec_real);
+	systime_snapshot->raw = ktime_add_ns(base_raw, nsec_raw);
+}
+EXPORT_SYMBOL_GPL(ktime_get_snapshot);
+
 #ifdef CONFIG_NTP_PPS
 
 /**
@@ -901,15 +936,82 @@ EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
 #endif /* CONFIG_NTP_PPS */
 
 /**
+ * adjust_historical_crosststamp - adjust crosstimestamp previous to current interval
+ * @total_history_cycles:	Total history length in cycles
+ * @partial_history_cycles:	Cycle offset into history (fractional part)
+ * @total_history_monoraw:	Total history length in monotonic raw ns
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
+	 *		mult(real)/mult(raw) yielding the realtime correction
+	 * Otherwise, calculate the realtime correction similar to monotonic
+	 *	raw calculation
+	 */
+	if (discontinuity)
+		corr_realtime = (corr_monoraw * tk->tkr_mono.mult) /
+			tk->tkr_raw.mult;
+	else
+		corr_realtime = (ktime_to_ns(total_history_realtime) *
+				partial_history_cycles) / total_history_cycles;
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
  * @xtstamp:		Receives simultaneously captured system and device time
  * @sync_devicetime:	Callback to get simultaneous device time and
  *	system counter from the device driver
+ * @history_ref:	Historical reference point used to interpolate system
+ *	time when counter provided by the driver is before the current interval
  *
  * Reads a timestamp from a device and correlates it to system time
  */
 int get_device_system_crosststamp(struct system_device_crosststamp *xtstamp,
-				  struct get_sync_device_time *sync_devicetime)
+				  struct get_sync_device_time *sync_devicetime,
+				  struct system_time_snapshot *history_ref)
 {
 	struct timekeeper *tk = &tk_core.timekeeper;
 	unsigned long seq;
@@ -918,6 +1020,12 @@ int get_device_system_crosststamp(struct system_device_crosststamp *xtstamp,
 	ktime_t base_real;
 	s64 nsec_raw;
 	s64 nsec_real;
+	cycles_t cycles;
+	cycle_t now;
+	cycle_t interval_start;
+	unsigned int clock_was_set_seq;
+	u8 cs_seq;
+	bool do_interp;
 	int ret;
 
 	do {
@@ -936,19 +1044,63 @@ int get_device_system_crosststamp(struct system_device_crosststamp *xtstamp,
 		 */
 		if (tk->tkr_mono.clock != raw_sys.cs)
 			return -ENODEV;
+		cycles = raw_sys.cycles;
+
+		/*
+		 * Check whether the system counter value provided by the
+		 * device driver is on the current interval.
+		 */
+		now = tk->tkr_mono.read(tk->tkr_mono.clock);
+		interval_start = tk->tkr_mono.cycle_last;
+		if (!cycle_between(interval_start, cycles, now)) {
+			cs_seq = tk->tkr_mono.cs_seq;
+			clock_was_set_seq = tk->clock_was_set_seq;
+			cycles = interval_start;
+			do_interp = true;
+		} else {
+			do_interp = false;
+		}
 
 		base_real = ktime_add(tk->tkr_mono.base,
 				      tk_core.timekeeper.offs_real);
 		base_raw = tk->tkr_raw.base;
 
-		nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono,
-						     raw_sys.cycles);
-		nsec_raw = timekeeping_cycles_to_ns(&tk->tkr_raw,
-						    raw_sys.cycles);
+		nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono, cycles);
+		nsec_raw = timekeeping_cycles_to_ns(&tk->tkr_raw, cycles);
 	} while (read_seqcount_retry(&tk_core.seq, seq));
 
 	xtstamp->sys_realtime = ktime_add_ns(base_real, nsec_real);
 	xtstamp->sys_monoraw = ktime_add_ns(base_raw, nsec_raw);
+
+	/*
+	 * Interpolate if necessary, working back from the start of the current
+	 * interval
+	 */
+	if (do_interp) {
+		cycle_t total_history_cycles;
+		ktime_t history_monoraw;
+		ktime_t history_realtime;
+		bool discontinuity;
+		cycle_t partial_history_cycles = cycles - raw_sys.cycles;
+
+		if (!history_ref || history_ref->cs_seq != cs_seq ||
+		    !cycle_between(history_ref->cycles, raw_sys.cycles,
+				   interval_start))
+			return -EINVAL;
+		history_monoraw = ktime_sub(xtstamp->sys_monoraw,
+					    history_ref->raw);
+		history_realtime = ktime_sub(xtstamp->sys_realtime,
+					     history_ref->real);
+		total_history_cycles = cycles - history_ref->cycles;
+		discontinuity =
+			history_ref->clock_set_seq != clock_was_set_seq;
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
