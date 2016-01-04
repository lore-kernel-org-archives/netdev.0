From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [RFC v5 1/6] Timekeeping cross timestamp interface for device drivers
Date: Mon,  4 Jan 2016 04:45:18 -0800
Message-ID: <1451911523-8534-2-git-send-email-christopher.s.hall@intel.com>
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

ACKNOWLEDGMENT: The original correlated clock source and cross
timestamp code was developed by Thomas Gleixner
<tglx@linutronix.de>. It has changed considerably and any mistakes are
mine.

The precision with which events on multiple networked systems can be
synchronized using, as an example, PTP (IEEE 1588, 802.1AS) is limited
by the precision of the cross timestamps between the system clock and
the device (timestamp) clock. Precision here is the degree of
simultaneity when capturing the cross timestamp.

Currently the PTP cross timestamp is captured in software using the
PTP device driver ioctl PTP_SYS_OFFSET. Reads of the device clock are
interleaved with reads of the realtime clock. At best, the precision
of this cross timestamp is on the order of several microseconds due to
software latencies. Sub-microsecond precision is required for
industrial control and some media applications. To achieve this level
of precision hardware supported cross timestamping is needed.

Hardware cross timestamps are derived from simultaneously capturing
the device clock and the system clock. Applications use timestamps in
nanoseconds rather than clock ticks. The device driver can scale
device clock ticks to device time in nanoseconds, but cannot transform
system clock ticks. Only the kernel timekeeping code can do this. The
function get_device_system_crosststamp() allows device drivers to
return a cross timestamp with system time properly scaled to
nanoseconds.

The cross timestamps contain the realtime and monotonic raw clock
times. The realtime value is needed to discipline that clock using PTP
and the monotonic raw value is used for applications that don't
require a "real" time, but need an unadjusted clock time.

The get_device_system_crosststamp() code calls back into the driver
to ensure that the system counter is within the current timekeeping
update interval. Because of possible NTP/PTP frequency adjustments,
extrapolating a realtime clock time outside the current interval with
a potentially different scaling factor can result in a small amount of
error.

Modern Intel hardware provides an Always Running Timer (ART) which is
exactly related to TSC through a known frequency ratio. The ART is
routed to devices on the system and is used to precisely and
simultaneously capture the device clock with the ART. The kernel
timekeeping code requires a system clock value from the current clock
source to calculate the system time. The correlated clocksource adds a
means to transform a clock (in this case ART) exactly to the system
clock (TSC clocksource) that is used to calculate system time.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 include/linux/clocksource.h | 27 ++++++++++++++++
 include/linux/timekeeping.h | 35 +++++++++++++++++++++
 kernel/time/timekeeping.c   | 77 ++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 135 insertions(+), 4 deletions(-)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 7784b59..4b7973d 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -255,4 +255,31 @@ static inline void clocksource_probe(void) {}
 #define CLOCKSOURCE_ACPI_DECLARE(name, table_id, fn)		\
 	ACPI_DECLARE_PROBE_ENTRY(clksrc, name, table_id, 0, NULL, 0, fn)
 
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
+	cycle_t			(*convert)(struct correlated_cs *cs,
+					   cycle_t cycles);
+};
+
+/*
+ * struct raw_system_counterval - system counter value captured in device
+ *	driver used to produce system/device cross-timestamp
+ * @system:	System counter value
+ * @cs:		Clocksource related to system counter value. This is used by
+ *		timekeeping code to verify validity of counter for system time
+ *		conversion
+ */
+struct raw_system_counterval {
+	cycle_t			cycles;
+	struct clocksource	*cs;
+};
+
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index ec89d84..2209943 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -266,6 +266,41 @@ extern void timekeeping_inject_sleeptime64(struct timespec64 *delta);
 extern void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw,
 				        struct timespec64 *ts_real);
 
