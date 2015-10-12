From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Mon, 12 Oct 2015 11:45:19 -0700
Message-ID: <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
Cc: x86@kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.b.stanton@intel.com,
	"Christopher S. Hall" <christopher.s.hall@intel.com>
To: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

Modern Intel hardware provides the so called Always Running Timer
(ART). The TSC which is usually used for timekeeping is derived from
ART and runs with a fixed frequency ratio to it. ART is routed to
devices and allows to take atomic timestamp samples from the device
clock and the ART. One use case is PTP timestamps on network cards. We
want to utilize this feature as it allows us to better correlate the
PTP timestamp to the system time.

In order to gather precise timestamps we need to make sure that the
conversion from ART to TSC and the following conversion from TSC to
clock realtime happens synchronized with the ongoing timekeeping
updates. Otherwise we might convert an ART timestamp from point A in
time with the conversion factors of point B in time. These conversion
factors can differ due to NTP/PTP frequency adjustments and therefor
the resulting clock realtime timestamp would be slightly off, which is
contrary to the whole purpose of synchronized hardware timestamps.

Provide data structures which describe the correlation between two
clocksources and a function to gather correlated and convert
timestamps from a device. The function is as any other timekeeping
function protected against current timekeeper updates via the
timekeeper sequence lock. It calls the device function to gather the
hardware timestamps and converts them to clock real time and clock
monotonic raw.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Another representative use case of time sync and the correlated
clocksource (in addition to PTP noted above) is PTP synchronized
audio.

In a streaming application, as an example, samples will be sent
and/or received by multiple devices with a presentation time that is
in terms of the PTP master clock. Synchronizing the audio output on
these devices requires correlating the audio clock with the PTP
master clock. The more precise this correlation is, the better the
audio quality (i.e. out of sync audio sounds bad).

>From an application standpoint, to correlate the PTP master clock
with the audio device clock, the system clock is used as a
intermediate timebase. The transforms such an application would
perform are:

System Clock <-> Audio clock
System Clock <-> Network Device Clock [<-> PTP Master Clock]

Such audio applications make use of some existing ALSA library
calls that provide audio/system cross-timestamps (e.g.
snd_pcm_status_get_htstamp()). Previous driver implementations
capture these cross by reading the system clock (raw/mono/real)
and the device clock atomically in software.

Modern Intel platforms can perform a more accurate cross-
timestamp in hardware (ART,audio device clock).  The audio driver
requires ART->system time transforms -- the same as required for
the network driver. These platforms offload audio processing
(including cross-timestamps) to a DSP which to ensure
uninterrupted audio processing, communicates and response to the
host only once every millsecond. As a result is takes up to a
millisecond for the DSP to receive a request, the request is
processed by the DSP, the audio output hardware is polled for
completion, the result is copied into shared memory, and the
host is notified. All of these operation occur on a millisecond
cadence.  This transaction requires about 2 ms, but under
heavier workloads it may take up to 4 ms.

If update_wall_time() is called while waiting for a
response within get_correlated_ts() (from original patch), a retry
is attempted. This will occur if the cycle_interval(determined by
CONFIG_HZ and mult/shift values) cycles elapse.

The modification to the original patch accomodates these
slow devices by adding the option of providing an ART value outside
of the retry loop and adding a history which can consulted in the
case of an out of date counter value. The history is kept by
making the shadow_timekeeper an array. Each write to the
timekeeper rotates through the array, preserving a
history of updates.

With these changes, if get_correlated_timestamp() detects a counter
value previous to cycle_now, it consults the history in
shadow_timekeeper and translates the timestamp to the system time
value. If the timestamp value is too old, an error is returned

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 include/linux/clocksource.h |  33 +++++++
 include/linux/timekeeping.h |   4 +
 kernel/time/timekeeping.c   | 203 ++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 235 insertions(+), 5 deletions(-)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 278dd27..4bedadb 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -258,4 +258,37 @@ void acpi_generic_timer_init(void);
 static inline void acpi_generic_timer_init(void) { }
 #endif
 
