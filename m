From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [RFC v5 2/6] Always Running Timer (ART) correlated clocksource
Date: Mon,  4 Jan 2016 04:45:19 -0800
Message-ID: <1451911523-8534-3-git-send-email-christopher.s.hall@intel.com>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
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
---
 arch/x86/include/asm/cpufeature.h |  2 +-
 arch/x86/include/asm/tsc.h        |  2 ++
 arch/x86/kernel/tsc.c             | 46 +++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 49 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/c=
pufeature.h
index e4f8010..58c799e 100644
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
index 6d7c547..9474c9c 100644
--- a/arch/x86/include/asm/tsc.h
+++ b/arch/x86/include/asm/tsc.h
@@ -29,6 +29,8 @@ static inline cycles_t get_cycles(void)
 	return rdtsc();
 }
=20
+extern struct correlated_cs art_timestamper;
+
 extern void tsc_init(void);
 extern void mark_tsc_unstable(char *reason);
 extern int unsynchronized_tsc(void);
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index c7c4d9c..26dcf63 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -949,10 +949,36 @@ static struct notifier_block time_cpufreq_notifie=
r_block =3D {
 	.notifier_call  =3D time_cpufreq_notifier
 };
=20
+#define ART_CPUID_LEAF (0x15)
+/* The denominator will never be less that 2 */
+#define ART_MIN_DENOMINATOR (2)
+
+static u32 art_to_tsc_numerator;
+static u32 art_to_tsc_denominator;
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
+		if (art_to_tsc_denominator >=3D ART_MIN_DENOMINATOR)
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
@@ -1071,6 +1097,24 @@ int unsynchronized_tsc(void)
 	return 0;
 }
=20
+/*
+ * Convert ART to TSC given numerator/denominator found in detect_art(=
)
+ */
+static u64 convert_art_to_tsc(struct correlated_cs *cs, u64 cycles)
+{
+	u64 tmp, res;
+
+	res =3D (cycles / art_to_tsc_denominator) * art_to_tsc_numerator;
+	tmp =3D (cycles % art_to_tsc_denominator) * art_to_tsc_numerator;
+	res +=3D tmp / art_to_tsc_denominator;
+
+	return res;
+}
+
+struct correlated_cs art_timestamper =3D {
+	.convert	=3D convert_art_to_tsc,
+};
+EXPORT_SYMBOL(art_timestamper);
=20
 static void tsc_refine_calibration_work(struct work_struct *work);
 static DECLARE_DELAYED_WORK(tsc_irqwork, tsc_refine_calibration_work);
@@ -1142,6 +1186,8 @@ static void tsc_refine_calibration_work(struct wo=
rk_struct *work)
 		(unsigned long)tsc_khz % 1000);
=20
 out:
+	if (boot_cpu_has(X86_FEATURE_ART))
+		art_timestamper.related_cs =3D &clocksource_tsc;
 	clocksource_register_khz(&clocksource_tsc, tsc_khz);
 }
=20
--=20
2.1.4
