From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v3 2/4] Added ART correlated clocksource and ART CPU feature
Date: Fri, 21 Aug 2015 11:52:06 -0700
Message-ID: <1440183128-1384-3-git-send-email-christopher.s.hall@intel.com>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
Cc: richardcochran@gmail.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, peterz@infradead.org,
	"Christopher S. Hall" <christopher.s.hall@intel.com>
To: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add detect_art() call to early TSC initialization which reads ART->TSC
	numerator/denominator and sets CPU feature if present

Add convert_art_to_tsc() function performing conversion ART to TSC

Add art_timestamp referencing art_to_tsc() and clocksource_tsc enabling
	driver conversion of ART to TSC

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 arch/x86/include/asm/cpufeature.h |  3 ++-
 arch/x86/include/asm/tsc.h        |  2 ++
 arch/x86/kernel/tsc.c             | 54 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 1 deletion(-)

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
index 94605c0..8d52d91 100644
--- a/arch/x86/include/asm/tsc.h
+++ b/arch/x86/include/asm/tsc.h
@@ -45,6 +45,8 @@ static __always_inline cycles_t vget_cycles(void)
 	return (cycles_t)__native_read_tsc();
 }
 
+extern struct correlated_cs art_timestamper;
+
 extern void tsc_init(void);
 extern void mark_tsc_unstable(char *reason);
 extern int unsynchronized_tsc(void);
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 7437b41..13f12e0 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -939,10 +939,36 @@ static struct notifier_block time_cpufreq_notifier_block = {
 	.notifier_call  = time_cpufreq_notifier
 };
 
+#define ART_CPUID_LEAF (0x15)
+#define ART_MIN_DENOMINATOR (2)
+
+static u32 art_to_tsc_numerator;
+static u32 art_to_tsc_denominator;
+
+/*
+ * If ART is present detect the numberator:denominator to convert to TSC
+ */
+void detect_art(void)
+{
+	unsigned int unused[2];
+
+	if (boot_cpu_data.cpuid_level >= ART_CPUID_LEAF) {
+		cpuid(ART_CPUID_LEAF, &art_to_tsc_denominator,
+		      &art_to_tsc_numerator, unused, unused+1);
+
+		if (art_to_tsc_denominator >= ART_MIN_DENOMINATOR) {
+			set_cpu_cap(&boot_cpu_data, X86_FEATURE_ART);
+		}
+	}
+}
+
 static int __init cpufreq_tsc(void)
 {
 	if (!cpu_has_tsc)
 		return 0;
+
+	detect_art();
+
 	if (boot_cpu_has(X86_FEATURE_CONSTANT_TSC))
 		return 0;
 	cpufreq_register_notifier(&time_cpufreq_notifier_block,
@@ -1059,6 +1085,32 @@ int unsynchronized_tsc(void)
 	return 0;
 }
 
+/*
+ * Convert ART to TSC given numerator/denominator found in detect_art()
+ */
+static u64 convert_art_to_tsc(struct correlated_cs *cs, u64 cycles)
+{
+	u64 tmp, res;
+
+	switch (art_to_tsc_denominator) {
+	default:
+		res = (cycles / art_to_tsc_denominator) * art_to_tsc_numerator;
+		tmp = (cycles % art_to_tsc_denominator) * art_to_tsc_numerator;
+		res += tmp / art_to_tsc_denominator;
+		break;
+	case 2:
+	       res = (cycles >> 1) * art_to_tsc_numerator;
+	       tmp = (cycles & 0x1) * art_to_tsc_numerator;
+	       res += tmp >> 1;
+	       break;
+	}
+	return res;
+}
+
+struct correlated_cs art_timestamper = {
+	.convert	= convert_art_to_tsc,
+};
+EXPORT_SYMBOL(art_timestamper);
 
 static void tsc_refine_calibration_work(struct work_struct *work);
 static DECLARE_DELAYED_WORK(tsc_irqwork, tsc_refine_calibration_work);
@@ -1130,6 +1182,8 @@ static void tsc_refine_calibration_work(struct work_struct *work)
 		(unsigned long)tsc_khz % 1000);
 
 out:
+	if (cpu_has_art)
+		art_timestamper.related_cs = &clocksource_tsc;
 	clocksource_register_khz(&clocksource_tsc, tsc_khz);
 }
 
-- 
2.1.4
