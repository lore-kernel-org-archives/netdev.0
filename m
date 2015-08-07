From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH v2 1/4] Add generic correlated clocksource code and ART to TSC conversion code
Date: Fri,  7 Aug 2015 16:01:32 -0700
Message-ID: <1438988495-9942-2-git-send-email-christopher.s.hall@intel.com>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Original patch description:

Subject: ptp: Get sync timestamps
From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 29 Jul 2015 10:52:06 +0200

The ART stuff wants to be splitted out.

======== Changes =======

Add struct correlated_cs (clocksource) with pointer to original clocksource
	and function pointer to convert correlated clocksource to the original

Add struct correlated_ts (timestamp) with function pointer to read correlated
	clocksource, device and system (in terms of correlated clocksource)
	counter values (input) with resulting converted real and monotonic raw
	system times (output)

Add get_correlated_timestamp() function which given specific correlated_cs
	and correlated_ts convert correlated counter value to system time

Add art_to_tsc conversion function translated Always Running Timer (ART) to
	TSC value
---
 arch/x86/kernel/tsc.c       | 31 ++++++++++++++++++++++
 include/linux/clocksource.h | 30 +++++++++++++++++++++
 include/linux/timekeeping.h |  4 +++
 kernel/time/timekeeping.c   | 63 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 128 insertions(+)

diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 7437b41..a90aa6a 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -1059,6 +1059,27 @@ int unsynchronized_tsc(void)
 	return 0;
 }
 
+static u32 tsc_numerator;
+static u32 tsc_denominator;
+/*
+ * CHECKME: Do we need the adjust value? It should be 0, but if we run
+ * in a VM this might be a different story.
+ */
+static u64 tsc_adjust;
+
+static u64 art_to_tsc(u64 cycles)
+{
+	u64 tmp, res = tsc_adjust;
+
+	res += (cycles / tsc_denominator) * tsc_numerator;
+	tmp = (cycles % tsc_denominator) * tsc_numerator;
+	res += tmp / tsc_denominator;
+	return res;
+}
+
+struct correlated_cs art_timestamper = {
+	.convert	= art_to_tsc,
+};
 
 static void tsc_refine_calibration_work(struct work_struct *work);
 static DECLARE_DELAYED_WORK(tsc_irqwork, tsc_refine_calibration_work);
@@ -1129,6 +1150,16 @@ static void tsc_refine_calibration_work(struct work_struct *work)
 		(unsigned long)tsc_khz / 1000,
 		(unsigned long)tsc_khz % 1000);
 
+	/*
+	 * TODO:
+	 *
+	 * If the system has ART, initialize the art_to_tsc conversion
+	 * and set: art_timestamp.related_cs = &tsc_clocksource.
+	 *
+	 * Before that point a call to get_correlated_timestamp will
+	 * fail the clocksource match check.
+	 */
+
 out:
 	clocksource_register_khz(&clocksource_tsc, tsc_khz);
 }
diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 278dd27..2ed3d0c 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -258,4 +258,34 @@ void acpi_generic_timer_init(void);
 static inline void acpi_generic_timer_init(void) { }
 #endif
 
+/**
+ * struct correlated_cs - Descriptor for a clocksource correlated to another clocksource
+ * @related_cs:		Pointer to the related timekeeping clocksource
+ * @convert:		Conversion function to convert a timestamp from
+ *			the correlated clocksource to cycles of the related
+ *			timekeeping clocksource
+ */
+struct correlated_cs {
+	struct clocksource	*related_cs;
+	u64			(*convert)(u64 cycles);
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
+	u64			system_real;
+	u64			system_raw;
+};
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 6e191e4..a9e1a2d 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -258,6 +258,10 @@ extern void timekeeping_inject_sleeptime64(struct timespec64 *delta);
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
index bca3667..769a04b 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -312,6 +312,19 @@ static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
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
@@ -885,6 +898,56 @@ EXPORT_SYMBOL(getnstime_raw_and_real);
 #endif /* CONFIG_NTP_PPS */
 
 /**
+ * get_correlated_timestamp - Get a correlated timestamp
+ *
+ * Reads a timestamp from a device and correlates it to system time
+ */
+int get_correlated_timestamp(struct correlated_ts *crt,
+			     struct correlated_cs *crs)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	unsigned long seq;
+	cycles_t cycles;
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
+		 * Try to get a timestamp from the device.
+		 */
+		ret = crt->get_ts(crt);
+		if (ret)
+			return ret;
+
+		/*
+		 * Convert the timestamp to timekeeper clock cycles
+		 */
+		cycles = crs->convert(crs, crt->system_ts);
+
+		/* Convert to clock realtime */
+		base = ktime_add(tk->tkr_mono.base, tk_core.timekeeper.offs_real);
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
+
+/**
  * do_gettimeofday - Returns the time of day in a timeval
  * @tv:		pointer to the timeval to be set
  *
-- 
1.9.1
