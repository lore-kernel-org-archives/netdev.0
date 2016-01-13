From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v6 2/9] Add driver cross timestamp interface for higher precision time synchronization
Date: Wed, 13 Jan 2016 04:12:22 -0800
Message-ID: <1452687149-11281-3-git-send-email-christopher.s.hall@intel.com>
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
function get_device_system_crosstimestamp() allows device drivers to
return a cross timestamp with system time properly scaled to
nanoseconds.

The cross timestamps contain the realtime and monotonic raw clock
times. The realtime value is needed to discipline that clock using PTP
and the monotonic raw value is used for applications that don't
require a "real" time, but need an unadjusted clock time.

The get_device_system_crosstimestamp() code calls back into the driver
to ensure that the system counter is within the current timekeeping
update interval. Because of possible NTP/PTP frequency adjustments,
extrapolating a realtime clock time outside the current interval with
a potentially different scaling factor can result in a small amount of
error.

Modern Intel hardware provides an Always Running Timer (ART) which is
exactly related to TSC through a known frequency ratio. The ART is
routed to devices on the system and is used to precisely and
simultaneously capture the device clock with the ART.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 include/linux/clocksource.h | 12 ++++++++++
 include/linux/timekeeping.h | 35 ++++++++++++++++++++++++++++
 kernel/time/timekeeping.c   | 56 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 103 insertions(+)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 7784b59..4542293 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -255,4 +255,16 @@ static inline void clocksource_probe(void) {}
 #define CLOCKSOURCE_ACPI_DECLARE(name, table_id, fn)		\
 	ACPI_DECLARE_PROBE_ENTRY(clksrc, name, table_id, 0, NULL, 0, fn)
 
+/*
+ * struct system_counterval_t - system counter value with the pointer to the
+ *	corresponding clocksource
+ * @cycles:	System counter value
+ * @cs:		Clocksource corresponding to system counter value. Used by
+ *	timekeeping code to verify comparibility of two cycle values
+ */
+struct system_counterval_t {
+	cycle_t			cycles;
+	struct clocksource	*cs;
+};
+
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index ec89d84..2651e0a 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -266,6 +266,41 @@ extern void timekeeping_inject_sleeptime64(struct timespec64 *delta);
 extern void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw,
 				        struct timespec64 *ts_real);
 
+
+/*
+ * struct system_device_crosststamp - system/device cross-timestamp
+ *	(syncronized capture)
+ * @device:		Device time
+ * @sys_realtime:	Realtime simultaneous with device time
+ * @sys_monoraw:	Monotonic raw simultaneous with device time
+ */
+struct system_device_crosststamp {
+	ktime_t device;
+	ktime_t sys_realtime;
+	ktime_t sys_monoraw;
+};
+
+struct system_counterval_t;
+/*
+ * struct get_sync_device_time_cb - Provides method to capture device time
+ *	synchronized with raw system counter value
+ * @get_time:	Callback providing synchronized capture of device time
+ *		and system counter. Returns 0 on success, < 0 on failure
+ * @ctx:	Context provided to callback function
+ */
+struct sync_device_time_cb {
+	int	(*get_time)(ktime_t *device_time,
+			    struct system_counterval_t *system_counterval,
+			    void *ctx);
+	void	 *ctx;
+};
+
+/*
+ * Get cross timestamp between system clock and device clock
+ */
+extern int get_device_system_crosststamp(struct sync_device_time_cb *cb,
+					 struct system_device_crosststamp *ts);
+
 /*
  * Persistent clock related interfaces
  */
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 3f127dd..84534f8 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -901,6 +901,62 @@ EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
 #endif /* CONFIG_NTP_PPS */
 
 /**
+ * get_device_system_crosststamp - Synchronously capture system/device timestamp
+ * @sync_devicetime:	Callback to get simultaneous device time and
+ *	system counter from the device driver
+ * @xtstamp:		Receives simultaneously captured system and device time
+ *
+ * Reads a timestamp from a device and correlates it to system time
+ */
+int get_device_system_crosststamp(struct sync_device_time_cb *sync_devicetime,
+				  struct system_device_crosststamp *xtstamp)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	unsigned long seq;
+	struct system_counterval_t system_counterval;
+	ktime_t base_raw;
+	ktime_t base_real;
+	s64 nsec_raw;
+	s64 nsec_real;
+	int ret;
+
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+		/*
+		 * Try to synchronously capture device time and a system
+		 * counter value calling back into the device driver
+		 */
+		ret = sync_devicetime->get_time(&xtstamp->device,
+						&system_counterval,
+						sync_devicetime->ctx);
+		if (ret)
+			return ret;
+
+		/*
+		 * Verify that the clocksource associated with the captured
+		 * system counter value is the same as the currently installed
+		 * timekeeper clocksource
+		 */
+		if (tk->tkr_mono.clock != system_counterval.cs)
+			return -ENODEV;
+
+		base_real = ktime_add(tk->tkr_mono.base,
+				      tk_core.timekeeper.offs_real);
+		base_raw = tk->tkr_raw.base;
+
+		nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono,
+						     system_counterval.cycles);
+		nsec_raw = timekeeping_cycles_to_ns(&tk->tkr_raw,
+						    system_counterval.cycles);
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
