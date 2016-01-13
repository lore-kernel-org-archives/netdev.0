From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v6 1/9] Add cycles to nanoseconds translation
Date: Wed, 13 Jan 2016 04:12:21 -0800
Message-ID: <1452687149-11281-2-git-send-email-christopher.s.hall@intel.com>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16629 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970AbcAMTSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 14:18:40 -0500
In-Reply-To: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timekeeping code does not currently provide a way to translate
externally provided clocksource cycles to system time. The cycle count
is always provided by the result clocksource read() method internal to
the timekeeping code. The added function timekeeping_cycles_to_ns()
calculated a nanosecond value from a cycle count that can be added to
tk_read_base.base value yielding the current system time. This allows
clocksource cycle values external to the timekeeping code to provide a
cycle count that can be transformed to system time.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 kernel/time/timekeeping.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index d563c19..3f127dd 100644
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
-- 
2.1.4
