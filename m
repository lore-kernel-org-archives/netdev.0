From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of timekeeping.c
Date: Thu, 12 Feb 2009 16:03:34 +0100
Message-ID: <1234451023-6505-1-git-send-email-patrick.ohly@intel.com>
References: <1234450981.5914.11.camel@ecld0pohly>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Stultz <johnstul@us.ibm.com>,
	John Ronciak <john.ronciak@intel.com>,
	Patrick Ohly <patrick.ohly@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15848 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760704AbZBLPDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 10:03:48 -0500
In-Reply-To: <1234450981.5914.11.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far struct clocksource acted as the interface between time/timekeeping.c
and hardware. This patch generalizes the concept so that a similar
interface can also be used in other contexts. For that it introduces
new structures and related functions *without* touching the existing
struct clocksource.

The reasons for adding these new structures to clocksource.[ch] are
* the APIs are clearly related
* struct clocksource could be cleaned up to use the new structs
* avoids proliferation of files with similar names (timesource.h?
  timecounter.h?)

As outlined in the discussion with John Stultz, this patch adds
* struct cyclecounter: stateless API to hardware which counts clock cycles
* struct timecounter: stateful utility code built on a cyclecounter which
  provides a nanosecond counter
* only the function to read the nanosecond counter; deltas are used internally
  and not exposed to users of timecounter

The code does no locking of the shared state. It must be called at least
as often as the cycle counter wraps around to detect these wrap arounds.
Both is the responsibility of the timecounter user.

Acked-by: John Stultz <johnstul@us.ibm.com>
Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 include/linux/clocksource.h |  101 +++++++++++++++++++++++++++++++++++++++++++
 kernel/time/clocksource.c   |   76 ++++++++++++++++++++++++++++++++
 2 files changed, 177 insertions(+), 0 deletions(-)

diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index f88d32f..573819e 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -22,8 +22,109 @@ typedef u64 cycle_t;
 struct clocksource;
 
 /**
+ * struct cyclecounter - hardware abstraction for a free running counter
+ *	Provides completely state-free accessors to the underlying hardware.
+ *	Depending on which hardware it reads, the cycle counter may wrap
+ *	around quickly. Locking rules (if necessary) have to be defined
+ *	by the implementor and user of specific instances of this API.
+ *
+ * @read:		returns the current cycle value
+ * @mask:		bitmask for two's complement
+ *			subtraction of non 64 bit counters,
+ *			see CLOCKSOURCE_MASK() helper macro
+ * @mult:		cycle to nanosecond multiplier
+ * @shift:		cycle to nanosecond divisor (power of two)
+ */
+struct cyclecounter {
+	cycle_t (*read)(const struct cyclecounter *cc);
+	cycle_t mask;
+	u32 mult;
+	u32 shift;
+};
+
+/**
+ * struct timecounter - layer above a %struct cyclecounter which counts nanoseconds
+ *	Contains the state needed by timecounter_read() to detect
+ *	cycle counter wrap around. Initialize with
+ *	timecounter_init(). Also used to convert cycle counts into the
+ *	corresponding nanosecond counts with timecounter_cyc2time(). Users
+ *	of this code are responsible for initializing the underlying
+ *	cycle counter hardware, locking issues and reading the time
+ *	more often than the cycle counter wraps around. The nanosecond
+ *	counter will only wrap around after ~585 years.
+ *
+ * @cc:			the cycle counter used by this instance
+ * @cycle_last:		most recent cycle counter value seen by
+ *			timecounter_read()
+ * @nsec:		continuously increasing count
+ */
+struct timecounter {
+	const struct cyclecounter *cc;
+	cycle_t cycle_last;
+	u64 nsec;
+};
+
+/**
+ * cyclecounter_cyc2ns - converts cycle counter cycles to nanoseconds
+ * @tc:		Pointer to cycle counter.
+ * @cycles:	Cycles
+ *
+ * XXX - This could use some mult_lxl_ll() asm optimization. Same code
+ * as in cyc2ns, but with unsigned result.
+ */
+static inline u64 cyclecounter_cyc2ns(const struct cyclecounter *cc,
+				      cycle_t cycles)
+{
+	u64 ret = (u64)cycles;
+	ret = (ret * cc->mult) >> cc->shift;
+	return ret;
+}
+
+/**
+ * timecounter_init - initialize a time counter
+ * @tc:			Pointer to time counter which is to be initialized/reset
+ * @cc:			A cycle counter, ready to be used.
+ * @start_tstamp:	Arbitrary initial time stamp.
+ *
+ * After this call the current cycle register (roughly) corresponds to
+ * the initial time stamp. Every call to timecounter_read() increments
+ * the time stamp counter by the number of elapsed nanoseconds.
+ */
+extern void timecounter_init(struct timecounter *tc,
+			     const struct cyclecounter *cc,
+			     u64 start_tstamp);
+
+/**
+ * timecounter_read - return nanoseconds elapsed since timecounter_init()
+ *                    plus the initial time stamp
+ * @tc:          Pointer to time counter.
+ *
+ * In other words, keeps track of time since the same epoch as
+ * the function which generated the initial time stamp.
+ */
+extern u64 timecounter_read(struct timecounter *tc);
+
+/**
+ * timecounter_cyc2time - convert a cycle counter to same
+ *                        time base as values returned by
+ *                        timecounter_read()
+ * @tc:		Pointer to time counter.
+ * @cycle:	a value returned by tc->cc->read()
+ *
+ * Cycle counts that are converted correctly as long as they
+ * fall into the interval [-1/2 max cycle count, +1/2 max cycle count],
+ * with "max cycle count" == cs->mask+1.
+ *
+ * This allows conversion of cycle counter values which were generated
+ * in the past.
+ */
+extern u64 timecounter_cyc2time(struct timecounter *tc,
+				cycle_t cycle_tstamp);
+
+/**
  * struct clocksource - hardware abstraction for a free running counter
  *	Provides mostly state-free accessors to the underlying hardware.
+ *	This is the structure used for system time.
  *
  * @name:		ptr to clocksource name
  * @list:		list head for registration
diff --git a/kernel/time/clocksource.c b/kernel/time/clocksource.c
index ca89e15..c46c931 100644
--- a/kernel/time/clocksource.c
+++ b/kernel/time/clocksource.c
@@ -31,6 +31,82 @@
 #include <linux/sched.h> /* for spin_unlock_irq() using preempt_count() m68k */
 #include <linux/tick.h>
 
