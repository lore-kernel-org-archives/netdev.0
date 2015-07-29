From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Wed, 29 Jul 2015 12:23:27 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1507291222190.3825@nanos>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com> <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com> <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com> <CALAqxLVkwJ5cmvSZ9bL-F7YTFprZ+CvZW4MrMN0sEkk5yFqMRQ@mail.gmail.com>
 <alpine.DEB.2.11.1507291014490.3825@nanos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christopher Hall <christopher.s.hall@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1507291014490.3825@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Jul 2015, Thomas Gleixner wrote:
> On Mon, 27 Jul 2015, John Stultz wrote:
> > On Mon, Jul 27, 2015 at 8:44 PM, John Stultz <john.stultz@linaro.org> wrote:
> > > On Mon, Jul 27, 2015 at 5:46 PM, Christopher Hall
> > > <christopher.s.hall@intel.com> wrote:
> > >> * counter_to_rawmono64
> > >> * counter_to_mono64
> > >> * counter_to_realtime64
> > >>
> > >> Enables drivers to translate a captured system clock counter to system
> > >> time. This is useful for network and audio devices that capture timestamps
> > >> in terms of both the system clock and device clock.
> > >
> > > Huh.  So for counter_to_realtime64 & mono64, this seems to ignore the
> > > fact that the multiplier is constantly adjusted and corrected. So that
> > > calling the function twice with the same counter value may result in
> > > different returned values.
> > >
> > > I've not yet groked the whole patchset, but it seems like there needs
> > > to be some mechanism that ensures the counter value is captured and
> > > used in the same (or at least close) interval that the timekeeper data
> > > is valid for.
> > 
> > 
> > So reading through. It looks like you only use art_to_realtime(), right?
> > 
> > So again, since CLOCK_MONOTONIC and CLOCK_REALTIME are constaly being
> > frequency adjusted, it might be best to construct this delta in the
> > following way.
> > 
> > 
> > Add counter_to_rawmono64(), which should be able to safely calculate
> > the corresponding CLOCK_MONOTONIC_RAW time from any given cycle value.
> > 
> > Use getnstime_raw_and_real() to get a immediate snapshot of current
> > MONOTONIC_RAW  and REALTIME clocks.
> > 
> > Then calculate the delta between the snapshotted counter raw time, and
> > the current raw time.  Then apply that offset to the current realtime.
> > 
> > The larger the raw-time delta, the larger the possible realtime error.
> > But I think that will be as good as it gets.
> 
> I think that's still not the right approach. The whole purpose of this
> is to get a precise snapshot of 
> 
>    - PTP time from the ETH device
> and
>    - current system time
> 
> Right now this does
> 
>       ktime_get_real();
>       read_ptp_time();
> 
> which is obviously not precise.
> 
> The new hardware allows you to latch PTP time and ART time atomically
> in the ETH device and read them out.
> 
> ART is the base clock of the TSC where
> 
>     TSC = K + (ART * n) / d;
> 
> So for this to work proper, we need a function which converts ART to
> TSC. This is obviously x86/TSC specific code.
> 
> Now on the PTP side we need a callback provided by the device driver
> to get the snapshot of the PTP and the ART.
> 
> So the proposed implementation merily calls that callback from the PTP
> ioctl and then tries to do a magic CLOCK_REALTIME conversion of the
> ART value. But that's just wrong as it does not guarantee a proper
> correlation to the core timekeeping.
> 
> So what we really need is a function in the timekeeper core which gets
> the PTP/ART timestamps from the device under the timekeeper sequence
> counter and converts to clock realtime and raw monotonic.
> 
> That function is then called from the PTP ioctl.
> 
> Anything else is just 'lets hope it works and is precise enough'
> voodoo.
> 
> Something like the below untested patch should be all we need for PTP
> to be as precise as possible.
> 
> I don't know whether we need functionality to convert arbitrary
> timestamps at all, but if we really need them then they are going to
> be pretty simple and explicitely not precise for anything else than
> clock monotonic raw. But that's a different story.
> 
> Lets concentrate on PTP first and talk about the other stuff once we
> settled the use case which actually has a precision requirement.

Gah crap. Picked a stale version of the patch.
 
Thanks,

	tglx

