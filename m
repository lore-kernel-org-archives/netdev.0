From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 6/8] x86/tsc: Always Running Timer (ART) correlated clocksource
Date: Thu,  3 Mar 2016 17:57:04 -0800
Message-ID: <1457056626-4899-7-git-send-email-john.stultz@linaro.org>
References: <1457056626-4899-1-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com, hpa@zytor.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	John Stultz <john.stultz@linaro.org>
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457056626-4899-1-git-send-email-john.stultz@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Christopher S. Hall" <christopher.s.hall@intel.com>

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

TSC_value =3D (ART_value * m) / n + k [n >=3D 1]

[k is an offset that can adjusted by a privileged agent. The
IA32_TSC_ADJUST MSR is an example of an interface to adjust k.
See 17.14.4 of the Intel SDM for more details]

Cc: Prarit Bhargava <prarit@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: kevin.b.stanton@intel.com
Cc: kevin.j.clarke@intel.com
Cc: hpa@zytor.com
Cc: jeffrey.t.kirsher@intel.com
Cc: netdev@vger.kernel.org
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
[jstultz: Tweaked to fix build issue, also reworked math for
64bit division on 32bit systems, as well as !CONFIG_CPU_FREQ build
fixes]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 arch/x86/include/asm/cpufeature.h |  2 +-
 arch/x86/include/asm/tsc.h        |  2 ++
 arch/x86/kernel/tsc.c             | 59 +++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/c=
pufeature.h
index 7ad8c94..ff557b4 100644
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
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 3d743da..80d761e 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -43,6 +43,11 @@ static DEFINE_STATIC_KEY_FALSE(__use_tsc);
=20
 int tsc_clocksource_reliable;
=20
+static u32 art_to_tsc_numerator;
+static u32 art_to_tsc_denominator;
+static u64 art_to_tsc_offset;
+struct clocksource *art_related_clocksource;
+
 /*
  * Use a ring-buffer like data structure, where a writer advances the =
head by
  * writing a new data entry and a reader advances the tail when it obs=
erves a
@@ -964,6 +969,37 @@ core_initcall(cpufreq_tsc);
=20
 #endif /* CONFIG_CPU_FREQ */
=20
+#define ART_CPUID_LEAF (0x15)
+#define ART_MIN_DENOMINATOR (1)
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
+	if (boot_cpu_data.cpuid_level < ART_CPUID_LEAF)
+		return;
+
+	cpuid(ART_CPUID_LEAF, &art_to_tsc_denominator,
+	      &art_to_tsc_numerator, unused, unused+1);
+
+	/* Don't enable ART in a VM, non-stop TSC required */
+	if (boot_cpu_has(X86_FEATURE_HYPERVISOR) ||
+	    !boot_cpu_has(X86_FEATURE_NONSTOP_TSC) ||
+	    art_to_tsc_denominator < ART_MIN_DENOMINATOR)
+		return;
+
+	if (rdmsrl_safe(MSR_IA32_TSC_ADJUST, &art_to_tsc_offset))
+		return;
+
+	/* Make this sticky over multiple CPU init calls */
+	setup_force_cpu_cap(X86_FEATURE_ART);
+}
+
+
 /* clocksource code */
=20
 static struct clocksource clocksource_tsc;
@@ -1071,6 +1107,25 @@ int unsynchronized_tsc(void)
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
+	res +=3D tmp + art_to_tsc_offset;
+
+	return (struct system_counterval_t) {.cs =3D art_related_clocksource,
+			.cycles =3D res};
+}
+EXPORT_SYMBOL(convert_art_to_tsc);
=20
 static void tsc_refine_calibration_work(struct work_struct *work);
 static DECLARE_DELAYED_WORK(tsc_irqwork, tsc_refine_calibration_work);
@@ -1142,6 +1197,8 @@ static void tsc_refine_calibration_work(struct wo=
rk_struct *work)
 		(unsigned long)tsc_khz % 1000);
=20
 out:
+	if (boot_cpu_has(X86_FEATURE_ART))
+		art_related_clocksource =3D &clocksource_tsc;
 	clocksource_register_khz(&clocksource_tsc, tsc_khz);
 }
=20
@@ -1235,6 +1292,8 @@ void __init tsc_init(void)
 		mark_tsc_unstable("TSCs unsynchronized");
=20
 	check_system_tsc_reliable();
+
+	detect_art();
 }
=20
 #ifdef CONFIG_SMP
--=20
1.9.1
