From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH 3/5] Add calls to translate Always Running Timer (ART) to system time
Date: Mon, 27 Jul 2015 17:46:54 -0700
Message-ID: <1438044416-15588-4-git-send-email-christopher.s.hall@intel.com>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* art_to_mono64
* art_to_rawmono64
* art_to_realtime64

Intel audio and PCH ethernet devices use the Always Running Timer (ART) to
relate their device clock to system time

Signed-off-by: Christopher Hall <christopher.s.hall@intel.com>
---
 arch/x86/Kconfig           |  12 ++++
 arch/x86/include/asm/art.h |  42 ++++++++++++++
 arch/x86/kernel/Makefile   |   1 +
 arch/x86/kernel/art.c      | 134 +++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/tsc.c      |   4 ++
 5 files changed, 193 insertions(+)
 create mode 100644 arch/x86/include/asm/art.h
 create mode 100644 arch/x86/kernel/art.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b3a1a5d..1ef9985 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1175,6 +1175,18 @@ config X86_CPUID
 	  with major 203 and minors 0 to 31 for /dev/cpu/0/cpuid to
 	  /dev/cpu/31/cpuid.
 
+config X86_ART
+	bool "Always Running Timer"
+	default y
+	depends on X86_TSC
+	---help---
+	  This option provides functionality to drivers and devices that use
+	  the always-running-timer (ART) to correlate their device clock
+	  counter with the system clock counter. The TSC is *exactly* related
+	  to the ART by a ratio m/n specified by CPUID leaf 0x15
+	  (n=EAX,m=EBX). If ART is unused or unavailable there isn't any
+	  performance impact. It's safe to say Y.
+
 choice
 	prompt "High Memory Support"
 	default HIGHMEM4G
diff --git a/arch/x86/include/asm/art.h b/arch/x86/include/asm/art.h
new file mode 100644
index 0000000..da58ce4
--- /dev/null
+++ b/arch/x86/include/asm/art.h
@@ -0,0 +1,42 @@
+/*
+ * x86 ART related functions
+ */
+#ifndef _ASM_X86_ART_H
+#define _ASM_X86_ART_H
+
+#ifndef CONFIG_X86_ART
+
+static inline int setup_art(void)
+{
+	return 0;
+}
+
+static inline bool has_art(void)
+{
+	return false;
+}
+
+static inline int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art)
+{
+	return -ENXIO;
+}
+static inline int art_to_realtime64(struct timespec64 *realtime, cycle_t art)
+{
+	return -ENXIO;
+}
+static inline int art_to_mono64(struct timespec64 *mono, cycle_t art)
+{
+	return -ENXIO;
+}
+
+#else
+
+extern int setup_art(void);
+extern bool has_art(void);
+extern int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art);
+extern int art_to_realtime64(struct timespec64 *realtime, cycle_t art);
+extern int art_to_mono64(struct timespec64 *mono, cycle_t art);
+
+#endif
+
+#endif/*_ASM_X86_ART_H*/
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 0f15af4..0908311 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -109,6 +109,7 @@ obj-$(CONFIG_PERF_EVENTS)		+= perf_regs.o
 obj-$(CONFIG_TRACING)			+= tracepoint.o
 obj-$(CONFIG_IOSF_MBI)			+= iosf_mbi.o
 obj-$(CONFIG_PMC_ATOM)			+= pmc_atom.o
+obj-$(CONFIG_X86_ART)			+= art.o
 
 ###
 # 64 bit specific files