----------------------------------------->
Subject: ptp: Get sync timestamps
From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 29 Jul 2015 10:52:06 +0200

The ART stuff wants to be splitted out.

Not-Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/kernel/tsc.c       |   31 +++++++++++++++++++++
 include/linux/clocksource.h |   30 ++++++++++++++++++++
 include/linux/timekeeping.h |    4 ++
 kernel/time/timekeeping.c   |   63 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 128 insertions(+)

Index: linux/arch/x86/kernel/tsc.c
===================================================================
--- linux.orig/arch/x86/kernel/tsc.c
+++ linux/arch/x86/kernel/tsc.c
@@ -1059,6 +1059,27 @@ int unsynchronized_tsc(void)
 	return 0;
 }
 
+static u32 tsc_numerator;
+static u32 tsc_denominator;
+/*
+ * CHECKME: Do we need the adjust value? It should be 0, but if we run
+ * in a VM this might be a different story.
+ */
+static u64 tsc_adjust;
+
+static u64 art_to_tsc(u64 cycles)
+{
+	u64 tmp, res = tsc_adjust;
+
+	res += (cycles / tsc_denominator) * tsc_numerator;
+	tmp = (cycles % tsc_denominator) * tsc_numerator;
+	res += tmp / tsc_denominator;
+	return res;
+}
+
+struct correlated_cs art_timestamper = {
+	.convert	= art_to_tsc,
+};
 
 static void tsc_refine_calibration_work(struct work_struct *work);
 static DECLARE_DELAYED_WORK(tsc_irqwork, tsc_refine_calibration_work);
@@ -1129,6 +1150,16 @@ static void tsc_refine_calibration_work(
 		(unsigned long)tsc_khz / 1000,
 		(unsigned long)tsc_khz % 1000);
 
+	/*
+	 * TODO:
+	 *
+	 * If the system has ART, initialize the art_to_tsc conversion
+	 * and set: art_timestamp.related_cs = &tsc_clocksource.
+	 *
+	 * Before that point a call to get_correlated_timestamp will
+	 * fail the clocksource match check.
+	 */
+
 out:
 	clocksource_register_khz(&clocksource_tsc, tsc_khz);
 }
Index: linux/include/linux/clocksource.h
===================================================================
--- linux.orig/include/linux/clocksource.h
+++ linux/include/linux/clocksource.h
@@ -258,4 +258,34 @@ void acpi_generic_timer_init(void);
 static inline void acpi_generic_timer_init(void) { }
 #endif
 
+/**
+ * struct correlated_cs - Descriptor for a clocksource correlated to another clocksource
+ * @related_cs:		Pointer to the related timekeeping clocksource
+ * @convert:		Conversion function to convert a timestamp from
+ *			the correlated clocksource to cycles of the related
+ *			timekeeping clocksource
+ */
+struct correlated_cs {
+	struct clocksource	*related_cs;
+	u64			(*convert)(u64 cycles);
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
+	u64			system_real;
+	u64			system_raw;
+};
 #endif /* _LINUX_CLOCKSOURCE_H */
Index: linux/include/linux/timekeeping.h
===================================================================
--- linux.orig/include/linux/timekeeping.h
+++ linux/include/linux/timekeeping.h
@@ -258,6 +258,10 @@ extern void timekeeping_inject_sleeptime
  */
 extern void getnstime_raw_and_real(struct timespec *ts_raw,
 				   struct timespec *ts_real);
+struct correlated_ts;
+struct correlated_cs;
+extern int get_correlated_timestamp(struct correlated_ts *crt,
+				    struct correlated_cs *crs);
 
 /*
  * Persistent clock related interfaces
Index: linux/kernel/time/timekeeping.c
===================================================================
--- linux.orig/kernel/time/timekeeping.c
+++ linux/kernel/time/timekeeping.c
@@ -312,6 +312,19 @@ static inline s64 timekeeping_get_ns(str
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
@@ -885,6 +898,56 @@ EXPORT_SYMBOL(getnstime_raw_and_real);
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
+		base = ktime_add(tk->tkr_mono.base, tk_core.timekeeper.offs_real);
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
+
+/**
  * do_gettimeofday - Returns the time of day in a timeval
  * @tv:		pointer to the timeval to be set
  *