+/*
+ * struct correlated_cs - Descriptor for a clocksource correlated to another
+ *	clocksource
+ * @related_cs:		Pointer to the related timekeeping clocksource
+ * @convert:		Conversion function to convert a timestamp from
+ *			the correlated clocksource to cycles of the related
+ *			timekeeping clocksource
+ */
+struct correlated_cs {
+	struct clocksource	*related_cs;
+	u64			(*convert)(struct correlated_cs *cs,
+					   u64 cycles);
+};
+
+struct correlated_ts;
+
+/**
+ * struct correlated_ts - Descriptor for taking a correlated time stamp
+ * @get_ts:		Function to read out a synced system and device
+ *			timestamp
+ * @system_ts:		The raw system clock timestamp
+ * @device_ts:		The raw device timestamp
+ * @system_real:	@system_ts converted to CLOCK_REALTIME
+ * @system_raw:		@system_ts converted to CLOCK_MONOTONIC_RAW
+ */
+struct correlated_ts {
+	int			(*get_ts)(struct correlated_ts *ts);
+	u64			system_ts;
+	u64			device_ts;
+	ktime_t			system_real;
+	ktime_t			system_raw;
+	void			*private;
+};
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index ba0ae09..79c46d4 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -265,6 +265,10 @@ extern void timekeeping_inject_sleeptime64(struct timespec64 *delta);
  */
 extern void getnstime_raw_and_real(struct timespec *ts_raw,
 				   struct timespec *ts_real);
+struct correlated_ts;
+struct correlated_cs;
+extern int get_correlated_timestamp(struct correlated_ts *crt,
+				    struct correlated_cs *crs);
 
 /*
  * Persistent clock related interfaces
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 3739ac6..1a0860c 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -41,8 +41,13 @@ static struct {
 	struct timekeeper	timekeeper;
 } tk_core ____cacheline_aligned;
 
+/* This needs to be 3 or greater for backtracking to be useful */
+#define SHADOW_HISTORY_DEPTH 7
+
 static DEFINE_RAW_SPINLOCK(timekeeper_lock);
-static struct timekeeper shadow_timekeeper;
+static struct timekeeper shadow_timekeeper[SHADOW_HISTORY_DEPTH];
+static int shadow_index = -1; /* incremented to zero in timekeeping_init() */
+static bool shadow_timekeeper_full;
 
 /**
  * struct tk_fast - NMI safe timekeeper
@@ -312,6 +317,19 @@ static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
 	return nsec + arch_gettimeoffset();
 }
 
+static inline s64 timekeeping_convert_to_ns(struct tk_read_base *tkr,
+					    cycle_t cycles)
+{
+	cycle_t delta;
+	s64 nsec;
+
+	/* calculate the delta since the last update_wall_time */
+	delta = clocksource_delta(cycles, tkr->cycle_last, tkr->mask);
+
+	nsec = delta * tkr->mult + tkr->xtime_nsec;
+	return nsec >> tkr->shift;
+}
+
 /**
  * update_fast_timekeeper - Update the fast and NMI safe monotonic timekeeper.
  * @tkr: Timekeeping readout base from which we take the update
@@ -558,6 +576,21 @@ static inline void tk_update_ktime_data(struct timekeeper *tk)
 	tk->ktime_sec = seconds;
 }
 
+/*
+ * Modifies shadow index argument to point to the next array element
+ * Returns bool indicating shadow array fullness after the update
+ */
+static bool get_next_shadow_index(int *shadow_index_out)
+{
+	*shadow_index_out = (shadow_index + 1) % SHADOW_HISTORY_DEPTH;
+	/*
+	 * If shadow timekeeper is full it stays full, otherwise compute
+	 * the next value based on whether the index rolls over
+	 */
+	return shadow_timekeeper_full ?
+		true : *shadow_index_out < shadow_index;
+}
+
 /* must hold timekeeper_lock */
 static void timekeeping_update(struct timekeeper *tk, unsigned int action)
 {
@@ -582,9 +615,15 @@ static void timekeeping_update(struct timekeeper *tk, unsigned int action)
 	 * to happen last here to ensure we don't over-write the
 	 * timekeeper structure on the next update with stale data
 	 */
-	if (action & TK_MIRROR)
-		memcpy(&shadow_timekeeper, &tk_core.timekeeper,
-		       sizeof(tk_core.timekeeper));
+	if (action & TK_MIRROR) {
+		int next_shadow_index;
+		bool next_shadow_full =
+			get_next_shadow_index(&next_shadow_index);
+		memcpy(shadow_timekeeper+next_shadow_index,
+		       &tk_core.timekeeper, sizeof(tk_core.timekeeper));
+		shadow_index = next_shadow_index;
+		shadow_timekeeper_full = next_shadow_full;
+	}
 }
 
 /**
@@ -884,6 +923,142 @@ EXPORT_SYMBOL(getnstime_raw_and_real);
 
 #endif /* CONFIG_NTP_PPS */
 
