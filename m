From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 09/13] clocksource: allow usage independent of
	timekeeping.c
Date: Tue, 4 Nov 2008 10:23:42 +0100
Message-ID: <1226415438.31699.8.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62793 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756179AbYKKO5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:57:20 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far struct clocksource acted as the interface between time/timekeeping
and hardware. This patch generalizes the concept so that the same
interface can also be used in other contexts.

The only change as far as kernel/time/timekeeping is concerned is that
the hardware access can be done either with or without passing
the clocksource pointer as context. This is necessary in those
cases when there is more than one instance of the hardware.

The extensions in this patch add code which turns the raw cycle count
provided by hardware into a continously increasing time value. This
reuses fields also used by timekeeping.c. Because of slightly different
semantic (__get_nsec_offset does not update cycle_last, clocksource_read_ns
does that transparently) timekeeping.c was not modified to use the
generalized code.

The new code does no locking of the clocksource. This is the responsibility
of the caller.

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 include/linux/clocksource.h |  119 ++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 118 insertions(+), 1 deletions(-)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 55e434f..da4c7cd 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -24,6 +24,9 @@ struct clocksource;
 /**
  * struct clocksource - hardware abstraction for a free running counter
  *	Provides mostly state-free accessors to the underlying hardware.
+ *      Also provides utility functions which convert the underlying
+ *      hardware cycle values into a non-decreasing count of nanoseconds
+ *      ("time").
  *
  * @name:		ptr to clocksource name
  * @list:		list head for registration
@@ -43,6 +46,9 @@ struct clocksource;
  *				The ideal clocksource. A must-use where
  *				available.
  * @read:		returns a cycle value
+ * @read_clock:         alternative to read which gets a pointer to the clock
+ *                      source so that the same code can read different clocks;
+ *                      either read or read_clock must be set
  * @mask:		bitmask for two's complement
  *			subtraction of non 64 bit counters
  * @mult:		cycle to nanosecond multiplier
@@ -61,6 +67,7 @@ struct clocksource {
 	struct list_head list;
 	int rating;
 	cycle_t (*read)(void);
+	cycle_t (*read_clock)(struct clocksource *cs);
 	cycle_t mask;
 	u32 mult;
 	u32 shift;
@@ -166,7 +173,7 @@ static inline u32 clocksource_hz2mult(u32 hz, u32 shift_constant)
  */
 static inline cycle_t clocksource_read(struct clocksource *cs)
 {
-	return cs->read();
+	return (cs->read ? cs->read() : cs->read_clock(cs));
 }
 
 /**
@@ -186,6 +193,116 @@ static inline s64 cyc2ns(struct clocksource *cs, cycle_t cycles)
 }
 
 /**
+ * clocksource_read_ns - get nanoseconds since last call of this function
+ *                       (never negative)
+ * @cs:         Pointer to clocksource
+ *
+ * When the underlying cycle counter runs over, this will be handled
+ * correctly as long as it does not run over more than once between
+ * calls.
+ *
+ * The first call to this function for a new clock source initializes
+ * the time tracking and returns bogus results.
+ */
+static inline s64 clocksource_read_ns(struct clocksource *cs)
+{
+	cycle_t cycle_now, cycle_delta;
+	s64 ns_offset;
+
+	/* read clocksource: */
+	cycle_now = clocksource_read(cs);
+
+	/* calculate the delta since the last clocksource_read_ns: */
+	cycle_delta = (cycle_now - cs->cycle_last) & cs->mask;
+
+	/* convert to nanoseconds: */
+	ns_offset = cyc2ns(cs, cycle_delta);
+
+	/* update time stamp of clocksource_read_ns call: */
+	cs->cycle_last = cycle_now;
+
+	return ns_offset;
+}
+
+/**
+ * clocksource_init_time - initialize a clock source for use with
+ *                         %clocksource_read_time() and
+ *                         %clocksource_cyc2time()
+ * @cs:            Pointer to clocksource.
+ * @start_tstamp:  Arbitrary initial time stamp.
+ *
+ * After this call the current cycle register (roughly) corresponds to
+ * the initial time stamp. Every call to %clocksource_read_time()
+ * increments the time stamp counter by the number of elapsed
+ * nanoseconds.
+ */
+static inline void clocksource_init_time(struct clocksource *cs,
+					u64 start_tstamp)
+{
+	cs->cycle_last = clocksource_read(cs);
+	cs->xtime_nsec = start_tstamp;
+}
+
+/**
+ * clocksource_read_time - return nanoseconds since %clocksource_init_time()
+ *                         plus the initial time stamp
+ * @cs:          Pointer to clocksource.
+ *
+ * In other words, keeps track of time since the same epoch as
+ * the function which generated the initial time stamp. Don't mix
+ * with calls to %clocksource_read_ns()!
+ */
+static inline u64 clocksource_read_time(struct clocksource *cs)
+{
+	u64 nsec;
+
+	/* increment time by nanoseconds since last call */
+	nsec = clocksource_read_ns(cs);
+	nsec += cs->xtime_nsec;
+	cs->xtime_nsec = nsec;
+
+	return nsec;
+}
+
+/**
+ * clocksource_cyc2time - convert an absolute cycle time stamp to same
+ *                        time base as values returned by
+ *                        %clocksource_read_time()
+ * @cs:            Pointer to clocksource.
+ * @cycle_tstamp:  a value returned by cs->read()
+ *
+ * Cycle time stamps that are converted correctly as long as they
+ * fall into the time interval [-1/2 max cycle count, 1/2 cycle count],
+ * with "max cycle count" == cs->mask+1.
+ *
+ * This avoids situations where a cycle time stamp is generated, the
+ * current cycle counter is updated, and then when transforming the
+ * time stamp the value is treated as if it was in the future. Always
+ * updating the cycle counter would also work, but incurr additional
+ * overhead.
+ */
+static inline u64 clocksource_cyc2time(struct clocksource *cs,
+				cycle_t cycle_tstamp)
+{
+	u64 cycle_delta = (cycle_tstamp - cs->cycle_last) & cs->mask;
+	u64 nsec;
+
+	/*
+	 * Instead of always treating cycle_tstamp as more recent
+	 * than cs->cycle_last, detect when it is too far in the
+	 * future and treat it as old time stamp instead.
+	 */
+	if (cycle_delta > cs->mask / 2) {
+		cycle_delta = (cs->cycle_last - cycle_tstamp) & cs->mask;
+		nsec = cs->xtime_nsec - cyc2ns(cs, cycle_delta);
+	} else {
+		nsec = cyc2ns(cs, cycle_delta) + cs->xtime_nsec;
+	}
+
+	return nsec;
+}
+
+/**
  * clocksource_calculate_interval - Calculates a clocksource interval struct
  *
  * @c:		Pointer to clocksource.
-- 
1.6.0.4