diff --git a/arch/x86/kernel/art.c b/arch/x86/kernel/art.c
new file mode 100644
index 0000000..1906cf0
--- /dev/null
+++ b/arch/x86/kernel/art.c
@@ -0,0 +1,134 @@
+#include <asm/tsc.h>
+#include <asm/cpufeature.h>
+#include <asm/processor.h>
+#include <linux/spinlock.h>
+#include <linux/seqlock.h>
+
+#define CPUID_ART_LEAF 0x15
+
+static bool art_present;
+
+static struct art_state {
+	seqcount_t seq;
+	u32 art_ratio_numerator;
+	u32 art_ratio_denominator;
+
+	cycle_t prev_art;
+	cycle_t prev_tsc_corr_art; /*This is the TSC value corresponding to
+				     prev_art */
+	u32 tsc_remainder;
+} art_state ____cacheline_aligned;
+
+static DEFINE_RAW_SPINLOCK(art_lock);
+
+#define MIN_DENOMINATOR 2
+int setup_art(void)
+{
+	if (boot_cpu_data.cpuid_level < CPUID_ART_LEAF)
+		return 0;
+	art_state.art_ratio_denominator = cpuid_eax(CPUID_ART_LEAF);
+	if (art_state.art_ratio_denominator < MIN_DENOMINATOR)
+		return 0;
+	art_state.art_ratio_numerator = cpuid_ebx(CPUID_ART_LEAF);
+
+	art_present = true;
+	return 0;
+}
+
+static bool has_art(void)
+{
+	return art_present;
+}
+EXPORT_SYMBOL(has_art);
+
+#define ROLLOVER_THRESHOLD (2ULL << 23)
+
+static u32 art_scale(struct art_state *art_state, cycle_t *art)
+{
+	u32 rem;
+
+	*art *= art_state->art_ratio_numerator;
+
+	switch (art_state->art_ratio_denominator) {
+	default:
+		rem = do_div(*art, art_state->art_ratio_denominator);
+	case 2:
+		rem = *art & 0x1;
+		*art >>= 1;
+	}
+	return rem + art_state->tsc_remainder;
+}
+
+static cycle_t art_to_tsc(cycle_t art)
+{
+	unsigned seq;
+	cycle_t tsc_next;
+	u32 rem_next;
+	bool backward = false;
+	unsigned long flags;
+
+	do {
+		seq = read_seqcount_begin(&art_state.seq);
+
+		if (art < art_state.prev_art &&
+		    art_state.prev_art - art < ROLLOVER_THRESHOLD) {
+			tsc_next = (art_state.prev_art-art);
+			art_scale(&art_state, &tsc_next);
+			tsc_next = art_state.prev_tsc_corr_art - tsc_next;
+			backward = true;
+		} else {
+			tsc_next = art - art_state.prev_art;
+			rem_next = art_scale(&art_state, &tsc_next);
+			tsc_next += art_state.prev_tsc_corr_art;
+
+			tsc_next += rem_next /
+				art_state.art_ratio_denominator;
+			rem_next %= art_state.art_ratio_denominator;
+		}
+	} while (read_seqcount_retry(&art_state.seq, seq));
+
+	/* There's no need to update after every read, if an update is
+	   already in progress by someone else just exit */
+	if (!backward && raw_spin_trylock_irqsave(&art_lock, flags)) {
+		write_seqcount_begin(&art_state.seq);
+		art_state.prev_art = art;
+		art_state.prev_tsc_corr_art = tsc_next;
+		art_state.tsc_remainder = rem_next;
+		write_seqcount_end(&art_state.seq);
+		raw_spin_unlock_irqrestore(&art_lock, flags);
+	}
+
+	return tsc_next;
+}
+
+static bool checked_art_to_tsc(cycle_t *tsc)
+{
+	if (!has_art())
+		return false;
+	*tsc = art_to_tsc(*tsc);
+	return true;
+}
+
+static int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art)
+{
+	if (!checked_art_to_tsc(&art))
+		return -ENXIO;
+	return tsc_to_rawmono64(rawmono, art);
+}
+EXPORT_SYMBOL(art_to_rawmono64);
+
+static int art_to_realtime64(struct timespec64 *realtime, cycle_t art)
+{
+	if (!checked_art_to_tsc(&art))
+		return -ENXIO;
+	return tsc_to_realtime64(realtime, art);
+}
+EXPORT_SYMBOL(art_to_realtime64);
+
+static int art_to_mono64(struct timespec64 *mono, cycle_t art)
+{
+	if (!checked_art_to_tsc(&art))
+		return -ENXIO;
+	return tsc_to_mono64(mono, art);
+}
+EXPORT_SYMBOL(art_to_mono64);
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index a192271..828c4b3 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -22,6 +22,8 @@
 #include <asm/nmi.h>
 #include <asm/x86_init.h>
 
+#include <asm/art.h>
+
 unsigned int __read_mostly cpu_khz;	/* TSC clocks / usec, not used here */
 EXPORT_SYMBOL(cpu_khz);
 
@@ -1177,6 +1179,8 @@ static int __init init_tsc_clocksource(void)
 		return 0;
 	}
 
+	setup_art();
+
 	schedule_delayed_work(&tsc_irqwork, 0);
 	return 0;
 }
-- 
1.9.1
