From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v3 1/4] Add correlated clocksource deriving system time from an auxiliary clocksource
Date: Fri, 21 Aug 2015 11:52:05 -0700
Message-ID: <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
Cc: richardcochran@gmail.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, peterz@infradead.org,
	"Christopher S. Hall" <christopher.s.hall@intel.com>
To: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add struct correlated_cs with pointer to original clocksource and
	function pointer to convert correlated clocksource to the original

Add get_correlated_timestamp() function which given specific correlated_cs
	and correlated_ts convert correlated counter value to system time

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 include/linux/clocksource.h | 33 +++++++++++++++++++++++
 include/linux/timekeeping.h |  4 +++
 kernel/time/timekeeping.c   | 65 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 102 insertions(+)

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
index bca3667..90a7c6f 100644
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
@@ -885,6 +898,58 @@ EXPORT_SYMBOL(getnstime_raw_and_real);
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
+EXPORT_SYMBOL(get_correlated_timestamp);
+
+/**
  * do_gettimeofday - Returns the time of day in a timeval
  * @tv:		pointer to the timeval to be set
  *
-- 
2.1.4
