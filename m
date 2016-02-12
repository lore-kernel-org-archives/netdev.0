From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v7 4/8] time: Add driver cross timestamp interface for higher precision time synchronization
Date: Fri, 12 Feb 2016 12:25:25 -0800
Message-ID: <1455308729-6280-5-git-send-email-christopher.s.hall@intel.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACKNOWLEDGMENT: cross timestamp code was developed by Thomas Gleixner
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

The function get_device_system_crosstimestamp() allows device drivers
to return a cross timestamp with system time properly scaled to
nanoseconds.  The realtime value is needed to discipline that clock
using PTP and the monotonic raw value is used for applications that
don't require a "real" time, but need an unadjusted clock time.  The
get_device_system_crosstimestamp() code calls back into the driver to
ensure that the system counter is within the current timekeeping
update interval.

Modern Intel hardware provides an Always Running Timer (ART) which is
exactly related to TSC through a known frequency ratio. The ART is
routed to devices on the system and is used to precisely and
simultaneously capture the device clock with the ART.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
[jstultz: Reworked to remove extra structures and simplify calling]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/timekeeping.h | 35 +++++++++++++++++++++++++++
 kernel/time/timekeeping.c   | 58 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 93 insertions(+)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index af220e1..75bb836 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -280,6 +280,41 @@ struct system_time_snapshot {
 };
 
 /*
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
+/*
+ * Get cross timestamp between system clock and device clock
+ */
+extern int get_device_system_crosststamp(
+			int (*get_time_fn)(ktime_t *device_time,
+				struct system_counterval_t *system_counterval,
+				void *ctx),
+			void *ctx,
+			struct system_device_crosststamp *xtstamp);
+
+/*
  * Simultaneously snapshot realtime and monotonic raw clocks
  */
 extern void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot);
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index f1a1c97..8c53398 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -908,6 +908,64 @@ void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
 EXPORT_SYMBOL_GPL(ktime_get_snapshot);
 
 /**
+ * get_device_system_crosststamp - Synchronously capture system/device timestamp
+ * @sync_devicetime:	Callback to get simultaneous device time and
+ *	system counter from the device driver
+ * @xtstamp:		Receives simultaneously captured system and device time
+ *
+ * Reads a timestamp from a device and correlates it to system time
+ */
+int get_device_system_crosststamp(int (*get_time_fn)
+				  (ktime_t *device_time,
+				   struct system_counterval_t *sys_counterval,
+				   void *ctx),
+				  void *ctx,
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
+		ret = get_time_fn(&xtstamp->device, &system_counterval, ctx);
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