+
+/*
+ * struct system_device_crosststamp - system/device cross-timestamp
+ *	(syncronized capture)
+ * @device:	Device time
+ * @realtime:	Realtime simultaneous with device time
+ * @monoraw:	Monotonic raw simultaneous with device time
+ */
+struct system_device_crosststamp {
+	ktime_t device;
+	ktime_t sys_realtime;
+	ktime_t sys_monoraw;
+};
+
+struct raw_system_counterval;
+/*
+ * struct get_sync_device_time - Provides method to capture device time
+ *	synchronized with raw system counter value
+ * @get_time:	Callback providing synchronized capture of device time
+ *		and system counter. Returns 0 on success, < 0 on failure
+ * @ctx:	Context provided to callback function
+ */
+struct get_sync_device_time {
+	int	(*get_time)(ktime_t *device,
+			    struct raw_system_counterval *system,
+			    void *ctx);
+	void	 *ctx;
+};
+
+/*
+ * Get cross timestamp between system clock and device clock
+ */
+extern int get_device_system_crosststamp(struct system_device_crosststamp *ct,
+					 struct get_sync_device_time *dt);
+
 /*
  * Persistent clock related interfaces
  */
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index d563c19..9c1ddc3 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -298,13 +298,11 @@ u32 (*arch_gettimeoffset)(void) = default_arch_gettimeoffset;
 static inline u32 arch_gettimeoffset(void) { return 0; }
 #endif
 
-static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
+static inline s64 timekeeping_delta_to_ns(struct tk_read_base *tkr,
+					  cycle_t delta)
 {
-	cycle_t delta;
 	s64 nsec;
 
-	delta = timekeeping_get_delta(tkr);
-
 	nsec = delta * tkr->mult + tkr->xtime_nsec;
 	nsec >>= tkr->shift;
 
@@ -312,6 +310,24 @@ static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
 	return nsec + arch_gettimeoffset();
 }
 
+static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
+{
+	cycle_t delta;
+
+	delta = timekeeping_get_delta(tkr);
+	return timekeeping_delta_to_ns(tkr, delta);
+}
+
+static inline s64 timekeeping_cycles_to_ns(struct tk_read_base *tkr,
+					    cycle_t cycles)
+{
+	cycle_t delta;
+
+	/* calculate the delta since the last update_wall_time */
+	delta = clocksource_delta(cycles, tkr->cycle_last, tkr->mask);
+	return timekeeping_delta_to_ns(tkr, delta);
+}
+
 /**
  * update_fast_timekeeper - Update the fast and NMI safe monotonic timekeeper.
  * @tkr: Timekeeping readout base from which we take the update
@@ -885,6 +901,59 @@ EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
 #endif /* CONFIG_NTP_PPS */
 
 /**
+ * get_device_system_crosststamp - Synchronously capture system/device timestamp
+ * @xtstamp:		Receives simultaneously captured system and device time
+ * @sync_devicetime:	Callback to get simultaneous device time and
+ *	system counter from the device driver
+ *
+ * Reads a timestamp from a device and correlates it to system time
+ */
+int get_device_system_crosststamp(struct system_device_crosststamp *xtstamp,
+				  struct get_sync_device_time *sync_devicetime)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	unsigned long seq;
+	struct raw_system_counterval raw_sys;
+	ktime_t base_raw;
+	ktime_t base_real;
+	s64 nsec_raw;
+	s64 nsec_real;
+	int ret;
+
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+		/*
+		 * Try to get a timestamp from the device driver.
+		 */
+		ret = sync_devicetime->get_time(&xtstamp->device, &raw_sys,
+						sync_devicetime->ctx);
+		if (ret)
+			return ret;
+
+		/*
+		 * Verify that the correlated clocksource is related to
+		 * the currently installed timekeeper clocksource
+		 */
+		if (tk->tkr_mono.clock != raw_sys.cs)
+			return -ENODEV;
+
+		base_real = ktime_add(tk->tkr_mono.base,
+				      tk_core.timekeeper.offs_real);
+		base_raw = tk->tkr_raw.base;
+
+		nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono,
+						     raw_sys.cycles);
+		nsec_raw = timekeeping_cycles_to_ns(&tk->tkr_raw,
+						    raw_sys.cycles);
+	} while (read_seqcount_retry(&tk_core.seq, seq));
+
+	xtstamp->sys_realtime = ktime_add_ns(base_real, nsec_real);
+	xtstamp->sys_monoraw = ktime_add_ns(base_raw, nsec_raw);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(get_device_system_crosststamp);
+
+/**
  * do_gettimeofday - Returns the time of day in a timeval
  * @tv:		pointer to the timeval to be set
  *
-- 
2.1.4