+/*
+ * Iterator-like function which can be called multiple times to return the
+ * previous shadow_index
+ * Returns false when finding previous is not possible because:
+ * - The array is not full
+ * - The previous shadow_index refers to an entry that may be in-flight
+ */
+static bool get_prev_shadow_index(int *shadow_index_io)
+{
+	int guard_index;
+	int ret = (*shadow_index_io - 1) % SHADOW_HISTORY_DEPTH;
+
+	ret += ret < 0 ? SHADOW_HISTORY_DEPTH : 0;
+	/*
+	 * guard_index references the next shadow entry, assume that this
+	 * isn't valid since its not protected by sequence lock
+	 */
+	get_next_shadow_index(&guard_index);
+	/* if the array isn't full and index references top (invalid) entry */
+	if (!shadow_timekeeper_full && ret > *shadow_index_io)
+		return false;
+	/* the next entry may be in-flight and may be invalid  */
+	if (ret == guard_index)
+		return false;
+	/* Also make sure that entry is valid based on current shadow_index */
+	*shadow_index_io = ret;
+	return true;
+}
+
+/*
+ * cycle_between - true if test occurs chronologically between before and after
+ */
+
+static bool cycle_between(cycles_t after, cycles_t test, cycles_t before)
+{
+	if (test < before && before > after)
+		return true;
+	if (test > before && test < after)
+		return true;
+	return false;
+}
+
+/**
+ * get_correlated_timestamp - Get a correlated timestamp
+ * @crs: conversion between correlated clock and system clock
+ * @crt: callback to get simultaneous device and correlated clock value *or*
+ *	contains a valid correlated clock value and NULL callback
+ *
+ * Reads a timestamp from a device and correlates it to system time.  This
+ * function can be used in two ways.  If a non-NULL get_ts function pointer is
+ * supplied in @crt, this function is called within the retry loop to
+ * read the current correlated clock value and associated device time.
+ * Otherwise (get_ts is NULL) a correlated clock value is supplied and
+ * the history in shadow_timekeeper is consulted if necessary.
+ */
+int get_correlated_timestamp(struct correlated_ts *crt,
+			     struct correlated_cs *crs)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	unsigned long seq;
+	cycles_t cycles, cycles_now, cycles_last;
+	ktime_t base;
+	s64 nsecs;
+	int ret;
+
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+		/*
+		 * Verify that the correlated clocksoure is related to
+		 * the currently installed timekeeper clocksoure
+		 */
+		if (tk->tkr_mono.clock != crs->related_cs)
+			return -ENODEV;
+
+		/*
+		 * Get a timestamp from the device if get_ts is non-NULL
+		 */
+		if( crt->get_ts ) {
+			ret = crt->get_ts(crt);
+			if (ret)
+				return ret;
+		}
+
+		/*
+		 * Convert the timestamp to timekeeper clock cycles
+		 */
+		cycles = crs->convert(crs, crt->system_ts);
+
+		/*
+		 * If we have get_ts is valid, we know the cycles value
+		 * value is up to date and we can just do the conversion
+		 */
+		if( crt->get_ts )
+			goto do_convert;
+
+		/*
+		 * Since the cycles value is supplied outside of the loop,
+		 * there is no guarantee that it represents a time *after*
+		 * cycle_last do some checks to figure out whether it's
+		 * represents the past or the future taking rollover
+		 * into account. If the value is in the past, try to backtrack
+		 */
+		cycles_now = tk->tkr_mono.read(tk->tkr_mono.clock);
+		cycles_last = tk->tkr_mono.cycle_last;
+		if ((cycles >= cycles_last && cycles_now < cycles) ||
+		    (cycles < cycles_last && cycles_now >= cycles_last)) {
+			/* cycles is in the past try to backtrack */
+			int backtrack_index = shadow_index;
+
+			while (get_prev_shadow_index(&backtrack_index)) {
+				tk = shadow_timekeeper+backtrack_index;
+				if (cycle_between(cycles_last, cycles,
+						  tk->tkr_mono.cycle_last))
+					goto do_convert;
+				cycles_last = tk->tkr_mono.cycle_last;
+			}
+			return -EAGAIN;
+		}
+
+do_convert:
+		/* Convert to clock realtime */
+		base = ktime_add(tk->tkr_mono.base,
+				 tk_core.timekeeper.offs_real);
+		nsecs = timekeeping_convert_to_ns(&tk->tkr_mono, cycles);
+		crt->system_real = ktime_add_ns(base, nsecs);
+
+		/* Convert to clock raw monotonic */
+		base = tk->tkr_raw.base;
+		nsecs = timekeeping_convert_to_ns(&tk->tkr_raw, cycles);
+		crt->system_raw = ktime_add_ns(base, nsecs);
+
+	} while (read_seqcount_retry(&tk_core.seq, seq));
+	return 0;
+}
+EXPORT_SYMBOL_GPL(get_correlated_timestamp);
+
 /**
  * do_gettimeofday - Returns the time of day in a timeval
  * @tv:		pointer to the timeval to be set
@@ -1763,7 +1938,9 @@ static cycle_t logarithmic_accumulation(struct timekeeper *tk, cycle_t offset,
 void update_wall_time(void)
 {
 	struct timekeeper *real_tk = &tk_core.timekeeper;
-	struct timekeeper *tk = &shadow_timekeeper;
+	struct timekeeper *tk;
+	int next_shadow_index;
+	bool next_shadow_full;
 	cycle_t offset;
 	int shift = 0, maxshift;
 	unsigned int clock_set = 0;
@@ -1775,6 +1952,9 @@ void update_wall_time(void)
 	if (unlikely(timekeeping_suspended))
 		goto out;
 
+	/* Make sure we're inside the lock */
+	tk = shadow_timekeeper+shadow_index;
+
 #ifdef CONFIG_ARCH_USES_GETTIMEOFFSET
 	offset = real_tk->cycle_interval;
 #else
