From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v7 6/8] x86: tsc: Always Running Timer (ART) correlated clocksource
Date: Fri, 12 Feb 2016 12:25:27 -0800
Message-ID: <1455308729-6280-7-git-send-email-christopher.s.hall@intel.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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

On modern Intel systems TSC is derived from the new Always Running Time=
r
(ART). ART can be captured simultaneous to the capture of
audio and network device clocks, allowing a correlation between timebas=
es
to be constructed. Upon capture, the driver converts the captured ART
value to the appropriate system clock using the correlated clocksource
mechanism.

On systems that support ART a new CPUID leaf (0x15) returns parameters
=E2=80=9Cm=E2=80=9D and =E2=80=9Cn=E2=80=9D such that:

TSC_value =3D (ART_value * m) / n + k [n >=3D 2]

[k is an offset that can adjusted by a privileged agent. The
IA32_TSC_ADJUST MSR is an example of an interface to adjust k.
See 17.14.4 of the Intel SDM for more details]

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
[jstultz: Tweaked to fix build issue, also reworked math for
64bit division on 32bit systems]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 arch/x86/include/asm/cpufeature.h |  3 ++-
 arch/x86/include/asm/tsc.h        |  2 ++
 arch/x86/kernel/cpu/scattered.c   |  1 +
 arch/x86/kernel/tsc.c             | 50 +++++++++++++++++++++++++++++++=
++++++++
 4 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/c=
pufeature.h
index 7ad8c94..111b892 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -85,7 +85,7 @@
 #define X86_FEATURE_P4		( 3*32+ 7) /* "" P4 */
 #define X86_FEATURE_CONSTANT_TSC ( 3*32+ 8) /* TSC ticks at a constant=
 rate */
 #define X86_FEATURE_UP		( 3*32+ 9) /* smp kernel running on up */
-/* free, was #define X86_FEATURE_FXSAVE_LEAK ( 3*32+10) * "" FXSAVE le=
aks FOP/FIP/FOP */
+#define X86_FEATURE_ART		(3*32+10) /* Platform has always running time=
r (ART) */
 #define X86_FEATURE_ARCH_PERFMON ( 3*32+11) /* Intel Architectural Per=
fMon */
 #define X86_FEATURE_PEBS	( 3*32+12) /* Precise-Event Based Sampling */
 #define X86_FEATURE_BTS		( 3*32+13) /* Branch Trace Store */
@@ -188,6 +188,7 @@
=20
 #define X86_FEATURE_CPB		( 7*32+ 2) /* AMD Core Performance Boost */
 #define X86_FEATURE_EPB		( 7*32+ 3) /* IA32_ENERGY_PERF_BIAS support *=
/
+#define X86_FEATURE_INVARIANT_TSC (7*32+4) /* Intel Invariant TSC */
=20
 #define X86_FEATURE_HW_PSTATE	( 7*32+ 8) /* AMD HW-PState */
 #define X86_FEATURE_PROC_FEEDBACK ( 7*32+ 9) /* AMD ProcFeedbackInterf=
ace */
diff --git a/arch/x86/include/asm/tsc.h b/arch/x86/include/asm/tsc.h
index 6d7c547..174c421 100644
--- a/arch/x86/include/asm/tsc.h
+++ b/arch/x86/include/asm/tsc.h
@@ -29,6 +29,8 @@ static inline cycles_t get_cycles(void)
 	return rdtsc();
 }
=20
+extern struct system_counterval_t convert_art_to_tsc(cycle_t art);
+
 extern void tsc_init(void);
 extern void mark_tsc_unstable(char *reason);
 extern int unsynchronized_tsc(void);
diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scat=
tered.c
index 8cb57df..af0ecd7 100644
--- a/arch/x86/kernel/cpu/scattered.c
+++ b/arch/x86/kernel/cpu/scattered.c
@@ -35,6 +35,7 @@ void init_scattered_cpuid_features(struct cpuinfo_x86=
 *c)
 		{ X86_FEATURE_APERFMPERF,	CR_ECX, 0, 0x00000006, 0 },
 		{ X86_FEATURE_EPB,		CR_ECX, 3, 0x00000006, 0 },
 		{ X86_FEATURE_HW_PSTATE,	CR_EDX, 7, 0x80000007, 0 },
+		{ X86_FEATURE_INVARIANT_TSC,	CR_EDX, 8, 0x80000007, 0 },
 		{ X86_FEATURE_CPB,		CR_EDX, 9, 0x80000007, 0 },
 		{ X86_FEATURE_PROC_FEEDBACK,	CR_EDX,11, 0x80000007, 0 },
 		{ 0, 0, 0, 0, 0 }
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 3d743da..0ee3b62 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -43,6 +43,10 @@ static DEFINE_STATIC_KEY_FALSE(__use_tsc);
=20
 int tsc_clocksource_reliable;
=20
+static u32 art_to_tsc_numerator;
+static u32 art_to_tsc_denominator;
+struct clocksource *art_related_clocksource;
+
 /*
  * Use a ring-buffer like data structure, where a writer advances the =
head by
  * writing a new data entry and a reader advances the tail when it obs=
erves a
@@ -949,10 +953,35 @@ static struct notifier_block time_cpufreq_notifie=
r_block =3D {
 	.notifier_call  =3D time_cpufreq_notifier
 };
=20
+#define ART_CPUID_LEAF (0x15)
+/* The denominator will never be less that 2 */
+#define ART_MIN_DENOMINATOR (2)
+
+
+/*
+ * If ART is present detect the numerator:denominator to convert to TS=
C
+ */
+static void detect_art(void)
+{
+	unsigned int unused[2];
+
+	if (boot_cpu_data.cpuid_level >=3D ART_CPUID_LEAF) {
+		cpuid(ART_CPUID_LEAF, &art_to_tsc_denominator,
+		      &art_to_tsc_numerator, unused, unused+1);
+
+		if (boot_cpu_has(X86_FEATURE_INVARIANT_TSC) &&
+		    art_to_tsc_denominator >=3D ART_MIN_DENOMINATOR)
+			set_cpu_cap(&boot_cpu_data, X86_FEATURE_ART);
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
@@ -1071,6 +1100,25 @@ int unsynchronized_tsc(void)
 	return 0;
 }
=20
+/*
+ * Convert ART to TSC given numerator/denominator found in detect_art(=
)
+ */
+struct system_counterval_t convert_art_to_tsc(cycle_t art)
+{
+	u64 tmp, res, rem;
+
+	rem =3D do_div(art, art_to_tsc_denominator);
+
+	res =3D art * art_to_tsc_numerator;
+	tmp =3D rem * art_to_tsc_numerator;
+
+	do_div(tmp, art_to_tsc_denominator);
+	res +=3D tmp;
+
+	return (struct system_counterval_t) {.cs =3D art_related_clocksource,
+			.cycles =3D res};
+}
+EXPORT_SYMBOL(convert_art_to_tsc);
=20
 static void tsc_refine_calibration_work(struct work_struct *work);
 static DECLARE_DELAYED_WORK(tsc_irqwork, tsc_refine_calibration_work);
@@ -1142,6 +1190,8 @@ static void tsc_refine_calibration_work(struct wo=
rk_struct *work)
 		(unsigned long)tsc_khz % 1000);
=20
 out:
+	if (boot_cpu_has(X86_FEATURE_ART))
+		art_related_clocksource =3D &clocksource_tsc;
 	clocksource_register_khz(&clocksource_tsc, tsc_khz);
 }
=20
--=20
2.1.4
