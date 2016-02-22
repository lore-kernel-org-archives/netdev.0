From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v8 2/8] time: Add timekeeping snapshot code capturing system time and counter
Date: Mon, 22 Feb 2016 03:15:20 -0800
Message-ID: <1456139726-3327-3-git-send-email-christopher.s.hall@intel.com>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com>
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the current timekeeping code there isn't any interface to
atomically capture the current relationship between the system counter
and system time. ktime_get_snapshot() returns this triple (counter,
monotonic raw, realtime) in the system_time_snapshot struct.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
[jstultz: Moved structure definitions around to clean things up]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/timekeeping.h | 18 ++++++++++++++++++
 kernel/time/timekeeping.c   | 30 ++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index ec89d84..af220e1 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -267,6 +267,24 @@ extern void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw,
 				        struct timespec64 *ts_real);
 
 /*
+ * struct system_time_snapshot - simultaneous raw/real time capture with
+ *	counter value
+ * @cycles:	Clocksource counter value to produce the system times
+ * @real:	Realtime system time
+ * @raw:	Monotonic raw system time
+ */
+struct system_time_snapshot {
+	cycles_t	cycles;
+	ktime_t		real;
+	ktime_t		raw;
+};
+
+/*
+ * Simultaneously snapshot realtime and monotonic raw clocks
+ */
+extern void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot);
+
+/*
  * Persistent clock related interfaces
  */
 extern int persistent_clock_is_local;
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 4243d28..89b4695 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -874,6 +874,36 @@ time64_t __ktime_get_real_seconds(void)
 	return tk->xtime_sec;
 }
 
+/**
+ * ktime_get_snapshot - snapshots the realtime/monotonic raw clocks with counter
+ * @systime_snapshot:	pointer to struct receiving the system time snapshot
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
 
 #ifdef CONFIG_NTP_PPS
 
-- 
2.1.4
