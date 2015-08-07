From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH v2 2/4] Add ART initialization code
Date: Fri,  7 Aug 2015 16:01:33 -0700
Message-ID: <1438988495-9942-3-git-send-email-christopher.s.hall@intel.com>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add private struct correlated_ts member used by get_ts() code

added EXPORTs making get_correlated_timestamp() function and
	art_timestamper accessible

Add special case for denominator of 2 (art_to_tsc())
---
 arch/x86/include/asm/cpufeature.h |  3 ++-
 arch/x86/include/asm/tsc.h        |  1 +
 arch/x86/kernel/tsc.c             | 42 ++++++++++++++++++++++++++-------------
 include/linux/clocksource.h       |  8 +++++---
 kernel/time/timekeeping.c         |  1 +
 5 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index 3d6606f..a9322e5 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -85,7 +85,7 @@
 #define X86_FEATURE_P4		( 3*32+ 7) /* "" P4 */
 #define X86_FEATURE_CONSTANT_TSC ( 3*32+ 8) /* TSC ticks at a constant rate */
 #define X86_FEATURE_UP		( 3*32+ 9) /* smp kernel running on up */
-/* free, was #define X86_FEATURE_FXSAVE_LEAK ( 3*32+10) * "" FXSAVE leaks FOP/FIP/FOP */
+#define X86_FEATURE_ART		(3*32+10) /* Platform has always running timer (ART) */
 #define X86_FEATURE_ARCH_PERFMON ( 3*32+11) /* Intel Architectural PerfMon */
 #define X86_FEATURE_PEBS	( 3*32+12) /* Precise-Event Based Sampling */
 #define X86_FEATURE_BTS		( 3*32+13) /* Branch Trace Store */
@@ -352,6 +352,7 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
 #define cpu_has_de		boot_cpu_has(X86_FEATURE_DE)
 #define cpu_has_pse		boot_cpu_has(X86_FEATURE_PSE)
 #define cpu_has_tsc		boot_cpu_has(X86_FEATURE_TSC)
+#define cpu_has_art		boot_cpu_has(X86_FEATURE_ART)
 #define cpu_has_pge		boot_cpu_has(X86_FEATURE_PGE)
 #define cpu_has_apic		boot_cpu_has(X86_FEATURE_APIC)
 #define cpu_has_sep		boot_cpu_has(X86_FEATURE_SEP)
diff --git a/arch/x86/include/asm/tsc.h b/arch/x86/include/asm/tsc.h
index 94605c0..0089991 100644
--- a/arch/x86/include/asm/tsc.h
+++ b/arch/x86/include/asm/tsc.h
@@ -53,6 +53,7 @@ extern int check_tsc_disabled(void);
 extern unsigned long native_calibrate_tsc(void);
 
 extern int tsc_clocksource_reliable;
+extern struct correlated_cs art_timestamper;
 
 /*
  * Boot-time check whether the TSCs are synchronized across
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index a90aa6a..0a2f336 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -1059,6 +1059,9 @@ int unsynchronized_tsc(void)
 	return 0;
 }
 
+#define ART_CPUID_LEAF (0x15)
+#define ART_MIN_DENOMINATOR (2)
+
 static u32 tsc_numerator;
 static u32 tsc_denominator;
 /*
@@ -1067,19 +1070,29 @@ static u32 tsc_denominator;
  */
 static u64 tsc_adjust;
 
-static u64 art_to_tsc(u64 cycles)
+static u64 art_to_tsc(struct correlated_cs *cs, u64 cycles)
 {
 	u64 tmp, res = tsc_adjust;
 
-	res += (cycles / tsc_denominator) * tsc_numerator;
-	tmp = (cycles % tsc_denominator) * tsc_numerator;
-	res += tmp / tsc_denominator;
+	switch (tsc_denominator) {
+	default:
+		res += (cycles / tsc_denominator) * tsc_numerator;
+		tmp = (cycles % tsc_denominator) * tsc_numerator;
+		res += tmp / tsc_denominator;
+		break;
+	case 2:
+		res += (cycles >> 1) * tsc_numerator;
+		tmp = (cycles & 0x1) * tsc_numerator;
+		res += tmp >> 1;
+		break;
+	}
 	return res;
 }
 
 struct correlated_cs art_timestamper = {
 	.convert	= art_to_tsc,
 };
+EXPORT_SYMBOL(art_timestamper);
 
 static void tsc_refine_calibration_work(struct work_struct *work);
 static DECLARE_DELAYED_WORK(tsc_irqwork, tsc_refine_calibration_work);
@@ -1103,6 +1116,7 @@ static void tsc_refine_calibration_work(struct work_struct *work)
 	static int hpet;
 	u64 tsc_stop, ref_stop, delta;
 	unsigned long freq;
+	unsigned int unused[2];
 
 	/* Don't bother refining TSC on unstable systems */
 	if (check_tsc_unstable())
@@ -1150,17 +1164,17 @@ static void tsc_refine_calibration_work(struct work_struct *work)
 		(unsigned long)tsc_khz / 1000,
 		(unsigned long)tsc_khz % 1000);
 
-	/*
-	 * TODO:
-	 *
-	 * If the system has ART, initialize the art_to_tsc conversion
-	 * and set: art_timestamp.related_cs = &tsc_clocksource.
-	 *
-	 * Before that point a call to get_correlated_timestamp will
-	 * fail the clocksource match check.
-	 */
-
 out:
+	if (boot_cpu_data.cpuid_level >= ART_CPUID_LEAF) {
+		cpuid(ART_CPUID_LEAF, &tsc_denominator, &tsc_numerator, unused,
+		      unused+1);
+
+		if (tsc_denominator >= ART_MIN_DENOMINATOR) {
+			set_cpu_cap(&boot_cpu_data, X86_FEATURE_ART);
+			art_timestamper.related_cs = &clocksource_tsc;
+		}
+	}
+
 	clocksource_register_khz(&clocksource_tsc, tsc_khz);
 }
 
diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 2ed3d0c..46ce54b 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -267,7 +267,8 @@ static inline void acpi_generic_timer_init(void) { }
  */
 struct correlated_cs {
 	struct clocksource	*related_cs;
-	u64			(*convert)(u64 cycles);
+	u64			(*convert)(struct correlated_cs *cs,
+					   u64 cycles);
 };
 
 struct correlated_ts;
@@ -285,7 +286,8 @@ struct correlated_ts {
 	int			(*get_ts)(struct correlated_ts *ts);
 	u64			system_ts;
 	u64			device_ts;
-	u64			system_real;
-	u64			system_raw;
+	ktime_t			system_real;
+	ktime_t			system_raw;
+	void			*private;
 };
 #endif /* _LINUX_CLOCKSOURCE_H */
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 769a04b..abf8aec 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -946,6 +946,7 @@ int get_correlated_timestamp(struct correlated_ts *crt,
 	} while (read_seqcount_retry(&tk_core.seq, seq));
 	return 0;
 }
+EXPORT_SYMBOL(get_correlated_timestamp);
 
 /**
  * do_gettimeofday - Returns the time of day in a timeval
-- 
1.9.1
