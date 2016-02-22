From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v8 1/8] time: Add cycles to nanoseconds translation
Date: Mon, 22 Feb 2016 03:15:19 -0800
Message-ID: <1456139726-3327-2-git-send-email-christopher.s.hall@intel.com>
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

The timekeeping code does not currently provide a way to translate
externally provided clocksource cycles to system time. The cycle count
is always provided by the result clocksource read() method internal to
the timekeeping code. The added function timekeeping_cycles_to_ns()
calculated a nanosecond value from a cycle count that can be added to
tk_read_base.base value yielding the current system time. This allows
clocksource cycle values external to the timekeeping code to provide a
cycle count that can be transformed to system time.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 kernel/time/timekeeping.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 34b4ced..4243d28 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -298,17 +298,34 @@ u32 (*arch_gettimeoffset)(void) = default_arch_gettimeoffset;
 static inline u32 arch_gettimeoffset(void) { return 0; }
 #endif
 
+static inline s64 timekeeping_delta_to_ns(struct tk_read_base *tkr,
+					  cycle_t delta)
+{
+	s64 nsec;
+
+	nsec = delta * tkr->mult + tkr->xtime_nsec;
+	nsec >>= tkr->shift;
+
+	/* If arch requires, add in get_arch_timeoffset() */
+	return nsec + arch_gettimeoffset();
+}
+
 static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
 {
 	cycle_t delta;
-	s64 nsec;
 
 	delta = timekeeping_get_delta(tkr);
+	return timekeeping_delta_to_ns(tkr, delta);
+}
 
-	nsec = (delta * tkr->mult + tkr->xtime_nsec) >> tkr->shift;
+static inline s64 timekeeping_cycles_to_ns(struct tk_read_base *tkr,
+					    cycle_t cycles)
+{
+	cycle_t delta;
 
-	/* If arch requires, add in get_arch_timeoffset() */
-	return nsec + arch_gettimeoffset();
+	/* calculate the delta since the last update_wall_time */
+	delta = clocksource_delta(cycles, tkr->cycle_last, tkr->mask);
+	return timekeeping_delta_to_ns(tkr, delta);
 }
 
 /**
-- 
2.1.4