@@ -1786,6 +1966,13 @@ void update_wall_time(void)
 	if (offset < real_tk->cycle_interval)
 		goto out;
 
+	/* Copy the current shadow timekeeper to the 'next' and point to it */
+	next_shadow_index = shadow_index;
+	next_shadow_full = get_next_shadow_index(&next_shadow_index);
+	memcpy(shadow_timekeeper+next_shadow_index,
+	       shadow_timekeeper+shadow_index, sizeof(*shadow_timekeeper));
+	tk = shadow_timekeeper+next_shadow_index;
+
 	/* Do some additional sanity checking */
 	timekeeping_check_update(real_tk, offset);
 
@@ -1834,8 +2021,14 @@ void update_wall_time(void)
 	 * spinlocked/seqcount protected sections. And we trade this
 	 * memcpy under the tk_core.seq against one before we start
 	 * updating.
+	 *
+	 * Update the shadow index inside here forcing any backtracking
+	 * operations inside get_correlated_timestamp() to restart with
+	 * valid values
 	 */
 	timekeeping_update(tk, clock_set);
+	shadow_index = next_shadow_index;
+	shadow_timekeeper_full = next_shadow_full;
 	memcpy(real_tk, tk, sizeof(*tk));
 	/* The memcpy must come last. Do not put anything here! */
 	write_seqcount_end(&tk_core.seq);
-- 
2.1.4