+void timecounter_init(struct timecounter *tc,
+		      const struct cyclecounter *cc,
+		      u64 start_tstamp)
+{
+	tc->cc = cc;
+	tc->cycle_last = cc->read(cc);
+	tc->nsec = start_tstamp;
+}
+EXPORT_SYMBOL(timecounter_init);
+
+/**
+ * timecounter_read_delta - get nanoseconds since last call of this function
+ * @tc:         Pointer to time counter
+ *
+ * When the underlying cycle counter runs over, this will be handled
+ * correctly as long as it does not run over more than once between
+ * calls.
+ *
+ * The first call to this function for a new time counter initializes
+ * the time tracking and returns an undefined result.
+ */
+static u64 timecounter_read_delta(struct timecounter *tc)
+{
+	cycle_t cycle_now, cycle_delta;
+	u64 ns_offset;
+
+	/* read cycle counter: */
+	cycle_now = tc->cc->read(tc->cc);
+
+	/* calculate the delta since the last timecounter_read_delta(): */
+	cycle_delta = (cycle_now - tc->cycle_last) & tc->cc->mask;
+
+	/* convert to nanoseconds: */
+	ns_offset = cyclecounter_cyc2ns(tc->cc, cycle_delta);
+
+	/* update time stamp of timecounter_read_delta() call: */
+	tc->cycle_last = cycle_now;
+
+	return ns_offset;
+}
+
+u64 timecounter_read(struct timecounter *tc)
+{
+	u64 nsec;
+
+	/* increment time by nanoseconds since last call */
+	nsec = timecounter_read_delta(tc);
+	nsec += tc->nsec;
+	tc->nsec = nsec;
+
+	return nsec;
+}
+EXPORT_SYMBOL(timecounter_read);
+
+u64 timecounter_cyc2time(struct timecounter *tc,
+			 cycle_t cycle_tstamp)
+{
+	u64 cycle_delta = (cycle_tstamp - tc->cycle_last) & tc->cc->mask;
+	u64 nsec;
+
+	/*
+	 * Instead of always treating cycle_tstamp as more recent
+	 * than tc->cycle_last, detect when it is too far in the
+	 * future and treat it as old time stamp instead.
+	 */
+	if (cycle_delta > tc->cc->mask / 2) {
+		cycle_delta = (tc->cycle_last - cycle_tstamp) & tc->cc->mask;
+		nsec = tc->nsec - cyclecounter_cyc2ns(tc->cc, cycle_delta);
+	} else {
+		nsec = cyclecounter_cyc2ns(tc->cc, cycle_delta) + tc->nsec;
+	}
+
+	return nsec;
+}
+EXPORT_SYMBOL(timecounter_cyc2time);
+
 /* XXX - Would like a better way for initializing curr_clocksource */
 extern struct clocksource clocksource_jiffies;
 
-- 
1.6.1.2

