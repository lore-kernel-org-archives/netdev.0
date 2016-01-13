From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v6 5/9] Add timekeeping snapshot code capturing system time and counter
Date: Wed, 13 Jan 2016 04:12:25 -0800
Message-ID: <1452687149-11281-6-git-send-email-christopher.s.hall@intel.com>
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

In the current timekeeping code there isn't any interface to
atomically capture the current relationship between the system counter
and system time. ktime_get_snapshot() returns this triple (counter,
monotonic raw, realtime) in the system_time_snapshot struct.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 include/linux/clocksource.h | 13 +++++++++++++
 include/linux/timekeeping.h |  6 ++++++
 kernel/time/timekeeping.c   | 31 +++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 726ca68..cccbd1c 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -281,4 +281,17 @@ struct correlated_cs {
 					   cycle_t cycles);
 };
 
+/*
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
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 2651e0a..f5fe657 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -301,6 +301,12 @@ struct sync_device_time_cb {
 extern int get_device_system_crosststamp(struct sync_device_time_cb *cb,
 					 struct system_device_crosststamp *ts);
 
+struct system_time_snapshot;
+/*
+ * Simultaneously snapshot realtime and monotonic raw clocks
+ */
+extern void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot);
+
 /*
  * Persistent clock related interfaces
  */
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 84534f8..26049df 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -862,6 +862,37 @@ time64_t ktime_get_real_seconds(void)
 }
 EXPORT_SYMBOL_GPL(ktime_get_real_seconds);
 
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
+
 #ifdef CONFIG_NTP_PPS
 
 /**
-- 
2.1.4
